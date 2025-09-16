Name: Taejeong Kim
CS Login: taejeong
Wisc ID: tkim347
Email: tkim347@wisc.edu
Status: I think it all works fine
Changes: add int getparentname(char*,char*,int,int) in user.h
         add SYSCALL(getparentname) in usys.S
         add #define SYS_getparentname in syscall.h
         add extern int sys_getparentname(void); and [SYS_getparentname] sys_getparentname in syscall.c
         created getparentname in sysproc.c
