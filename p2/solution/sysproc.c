#include "types.h"
#include "x86.h"
#include "defs.h"
#include "date.h"
#include "param.h"
#include "memlayout.h"
#include "mmu.h"
#include "proc.h"

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

int
sys_getparentname(void)
{
  char *parentbuf, *childbuf;
    int parentbufsize, childbufsize;
    struct proc *parent_proc, *cur_proc = myproc(); // Get current process

    // Fetch arguments from user space
    if (argptr(0, (void*)&parentbuf, sizeof(parentbuf)) < 0 ||
        argptr(1, (void*)&childbuf, sizeof(childbuf)) < 0 ||
        argint(2, &parentbufsize) < 0 ||
        argint(3, &childbufsize) < 0) {
        return -1; // Error fetching arguments
    }

    // Validate inputs
    if (!parentbuf || !childbuf || parentbufsize <= 0 || childbufsize <= 0) {
        return -1;
    }

    // Get parent process
    parent_proc = cur_proc->parent;

    // Copy process names to user buffers
    safestrcpy(parentbuf, parent_proc->name, parentbufsize);
    safestrcpy(childbuf, cur_proc->name, childbufsize);

    return 0; // Success
}
