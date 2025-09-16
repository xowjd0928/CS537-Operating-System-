#include "types.h"
#include "x86.h"
#include "defs.h"
#include "date.h"
#include "param.h"
#include "memlayout.h"
#include "mmu.h"
#include "proc.h"
#include "fs.h"
#include "spinlock.h"
#include "sleeplock.h"
#include "file.h"

int
sys_fork(void)
{
  return fork();
}

int
sys_exit(void)
{
  exit();
  return 0;  // not reached
}

int
sys_wait(void)
{
  return wait();
}

int
sys_kill(void)
{
  int pid;

  if(argint(0, &pid) < 0)
    return -1;
  return kill(pid);
}

int
sys_getpid(void)
{
  return myproc()->pid;
}

int
sys_sbrk(void)
{
  int addr;
  int n;

  if(argint(0, &n) < 0)
    return -1;
  addr = myproc()->sz;
  if(growproc(n) < 0)
    return -1;
  return addr;
}

int
sys_sleep(void)
{
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
    return -1;
  acquire(&tickslock);
  ticks0 = ticks;
  while(ticks - ticks0 < n){
    if(myproc()->killed){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
  }
  release(&tickslock);
  return 0;
}

// return how many clock tick interrupts have occurred
// since start.
int
sys_uptime(void)
{
  uint xticks;

  acquire(&tickslock);
  xticks = ticks;
  release(&tickslock);
  return xticks;
}

uint
sys_wmap(void) {
    uint addr;
    int length, flags, fd;

    if (argint(0, (int*)&addr) < 0 || argint(1, &length) < 0 || argint(2, &flags) < 0 || argint(3, &fd) < 0) {
        return FAILED;
    }

    // Basic validation checks
    if (length <= 0 || !(flags & MAP_FIXED) || !(flags & MAP_SHARED)) {
        return FAILED;
    }

    // Validate address if MAP_FIXED is set
    if (addr < 0x60000000 || addr >= 0x80000000) {
        return FAILED;
    }

    return proc_wmap(addr, length, flags, fd);
    return FAILED;
}

// System call to remove a memory mapping
int
sys_wunmap(void) {
    uint addr;
    if (argint(0, (int*)&addr) < 0) {
        return FAILED;
    }

    struct proc *curproc = myproc();
    struct mmap_region *region = 0;
    int region_index = -1;

    // Find the region with the matching start address
    for (int i = 0; i < curproc->num_mmap_regions; i++) {
        if (curproc->mmap_regions[i].start_addr == addr) {
            region = &curproc->mmap_regions[i];
            region_index = i;
            break;
        }
    }

    // Check if a valid mapping was found and if addr is page-aligned
    if (!region || addr % PGSIZE != 0) {
        return FAILED;
    }

    // Handle MAP_SHARED mappings
    if (region->flags & MAP_SHARED) {
        if (region->fd >= 0) {
            // File-backed mapping: write back changes to the file
            struct file *f = curproc->ofile[region->fd];
            if (f) {
                for (uint va = region->start_addr; va < region->start_addr + region->length; va += PGSIZE) {
                    pte_t *pte = walkpgdir(curproc->pgdir, (void *)va, 0);
                    if (pte && (*pte & PTE_P)) {
                        uint pa = PTE_ADDR(*pte);
                        char *page_addr = (char *)P2V(pa);

                        // Calculate file offset and write back the page
                        uint file_offset = va - region->start_addr;
                        f->off = file_offset;
                        if (filewrite(f, page_addr, PGSIZE) != PGSIZE) {
                            cprintf("wunmap: Failed to write back page at va=0x%x\n", va);
                            return FAILED;
                        }
                    }
                }
            }
        } else {
            // Anonymous mapping: propagate shared changes if necessary
            for (uint va = region->start_addr; va < region->start_addr + region->length; va += PGSIZE) {
                pte_t *pte = walkpgdir(curproc->pgdir, (void *)va, 0);
                if (pte && (*pte & PTE_P)) {
                    // Ensure changes are propagated for shared anonymous memory
                    *pte = 0;  // Clear the page table entry
                }
            }
        }
    }

    // Unmap and free each page in the mapping
    for (uint va = region->start_addr; va < region->start_addr + region->length; va += PGSIZE) {
        pte_t *pte = walkpgdir(curproc->pgdir, (void*)va, 0);
        if (pte && (*pte & PTE_P)) {
            uint pa = PTE_ADDR(*pte);
            kfree(P2V(pa));      // Free the physical page
            *pte = 0;            // Clear the page table entry
        }
    }

    // Remove the mapping from the process's list by shifting entries
    for (int j = region_index; j < curproc->num_mmap_regions - 1; j++) {
        curproc->mmap_regions[j] = curproc->mmap_regions[j + 1];
    }
    curproc->num_mmap_regions--;

    // Flush TLB to ensure changes take effect
    lcr3(V2P(curproc->pgdir));

    return SUCCESS;
}

uint
sys_va2pa(void) {
    uint va;
    if (argint(0, (int*)&va) < 0) {
        return -1;
    }

    struct proc *curproc = myproc();
    pte_t *pte = walkpgdir(curproc->pgdir, (void*)va, 0);
    
    // Check if the page table entry exists and is present
    if (pte && (*pte & PTE_P)) {
        uint pa = PTE_ADDR(*pte);  // Get the page frame number (base physical address)
        uint offset = va % PGSIZE; // Calculate the offset within the page
        return pa + offset;        // Return the full physical address
    }

    // If the virtual address does not map to a physical address, return -1
    return FAILED;
}

int 
sys_getwmapinfo(void) {
    struct wmapinfo *wminfo;

    // Retrieve the user-provided pointer for wmapinfo structure
    if (argptr(0, (void*)&wminfo, sizeof(*wminfo)) < 0)
        return FAILED;

    struct proc *curproc = myproc();
    int num_mmaps = curproc->num_mmap_regions;

    // Populate the wmapinfo structure with mappings information
    wminfo->total_mmaps = num_mmaps;

    for (int i = 0; i < num_mmaps && i < MAX_WMMAP_INFO; i++) {
        struct mmap_region *region = &curproc->mmap_regions[i];
        wminfo->addr[i] = region->start_addr;
        wminfo->length[i] = region->length;

        // Calculate the number of loaded (physically allocated) pages in this mapping
        int loaded_pages = 0;
        for (uint va = region->start_addr; va < region->start_addr + region->length; va += PGSIZE) {
            pte_t *pte = walkpgdir(curproc->pgdir, (void*)va, 0);
            if (pte && (*pte & PTE_P)) {  // Check if page is present
                loaded_pages++;
            }
        }
        wminfo->n_loaded_pages[i] = loaded_pages;
    }

    return SUCCESS;
}