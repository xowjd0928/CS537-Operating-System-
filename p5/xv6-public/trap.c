#include "types.h"
#include "defs.h"
#include "param.h"
#include "memlayout.h"
#include "mmu.h"
#include "proc.h"
#include "x86.h"
#include "traps.h"
#include "fs.h"
#include "spinlock.h"
#include "sleeplock.h"
#include "file.h"

// Interrupt descriptor table (shared by all CPUs).
struct gatedesc idt[256];
extern uint vectors[];  // in vectors.S: array of 256 entry pointers
struct spinlock tickslock;
uint ticks;

void
tvinit(void)
{
  int i;

  for(i = 0; i < 256; i++)
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);

  initlock(&tickslock, "time");
}

void
idtinit(void)
{
  lidt(idt, sizeof(idt));
}

//PAGEBREAK: 41
void trap(struct trapframe *tf) {
    struct proc *curproc = myproc();

    if(tf->trapno == T_SYSCALL){
        if(curproc->killed)
            exit();
        curproc->tf = tf;
        syscall();
        if(curproc->killed)
            exit();
        return;
    }

    switch(tf->trapno){
    case T_IRQ0 + IRQ_TIMER:
        if(cpuid() == 0){
            acquire(&tickslock);
            ticks++;
            wakeup(&ticks);
            release(&tickslock);
        }
        lapiceoi();
        break;

    case T_IRQ0 + IRQ_IDE:
        ideintr();
        lapiceoi();
        break;

    case T_IRQ0 + IRQ_IDE+1:
        // Bochs generates spurious IDE1 interrupts.
        break;

    case T_IRQ0 + IRQ_KBD:
        kbdintr();
        lapiceoi();
        break;

    case T_IRQ0 + IRQ_COM1:
        uartintr();
        lapiceoi();
        break;

    case T_IRQ0 + 7:
    case T_IRQ0 + IRQ_SPURIOUS:
        cprintf("cpu%d: spurious interrupt at %x:%x\n",
                cpuid(), tf->cs, tf->eip);
        lapiceoi();
        break;

case T_PGFLT: {
    uint fault_addr = rcr2();                // Address that caused the page fault
    uint page_addr = PGROUNDDOWN(fault_addr); // Align to page boundary

    cprintf("Page fault at va=0x%x\n", fault_addr);

    if (fault_addr < 0x60000000) { // Apply COW logic
        pte_t *pte = walkpgdir(curproc->pgdir, (void *)fault_addr, 0);
        if (!(*pte & PTE_P) || !*pte) {
    cprintf("Page fault: PTE not present at va=0x%x, pte=0x%x\n", fault_addr, *pte);
    curproc->killed = 1;
    return;
}
        

        uint pa = PTE_ADDR(*pte); // Get the physical address
        cprintf("PTE found: pa=0x%x, flags=0x%x\n", pa, *pte);

        if (*pte & PTE_COW) { // Check if it's a COW page
            if (get_ref(pa) == 1) { // Reference count == 1
                *pte |= PTE_W;      // Make page writable
                *pte &= ~PTE_COW;   // Remove COW flag
                lcr3(V2P(curproc->pgdir)); // Flush TLB
                cprintf("COW: Made writable, va=0x%x, pa=0x%x\n", fault_addr, pa);
                return;
            } else { // Reference count > 1: Duplicate page
                char *new_page = kalloc();
                if (!new_page) {
                    cprintf("Page fault: Out of memory\n");
                    curproc->killed = 1;
                    return;
                }

                // Copy content from the original page
                memmove(new_page, (char *)P2V(pa), PGSIZE);

                // Update PTE to point to the new page
                *pte = V2P(new_page) | PTE_FLAGS(*pte);
                *pte |= PTE_W;      // Make writable
                *pte &= ~PTE_COW;   // Remove COW flag
                lcr3(V2P(curproc->pgdir)); // Flush TLB
                // Decrement reference count for the old page
                dec_ref(pa);
                if (get_ref(pa) == 0) {
                    kfree((char *)P2V(pa)); // Free if no references remain
                }
                cprintf("COW: Duplicated page, va=0x%x, new_pa=0x%x\n", fault_addr, V2P(new_page));
                return;
            }
        } else {
            // Non-COW fault: Check if it's a legitimate user-space page fault
            cprintf("Page fault: Non-COW fault at va=0x%x\n", fault_addr);
            curproc->killed = 1; // Kill process for invalid non-COW access
            return;
        }
    }
    
    struct mmap_region *region = 0;

    // Check if fault_addr falls within any memory-mapped region
    for (int i = 0; i < curproc->num_mmap_regions; i++) {
        uint start = curproc->mmap_regions[i].start_addr;
        uint end = start + curproc->mmap_regions[i].length;
        if (fault_addr >= start && fault_addr < end) {
            region = &curproc->mmap_regions[i];
            break;
        }
    }

    if (region) {
        // Allocate a physical page for the faulting address
        char *mem = kalloc();
        if (!mem) {
            cprintf("trap: out of memory\n");
            curproc->killed = 1;
            return;
        }
        
        if (!(region->flags & MAP_ANONYMOUS) && region->fd >= 0) {
            struct file *f = curproc->ofile[region->fd];
            if (!f) {
            cprintf("trap: file descriptor %d not associated with any file\n", region->fd);
            kfree(mem);
            curproc->killed = 1;
            return;
            }
            if (!f->ip) {
            cprintf("trap: file descriptor %d has no inode\n", region->fd);
            kfree(mem);
            curproc->killed = 1;
            return;
            }

            int file_offset = page_addr - region->start_addr;

            // Validate file offset
            if (file_offset >= f->ip->size) {
                memset(mem, 0, PGSIZE);  // Clear page for out-of-bounds accesses
            } else {
                int bytes_to_read = PGSIZE;
                if (file_offset + PGSIZE > f->ip->size) {
                    bytes_to_read = f->ip->size - file_offset;
                }

                memset(mem, 0, PGSIZE);  // Clear the page first

                // Use readi directly for safe inode-based read
                ilock(f->ip);
                if (readi(f->ip, mem, file_offset, bytes_to_read) != bytes_to_read) {
                    iunlock(f->ip);
                    kfree(mem);
                    cprintf("trap: readi failed at offset %d\n", file_offset);
                    curproc->killed = 1;
                    return;
                }
                iunlock(f->ip);

                // Zero out remaining memory if partial read
                if (bytes_to_read < PGSIZE) {
                    memset(mem + bytes_to_read, 0, PGSIZE - bytes_to_read);
                }
            }
        } else {
            // Anonymous mapping
            memset(mem, 0, PGSIZE);  // Clear the page for anonymous mappings
        }

        // Map the newly allocated page to the faulting virtual address
        if (mappages(curproc->pgdir, (char *)page_addr, PGSIZE, V2P(mem), PTE_W | PTE_U) < 0) {
            kfree(mem);
            cprintf("trap: mappages failed\n");
            curproc->killed = 1;
            return;
        }

        // Increment the count of loaded pages in the mapped region
        region->n_loaded_pages++;
        return; // Resume execution after handling the page fault
    }

    // If fault address is not part of any mapped region, mark process as killed
    cprintf("Page fault: Segmentation Fault at 0x%x\n", fault_addr);
    curproc->killed = 1;
    break;
}

    default:
        if(curproc == 0 || (tf->cs&3) == 0){
            // In kernel, it must be our mistake.
            cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
                    tf->trapno, cpuid(), tf->eip, rcr2());
            panic("trap");
        }
        // In user space, assume process misbehaved.
        cprintf("pid %d %s: trap %d err %d on cpu %d "
                "eip 0x%x addr 0x%x--kill proc\n",
                curproc->pid, curproc->name, tf->trapno,
                tf->err, cpuid(), tf->eip, rcr2());
        curproc->killed = 1;
    }

    // Force process exit if it has been killed and is in user space.
    if(curproc && curproc->killed && (tf->cs&3) == DPL_USER)
        exit();

    // Force process to give up CPU on clock tick.
    if(curproc && curproc->state == RUNNING && tf->trapno == T_IRQ0+IRQ_TIMER)
        yield();

    // Check if the process has been killed since we yielded
    if(curproc && curproc->killed && (tf->cs&3) == DPL_USER)
        exit();
}