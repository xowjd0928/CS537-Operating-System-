#include "types.h"
#include "x86.h"
#include "defs.h"
#include "date.h"
#include "param.h"
#include "memlayout.h"
#include "mmu.h"
#include "proc.h"
#include "spinlock.h"
#include "pstat.h"

struct {
  struct spinlock lock;
  struct proc proc[NPROC];
} ptable;

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

int sys_settickets(void) {
    int n;
    struct proc *p = myproc();

    if (argint(0, &n) < 0)
        return -1;

    // Ensure tickets are within valid range
    if (n < 1)
        n = 8;  // Default to 8 if invalid
    else if (n > 32)
        n = 32;  // Max of 32 tickets

    acquire(&ptable.lock);
    p->tickets = n;
    p->stride = STRIDE1 / p->tickets;
    release(&ptable.lock);

    return 0;
}

int sys_getpinfo(void) {
    struct pstat *ps;
    struct proc *p;

    if (argptr(0, (void*)&ps, sizeof(struct pstat)) < 0)
        return -1;

    acquire(&ptable.lock);

    for (int i = 0; i < NPROC; i++) {
        p = &ptable.proc[i];
        ps->inuse[i] = (p->state != UNUSED);
        ps->tickets[i] = p->tickets;
        ps->pid[i] = p->pid;
        ps->pass[i] = p->pass;
        ps->remain[i] = p->remain;
        ps->stride[i] = p->stride;
        ps->rtime[i] = p->rtime;
    }

    release(&ptable.lock);

    return 0;
}