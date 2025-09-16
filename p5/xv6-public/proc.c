#include "types.h"
#include "defs.h"
#include "param.h"
#include "memlayout.h"
#include "mmu.h"
#include "x86.h"
#include "proc.h"
#include "fs.h"
#include "spinlock.h"
#include "sleeplock.h"
#include "file.h"

struct {
  struct spinlock lock;
  struct proc proc[NPROC];
} ptable;

static struct proc *initproc;

int nextpid = 1;
extern void forkret(void);
extern void trapret(void);

static void wakeup1(void *chan);

void
pinit(void)
{
  initlock(&ptable.lock, "ptable");
}

// Must be called with interrupts disabled
int
cpuid() {
  return mycpu()-cpus;
}

// Must be called with interrupts disabled to avoid the caller being
// rescheduled between reading lapicid and running through the loop.
struct cpu*
mycpu(void)
{
  int apicid, i;
  
  if(readeflags()&FL_IF)
    panic("mycpu called with interrupts enabled\n");
  
  apicid = lapicid();
  // APIC IDs are not guaranteed to be contiguous. Maybe we should have
  // a reverse map, or reserve a register to store &cpus[i].
  for (i = 0; i < ncpu; ++i) {
    if (cpus[i].apicid == apicid)
      return &cpus[i];
  }
  panic("unknown apicid\n");
}

// Disable interrupts so that we are not rescheduled
// while reading proc from the cpu structure
struct proc*
myproc(void) {
  struct cpu *c;
  struct proc *p;
  pushcli();
  c = mycpu();
  p = c->proc;
  popcli();
  return p;
}

//PAGEBREAK: 32
// Look in the process table for an UNUSED proc.
// If found, change state to EMBRYO and initialize
// state required to run in the kernel.
// Otherwise return 0.
static struct proc*
allocproc(void)
{
  struct proc *p;
  char *sp;

  acquire(&ptable.lock);

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
    if(p->state == UNUSED)
      goto found;

  release(&ptable.lock);
  return 0;

found:
  p->state = EMBRYO;
  p->pid = nextpid++;

  release(&ptable.lock);

  // Allocate kernel stack.
  if((p->kstack = kalloc()) == 0){
    p->state = UNUSED;
    return 0;
  }
  sp = p->kstack + KSTACKSIZE;

  // Leave room for trap frame.
  sp -= sizeof *p->tf;
  p->tf = (struct trapframe*)sp;

  // Set up new context to start executing at forkret,
  // which returns to trapret.
  sp -= 4;
  *(uint*)sp = (uint)trapret;

  sp -= sizeof *p->context;
  p->context = (struct context*)sp;
  memset(p->context, 0, sizeof *p->context);
  p->context->eip = (uint)forkret;

  return p;
}

//PAGEBREAK: 32
// Set up first user process.
void
userinit(void)
{
  struct proc *p;
  extern char _binary_initcode_start[], _binary_initcode_size[];

  p = allocproc();
  
  initproc = p;
  if((p->pgdir = setupkvm()) == 0)
    panic("userinit: out of memory?");
  inituvm(p->pgdir, _binary_initcode_start, (int)_binary_initcode_size);
  p->sz = PGSIZE;
  memset(p->tf, 0, sizeof(*p->tf));
  p->tf->cs = (SEG_UCODE << 3) | DPL_USER;
  p->tf->ds = (SEG_UDATA << 3) | DPL_USER;
  p->tf->es = p->tf->ds;
  p->tf->ss = p->tf->ds;
  p->tf->eflags = FL_IF;
  p->tf->esp = PGSIZE;
  p->tf->eip = 0;  // beginning of initcode.S

  safestrcpy(p->name, "initcode", sizeof(p->name));
  p->cwd = namei("/");

  // this assignment to p->state lets other cores
  // run this process. the acquire forces the above
  // writes to be visible, and the lock is also needed
  // because the assignment might not be atomic.
  acquire(&ptable.lock);

  p->state = RUNNABLE;

  release(&ptable.lock);
}

// Grow current process's memory by n bytes.
// Return 0 on success, -1 on failure.
int
growproc(int n)
{
  uint sz;
  struct proc *curproc = myproc();

  sz = curproc->sz;
  if(n > 0){
    if((sz = allocuvm(curproc->pgdir, sz, sz + n)) == 0)
      return -1;
  } else if(n < 0){
    if((sz = deallocuvm(curproc->pgdir, sz, sz + n)) == 0)
      return -1;
  }
  curproc->sz = sz;
  switchuvm(curproc);
  return 0;
}

// Create a new process copying p as the parent.
// Sets up stack to return as if from system call.
// Caller must set state of returned proc to RUNNABLE.
int
fork(void) {
    int i, pid;
    struct proc *np;
    struct proc *curproc = myproc();

    // Allocate process.
    if ((np = allocproc()) == 0) {
        return -1;
    }

    // Copy process state from parent.
    if ((np->pgdir = copyuvm(curproc->pgdir, curproc->sz)) == 0) {
        kfree(np->kstack);
        np->kstack = 0;
        np->state = UNUSED;
        return -1;
    }
    np->sz = curproc->sz;
    np->parent = curproc;
    *np->tf = *curproc->tf;

    // Clear %eax so that fork returns 0 in the child.
    np->tf->eax = 0;

    // Duplicate open files.
    for (i = 0; i < NOFILE; i++) {
        if (curproc->ofile[i]) {
            np->ofile[i] = filedup(curproc->ofile[i]);
        }
    }
    np->cwd = idup(curproc->cwd);

    safestrcpy(np->name, curproc->name, sizeof(curproc->name));

    pid = np->pid;

    // Copy memory mappings from parent to child.
    np->num_mmap_regions = curproc->num_mmap_regions;
    for (i = 0; i < curproc->num_mmap_regions; i++) {
        struct mmap_region *parent_region = &curproc->mmap_regions[i];
        struct mmap_region *child_region = &np->mmap_regions[i];

        // Copy metadata.
        *child_region = *parent_region;

        // Duplicate file descriptor for file-backed mappings.
        if (!(parent_region->flags & MAP_ANONYMOUS)) {
            struct file *f = curproc->ofile[parent_region->fd];
            if (f) {
                child_region->fd = -1;
                for (int j = 0; j < NOFILE; j++) {
                    if (np->ofile[j] == 0) {
                        np->ofile[j] = filedup(f);
                        child_region->fd = j;
                        break;
                    }
                }
                if (child_region->fd == -1) {
                    cprintf("fork: Failed to duplicate file descriptor for mmap, fd=%d\n", parent_region->fd);
                    goto bad;
                }
            }
        }

        // Map pages into the child's page table.
        for (uint va = parent_region->start_addr;
             va < parent_region->start_addr + parent_region->length;
             va += PGSIZE) {
            pte_t *pte = walkpgdir(curproc->pgdir, (void *)va, 0);
            if (pte && (*pte & PTE_P)) {
                uint pa = PTE_ADDR(*pte);
                int perm = PTE_FLAGS(*pte);
                if (mappages(np->pgdir, (void *)va, PGSIZE, pa, perm) < 0) {
                    cprintf("fork: Failed to map page at va=0x%x\n", va);
                    goto bad;
                }
            }
        }
    }

    // Set the new process to RUNNABLE state.
    acquire(&ptable.lock);
    np->state = RUNNABLE;
    release(&ptable.lock);

    return pid;

bad:
    freevm(np->pgdir);
    kfree(np->kstack);
    np->state = UNUSED;
    return -1;
}
// Exit the current process.  Does not return.
// An exited process remains in the zombie state
// until its parent calls wait() to find out it exited.
void exit(void)
{
  struct proc *curproc = myproc();
  struct proc *p;
  int fd;

  if (curproc == initproc)
    panic("init exiting");

  // Handle memory mappings created by wmap
  for (int i = 0; i < curproc->num_mmap_regions; i++) {
    struct mmap_region *region = &curproc->mmap_regions[i];

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
                cprintf("exit: Failed to write back page at va=0x%x\n", va);
              }
            }
          }
        }
      } else {
        // Anonymous mapping: clear entries for shared regions
        for (uint va = region->start_addr; va < region->start_addr + region->length; va += PGSIZE) {
          pte_t *pte = walkpgdir(curproc->pgdir, (void *)va, 0);
          if (pte && (*pte & PTE_P)) {
            *pte = 0; // Clear the page table entry
          }
        }
      }
    }

    // Unmap and free all pages in the mapping
    for (uint va = region->start_addr; va < region->start_addr + region->length; va += PGSIZE) {
      pte_t *pte = walkpgdir(curproc->pgdir, (void *)va, 0);
      if (pte && (*pte & PTE_P)) {
        uint pa = PTE_ADDR(*pte);
        kfree(P2V(pa));      // Free the physical page
        *pte = 0;            // Clear the page table entry
      }
    }
  }

  // Reset the number of memory mappings
  curproc->num_mmap_regions = 0;

  // Handle COW for non-wmap regions (va < 0x60000000)
  for (uint va = 0; va < 0x60000000; va += PGSIZE) {
    pte_t *pte = walkpgdir(curproc->pgdir, (void *)va, 0);
    if (!pte || !(*pte & PTE_P)) {
      continue; // Skip unmapped pages
    }

    uint pa = PTE_ADDR(*pte);
    if (get_ref(pa) > 0) {
      dec_ref(pa); // Decrement reference count
      if (get_ref(pa) == 0) {
        kfree((char *)P2V(pa)); // Free physical page if no references remain
      }
    }

    *pte = 0; // Clear the page table entry
  }

  // Flush TLB after all page table updates
  lcr3(V2P(curproc->pgdir));

  // Close all open files
  for (fd = 0; fd < NOFILE; fd++) {
    if (curproc->ofile[fd]) {
      fileclose(curproc->ofile[fd]);
      curproc->ofile[fd] = 0;
    }
  }

  // Release the current working directory
  begin_op();
  iput(curproc->cwd);
  end_op();
  curproc->cwd = 0;

  acquire(&ptable.lock);

  // Wake up parent process
  wakeup1(curproc->parent);

  // Reassign children to init
  for (p = ptable.proc; p < &ptable.proc[NPROC]; p++) {
    if (p->parent == curproc) {
      p->parent = initproc;
      if (p->state == ZOMBIE)
        wakeup1(initproc);
    }
  }

  // Set process state to ZOMBIE and schedule
  curproc->state = ZOMBIE;
  sched();
  panic("zombie exit");
}

// Wait for a child process to exit and return its pid.
// Return -1 if this process has no children.
int
wait(void)
{
  struct proc *p;
  int havekids, pid;
  struct proc *curproc = myproc();
  
  acquire(&ptable.lock);
  for(;;){
    // Scan through table looking for exited children.
    havekids = 0;
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
      if(p->parent != curproc)
        continue;
      havekids = 1;
      if(p->state == ZOMBIE){
        // Found one.
        pid = p->pid;
        kfree(p->kstack);
        p->kstack = 0;
        freevm(p->pgdir);
        p->pid = 0;
        p->parent = 0;
        p->name[0] = 0;
        p->killed = 0;
        p->state = UNUSED;
        release(&ptable.lock);
        return pid;
      }
    }

    // No point waiting if we don't have any children.
    if(!havekids || curproc->killed){
      release(&ptable.lock);
      return -1;
    }

    // Wait for children to exit.  (See wakeup1 call in proc_exit.)
    sleep(curproc, &ptable.lock);  //DOC: wait-sleep
  }
}

//PAGEBREAK: 42
// Per-CPU process scheduler.
// Each CPU calls scheduler() after setting itself up.
// Scheduler never returns.  It loops, doing:
//  - choose a process to run
//  - swtch to start running that process
//  - eventually that process transfers control
//      via swtch back to the scheduler.
void
scheduler(void)
{
  struct proc *p;
  struct cpu *c = mycpu();
  c->proc = 0;
  
  for(;;){
    // Enable interrupts on this processor.
    sti();

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
      if(p->state != RUNNABLE)
        continue;

      // Switch to chosen process.  It is the process's job
      // to release ptable.lock and then reacquire it
      // before jumping back to us.
      c->proc = p;
      switchuvm(p);
      p->state = RUNNING;

      swtch(&(c->scheduler), p->context);
      switchkvm();

      // Process is done running for now.
      // It should have changed its p->state before coming back.
      c->proc = 0;
    }
    release(&ptable.lock);

  }
}

// Enter scheduler.  Must hold only ptable.lock
// and have changed proc->state. Saves and restores
// intena because intena is a property of this
// kernel thread, not this CPU. It should
// be proc->intena and proc->ncli, but that would
// break in the few places where a lock is held but
// there's no process.
void
sched(void)
{
  int intena;
  struct proc *p = myproc();

  if(!holding(&ptable.lock))
    panic("sched ptable.lock");
  if(mycpu()->ncli != 1)
    panic("sched locks");
  if(p->state == RUNNING)
    panic("sched running");
  if(readeflags()&FL_IF)
    panic("sched interruptible");
  intena = mycpu()->intena;
  swtch(&p->context, mycpu()->scheduler);
  mycpu()->intena = intena;
}

// Give up the CPU for one scheduling round.
void
yield(void)
{
  acquire(&ptable.lock);  //DOC: yieldlock
  myproc()->state = RUNNABLE;
  sched();
  release(&ptable.lock);
}

// A fork child's very first scheduling by scheduler()
// will swtch here.  "Return" to user space.
void
forkret(void)
{
  static int first = 1;
  // Still holding ptable.lock from scheduler.
  release(&ptable.lock);

  if (first) {
    // Some initialization functions must be run in the context
    // of a regular process (e.g., they call sleep), and thus cannot
    // be run from main().
    first = 0;
    iinit(ROOTDEV);
    initlog(ROOTDEV);
  }

  // Return to "caller", actually trapret (see allocproc).
}

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
  struct proc *p = myproc();
  
  if(p == 0)
    panic("sleep");

  if(lk == 0)
    panic("sleep without lk");

  // Must acquire ptable.lock in order to
  // change p->state and then call sched.
  // Once we hold ptable.lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup runs with ptable.lock locked),
  // so it's okay to release lk.
  if(lk != &ptable.lock){  //DOC: sleeplock0
    acquire(&ptable.lock);  //DOC: sleeplock1
    release(lk);
  }
  // Go to sleep.
  p->chan = chan;
  p->state = SLEEPING;

  sched();

  // Tidy up.
  p->chan = 0;

  // Reacquire original lock.
  if(lk != &ptable.lock){  //DOC: sleeplock2
    release(&ptable.lock);
    acquire(lk);
  }
}

//PAGEBREAK!
// Wake up all processes sleeping on chan.
// The ptable lock must be held.
static void
wakeup1(void *chan)
{
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
    if(p->state == SLEEPING && p->chan == chan)
      p->state = RUNNABLE;
}

// Wake up all processes sleeping on chan.
void
wakeup(void *chan)
{
  acquire(&ptable.lock);
  wakeup1(chan);
  release(&ptable.lock);
}

// Kill the process with the given pid.
// Process won't exit until it returns
// to user space (see trap in trap.c).
int
kill(int pid)
{
  struct proc *p;

  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
    if(p->pid == pid){
      p->killed = 1;
      // Wake process from sleep if necessary.
      if(p->state == SLEEPING)
        p->state = RUNNABLE;
      release(&ptable.lock);
      return 0;
    }
  }
  release(&ptable.lock);
  return -1;
}

//PAGEBREAK: 36
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
  static char *states[] = {
  [UNUSED]    "unused",
  [EMBRYO]    "embryo",
  [SLEEPING]  "sleep ",
  [RUNNABLE]  "runble",
  [RUNNING]   "run   ",
  [ZOMBIE]    "zombie"
  };
  int i;
  struct proc *p;
  char *state;
  uint pc[10];

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
      state = states[p->state];
    else
      state = "???";
    cprintf("%d %s %s", p->pid, state, p->name);
    if(p->state == SLEEPING){
      getcallerpcs((uint*)p->context->ebp+2, pc);
      for(i=0; i<10 && pc[i] != 0; i++)
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
  }
}

struct spinlock mmap_lock;

int proc_wmap(uint addr, int length, int flags, int fd) {
    struct proc *curproc = myproc();
    acquire(&mmap_lock);  // Acquire the mmap lock

    // Ensure we do not exceed the maximum number of allowed mappings
    if (curproc->num_mmap_regions >= MAX_WMMAP_INFO) {
        release(&mmap_lock);  // Release lock before returning
        return FAILED;
    }

    // Check for overlapping regions
    for (int i = 0; i < curproc->num_mmap_regions; i++) {
        struct mmap_region *existing_region = &curproc->mmap_regions[i];
        uint end_addr = existing_region->start_addr + existing_region->length;
        if (!(addr + length <= existing_region->start_addr || addr >= end_addr)) {
            release(&mmap_lock);  // Release lock before returning
            return FAILED;  // Overlap detected
        }
    }

    // Handle file descriptor and reference counting
    struct file *f = (flags & MAP_ANONYMOUS) ? 0 : curproc->ofile[fd];
    if (f == 0 && !(flags & MAP_ANONYMOUS)) {
        release(&mmap_lock);  // Release lock before returning
        return FAILED;  // Invalid fd for file-backed mapping
    }

    int dup_fd = -1;
    if (!(flags & MAP_ANONYMOUS)) {
        dup_fd = -1;
        for (int i = 0; i < NOFILE; i++) {
            if (curproc->ofile[i] == 0) {
                curproc->ofile[i] = filedup(f);  // Duplicate the file descriptor
                dup_fd = i;
                break;
            }
        }
        if (dup_fd < 0) {
            release(&mmap_lock);  // Release lock before returning
            return FAILED;  // No available file descriptor slot
        }
    }

    // Set up a new mmap_region struct in the current process
    struct mmap_region *region = &curproc->mmap_regions[curproc->num_mmap_regions++];
    region->start_addr = addr;
    region->length = length;
    region->flags = flags;
    region->fd = (flags & MAP_ANONYMOUS) ? -1 : dup_fd;  // Use the duplicated fd
    region->n_loaded_pages = 0;

    release(&mmap_lock);  // Release the mmap lock
    return addr;
}