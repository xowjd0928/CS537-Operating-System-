
kernel:     file format elf32-i386


Disassembly of section .text:

80100000 <multiboot_header>:
80100000:	02 b0 ad 1b 00 00    	add    0x1bad(%eax),%dh
80100006:	00 00                	add    %al,(%eax)
80100008:	fe 4f 52             	decb   0x52(%edi)
8010000b:	e4                   	.byte 0xe4

8010000c <entry>:

# Entering xv6 on boot processor, with paging off.
.globl entry
entry:
  # Turn on page size extension for 4Mbyte pages
  movl    %cr4, %eax
8010000c:	0f 20 e0             	mov    %cr4,%eax
  orl     $(CR4_PSE), %eax
8010000f:	83 c8 10             	or     $0x10,%eax
  movl    %eax, %cr4
80100012:	0f 22 e0             	mov    %eax,%cr4
  # Set page directory
  movl    $(V2P_WO(entrypgdir)), %eax
80100015:	b8 00 a0 10 00       	mov    $0x10a000,%eax
  movl    %eax, %cr3
8010001a:	0f 22 d8             	mov    %eax,%cr3
  # Turn on paging.
  movl    %cr0, %eax
8010001d:	0f 20 c0             	mov    %cr0,%eax
  orl     $(CR0_PG|CR0_WP), %eax
80100020:	0d 00 00 01 80       	or     $0x80010000,%eax
  movl    %eax, %cr0
80100025:	0f 22 c0             	mov    %eax,%cr0

  # Set up the stack pointer.
  movl $(stack + KSTACKSIZE), %esp
80100028:	bc 10 b6 21 80       	mov    $0x8021b610,%esp

  # Jump to main(), and switch to executing at
  # high addresses. The indirect call is needed because
  # the assembler produces a PC-relative instruction
  # for a direct jump.
  mov $main, %eax
8010002d:	b8 d0 30 10 80       	mov    $0x801030d0,%eax
  jmp *%eax
80100032:	ff e0                	jmp    *%eax
80100034:	66 90                	xchg   %ax,%ax
80100036:	66 90                	xchg   %ax,%ax
80100038:	66 90                	xchg   %ax,%ax
8010003a:	66 90                	xchg   %ax,%ax
8010003c:	66 90                	xchg   %ax,%ax
8010003e:	66 90                	xchg   %ax,%ax

80100040 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
80100040:	55                   	push   %ebp
80100041:	89 e5                	mov    %esp,%ebp
80100043:	53                   	push   %ebx

//PAGEBREAK!
  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
  bcache.head.next = &bcache.head;
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
80100044:	bb 54 b5 10 80       	mov    $0x8010b554,%ebx
{
80100049:	83 ec 0c             	sub    $0xc,%esp
  initlock(&bcache.lock, "bcache");
8010004c:	68 a0 80 10 80       	push   $0x801080a0
80100051:	68 20 b5 10 80       	push   $0x8010b520
80100056:	e8 75 49 00 00       	call   801049d0 <initlock>
  bcache.head.next = &bcache.head;
8010005b:	83 c4 10             	add    $0x10,%esp
8010005e:	b8 1c fc 10 80       	mov    $0x8010fc1c,%eax
  bcache.head.prev = &bcache.head;
80100063:	c7 05 6c fc 10 80 1c 	movl   $0x8010fc1c,0x8010fc6c
8010006a:	fc 10 80 
  bcache.head.next = &bcache.head;
8010006d:	c7 05 70 fc 10 80 1c 	movl   $0x8010fc1c,0x8010fc70
80100074:	fc 10 80 
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
80100077:	eb 09                	jmp    80100082 <binit+0x42>
80100079:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80100080:	89 d3                	mov    %edx,%ebx
    b->next = bcache.head.next;
80100082:	89 43 54             	mov    %eax,0x54(%ebx)
    b->prev = &bcache.head;
    initsleeplock(&b->lock, "buffer");
80100085:	83 ec 08             	sub    $0x8,%esp
80100088:	8d 43 0c             	lea    0xc(%ebx),%eax
    b->prev = &bcache.head;
8010008b:	c7 43 50 1c fc 10 80 	movl   $0x8010fc1c,0x50(%ebx)
    initsleeplock(&b->lock, "buffer");
80100092:	68 a7 80 10 80       	push   $0x801080a7
80100097:	50                   	push   %eax
80100098:	e8 03 48 00 00       	call   801048a0 <initsleeplock>
    bcache.head.next->prev = b;
8010009d:	a1 70 fc 10 80       	mov    0x8010fc70,%eax
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
801000a2:	8d 93 5c 02 00 00    	lea    0x25c(%ebx),%edx
801000a8:	83 c4 10             	add    $0x10,%esp
    bcache.head.next->prev = b;
801000ab:	89 58 50             	mov    %ebx,0x50(%eax)
    bcache.head.next = b;
801000ae:	89 d8                	mov    %ebx,%eax
801000b0:	89 1d 70 fc 10 80    	mov    %ebx,0x8010fc70
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
801000b6:	81 fb c0 f9 10 80    	cmp    $0x8010f9c0,%ebx
801000bc:	75 c2                	jne    80100080 <binit+0x40>
  }
}
801000be:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801000c1:	c9                   	leave  
801000c2:	c3                   	ret    
801000c3:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801000ca:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

801000d0 <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
801000d0:	55                   	push   %ebp
801000d1:	89 e5                	mov    %esp,%ebp
801000d3:	57                   	push   %edi
801000d4:	56                   	push   %esi
801000d5:	53                   	push   %ebx
801000d6:	83 ec 18             	sub    $0x18,%esp
801000d9:	8b 75 08             	mov    0x8(%ebp),%esi
801000dc:	8b 7d 0c             	mov    0xc(%ebp),%edi
  acquire(&bcache.lock);
801000df:	68 20 b5 10 80       	push   $0x8010b520
801000e4:	e8 b7 4a 00 00       	call   80104ba0 <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
801000e9:	8b 1d 70 fc 10 80    	mov    0x8010fc70,%ebx
801000ef:	83 c4 10             	add    $0x10,%esp
801000f2:	81 fb 1c fc 10 80    	cmp    $0x8010fc1c,%ebx
801000f8:	75 11                	jne    8010010b <bread+0x3b>
801000fa:	eb 24                	jmp    80100120 <bread+0x50>
801000fc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80100100:	8b 5b 54             	mov    0x54(%ebx),%ebx
80100103:	81 fb 1c fc 10 80    	cmp    $0x8010fc1c,%ebx
80100109:	74 15                	je     80100120 <bread+0x50>
    if(b->dev == dev && b->blockno == blockno){
8010010b:	3b 73 04             	cmp    0x4(%ebx),%esi
8010010e:	75 f0                	jne    80100100 <bread+0x30>
80100110:	3b 7b 08             	cmp    0x8(%ebx),%edi
80100113:	75 eb                	jne    80100100 <bread+0x30>
      b->refcnt++;
80100115:	83 43 4c 01          	addl   $0x1,0x4c(%ebx)
      release(&bcache.lock);
80100119:	eb 3f                	jmp    8010015a <bread+0x8a>
8010011b:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
8010011f:	90                   	nop
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
80100120:	8b 1d 6c fc 10 80    	mov    0x8010fc6c,%ebx
80100126:	81 fb 1c fc 10 80    	cmp    $0x8010fc1c,%ebx
8010012c:	75 0d                	jne    8010013b <bread+0x6b>
8010012e:	eb 6e                	jmp    8010019e <bread+0xce>
80100130:	8b 5b 50             	mov    0x50(%ebx),%ebx
80100133:	81 fb 1c fc 10 80    	cmp    $0x8010fc1c,%ebx
80100139:	74 63                	je     8010019e <bread+0xce>
    if(b->refcnt == 0 && (b->flags & B_DIRTY) == 0) {
8010013b:	8b 43 4c             	mov    0x4c(%ebx),%eax
8010013e:	85 c0                	test   %eax,%eax
80100140:	75 ee                	jne    80100130 <bread+0x60>
80100142:	f6 03 04             	testb  $0x4,(%ebx)
80100145:	75 e9                	jne    80100130 <bread+0x60>
      b->dev = dev;
80100147:	89 73 04             	mov    %esi,0x4(%ebx)
      b->blockno = blockno;
8010014a:	89 7b 08             	mov    %edi,0x8(%ebx)
      b->flags = 0;
8010014d:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
      b->refcnt = 1;
80100153:	c7 43 4c 01 00 00 00 	movl   $0x1,0x4c(%ebx)
      release(&bcache.lock);
8010015a:	83 ec 0c             	sub    $0xc,%esp
8010015d:	68 20 b5 10 80       	push   $0x8010b520
80100162:	e8 d9 49 00 00       	call   80104b40 <release>
      acquiresleep(&b->lock);
80100167:	8d 43 0c             	lea    0xc(%ebx),%eax
8010016a:	89 04 24             	mov    %eax,(%esp)
8010016d:	e8 6e 47 00 00       	call   801048e0 <acquiresleep>
      return b;
80100172:	83 c4 10             	add    $0x10,%esp
  struct buf *b;

  b = bget(dev, blockno);
  if((b->flags & B_VALID) == 0) {
80100175:	f6 03 02             	testb  $0x2,(%ebx)
80100178:	74 0e                	je     80100188 <bread+0xb8>
    iderw(b);
  }
  return b;
}
8010017a:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010017d:	89 d8                	mov    %ebx,%eax
8010017f:	5b                   	pop    %ebx
80100180:	5e                   	pop    %esi
80100181:	5f                   	pop    %edi
80100182:	5d                   	pop    %ebp
80100183:	c3                   	ret    
80100184:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    iderw(b);
80100188:	83 ec 0c             	sub    $0xc,%esp
8010018b:	53                   	push   %ebx
8010018c:	e8 5f 21 00 00       	call   801022f0 <iderw>
80100191:	83 c4 10             	add    $0x10,%esp
}
80100194:	8d 65 f4             	lea    -0xc(%ebp),%esp
80100197:	89 d8                	mov    %ebx,%eax
80100199:	5b                   	pop    %ebx
8010019a:	5e                   	pop    %esi
8010019b:	5f                   	pop    %edi
8010019c:	5d                   	pop    %ebp
8010019d:	c3                   	ret    
  panic("bget: no buffers");
8010019e:	83 ec 0c             	sub    $0xc,%esp
801001a1:	68 ae 80 10 80       	push   $0x801080ae
801001a6:	e8 d5 01 00 00       	call   80100380 <panic>
801001ab:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
801001af:	90                   	nop

801001b0 <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
801001b0:	55                   	push   %ebp
801001b1:	89 e5                	mov    %esp,%ebp
801001b3:	53                   	push   %ebx
801001b4:	83 ec 10             	sub    $0x10,%esp
801001b7:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if(!holdingsleep(&b->lock))
801001ba:	8d 43 0c             	lea    0xc(%ebx),%eax
801001bd:	50                   	push   %eax
801001be:	e8 bd 47 00 00       	call   80104980 <holdingsleep>
801001c3:	83 c4 10             	add    $0x10,%esp
801001c6:	85 c0                	test   %eax,%eax
801001c8:	74 0f                	je     801001d9 <bwrite+0x29>
    panic("bwrite");
  b->flags |= B_DIRTY;
801001ca:	83 0b 04             	orl    $0x4,(%ebx)
  iderw(b);
801001cd:	89 5d 08             	mov    %ebx,0x8(%ebp)
}
801001d0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801001d3:	c9                   	leave  
  iderw(b);
801001d4:	e9 17 21 00 00       	jmp    801022f0 <iderw>
    panic("bwrite");
801001d9:	83 ec 0c             	sub    $0xc,%esp
801001dc:	68 bf 80 10 80       	push   $0x801080bf
801001e1:	e8 9a 01 00 00       	call   80100380 <panic>
801001e6:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801001ed:	8d 76 00             	lea    0x0(%esi),%esi

801001f0 <brelse>:

// Release a locked buffer.
// Move to the head of the MRU list.
void
brelse(struct buf *b)
{
801001f0:	55                   	push   %ebp
801001f1:	89 e5                	mov    %esp,%ebp
801001f3:	56                   	push   %esi
801001f4:	53                   	push   %ebx
801001f5:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if(!holdingsleep(&b->lock))
801001f8:	8d 73 0c             	lea    0xc(%ebx),%esi
801001fb:	83 ec 0c             	sub    $0xc,%esp
801001fe:	56                   	push   %esi
801001ff:	e8 7c 47 00 00       	call   80104980 <holdingsleep>
80100204:	83 c4 10             	add    $0x10,%esp
80100207:	85 c0                	test   %eax,%eax
80100209:	74 66                	je     80100271 <brelse+0x81>
    panic("brelse");

  releasesleep(&b->lock);
8010020b:	83 ec 0c             	sub    $0xc,%esp
8010020e:	56                   	push   %esi
8010020f:	e8 2c 47 00 00       	call   80104940 <releasesleep>

  acquire(&bcache.lock);
80100214:	c7 04 24 20 b5 10 80 	movl   $0x8010b520,(%esp)
8010021b:	e8 80 49 00 00       	call   80104ba0 <acquire>
  b->refcnt--;
80100220:	8b 43 4c             	mov    0x4c(%ebx),%eax
  if (b->refcnt == 0) {
80100223:	83 c4 10             	add    $0x10,%esp
  b->refcnt--;
80100226:	83 e8 01             	sub    $0x1,%eax
80100229:	89 43 4c             	mov    %eax,0x4c(%ebx)
  if (b->refcnt == 0) {
8010022c:	85 c0                	test   %eax,%eax
8010022e:	75 2f                	jne    8010025f <brelse+0x6f>
    // no one is waiting for it.
    b->next->prev = b->prev;
80100230:	8b 43 54             	mov    0x54(%ebx),%eax
80100233:	8b 53 50             	mov    0x50(%ebx),%edx
80100236:	89 50 50             	mov    %edx,0x50(%eax)
    b->prev->next = b->next;
80100239:	8b 43 50             	mov    0x50(%ebx),%eax
8010023c:	8b 53 54             	mov    0x54(%ebx),%edx
8010023f:	89 50 54             	mov    %edx,0x54(%eax)
    b->next = bcache.head.next;
80100242:	a1 70 fc 10 80       	mov    0x8010fc70,%eax
    b->prev = &bcache.head;
80100247:	c7 43 50 1c fc 10 80 	movl   $0x8010fc1c,0x50(%ebx)
    b->next = bcache.head.next;
8010024e:	89 43 54             	mov    %eax,0x54(%ebx)
    bcache.head.next->prev = b;
80100251:	a1 70 fc 10 80       	mov    0x8010fc70,%eax
80100256:	89 58 50             	mov    %ebx,0x50(%eax)
    bcache.head.next = b;
80100259:	89 1d 70 fc 10 80    	mov    %ebx,0x8010fc70
  }
  
  release(&bcache.lock);
8010025f:	c7 45 08 20 b5 10 80 	movl   $0x8010b520,0x8(%ebp)
}
80100266:	8d 65 f8             	lea    -0x8(%ebp),%esp
80100269:	5b                   	pop    %ebx
8010026a:	5e                   	pop    %esi
8010026b:	5d                   	pop    %ebp
  release(&bcache.lock);
8010026c:	e9 cf 48 00 00       	jmp    80104b40 <release>
    panic("brelse");
80100271:	83 ec 0c             	sub    $0xc,%esp
80100274:	68 c6 80 10 80       	push   $0x801080c6
80100279:	e8 02 01 00 00       	call   80100380 <panic>
8010027e:	66 90                	xchg   %ax,%ax

80100280 <consoleread>:
  }
}

int
consoleread(struct inode *ip, char *dst, int n)
{
80100280:	55                   	push   %ebp
80100281:	89 e5                	mov    %esp,%ebp
80100283:	57                   	push   %edi
80100284:	56                   	push   %esi
80100285:	53                   	push   %ebx
80100286:	83 ec 18             	sub    $0x18,%esp
80100289:	8b 5d 10             	mov    0x10(%ebp),%ebx
8010028c:	8b 75 0c             	mov    0xc(%ebp),%esi
  uint target;
  int c;

  iunlock(ip);
8010028f:	ff 75 08             	push   0x8(%ebp)
  target = n;
80100292:	89 df                	mov    %ebx,%edi
  iunlock(ip);
80100294:	e8 d7 15 00 00       	call   80101870 <iunlock>
  acquire(&cons.lock);
80100299:	c7 04 24 20 ff 10 80 	movl   $0x8010ff20,(%esp)
801002a0:	e8 fb 48 00 00       	call   80104ba0 <acquire>
  while(n > 0){
801002a5:	83 c4 10             	add    $0x10,%esp
801002a8:	85 db                	test   %ebx,%ebx
801002aa:	0f 8e 94 00 00 00    	jle    80100344 <consoleread+0xc4>
    while(input.r == input.w){
801002b0:	a1 00 ff 10 80       	mov    0x8010ff00,%eax
801002b5:	3b 05 04 ff 10 80    	cmp    0x8010ff04,%eax
801002bb:	74 25                	je     801002e2 <consoleread+0x62>
801002bd:	eb 59                	jmp    80100318 <consoleread+0x98>
801002bf:	90                   	nop
      if(myproc()->killed){
        release(&cons.lock);
        ilock(ip);
        return -1;
      }
      sleep(&input.r, &cons.lock);
801002c0:	83 ec 08             	sub    $0x8,%esp
801002c3:	68 20 ff 10 80       	push   $0x8010ff20
801002c8:	68 00 ff 10 80       	push   $0x8010ff00
801002cd:	e8 fe 41 00 00       	call   801044d0 <sleep>
    while(input.r == input.w){
801002d2:	a1 00 ff 10 80       	mov    0x8010ff00,%eax
801002d7:	83 c4 10             	add    $0x10,%esp
801002da:	3b 05 04 ff 10 80    	cmp    0x8010ff04,%eax
801002e0:	75 36                	jne    80100318 <consoleread+0x98>
      if(myproc()->killed){
801002e2:	e8 09 37 00 00       	call   801039f0 <myproc>
801002e7:	8b 48 24             	mov    0x24(%eax),%ecx
801002ea:	85 c9                	test   %ecx,%ecx
801002ec:	74 d2                	je     801002c0 <consoleread+0x40>
        release(&cons.lock);
801002ee:	83 ec 0c             	sub    $0xc,%esp
801002f1:	68 20 ff 10 80       	push   $0x8010ff20
801002f6:	e8 45 48 00 00       	call   80104b40 <release>
        ilock(ip);
801002fb:	5a                   	pop    %edx
801002fc:	ff 75 08             	push   0x8(%ebp)
801002ff:	e8 8c 14 00 00       	call   80101790 <ilock>
        return -1;
80100304:	83 c4 10             	add    $0x10,%esp
  }
  release(&cons.lock);
  ilock(ip);

  return target - n;
}
80100307:	8d 65 f4             	lea    -0xc(%ebp),%esp
        return -1;
8010030a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010030f:	5b                   	pop    %ebx
80100310:	5e                   	pop    %esi
80100311:	5f                   	pop    %edi
80100312:	5d                   	pop    %ebp
80100313:	c3                   	ret    
80100314:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    c = input.buf[input.r++ % INPUT_BUF];
80100318:	8d 50 01             	lea    0x1(%eax),%edx
8010031b:	89 15 00 ff 10 80    	mov    %edx,0x8010ff00
80100321:	89 c2                	mov    %eax,%edx
80100323:	83 e2 7f             	and    $0x7f,%edx
80100326:	0f be 8a 80 fe 10 80 	movsbl -0x7fef0180(%edx),%ecx
    if(c == C('D')){  // EOF
8010032d:	80 f9 04             	cmp    $0x4,%cl
80100330:	74 37                	je     80100369 <consoleread+0xe9>
    *dst++ = c;
80100332:	83 c6 01             	add    $0x1,%esi
    --n;
80100335:	83 eb 01             	sub    $0x1,%ebx
    *dst++ = c;
80100338:	88 4e ff             	mov    %cl,-0x1(%esi)
    if(c == '\n')
8010033b:	83 f9 0a             	cmp    $0xa,%ecx
8010033e:	0f 85 64 ff ff ff    	jne    801002a8 <consoleread+0x28>
  release(&cons.lock);
80100344:	83 ec 0c             	sub    $0xc,%esp
80100347:	68 20 ff 10 80       	push   $0x8010ff20
8010034c:	e8 ef 47 00 00       	call   80104b40 <release>
  ilock(ip);
80100351:	58                   	pop    %eax
80100352:	ff 75 08             	push   0x8(%ebp)
80100355:	e8 36 14 00 00       	call   80101790 <ilock>
  return target - n;
8010035a:	89 f8                	mov    %edi,%eax
8010035c:	83 c4 10             	add    $0x10,%esp
}
8010035f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  return target - n;
80100362:	29 d8                	sub    %ebx,%eax
}
80100364:	5b                   	pop    %ebx
80100365:	5e                   	pop    %esi
80100366:	5f                   	pop    %edi
80100367:	5d                   	pop    %ebp
80100368:	c3                   	ret    
      if(n < target){
80100369:	39 fb                	cmp    %edi,%ebx
8010036b:	73 d7                	jae    80100344 <consoleread+0xc4>
        input.r--;
8010036d:	a3 00 ff 10 80       	mov    %eax,0x8010ff00
80100372:	eb d0                	jmp    80100344 <consoleread+0xc4>
80100374:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010037b:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
8010037f:	90                   	nop

80100380 <panic>:
{
80100380:	55                   	push   %ebp
80100381:	89 e5                	mov    %esp,%ebp
80100383:	56                   	push   %esi
80100384:	53                   	push   %ebx
80100385:	83 ec 30             	sub    $0x30,%esp
}

static inline void
cli(void)
{
  asm volatile("cli");
80100388:	fa                   	cli    
  cons.locking = 0;
80100389:	c7 05 54 ff 10 80 00 	movl   $0x0,0x8010ff54
80100390:	00 00 00 
  getcallerpcs(&s, pcs);
80100393:	8d 5d d0             	lea    -0x30(%ebp),%ebx
80100396:	8d 75 f8             	lea    -0x8(%ebp),%esi
  cprintf("lapicid %d: panic: ", lapicid());
80100399:	e8 c2 25 00 00       	call   80102960 <lapicid>
8010039e:	83 ec 08             	sub    $0x8,%esp
801003a1:	50                   	push   %eax
801003a2:	68 cd 80 10 80       	push   $0x801080cd
801003a7:	e8 f4 02 00 00       	call   801006a0 <cprintf>
  cprintf(s);
801003ac:	58                   	pop    %eax
801003ad:	ff 75 08             	push   0x8(%ebp)
801003b0:	e8 eb 02 00 00       	call   801006a0 <cprintf>
  cprintf("\n");
801003b5:	c7 04 24 fb 8c 10 80 	movl   $0x80108cfb,(%esp)
801003bc:	e8 df 02 00 00       	call   801006a0 <cprintf>
  getcallerpcs(&s, pcs);
801003c1:	8d 45 08             	lea    0x8(%ebp),%eax
801003c4:	5a                   	pop    %edx
801003c5:	59                   	pop    %ecx
801003c6:	53                   	push   %ebx
801003c7:	50                   	push   %eax
801003c8:	e8 23 46 00 00       	call   801049f0 <getcallerpcs>
  for(i=0; i<10; i++)
801003cd:	83 c4 10             	add    $0x10,%esp
    cprintf(" %p", pcs[i]);
801003d0:	83 ec 08             	sub    $0x8,%esp
801003d3:	ff 33                	push   (%ebx)
  for(i=0; i<10; i++)
801003d5:	83 c3 04             	add    $0x4,%ebx
    cprintf(" %p", pcs[i]);
801003d8:	68 e1 80 10 80       	push   $0x801080e1
801003dd:	e8 be 02 00 00       	call   801006a0 <cprintf>
  for(i=0; i<10; i++)
801003e2:	83 c4 10             	add    $0x10,%esp
801003e5:	39 f3                	cmp    %esi,%ebx
801003e7:	75 e7                	jne    801003d0 <panic+0x50>
  panicked = 1; // freeze other CPU
801003e9:	c7 05 58 ff 10 80 01 	movl   $0x1,0x8010ff58
801003f0:	00 00 00 
  for(;;)
801003f3:	eb fe                	jmp    801003f3 <panic+0x73>
801003f5:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801003fc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

80100400 <consputc.part.0>:
consputc(int c)
80100400:	55                   	push   %ebp
80100401:	89 e5                	mov    %esp,%ebp
80100403:	57                   	push   %edi
80100404:	56                   	push   %esi
80100405:	53                   	push   %ebx
80100406:	89 c3                	mov    %eax,%ebx
80100408:	83 ec 1c             	sub    $0x1c,%esp
  if(c == BACKSPACE){
8010040b:	3d 00 01 00 00       	cmp    $0x100,%eax
80100410:	0f 84 ea 00 00 00    	je     80100500 <consputc.part.0+0x100>
    uartputc(c);
80100416:	83 ec 0c             	sub    $0xc,%esp
80100419:	50                   	push   %eax
8010041a:	e8 f1 66 00 00       	call   80106b10 <uartputc>
8010041f:	83 c4 10             	add    $0x10,%esp
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80100422:	bf d4 03 00 00       	mov    $0x3d4,%edi
80100427:	b8 0e 00 00 00       	mov    $0xe,%eax
8010042c:	89 fa                	mov    %edi,%edx
8010042e:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
8010042f:	be d5 03 00 00       	mov    $0x3d5,%esi
80100434:	89 f2                	mov    %esi,%edx
80100436:	ec                   	in     (%dx),%al
  pos = inb(CRTPORT+1) << 8;
80100437:	0f b6 c8             	movzbl %al,%ecx
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
8010043a:	89 fa                	mov    %edi,%edx
8010043c:	b8 0f 00 00 00       	mov    $0xf,%eax
80100441:	c1 e1 08             	shl    $0x8,%ecx
80100444:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80100445:	89 f2                	mov    %esi,%edx
80100447:	ec                   	in     (%dx),%al
  pos |= inb(CRTPORT+1);
80100448:	0f b6 c0             	movzbl %al,%eax
8010044b:	09 c8                	or     %ecx,%eax
  if(c == '\n')
8010044d:	83 fb 0a             	cmp    $0xa,%ebx
80100450:	0f 84 92 00 00 00    	je     801004e8 <consputc.part.0+0xe8>
  else if(c == BACKSPACE){
80100456:	81 fb 00 01 00 00    	cmp    $0x100,%ebx
8010045c:	74 72                	je     801004d0 <consputc.part.0+0xd0>
    crt[pos++] = (c&0xff) | 0x0700;  // black on white
8010045e:	0f b6 db             	movzbl %bl,%ebx
80100461:	8d 70 01             	lea    0x1(%eax),%esi
80100464:	80 cf 07             	or     $0x7,%bh
80100467:	66 89 9c 00 00 80 0b 	mov    %bx,-0x7ff48000(%eax,%eax,1)
8010046e:	80 
  if(pos < 0 || pos > 25*80)
8010046f:	81 fe d0 07 00 00    	cmp    $0x7d0,%esi
80100475:	0f 8f fb 00 00 00    	jg     80100576 <consputc.part.0+0x176>
  if((pos/80) >= 24){  // Scroll up.
8010047b:	81 fe 7f 07 00 00    	cmp    $0x77f,%esi
80100481:	0f 8f a9 00 00 00    	jg     80100530 <consputc.part.0+0x130>
  outb(CRTPORT+1, pos>>8);
80100487:	89 f0                	mov    %esi,%eax
  crt[pos] = ' ' | 0x0700;
80100489:	8d b4 36 00 80 0b 80 	lea    -0x7ff48000(%esi,%esi,1),%esi
  outb(CRTPORT+1, pos);
80100490:	88 45 e7             	mov    %al,-0x19(%ebp)
  outb(CRTPORT+1, pos>>8);
80100493:	0f b6 fc             	movzbl %ah,%edi
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80100496:	bb d4 03 00 00       	mov    $0x3d4,%ebx
8010049b:	b8 0e 00 00 00       	mov    $0xe,%eax
801004a0:	89 da                	mov    %ebx,%edx
801004a2:	ee                   	out    %al,(%dx)
801004a3:	b9 d5 03 00 00       	mov    $0x3d5,%ecx
801004a8:	89 f8                	mov    %edi,%eax
801004aa:	89 ca                	mov    %ecx,%edx
801004ac:	ee                   	out    %al,(%dx)
801004ad:	b8 0f 00 00 00       	mov    $0xf,%eax
801004b2:	89 da                	mov    %ebx,%edx
801004b4:	ee                   	out    %al,(%dx)
801004b5:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
801004b9:	89 ca                	mov    %ecx,%edx
801004bb:	ee                   	out    %al,(%dx)
  crt[pos] = ' ' | 0x0700;
801004bc:	b8 20 07 00 00       	mov    $0x720,%eax
801004c1:	66 89 06             	mov    %ax,(%esi)
}
801004c4:	8d 65 f4             	lea    -0xc(%ebp),%esp
801004c7:	5b                   	pop    %ebx
801004c8:	5e                   	pop    %esi
801004c9:	5f                   	pop    %edi
801004ca:	5d                   	pop    %ebp
801004cb:	c3                   	ret    
801004cc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    if(pos > 0) --pos;
801004d0:	8d 70 ff             	lea    -0x1(%eax),%esi
801004d3:	85 c0                	test   %eax,%eax
801004d5:	75 98                	jne    8010046f <consputc.part.0+0x6f>
801004d7:	c6 45 e7 00          	movb   $0x0,-0x19(%ebp)
801004db:	be 00 80 0b 80       	mov    $0x800b8000,%esi
801004e0:	31 ff                	xor    %edi,%edi
801004e2:	eb b2                	jmp    80100496 <consputc.part.0+0x96>
801004e4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    pos += 80 - pos%80;
801004e8:	ba cd cc cc cc       	mov    $0xcccccccd,%edx
801004ed:	f7 e2                	mul    %edx
801004ef:	c1 ea 06             	shr    $0x6,%edx
801004f2:	8d 04 92             	lea    (%edx,%edx,4),%eax
801004f5:	c1 e0 04             	shl    $0x4,%eax
801004f8:	8d 70 50             	lea    0x50(%eax),%esi
801004fb:	e9 6f ff ff ff       	jmp    8010046f <consputc.part.0+0x6f>
    uartputc('\b'); uartputc(' '); uartputc('\b');
80100500:	83 ec 0c             	sub    $0xc,%esp
80100503:	6a 08                	push   $0x8
80100505:	e8 06 66 00 00       	call   80106b10 <uartputc>
8010050a:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
80100511:	e8 fa 65 00 00       	call   80106b10 <uartputc>
80100516:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
8010051d:	e8 ee 65 00 00       	call   80106b10 <uartputc>
80100522:	83 c4 10             	add    $0x10,%esp
80100525:	e9 f8 fe ff ff       	jmp    80100422 <consputc.part.0+0x22>
8010052a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    memmove(crt, crt+80, sizeof(crt[0])*23*80);
80100530:	83 ec 04             	sub    $0x4,%esp
    pos -= 80;
80100533:	8d 5e b0             	lea    -0x50(%esi),%ebx
    memset(crt+pos, 0, sizeof(crt[0])*(24*80 - pos));
80100536:	8d b4 36 60 7f 0b 80 	lea    -0x7ff480a0(%esi,%esi,1),%esi
  outb(CRTPORT+1, pos);
8010053d:	bf 07 00 00 00       	mov    $0x7,%edi
    memmove(crt, crt+80, sizeof(crt[0])*23*80);
80100542:	68 60 0e 00 00       	push   $0xe60
80100547:	68 a0 80 0b 80       	push   $0x800b80a0
8010054c:	68 00 80 0b 80       	push   $0x800b8000
80100551:	e8 aa 47 00 00       	call   80104d00 <memmove>
    memset(crt+pos, 0, sizeof(crt[0])*(24*80 - pos));
80100556:	b8 80 07 00 00       	mov    $0x780,%eax
8010055b:	83 c4 0c             	add    $0xc,%esp
8010055e:	29 d8                	sub    %ebx,%eax
80100560:	01 c0                	add    %eax,%eax
80100562:	50                   	push   %eax
80100563:	6a 00                	push   $0x0
80100565:	56                   	push   %esi
80100566:	e8 f5 46 00 00       	call   80104c60 <memset>
  outb(CRTPORT+1, pos);
8010056b:	88 5d e7             	mov    %bl,-0x19(%ebp)
8010056e:	83 c4 10             	add    $0x10,%esp
80100571:	e9 20 ff ff ff       	jmp    80100496 <consputc.part.0+0x96>
    panic("pos under/overflow");
80100576:	83 ec 0c             	sub    $0xc,%esp
80100579:	68 e5 80 10 80       	push   $0x801080e5
8010057e:	e8 fd fd ff ff       	call   80100380 <panic>
80100583:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010058a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

80100590 <consolewrite>:

int
consolewrite(struct inode *ip, char *buf, int n)
{
80100590:	55                   	push   %ebp
80100591:	89 e5                	mov    %esp,%ebp
80100593:	57                   	push   %edi
80100594:	56                   	push   %esi
80100595:	53                   	push   %ebx
80100596:	83 ec 18             	sub    $0x18,%esp
  int i;

  iunlock(ip);
80100599:	ff 75 08             	push   0x8(%ebp)
{
8010059c:	8b 75 10             	mov    0x10(%ebp),%esi
  iunlock(ip);
8010059f:	e8 cc 12 00 00       	call   80101870 <iunlock>
  acquire(&cons.lock);
801005a4:	c7 04 24 20 ff 10 80 	movl   $0x8010ff20,(%esp)
801005ab:	e8 f0 45 00 00       	call   80104ba0 <acquire>
  for(i = 0; i < n; i++)
801005b0:	83 c4 10             	add    $0x10,%esp
801005b3:	85 f6                	test   %esi,%esi
801005b5:	7e 25                	jle    801005dc <consolewrite+0x4c>
801005b7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
801005ba:	8d 3c 33             	lea    (%ebx,%esi,1),%edi
  if(panicked){
801005bd:	8b 15 58 ff 10 80    	mov    0x8010ff58,%edx
    consputc(buf[i] & 0xff);
801005c3:	0f b6 03             	movzbl (%ebx),%eax
  if(panicked){
801005c6:	85 d2                	test   %edx,%edx
801005c8:	74 06                	je     801005d0 <consolewrite+0x40>
  asm volatile("cli");
801005ca:	fa                   	cli    
    for(;;)
801005cb:	eb fe                	jmp    801005cb <consolewrite+0x3b>
801005cd:	8d 76 00             	lea    0x0(%esi),%esi
801005d0:	e8 2b fe ff ff       	call   80100400 <consputc.part.0>
  for(i = 0; i < n; i++)
801005d5:	83 c3 01             	add    $0x1,%ebx
801005d8:	39 df                	cmp    %ebx,%edi
801005da:	75 e1                	jne    801005bd <consolewrite+0x2d>
  release(&cons.lock);
801005dc:	83 ec 0c             	sub    $0xc,%esp
801005df:	68 20 ff 10 80       	push   $0x8010ff20
801005e4:	e8 57 45 00 00       	call   80104b40 <release>
  ilock(ip);
801005e9:	58                   	pop    %eax
801005ea:	ff 75 08             	push   0x8(%ebp)
801005ed:	e8 9e 11 00 00       	call   80101790 <ilock>

  return n;
}
801005f2:	8d 65 f4             	lea    -0xc(%ebp),%esp
801005f5:	89 f0                	mov    %esi,%eax
801005f7:	5b                   	pop    %ebx
801005f8:	5e                   	pop    %esi
801005f9:	5f                   	pop    %edi
801005fa:	5d                   	pop    %ebp
801005fb:	c3                   	ret    
801005fc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

80100600 <printint>:
{
80100600:	55                   	push   %ebp
80100601:	89 e5                	mov    %esp,%ebp
80100603:	57                   	push   %edi
80100604:	56                   	push   %esi
80100605:	53                   	push   %ebx
80100606:	83 ec 2c             	sub    $0x2c,%esp
80100609:	89 55 d4             	mov    %edx,-0x2c(%ebp)
8010060c:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  if(sign && (sign = xx < 0))
8010060f:	85 c9                	test   %ecx,%ecx
80100611:	74 04                	je     80100617 <printint+0x17>
80100613:	85 c0                	test   %eax,%eax
80100615:	78 6d                	js     80100684 <printint+0x84>
    x = xx;
80100617:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
8010061e:	89 c1                	mov    %eax,%ecx
  i = 0;
80100620:	31 db                	xor    %ebx,%ebx
80100622:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    buf[i++] = digits[x % base];
80100628:	89 c8                	mov    %ecx,%eax
8010062a:	31 d2                	xor    %edx,%edx
8010062c:	89 de                	mov    %ebx,%esi
8010062e:	89 cf                	mov    %ecx,%edi
80100630:	f7 75 d4             	divl   -0x2c(%ebp)
80100633:	8d 5b 01             	lea    0x1(%ebx),%ebx
80100636:	0f b6 92 10 81 10 80 	movzbl -0x7fef7ef0(%edx),%edx
  }while((x /= base) != 0);
8010063d:	89 c1                	mov    %eax,%ecx
    buf[i++] = digits[x % base];
8010063f:	88 54 1d d7          	mov    %dl,-0x29(%ebp,%ebx,1)
  }while((x /= base) != 0);
80100643:	3b 7d d4             	cmp    -0x2c(%ebp),%edi
80100646:	73 e0                	jae    80100628 <printint+0x28>
  if(sign)
80100648:	8b 4d d0             	mov    -0x30(%ebp),%ecx
8010064b:	85 c9                	test   %ecx,%ecx
8010064d:	74 0c                	je     8010065b <printint+0x5b>
    buf[i++] = '-';
8010064f:	c6 44 1d d8 2d       	movb   $0x2d,-0x28(%ebp,%ebx,1)
    buf[i++] = digits[x % base];
80100654:	89 de                	mov    %ebx,%esi
    buf[i++] = '-';
80100656:	ba 2d 00 00 00       	mov    $0x2d,%edx
  while(--i >= 0)
8010065b:	8d 5c 35 d7          	lea    -0x29(%ebp,%esi,1),%ebx
8010065f:	0f be c2             	movsbl %dl,%eax
  if(panicked){
80100662:	8b 15 58 ff 10 80    	mov    0x8010ff58,%edx
80100668:	85 d2                	test   %edx,%edx
8010066a:	74 04                	je     80100670 <printint+0x70>
8010066c:	fa                   	cli    
    for(;;)
8010066d:	eb fe                	jmp    8010066d <printint+0x6d>
8010066f:	90                   	nop
80100670:	e8 8b fd ff ff       	call   80100400 <consputc.part.0>
  while(--i >= 0)
80100675:	8d 45 d7             	lea    -0x29(%ebp),%eax
80100678:	39 c3                	cmp    %eax,%ebx
8010067a:	74 0e                	je     8010068a <printint+0x8a>
    consputc(buf[i]);
8010067c:	0f be 03             	movsbl (%ebx),%eax
8010067f:	83 eb 01             	sub    $0x1,%ebx
80100682:	eb de                	jmp    80100662 <printint+0x62>
    x = -xx;
80100684:	f7 d8                	neg    %eax
80100686:	89 c1                	mov    %eax,%ecx
80100688:	eb 96                	jmp    80100620 <printint+0x20>
}
8010068a:	83 c4 2c             	add    $0x2c,%esp
8010068d:	5b                   	pop    %ebx
8010068e:	5e                   	pop    %esi
8010068f:	5f                   	pop    %edi
80100690:	5d                   	pop    %ebp
80100691:	c3                   	ret    
80100692:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80100699:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

801006a0 <cprintf>:
{
801006a0:	55                   	push   %ebp
801006a1:	89 e5                	mov    %esp,%ebp
801006a3:	57                   	push   %edi
801006a4:	56                   	push   %esi
801006a5:	53                   	push   %ebx
801006a6:	83 ec 1c             	sub    $0x1c,%esp
  locking = cons.locking;
801006a9:	a1 54 ff 10 80       	mov    0x8010ff54,%eax
801006ae:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  if(locking)
801006b1:	85 c0                	test   %eax,%eax
801006b3:	0f 85 27 01 00 00    	jne    801007e0 <cprintf+0x140>
  if (fmt == 0)
801006b9:	8b 75 08             	mov    0x8(%ebp),%esi
801006bc:	85 f6                	test   %esi,%esi
801006be:	0f 84 ac 01 00 00    	je     80100870 <cprintf+0x1d0>
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
801006c4:	0f b6 06             	movzbl (%esi),%eax
  argp = (uint*)(void*)(&fmt + 1);
801006c7:	8d 7d 0c             	lea    0xc(%ebp),%edi
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
801006ca:	31 db                	xor    %ebx,%ebx
801006cc:	85 c0                	test   %eax,%eax
801006ce:	74 56                	je     80100726 <cprintf+0x86>
    if(c != '%'){
801006d0:	83 f8 25             	cmp    $0x25,%eax
801006d3:	0f 85 cf 00 00 00    	jne    801007a8 <cprintf+0x108>
    c = fmt[++i] & 0xff;
801006d9:	83 c3 01             	add    $0x1,%ebx
801006dc:	0f b6 14 1e          	movzbl (%esi,%ebx,1),%edx
    if(c == 0)
801006e0:	85 d2                	test   %edx,%edx
801006e2:	74 42                	je     80100726 <cprintf+0x86>
    switch(c){
801006e4:	83 fa 70             	cmp    $0x70,%edx
801006e7:	0f 84 90 00 00 00    	je     8010077d <cprintf+0xdd>
801006ed:	7f 51                	jg     80100740 <cprintf+0xa0>
801006ef:	83 fa 25             	cmp    $0x25,%edx
801006f2:	0f 84 c0 00 00 00    	je     801007b8 <cprintf+0x118>
801006f8:	83 fa 64             	cmp    $0x64,%edx
801006fb:	0f 85 f4 00 00 00    	jne    801007f5 <cprintf+0x155>
      printint(*argp++, 10, 1);
80100701:	8d 47 04             	lea    0x4(%edi),%eax
80100704:	b9 01 00 00 00       	mov    $0x1,%ecx
80100709:	ba 0a 00 00 00       	mov    $0xa,%edx
8010070e:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100711:	8b 07                	mov    (%edi),%eax
80100713:	e8 e8 fe ff ff       	call   80100600 <printint>
80100718:	8b 7d e0             	mov    -0x20(%ebp),%edi
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
8010071b:	83 c3 01             	add    $0x1,%ebx
8010071e:	0f b6 04 1e          	movzbl (%esi,%ebx,1),%eax
80100722:	85 c0                	test   %eax,%eax
80100724:	75 aa                	jne    801006d0 <cprintf+0x30>
  if(locking)
80100726:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100729:	85 c0                	test   %eax,%eax
8010072b:	0f 85 22 01 00 00    	jne    80100853 <cprintf+0x1b3>
}
80100731:	8d 65 f4             	lea    -0xc(%ebp),%esp
80100734:	5b                   	pop    %ebx
80100735:	5e                   	pop    %esi
80100736:	5f                   	pop    %edi
80100737:	5d                   	pop    %ebp
80100738:	c3                   	ret    
80100739:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    switch(c){
80100740:	83 fa 73             	cmp    $0x73,%edx
80100743:	75 33                	jne    80100778 <cprintf+0xd8>
      if((s = (char*)*argp++) == 0)
80100745:	8d 47 04             	lea    0x4(%edi),%eax
80100748:	8b 3f                	mov    (%edi),%edi
8010074a:	89 45 e0             	mov    %eax,-0x20(%ebp)
8010074d:	85 ff                	test   %edi,%edi
8010074f:	0f 84 e3 00 00 00    	je     80100838 <cprintf+0x198>
      for(; *s; s++)
80100755:	0f be 07             	movsbl (%edi),%eax
80100758:	84 c0                	test   %al,%al
8010075a:	0f 84 08 01 00 00    	je     80100868 <cprintf+0x1c8>
  if(panicked){
80100760:	8b 15 58 ff 10 80    	mov    0x8010ff58,%edx
80100766:	85 d2                	test   %edx,%edx
80100768:	0f 84 b2 00 00 00    	je     80100820 <cprintf+0x180>
8010076e:	fa                   	cli    
    for(;;)
8010076f:	eb fe                	jmp    8010076f <cprintf+0xcf>
80100771:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    switch(c){
80100778:	83 fa 78             	cmp    $0x78,%edx
8010077b:	75 78                	jne    801007f5 <cprintf+0x155>
      printint(*argp++, 16, 0);
8010077d:	8d 47 04             	lea    0x4(%edi),%eax
80100780:	31 c9                	xor    %ecx,%ecx
80100782:	ba 10 00 00 00       	mov    $0x10,%edx
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
80100787:	83 c3 01             	add    $0x1,%ebx
      printint(*argp++, 16, 0);
8010078a:	89 45 e0             	mov    %eax,-0x20(%ebp)
8010078d:	8b 07                	mov    (%edi),%eax
8010078f:	e8 6c fe ff ff       	call   80100600 <printint>
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
80100794:	0f b6 04 1e          	movzbl (%esi,%ebx,1),%eax
      printint(*argp++, 16, 0);
80100798:	8b 7d e0             	mov    -0x20(%ebp),%edi
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
8010079b:	85 c0                	test   %eax,%eax
8010079d:	0f 85 2d ff ff ff    	jne    801006d0 <cprintf+0x30>
801007a3:	eb 81                	jmp    80100726 <cprintf+0x86>
801007a5:	8d 76 00             	lea    0x0(%esi),%esi
  if(panicked){
801007a8:	8b 0d 58 ff 10 80    	mov    0x8010ff58,%ecx
801007ae:	85 c9                	test   %ecx,%ecx
801007b0:	74 14                	je     801007c6 <cprintf+0x126>
801007b2:	fa                   	cli    
    for(;;)
801007b3:	eb fe                	jmp    801007b3 <cprintf+0x113>
801007b5:	8d 76 00             	lea    0x0(%esi),%esi
  if(panicked){
801007b8:	a1 58 ff 10 80       	mov    0x8010ff58,%eax
801007bd:	85 c0                	test   %eax,%eax
801007bf:	75 6c                	jne    8010082d <cprintf+0x18d>
801007c1:	b8 25 00 00 00       	mov    $0x25,%eax
801007c6:	e8 35 fc ff ff       	call   80100400 <consputc.part.0>
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
801007cb:	83 c3 01             	add    $0x1,%ebx
801007ce:	0f b6 04 1e          	movzbl (%esi,%ebx,1),%eax
801007d2:	85 c0                	test   %eax,%eax
801007d4:	0f 85 f6 fe ff ff    	jne    801006d0 <cprintf+0x30>
801007da:	e9 47 ff ff ff       	jmp    80100726 <cprintf+0x86>
801007df:	90                   	nop
    acquire(&cons.lock);
801007e0:	83 ec 0c             	sub    $0xc,%esp
801007e3:	68 20 ff 10 80       	push   $0x8010ff20
801007e8:	e8 b3 43 00 00       	call   80104ba0 <acquire>
801007ed:	83 c4 10             	add    $0x10,%esp
801007f0:	e9 c4 fe ff ff       	jmp    801006b9 <cprintf+0x19>
  if(panicked){
801007f5:	8b 0d 58 ff 10 80    	mov    0x8010ff58,%ecx
801007fb:	85 c9                	test   %ecx,%ecx
801007fd:	75 31                	jne    80100830 <cprintf+0x190>
801007ff:	b8 25 00 00 00       	mov    $0x25,%eax
80100804:	89 55 e0             	mov    %edx,-0x20(%ebp)
80100807:	e8 f4 fb ff ff       	call   80100400 <consputc.part.0>
8010080c:	8b 15 58 ff 10 80    	mov    0x8010ff58,%edx
80100812:	85 d2                	test   %edx,%edx
80100814:	8b 55 e0             	mov    -0x20(%ebp),%edx
80100817:	74 2e                	je     80100847 <cprintf+0x1a7>
80100819:	fa                   	cli    
    for(;;)
8010081a:	eb fe                	jmp    8010081a <cprintf+0x17a>
8010081c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80100820:	e8 db fb ff ff       	call   80100400 <consputc.part.0>
      for(; *s; s++)
80100825:	83 c7 01             	add    $0x1,%edi
80100828:	e9 28 ff ff ff       	jmp    80100755 <cprintf+0xb5>
8010082d:	fa                   	cli    
    for(;;)
8010082e:	eb fe                	jmp    8010082e <cprintf+0x18e>
80100830:	fa                   	cli    
80100831:	eb fe                	jmp    80100831 <cprintf+0x191>
80100833:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80100837:	90                   	nop
        s = "(null)";
80100838:	bf f8 80 10 80       	mov    $0x801080f8,%edi
      for(; *s; s++)
8010083d:	b8 28 00 00 00       	mov    $0x28,%eax
80100842:	e9 19 ff ff ff       	jmp    80100760 <cprintf+0xc0>
80100847:	89 d0                	mov    %edx,%eax
80100849:	e8 b2 fb ff ff       	call   80100400 <consputc.part.0>
8010084e:	e9 c8 fe ff ff       	jmp    8010071b <cprintf+0x7b>
    release(&cons.lock);
80100853:	83 ec 0c             	sub    $0xc,%esp
80100856:	68 20 ff 10 80       	push   $0x8010ff20
8010085b:	e8 e0 42 00 00       	call   80104b40 <release>
80100860:	83 c4 10             	add    $0x10,%esp
}
80100863:	e9 c9 fe ff ff       	jmp    80100731 <cprintf+0x91>
      if((s = (char*)*argp++) == 0)
80100868:	8b 7d e0             	mov    -0x20(%ebp),%edi
8010086b:	e9 ab fe ff ff       	jmp    8010071b <cprintf+0x7b>
    panic("null fmt");
80100870:	83 ec 0c             	sub    $0xc,%esp
80100873:	68 ff 80 10 80       	push   $0x801080ff
80100878:	e8 03 fb ff ff       	call   80100380 <panic>
8010087d:	8d 76 00             	lea    0x0(%esi),%esi

80100880 <consoleintr>:
{
80100880:	55                   	push   %ebp
80100881:	89 e5                	mov    %esp,%ebp
80100883:	57                   	push   %edi
80100884:	56                   	push   %esi
  int c, doprocdump = 0;
80100885:	31 f6                	xor    %esi,%esi
{
80100887:	53                   	push   %ebx
80100888:	83 ec 18             	sub    $0x18,%esp
8010088b:	8b 7d 08             	mov    0x8(%ebp),%edi
  acquire(&cons.lock);
8010088e:	68 20 ff 10 80       	push   $0x8010ff20
80100893:	e8 08 43 00 00       	call   80104ba0 <acquire>
  while((c = getc()) >= 0){
80100898:	83 c4 10             	add    $0x10,%esp
8010089b:	eb 1a                	jmp    801008b7 <consoleintr+0x37>
8010089d:	8d 76 00             	lea    0x0(%esi),%esi
    switch(c){
801008a0:	83 fb 08             	cmp    $0x8,%ebx
801008a3:	0f 84 d7 00 00 00    	je     80100980 <consoleintr+0x100>
801008a9:	83 fb 10             	cmp    $0x10,%ebx
801008ac:	0f 85 32 01 00 00    	jne    801009e4 <consoleintr+0x164>
801008b2:	be 01 00 00 00       	mov    $0x1,%esi
  while((c = getc()) >= 0){
801008b7:	ff d7                	call   *%edi
801008b9:	89 c3                	mov    %eax,%ebx
801008bb:	85 c0                	test   %eax,%eax
801008bd:	0f 88 05 01 00 00    	js     801009c8 <consoleintr+0x148>
    switch(c){
801008c3:	83 fb 15             	cmp    $0x15,%ebx
801008c6:	74 78                	je     80100940 <consoleintr+0xc0>
801008c8:	7e d6                	jle    801008a0 <consoleintr+0x20>
801008ca:	83 fb 7f             	cmp    $0x7f,%ebx
801008cd:	0f 84 ad 00 00 00    	je     80100980 <consoleintr+0x100>
      if(c != 0 && input.e-input.r < INPUT_BUF){
801008d3:	a1 08 ff 10 80       	mov    0x8010ff08,%eax
801008d8:	89 c2                	mov    %eax,%edx
801008da:	2b 15 00 ff 10 80    	sub    0x8010ff00,%edx
801008e0:	83 fa 7f             	cmp    $0x7f,%edx
801008e3:	77 d2                	ja     801008b7 <consoleintr+0x37>
        input.buf[input.e++ % INPUT_BUF] = c;
801008e5:	8d 48 01             	lea    0x1(%eax),%ecx
  if(panicked){
801008e8:	8b 15 58 ff 10 80    	mov    0x8010ff58,%edx
        input.buf[input.e++ % INPUT_BUF] = c;
801008ee:	83 e0 7f             	and    $0x7f,%eax
801008f1:	89 0d 08 ff 10 80    	mov    %ecx,0x8010ff08
        c = (c == '\r') ? '\n' : c;
801008f7:	83 fb 0d             	cmp    $0xd,%ebx
801008fa:	0f 84 13 01 00 00    	je     80100a13 <consoleintr+0x193>
        input.buf[input.e++ % INPUT_BUF] = c;
80100900:	88 98 80 fe 10 80    	mov    %bl,-0x7fef0180(%eax)
  if(panicked){
80100906:	85 d2                	test   %edx,%edx
80100908:	0f 85 10 01 00 00    	jne    80100a1e <consoleintr+0x19e>
8010090e:	89 d8                	mov    %ebx,%eax
80100910:	e8 eb fa ff ff       	call   80100400 <consputc.part.0>
        if(c == '\n' || c == C('D') || input.e == input.r+INPUT_BUF){
80100915:	83 fb 0a             	cmp    $0xa,%ebx
80100918:	0f 84 14 01 00 00    	je     80100a32 <consoleintr+0x1b2>
8010091e:	83 fb 04             	cmp    $0x4,%ebx
80100921:	0f 84 0b 01 00 00    	je     80100a32 <consoleintr+0x1b2>
80100927:	a1 00 ff 10 80       	mov    0x8010ff00,%eax
8010092c:	83 e8 80             	sub    $0xffffff80,%eax
8010092f:	39 05 08 ff 10 80    	cmp    %eax,0x8010ff08
80100935:	75 80                	jne    801008b7 <consoleintr+0x37>
80100937:	e9 fb 00 00 00       	jmp    80100a37 <consoleintr+0x1b7>
8010093c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
      while(input.e != input.w &&
80100940:	a1 08 ff 10 80       	mov    0x8010ff08,%eax
80100945:	39 05 04 ff 10 80    	cmp    %eax,0x8010ff04
8010094b:	0f 84 66 ff ff ff    	je     801008b7 <consoleintr+0x37>
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
80100951:	83 e8 01             	sub    $0x1,%eax
80100954:	89 c2                	mov    %eax,%edx
80100956:	83 e2 7f             	and    $0x7f,%edx
      while(input.e != input.w &&
80100959:	80 ba 80 fe 10 80 0a 	cmpb   $0xa,-0x7fef0180(%edx)
80100960:	0f 84 51 ff ff ff    	je     801008b7 <consoleintr+0x37>
  if(panicked){
80100966:	8b 15 58 ff 10 80    	mov    0x8010ff58,%edx
        input.e--;
8010096c:	a3 08 ff 10 80       	mov    %eax,0x8010ff08
  if(panicked){
80100971:	85 d2                	test   %edx,%edx
80100973:	74 33                	je     801009a8 <consoleintr+0x128>
80100975:	fa                   	cli    
    for(;;)
80100976:	eb fe                	jmp    80100976 <consoleintr+0xf6>
80100978:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010097f:	90                   	nop
      if(input.e != input.w){
80100980:	a1 08 ff 10 80       	mov    0x8010ff08,%eax
80100985:	3b 05 04 ff 10 80    	cmp    0x8010ff04,%eax
8010098b:	0f 84 26 ff ff ff    	je     801008b7 <consoleintr+0x37>
        input.e--;
80100991:	83 e8 01             	sub    $0x1,%eax
80100994:	a3 08 ff 10 80       	mov    %eax,0x8010ff08
  if(panicked){
80100999:	a1 58 ff 10 80       	mov    0x8010ff58,%eax
8010099e:	85 c0                	test   %eax,%eax
801009a0:	74 56                	je     801009f8 <consoleintr+0x178>
801009a2:	fa                   	cli    
    for(;;)
801009a3:	eb fe                	jmp    801009a3 <consoleintr+0x123>
801009a5:	8d 76 00             	lea    0x0(%esi),%esi
801009a8:	b8 00 01 00 00       	mov    $0x100,%eax
801009ad:	e8 4e fa ff ff       	call   80100400 <consputc.part.0>
      while(input.e != input.w &&
801009b2:	a1 08 ff 10 80       	mov    0x8010ff08,%eax
801009b7:	3b 05 04 ff 10 80    	cmp    0x8010ff04,%eax
801009bd:	75 92                	jne    80100951 <consoleintr+0xd1>
801009bf:	e9 f3 fe ff ff       	jmp    801008b7 <consoleintr+0x37>
801009c4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  release(&cons.lock);
801009c8:	83 ec 0c             	sub    $0xc,%esp
801009cb:	68 20 ff 10 80       	push   $0x8010ff20
801009d0:	e8 6b 41 00 00       	call   80104b40 <release>
  if(doprocdump) {
801009d5:	83 c4 10             	add    $0x10,%esp
801009d8:	85 f6                	test   %esi,%esi
801009da:	75 2b                	jne    80100a07 <consoleintr+0x187>
}
801009dc:	8d 65 f4             	lea    -0xc(%ebp),%esp
801009df:	5b                   	pop    %ebx
801009e0:	5e                   	pop    %esi
801009e1:	5f                   	pop    %edi
801009e2:	5d                   	pop    %ebp
801009e3:	c3                   	ret    
      if(c != 0 && input.e-input.r < INPUT_BUF){
801009e4:	85 db                	test   %ebx,%ebx
801009e6:	0f 84 cb fe ff ff    	je     801008b7 <consoleintr+0x37>
801009ec:	e9 e2 fe ff ff       	jmp    801008d3 <consoleintr+0x53>
801009f1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801009f8:	b8 00 01 00 00       	mov    $0x100,%eax
801009fd:	e8 fe f9 ff ff       	call   80100400 <consputc.part.0>
80100a02:	e9 b0 fe ff ff       	jmp    801008b7 <consoleintr+0x37>
}
80100a07:	8d 65 f4             	lea    -0xc(%ebp),%esp
80100a0a:	5b                   	pop    %ebx
80100a0b:	5e                   	pop    %esi
80100a0c:	5f                   	pop    %edi
80100a0d:	5d                   	pop    %ebp
    procdump();  // now call procdump() wo. cons.lock held
80100a0e:	e9 5d 3c 00 00       	jmp    80104670 <procdump>
        input.buf[input.e++ % INPUT_BUF] = c;
80100a13:	c6 80 80 fe 10 80 0a 	movb   $0xa,-0x7fef0180(%eax)
  if(panicked){
80100a1a:	85 d2                	test   %edx,%edx
80100a1c:	74 0a                	je     80100a28 <consoleintr+0x1a8>
80100a1e:	fa                   	cli    
    for(;;)
80100a1f:	eb fe                	jmp    80100a1f <consoleintr+0x19f>
80100a21:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80100a28:	b8 0a 00 00 00       	mov    $0xa,%eax
80100a2d:	e8 ce f9 ff ff       	call   80100400 <consputc.part.0>
          input.w = input.e;
80100a32:	a1 08 ff 10 80       	mov    0x8010ff08,%eax
          wakeup(&input.r);
80100a37:	83 ec 0c             	sub    $0xc,%esp
          input.w = input.e;
80100a3a:	a3 04 ff 10 80       	mov    %eax,0x8010ff04
          wakeup(&input.r);
80100a3f:	68 00 ff 10 80       	push   $0x8010ff00
80100a44:	e8 47 3b 00 00       	call   80104590 <wakeup>
80100a49:	83 c4 10             	add    $0x10,%esp
80100a4c:	e9 66 fe ff ff       	jmp    801008b7 <consoleintr+0x37>
80100a51:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80100a58:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80100a5f:	90                   	nop

80100a60 <consoleinit>:

void
consoleinit(void)
{
80100a60:	55                   	push   %ebp
80100a61:	89 e5                	mov    %esp,%ebp
80100a63:	83 ec 10             	sub    $0x10,%esp
  initlock(&cons.lock, "console");
80100a66:	68 08 81 10 80       	push   $0x80108108
80100a6b:	68 20 ff 10 80       	push   $0x8010ff20
80100a70:	e8 5b 3f 00 00       	call   801049d0 <initlock>

  devsw[CONSOLE].write = consolewrite;
  devsw[CONSOLE].read = consoleread;
  cons.locking = 1;

  ioapicenable(IRQ_KBD, 0);
80100a75:	58                   	pop    %eax
80100a76:	5a                   	pop    %edx
80100a77:	6a 00                	push   $0x0
80100a79:	6a 01                	push   $0x1
  devsw[CONSOLE].write = consolewrite;
80100a7b:	c7 05 0c 09 11 80 90 	movl   $0x80100590,0x8011090c
80100a82:	05 10 80 
  devsw[CONSOLE].read = consoleread;
80100a85:	c7 05 08 09 11 80 80 	movl   $0x80100280,0x80110908
80100a8c:	02 10 80 
  cons.locking = 1;
80100a8f:	c7 05 54 ff 10 80 01 	movl   $0x1,0x8010ff54
80100a96:	00 00 00 
  ioapicenable(IRQ_KBD, 0);
80100a99:	e8 f2 19 00 00       	call   80102490 <ioapicenable>
}
80100a9e:	83 c4 10             	add    $0x10,%esp
80100aa1:	c9                   	leave  
80100aa2:	c3                   	ret    
80100aa3:	66 90                	xchg   %ax,%ax
80100aa5:	66 90                	xchg   %ax,%ax
80100aa7:	66 90                	xchg   %ax,%ax
80100aa9:	66 90                	xchg   %ax,%ax
80100aab:	66 90                	xchg   %ax,%ax
80100aad:	66 90                	xchg   %ax,%ax
80100aaf:	90                   	nop

80100ab0 <exec>:
#include "x86.h"
#include "elf.h"

int
exec(char *path, char **argv)
{
80100ab0:	55                   	push   %ebp
80100ab1:	89 e5                	mov    %esp,%ebp
80100ab3:	57                   	push   %edi
80100ab4:	56                   	push   %esi
80100ab5:	53                   	push   %ebx
80100ab6:	81 ec 0c 01 00 00    	sub    $0x10c,%esp
  uint argc, sz, sp, ustack[3+MAXARG+1];
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pde_t *pgdir, *oldpgdir;
  struct proc *curproc = myproc();
80100abc:	e8 2f 2f 00 00       	call   801039f0 <myproc>
80100ac1:	89 85 ec fe ff ff    	mov    %eax,-0x114(%ebp)

  begin_op();
80100ac7:	e8 04 23 00 00       	call   80102dd0 <begin_op>

  if((ip = namei(path)) == 0){
80100acc:	83 ec 0c             	sub    $0xc,%esp
80100acf:	ff 75 08             	push   0x8(%ebp)
80100ad2:	e8 d9 15 00 00       	call   801020b0 <namei>
80100ad7:	83 c4 10             	add    $0x10,%esp
80100ada:	85 c0                	test   %eax,%eax
80100adc:	0f 84 12 03 00 00    	je     80100df4 <exec+0x344>
    end_op();
    cprintf("exec: fail\n");
    return -1;
  }
  ilock(ip);
80100ae2:	83 ec 0c             	sub    $0xc,%esp
80100ae5:	89 c3                	mov    %eax,%ebx
80100ae7:	50                   	push   %eax
80100ae8:	e8 a3 0c 00 00       	call   80101790 <ilock>
  pgdir = 0;

  // Check ELF header
  if(readi(ip, (char*)&elf, 0, sizeof(elf)) != sizeof(elf))
80100aed:	8d 85 24 ff ff ff    	lea    -0xdc(%ebp),%eax
80100af3:	6a 34                	push   $0x34
80100af5:	6a 00                	push   $0x0
80100af7:	50                   	push   %eax
80100af8:	53                   	push   %ebx
80100af9:	e8 a2 0f 00 00       	call   80101aa0 <readi>
80100afe:	83 c4 20             	add    $0x20,%esp
80100b01:	83 f8 34             	cmp    $0x34,%eax
80100b04:	74 22                	je     80100b28 <exec+0x78>

 bad:
  if(pgdir)
    freevm(pgdir);
  if(ip){
    iunlockput(ip);
80100b06:	83 ec 0c             	sub    $0xc,%esp
80100b09:	53                   	push   %ebx
80100b0a:	e8 11 0f 00 00       	call   80101a20 <iunlockput>
    end_op();
80100b0f:	e8 2c 23 00 00       	call   80102e40 <end_op>
80100b14:	83 c4 10             	add    $0x10,%esp
  }
  return -1;
80100b17:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80100b1c:	8d 65 f4             	lea    -0xc(%ebp),%esp
80100b1f:	5b                   	pop    %ebx
80100b20:	5e                   	pop    %esi
80100b21:	5f                   	pop    %edi
80100b22:	5d                   	pop    %ebp
80100b23:	c3                   	ret    
80100b24:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  if(elf.magic != ELF_MAGIC)
80100b28:	81 bd 24 ff ff ff 7f 	cmpl   $0x464c457f,-0xdc(%ebp)
80100b2f:	45 4c 46 
80100b32:	75 d2                	jne    80100b06 <exec+0x56>
  if((pgdir = setupkvm()) == 0)
80100b34:	e8 17 72 00 00       	call   80107d50 <setupkvm>
80100b39:	89 85 f4 fe ff ff    	mov    %eax,-0x10c(%ebp)
80100b3f:	85 c0                	test   %eax,%eax
80100b41:	74 c3                	je     80100b06 <exec+0x56>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100b43:	66 83 bd 50 ff ff ff 	cmpw   $0x0,-0xb0(%ebp)
80100b4a:	00 
80100b4b:	8b b5 40 ff ff ff    	mov    -0xc0(%ebp),%esi
80100b51:	0f 84 bc 02 00 00    	je     80100e13 <exec+0x363>
  sz = 0;
80100b57:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
80100b5e:	00 00 00 
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100b61:	31 ff                	xor    %edi,%edi
80100b63:	e9 98 00 00 00       	jmp    80100c00 <exec+0x150>
80100b68:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80100b6f:	90                   	nop
    if(ph.type != ELF_PROG_LOAD)
80100b70:	83 bd 04 ff ff ff 01 	cmpl   $0x1,-0xfc(%ebp)
80100b77:	75 76                	jne    80100bef <exec+0x13f>
    if(ph.memsz < ph.filesz)
80100b79:	8b 85 18 ff ff ff    	mov    -0xe8(%ebp),%eax
80100b7f:	3b 85 14 ff ff ff    	cmp    -0xec(%ebp),%eax
80100b85:	0f 82 91 00 00 00    	jb     80100c1c <exec+0x16c>
    if(ph.vaddr + ph.memsz < ph.vaddr)
80100b8b:	03 85 0c ff ff ff    	add    -0xf4(%ebp),%eax
80100b91:	0f 82 85 00 00 00    	jb     80100c1c <exec+0x16c>
    if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
80100b97:	83 ec 04             	sub    $0x4,%esp
80100b9a:	50                   	push   %eax
80100b9b:	ff b5 f0 fe ff ff    	push   -0x110(%ebp)
80100ba1:	ff b5 f4 fe ff ff    	push   -0x10c(%ebp)
80100ba7:	e8 c4 6f 00 00       	call   80107b70 <allocuvm>
80100bac:	83 c4 10             	add    $0x10,%esp
80100baf:	89 85 f0 fe ff ff    	mov    %eax,-0x110(%ebp)
80100bb5:	85 c0                	test   %eax,%eax
80100bb7:	74 63                	je     80100c1c <exec+0x16c>
    if(ph.vaddr % PGSIZE != 0)
80100bb9:	8b 85 0c ff ff ff    	mov    -0xf4(%ebp),%eax
80100bbf:	a9 ff 0f 00 00       	test   $0xfff,%eax
80100bc4:	75 56                	jne    80100c1c <exec+0x16c>
    if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz, ph.flags) < 0)
80100bc6:	83 ec 08             	sub    $0x8,%esp
80100bc9:	ff b5 1c ff ff ff    	push   -0xe4(%ebp)
80100bcf:	ff b5 14 ff ff ff    	push   -0xec(%ebp)
80100bd5:	ff b5 08 ff ff ff    	push   -0xf8(%ebp)
80100bdb:	53                   	push   %ebx
80100bdc:	50                   	push   %eax
80100bdd:	ff b5 f4 fe ff ff    	push   -0x10c(%ebp)
80100be3:	e8 78 6e 00 00       	call   80107a60 <loaduvm>
80100be8:	83 c4 20             	add    $0x20,%esp
80100beb:	85 c0                	test   %eax,%eax
80100bed:	78 2d                	js     80100c1c <exec+0x16c>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100bef:	0f b7 85 50 ff ff ff 	movzwl -0xb0(%ebp),%eax
80100bf6:	83 c7 01             	add    $0x1,%edi
80100bf9:	83 c6 20             	add    $0x20,%esi
80100bfc:	39 f8                	cmp    %edi,%eax
80100bfe:	7e 38                	jle    80100c38 <exec+0x188>
    if(readi(ip, (char*)&ph, off, sizeof(ph)) != sizeof(ph))
80100c00:	8d 85 04 ff ff ff    	lea    -0xfc(%ebp),%eax
80100c06:	6a 20                	push   $0x20
80100c08:	56                   	push   %esi
80100c09:	50                   	push   %eax
80100c0a:	53                   	push   %ebx
80100c0b:	e8 90 0e 00 00       	call   80101aa0 <readi>
80100c10:	83 c4 10             	add    $0x10,%esp
80100c13:	83 f8 20             	cmp    $0x20,%eax
80100c16:	0f 84 54 ff ff ff    	je     80100b70 <exec+0xc0>
    freevm(pgdir);
80100c1c:	83 ec 0c             	sub    $0xc,%esp
80100c1f:	ff b5 f4 fe ff ff    	push   -0x10c(%ebp)
80100c25:	e8 a6 70 00 00       	call   80107cd0 <freevm>
  if(ip){
80100c2a:	83 c4 10             	add    $0x10,%esp
80100c2d:	e9 d4 fe ff ff       	jmp    80100b06 <exec+0x56>
80100c32:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  sz = PGROUNDUP(sz);
80100c38:	8b bd f0 fe ff ff    	mov    -0x110(%ebp),%edi
80100c3e:	81 c7 ff 0f 00 00    	add    $0xfff,%edi
80100c44:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
  if((sz = allocuvm(pgdir, sz, sz + 2*PGSIZE)) == 0)
80100c4a:	8d b7 00 20 00 00    	lea    0x2000(%edi),%esi
  iunlockput(ip);
80100c50:	83 ec 0c             	sub    $0xc,%esp
80100c53:	53                   	push   %ebx
80100c54:	e8 c7 0d 00 00       	call   80101a20 <iunlockput>
  end_op();
80100c59:	e8 e2 21 00 00       	call   80102e40 <end_op>
  if((sz = allocuvm(pgdir, sz, sz + 2*PGSIZE)) == 0)
80100c5e:	83 c4 0c             	add    $0xc,%esp
80100c61:	56                   	push   %esi
80100c62:	57                   	push   %edi
80100c63:	8b bd f4 fe ff ff    	mov    -0x10c(%ebp),%edi
80100c69:	57                   	push   %edi
80100c6a:	e8 01 6f 00 00       	call   80107b70 <allocuvm>
80100c6f:	83 c4 10             	add    $0x10,%esp
80100c72:	89 c6                	mov    %eax,%esi
80100c74:	85 c0                	test   %eax,%eax
80100c76:	0f 84 94 00 00 00    	je     80100d10 <exec+0x260>
  clearpteu(pgdir, (char*)(sz - 2*PGSIZE));
80100c7c:	83 ec 08             	sub    $0x8,%esp
80100c7f:	8d 80 00 e0 ff ff    	lea    -0x2000(%eax),%eax
  for(argc = 0; argv[argc]; argc++) {
80100c85:	89 f3                	mov    %esi,%ebx
  clearpteu(pgdir, (char*)(sz - 2*PGSIZE));
80100c87:	50                   	push   %eax
80100c88:	57                   	push   %edi
  for(argc = 0; argv[argc]; argc++) {
80100c89:	31 ff                	xor    %edi,%edi
  clearpteu(pgdir, (char*)(sz - 2*PGSIZE));
80100c8b:	e8 60 71 00 00       	call   80107df0 <clearpteu>
  for(argc = 0; argv[argc]; argc++) {
80100c90:	8b 45 0c             	mov    0xc(%ebp),%eax
80100c93:	83 c4 10             	add    $0x10,%esp
80100c96:	8d 95 58 ff ff ff    	lea    -0xa8(%ebp),%edx
80100c9c:	8b 00                	mov    (%eax),%eax
80100c9e:	85 c0                	test   %eax,%eax
80100ca0:	0f 84 8b 00 00 00    	je     80100d31 <exec+0x281>
80100ca6:	89 b5 f0 fe ff ff    	mov    %esi,-0x110(%ebp)
80100cac:	8b b5 f4 fe ff ff    	mov    -0x10c(%ebp),%esi
80100cb2:	eb 23                	jmp    80100cd7 <exec+0x227>
80100cb4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80100cb8:	8b 45 0c             	mov    0xc(%ebp),%eax
    ustack[3+argc] = sp;
80100cbb:	89 9c bd 64 ff ff ff 	mov    %ebx,-0x9c(%ebp,%edi,4)
  for(argc = 0; argv[argc]; argc++) {
80100cc2:	83 c7 01             	add    $0x1,%edi
    ustack[3+argc] = sp;
80100cc5:	8d 95 58 ff ff ff    	lea    -0xa8(%ebp),%edx
  for(argc = 0; argv[argc]; argc++) {
80100ccb:	8b 04 b8             	mov    (%eax,%edi,4),%eax
80100cce:	85 c0                	test   %eax,%eax
80100cd0:	74 59                	je     80100d2b <exec+0x27b>
    if(argc >= MAXARG)
80100cd2:	83 ff 20             	cmp    $0x20,%edi
80100cd5:	74 39                	je     80100d10 <exec+0x260>
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
80100cd7:	83 ec 0c             	sub    $0xc,%esp
80100cda:	50                   	push   %eax
80100cdb:	e8 80 41 00 00       	call   80104e60 <strlen>
80100ce0:	29 c3                	sub    %eax,%ebx
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
80100ce2:	58                   	pop    %eax
80100ce3:	8b 45 0c             	mov    0xc(%ebp),%eax
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
80100ce6:	83 eb 01             	sub    $0x1,%ebx
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
80100ce9:	ff 34 b8             	push   (%eax,%edi,4)
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
80100cec:	83 e3 fc             	and    $0xfffffffc,%ebx
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
80100cef:	e8 6c 41 00 00       	call   80104e60 <strlen>
80100cf4:	83 c0 01             	add    $0x1,%eax
80100cf7:	50                   	push   %eax
80100cf8:	8b 45 0c             	mov    0xc(%ebp),%eax
80100cfb:	ff 34 b8             	push   (%eax,%edi,4)
80100cfe:	53                   	push   %ebx
80100cff:	56                   	push   %esi
80100d00:	e8 ab 72 00 00       	call   80107fb0 <copyout>
80100d05:	83 c4 20             	add    $0x20,%esp
80100d08:	85 c0                	test   %eax,%eax
80100d0a:	79 ac                	jns    80100cb8 <exec+0x208>
80100d0c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    freevm(pgdir);
80100d10:	83 ec 0c             	sub    $0xc,%esp
80100d13:	ff b5 f4 fe ff ff    	push   -0x10c(%ebp)
80100d19:	e8 b2 6f 00 00       	call   80107cd0 <freevm>
80100d1e:	83 c4 10             	add    $0x10,%esp
  return -1;
80100d21:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100d26:	e9 f1 fd ff ff       	jmp    80100b1c <exec+0x6c>
80100d2b:	8b b5 f0 fe ff ff    	mov    -0x110(%ebp),%esi
  ustack[2] = sp - (argc+1)*4;  // argv pointer
80100d31:	8d 04 bd 04 00 00 00 	lea    0x4(,%edi,4),%eax
80100d38:	89 d9                	mov    %ebx,%ecx
  ustack[3+argc] = 0;
80100d3a:	c7 84 bd 64 ff ff ff 	movl   $0x0,-0x9c(%ebp,%edi,4)
80100d41:	00 00 00 00 
  ustack[2] = sp - (argc+1)*4;  // argv pointer
80100d45:	29 c1                	sub    %eax,%ecx
  sp -= (3+argc+1) * 4;
80100d47:	83 c0 0c             	add    $0xc,%eax
  ustack[1] = argc;
80100d4a:	89 bd 5c ff ff ff    	mov    %edi,-0xa4(%ebp)
  sp -= (3+argc+1) * 4;
80100d50:	29 c3                	sub    %eax,%ebx
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
80100d52:	50                   	push   %eax
80100d53:	52                   	push   %edx
80100d54:	53                   	push   %ebx
80100d55:	ff b5 f4 fe ff ff    	push   -0x10c(%ebp)
  ustack[0] = 0xffffffff;  // fake return PC
80100d5b:	c7 85 58 ff ff ff ff 	movl   $0xffffffff,-0xa8(%ebp)
80100d62:	ff ff ff 
  ustack[2] = sp - (argc+1)*4;  // argv pointer
80100d65:	89 8d 60 ff ff ff    	mov    %ecx,-0xa0(%ebp)
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
80100d6b:	e8 40 72 00 00       	call   80107fb0 <copyout>
80100d70:	83 c4 10             	add    $0x10,%esp
80100d73:	85 c0                	test   %eax,%eax
80100d75:	78 99                	js     80100d10 <exec+0x260>
  for(last=s=path; *s; s++)
80100d77:	8b 45 08             	mov    0x8(%ebp),%eax
80100d7a:	8b 55 08             	mov    0x8(%ebp),%edx
80100d7d:	0f b6 00             	movzbl (%eax),%eax
80100d80:	84 c0                	test   %al,%al
80100d82:	74 1b                	je     80100d9f <exec+0x2ef>
80100d84:	89 d1                	mov    %edx,%ecx
80100d86:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80100d8d:	8d 76 00             	lea    0x0(%esi),%esi
      last = s+1;
80100d90:	83 c1 01             	add    $0x1,%ecx
80100d93:	3c 2f                	cmp    $0x2f,%al
  for(last=s=path; *s; s++)
80100d95:	0f b6 01             	movzbl (%ecx),%eax
      last = s+1;
80100d98:	0f 44 d1             	cmove  %ecx,%edx
  for(last=s=path; *s; s++)
80100d9b:	84 c0                	test   %al,%al
80100d9d:	75 f1                	jne    80100d90 <exec+0x2e0>
  safestrcpy(curproc->name, last, sizeof(curproc->name));
80100d9f:	8b bd ec fe ff ff    	mov    -0x114(%ebp),%edi
80100da5:	83 ec 04             	sub    $0x4,%esp
80100da8:	6a 10                	push   $0x10
80100daa:	89 f8                	mov    %edi,%eax
80100dac:	52                   	push   %edx
80100dad:	83 c0 6c             	add    $0x6c,%eax
80100db0:	50                   	push   %eax
80100db1:	e8 6a 40 00 00       	call   80104e20 <safestrcpy>
  curproc->pgdir = pgdir;
80100db6:	8b 8d f4 fe ff ff    	mov    -0x10c(%ebp),%ecx
  oldpgdir = curproc->pgdir;
80100dbc:	89 f8                	mov    %edi,%eax
80100dbe:	8b 7f 04             	mov    0x4(%edi),%edi
  curproc->sz = sz;
80100dc1:	89 30                	mov    %esi,(%eax)
  curproc->pgdir = pgdir;
80100dc3:	89 48 04             	mov    %ecx,0x4(%eax)
  curproc->tf->eip = elf.entry;  // main
80100dc6:	89 c1                	mov    %eax,%ecx
80100dc8:	8b 95 3c ff ff ff    	mov    -0xc4(%ebp),%edx
80100dce:	8b 40 18             	mov    0x18(%eax),%eax
80100dd1:	89 50 38             	mov    %edx,0x38(%eax)
  curproc->tf->esp = sp;
80100dd4:	8b 41 18             	mov    0x18(%ecx),%eax
80100dd7:	89 58 44             	mov    %ebx,0x44(%eax)
  switchuvm(curproc);
80100dda:	89 0c 24             	mov    %ecx,(%esp)
80100ddd:	e8 ee 6a 00 00       	call   801078d0 <switchuvm>
  freevm(oldpgdir);
80100de2:	89 3c 24             	mov    %edi,(%esp)
80100de5:	e8 e6 6e 00 00       	call   80107cd0 <freevm>
  return 0;
80100dea:	83 c4 10             	add    $0x10,%esp
80100ded:	31 c0                	xor    %eax,%eax
80100def:	e9 28 fd ff ff       	jmp    80100b1c <exec+0x6c>
    end_op();
80100df4:	e8 47 20 00 00       	call   80102e40 <end_op>
    cprintf("exec: fail\n");
80100df9:	83 ec 0c             	sub    $0xc,%esp
80100dfc:	68 21 81 10 80       	push   $0x80108121
80100e01:	e8 9a f8 ff ff       	call   801006a0 <cprintf>
    return -1;
80100e06:	83 c4 10             	add    $0x10,%esp
80100e09:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100e0e:	e9 09 fd ff ff       	jmp    80100b1c <exec+0x6c>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100e13:	be 00 20 00 00       	mov    $0x2000,%esi
80100e18:	31 ff                	xor    %edi,%edi
80100e1a:	e9 31 fe ff ff       	jmp    80100c50 <exec+0x1a0>
80100e1f:	90                   	nop

80100e20 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
80100e20:	55                   	push   %ebp
80100e21:	89 e5                	mov    %esp,%ebp
80100e23:	83 ec 10             	sub    $0x10,%esp
  initlock(&ftable.lock, "ftable");
80100e26:	68 2d 81 10 80       	push   $0x8010812d
80100e2b:	68 60 ff 10 80       	push   $0x8010ff60
80100e30:	e8 9b 3b 00 00       	call   801049d0 <initlock>
}
80100e35:	83 c4 10             	add    $0x10,%esp
80100e38:	c9                   	leave  
80100e39:	c3                   	ret    
80100e3a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

80100e40 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
80100e40:	55                   	push   %ebp
80100e41:	89 e5                	mov    %esp,%ebp
80100e43:	53                   	push   %ebx
  struct file *f;

  acquire(&ftable.lock);
  for(f = ftable.file; f < ftable.file + NFILE; f++){
80100e44:	bb 94 ff 10 80       	mov    $0x8010ff94,%ebx
{
80100e49:	83 ec 10             	sub    $0x10,%esp
  acquire(&ftable.lock);
80100e4c:	68 60 ff 10 80       	push   $0x8010ff60
80100e51:	e8 4a 3d 00 00       	call   80104ba0 <acquire>
80100e56:	83 c4 10             	add    $0x10,%esp
80100e59:	eb 10                	jmp    80100e6b <filealloc+0x2b>
80100e5b:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80100e5f:	90                   	nop
  for(f = ftable.file; f < ftable.file + NFILE; f++){
80100e60:	83 c3 18             	add    $0x18,%ebx
80100e63:	81 fb f4 08 11 80    	cmp    $0x801108f4,%ebx
80100e69:	74 25                	je     80100e90 <filealloc+0x50>
    if(f->ref == 0){
80100e6b:	8b 43 04             	mov    0x4(%ebx),%eax
80100e6e:	85 c0                	test   %eax,%eax
80100e70:	75 ee                	jne    80100e60 <filealloc+0x20>
      f->ref = 1;
      release(&ftable.lock);
80100e72:	83 ec 0c             	sub    $0xc,%esp
      f->ref = 1;
80100e75:	c7 43 04 01 00 00 00 	movl   $0x1,0x4(%ebx)
      release(&ftable.lock);
80100e7c:	68 60 ff 10 80       	push   $0x8010ff60
80100e81:	e8 ba 3c 00 00       	call   80104b40 <release>
      return f;
    }
  }
  release(&ftable.lock);
  return 0;
}
80100e86:	89 d8                	mov    %ebx,%eax
      return f;
80100e88:	83 c4 10             	add    $0x10,%esp
}
80100e8b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80100e8e:	c9                   	leave  
80100e8f:	c3                   	ret    
  release(&ftable.lock);
80100e90:	83 ec 0c             	sub    $0xc,%esp
  return 0;
80100e93:	31 db                	xor    %ebx,%ebx
  release(&ftable.lock);
80100e95:	68 60 ff 10 80       	push   $0x8010ff60
80100e9a:	e8 a1 3c 00 00       	call   80104b40 <release>
}
80100e9f:	89 d8                	mov    %ebx,%eax
  return 0;
80100ea1:	83 c4 10             	add    $0x10,%esp
}
80100ea4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80100ea7:	c9                   	leave  
80100ea8:	c3                   	ret    
80100ea9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

80100eb0 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
80100eb0:	55                   	push   %ebp
80100eb1:	89 e5                	mov    %esp,%ebp
80100eb3:	53                   	push   %ebx
80100eb4:	83 ec 10             	sub    $0x10,%esp
80100eb7:	8b 5d 08             	mov    0x8(%ebp),%ebx
  acquire(&ftable.lock);
80100eba:	68 60 ff 10 80       	push   $0x8010ff60
80100ebf:	e8 dc 3c 00 00       	call   80104ba0 <acquire>
  if(f->ref < 1)
80100ec4:	8b 43 04             	mov    0x4(%ebx),%eax
80100ec7:	83 c4 10             	add    $0x10,%esp
80100eca:	85 c0                	test   %eax,%eax
80100ecc:	7e 1a                	jle    80100ee8 <filedup+0x38>
    panic("filedup");
  f->ref++;
80100ece:	83 c0 01             	add    $0x1,%eax
  release(&ftable.lock);
80100ed1:	83 ec 0c             	sub    $0xc,%esp
  f->ref++;
80100ed4:	89 43 04             	mov    %eax,0x4(%ebx)
  release(&ftable.lock);
80100ed7:	68 60 ff 10 80       	push   $0x8010ff60
80100edc:	e8 5f 3c 00 00       	call   80104b40 <release>
  return f;
}
80100ee1:	89 d8                	mov    %ebx,%eax
80100ee3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80100ee6:	c9                   	leave  
80100ee7:	c3                   	ret    
    panic("filedup");
80100ee8:	83 ec 0c             	sub    $0xc,%esp
80100eeb:	68 34 81 10 80       	push   $0x80108134
80100ef0:	e8 8b f4 ff ff       	call   80100380 <panic>
80100ef5:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80100efc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

80100f00 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
80100f00:	55                   	push   %ebp
80100f01:	89 e5                	mov    %esp,%ebp
80100f03:	57                   	push   %edi
80100f04:	56                   	push   %esi
80100f05:	53                   	push   %ebx
80100f06:	83 ec 28             	sub    $0x28,%esp
80100f09:	8b 5d 08             	mov    0x8(%ebp),%ebx
  struct file ff;

  acquire(&ftable.lock);
80100f0c:	68 60 ff 10 80       	push   $0x8010ff60
80100f11:	e8 8a 3c 00 00       	call   80104ba0 <acquire>
  if(f->ref < 1)
80100f16:	8b 53 04             	mov    0x4(%ebx),%edx
80100f19:	83 c4 10             	add    $0x10,%esp
80100f1c:	85 d2                	test   %edx,%edx
80100f1e:	0f 8e a5 00 00 00    	jle    80100fc9 <fileclose+0xc9>
    panic("fileclose");
  if(--f->ref > 0){
80100f24:	83 ea 01             	sub    $0x1,%edx
80100f27:	89 53 04             	mov    %edx,0x4(%ebx)
80100f2a:	75 44                	jne    80100f70 <fileclose+0x70>
    release(&ftable.lock);
    return;
  }
  ff = *f;
80100f2c:	0f b6 43 09          	movzbl 0x9(%ebx),%eax
  f->ref = 0;
  f->type = FD_NONE;
  release(&ftable.lock);
80100f30:	83 ec 0c             	sub    $0xc,%esp
  ff = *f;
80100f33:	8b 3b                	mov    (%ebx),%edi
  f->type = FD_NONE;
80100f35:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  ff = *f;
80100f3b:	8b 73 0c             	mov    0xc(%ebx),%esi
80100f3e:	88 45 e7             	mov    %al,-0x19(%ebp)
80100f41:	8b 43 10             	mov    0x10(%ebx),%eax
  release(&ftable.lock);
80100f44:	68 60 ff 10 80       	push   $0x8010ff60
  ff = *f;
80100f49:	89 45 e0             	mov    %eax,-0x20(%ebp)
  release(&ftable.lock);
80100f4c:	e8 ef 3b 00 00       	call   80104b40 <release>

  if(ff.type == FD_PIPE)
80100f51:	83 c4 10             	add    $0x10,%esp
80100f54:	83 ff 01             	cmp    $0x1,%edi
80100f57:	74 57                	je     80100fb0 <fileclose+0xb0>
    pipeclose(ff.pipe, ff.writable);
  else if(ff.type == FD_INODE){
80100f59:	83 ff 02             	cmp    $0x2,%edi
80100f5c:	74 2a                	je     80100f88 <fileclose+0x88>
    begin_op();
    iput(ff.ip);
    end_op();
  }
}
80100f5e:	8d 65 f4             	lea    -0xc(%ebp),%esp
80100f61:	5b                   	pop    %ebx
80100f62:	5e                   	pop    %esi
80100f63:	5f                   	pop    %edi
80100f64:	5d                   	pop    %ebp
80100f65:	c3                   	ret    
80100f66:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80100f6d:	8d 76 00             	lea    0x0(%esi),%esi
    release(&ftable.lock);
80100f70:	c7 45 08 60 ff 10 80 	movl   $0x8010ff60,0x8(%ebp)
}
80100f77:	8d 65 f4             	lea    -0xc(%ebp),%esp
80100f7a:	5b                   	pop    %ebx
80100f7b:	5e                   	pop    %esi
80100f7c:	5f                   	pop    %edi
80100f7d:	5d                   	pop    %ebp
    release(&ftable.lock);
80100f7e:	e9 bd 3b 00 00       	jmp    80104b40 <release>
80100f83:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80100f87:	90                   	nop
    begin_op();
80100f88:	e8 43 1e 00 00       	call   80102dd0 <begin_op>
    iput(ff.ip);
80100f8d:	83 ec 0c             	sub    $0xc,%esp
80100f90:	ff 75 e0             	push   -0x20(%ebp)
80100f93:	e8 28 09 00 00       	call   801018c0 <iput>
    end_op();
80100f98:	83 c4 10             	add    $0x10,%esp
}
80100f9b:	8d 65 f4             	lea    -0xc(%ebp),%esp
80100f9e:	5b                   	pop    %ebx
80100f9f:	5e                   	pop    %esi
80100fa0:	5f                   	pop    %edi
80100fa1:	5d                   	pop    %ebp
    end_op();
80100fa2:	e9 99 1e 00 00       	jmp    80102e40 <end_op>
80100fa7:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80100fae:	66 90                	xchg   %ax,%ax
    pipeclose(ff.pipe, ff.writable);
80100fb0:	0f be 5d e7          	movsbl -0x19(%ebp),%ebx
80100fb4:	83 ec 08             	sub    $0x8,%esp
80100fb7:	53                   	push   %ebx
80100fb8:	56                   	push   %esi
80100fb9:	e8 e2 25 00 00       	call   801035a0 <pipeclose>
80100fbe:	83 c4 10             	add    $0x10,%esp
}
80100fc1:	8d 65 f4             	lea    -0xc(%ebp),%esp
80100fc4:	5b                   	pop    %ebx
80100fc5:	5e                   	pop    %esi
80100fc6:	5f                   	pop    %edi
80100fc7:	5d                   	pop    %ebp
80100fc8:	c3                   	ret    
    panic("fileclose");
80100fc9:	83 ec 0c             	sub    $0xc,%esp
80100fcc:	68 3c 81 10 80       	push   $0x8010813c
80100fd1:	e8 aa f3 ff ff       	call   80100380 <panic>
80100fd6:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80100fdd:	8d 76 00             	lea    0x0(%esi),%esi

80100fe0 <filestat>:

// Get metadata about file f.
int
filestat(struct file *f, struct stat *st)
{
80100fe0:	55                   	push   %ebp
80100fe1:	89 e5                	mov    %esp,%ebp
80100fe3:	53                   	push   %ebx
80100fe4:	83 ec 04             	sub    $0x4,%esp
80100fe7:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if(f->type == FD_INODE){
80100fea:	83 3b 02             	cmpl   $0x2,(%ebx)
80100fed:	75 31                	jne    80101020 <filestat+0x40>
    ilock(f->ip);
80100fef:	83 ec 0c             	sub    $0xc,%esp
80100ff2:	ff 73 10             	push   0x10(%ebx)
80100ff5:	e8 96 07 00 00       	call   80101790 <ilock>
    stati(f->ip, st);
80100ffa:	58                   	pop    %eax
80100ffb:	5a                   	pop    %edx
80100ffc:	ff 75 0c             	push   0xc(%ebp)
80100fff:	ff 73 10             	push   0x10(%ebx)
80101002:	e8 69 0a 00 00       	call   80101a70 <stati>
    iunlock(f->ip);
80101007:	59                   	pop    %ecx
80101008:	ff 73 10             	push   0x10(%ebx)
8010100b:	e8 60 08 00 00       	call   80101870 <iunlock>
    return 0;
  }
  return -1;
}
80101010:	8b 5d fc             	mov    -0x4(%ebp),%ebx
    return 0;
80101013:	83 c4 10             	add    $0x10,%esp
80101016:	31 c0                	xor    %eax,%eax
}
80101018:	c9                   	leave  
80101019:	c3                   	ret    
8010101a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
80101020:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  return -1;
80101023:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80101028:	c9                   	leave  
80101029:	c3                   	ret    
8010102a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

80101030 <fileread>:

// Read from file f.
int
fileread(struct file *f, char *addr, int n)
{
80101030:	55                   	push   %ebp
80101031:	89 e5                	mov    %esp,%ebp
80101033:	57                   	push   %edi
80101034:	56                   	push   %esi
80101035:	53                   	push   %ebx
80101036:	83 ec 0c             	sub    $0xc,%esp
80101039:	8b 5d 08             	mov    0x8(%ebp),%ebx
8010103c:	8b 75 0c             	mov    0xc(%ebp),%esi
8010103f:	8b 7d 10             	mov    0x10(%ebp),%edi
  int r;

  if(f->readable == 0)
80101042:	80 7b 08 00          	cmpb   $0x0,0x8(%ebx)
80101046:	74 60                	je     801010a8 <fileread+0x78>
    return -1;
  if(f->type == FD_PIPE)
80101048:	8b 03                	mov    (%ebx),%eax
8010104a:	83 f8 01             	cmp    $0x1,%eax
8010104d:	74 41                	je     80101090 <fileread+0x60>
    return piperead(f->pipe, addr, n);
  if(f->type == FD_INODE){
8010104f:	83 f8 02             	cmp    $0x2,%eax
80101052:	75 5b                	jne    801010af <fileread+0x7f>
    ilock(f->ip);
80101054:	83 ec 0c             	sub    $0xc,%esp
80101057:	ff 73 10             	push   0x10(%ebx)
8010105a:	e8 31 07 00 00       	call   80101790 <ilock>
    if((r = readi(f->ip, addr, f->off, n)) > 0)
8010105f:	57                   	push   %edi
80101060:	ff 73 14             	push   0x14(%ebx)
80101063:	56                   	push   %esi
80101064:	ff 73 10             	push   0x10(%ebx)
80101067:	e8 34 0a 00 00       	call   80101aa0 <readi>
8010106c:	83 c4 20             	add    $0x20,%esp
8010106f:	89 c6                	mov    %eax,%esi
80101071:	85 c0                	test   %eax,%eax
80101073:	7e 03                	jle    80101078 <fileread+0x48>
      f->off += r;
80101075:	01 43 14             	add    %eax,0x14(%ebx)
    iunlock(f->ip);
80101078:	83 ec 0c             	sub    $0xc,%esp
8010107b:	ff 73 10             	push   0x10(%ebx)
8010107e:	e8 ed 07 00 00       	call   80101870 <iunlock>
    return r;
80101083:	83 c4 10             	add    $0x10,%esp
  }
  panic("fileread");
}
80101086:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101089:	89 f0                	mov    %esi,%eax
8010108b:	5b                   	pop    %ebx
8010108c:	5e                   	pop    %esi
8010108d:	5f                   	pop    %edi
8010108e:	5d                   	pop    %ebp
8010108f:	c3                   	ret    
    return piperead(f->pipe, addr, n);
80101090:	8b 43 0c             	mov    0xc(%ebx),%eax
80101093:	89 45 08             	mov    %eax,0x8(%ebp)
}
80101096:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101099:	5b                   	pop    %ebx
8010109a:	5e                   	pop    %esi
8010109b:	5f                   	pop    %edi
8010109c:	5d                   	pop    %ebp
    return piperead(f->pipe, addr, n);
8010109d:	e9 9e 26 00 00       	jmp    80103740 <piperead>
801010a2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    return -1;
801010a8:	be ff ff ff ff       	mov    $0xffffffff,%esi
801010ad:	eb d7                	jmp    80101086 <fileread+0x56>
  panic("fileread");
801010af:	83 ec 0c             	sub    $0xc,%esp
801010b2:	68 46 81 10 80       	push   $0x80108146
801010b7:	e8 c4 f2 ff ff       	call   80100380 <panic>
801010bc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

801010c0 <filewrite>:

//PAGEBREAK!
// Write to file f.
int
filewrite(struct file *f, char *addr, int n)
{
801010c0:	55                   	push   %ebp
801010c1:	89 e5                	mov    %esp,%ebp
801010c3:	57                   	push   %edi
801010c4:	56                   	push   %esi
801010c5:	53                   	push   %ebx
801010c6:	83 ec 1c             	sub    $0x1c,%esp
801010c9:	8b 45 0c             	mov    0xc(%ebp),%eax
801010cc:	8b 5d 08             	mov    0x8(%ebp),%ebx
801010cf:	89 45 dc             	mov    %eax,-0x24(%ebp)
801010d2:	8b 45 10             	mov    0x10(%ebp),%eax
  int r;

  if(f->writable == 0)
801010d5:	80 7b 09 00          	cmpb   $0x0,0x9(%ebx)
{
801010d9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  if(f->writable == 0)
801010dc:	0f 84 bd 00 00 00    	je     8010119f <filewrite+0xdf>
    return -1;
  if(f->type == FD_PIPE)
801010e2:	8b 03                	mov    (%ebx),%eax
801010e4:	83 f8 01             	cmp    $0x1,%eax
801010e7:	0f 84 bf 00 00 00    	je     801011ac <filewrite+0xec>
    return pipewrite(f->pipe, addr, n);
  if(f->type == FD_INODE){
801010ed:	83 f8 02             	cmp    $0x2,%eax
801010f0:	0f 85 c8 00 00 00    	jne    801011be <filewrite+0xfe>
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * 512;
    int i = 0;
    while(i < n){
801010f6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
    int i = 0;
801010f9:	31 f6                	xor    %esi,%esi
    while(i < n){
801010fb:	85 c0                	test   %eax,%eax
801010fd:	7f 30                	jg     8010112f <filewrite+0x6f>
801010ff:	e9 94 00 00 00       	jmp    80101198 <filewrite+0xd8>
80101104:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
        n1 = max;

      begin_op();
      ilock(f->ip);
      if ((r = writei(f->ip, addr + i, f->off, n1)) > 0)
        f->off += r;
80101108:	01 43 14             	add    %eax,0x14(%ebx)
      iunlock(f->ip);
8010110b:	83 ec 0c             	sub    $0xc,%esp
8010110e:	ff 73 10             	push   0x10(%ebx)
        f->off += r;
80101111:	89 45 e0             	mov    %eax,-0x20(%ebp)
      iunlock(f->ip);
80101114:	e8 57 07 00 00       	call   80101870 <iunlock>
      end_op();
80101119:	e8 22 1d 00 00       	call   80102e40 <end_op>

      if(r < 0)
        break;
      if(r != n1)
8010111e:	8b 45 e0             	mov    -0x20(%ebp),%eax
80101121:	83 c4 10             	add    $0x10,%esp
80101124:	39 c7                	cmp    %eax,%edi
80101126:	75 5c                	jne    80101184 <filewrite+0xc4>
        panic("short filewrite");
      i += r;
80101128:	01 fe                	add    %edi,%esi
    while(i < n){
8010112a:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
8010112d:	7e 69                	jle    80101198 <filewrite+0xd8>
      int n1 = n - i;
8010112f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
80101132:	b8 00 06 00 00       	mov    $0x600,%eax
80101137:	29 f7                	sub    %esi,%edi
80101139:	39 c7                	cmp    %eax,%edi
8010113b:	0f 4f f8             	cmovg  %eax,%edi
      begin_op();
8010113e:	e8 8d 1c 00 00       	call   80102dd0 <begin_op>
      ilock(f->ip);
80101143:	83 ec 0c             	sub    $0xc,%esp
80101146:	ff 73 10             	push   0x10(%ebx)
80101149:	e8 42 06 00 00       	call   80101790 <ilock>
      if ((r = writei(f->ip, addr + i, f->off, n1)) > 0)
8010114e:	8b 45 dc             	mov    -0x24(%ebp),%eax
80101151:	57                   	push   %edi
80101152:	ff 73 14             	push   0x14(%ebx)
80101155:	01 f0                	add    %esi,%eax
80101157:	50                   	push   %eax
80101158:	ff 73 10             	push   0x10(%ebx)
8010115b:	e8 40 0a 00 00       	call   80101ba0 <writei>
80101160:	83 c4 20             	add    $0x20,%esp
80101163:	85 c0                	test   %eax,%eax
80101165:	7f a1                	jg     80101108 <filewrite+0x48>
      iunlock(f->ip);
80101167:	83 ec 0c             	sub    $0xc,%esp
8010116a:	ff 73 10             	push   0x10(%ebx)
8010116d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80101170:	e8 fb 06 00 00       	call   80101870 <iunlock>
      end_op();
80101175:	e8 c6 1c 00 00       	call   80102e40 <end_op>
      if(r < 0)
8010117a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010117d:	83 c4 10             	add    $0x10,%esp
80101180:	85 c0                	test   %eax,%eax
80101182:	75 1b                	jne    8010119f <filewrite+0xdf>
        panic("short filewrite");
80101184:	83 ec 0c             	sub    $0xc,%esp
80101187:	68 4f 81 10 80       	push   $0x8010814f
8010118c:	e8 ef f1 ff ff       	call   80100380 <panic>
80101191:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    }
    return i == n ? n : -1;
80101198:	89 f0                	mov    %esi,%eax
8010119a:	3b 75 e4             	cmp    -0x1c(%ebp),%esi
8010119d:	74 05                	je     801011a4 <filewrite+0xe4>
8010119f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  }
  panic("filewrite");
}
801011a4:	8d 65 f4             	lea    -0xc(%ebp),%esp
801011a7:	5b                   	pop    %ebx
801011a8:	5e                   	pop    %esi
801011a9:	5f                   	pop    %edi
801011aa:	5d                   	pop    %ebp
801011ab:	c3                   	ret    
    return pipewrite(f->pipe, addr, n);
801011ac:	8b 43 0c             	mov    0xc(%ebx),%eax
801011af:	89 45 08             	mov    %eax,0x8(%ebp)
}
801011b2:	8d 65 f4             	lea    -0xc(%ebp),%esp
801011b5:	5b                   	pop    %ebx
801011b6:	5e                   	pop    %esi
801011b7:	5f                   	pop    %edi
801011b8:	5d                   	pop    %ebp
    return pipewrite(f->pipe, addr, n);
801011b9:	e9 82 24 00 00       	jmp    80103640 <pipewrite>
  panic("filewrite");
801011be:	83 ec 0c             	sub    $0xc,%esp
801011c1:	68 55 81 10 80       	push   $0x80108155
801011c6:	e8 b5 f1 ff ff       	call   80100380 <panic>
801011cb:	66 90                	xchg   %ax,%ax
801011cd:	66 90                	xchg   %ax,%ax
801011cf:	90                   	nop

801011d0 <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
801011d0:	55                   	push   %ebp
801011d1:	89 c1                	mov    %eax,%ecx
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
801011d3:	89 d0                	mov    %edx,%eax
801011d5:	c1 e8 0c             	shr    $0xc,%eax
801011d8:	03 05 cc 25 11 80    	add    0x801125cc,%eax
{
801011de:	89 e5                	mov    %esp,%ebp
801011e0:	56                   	push   %esi
801011e1:	53                   	push   %ebx
801011e2:	89 d3                	mov    %edx,%ebx
  bp = bread(dev, BBLOCK(b, sb));
801011e4:	83 ec 08             	sub    $0x8,%esp
801011e7:	50                   	push   %eax
801011e8:	51                   	push   %ecx
801011e9:	e8 e2 ee ff ff       	call   801000d0 <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
801011ee:	89 d9                	mov    %ebx,%ecx
  if((bp->data[bi/8] & m) == 0)
801011f0:	c1 fb 03             	sar    $0x3,%ebx
801011f3:	83 c4 10             	add    $0x10,%esp
  bp = bread(dev, BBLOCK(b, sb));
801011f6:	89 c6                	mov    %eax,%esi
  m = 1 << (bi % 8);
801011f8:	83 e1 07             	and    $0x7,%ecx
801011fb:	b8 01 00 00 00       	mov    $0x1,%eax
  if((bp->data[bi/8] & m) == 0)
80101200:	81 e3 ff 01 00 00    	and    $0x1ff,%ebx
  m = 1 << (bi % 8);
80101206:	d3 e0                	shl    %cl,%eax
  if((bp->data[bi/8] & m) == 0)
80101208:	0f b6 4c 1e 5c       	movzbl 0x5c(%esi,%ebx,1),%ecx
8010120d:	85 c1                	test   %eax,%ecx
8010120f:	74 23                	je     80101234 <bfree+0x64>
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
80101211:	f7 d0                	not    %eax
  log_write(bp);
80101213:	83 ec 0c             	sub    $0xc,%esp
  bp->data[bi/8] &= ~m;
80101216:	21 c8                	and    %ecx,%eax
80101218:	88 44 1e 5c          	mov    %al,0x5c(%esi,%ebx,1)
  log_write(bp);
8010121c:	56                   	push   %esi
8010121d:	e8 8e 1d 00 00       	call   80102fb0 <log_write>
  brelse(bp);
80101222:	89 34 24             	mov    %esi,(%esp)
80101225:	e8 c6 ef ff ff       	call   801001f0 <brelse>
}
8010122a:	83 c4 10             	add    $0x10,%esp
8010122d:	8d 65 f8             	lea    -0x8(%ebp),%esp
80101230:	5b                   	pop    %ebx
80101231:	5e                   	pop    %esi
80101232:	5d                   	pop    %ebp
80101233:	c3                   	ret    
    panic("freeing free block");
80101234:	83 ec 0c             	sub    $0xc,%esp
80101237:	68 5f 81 10 80       	push   $0x8010815f
8010123c:	e8 3f f1 ff ff       	call   80100380 <panic>
80101241:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80101248:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010124f:	90                   	nop

80101250 <balloc>:
{
80101250:	55                   	push   %ebp
80101251:	89 e5                	mov    %esp,%ebp
80101253:	57                   	push   %edi
80101254:	56                   	push   %esi
80101255:	53                   	push   %ebx
80101256:	83 ec 1c             	sub    $0x1c,%esp
  for(b = 0; b < sb.size; b += BPB){
80101259:	8b 0d b4 25 11 80    	mov    0x801125b4,%ecx
{
8010125f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  for(b = 0; b < sb.size; b += BPB){
80101262:	85 c9                	test   %ecx,%ecx
80101264:	0f 84 87 00 00 00    	je     801012f1 <balloc+0xa1>
8010126a:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
    bp = bread(dev, BBLOCK(b, sb));
80101271:	8b 75 dc             	mov    -0x24(%ebp),%esi
80101274:	83 ec 08             	sub    $0x8,%esp
80101277:	89 f0                	mov    %esi,%eax
80101279:	c1 f8 0c             	sar    $0xc,%eax
8010127c:	03 05 cc 25 11 80    	add    0x801125cc,%eax
80101282:	50                   	push   %eax
80101283:	ff 75 d8             	push   -0x28(%ebp)
80101286:	e8 45 ee ff ff       	call   801000d0 <bread>
8010128b:	83 c4 10             	add    $0x10,%esp
8010128e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
80101291:	a1 b4 25 11 80       	mov    0x801125b4,%eax
80101296:	89 45 e0             	mov    %eax,-0x20(%ebp)
80101299:	31 c0                	xor    %eax,%eax
8010129b:	eb 2f                	jmp    801012cc <balloc+0x7c>
8010129d:	8d 76 00             	lea    0x0(%esi),%esi
      m = 1 << (bi % 8);
801012a0:	89 c1                	mov    %eax,%ecx
801012a2:	bb 01 00 00 00       	mov    $0x1,%ebx
      if((bp->data[bi/8] & m) == 0){  // Is block free?
801012a7:	8b 55 e4             	mov    -0x1c(%ebp),%edx
      m = 1 << (bi % 8);
801012aa:	83 e1 07             	and    $0x7,%ecx
801012ad:	d3 e3                	shl    %cl,%ebx
      if((bp->data[bi/8] & m) == 0){  // Is block free?
801012af:	89 c1                	mov    %eax,%ecx
801012b1:	c1 f9 03             	sar    $0x3,%ecx
801012b4:	0f b6 7c 0a 5c       	movzbl 0x5c(%edx,%ecx,1),%edi
801012b9:	89 fa                	mov    %edi,%edx
801012bb:	85 df                	test   %ebx,%edi
801012bd:	74 41                	je     80101300 <balloc+0xb0>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
801012bf:	83 c0 01             	add    $0x1,%eax
801012c2:	83 c6 01             	add    $0x1,%esi
801012c5:	3d 00 10 00 00       	cmp    $0x1000,%eax
801012ca:	74 05                	je     801012d1 <balloc+0x81>
801012cc:	39 75 e0             	cmp    %esi,-0x20(%ebp)
801012cf:	77 cf                	ja     801012a0 <balloc+0x50>
    brelse(bp);
801012d1:	83 ec 0c             	sub    $0xc,%esp
801012d4:	ff 75 e4             	push   -0x1c(%ebp)
801012d7:	e8 14 ef ff ff       	call   801001f0 <brelse>
  for(b = 0; b < sb.size; b += BPB){
801012dc:	81 45 dc 00 10 00 00 	addl   $0x1000,-0x24(%ebp)
801012e3:	83 c4 10             	add    $0x10,%esp
801012e6:	8b 45 dc             	mov    -0x24(%ebp),%eax
801012e9:	39 05 b4 25 11 80    	cmp    %eax,0x801125b4
801012ef:	77 80                	ja     80101271 <balloc+0x21>
  panic("balloc: out of blocks");
801012f1:	83 ec 0c             	sub    $0xc,%esp
801012f4:	68 72 81 10 80       	push   $0x80108172
801012f9:	e8 82 f0 ff ff       	call   80100380 <panic>
801012fe:	66 90                	xchg   %ax,%ax
        bp->data[bi/8] |= m;  // Mark block in use.
80101300:	8b 7d e4             	mov    -0x1c(%ebp),%edi
        log_write(bp);
80101303:	83 ec 0c             	sub    $0xc,%esp
        bp->data[bi/8] |= m;  // Mark block in use.
80101306:	09 da                	or     %ebx,%edx
80101308:	88 54 0f 5c          	mov    %dl,0x5c(%edi,%ecx,1)
        log_write(bp);
8010130c:	57                   	push   %edi
8010130d:	e8 9e 1c 00 00       	call   80102fb0 <log_write>
        brelse(bp);
80101312:	89 3c 24             	mov    %edi,(%esp)
80101315:	e8 d6 ee ff ff       	call   801001f0 <brelse>
  bp = bread(dev, bno);
8010131a:	58                   	pop    %eax
8010131b:	5a                   	pop    %edx
8010131c:	56                   	push   %esi
8010131d:	ff 75 d8             	push   -0x28(%ebp)
80101320:	e8 ab ed ff ff       	call   801000d0 <bread>
  memset(bp->data, 0, BSIZE);
80101325:	83 c4 0c             	add    $0xc,%esp
  bp = bread(dev, bno);
80101328:	89 c3                	mov    %eax,%ebx
  memset(bp->data, 0, BSIZE);
8010132a:	8d 40 5c             	lea    0x5c(%eax),%eax
8010132d:	68 00 02 00 00       	push   $0x200
80101332:	6a 00                	push   $0x0
80101334:	50                   	push   %eax
80101335:	e8 26 39 00 00       	call   80104c60 <memset>
  log_write(bp);
8010133a:	89 1c 24             	mov    %ebx,(%esp)
8010133d:	e8 6e 1c 00 00       	call   80102fb0 <log_write>
  brelse(bp);
80101342:	89 1c 24             	mov    %ebx,(%esp)
80101345:	e8 a6 ee ff ff       	call   801001f0 <brelse>
}
8010134a:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010134d:	89 f0                	mov    %esi,%eax
8010134f:	5b                   	pop    %ebx
80101350:	5e                   	pop    %esi
80101351:	5f                   	pop    %edi
80101352:	5d                   	pop    %ebp
80101353:	c3                   	ret    
80101354:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010135b:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
8010135f:	90                   	nop

80101360 <iget>:
// Find the inode with number inum on device dev
// and return the in-memory copy. Does not lock
// the inode and does not read it from disk.
static struct inode*
iget(uint dev, uint inum)
{
80101360:	55                   	push   %ebp
80101361:	89 e5                	mov    %esp,%ebp
80101363:	57                   	push   %edi
80101364:	89 c7                	mov    %eax,%edi
80101366:	56                   	push   %esi
  struct inode *ip, *empty;

  acquire(&icache.lock);

  // Is the inode already cached?
  empty = 0;
80101367:	31 f6                	xor    %esi,%esi
{
80101369:	53                   	push   %ebx
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
8010136a:	bb 94 09 11 80       	mov    $0x80110994,%ebx
{
8010136f:	83 ec 28             	sub    $0x28,%esp
80101372:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  acquire(&icache.lock);
80101375:	68 60 09 11 80       	push   $0x80110960
8010137a:	e8 21 38 00 00       	call   80104ba0 <acquire>
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
8010137f:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  acquire(&icache.lock);
80101382:	83 c4 10             	add    $0x10,%esp
80101385:	eb 1b                	jmp    801013a2 <iget+0x42>
80101387:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010138e:	66 90                	xchg   %ax,%ax
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
80101390:	39 3b                	cmp    %edi,(%ebx)
80101392:	74 6c                	je     80101400 <iget+0xa0>
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
80101394:	81 c3 90 00 00 00    	add    $0x90,%ebx
8010139a:	81 fb b4 25 11 80    	cmp    $0x801125b4,%ebx
801013a0:	73 26                	jae    801013c8 <iget+0x68>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
801013a2:	8b 43 08             	mov    0x8(%ebx),%eax
801013a5:	85 c0                	test   %eax,%eax
801013a7:	7f e7                	jg     80101390 <iget+0x30>
      ip->ref++;
      release(&icache.lock);
      return ip;
    }
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
801013a9:	85 f6                	test   %esi,%esi
801013ab:	75 e7                	jne    80101394 <iget+0x34>
801013ad:	85 c0                	test   %eax,%eax
801013af:	75 76                	jne    80101427 <iget+0xc7>
801013b1:	89 de                	mov    %ebx,%esi
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
801013b3:	81 c3 90 00 00 00    	add    $0x90,%ebx
801013b9:	81 fb b4 25 11 80    	cmp    $0x801125b4,%ebx
801013bf:	72 e1                	jb     801013a2 <iget+0x42>
801013c1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
      empty = ip;
  }

  // Recycle an inode cache entry.
  if(empty == 0)
801013c8:	85 f6                	test   %esi,%esi
801013ca:	74 79                	je     80101445 <iget+0xe5>
  ip = empty;
  ip->dev = dev;
  ip->inum = inum;
  ip->ref = 1;
  ip->valid = 0;
  release(&icache.lock);
801013cc:	83 ec 0c             	sub    $0xc,%esp
  ip->dev = dev;
801013cf:	89 3e                	mov    %edi,(%esi)
  ip->inum = inum;
801013d1:	89 56 04             	mov    %edx,0x4(%esi)
  ip->ref = 1;
801013d4:	c7 46 08 01 00 00 00 	movl   $0x1,0x8(%esi)
  ip->valid = 0;
801013db:	c7 46 4c 00 00 00 00 	movl   $0x0,0x4c(%esi)
  release(&icache.lock);
801013e2:	68 60 09 11 80       	push   $0x80110960
801013e7:	e8 54 37 00 00       	call   80104b40 <release>

  return ip;
801013ec:	83 c4 10             	add    $0x10,%esp
}
801013ef:	8d 65 f4             	lea    -0xc(%ebp),%esp
801013f2:	89 f0                	mov    %esi,%eax
801013f4:	5b                   	pop    %ebx
801013f5:	5e                   	pop    %esi
801013f6:	5f                   	pop    %edi
801013f7:	5d                   	pop    %ebp
801013f8:	c3                   	ret    
801013f9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
80101400:	39 53 04             	cmp    %edx,0x4(%ebx)
80101403:	75 8f                	jne    80101394 <iget+0x34>
      release(&icache.lock);
80101405:	83 ec 0c             	sub    $0xc,%esp
      ip->ref++;
80101408:	83 c0 01             	add    $0x1,%eax
      return ip;
8010140b:	89 de                	mov    %ebx,%esi
      release(&icache.lock);
8010140d:	68 60 09 11 80       	push   $0x80110960
      ip->ref++;
80101412:	89 43 08             	mov    %eax,0x8(%ebx)
      release(&icache.lock);
80101415:	e8 26 37 00 00       	call   80104b40 <release>
      return ip;
8010141a:	83 c4 10             	add    $0x10,%esp
}
8010141d:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101420:	89 f0                	mov    %esi,%eax
80101422:	5b                   	pop    %ebx
80101423:	5e                   	pop    %esi
80101424:	5f                   	pop    %edi
80101425:	5d                   	pop    %ebp
80101426:	c3                   	ret    
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
80101427:	81 c3 90 00 00 00    	add    $0x90,%ebx
8010142d:	81 fb b4 25 11 80    	cmp    $0x801125b4,%ebx
80101433:	73 10                	jae    80101445 <iget+0xe5>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
80101435:	8b 43 08             	mov    0x8(%ebx),%eax
80101438:	85 c0                	test   %eax,%eax
8010143a:	0f 8f 50 ff ff ff    	jg     80101390 <iget+0x30>
80101440:	e9 68 ff ff ff       	jmp    801013ad <iget+0x4d>
    panic("iget: no inodes");
80101445:	83 ec 0c             	sub    $0xc,%esp
80101448:	68 88 81 10 80       	push   $0x80108188
8010144d:	e8 2e ef ff ff       	call   80100380 <panic>
80101452:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80101459:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

80101460 <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
80101460:	55                   	push   %ebp
80101461:	89 e5                	mov    %esp,%ebp
80101463:	57                   	push   %edi
80101464:	56                   	push   %esi
80101465:	89 c6                	mov    %eax,%esi
80101467:	53                   	push   %ebx
80101468:	83 ec 1c             	sub    $0x1c,%esp
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
8010146b:	83 fa 0b             	cmp    $0xb,%edx
8010146e:	0f 86 8c 00 00 00    	jbe    80101500 <bmap+0xa0>
    if((addr = ip->addrs[bn]) == 0)
      ip->addrs[bn] = addr = balloc(ip->dev);
    return addr;
  }
  bn -= NDIRECT;
80101474:	8d 5a f4             	lea    -0xc(%edx),%ebx

  if(bn < NINDIRECT){
80101477:	83 fb 7f             	cmp    $0x7f,%ebx
8010147a:	0f 87 a2 00 00 00    	ja     80101522 <bmap+0xc2>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
80101480:	8b 80 8c 00 00 00    	mov    0x8c(%eax),%eax
80101486:	85 c0                	test   %eax,%eax
80101488:	74 5e                	je     801014e8 <bmap+0x88>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    bp = bread(ip->dev, addr);
8010148a:	83 ec 08             	sub    $0x8,%esp
8010148d:	50                   	push   %eax
8010148e:	ff 36                	push   (%esi)
80101490:	e8 3b ec ff ff       	call   801000d0 <bread>
    a = (uint*)bp->data;
    if((addr = a[bn]) == 0){
80101495:	83 c4 10             	add    $0x10,%esp
80101498:	8d 5c 98 5c          	lea    0x5c(%eax,%ebx,4),%ebx
    bp = bread(ip->dev, addr);
8010149c:	89 c2                	mov    %eax,%edx
    if((addr = a[bn]) == 0){
8010149e:	8b 3b                	mov    (%ebx),%edi
801014a0:	85 ff                	test   %edi,%edi
801014a2:	74 1c                	je     801014c0 <bmap+0x60>
      a[bn] = addr = balloc(ip->dev);
      log_write(bp);
    }
    brelse(bp);
801014a4:	83 ec 0c             	sub    $0xc,%esp
801014a7:	52                   	push   %edx
801014a8:	e8 43 ed ff ff       	call   801001f0 <brelse>
801014ad:	83 c4 10             	add    $0x10,%esp
    return addr;
  }

  panic("bmap: out of range");
}
801014b0:	8d 65 f4             	lea    -0xc(%ebp),%esp
801014b3:	89 f8                	mov    %edi,%eax
801014b5:	5b                   	pop    %ebx
801014b6:	5e                   	pop    %esi
801014b7:	5f                   	pop    %edi
801014b8:	5d                   	pop    %ebp
801014b9:	c3                   	ret    
801014ba:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
801014c0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
      a[bn] = addr = balloc(ip->dev);
801014c3:	8b 06                	mov    (%esi),%eax
801014c5:	e8 86 fd ff ff       	call   80101250 <balloc>
      log_write(bp);
801014ca:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801014cd:	83 ec 0c             	sub    $0xc,%esp
      a[bn] = addr = balloc(ip->dev);
801014d0:	89 03                	mov    %eax,(%ebx)
801014d2:	89 c7                	mov    %eax,%edi
      log_write(bp);
801014d4:	52                   	push   %edx
801014d5:	e8 d6 1a 00 00       	call   80102fb0 <log_write>
801014da:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801014dd:	83 c4 10             	add    $0x10,%esp
801014e0:	eb c2                	jmp    801014a4 <bmap+0x44>
801014e2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
801014e8:	8b 06                	mov    (%esi),%eax
801014ea:	e8 61 fd ff ff       	call   80101250 <balloc>
801014ef:	89 86 8c 00 00 00    	mov    %eax,0x8c(%esi)
801014f5:	eb 93                	jmp    8010148a <bmap+0x2a>
801014f7:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801014fe:	66 90                	xchg   %ax,%ax
    if((addr = ip->addrs[bn]) == 0)
80101500:	8d 5a 14             	lea    0x14(%edx),%ebx
80101503:	8b 7c 98 0c          	mov    0xc(%eax,%ebx,4),%edi
80101507:	85 ff                	test   %edi,%edi
80101509:	75 a5                	jne    801014b0 <bmap+0x50>
      ip->addrs[bn] = addr = balloc(ip->dev);
8010150b:	8b 00                	mov    (%eax),%eax
8010150d:	e8 3e fd ff ff       	call   80101250 <balloc>
80101512:	89 44 9e 0c          	mov    %eax,0xc(%esi,%ebx,4)
80101516:	89 c7                	mov    %eax,%edi
}
80101518:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010151b:	5b                   	pop    %ebx
8010151c:	89 f8                	mov    %edi,%eax
8010151e:	5e                   	pop    %esi
8010151f:	5f                   	pop    %edi
80101520:	5d                   	pop    %ebp
80101521:	c3                   	ret    
  panic("bmap: out of range");
80101522:	83 ec 0c             	sub    $0xc,%esp
80101525:	68 98 81 10 80       	push   $0x80108198
8010152a:	e8 51 ee ff ff       	call   80100380 <panic>
8010152f:	90                   	nop

80101530 <readsb>:
{
80101530:	55                   	push   %ebp
80101531:	89 e5                	mov    %esp,%ebp
80101533:	56                   	push   %esi
80101534:	53                   	push   %ebx
80101535:	8b 75 0c             	mov    0xc(%ebp),%esi
  bp = bread(dev, 1);
80101538:	83 ec 08             	sub    $0x8,%esp
8010153b:	6a 01                	push   $0x1
8010153d:	ff 75 08             	push   0x8(%ebp)
80101540:	e8 8b eb ff ff       	call   801000d0 <bread>
  memmove(sb, bp->data, sizeof(*sb));
80101545:	83 c4 0c             	add    $0xc,%esp
  bp = bread(dev, 1);
80101548:	89 c3                	mov    %eax,%ebx
  memmove(sb, bp->data, sizeof(*sb));
8010154a:	8d 40 5c             	lea    0x5c(%eax),%eax
8010154d:	6a 1c                	push   $0x1c
8010154f:	50                   	push   %eax
80101550:	56                   	push   %esi
80101551:	e8 aa 37 00 00       	call   80104d00 <memmove>
  brelse(bp);
80101556:	89 5d 08             	mov    %ebx,0x8(%ebp)
80101559:	83 c4 10             	add    $0x10,%esp
}
8010155c:	8d 65 f8             	lea    -0x8(%ebp),%esp
8010155f:	5b                   	pop    %ebx
80101560:	5e                   	pop    %esi
80101561:	5d                   	pop    %ebp
  brelse(bp);
80101562:	e9 89 ec ff ff       	jmp    801001f0 <brelse>
80101567:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010156e:	66 90                	xchg   %ax,%ax

80101570 <iinit>:
{
80101570:	55                   	push   %ebp
80101571:	89 e5                	mov    %esp,%ebp
80101573:	53                   	push   %ebx
80101574:	bb a0 09 11 80       	mov    $0x801109a0,%ebx
80101579:	83 ec 0c             	sub    $0xc,%esp
  initlock(&icache.lock, "icache");
8010157c:	68 ab 81 10 80       	push   $0x801081ab
80101581:	68 60 09 11 80       	push   $0x80110960
80101586:	e8 45 34 00 00       	call   801049d0 <initlock>
  for(i = 0; i < NINODE; i++) {
8010158b:	83 c4 10             	add    $0x10,%esp
8010158e:	66 90                	xchg   %ax,%ax
    initsleeplock(&icache.inode[i].lock, "inode");
80101590:	83 ec 08             	sub    $0x8,%esp
80101593:	68 b2 81 10 80       	push   $0x801081b2
80101598:	53                   	push   %ebx
  for(i = 0; i < NINODE; i++) {
80101599:	81 c3 90 00 00 00    	add    $0x90,%ebx
    initsleeplock(&icache.inode[i].lock, "inode");
8010159f:	e8 fc 32 00 00       	call   801048a0 <initsleeplock>
  for(i = 0; i < NINODE; i++) {
801015a4:	83 c4 10             	add    $0x10,%esp
801015a7:	81 fb c0 25 11 80    	cmp    $0x801125c0,%ebx
801015ad:	75 e1                	jne    80101590 <iinit+0x20>
  bp = bread(dev, 1);
801015af:	83 ec 08             	sub    $0x8,%esp
801015b2:	6a 01                	push   $0x1
801015b4:	ff 75 08             	push   0x8(%ebp)
801015b7:	e8 14 eb ff ff       	call   801000d0 <bread>
  memmove(sb, bp->data, sizeof(*sb));
801015bc:	83 c4 0c             	add    $0xc,%esp
  bp = bread(dev, 1);
801015bf:	89 c3                	mov    %eax,%ebx
  memmove(sb, bp->data, sizeof(*sb));
801015c1:	8d 40 5c             	lea    0x5c(%eax),%eax
801015c4:	6a 1c                	push   $0x1c
801015c6:	50                   	push   %eax
801015c7:	68 b4 25 11 80       	push   $0x801125b4
801015cc:	e8 2f 37 00 00       	call   80104d00 <memmove>
  brelse(bp);
801015d1:	89 1c 24             	mov    %ebx,(%esp)
801015d4:	e8 17 ec ff ff       	call   801001f0 <brelse>
  cprintf("sb: size %d nblocks %d ninodes %d nlog %d logstart %d\
801015d9:	ff 35 cc 25 11 80    	push   0x801125cc
801015df:	ff 35 c8 25 11 80    	push   0x801125c8
801015e5:	ff 35 c4 25 11 80    	push   0x801125c4
801015eb:	ff 35 c0 25 11 80    	push   0x801125c0
801015f1:	ff 35 bc 25 11 80    	push   0x801125bc
801015f7:	ff 35 b8 25 11 80    	push   0x801125b8
801015fd:	ff 35 b4 25 11 80    	push   0x801125b4
80101603:	68 18 82 10 80       	push   $0x80108218
80101608:	e8 93 f0 ff ff       	call   801006a0 <cprintf>
}
8010160d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80101610:	83 c4 30             	add    $0x30,%esp
80101613:	c9                   	leave  
80101614:	c3                   	ret    
80101615:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010161c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

80101620 <ialloc>:
{
80101620:	55                   	push   %ebp
80101621:	89 e5                	mov    %esp,%ebp
80101623:	57                   	push   %edi
80101624:	56                   	push   %esi
80101625:	53                   	push   %ebx
80101626:	83 ec 1c             	sub    $0x1c,%esp
80101629:	8b 45 0c             	mov    0xc(%ebp),%eax
  for(inum = 1; inum < sb.ninodes; inum++){
8010162c:	83 3d bc 25 11 80 01 	cmpl   $0x1,0x801125bc
{
80101633:	8b 75 08             	mov    0x8(%ebp),%esi
80101636:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  for(inum = 1; inum < sb.ninodes; inum++){
80101639:	0f 86 91 00 00 00    	jbe    801016d0 <ialloc+0xb0>
8010163f:	bf 01 00 00 00       	mov    $0x1,%edi
80101644:	eb 21                	jmp    80101667 <ialloc+0x47>
80101646:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010164d:	8d 76 00             	lea    0x0(%esi),%esi
    brelse(bp);
80101650:	83 ec 0c             	sub    $0xc,%esp
  for(inum = 1; inum < sb.ninodes; inum++){
80101653:	83 c7 01             	add    $0x1,%edi
    brelse(bp);
80101656:	53                   	push   %ebx
80101657:	e8 94 eb ff ff       	call   801001f0 <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
8010165c:	83 c4 10             	add    $0x10,%esp
8010165f:	3b 3d bc 25 11 80    	cmp    0x801125bc,%edi
80101665:	73 69                	jae    801016d0 <ialloc+0xb0>
    bp = bread(dev, IBLOCK(inum, sb));
80101667:	89 f8                	mov    %edi,%eax
80101669:	83 ec 08             	sub    $0x8,%esp
8010166c:	c1 e8 03             	shr    $0x3,%eax
8010166f:	03 05 c8 25 11 80    	add    0x801125c8,%eax
80101675:	50                   	push   %eax
80101676:	56                   	push   %esi
80101677:	e8 54 ea ff ff       	call   801000d0 <bread>
    if(dip->type == 0){  // a free inode
8010167c:	83 c4 10             	add    $0x10,%esp
    bp = bread(dev, IBLOCK(inum, sb));
8010167f:	89 c3                	mov    %eax,%ebx
    dip = (struct dinode*)bp->data + inum%IPB;
80101681:	89 f8                	mov    %edi,%eax
80101683:	83 e0 07             	and    $0x7,%eax
80101686:	c1 e0 06             	shl    $0x6,%eax
80101689:	8d 4c 03 5c          	lea    0x5c(%ebx,%eax,1),%ecx
    if(dip->type == 0){  // a free inode
8010168d:	66 83 39 00          	cmpw   $0x0,(%ecx)
80101691:	75 bd                	jne    80101650 <ialloc+0x30>
      memset(dip, 0, sizeof(*dip));
80101693:	83 ec 04             	sub    $0x4,%esp
80101696:	89 4d e0             	mov    %ecx,-0x20(%ebp)
80101699:	6a 40                	push   $0x40
8010169b:	6a 00                	push   $0x0
8010169d:	51                   	push   %ecx
8010169e:	e8 bd 35 00 00       	call   80104c60 <memset>
      dip->type = type;
801016a3:	0f b7 45 e4          	movzwl -0x1c(%ebp),%eax
801016a7:	8b 4d e0             	mov    -0x20(%ebp),%ecx
801016aa:	66 89 01             	mov    %ax,(%ecx)
      log_write(bp);   // mark it allocated on the disk
801016ad:	89 1c 24             	mov    %ebx,(%esp)
801016b0:	e8 fb 18 00 00       	call   80102fb0 <log_write>
      brelse(bp);
801016b5:	89 1c 24             	mov    %ebx,(%esp)
801016b8:	e8 33 eb ff ff       	call   801001f0 <brelse>
      return iget(dev, inum);
801016bd:	83 c4 10             	add    $0x10,%esp
}
801016c0:	8d 65 f4             	lea    -0xc(%ebp),%esp
      return iget(dev, inum);
801016c3:	89 fa                	mov    %edi,%edx
}
801016c5:	5b                   	pop    %ebx
      return iget(dev, inum);
801016c6:	89 f0                	mov    %esi,%eax
}
801016c8:	5e                   	pop    %esi
801016c9:	5f                   	pop    %edi
801016ca:	5d                   	pop    %ebp
      return iget(dev, inum);
801016cb:	e9 90 fc ff ff       	jmp    80101360 <iget>
  panic("ialloc: no inodes");
801016d0:	83 ec 0c             	sub    $0xc,%esp
801016d3:	68 b8 81 10 80       	push   $0x801081b8
801016d8:	e8 a3 ec ff ff       	call   80100380 <panic>
801016dd:	8d 76 00             	lea    0x0(%esi),%esi

801016e0 <iupdate>:
{
801016e0:	55                   	push   %ebp
801016e1:	89 e5                	mov    %esp,%ebp
801016e3:	56                   	push   %esi
801016e4:	53                   	push   %ebx
801016e5:	8b 5d 08             	mov    0x8(%ebp),%ebx
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
801016e8:	8b 43 04             	mov    0x4(%ebx),%eax
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
801016eb:	83 c3 5c             	add    $0x5c,%ebx
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
801016ee:	83 ec 08             	sub    $0x8,%esp
801016f1:	c1 e8 03             	shr    $0x3,%eax
801016f4:	03 05 c8 25 11 80    	add    0x801125c8,%eax
801016fa:	50                   	push   %eax
801016fb:	ff 73 a4             	push   -0x5c(%ebx)
801016fe:	e8 cd e9 ff ff       	call   801000d0 <bread>
  dip->type = ip->type;
80101703:	0f b7 53 f4          	movzwl -0xc(%ebx),%edx
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
80101707:	83 c4 0c             	add    $0xc,%esp
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
8010170a:	89 c6                	mov    %eax,%esi
  dip = (struct dinode*)bp->data + ip->inum%IPB;
8010170c:	8b 43 a8             	mov    -0x58(%ebx),%eax
8010170f:	83 e0 07             	and    $0x7,%eax
80101712:	c1 e0 06             	shl    $0x6,%eax
80101715:	8d 44 06 5c          	lea    0x5c(%esi,%eax,1),%eax
  dip->type = ip->type;
80101719:	66 89 10             	mov    %dx,(%eax)
  dip->major = ip->major;
8010171c:	0f b7 53 f6          	movzwl -0xa(%ebx),%edx
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
80101720:	83 c0 0c             	add    $0xc,%eax
  dip->major = ip->major;
80101723:	66 89 50 f6          	mov    %dx,-0xa(%eax)
  dip->minor = ip->minor;
80101727:	0f b7 53 f8          	movzwl -0x8(%ebx),%edx
8010172b:	66 89 50 f8          	mov    %dx,-0x8(%eax)
  dip->nlink = ip->nlink;
8010172f:	0f b7 53 fa          	movzwl -0x6(%ebx),%edx
80101733:	66 89 50 fa          	mov    %dx,-0x6(%eax)
  dip->size = ip->size;
80101737:	8b 53 fc             	mov    -0x4(%ebx),%edx
8010173a:	89 50 fc             	mov    %edx,-0x4(%eax)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
8010173d:	6a 34                	push   $0x34
8010173f:	53                   	push   %ebx
80101740:	50                   	push   %eax
80101741:	e8 ba 35 00 00       	call   80104d00 <memmove>
  log_write(bp);
80101746:	89 34 24             	mov    %esi,(%esp)
80101749:	e8 62 18 00 00       	call   80102fb0 <log_write>
  brelse(bp);
8010174e:	89 75 08             	mov    %esi,0x8(%ebp)
80101751:	83 c4 10             	add    $0x10,%esp
}
80101754:	8d 65 f8             	lea    -0x8(%ebp),%esp
80101757:	5b                   	pop    %ebx
80101758:	5e                   	pop    %esi
80101759:	5d                   	pop    %ebp
  brelse(bp);
8010175a:	e9 91 ea ff ff       	jmp    801001f0 <brelse>
8010175f:	90                   	nop

80101760 <idup>:
{
80101760:	55                   	push   %ebp
80101761:	89 e5                	mov    %esp,%ebp
80101763:	53                   	push   %ebx
80101764:	83 ec 10             	sub    $0x10,%esp
80101767:	8b 5d 08             	mov    0x8(%ebp),%ebx
  acquire(&icache.lock);
8010176a:	68 60 09 11 80       	push   $0x80110960
8010176f:	e8 2c 34 00 00       	call   80104ba0 <acquire>
  ip->ref++;
80101774:	83 43 08 01          	addl   $0x1,0x8(%ebx)
  release(&icache.lock);
80101778:	c7 04 24 60 09 11 80 	movl   $0x80110960,(%esp)
8010177f:	e8 bc 33 00 00       	call   80104b40 <release>
}
80101784:	89 d8                	mov    %ebx,%eax
80101786:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80101789:	c9                   	leave  
8010178a:	c3                   	ret    
8010178b:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
8010178f:	90                   	nop

80101790 <ilock>:
{
80101790:	55                   	push   %ebp
80101791:	89 e5                	mov    %esp,%ebp
80101793:	56                   	push   %esi
80101794:	53                   	push   %ebx
80101795:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if(ip == 0 || ip->ref < 1)
80101798:	85 db                	test   %ebx,%ebx
8010179a:	0f 84 b7 00 00 00    	je     80101857 <ilock+0xc7>
801017a0:	8b 53 08             	mov    0x8(%ebx),%edx
801017a3:	85 d2                	test   %edx,%edx
801017a5:	0f 8e ac 00 00 00    	jle    80101857 <ilock+0xc7>
  acquiresleep(&ip->lock);
801017ab:	83 ec 0c             	sub    $0xc,%esp
801017ae:	8d 43 0c             	lea    0xc(%ebx),%eax
801017b1:	50                   	push   %eax
801017b2:	e8 29 31 00 00       	call   801048e0 <acquiresleep>
  if(ip->valid == 0){
801017b7:	8b 43 4c             	mov    0x4c(%ebx),%eax
801017ba:	83 c4 10             	add    $0x10,%esp
801017bd:	85 c0                	test   %eax,%eax
801017bf:	74 0f                	je     801017d0 <ilock+0x40>
}
801017c1:	8d 65 f8             	lea    -0x8(%ebp),%esp
801017c4:	5b                   	pop    %ebx
801017c5:	5e                   	pop    %esi
801017c6:	5d                   	pop    %ebp
801017c7:	c3                   	ret    
801017c8:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801017cf:	90                   	nop
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
801017d0:	8b 43 04             	mov    0x4(%ebx),%eax
801017d3:	83 ec 08             	sub    $0x8,%esp
801017d6:	c1 e8 03             	shr    $0x3,%eax
801017d9:	03 05 c8 25 11 80    	add    0x801125c8,%eax
801017df:	50                   	push   %eax
801017e0:	ff 33                	push   (%ebx)
801017e2:	e8 e9 e8 ff ff       	call   801000d0 <bread>
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
801017e7:	83 c4 0c             	add    $0xc,%esp
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
801017ea:	89 c6                	mov    %eax,%esi
    dip = (struct dinode*)bp->data + ip->inum%IPB;
801017ec:	8b 43 04             	mov    0x4(%ebx),%eax
801017ef:	83 e0 07             	and    $0x7,%eax
801017f2:	c1 e0 06             	shl    $0x6,%eax
801017f5:	8d 44 06 5c          	lea    0x5c(%esi,%eax,1),%eax
    ip->type = dip->type;
801017f9:	0f b7 10             	movzwl (%eax),%edx
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
801017fc:	83 c0 0c             	add    $0xc,%eax
    ip->type = dip->type;
801017ff:	66 89 53 50          	mov    %dx,0x50(%ebx)
    ip->major = dip->major;
80101803:	0f b7 50 f6          	movzwl -0xa(%eax),%edx
80101807:	66 89 53 52          	mov    %dx,0x52(%ebx)
    ip->minor = dip->minor;
8010180b:	0f b7 50 f8          	movzwl -0x8(%eax),%edx
8010180f:	66 89 53 54          	mov    %dx,0x54(%ebx)
    ip->nlink = dip->nlink;
80101813:	0f b7 50 fa          	movzwl -0x6(%eax),%edx
80101817:	66 89 53 56          	mov    %dx,0x56(%ebx)
    ip->size = dip->size;
8010181b:	8b 50 fc             	mov    -0x4(%eax),%edx
8010181e:	89 53 58             	mov    %edx,0x58(%ebx)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
80101821:	6a 34                	push   $0x34
80101823:	50                   	push   %eax
80101824:	8d 43 5c             	lea    0x5c(%ebx),%eax
80101827:	50                   	push   %eax
80101828:	e8 d3 34 00 00       	call   80104d00 <memmove>
    brelse(bp);
8010182d:	89 34 24             	mov    %esi,(%esp)
80101830:	e8 bb e9 ff ff       	call   801001f0 <brelse>
    if(ip->type == 0)
80101835:	83 c4 10             	add    $0x10,%esp
80101838:	66 83 7b 50 00       	cmpw   $0x0,0x50(%ebx)
    ip->valid = 1;
8010183d:	c7 43 4c 01 00 00 00 	movl   $0x1,0x4c(%ebx)
    if(ip->type == 0)
80101844:	0f 85 77 ff ff ff    	jne    801017c1 <ilock+0x31>
      panic("ilock: no type");
8010184a:	83 ec 0c             	sub    $0xc,%esp
8010184d:	68 d0 81 10 80       	push   $0x801081d0
80101852:	e8 29 eb ff ff       	call   80100380 <panic>
    panic("ilock");
80101857:	83 ec 0c             	sub    $0xc,%esp
8010185a:	68 ca 81 10 80       	push   $0x801081ca
8010185f:	e8 1c eb ff ff       	call   80100380 <panic>
80101864:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010186b:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
8010186f:	90                   	nop

80101870 <iunlock>:
{
80101870:	55                   	push   %ebp
80101871:	89 e5                	mov    %esp,%ebp
80101873:	56                   	push   %esi
80101874:	53                   	push   %ebx
80101875:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
80101878:	85 db                	test   %ebx,%ebx
8010187a:	74 28                	je     801018a4 <iunlock+0x34>
8010187c:	83 ec 0c             	sub    $0xc,%esp
8010187f:	8d 73 0c             	lea    0xc(%ebx),%esi
80101882:	56                   	push   %esi
80101883:	e8 f8 30 00 00       	call   80104980 <holdingsleep>
80101888:	83 c4 10             	add    $0x10,%esp
8010188b:	85 c0                	test   %eax,%eax
8010188d:	74 15                	je     801018a4 <iunlock+0x34>
8010188f:	8b 43 08             	mov    0x8(%ebx),%eax
80101892:	85 c0                	test   %eax,%eax
80101894:	7e 0e                	jle    801018a4 <iunlock+0x34>
  releasesleep(&ip->lock);
80101896:	89 75 08             	mov    %esi,0x8(%ebp)
}
80101899:	8d 65 f8             	lea    -0x8(%ebp),%esp
8010189c:	5b                   	pop    %ebx
8010189d:	5e                   	pop    %esi
8010189e:	5d                   	pop    %ebp
  releasesleep(&ip->lock);
8010189f:	e9 9c 30 00 00       	jmp    80104940 <releasesleep>
    panic("iunlock");
801018a4:	83 ec 0c             	sub    $0xc,%esp
801018a7:	68 df 81 10 80       	push   $0x801081df
801018ac:	e8 cf ea ff ff       	call   80100380 <panic>
801018b1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801018b8:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801018bf:	90                   	nop

801018c0 <iput>:
{
801018c0:	55                   	push   %ebp
801018c1:	89 e5                	mov    %esp,%ebp
801018c3:	57                   	push   %edi
801018c4:	56                   	push   %esi
801018c5:	53                   	push   %ebx
801018c6:	83 ec 28             	sub    $0x28,%esp
801018c9:	8b 5d 08             	mov    0x8(%ebp),%ebx
  acquiresleep(&ip->lock);
801018cc:	8d 7b 0c             	lea    0xc(%ebx),%edi
801018cf:	57                   	push   %edi
801018d0:	e8 0b 30 00 00       	call   801048e0 <acquiresleep>
  if(ip->valid && ip->nlink == 0){
801018d5:	8b 53 4c             	mov    0x4c(%ebx),%edx
801018d8:	83 c4 10             	add    $0x10,%esp
801018db:	85 d2                	test   %edx,%edx
801018dd:	74 07                	je     801018e6 <iput+0x26>
801018df:	66 83 7b 56 00       	cmpw   $0x0,0x56(%ebx)
801018e4:	74 32                	je     80101918 <iput+0x58>
  releasesleep(&ip->lock);
801018e6:	83 ec 0c             	sub    $0xc,%esp
801018e9:	57                   	push   %edi
801018ea:	e8 51 30 00 00       	call   80104940 <releasesleep>
  acquire(&icache.lock);
801018ef:	c7 04 24 60 09 11 80 	movl   $0x80110960,(%esp)
801018f6:	e8 a5 32 00 00       	call   80104ba0 <acquire>
  ip->ref--;
801018fb:	83 6b 08 01          	subl   $0x1,0x8(%ebx)
  release(&icache.lock);
801018ff:	83 c4 10             	add    $0x10,%esp
80101902:	c7 45 08 60 09 11 80 	movl   $0x80110960,0x8(%ebp)
}
80101909:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010190c:	5b                   	pop    %ebx
8010190d:	5e                   	pop    %esi
8010190e:	5f                   	pop    %edi
8010190f:	5d                   	pop    %ebp
  release(&icache.lock);
80101910:	e9 2b 32 00 00       	jmp    80104b40 <release>
80101915:	8d 76 00             	lea    0x0(%esi),%esi
    acquire(&icache.lock);
80101918:	83 ec 0c             	sub    $0xc,%esp
8010191b:	68 60 09 11 80       	push   $0x80110960
80101920:	e8 7b 32 00 00       	call   80104ba0 <acquire>
    int r = ip->ref;
80101925:	8b 73 08             	mov    0x8(%ebx),%esi
    release(&icache.lock);
80101928:	c7 04 24 60 09 11 80 	movl   $0x80110960,(%esp)
8010192f:	e8 0c 32 00 00       	call   80104b40 <release>
    if(r == 1){
80101934:	83 c4 10             	add    $0x10,%esp
80101937:	83 fe 01             	cmp    $0x1,%esi
8010193a:	75 aa                	jne    801018e6 <iput+0x26>
8010193c:	8d 8b 8c 00 00 00    	lea    0x8c(%ebx),%ecx
80101942:	89 7d e4             	mov    %edi,-0x1c(%ebp)
80101945:	8d 73 5c             	lea    0x5c(%ebx),%esi
80101948:	89 cf                	mov    %ecx,%edi
8010194a:	eb 0b                	jmp    80101957 <iput+0x97>
8010194c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
{
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
80101950:	83 c6 04             	add    $0x4,%esi
80101953:	39 fe                	cmp    %edi,%esi
80101955:	74 19                	je     80101970 <iput+0xb0>
    if(ip->addrs[i]){
80101957:	8b 16                	mov    (%esi),%edx
80101959:	85 d2                	test   %edx,%edx
8010195b:	74 f3                	je     80101950 <iput+0x90>
      bfree(ip->dev, ip->addrs[i]);
8010195d:	8b 03                	mov    (%ebx),%eax
8010195f:	e8 6c f8 ff ff       	call   801011d0 <bfree>
      ip->addrs[i] = 0;
80101964:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
8010196a:	eb e4                	jmp    80101950 <iput+0x90>
8010196c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    }
  }

  if(ip->addrs[NDIRECT]){
80101970:	8b 83 8c 00 00 00    	mov    0x8c(%ebx),%eax
80101976:	8b 7d e4             	mov    -0x1c(%ebp),%edi
80101979:	85 c0                	test   %eax,%eax
8010197b:	75 2d                	jne    801019aa <iput+0xea>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
  iupdate(ip);
8010197d:	83 ec 0c             	sub    $0xc,%esp
  ip->size = 0;
80101980:	c7 43 58 00 00 00 00 	movl   $0x0,0x58(%ebx)
  iupdate(ip);
80101987:	53                   	push   %ebx
80101988:	e8 53 fd ff ff       	call   801016e0 <iupdate>
      ip->type = 0;
8010198d:	31 c0                	xor    %eax,%eax
8010198f:	66 89 43 50          	mov    %ax,0x50(%ebx)
      iupdate(ip);
80101993:	89 1c 24             	mov    %ebx,(%esp)
80101996:	e8 45 fd ff ff       	call   801016e0 <iupdate>
      ip->valid = 0;
8010199b:	c7 43 4c 00 00 00 00 	movl   $0x0,0x4c(%ebx)
801019a2:	83 c4 10             	add    $0x10,%esp
801019a5:	e9 3c ff ff ff       	jmp    801018e6 <iput+0x26>
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
801019aa:	83 ec 08             	sub    $0x8,%esp
801019ad:	50                   	push   %eax
801019ae:	ff 33                	push   (%ebx)
801019b0:	e8 1b e7 ff ff       	call   801000d0 <bread>
801019b5:	89 7d e0             	mov    %edi,-0x20(%ebp)
801019b8:	83 c4 10             	add    $0x10,%esp
801019bb:	8d 88 5c 02 00 00    	lea    0x25c(%eax),%ecx
801019c1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    for(j = 0; j < NINDIRECT; j++){
801019c4:	8d 70 5c             	lea    0x5c(%eax),%esi
801019c7:	89 cf                	mov    %ecx,%edi
801019c9:	eb 0c                	jmp    801019d7 <iput+0x117>
801019cb:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
801019cf:	90                   	nop
801019d0:	83 c6 04             	add    $0x4,%esi
801019d3:	39 f7                	cmp    %esi,%edi
801019d5:	74 0f                	je     801019e6 <iput+0x126>
      if(a[j])
801019d7:	8b 16                	mov    (%esi),%edx
801019d9:	85 d2                	test   %edx,%edx
801019db:	74 f3                	je     801019d0 <iput+0x110>
        bfree(ip->dev, a[j]);
801019dd:	8b 03                	mov    (%ebx),%eax
801019df:	e8 ec f7 ff ff       	call   801011d0 <bfree>
801019e4:	eb ea                	jmp    801019d0 <iput+0x110>
    brelse(bp);
801019e6:	83 ec 0c             	sub    $0xc,%esp
801019e9:	ff 75 e4             	push   -0x1c(%ebp)
801019ec:	8b 7d e0             	mov    -0x20(%ebp),%edi
801019ef:	e8 fc e7 ff ff       	call   801001f0 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
801019f4:	8b 93 8c 00 00 00    	mov    0x8c(%ebx),%edx
801019fa:	8b 03                	mov    (%ebx),%eax
801019fc:	e8 cf f7 ff ff       	call   801011d0 <bfree>
    ip->addrs[NDIRECT] = 0;
80101a01:	83 c4 10             	add    $0x10,%esp
80101a04:	c7 83 8c 00 00 00 00 	movl   $0x0,0x8c(%ebx)
80101a0b:	00 00 00 
80101a0e:	e9 6a ff ff ff       	jmp    8010197d <iput+0xbd>
80101a13:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80101a1a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

80101a20 <iunlockput>:
{
80101a20:	55                   	push   %ebp
80101a21:	89 e5                	mov    %esp,%ebp
80101a23:	56                   	push   %esi
80101a24:	53                   	push   %ebx
80101a25:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
80101a28:	85 db                	test   %ebx,%ebx
80101a2a:	74 34                	je     80101a60 <iunlockput+0x40>
80101a2c:	83 ec 0c             	sub    $0xc,%esp
80101a2f:	8d 73 0c             	lea    0xc(%ebx),%esi
80101a32:	56                   	push   %esi
80101a33:	e8 48 2f 00 00       	call   80104980 <holdingsleep>
80101a38:	83 c4 10             	add    $0x10,%esp
80101a3b:	85 c0                	test   %eax,%eax
80101a3d:	74 21                	je     80101a60 <iunlockput+0x40>
80101a3f:	8b 43 08             	mov    0x8(%ebx),%eax
80101a42:	85 c0                	test   %eax,%eax
80101a44:	7e 1a                	jle    80101a60 <iunlockput+0x40>
  releasesleep(&ip->lock);
80101a46:	83 ec 0c             	sub    $0xc,%esp
80101a49:	56                   	push   %esi
80101a4a:	e8 f1 2e 00 00       	call   80104940 <releasesleep>
  iput(ip);
80101a4f:	89 5d 08             	mov    %ebx,0x8(%ebp)
80101a52:	83 c4 10             	add    $0x10,%esp
}
80101a55:	8d 65 f8             	lea    -0x8(%ebp),%esp
80101a58:	5b                   	pop    %ebx
80101a59:	5e                   	pop    %esi
80101a5a:	5d                   	pop    %ebp
  iput(ip);
80101a5b:	e9 60 fe ff ff       	jmp    801018c0 <iput>
    panic("iunlock");
80101a60:	83 ec 0c             	sub    $0xc,%esp
80101a63:	68 df 81 10 80       	push   $0x801081df
80101a68:	e8 13 e9 ff ff       	call   80100380 <panic>
80101a6d:	8d 76 00             	lea    0x0(%esi),%esi

80101a70 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
80101a70:	55                   	push   %ebp
80101a71:	89 e5                	mov    %esp,%ebp
80101a73:	8b 55 08             	mov    0x8(%ebp),%edx
80101a76:	8b 45 0c             	mov    0xc(%ebp),%eax
  st->dev = ip->dev;
80101a79:	8b 0a                	mov    (%edx),%ecx
80101a7b:	89 48 04             	mov    %ecx,0x4(%eax)
  st->ino = ip->inum;
80101a7e:	8b 4a 04             	mov    0x4(%edx),%ecx
80101a81:	89 48 08             	mov    %ecx,0x8(%eax)
  st->type = ip->type;
80101a84:	0f b7 4a 50          	movzwl 0x50(%edx),%ecx
80101a88:	66 89 08             	mov    %cx,(%eax)
  st->nlink = ip->nlink;
80101a8b:	0f b7 4a 56          	movzwl 0x56(%edx),%ecx
80101a8f:	66 89 48 0c          	mov    %cx,0xc(%eax)
  st->size = ip->size;
80101a93:	8b 52 58             	mov    0x58(%edx),%edx
80101a96:	89 50 10             	mov    %edx,0x10(%eax)
}
80101a99:	5d                   	pop    %ebp
80101a9a:	c3                   	ret    
80101a9b:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80101a9f:	90                   	nop

80101aa0 <readi>:
//PAGEBREAK!
// Read data from inode.
// Caller must hold ip->lock.
int
readi(struct inode *ip, char *dst, uint off, uint n)
{
80101aa0:	55                   	push   %ebp
80101aa1:	89 e5                	mov    %esp,%ebp
80101aa3:	57                   	push   %edi
80101aa4:	56                   	push   %esi
80101aa5:	53                   	push   %ebx
80101aa6:	83 ec 1c             	sub    $0x1c,%esp
80101aa9:	8b 7d 0c             	mov    0xc(%ebp),%edi
80101aac:	8b 45 08             	mov    0x8(%ebp),%eax
80101aaf:	8b 75 10             	mov    0x10(%ebp),%esi
80101ab2:	89 7d e0             	mov    %edi,-0x20(%ebp)
80101ab5:	8b 7d 14             	mov    0x14(%ebp),%edi
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
80101ab8:	66 83 78 50 03       	cmpw   $0x3,0x50(%eax)
{
80101abd:	89 45 d8             	mov    %eax,-0x28(%ebp)
80101ac0:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  if(ip->type == T_DEV){
80101ac3:	0f 84 a7 00 00 00    	je     80101b70 <readi+0xd0>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].read)
      return -1;
    return devsw[ip->major].read(ip, dst, n);
  }

  if(off > ip->size || off + n < off)
80101ac9:	8b 45 d8             	mov    -0x28(%ebp),%eax
80101acc:	8b 40 58             	mov    0x58(%eax),%eax
80101acf:	39 c6                	cmp    %eax,%esi
80101ad1:	0f 87 ba 00 00 00    	ja     80101b91 <readi+0xf1>
80101ad7:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
80101ada:	31 c9                	xor    %ecx,%ecx
80101adc:	89 da                	mov    %ebx,%edx
80101ade:	01 f2                	add    %esi,%edx
80101ae0:	0f 92 c1             	setb   %cl
80101ae3:	89 cf                	mov    %ecx,%edi
80101ae5:	0f 82 a6 00 00 00    	jb     80101b91 <readi+0xf1>
    return -1;
  if(off + n > ip->size)
    n = ip->size - off;
80101aeb:	89 c1                	mov    %eax,%ecx
80101aed:	29 f1                	sub    %esi,%ecx
80101aef:	39 d0                	cmp    %edx,%eax
80101af1:	0f 43 cb             	cmovae %ebx,%ecx
80101af4:	89 4d e4             	mov    %ecx,-0x1c(%ebp)

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
80101af7:	85 c9                	test   %ecx,%ecx
80101af9:	74 67                	je     80101b62 <readi+0xc2>
80101afb:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80101aff:	90                   	nop
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
80101b00:	8b 5d d8             	mov    -0x28(%ebp),%ebx
80101b03:	89 f2                	mov    %esi,%edx
80101b05:	c1 ea 09             	shr    $0x9,%edx
80101b08:	89 d8                	mov    %ebx,%eax
80101b0a:	e8 51 f9 ff ff       	call   80101460 <bmap>
80101b0f:	83 ec 08             	sub    $0x8,%esp
80101b12:	50                   	push   %eax
80101b13:	ff 33                	push   (%ebx)
80101b15:	e8 b6 e5 ff ff       	call   801000d0 <bread>
    m = min(n - tot, BSIZE - off%BSIZE);
80101b1a:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
80101b1d:	b9 00 02 00 00       	mov    $0x200,%ecx
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
80101b22:	89 c2                	mov    %eax,%edx
    m = min(n - tot, BSIZE - off%BSIZE);
80101b24:	89 f0                	mov    %esi,%eax
80101b26:	25 ff 01 00 00       	and    $0x1ff,%eax
80101b2b:	29 fb                	sub    %edi,%ebx
    memmove(dst, bp->data + off%BSIZE, m);
80101b2d:	89 55 dc             	mov    %edx,-0x24(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
80101b30:	29 c1                	sub    %eax,%ecx
    memmove(dst, bp->data + off%BSIZE, m);
80101b32:	8d 44 02 5c          	lea    0x5c(%edx,%eax,1),%eax
    m = min(n - tot, BSIZE - off%BSIZE);
80101b36:	39 d9                	cmp    %ebx,%ecx
80101b38:	0f 46 d9             	cmovbe %ecx,%ebx
    memmove(dst, bp->data + off%BSIZE, m);
80101b3b:	83 c4 0c             	add    $0xc,%esp
80101b3e:	53                   	push   %ebx
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
80101b3f:	01 df                	add    %ebx,%edi
80101b41:	01 de                	add    %ebx,%esi
    memmove(dst, bp->data + off%BSIZE, m);
80101b43:	50                   	push   %eax
80101b44:	ff 75 e0             	push   -0x20(%ebp)
80101b47:	e8 b4 31 00 00       	call   80104d00 <memmove>
    brelse(bp);
80101b4c:	8b 55 dc             	mov    -0x24(%ebp),%edx
80101b4f:	89 14 24             	mov    %edx,(%esp)
80101b52:	e8 99 e6 ff ff       	call   801001f0 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
80101b57:	01 5d e0             	add    %ebx,-0x20(%ebp)
80101b5a:	83 c4 10             	add    $0x10,%esp
80101b5d:	39 7d e4             	cmp    %edi,-0x1c(%ebp)
80101b60:	77 9e                	ja     80101b00 <readi+0x60>
  }
  return n;
80101b62:	8b 45 e4             	mov    -0x1c(%ebp),%eax
}
80101b65:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101b68:	5b                   	pop    %ebx
80101b69:	5e                   	pop    %esi
80101b6a:	5f                   	pop    %edi
80101b6b:	5d                   	pop    %ebp
80101b6c:	c3                   	ret    
80101b6d:	8d 76 00             	lea    0x0(%esi),%esi
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].read)
80101b70:	0f bf 40 52          	movswl 0x52(%eax),%eax
80101b74:	66 83 f8 09          	cmp    $0x9,%ax
80101b78:	77 17                	ja     80101b91 <readi+0xf1>
80101b7a:	8b 04 c5 00 09 11 80 	mov    -0x7feef700(,%eax,8),%eax
80101b81:	85 c0                	test   %eax,%eax
80101b83:	74 0c                	je     80101b91 <readi+0xf1>
    return devsw[ip->major].read(ip, dst, n);
80101b85:	89 7d 10             	mov    %edi,0x10(%ebp)
}
80101b88:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101b8b:	5b                   	pop    %ebx
80101b8c:	5e                   	pop    %esi
80101b8d:	5f                   	pop    %edi
80101b8e:	5d                   	pop    %ebp
    return devsw[ip->major].read(ip, dst, n);
80101b8f:	ff e0                	jmp    *%eax
      return -1;
80101b91:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101b96:	eb cd                	jmp    80101b65 <readi+0xc5>
80101b98:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80101b9f:	90                   	nop

80101ba0 <writei>:
// PAGEBREAK!
// Write data to inode.
// Caller must hold ip->lock.
int
writei(struct inode *ip, char *src, uint off, uint n)
{
80101ba0:	55                   	push   %ebp
80101ba1:	89 e5                	mov    %esp,%ebp
80101ba3:	57                   	push   %edi
80101ba4:	56                   	push   %esi
80101ba5:	53                   	push   %ebx
80101ba6:	83 ec 1c             	sub    $0x1c,%esp
80101ba9:	8b 45 08             	mov    0x8(%ebp),%eax
80101bac:	8b 75 0c             	mov    0xc(%ebp),%esi
80101baf:	8b 55 14             	mov    0x14(%ebp),%edx
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
80101bb2:	66 83 78 50 03       	cmpw   $0x3,0x50(%eax)
{
80101bb7:	89 75 dc             	mov    %esi,-0x24(%ebp)
80101bba:	89 45 d8             	mov    %eax,-0x28(%ebp)
80101bbd:	8b 75 10             	mov    0x10(%ebp),%esi
80101bc0:	89 55 e0             	mov    %edx,-0x20(%ebp)
  if(ip->type == T_DEV){
80101bc3:	0f 84 b7 00 00 00    	je     80101c80 <writei+0xe0>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].write)
      return -1;
    return devsw[ip->major].write(ip, src, n);
  }

  if(off > ip->size || off + n < off)
80101bc9:	8b 45 d8             	mov    -0x28(%ebp),%eax
80101bcc:	3b 70 58             	cmp    0x58(%eax),%esi
80101bcf:	0f 87 e7 00 00 00    	ja     80101cbc <writei+0x11c>
80101bd5:	8b 7d e0             	mov    -0x20(%ebp),%edi
80101bd8:	31 d2                	xor    %edx,%edx
80101bda:	89 f8                	mov    %edi,%eax
80101bdc:	01 f0                	add    %esi,%eax
80101bde:	0f 92 c2             	setb   %dl
    return -1;
  if(off + n > MAXFILE*BSIZE)
80101be1:	3d 00 18 01 00       	cmp    $0x11800,%eax
80101be6:	0f 87 d0 00 00 00    	ja     80101cbc <writei+0x11c>
80101bec:	85 d2                	test   %edx,%edx
80101bee:	0f 85 c8 00 00 00    	jne    80101cbc <writei+0x11c>
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
80101bf4:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80101bfb:	85 ff                	test   %edi,%edi
80101bfd:	74 72                	je     80101c71 <writei+0xd1>
80101bff:	90                   	nop
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
80101c00:	8b 7d d8             	mov    -0x28(%ebp),%edi
80101c03:	89 f2                	mov    %esi,%edx
80101c05:	c1 ea 09             	shr    $0x9,%edx
80101c08:	89 f8                	mov    %edi,%eax
80101c0a:	e8 51 f8 ff ff       	call   80101460 <bmap>
80101c0f:	83 ec 08             	sub    $0x8,%esp
80101c12:	50                   	push   %eax
80101c13:	ff 37                	push   (%edi)
80101c15:	e8 b6 e4 ff ff       	call   801000d0 <bread>
    m = min(n - tot, BSIZE - off%BSIZE);
80101c1a:	b9 00 02 00 00       	mov    $0x200,%ecx
80101c1f:	8b 5d e0             	mov    -0x20(%ebp),%ebx
80101c22:	2b 5d e4             	sub    -0x1c(%ebp),%ebx
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
80101c25:	89 c7                	mov    %eax,%edi
    m = min(n - tot, BSIZE - off%BSIZE);
80101c27:	89 f0                	mov    %esi,%eax
80101c29:	25 ff 01 00 00       	and    $0x1ff,%eax
80101c2e:	29 c1                	sub    %eax,%ecx
    memmove(bp->data + off%BSIZE, src, m);
80101c30:	8d 44 07 5c          	lea    0x5c(%edi,%eax,1),%eax
    m = min(n - tot, BSIZE - off%BSIZE);
80101c34:	39 d9                	cmp    %ebx,%ecx
80101c36:	0f 46 d9             	cmovbe %ecx,%ebx
    memmove(bp->data + off%BSIZE, src, m);
80101c39:	83 c4 0c             	add    $0xc,%esp
80101c3c:	53                   	push   %ebx
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
80101c3d:	01 de                	add    %ebx,%esi
    memmove(bp->data + off%BSIZE, src, m);
80101c3f:	ff 75 dc             	push   -0x24(%ebp)
80101c42:	50                   	push   %eax
80101c43:	e8 b8 30 00 00       	call   80104d00 <memmove>
    log_write(bp);
80101c48:	89 3c 24             	mov    %edi,(%esp)
80101c4b:	e8 60 13 00 00       	call   80102fb0 <log_write>
    brelse(bp);
80101c50:	89 3c 24             	mov    %edi,(%esp)
80101c53:	e8 98 e5 ff ff       	call   801001f0 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
80101c58:	01 5d e4             	add    %ebx,-0x1c(%ebp)
80101c5b:	83 c4 10             	add    $0x10,%esp
80101c5e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80101c61:	01 5d dc             	add    %ebx,-0x24(%ebp)
80101c64:	39 45 e0             	cmp    %eax,-0x20(%ebp)
80101c67:	77 97                	ja     80101c00 <writei+0x60>
  }

  if(n > 0 && off > ip->size){
80101c69:	8b 45 d8             	mov    -0x28(%ebp),%eax
80101c6c:	3b 70 58             	cmp    0x58(%eax),%esi
80101c6f:	77 37                	ja     80101ca8 <writei+0x108>
    ip->size = off;
    iupdate(ip);
  }
  return n;
80101c71:	8b 45 e0             	mov    -0x20(%ebp),%eax
}
80101c74:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101c77:	5b                   	pop    %ebx
80101c78:	5e                   	pop    %esi
80101c79:	5f                   	pop    %edi
80101c7a:	5d                   	pop    %ebp
80101c7b:	c3                   	ret    
80101c7c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].write)
80101c80:	0f bf 40 52          	movswl 0x52(%eax),%eax
80101c84:	66 83 f8 09          	cmp    $0x9,%ax
80101c88:	77 32                	ja     80101cbc <writei+0x11c>
80101c8a:	8b 04 c5 04 09 11 80 	mov    -0x7feef6fc(,%eax,8),%eax
80101c91:	85 c0                	test   %eax,%eax
80101c93:	74 27                	je     80101cbc <writei+0x11c>
    return devsw[ip->major].write(ip, src, n);
80101c95:	89 55 10             	mov    %edx,0x10(%ebp)
}
80101c98:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101c9b:	5b                   	pop    %ebx
80101c9c:	5e                   	pop    %esi
80101c9d:	5f                   	pop    %edi
80101c9e:	5d                   	pop    %ebp
    return devsw[ip->major].write(ip, src, n);
80101c9f:	ff e0                	jmp    *%eax
80101ca1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    ip->size = off;
80101ca8:	8b 45 d8             	mov    -0x28(%ebp),%eax
    iupdate(ip);
80101cab:	83 ec 0c             	sub    $0xc,%esp
    ip->size = off;
80101cae:	89 70 58             	mov    %esi,0x58(%eax)
    iupdate(ip);
80101cb1:	50                   	push   %eax
80101cb2:	e8 29 fa ff ff       	call   801016e0 <iupdate>
80101cb7:	83 c4 10             	add    $0x10,%esp
80101cba:	eb b5                	jmp    80101c71 <writei+0xd1>
      return -1;
80101cbc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101cc1:	eb b1                	jmp    80101c74 <writei+0xd4>
80101cc3:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80101cca:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

80101cd0 <namecmp>:
//PAGEBREAK!
// Directories

int
namecmp(const char *s, const char *t)
{
80101cd0:	55                   	push   %ebp
80101cd1:	89 e5                	mov    %esp,%ebp
80101cd3:	83 ec 0c             	sub    $0xc,%esp
  return strncmp(s, t, DIRSIZ);
80101cd6:	6a 0e                	push   $0xe
80101cd8:	ff 75 0c             	push   0xc(%ebp)
80101cdb:	ff 75 08             	push   0x8(%ebp)
80101cde:	e8 8d 30 00 00       	call   80104d70 <strncmp>
}
80101ce3:	c9                   	leave  
80101ce4:	c3                   	ret    
80101ce5:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80101cec:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

80101cf0 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
80101cf0:	55                   	push   %ebp
80101cf1:	89 e5                	mov    %esp,%ebp
80101cf3:	57                   	push   %edi
80101cf4:	56                   	push   %esi
80101cf5:	53                   	push   %ebx
80101cf6:	83 ec 1c             	sub    $0x1c,%esp
80101cf9:	8b 5d 08             	mov    0x8(%ebp),%ebx
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
80101cfc:	66 83 7b 50 01       	cmpw   $0x1,0x50(%ebx)
80101d01:	0f 85 85 00 00 00    	jne    80101d8c <dirlookup+0x9c>
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
80101d07:	8b 53 58             	mov    0x58(%ebx),%edx
80101d0a:	31 ff                	xor    %edi,%edi
80101d0c:	8d 75 d8             	lea    -0x28(%ebp),%esi
80101d0f:	85 d2                	test   %edx,%edx
80101d11:	74 3e                	je     80101d51 <dirlookup+0x61>
80101d13:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80101d17:	90                   	nop
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80101d18:	6a 10                	push   $0x10
80101d1a:	57                   	push   %edi
80101d1b:	56                   	push   %esi
80101d1c:	53                   	push   %ebx
80101d1d:	e8 7e fd ff ff       	call   80101aa0 <readi>
80101d22:	83 c4 10             	add    $0x10,%esp
80101d25:	83 f8 10             	cmp    $0x10,%eax
80101d28:	75 55                	jne    80101d7f <dirlookup+0x8f>
      panic("dirlookup read");
    if(de.inum == 0)
80101d2a:	66 83 7d d8 00       	cmpw   $0x0,-0x28(%ebp)
80101d2f:	74 18                	je     80101d49 <dirlookup+0x59>
  return strncmp(s, t, DIRSIZ);
80101d31:	83 ec 04             	sub    $0x4,%esp
80101d34:	8d 45 da             	lea    -0x26(%ebp),%eax
80101d37:	6a 0e                	push   $0xe
80101d39:	50                   	push   %eax
80101d3a:	ff 75 0c             	push   0xc(%ebp)
80101d3d:	e8 2e 30 00 00       	call   80104d70 <strncmp>
      continue;
    if(namecmp(name, de.name) == 0){
80101d42:	83 c4 10             	add    $0x10,%esp
80101d45:	85 c0                	test   %eax,%eax
80101d47:	74 17                	je     80101d60 <dirlookup+0x70>
  for(off = 0; off < dp->size; off += sizeof(de)){
80101d49:	83 c7 10             	add    $0x10,%edi
80101d4c:	3b 7b 58             	cmp    0x58(%ebx),%edi
80101d4f:	72 c7                	jb     80101d18 <dirlookup+0x28>
      return iget(dp->dev, inum);
    }
  }

  return 0;
}
80101d51:	8d 65 f4             	lea    -0xc(%ebp),%esp
  return 0;
80101d54:	31 c0                	xor    %eax,%eax
}
80101d56:	5b                   	pop    %ebx
80101d57:	5e                   	pop    %esi
80101d58:	5f                   	pop    %edi
80101d59:	5d                   	pop    %ebp
80101d5a:	c3                   	ret    
80101d5b:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80101d5f:	90                   	nop
      if(poff)
80101d60:	8b 45 10             	mov    0x10(%ebp),%eax
80101d63:	85 c0                	test   %eax,%eax
80101d65:	74 05                	je     80101d6c <dirlookup+0x7c>
        *poff = off;
80101d67:	8b 45 10             	mov    0x10(%ebp),%eax
80101d6a:	89 38                	mov    %edi,(%eax)
      inum = de.inum;
80101d6c:	0f b7 55 d8          	movzwl -0x28(%ebp),%edx
      return iget(dp->dev, inum);
80101d70:	8b 03                	mov    (%ebx),%eax
80101d72:	e8 e9 f5 ff ff       	call   80101360 <iget>
}
80101d77:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101d7a:	5b                   	pop    %ebx
80101d7b:	5e                   	pop    %esi
80101d7c:	5f                   	pop    %edi
80101d7d:	5d                   	pop    %ebp
80101d7e:	c3                   	ret    
      panic("dirlookup read");
80101d7f:	83 ec 0c             	sub    $0xc,%esp
80101d82:	68 f9 81 10 80       	push   $0x801081f9
80101d87:	e8 f4 e5 ff ff       	call   80100380 <panic>
    panic("dirlookup not DIR");
80101d8c:	83 ec 0c             	sub    $0xc,%esp
80101d8f:	68 e7 81 10 80       	push   $0x801081e7
80101d94:	e8 e7 e5 ff ff       	call   80100380 <panic>
80101d99:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

80101da0 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
80101da0:	55                   	push   %ebp
80101da1:	89 e5                	mov    %esp,%ebp
80101da3:	57                   	push   %edi
80101da4:	56                   	push   %esi
80101da5:	53                   	push   %ebx
80101da6:	89 c3                	mov    %eax,%ebx
80101da8:	83 ec 1c             	sub    $0x1c,%esp
  struct inode *ip, *next;

  if(*path == '/')
80101dab:	80 38 2f             	cmpb   $0x2f,(%eax)
{
80101dae:	89 55 dc             	mov    %edx,-0x24(%ebp)
80101db1:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
  if(*path == '/')
80101db4:	0f 84 64 01 00 00    	je     80101f1e <namex+0x17e>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
80101dba:	e8 31 1c 00 00       	call   801039f0 <myproc>
  acquire(&icache.lock);
80101dbf:	83 ec 0c             	sub    $0xc,%esp
    ip = idup(myproc()->cwd);
80101dc2:	8b 70 68             	mov    0x68(%eax),%esi
  acquire(&icache.lock);
80101dc5:	68 60 09 11 80       	push   $0x80110960
80101dca:	e8 d1 2d 00 00       	call   80104ba0 <acquire>
  ip->ref++;
80101dcf:	83 46 08 01          	addl   $0x1,0x8(%esi)
  release(&icache.lock);
80101dd3:	c7 04 24 60 09 11 80 	movl   $0x80110960,(%esp)
80101dda:	e8 61 2d 00 00       	call   80104b40 <release>
80101ddf:	83 c4 10             	add    $0x10,%esp
80101de2:	eb 07                	jmp    80101deb <namex+0x4b>
80101de4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    path++;
80101de8:	83 c3 01             	add    $0x1,%ebx
  while(*path == '/')
80101deb:	0f b6 03             	movzbl (%ebx),%eax
80101dee:	3c 2f                	cmp    $0x2f,%al
80101df0:	74 f6                	je     80101de8 <namex+0x48>
  if(*path == 0)
80101df2:	84 c0                	test   %al,%al
80101df4:	0f 84 06 01 00 00    	je     80101f00 <namex+0x160>
  while(*path != '/' && *path != 0)
80101dfa:	0f b6 03             	movzbl (%ebx),%eax
80101dfd:	84 c0                	test   %al,%al
80101dff:	0f 84 10 01 00 00    	je     80101f15 <namex+0x175>
80101e05:	89 df                	mov    %ebx,%edi
80101e07:	3c 2f                	cmp    $0x2f,%al
80101e09:	0f 84 06 01 00 00    	je     80101f15 <namex+0x175>
80101e0f:	90                   	nop
80101e10:	0f b6 47 01          	movzbl 0x1(%edi),%eax
    path++;
80101e14:	83 c7 01             	add    $0x1,%edi
  while(*path != '/' && *path != 0)
80101e17:	3c 2f                	cmp    $0x2f,%al
80101e19:	74 04                	je     80101e1f <namex+0x7f>
80101e1b:	84 c0                	test   %al,%al
80101e1d:	75 f1                	jne    80101e10 <namex+0x70>
  len = path - s;
80101e1f:	89 f8                	mov    %edi,%eax
80101e21:	29 d8                	sub    %ebx,%eax
  if(len >= DIRSIZ)
80101e23:	83 f8 0d             	cmp    $0xd,%eax
80101e26:	0f 8e ac 00 00 00    	jle    80101ed8 <namex+0x138>
    memmove(name, s, DIRSIZ);
80101e2c:	83 ec 04             	sub    $0x4,%esp
80101e2f:	6a 0e                	push   $0xe
80101e31:	53                   	push   %ebx
    path++;
80101e32:	89 fb                	mov    %edi,%ebx
    memmove(name, s, DIRSIZ);
80101e34:	ff 75 e4             	push   -0x1c(%ebp)
80101e37:	e8 c4 2e 00 00       	call   80104d00 <memmove>
80101e3c:	83 c4 10             	add    $0x10,%esp
  while(*path == '/')
80101e3f:	80 3f 2f             	cmpb   $0x2f,(%edi)
80101e42:	75 0c                	jne    80101e50 <namex+0xb0>
80101e44:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    path++;
80101e48:	83 c3 01             	add    $0x1,%ebx
  while(*path == '/')
80101e4b:	80 3b 2f             	cmpb   $0x2f,(%ebx)
80101e4e:	74 f8                	je     80101e48 <namex+0xa8>

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
80101e50:	83 ec 0c             	sub    $0xc,%esp
80101e53:	56                   	push   %esi
80101e54:	e8 37 f9 ff ff       	call   80101790 <ilock>
    if(ip->type != T_DIR){
80101e59:	83 c4 10             	add    $0x10,%esp
80101e5c:	66 83 7e 50 01       	cmpw   $0x1,0x50(%esi)
80101e61:	0f 85 cd 00 00 00    	jne    80101f34 <namex+0x194>
      iunlockput(ip);
      return 0;
    }
    if(nameiparent && *path == '\0'){
80101e67:	8b 45 dc             	mov    -0x24(%ebp),%eax
80101e6a:	85 c0                	test   %eax,%eax
80101e6c:	74 09                	je     80101e77 <namex+0xd7>
80101e6e:	80 3b 00             	cmpb   $0x0,(%ebx)
80101e71:	0f 84 22 01 00 00    	je     80101f99 <namex+0x1f9>
      // Stop one level early.
      iunlock(ip);
      return ip;
    }
    if((next = dirlookup(ip, name, 0)) == 0){
80101e77:	83 ec 04             	sub    $0x4,%esp
80101e7a:	6a 00                	push   $0x0
80101e7c:	ff 75 e4             	push   -0x1c(%ebp)
80101e7f:	56                   	push   %esi
80101e80:	e8 6b fe ff ff       	call   80101cf0 <dirlookup>
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
80101e85:	8d 56 0c             	lea    0xc(%esi),%edx
    if((next = dirlookup(ip, name, 0)) == 0){
80101e88:	83 c4 10             	add    $0x10,%esp
80101e8b:	89 c7                	mov    %eax,%edi
80101e8d:	85 c0                	test   %eax,%eax
80101e8f:	0f 84 e1 00 00 00    	je     80101f76 <namex+0x1d6>
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
80101e95:	83 ec 0c             	sub    $0xc,%esp
80101e98:	89 55 e0             	mov    %edx,-0x20(%ebp)
80101e9b:	52                   	push   %edx
80101e9c:	e8 df 2a 00 00       	call   80104980 <holdingsleep>
80101ea1:	83 c4 10             	add    $0x10,%esp
80101ea4:	85 c0                	test   %eax,%eax
80101ea6:	0f 84 30 01 00 00    	je     80101fdc <namex+0x23c>
80101eac:	8b 56 08             	mov    0x8(%esi),%edx
80101eaf:	85 d2                	test   %edx,%edx
80101eb1:	0f 8e 25 01 00 00    	jle    80101fdc <namex+0x23c>
  releasesleep(&ip->lock);
80101eb7:	8b 55 e0             	mov    -0x20(%ebp),%edx
80101eba:	83 ec 0c             	sub    $0xc,%esp
80101ebd:	52                   	push   %edx
80101ebe:	e8 7d 2a 00 00       	call   80104940 <releasesleep>
  iput(ip);
80101ec3:	89 34 24             	mov    %esi,(%esp)
80101ec6:	89 fe                	mov    %edi,%esi
80101ec8:	e8 f3 f9 ff ff       	call   801018c0 <iput>
80101ecd:	83 c4 10             	add    $0x10,%esp
80101ed0:	e9 16 ff ff ff       	jmp    80101deb <namex+0x4b>
80101ed5:	8d 76 00             	lea    0x0(%esi),%esi
    name[len] = 0;
80101ed8:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
80101edb:	8d 14 01             	lea    (%ecx,%eax,1),%edx
    memmove(name, s, len);
80101ede:	83 ec 04             	sub    $0x4,%esp
80101ee1:	89 55 e0             	mov    %edx,-0x20(%ebp)
80101ee4:	50                   	push   %eax
80101ee5:	53                   	push   %ebx
    name[len] = 0;
80101ee6:	89 fb                	mov    %edi,%ebx
    memmove(name, s, len);
80101ee8:	ff 75 e4             	push   -0x1c(%ebp)
80101eeb:	e8 10 2e 00 00       	call   80104d00 <memmove>
    name[len] = 0;
80101ef0:	8b 55 e0             	mov    -0x20(%ebp),%edx
80101ef3:	83 c4 10             	add    $0x10,%esp
80101ef6:	c6 02 00             	movb   $0x0,(%edx)
80101ef9:	e9 41 ff ff ff       	jmp    80101e3f <namex+0x9f>
80101efe:	66 90                	xchg   %ax,%ax
      return 0;
    }
    iunlockput(ip);
    ip = next;
  }
  if(nameiparent){
80101f00:	8b 45 dc             	mov    -0x24(%ebp),%eax
80101f03:	85 c0                	test   %eax,%eax
80101f05:	0f 85 be 00 00 00    	jne    80101fc9 <namex+0x229>
    iput(ip);
    return 0;
  }
  return ip;
}
80101f0b:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101f0e:	89 f0                	mov    %esi,%eax
80101f10:	5b                   	pop    %ebx
80101f11:	5e                   	pop    %esi
80101f12:	5f                   	pop    %edi
80101f13:	5d                   	pop    %ebp
80101f14:	c3                   	ret    
  while(*path != '/' && *path != 0)
80101f15:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80101f18:	89 df                	mov    %ebx,%edi
80101f1a:	31 c0                	xor    %eax,%eax
80101f1c:	eb c0                	jmp    80101ede <namex+0x13e>
    ip = iget(ROOTDEV, ROOTINO);
80101f1e:	ba 01 00 00 00       	mov    $0x1,%edx
80101f23:	b8 01 00 00 00       	mov    $0x1,%eax
80101f28:	e8 33 f4 ff ff       	call   80101360 <iget>
80101f2d:	89 c6                	mov    %eax,%esi
80101f2f:	e9 b7 fe ff ff       	jmp    80101deb <namex+0x4b>
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
80101f34:	83 ec 0c             	sub    $0xc,%esp
80101f37:	8d 5e 0c             	lea    0xc(%esi),%ebx
80101f3a:	53                   	push   %ebx
80101f3b:	e8 40 2a 00 00       	call   80104980 <holdingsleep>
80101f40:	83 c4 10             	add    $0x10,%esp
80101f43:	85 c0                	test   %eax,%eax
80101f45:	0f 84 91 00 00 00    	je     80101fdc <namex+0x23c>
80101f4b:	8b 46 08             	mov    0x8(%esi),%eax
80101f4e:	85 c0                	test   %eax,%eax
80101f50:	0f 8e 86 00 00 00    	jle    80101fdc <namex+0x23c>
  releasesleep(&ip->lock);
80101f56:	83 ec 0c             	sub    $0xc,%esp
80101f59:	53                   	push   %ebx
80101f5a:	e8 e1 29 00 00       	call   80104940 <releasesleep>
  iput(ip);
80101f5f:	89 34 24             	mov    %esi,(%esp)
      return 0;
80101f62:	31 f6                	xor    %esi,%esi
  iput(ip);
80101f64:	e8 57 f9 ff ff       	call   801018c0 <iput>
      return 0;
80101f69:	83 c4 10             	add    $0x10,%esp
}
80101f6c:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101f6f:	89 f0                	mov    %esi,%eax
80101f71:	5b                   	pop    %ebx
80101f72:	5e                   	pop    %esi
80101f73:	5f                   	pop    %edi
80101f74:	5d                   	pop    %ebp
80101f75:	c3                   	ret    
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
80101f76:	83 ec 0c             	sub    $0xc,%esp
80101f79:	89 55 e4             	mov    %edx,-0x1c(%ebp)
80101f7c:	52                   	push   %edx
80101f7d:	e8 fe 29 00 00       	call   80104980 <holdingsleep>
80101f82:	83 c4 10             	add    $0x10,%esp
80101f85:	85 c0                	test   %eax,%eax
80101f87:	74 53                	je     80101fdc <namex+0x23c>
80101f89:	8b 4e 08             	mov    0x8(%esi),%ecx
80101f8c:	85 c9                	test   %ecx,%ecx
80101f8e:	7e 4c                	jle    80101fdc <namex+0x23c>
  releasesleep(&ip->lock);
80101f90:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80101f93:	83 ec 0c             	sub    $0xc,%esp
80101f96:	52                   	push   %edx
80101f97:	eb c1                	jmp    80101f5a <namex+0x1ba>
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
80101f99:	83 ec 0c             	sub    $0xc,%esp
80101f9c:	8d 5e 0c             	lea    0xc(%esi),%ebx
80101f9f:	53                   	push   %ebx
80101fa0:	e8 db 29 00 00       	call   80104980 <holdingsleep>
80101fa5:	83 c4 10             	add    $0x10,%esp
80101fa8:	85 c0                	test   %eax,%eax
80101faa:	74 30                	je     80101fdc <namex+0x23c>
80101fac:	8b 7e 08             	mov    0x8(%esi),%edi
80101faf:	85 ff                	test   %edi,%edi
80101fb1:	7e 29                	jle    80101fdc <namex+0x23c>
  releasesleep(&ip->lock);
80101fb3:	83 ec 0c             	sub    $0xc,%esp
80101fb6:	53                   	push   %ebx
80101fb7:	e8 84 29 00 00       	call   80104940 <releasesleep>
}
80101fbc:	83 c4 10             	add    $0x10,%esp
}
80101fbf:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101fc2:	89 f0                	mov    %esi,%eax
80101fc4:	5b                   	pop    %ebx
80101fc5:	5e                   	pop    %esi
80101fc6:	5f                   	pop    %edi
80101fc7:	5d                   	pop    %ebp
80101fc8:	c3                   	ret    
    iput(ip);
80101fc9:	83 ec 0c             	sub    $0xc,%esp
80101fcc:	56                   	push   %esi
    return 0;
80101fcd:	31 f6                	xor    %esi,%esi
    iput(ip);
80101fcf:	e8 ec f8 ff ff       	call   801018c0 <iput>
    return 0;
80101fd4:	83 c4 10             	add    $0x10,%esp
80101fd7:	e9 2f ff ff ff       	jmp    80101f0b <namex+0x16b>
    panic("iunlock");
80101fdc:	83 ec 0c             	sub    $0xc,%esp
80101fdf:	68 df 81 10 80       	push   $0x801081df
80101fe4:	e8 97 e3 ff ff       	call   80100380 <panic>
80101fe9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

80101ff0 <dirlink>:
{
80101ff0:	55                   	push   %ebp
80101ff1:	89 e5                	mov    %esp,%ebp
80101ff3:	57                   	push   %edi
80101ff4:	56                   	push   %esi
80101ff5:	53                   	push   %ebx
80101ff6:	83 ec 20             	sub    $0x20,%esp
80101ff9:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if((ip = dirlookup(dp, name, 0)) != 0){
80101ffc:	6a 00                	push   $0x0
80101ffe:	ff 75 0c             	push   0xc(%ebp)
80102001:	53                   	push   %ebx
80102002:	e8 e9 fc ff ff       	call   80101cf0 <dirlookup>
80102007:	83 c4 10             	add    $0x10,%esp
8010200a:	85 c0                	test   %eax,%eax
8010200c:	75 67                	jne    80102075 <dirlink+0x85>
  for(off = 0; off < dp->size; off += sizeof(de)){
8010200e:	8b 7b 58             	mov    0x58(%ebx),%edi
80102011:	8d 75 d8             	lea    -0x28(%ebp),%esi
80102014:	85 ff                	test   %edi,%edi
80102016:	74 29                	je     80102041 <dirlink+0x51>
80102018:	31 ff                	xor    %edi,%edi
8010201a:	8d 75 d8             	lea    -0x28(%ebp),%esi
8010201d:	eb 09                	jmp    80102028 <dirlink+0x38>
8010201f:	90                   	nop
80102020:	83 c7 10             	add    $0x10,%edi
80102023:	3b 7b 58             	cmp    0x58(%ebx),%edi
80102026:	73 19                	jae    80102041 <dirlink+0x51>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80102028:	6a 10                	push   $0x10
8010202a:	57                   	push   %edi
8010202b:	56                   	push   %esi
8010202c:	53                   	push   %ebx
8010202d:	e8 6e fa ff ff       	call   80101aa0 <readi>
80102032:	83 c4 10             	add    $0x10,%esp
80102035:	83 f8 10             	cmp    $0x10,%eax
80102038:	75 4e                	jne    80102088 <dirlink+0x98>
    if(de.inum == 0)
8010203a:	66 83 7d d8 00       	cmpw   $0x0,-0x28(%ebp)
8010203f:	75 df                	jne    80102020 <dirlink+0x30>
  strncpy(de.name, name, DIRSIZ);
80102041:	83 ec 04             	sub    $0x4,%esp
80102044:	8d 45 da             	lea    -0x26(%ebp),%eax
80102047:	6a 0e                	push   $0xe
80102049:	ff 75 0c             	push   0xc(%ebp)
8010204c:	50                   	push   %eax
8010204d:	e8 6e 2d 00 00       	call   80104dc0 <strncpy>
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80102052:	6a 10                	push   $0x10
  de.inum = inum;
80102054:	8b 45 10             	mov    0x10(%ebp),%eax
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80102057:	57                   	push   %edi
80102058:	56                   	push   %esi
80102059:	53                   	push   %ebx
  de.inum = inum;
8010205a:	66 89 45 d8          	mov    %ax,-0x28(%ebp)
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
8010205e:	e8 3d fb ff ff       	call   80101ba0 <writei>
80102063:	83 c4 20             	add    $0x20,%esp
80102066:	83 f8 10             	cmp    $0x10,%eax
80102069:	75 2a                	jne    80102095 <dirlink+0xa5>
  return 0;
8010206b:	31 c0                	xor    %eax,%eax
}
8010206d:	8d 65 f4             	lea    -0xc(%ebp),%esp
80102070:	5b                   	pop    %ebx
80102071:	5e                   	pop    %esi
80102072:	5f                   	pop    %edi
80102073:	5d                   	pop    %ebp
80102074:	c3                   	ret    
    iput(ip);
80102075:	83 ec 0c             	sub    $0xc,%esp
80102078:	50                   	push   %eax
80102079:	e8 42 f8 ff ff       	call   801018c0 <iput>
    return -1;
8010207e:	83 c4 10             	add    $0x10,%esp
80102081:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102086:	eb e5                	jmp    8010206d <dirlink+0x7d>
      panic("dirlink read");
80102088:	83 ec 0c             	sub    $0xc,%esp
8010208b:	68 08 82 10 80       	push   $0x80108208
80102090:	e8 eb e2 ff ff       	call   80100380 <panic>
    panic("dirlink");
80102095:	83 ec 0c             	sub    $0xc,%esp
80102098:	68 8e 88 10 80       	push   $0x8010888e
8010209d:	e8 de e2 ff ff       	call   80100380 <panic>
801020a2:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801020a9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

801020b0 <namei>:

struct inode*
namei(char *path)
{
801020b0:	55                   	push   %ebp
  char name[DIRSIZ];
  return namex(path, 0, name);
801020b1:	31 d2                	xor    %edx,%edx
{
801020b3:	89 e5                	mov    %esp,%ebp
801020b5:	83 ec 18             	sub    $0x18,%esp
  return namex(path, 0, name);
801020b8:	8b 45 08             	mov    0x8(%ebp),%eax
801020bb:	8d 4d ea             	lea    -0x16(%ebp),%ecx
801020be:	e8 dd fc ff ff       	call   80101da0 <namex>
}
801020c3:	c9                   	leave  
801020c4:	c3                   	ret    
801020c5:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801020cc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

801020d0 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
801020d0:	55                   	push   %ebp
  return namex(path, 1, name);
801020d1:	ba 01 00 00 00       	mov    $0x1,%edx
{
801020d6:	89 e5                	mov    %esp,%ebp
  return namex(path, 1, name);
801020d8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
801020db:	8b 45 08             	mov    0x8(%ebp),%eax
}
801020de:	5d                   	pop    %ebp
  return namex(path, 1, name);
801020df:	e9 bc fc ff ff       	jmp    80101da0 <namex>
801020e4:	66 90                	xchg   %ax,%ax
801020e6:	66 90                	xchg   %ax,%ax
801020e8:	66 90                	xchg   %ax,%ax
801020ea:	66 90                	xchg   %ax,%ax
801020ec:	66 90                	xchg   %ax,%ax
801020ee:	66 90                	xchg   %ax,%ax

801020f0 <idestart>:
}

// Start the request for b.  Caller must hold idelock.
static void
idestart(struct buf *b)
{
801020f0:	55                   	push   %ebp
801020f1:	89 e5                	mov    %esp,%ebp
801020f3:	57                   	push   %edi
801020f4:	56                   	push   %esi
801020f5:	53                   	push   %ebx
801020f6:	83 ec 0c             	sub    $0xc,%esp
  if(b == 0)
801020f9:	85 c0                	test   %eax,%eax
801020fb:	0f 84 b4 00 00 00    	je     801021b5 <idestart+0xc5>
    panic("idestart");
  if(b->blockno >= FSSIZE)
80102101:	8b 70 08             	mov    0x8(%eax),%esi
80102104:	89 c3                	mov    %eax,%ebx
80102106:	81 fe e7 03 00 00    	cmp    $0x3e7,%esi
8010210c:	0f 87 96 00 00 00    	ja     801021a8 <idestart+0xb8>
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102112:	b9 f7 01 00 00       	mov    $0x1f7,%ecx
80102117:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010211e:	66 90                	xchg   %ax,%ax
80102120:	89 ca                	mov    %ecx,%edx
80102122:	ec                   	in     (%dx),%al
  while(((r = inb(0x1f7)) & (IDE_BSY|IDE_DRDY)) != IDE_DRDY)
80102123:	83 e0 c0             	and    $0xffffffc0,%eax
80102126:	3c 40                	cmp    $0x40,%al
80102128:	75 f6                	jne    80102120 <idestart+0x30>
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
8010212a:	31 ff                	xor    %edi,%edi
8010212c:	ba f6 03 00 00       	mov    $0x3f6,%edx
80102131:	89 f8                	mov    %edi,%eax
80102133:	ee                   	out    %al,(%dx)
80102134:	b8 01 00 00 00       	mov    $0x1,%eax
80102139:	ba f2 01 00 00       	mov    $0x1f2,%edx
8010213e:	ee                   	out    %al,(%dx)
8010213f:	ba f3 01 00 00       	mov    $0x1f3,%edx
80102144:	89 f0                	mov    %esi,%eax
80102146:	ee                   	out    %al,(%dx)

  idewait(0);
  outb(0x3f6, 0);  // generate interrupt
  outb(0x1f2, sector_per_block);  // number of sectors
  outb(0x1f3, sector & 0xff);
  outb(0x1f4, (sector >> 8) & 0xff);
80102147:	89 f0                	mov    %esi,%eax
80102149:	ba f4 01 00 00       	mov    $0x1f4,%edx
8010214e:	c1 f8 08             	sar    $0x8,%eax
80102151:	ee                   	out    %al,(%dx)
80102152:	ba f5 01 00 00       	mov    $0x1f5,%edx
80102157:	89 f8                	mov    %edi,%eax
80102159:	ee                   	out    %al,(%dx)
  outb(0x1f5, (sector >> 16) & 0xff);
  outb(0x1f6, 0xe0 | ((b->dev&1)<<4) | ((sector>>24)&0x0f));
8010215a:	0f b6 43 04          	movzbl 0x4(%ebx),%eax
8010215e:	ba f6 01 00 00       	mov    $0x1f6,%edx
80102163:	c1 e0 04             	shl    $0x4,%eax
80102166:	83 e0 10             	and    $0x10,%eax
80102169:	83 c8 e0             	or     $0xffffffe0,%eax
8010216c:	ee                   	out    %al,(%dx)
  if(b->flags & B_DIRTY){
8010216d:	f6 03 04             	testb  $0x4,(%ebx)
80102170:	75 16                	jne    80102188 <idestart+0x98>
80102172:	b8 20 00 00 00       	mov    $0x20,%eax
80102177:	89 ca                	mov    %ecx,%edx
80102179:	ee                   	out    %al,(%dx)
    outb(0x1f7, write_cmd);
    outsl(0x1f0, b->data, BSIZE/4);
  } else {
    outb(0x1f7, read_cmd);
  }
}
8010217a:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010217d:	5b                   	pop    %ebx
8010217e:	5e                   	pop    %esi
8010217f:	5f                   	pop    %edi
80102180:	5d                   	pop    %ebp
80102181:	c3                   	ret    
80102182:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
80102188:	b8 30 00 00 00       	mov    $0x30,%eax
8010218d:	89 ca                	mov    %ecx,%edx
8010218f:	ee                   	out    %al,(%dx)
  asm volatile("cld; rep outsl" :
80102190:	b9 80 00 00 00       	mov    $0x80,%ecx
    outsl(0x1f0, b->data, BSIZE/4);
80102195:	8d 73 5c             	lea    0x5c(%ebx),%esi
80102198:	ba f0 01 00 00       	mov    $0x1f0,%edx
8010219d:	fc                   	cld    
8010219e:	f3 6f                	rep outsl %ds:(%esi),(%dx)
}
801021a0:	8d 65 f4             	lea    -0xc(%ebp),%esp
801021a3:	5b                   	pop    %ebx
801021a4:	5e                   	pop    %esi
801021a5:	5f                   	pop    %edi
801021a6:	5d                   	pop    %ebp
801021a7:	c3                   	ret    
    panic("incorrect blockno");
801021a8:	83 ec 0c             	sub    $0xc,%esp
801021ab:	68 74 82 10 80       	push   $0x80108274
801021b0:	e8 cb e1 ff ff       	call   80100380 <panic>
    panic("idestart");
801021b5:	83 ec 0c             	sub    $0xc,%esp
801021b8:	68 6b 82 10 80       	push   $0x8010826b
801021bd:	e8 be e1 ff ff       	call   80100380 <panic>
801021c2:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801021c9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

801021d0 <ideinit>:
{
801021d0:	55                   	push   %ebp
801021d1:	89 e5                	mov    %esp,%ebp
801021d3:	83 ec 10             	sub    $0x10,%esp
  initlock(&idelock, "ide");
801021d6:	68 86 82 10 80       	push   $0x80108286
801021db:	68 00 26 11 80       	push   $0x80112600
801021e0:	e8 eb 27 00 00       	call   801049d0 <initlock>
  ioapicenable(IRQ_IDE, ncpu - 1);
801021e5:	58                   	pop    %eax
801021e6:	a1 84 27 21 80       	mov    0x80212784,%eax
801021eb:	5a                   	pop    %edx
801021ec:	83 e8 01             	sub    $0x1,%eax
801021ef:	50                   	push   %eax
801021f0:	6a 0e                	push   $0xe
801021f2:	e8 99 02 00 00       	call   80102490 <ioapicenable>
  while(((r = inb(0x1f7)) & (IDE_BSY|IDE_DRDY)) != IDE_DRDY)
801021f7:	83 c4 10             	add    $0x10,%esp
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801021fa:	ba f7 01 00 00       	mov    $0x1f7,%edx
801021ff:	90                   	nop
80102200:	ec                   	in     (%dx),%al
80102201:	83 e0 c0             	and    $0xffffffc0,%eax
80102204:	3c 40                	cmp    $0x40,%al
80102206:	75 f8                	jne    80102200 <ideinit+0x30>
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102208:	b8 f0 ff ff ff       	mov    $0xfffffff0,%eax
8010220d:	ba f6 01 00 00       	mov    $0x1f6,%edx
80102212:	ee                   	out    %al,(%dx)
80102213:	b9 e8 03 00 00       	mov    $0x3e8,%ecx
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102218:	ba f7 01 00 00       	mov    $0x1f7,%edx
8010221d:	eb 06                	jmp    80102225 <ideinit+0x55>
8010221f:	90                   	nop
  for(i=0; i<1000; i++){
80102220:	83 e9 01             	sub    $0x1,%ecx
80102223:	74 0f                	je     80102234 <ideinit+0x64>
80102225:	ec                   	in     (%dx),%al
    if(inb(0x1f7) != 0){
80102226:	84 c0                	test   %al,%al
80102228:	74 f6                	je     80102220 <ideinit+0x50>
      havedisk1 = 1;
8010222a:	c7 05 e0 25 11 80 01 	movl   $0x1,0x801125e0
80102231:	00 00 00 
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102234:	b8 e0 ff ff ff       	mov    $0xffffffe0,%eax
80102239:	ba f6 01 00 00       	mov    $0x1f6,%edx
8010223e:	ee                   	out    %al,(%dx)
}
8010223f:	c9                   	leave  
80102240:	c3                   	ret    
80102241:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80102248:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010224f:	90                   	nop

80102250 <ideintr>:

// Interrupt handler.
void
ideintr(void)
{
80102250:	55                   	push   %ebp
80102251:	89 e5                	mov    %esp,%ebp
80102253:	57                   	push   %edi
80102254:	56                   	push   %esi
80102255:	53                   	push   %ebx
80102256:	83 ec 18             	sub    $0x18,%esp
  struct buf *b;

  // First queued buffer is the active request.
  acquire(&idelock);
80102259:	68 00 26 11 80       	push   $0x80112600
8010225e:	e8 3d 29 00 00       	call   80104ba0 <acquire>

  if((b = idequeue) == 0){
80102263:	8b 1d e4 25 11 80    	mov    0x801125e4,%ebx
80102269:	83 c4 10             	add    $0x10,%esp
8010226c:	85 db                	test   %ebx,%ebx
8010226e:	74 63                	je     801022d3 <ideintr+0x83>
    release(&idelock);
    return;
  }
  idequeue = b->qnext;
80102270:	8b 43 58             	mov    0x58(%ebx),%eax
80102273:	a3 e4 25 11 80       	mov    %eax,0x801125e4

  // Read data if needed.
  if(!(b->flags & B_DIRTY) && idewait(1) >= 0)
80102278:	8b 33                	mov    (%ebx),%esi
8010227a:	f7 c6 04 00 00 00    	test   $0x4,%esi
80102280:	75 2f                	jne    801022b1 <ideintr+0x61>
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102282:	ba f7 01 00 00       	mov    $0x1f7,%edx
80102287:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010228e:	66 90                	xchg   %ax,%ax
80102290:	ec                   	in     (%dx),%al
  while(((r = inb(0x1f7)) & (IDE_BSY|IDE_DRDY)) != IDE_DRDY)
80102291:	89 c1                	mov    %eax,%ecx
80102293:	83 e1 c0             	and    $0xffffffc0,%ecx
80102296:	80 f9 40             	cmp    $0x40,%cl
80102299:	75 f5                	jne    80102290 <ideintr+0x40>
  if(checkerr && (r & (IDE_DF|IDE_ERR)) != 0)
8010229b:	a8 21                	test   $0x21,%al
8010229d:	75 12                	jne    801022b1 <ideintr+0x61>
    insl(0x1f0, b->data, BSIZE/4);
8010229f:	8d 7b 5c             	lea    0x5c(%ebx),%edi
  asm volatile("cld; rep insl" :
801022a2:	b9 80 00 00 00       	mov    $0x80,%ecx
801022a7:	ba f0 01 00 00       	mov    $0x1f0,%edx
801022ac:	fc                   	cld    
801022ad:	f3 6d                	rep insl (%dx),%es:(%edi)

  // Wake process waiting for this buf.
  b->flags |= B_VALID;
801022af:	8b 33                	mov    (%ebx),%esi
  b->flags &= ~B_DIRTY;
801022b1:	83 e6 fb             	and    $0xfffffffb,%esi
  wakeup(b);
801022b4:	83 ec 0c             	sub    $0xc,%esp
  b->flags &= ~B_DIRTY;
801022b7:	83 ce 02             	or     $0x2,%esi
801022ba:	89 33                	mov    %esi,(%ebx)
  wakeup(b);
801022bc:	53                   	push   %ebx
801022bd:	e8 ce 22 00 00       	call   80104590 <wakeup>

  // Start disk on next buf in queue.
  if(idequeue != 0)
801022c2:	a1 e4 25 11 80       	mov    0x801125e4,%eax
801022c7:	83 c4 10             	add    $0x10,%esp
801022ca:	85 c0                	test   %eax,%eax
801022cc:	74 05                	je     801022d3 <ideintr+0x83>
    idestart(idequeue);
801022ce:	e8 1d fe ff ff       	call   801020f0 <idestart>
    release(&idelock);
801022d3:	83 ec 0c             	sub    $0xc,%esp
801022d6:	68 00 26 11 80       	push   $0x80112600
801022db:	e8 60 28 00 00       	call   80104b40 <release>

  release(&idelock);
}
801022e0:	8d 65 f4             	lea    -0xc(%ebp),%esp
801022e3:	5b                   	pop    %ebx
801022e4:	5e                   	pop    %esi
801022e5:	5f                   	pop    %edi
801022e6:	5d                   	pop    %ebp
801022e7:	c3                   	ret    
801022e8:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801022ef:	90                   	nop

801022f0 <iderw>:
// Sync buf with disk.
// If B_DIRTY is set, write buf to disk, clear B_DIRTY, set B_VALID.
// Else if B_VALID is not set, read buf from disk, set B_VALID.
void
iderw(struct buf *b)
{
801022f0:	55                   	push   %ebp
801022f1:	89 e5                	mov    %esp,%ebp
801022f3:	53                   	push   %ebx
801022f4:	83 ec 10             	sub    $0x10,%esp
801022f7:	8b 5d 08             	mov    0x8(%ebp),%ebx
  struct buf **pp;

  if(!holdingsleep(&b->lock))
801022fa:	8d 43 0c             	lea    0xc(%ebx),%eax
801022fd:	50                   	push   %eax
801022fe:	e8 7d 26 00 00       	call   80104980 <holdingsleep>
80102303:	83 c4 10             	add    $0x10,%esp
80102306:	85 c0                	test   %eax,%eax
80102308:	0f 84 c3 00 00 00    	je     801023d1 <iderw+0xe1>
    panic("iderw: buf not locked");
  if((b->flags & (B_VALID|B_DIRTY)) == B_VALID)
8010230e:	8b 03                	mov    (%ebx),%eax
80102310:	83 e0 06             	and    $0x6,%eax
80102313:	83 f8 02             	cmp    $0x2,%eax
80102316:	0f 84 a8 00 00 00    	je     801023c4 <iderw+0xd4>
    panic("iderw: nothing to do");
  if(b->dev != 0 && !havedisk1)
8010231c:	8b 53 04             	mov    0x4(%ebx),%edx
8010231f:	85 d2                	test   %edx,%edx
80102321:	74 0d                	je     80102330 <iderw+0x40>
80102323:	a1 e0 25 11 80       	mov    0x801125e0,%eax
80102328:	85 c0                	test   %eax,%eax
8010232a:	0f 84 87 00 00 00    	je     801023b7 <iderw+0xc7>
    panic("iderw: ide disk 1 not present");

  acquire(&idelock);  //DOC:acquire-lock
80102330:	83 ec 0c             	sub    $0xc,%esp
80102333:	68 00 26 11 80       	push   $0x80112600
80102338:	e8 63 28 00 00       	call   80104ba0 <acquire>

  // Append b to idequeue.
  b->qnext = 0;
  for(pp=&idequeue; *pp; pp=&(*pp)->qnext)  //DOC:insert-queue
8010233d:	a1 e4 25 11 80       	mov    0x801125e4,%eax
  b->qnext = 0;
80102342:	c7 43 58 00 00 00 00 	movl   $0x0,0x58(%ebx)
  for(pp=&idequeue; *pp; pp=&(*pp)->qnext)  //DOC:insert-queue
80102349:	83 c4 10             	add    $0x10,%esp
8010234c:	85 c0                	test   %eax,%eax
8010234e:	74 60                	je     801023b0 <iderw+0xc0>
80102350:	89 c2                	mov    %eax,%edx
80102352:	8b 40 58             	mov    0x58(%eax),%eax
80102355:	85 c0                	test   %eax,%eax
80102357:	75 f7                	jne    80102350 <iderw+0x60>
80102359:	83 c2 58             	add    $0x58,%edx
    ;
  *pp = b;
8010235c:	89 1a                	mov    %ebx,(%edx)

  // Start disk if necessary.
  if(idequeue == b)
8010235e:	39 1d e4 25 11 80    	cmp    %ebx,0x801125e4
80102364:	74 3a                	je     801023a0 <iderw+0xb0>
    idestart(b);

  // Wait for request to finish.
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
80102366:	8b 03                	mov    (%ebx),%eax
80102368:	83 e0 06             	and    $0x6,%eax
8010236b:	83 f8 02             	cmp    $0x2,%eax
8010236e:	74 1b                	je     8010238b <iderw+0x9b>
    sleep(b, &idelock);
80102370:	83 ec 08             	sub    $0x8,%esp
80102373:	68 00 26 11 80       	push   $0x80112600
80102378:	53                   	push   %ebx
80102379:	e8 52 21 00 00       	call   801044d0 <sleep>
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
8010237e:	8b 03                	mov    (%ebx),%eax
80102380:	83 c4 10             	add    $0x10,%esp
80102383:	83 e0 06             	and    $0x6,%eax
80102386:	83 f8 02             	cmp    $0x2,%eax
80102389:	75 e5                	jne    80102370 <iderw+0x80>
  }


  release(&idelock);
8010238b:	c7 45 08 00 26 11 80 	movl   $0x80112600,0x8(%ebp)
}
80102392:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80102395:	c9                   	leave  
  release(&idelock);
80102396:	e9 a5 27 00 00       	jmp    80104b40 <release>
8010239b:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
8010239f:	90                   	nop
    idestart(b);
801023a0:	89 d8                	mov    %ebx,%eax
801023a2:	e8 49 fd ff ff       	call   801020f0 <idestart>
801023a7:	eb bd                	jmp    80102366 <iderw+0x76>
801023a9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  for(pp=&idequeue; *pp; pp=&(*pp)->qnext)  //DOC:insert-queue
801023b0:	ba e4 25 11 80       	mov    $0x801125e4,%edx
801023b5:	eb a5                	jmp    8010235c <iderw+0x6c>
    panic("iderw: ide disk 1 not present");
801023b7:	83 ec 0c             	sub    $0xc,%esp
801023ba:	68 b5 82 10 80       	push   $0x801082b5
801023bf:	e8 bc df ff ff       	call   80100380 <panic>
    panic("iderw: nothing to do");
801023c4:	83 ec 0c             	sub    $0xc,%esp
801023c7:	68 a0 82 10 80       	push   $0x801082a0
801023cc:	e8 af df ff ff       	call   80100380 <panic>
    panic("iderw: buf not locked");
801023d1:	83 ec 0c             	sub    $0xc,%esp
801023d4:	68 8a 82 10 80       	push   $0x8010828a
801023d9:	e8 a2 df ff ff       	call   80100380 <panic>
801023de:	66 90                	xchg   %ax,%ax

801023e0 <ioapicinit>:
  ioapic->data = data;
}

void
ioapicinit(void)
{
801023e0:	55                   	push   %ebp
  int i, id, maxintr;

  ioapic = (volatile struct ioapic*)IOAPIC;
801023e1:	c7 05 34 26 11 80 00 	movl   $0xfec00000,0x80112634
801023e8:	00 c0 fe 
{
801023eb:	89 e5                	mov    %esp,%ebp
801023ed:	56                   	push   %esi
801023ee:	53                   	push   %ebx
  ioapic->reg = reg;
801023ef:	c7 05 00 00 c0 fe 01 	movl   $0x1,0xfec00000
801023f6:	00 00 00 
  return ioapic->data;
801023f9:	8b 15 34 26 11 80    	mov    0x80112634,%edx
801023ff:	8b 72 10             	mov    0x10(%edx),%esi
  ioapic->reg = reg;
80102402:	c7 02 00 00 00 00    	movl   $0x0,(%edx)
  return ioapic->data;
80102408:	8b 0d 34 26 11 80    	mov    0x80112634,%ecx
  maxintr = (ioapicread(REG_VER) >> 16) & 0xFF;
  id = ioapicread(REG_ID) >> 24;
  if(id != ioapicid)
8010240e:	0f b6 15 80 27 21 80 	movzbl 0x80212780,%edx
  maxintr = (ioapicread(REG_VER) >> 16) & 0xFF;
80102415:	c1 ee 10             	shr    $0x10,%esi
80102418:	89 f0                	mov    %esi,%eax
8010241a:	0f b6 f0             	movzbl %al,%esi
  return ioapic->data;
8010241d:	8b 41 10             	mov    0x10(%ecx),%eax
  id = ioapicread(REG_ID) >> 24;
80102420:	c1 e8 18             	shr    $0x18,%eax
  if(id != ioapicid)
80102423:	39 c2                	cmp    %eax,%edx
80102425:	74 16                	je     8010243d <ioapicinit+0x5d>
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");
80102427:	83 ec 0c             	sub    $0xc,%esp
8010242a:	68 d4 82 10 80       	push   $0x801082d4
8010242f:	e8 6c e2 ff ff       	call   801006a0 <cprintf>
  ioapic->reg = reg;
80102434:	8b 0d 34 26 11 80    	mov    0x80112634,%ecx
8010243a:	83 c4 10             	add    $0x10,%esp
8010243d:	83 c6 21             	add    $0x21,%esi
{
80102440:	ba 10 00 00 00       	mov    $0x10,%edx
80102445:	b8 20 00 00 00       	mov    $0x20,%eax
8010244a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  ioapic->reg = reg;
80102450:	89 11                	mov    %edx,(%ecx)

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
80102452:	89 c3                	mov    %eax,%ebx
  ioapic->data = data;
80102454:	8b 0d 34 26 11 80    	mov    0x80112634,%ecx
  for(i = 0; i <= maxintr; i++){
8010245a:	83 c0 01             	add    $0x1,%eax
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
8010245d:	81 cb 00 00 01 00    	or     $0x10000,%ebx
  ioapic->data = data;
80102463:	89 59 10             	mov    %ebx,0x10(%ecx)
  ioapic->reg = reg;
80102466:	8d 5a 01             	lea    0x1(%edx),%ebx
  for(i = 0; i <= maxintr; i++){
80102469:	83 c2 02             	add    $0x2,%edx
  ioapic->reg = reg;
8010246c:	89 19                	mov    %ebx,(%ecx)
  ioapic->data = data;
8010246e:	8b 0d 34 26 11 80    	mov    0x80112634,%ecx
80102474:	c7 41 10 00 00 00 00 	movl   $0x0,0x10(%ecx)
  for(i = 0; i <= maxintr; i++){
8010247b:	39 f0                	cmp    %esi,%eax
8010247d:	75 d1                	jne    80102450 <ioapicinit+0x70>
    ioapicwrite(REG_TABLE+2*i+1, 0);
  }
}
8010247f:	8d 65 f8             	lea    -0x8(%ebp),%esp
80102482:	5b                   	pop    %ebx
80102483:	5e                   	pop    %esi
80102484:	5d                   	pop    %ebp
80102485:	c3                   	ret    
80102486:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010248d:	8d 76 00             	lea    0x0(%esi),%esi

80102490 <ioapicenable>:

void
ioapicenable(int irq, int cpunum)
{
80102490:	55                   	push   %ebp
  ioapic->reg = reg;
80102491:	8b 0d 34 26 11 80    	mov    0x80112634,%ecx
{
80102497:	89 e5                	mov    %esp,%ebp
80102499:	8b 45 08             	mov    0x8(%ebp),%eax
  // Mark interrupt edge-triggered, active high,
  // enabled, and routed to the given cpunum,
  // which happens to be that cpu's APIC ID.
  ioapicwrite(REG_TABLE+2*irq, T_IRQ0 + irq);
8010249c:	8d 50 20             	lea    0x20(%eax),%edx
8010249f:	8d 44 00 10          	lea    0x10(%eax,%eax,1),%eax
  ioapic->reg = reg;
801024a3:	89 01                	mov    %eax,(%ecx)
  ioapic->data = data;
801024a5:	8b 0d 34 26 11 80    	mov    0x80112634,%ecx
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
801024ab:	83 c0 01             	add    $0x1,%eax
  ioapic->data = data;
801024ae:	89 51 10             	mov    %edx,0x10(%ecx)
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
801024b1:	8b 55 0c             	mov    0xc(%ebp),%edx
  ioapic->reg = reg;
801024b4:	89 01                	mov    %eax,(%ecx)
  ioapic->data = data;
801024b6:	a1 34 26 11 80       	mov    0x80112634,%eax
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
801024bb:	c1 e2 18             	shl    $0x18,%edx
  ioapic->data = data;
801024be:	89 50 10             	mov    %edx,0x10(%eax)
}
801024c1:	5d                   	pop    %ebp
801024c2:	c3                   	ret    
801024c3:	66 90                	xchg   %ax,%ax
801024c5:	66 90                	xchg   %ax,%ax
801024c7:	66 90                	xchg   %ax,%ax
801024c9:	66 90                	xchg   %ax,%ax
801024cb:	66 90                	xchg   %ax,%ax
801024cd:	66 90                	xchg   %ax,%ax
801024cf:	90                   	nop

801024d0 <inc_ref>:
  struct run *freelist;
} kmem;

static uchar ref_count[REF_1MB];

void inc_ref(uint pa) {
801024d0:	55                   	push   %ebp
801024d1:	89 e5                	mov    %esp,%ebp
  ref_count[pa >> PTXSHIFT]++;
801024d3:	8b 45 08             	mov    0x8(%ebp),%eax
}
801024d6:	5d                   	pop    %ebp
  ref_count[pa >> PTXSHIFT]++;
801024d7:	c1 e8 0c             	shr    $0xc,%eax
801024da:	80 80 80 26 11 80 01 	addb   $0x1,-0x7feed980(%eax)
}
801024e1:	c3                   	ret    
801024e2:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801024e9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

801024f0 <dec_ref>:
void dec_ref(uint pa) {
801024f0:	55                   	push   %ebp
801024f1:	89 e5                	mov    %esp,%ebp
  ref_count[pa >> PTXSHIFT]--;
801024f3:	8b 45 08             	mov    0x8(%ebp),%eax
}
801024f6:	5d                   	pop    %ebp
  ref_count[pa >> PTXSHIFT]--;
801024f7:	c1 e8 0c             	shr    $0xc,%eax
801024fa:	80 a8 80 26 11 80 01 	subb   $0x1,-0x7feed980(%eax)
}
80102501:	c3                   	ret    
80102502:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80102509:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

80102510 <get_ref>:

int get_ref(uint pa) {
80102510:	55                   	push   %ebp
80102511:	89 e5                	mov    %esp,%ebp
  int cnt = ref_count[pa >> PTXSHIFT];
80102513:	8b 45 08             	mov    0x8(%ebp),%eax
  return cnt;
}
80102516:	5d                   	pop    %ebp
  int cnt = ref_count[pa >> PTXSHIFT];
80102517:	c1 e8 0c             	shr    $0xc,%eax
8010251a:	0f b6 80 80 26 11 80 	movzbl -0x7feed980(%eax),%eax
}
80102521:	c3                   	ret    
80102522:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80102529:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

80102530 <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(char *v)
{
80102530:	55                   	push   %ebp
80102531:	89 e5                	mov    %esp,%ebp
80102533:	53                   	push   %ebx
80102534:	83 ec 04             	sub    $0x4,%esp
80102537:	8b 5d 08             	mov    0x8(%ebp),%ebx
  struct run *r;

  if((uint)v % PGSIZE || v < end || V2P(v) >= PHYSTOP)
8010253a:	f7 c3 ff 0f 00 00    	test   $0xfff,%ebx
80102540:	75 76                	jne    801025b8 <kfree+0x88>
80102542:	81 fb 10 b6 21 80    	cmp    $0x8021b610,%ebx
80102548:	72 6e                	jb     801025b8 <kfree+0x88>
8010254a:	8d 83 00 00 00 80    	lea    -0x80000000(%ebx),%eax
80102550:	3d ff ff ff 0d       	cmp    $0xdffffff,%eax
80102555:	77 61                	ja     801025b8 <kfree+0x88>
    panic("kfree");

  // Fill with junk to catch dangling refs.
  memset(v, 1, PGSIZE);
80102557:	83 ec 04             	sub    $0x4,%esp
8010255a:	68 00 10 00 00       	push   $0x1000
8010255f:	6a 01                	push   $0x1
80102561:	53                   	push   %ebx
80102562:	e8 f9 26 00 00       	call   80104c60 <memset>

  if(kmem.use_lock)
80102567:	8b 15 74 26 11 80    	mov    0x80112674,%edx
8010256d:	83 c4 10             	add    $0x10,%esp
80102570:	85 d2                	test   %edx,%edx
80102572:	75 1c                	jne    80102590 <kfree+0x60>
    acquire(&kmem.lock);
  r = (struct run*)v;
  r->next = kmem.freelist;
80102574:	a1 78 26 11 80       	mov    0x80112678,%eax
80102579:	89 03                	mov    %eax,(%ebx)
  kmem.freelist = r;
  if(kmem.use_lock)
8010257b:	a1 74 26 11 80       	mov    0x80112674,%eax
  kmem.freelist = r;
80102580:	89 1d 78 26 11 80    	mov    %ebx,0x80112678
  if(kmem.use_lock)
80102586:	85 c0                	test   %eax,%eax
80102588:	75 1e                	jne    801025a8 <kfree+0x78>
    release(&kmem.lock);
}
8010258a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010258d:	c9                   	leave  
8010258e:	c3                   	ret    
8010258f:	90                   	nop
    acquire(&kmem.lock);
80102590:	83 ec 0c             	sub    $0xc,%esp
80102593:	68 40 26 11 80       	push   $0x80112640
80102598:	e8 03 26 00 00       	call   80104ba0 <acquire>
8010259d:	83 c4 10             	add    $0x10,%esp
801025a0:	eb d2                	jmp    80102574 <kfree+0x44>
801025a2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    release(&kmem.lock);
801025a8:	c7 45 08 40 26 11 80 	movl   $0x80112640,0x8(%ebp)
}
801025af:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801025b2:	c9                   	leave  
    release(&kmem.lock);
801025b3:	e9 88 25 00 00       	jmp    80104b40 <release>
    panic("kfree");
801025b8:	83 ec 0c             	sub    $0xc,%esp
801025bb:	68 06 83 10 80       	push   $0x80108306
801025c0:	e8 bb dd ff ff       	call   80100380 <panic>
801025c5:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801025cc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

801025d0 <freerange>:
{
801025d0:	55                   	push   %ebp
801025d1:	89 e5                	mov    %esp,%ebp
801025d3:	56                   	push   %esi
  p = (char*)PGROUNDUP((uint)vstart);
801025d4:	8b 45 08             	mov    0x8(%ebp),%eax
{
801025d7:	8b 75 0c             	mov    0xc(%ebp),%esi
801025da:	53                   	push   %ebx
  p = (char*)PGROUNDUP((uint)vstart);
801025db:	8d 98 ff 0f 00 00    	lea    0xfff(%eax),%ebx
801025e1:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
801025e7:	81 c3 00 10 00 00    	add    $0x1000,%ebx
801025ed:	39 de                	cmp    %ebx,%esi
801025ef:	72 23                	jb     80102614 <freerange+0x44>
801025f1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    kfree(p);
801025f8:	83 ec 0c             	sub    $0xc,%esp
801025fb:	8d 83 00 f0 ff ff    	lea    -0x1000(%ebx),%eax
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102601:	81 c3 00 10 00 00    	add    $0x1000,%ebx
    kfree(p);
80102607:	50                   	push   %eax
80102608:	e8 23 ff ff ff       	call   80102530 <kfree>
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
8010260d:	83 c4 10             	add    $0x10,%esp
80102610:	39 f3                	cmp    %esi,%ebx
80102612:	76 e4                	jbe    801025f8 <freerange+0x28>
}
80102614:	8d 65 f8             	lea    -0x8(%ebp),%esp
80102617:	5b                   	pop    %ebx
80102618:	5e                   	pop    %esi
80102619:	5d                   	pop    %ebp
8010261a:	c3                   	ret    
8010261b:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
8010261f:	90                   	nop

80102620 <kinit2>:
{
80102620:	55                   	push   %ebp
80102621:	89 e5                	mov    %esp,%ebp
80102623:	56                   	push   %esi
  p = (char*)PGROUNDUP((uint)vstart);
80102624:	8b 45 08             	mov    0x8(%ebp),%eax
{
80102627:	8b 75 0c             	mov    0xc(%ebp),%esi
8010262a:	53                   	push   %ebx
  p = (char*)PGROUNDUP((uint)vstart);
8010262b:	8d 98 ff 0f 00 00    	lea    0xfff(%eax),%ebx
80102631:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102637:	81 c3 00 10 00 00    	add    $0x1000,%ebx
8010263d:	39 de                	cmp    %ebx,%esi
8010263f:	72 23                	jb     80102664 <kinit2+0x44>
80102641:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    kfree(p);
80102648:	83 ec 0c             	sub    $0xc,%esp
8010264b:	8d 83 00 f0 ff ff    	lea    -0x1000(%ebx),%eax
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102651:	81 c3 00 10 00 00    	add    $0x1000,%ebx
    kfree(p);
80102657:	50                   	push   %eax
80102658:	e8 d3 fe ff ff       	call   80102530 <kfree>
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
8010265d:	83 c4 10             	add    $0x10,%esp
80102660:	39 de                	cmp    %ebx,%esi
80102662:	73 e4                	jae    80102648 <kinit2+0x28>
  kmem.use_lock = 1;
80102664:	c7 05 74 26 11 80 01 	movl   $0x1,0x80112674
8010266b:	00 00 00 
}
8010266e:	8d 65 f8             	lea    -0x8(%ebp),%esp
80102671:	5b                   	pop    %ebx
80102672:	5e                   	pop    %esi
80102673:	5d                   	pop    %ebp
80102674:	c3                   	ret    
80102675:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010267c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

80102680 <kinit1>:
{
80102680:	55                   	push   %ebp
80102681:	89 e5                	mov    %esp,%ebp
80102683:	56                   	push   %esi
80102684:	53                   	push   %ebx
80102685:	8b 75 0c             	mov    0xc(%ebp),%esi
  initlock(&kmem.lock, "kmem");
80102688:	83 ec 08             	sub    $0x8,%esp
8010268b:	68 0c 83 10 80       	push   $0x8010830c
80102690:	68 40 26 11 80       	push   $0x80112640
80102695:	e8 36 23 00 00       	call   801049d0 <initlock>
  p = (char*)PGROUNDUP((uint)vstart);
8010269a:	8b 45 08             	mov    0x8(%ebp),%eax
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
8010269d:	83 c4 10             	add    $0x10,%esp
  kmem.use_lock = 0;
801026a0:	c7 05 74 26 11 80 00 	movl   $0x0,0x80112674
801026a7:	00 00 00 
  p = (char*)PGROUNDUP((uint)vstart);
801026aa:	8d 98 ff 0f 00 00    	lea    0xfff(%eax),%ebx
801026b0:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
801026b6:	81 c3 00 10 00 00    	add    $0x1000,%ebx
801026bc:	39 de                	cmp    %ebx,%esi
801026be:	72 1c                	jb     801026dc <kinit1+0x5c>
    kfree(p);
801026c0:	83 ec 0c             	sub    $0xc,%esp
801026c3:	8d 83 00 f0 ff ff    	lea    -0x1000(%ebx),%eax
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
801026c9:	81 c3 00 10 00 00    	add    $0x1000,%ebx
    kfree(p);
801026cf:	50                   	push   %eax
801026d0:	e8 5b fe ff ff       	call   80102530 <kfree>
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
801026d5:	83 c4 10             	add    $0x10,%esp
801026d8:	39 de                	cmp    %ebx,%esi
801026da:	73 e4                	jae    801026c0 <kinit1+0x40>
}
801026dc:	8d 65 f8             	lea    -0x8(%ebp),%esp
801026df:	5b                   	pop    %ebx
801026e0:	5e                   	pop    %esi
801026e1:	5d                   	pop    %ebp
801026e2:	c3                   	ret    
801026e3:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801026ea:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

801026f0 <kalloc>:
char*
kalloc(void)
{
  struct run *r;

  if(kmem.use_lock)
801026f0:	a1 74 26 11 80       	mov    0x80112674,%eax
801026f5:	85 c0                	test   %eax,%eax
801026f7:	75 1f                	jne    80102718 <kalloc+0x28>
    acquire(&kmem.lock);
  r = kmem.freelist;
801026f9:	a1 78 26 11 80       	mov    0x80112678,%eax
  if(r)
801026fe:	85 c0                	test   %eax,%eax
80102700:	74 0e                	je     80102710 <kalloc+0x20>
    kmem.freelist = r->next;
80102702:	8b 10                	mov    (%eax),%edx
80102704:	89 15 78 26 11 80    	mov    %edx,0x80112678
  if(kmem.use_lock)
8010270a:	c3                   	ret    
8010270b:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
8010270f:	90                   	nop
    release(&kmem.lock);
  return (char*)r;
}
80102710:	c3                   	ret    
80102711:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
{
80102718:	55                   	push   %ebp
80102719:	89 e5                	mov    %esp,%ebp
8010271b:	83 ec 24             	sub    $0x24,%esp
    acquire(&kmem.lock);
8010271e:	68 40 26 11 80       	push   $0x80112640
80102723:	e8 78 24 00 00       	call   80104ba0 <acquire>
  r = kmem.freelist;
80102728:	a1 78 26 11 80       	mov    0x80112678,%eax
  if(kmem.use_lock)
8010272d:	8b 15 74 26 11 80    	mov    0x80112674,%edx
  if(r)
80102733:	83 c4 10             	add    $0x10,%esp
80102736:	85 c0                	test   %eax,%eax
80102738:	74 08                	je     80102742 <kalloc+0x52>
    kmem.freelist = r->next;
8010273a:	8b 08                	mov    (%eax),%ecx
8010273c:	89 0d 78 26 11 80    	mov    %ecx,0x80112678
  if(kmem.use_lock)
80102742:	85 d2                	test   %edx,%edx
80102744:	74 16                	je     8010275c <kalloc+0x6c>
    release(&kmem.lock);
80102746:	83 ec 0c             	sub    $0xc,%esp
80102749:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010274c:	68 40 26 11 80       	push   $0x80112640
80102751:	e8 ea 23 00 00       	call   80104b40 <release>
  return (char*)r;
80102756:	8b 45 f4             	mov    -0xc(%ebp),%eax
    release(&kmem.lock);
80102759:	83 c4 10             	add    $0x10,%esp
}
8010275c:	c9                   	leave  
8010275d:	c3                   	ret    
8010275e:	66 90                	xchg   %ax,%ax

80102760 <kbdgetc>:
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102760:	ba 64 00 00 00       	mov    $0x64,%edx
80102765:	ec                   	in     (%dx),%al
    normalmap, shiftmap, ctlmap, ctlmap
  };
  uint st, data, c;

  st = inb(KBSTATP);
  if((st & KBS_DIB) == 0)
80102766:	a8 01                	test   $0x1,%al
80102768:	0f 84 c2 00 00 00    	je     80102830 <kbdgetc+0xd0>
{
8010276e:	55                   	push   %ebp
8010276f:	ba 60 00 00 00       	mov    $0x60,%edx
80102774:	89 e5                	mov    %esp,%ebp
80102776:	53                   	push   %ebx
80102777:	ec                   	in     (%dx),%al
    return -1;
  data = inb(KBDATAP);

  if(data == 0xE0){
    shift |= E0ESC;
80102778:	8b 1d 80 26 21 80    	mov    0x80212680,%ebx
  data = inb(KBDATAP);
8010277e:	0f b6 c8             	movzbl %al,%ecx
  if(data == 0xE0){
80102781:	3c e0                	cmp    $0xe0,%al
80102783:	74 5b                	je     801027e0 <kbdgetc+0x80>
    return 0;
  } else if(data & 0x80){
    // Key released
    data = (shift & E0ESC ? data : data & 0x7F);
80102785:	89 da                	mov    %ebx,%edx
80102787:	83 e2 40             	and    $0x40,%edx
  } else if(data & 0x80){
8010278a:	84 c0                	test   %al,%al
8010278c:	78 62                	js     801027f0 <kbdgetc+0x90>
    shift &= ~(shiftcode[data] | E0ESC);
    return 0;
  } else if(shift & E0ESC){
8010278e:	85 d2                	test   %edx,%edx
80102790:	74 09                	je     8010279b <kbdgetc+0x3b>
    // Last character was an E0 escape; or with 0x80
    data |= 0x80;
80102792:	83 c8 80             	or     $0xffffff80,%eax
    shift &= ~E0ESC;
80102795:	83 e3 bf             	and    $0xffffffbf,%ebx
    data |= 0x80;
80102798:	0f b6 c8             	movzbl %al,%ecx
  }

  shift |= shiftcode[data];
8010279b:	0f b6 91 40 84 10 80 	movzbl -0x7fef7bc0(%ecx),%edx
  shift ^= togglecode[data];
801027a2:	0f b6 81 40 83 10 80 	movzbl -0x7fef7cc0(%ecx),%eax
  shift |= shiftcode[data];
801027a9:	09 da                	or     %ebx,%edx
  shift ^= togglecode[data];
801027ab:	31 c2                	xor    %eax,%edx
  c = charcode[shift & (CTL | SHIFT)][data];
801027ad:	89 d0                	mov    %edx,%eax
  shift ^= togglecode[data];
801027af:	89 15 80 26 21 80    	mov    %edx,0x80212680
  c = charcode[shift & (CTL | SHIFT)][data];
801027b5:	83 e0 03             	and    $0x3,%eax
  if(shift & CAPSLOCK){
801027b8:	83 e2 08             	and    $0x8,%edx
  c = charcode[shift & (CTL | SHIFT)][data];
801027bb:	8b 04 85 20 83 10 80 	mov    -0x7fef7ce0(,%eax,4),%eax
801027c2:	0f b6 04 08          	movzbl (%eax,%ecx,1),%eax
  if(shift & CAPSLOCK){
801027c6:	74 0b                	je     801027d3 <kbdgetc+0x73>
    if('a' <= c && c <= 'z')
801027c8:	8d 50 9f             	lea    -0x61(%eax),%edx
801027cb:	83 fa 19             	cmp    $0x19,%edx
801027ce:	77 48                	ja     80102818 <kbdgetc+0xb8>
      c += 'A' - 'a';
801027d0:	83 e8 20             	sub    $0x20,%eax
    else if('A' <= c && c <= 'Z')
      c += 'a' - 'A';
  }
  return c;
}
801027d3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801027d6:	c9                   	leave  
801027d7:	c3                   	ret    
801027d8:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801027df:	90                   	nop
    shift |= E0ESC;
801027e0:	83 cb 40             	or     $0x40,%ebx
    return 0;
801027e3:	31 c0                	xor    %eax,%eax
    shift |= E0ESC;
801027e5:	89 1d 80 26 21 80    	mov    %ebx,0x80212680
}
801027eb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801027ee:	c9                   	leave  
801027ef:	c3                   	ret    
    data = (shift & E0ESC ? data : data & 0x7F);
801027f0:	83 e0 7f             	and    $0x7f,%eax
801027f3:	85 d2                	test   %edx,%edx
801027f5:	0f 44 c8             	cmove  %eax,%ecx
    shift &= ~(shiftcode[data] | E0ESC);
801027f8:	0f b6 81 40 84 10 80 	movzbl -0x7fef7bc0(%ecx),%eax
801027ff:	83 c8 40             	or     $0x40,%eax
80102802:	0f b6 c0             	movzbl %al,%eax
80102805:	f7 d0                	not    %eax
80102807:	21 d8                	and    %ebx,%eax
}
80102809:	8b 5d fc             	mov    -0x4(%ebp),%ebx
    shift &= ~(shiftcode[data] | E0ESC);
8010280c:	a3 80 26 21 80       	mov    %eax,0x80212680
    return 0;
80102811:	31 c0                	xor    %eax,%eax
}
80102813:	c9                   	leave  
80102814:	c3                   	ret    
80102815:	8d 76 00             	lea    0x0(%esi),%esi
    else if('A' <= c && c <= 'Z')
80102818:	8d 48 bf             	lea    -0x41(%eax),%ecx
      c += 'a' - 'A';
8010281b:	8d 50 20             	lea    0x20(%eax),%edx
}
8010281e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80102821:	c9                   	leave  
      c += 'a' - 'A';
80102822:	83 f9 1a             	cmp    $0x1a,%ecx
80102825:	0f 42 c2             	cmovb  %edx,%eax
}
80102828:	c3                   	ret    
80102829:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    return -1;
80102830:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80102835:	c3                   	ret    
80102836:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010283d:	8d 76 00             	lea    0x0(%esi),%esi

80102840 <kbdintr>:

void
kbdintr(void)
{
80102840:	55                   	push   %ebp
80102841:	89 e5                	mov    %esp,%ebp
80102843:	83 ec 14             	sub    $0x14,%esp
  consoleintr(kbdgetc);
80102846:	68 60 27 10 80       	push   $0x80102760
8010284b:	e8 30 e0 ff ff       	call   80100880 <consoleintr>
}
80102850:	83 c4 10             	add    $0x10,%esp
80102853:	c9                   	leave  
80102854:	c3                   	ret    
80102855:	66 90                	xchg   %ax,%ax
80102857:	66 90                	xchg   %ax,%ax
80102859:	66 90                	xchg   %ax,%ax
8010285b:	66 90                	xchg   %ax,%ax
8010285d:	66 90                	xchg   %ax,%ax
8010285f:	90                   	nop

80102860 <lapicinit>:
}

void
lapicinit(void)
{
  if(!lapic)
80102860:	a1 84 26 21 80       	mov    0x80212684,%eax
80102865:	85 c0                	test   %eax,%eax
80102867:	0f 84 cb 00 00 00    	je     80102938 <lapicinit+0xd8>
  lapic[index] = value;
8010286d:	c7 80 f0 00 00 00 3f 	movl   $0x13f,0xf0(%eax)
80102874:	01 00 00 
  lapic[ID];  // wait for write to finish, by reading
80102877:	8b 50 20             	mov    0x20(%eax),%edx
  lapic[index] = value;
8010287a:	c7 80 e0 03 00 00 0b 	movl   $0xb,0x3e0(%eax)
80102881:	00 00 00 
  lapic[ID];  // wait for write to finish, by reading
80102884:	8b 50 20             	mov    0x20(%eax),%edx
  lapic[index] = value;
80102887:	c7 80 20 03 00 00 20 	movl   $0x20020,0x320(%eax)
8010288e:	00 02 00 
  lapic[ID];  // wait for write to finish, by reading
80102891:	8b 50 20             	mov    0x20(%eax),%edx
  lapic[index] = value;
80102894:	c7 80 80 03 00 00 80 	movl   $0x989680,0x380(%eax)
8010289b:	96 98 00 
  lapic[ID];  // wait for write to finish, by reading
8010289e:	8b 50 20             	mov    0x20(%eax),%edx
  lapic[index] = value;
801028a1:	c7 80 50 03 00 00 00 	movl   $0x10000,0x350(%eax)
801028a8:	00 01 00 
  lapic[ID];  // wait for write to finish, by reading
801028ab:	8b 50 20             	mov    0x20(%eax),%edx
  lapic[index] = value;
801028ae:	c7 80 60 03 00 00 00 	movl   $0x10000,0x360(%eax)
801028b5:	00 01 00 
  lapic[ID];  // wait for write to finish, by reading
801028b8:	8b 50 20             	mov    0x20(%eax),%edx
  lapicw(LINT0, MASKED);
  lapicw(LINT1, MASKED);

  // Disable performance counter overflow interrupts
  // on machines that provide that interrupt entry.
  if(((lapic[VER]>>16) & 0xFF) >= 4)
801028bb:	8b 50 30             	mov    0x30(%eax),%edx
801028be:	c1 ea 10             	shr    $0x10,%edx
801028c1:	81 e2 fc 00 00 00    	and    $0xfc,%edx
801028c7:	75 77                	jne    80102940 <lapicinit+0xe0>
  lapic[index] = value;
801028c9:	c7 80 70 03 00 00 33 	movl   $0x33,0x370(%eax)
801028d0:	00 00 00 
  lapic[ID];  // wait for write to finish, by reading
801028d3:	8b 50 20             	mov    0x20(%eax),%edx
  lapic[index] = value;
801028d6:	c7 80 80 02 00 00 00 	movl   $0x0,0x280(%eax)
801028dd:	00 00 00 
  lapic[ID];  // wait for write to finish, by reading
801028e0:	8b 50 20             	mov    0x20(%eax),%edx
  lapic[index] = value;
801028e3:	c7 80 80 02 00 00 00 	movl   $0x0,0x280(%eax)
801028ea:	00 00 00 
  lapic[ID];  // wait for write to finish, by reading
801028ed:	8b 50 20             	mov    0x20(%eax),%edx
  lapic[index] = value;
801028f0:	c7 80 b0 00 00 00 00 	movl   $0x0,0xb0(%eax)
801028f7:	00 00 00 
  lapic[ID];  // wait for write to finish, by reading
801028fa:	8b 50 20             	mov    0x20(%eax),%edx
  lapic[index] = value;
801028fd:	c7 80 10 03 00 00 00 	movl   $0x0,0x310(%eax)
80102904:	00 00 00 
  lapic[ID];  // wait for write to finish, by reading
80102907:	8b 50 20             	mov    0x20(%eax),%edx
  lapic[index] = value;
8010290a:	c7 80 00 03 00 00 00 	movl   $0x88500,0x300(%eax)
80102911:	85 08 00 
  lapic[ID];  // wait for write to finish, by reading
80102914:	8b 50 20             	mov    0x20(%eax),%edx
80102917:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010291e:	66 90                	xchg   %ax,%ax
  lapicw(EOI, 0);

  // Send an Init Level De-Assert to synchronise arbitration ID's.
  lapicw(ICRHI, 0);
  lapicw(ICRLO, BCAST | INIT | LEVEL);
  while(lapic[ICRLO] & DELIVS)
80102920:	8b 90 00 03 00 00    	mov    0x300(%eax),%edx
80102926:	80 e6 10             	and    $0x10,%dh
80102929:	75 f5                	jne    80102920 <lapicinit+0xc0>
  lapic[index] = value;
8010292b:	c7 80 80 00 00 00 00 	movl   $0x0,0x80(%eax)
80102932:	00 00 00 
  lapic[ID];  // wait for write to finish, by reading
80102935:	8b 40 20             	mov    0x20(%eax),%eax
    ;

  // Enable interrupts on the APIC (but not on the processor).
  lapicw(TPR, 0);
}
80102938:	c3                   	ret    
80102939:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  lapic[index] = value;
80102940:	c7 80 40 03 00 00 00 	movl   $0x10000,0x340(%eax)
80102947:	00 01 00 
  lapic[ID];  // wait for write to finish, by reading
8010294a:	8b 50 20             	mov    0x20(%eax),%edx
}
8010294d:	e9 77 ff ff ff       	jmp    801028c9 <lapicinit+0x69>
80102952:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80102959:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

80102960 <lapicid>:

int
lapicid(void)
{
  if (!lapic)
80102960:	a1 84 26 21 80       	mov    0x80212684,%eax
80102965:	85 c0                	test   %eax,%eax
80102967:	74 07                	je     80102970 <lapicid+0x10>
    return 0;
  return lapic[ID] >> 24;
80102969:	8b 40 20             	mov    0x20(%eax),%eax
8010296c:	c1 e8 18             	shr    $0x18,%eax
8010296f:	c3                   	ret    
    return 0;
80102970:	31 c0                	xor    %eax,%eax
}
80102972:	c3                   	ret    
80102973:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010297a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

80102980 <lapiceoi>:

// Acknowledge interrupt.
void
lapiceoi(void)
{
  if(lapic)
80102980:	a1 84 26 21 80       	mov    0x80212684,%eax
80102985:	85 c0                	test   %eax,%eax
80102987:	74 0d                	je     80102996 <lapiceoi+0x16>
  lapic[index] = value;
80102989:	c7 80 b0 00 00 00 00 	movl   $0x0,0xb0(%eax)
80102990:	00 00 00 
  lapic[ID];  // wait for write to finish, by reading
80102993:	8b 40 20             	mov    0x20(%eax),%eax
    lapicw(EOI, 0);
}
80102996:	c3                   	ret    
80102997:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010299e:	66 90                	xchg   %ax,%ax

801029a0 <microdelay>:
// Spin for a given number of microseconds.
// On real hardware would want to tune this dynamically.
void
microdelay(int us)
{
}
801029a0:	c3                   	ret    
801029a1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801029a8:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801029af:	90                   	nop

801029b0 <lapicstartap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapicstartap(uchar apicid, uint addr)
{
801029b0:	55                   	push   %ebp
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801029b1:	b8 0f 00 00 00       	mov    $0xf,%eax
801029b6:	ba 70 00 00 00       	mov    $0x70,%edx
801029bb:	89 e5                	mov    %esp,%ebp
801029bd:	53                   	push   %ebx
801029be:	8b 4d 0c             	mov    0xc(%ebp),%ecx
801029c1:	8b 5d 08             	mov    0x8(%ebp),%ebx
801029c4:	ee                   	out    %al,(%dx)
801029c5:	b8 0a 00 00 00       	mov    $0xa,%eax
801029ca:	ba 71 00 00 00       	mov    $0x71,%edx
801029cf:	ee                   	out    %al,(%dx)
  // and the warm reset vector (DWORD based at 40:67) to point at
  // the AP startup code prior to the [universal startup algorithm]."
  outb(CMOS_PORT, 0xF);  // offset 0xF is shutdown code
  outb(CMOS_PORT+1, 0x0A);
  wrv = (ushort*)P2V((0x40<<4 | 0x67));  // Warm reset vector
  wrv[0] = 0;
801029d0:	31 c0                	xor    %eax,%eax
  wrv[1] = addr >> 4;

  // "Universal startup algorithm."
  // Send INIT (level-triggered) interrupt to reset other CPU.
  lapicw(ICRHI, apicid<<24);
801029d2:	c1 e3 18             	shl    $0x18,%ebx
  wrv[0] = 0;
801029d5:	66 a3 67 04 00 80    	mov    %ax,0x80000467
  wrv[1] = addr >> 4;
801029db:	89 c8                	mov    %ecx,%eax
  // when it is in the halted state due to an INIT.  So the second
  // should be ignored, but it is part of the official Intel algorithm.
  // Bochs complains about the second one.  Too bad for Bochs.
  for(i = 0; i < 2; i++){
    lapicw(ICRHI, apicid<<24);
    lapicw(ICRLO, STARTUP | (addr>>12));
801029dd:	c1 e9 0c             	shr    $0xc,%ecx
  lapicw(ICRHI, apicid<<24);
801029e0:	89 da                	mov    %ebx,%edx
  wrv[1] = addr >> 4;
801029e2:	c1 e8 04             	shr    $0x4,%eax
    lapicw(ICRLO, STARTUP | (addr>>12));
801029e5:	80 cd 06             	or     $0x6,%ch
  wrv[1] = addr >> 4;
801029e8:	66 a3 69 04 00 80    	mov    %ax,0x80000469
  lapic[index] = value;
801029ee:	a1 84 26 21 80       	mov    0x80212684,%eax
801029f3:	89 98 10 03 00 00    	mov    %ebx,0x310(%eax)
  lapic[ID];  // wait for write to finish, by reading
801029f9:	8b 58 20             	mov    0x20(%eax),%ebx
  lapic[index] = value;
801029fc:	c7 80 00 03 00 00 00 	movl   $0xc500,0x300(%eax)
80102a03:	c5 00 00 
  lapic[ID];  // wait for write to finish, by reading
80102a06:	8b 58 20             	mov    0x20(%eax),%ebx
  lapic[index] = value;
80102a09:	c7 80 00 03 00 00 00 	movl   $0x8500,0x300(%eax)
80102a10:	85 00 00 
  lapic[ID];  // wait for write to finish, by reading
80102a13:	8b 58 20             	mov    0x20(%eax),%ebx
  lapic[index] = value;
80102a16:	89 90 10 03 00 00    	mov    %edx,0x310(%eax)
  lapic[ID];  // wait for write to finish, by reading
80102a1c:	8b 58 20             	mov    0x20(%eax),%ebx
  lapic[index] = value;
80102a1f:	89 88 00 03 00 00    	mov    %ecx,0x300(%eax)
  lapic[ID];  // wait for write to finish, by reading
80102a25:	8b 58 20             	mov    0x20(%eax),%ebx
  lapic[index] = value;
80102a28:	89 90 10 03 00 00    	mov    %edx,0x310(%eax)
  lapic[ID];  // wait for write to finish, by reading
80102a2e:	8b 50 20             	mov    0x20(%eax),%edx
  lapic[index] = value;
80102a31:	89 88 00 03 00 00    	mov    %ecx,0x300(%eax)
  lapic[ID];  // wait for write to finish, by reading
80102a37:	8b 40 20             	mov    0x20(%eax),%eax
    microdelay(200);
  }
}
80102a3a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80102a3d:	c9                   	leave  
80102a3e:	c3                   	ret    
80102a3f:	90                   	nop

80102a40 <cmostime>:
}

// qemu seems to use 24-hour GWT and the values are BCD encoded
void
cmostime(struct rtcdate *r)
{
80102a40:	55                   	push   %ebp
80102a41:	b8 0b 00 00 00       	mov    $0xb,%eax
80102a46:	ba 70 00 00 00       	mov    $0x70,%edx
80102a4b:	89 e5                	mov    %esp,%ebp
80102a4d:	57                   	push   %edi
80102a4e:	56                   	push   %esi
80102a4f:	53                   	push   %ebx
80102a50:	83 ec 4c             	sub    $0x4c,%esp
80102a53:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102a54:	ba 71 00 00 00       	mov    $0x71,%edx
80102a59:	ec                   	in     (%dx),%al
  struct rtcdate t1, t2;
  int sb, bcd;

  sb = cmos_read(CMOS_STATB);

  bcd = (sb & (1 << 2)) == 0;
80102a5a:	83 e0 04             	and    $0x4,%eax
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102a5d:	bb 70 00 00 00       	mov    $0x70,%ebx
80102a62:	88 45 b3             	mov    %al,-0x4d(%ebp)
80102a65:	8d 76 00             	lea    0x0(%esi),%esi
80102a68:	31 c0                	xor    %eax,%eax
80102a6a:	89 da                	mov    %ebx,%edx
80102a6c:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102a6d:	b9 71 00 00 00       	mov    $0x71,%ecx
80102a72:	89 ca                	mov    %ecx,%edx
80102a74:	ec                   	in     (%dx),%al
80102a75:	88 45 b7             	mov    %al,-0x49(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102a78:	89 da                	mov    %ebx,%edx
80102a7a:	b8 02 00 00 00       	mov    $0x2,%eax
80102a7f:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102a80:	89 ca                	mov    %ecx,%edx
80102a82:	ec                   	in     (%dx),%al
80102a83:	88 45 b6             	mov    %al,-0x4a(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102a86:	89 da                	mov    %ebx,%edx
80102a88:	b8 04 00 00 00       	mov    $0x4,%eax
80102a8d:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102a8e:	89 ca                	mov    %ecx,%edx
80102a90:	ec                   	in     (%dx),%al
80102a91:	88 45 b5             	mov    %al,-0x4b(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102a94:	89 da                	mov    %ebx,%edx
80102a96:	b8 07 00 00 00       	mov    $0x7,%eax
80102a9b:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102a9c:	89 ca                	mov    %ecx,%edx
80102a9e:	ec                   	in     (%dx),%al
80102a9f:	88 45 b4             	mov    %al,-0x4c(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102aa2:	89 da                	mov    %ebx,%edx
80102aa4:	b8 08 00 00 00       	mov    $0x8,%eax
80102aa9:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102aaa:	89 ca                	mov    %ecx,%edx
80102aac:	ec                   	in     (%dx),%al
80102aad:	89 c7                	mov    %eax,%edi
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102aaf:	89 da                	mov    %ebx,%edx
80102ab1:	b8 09 00 00 00       	mov    $0x9,%eax
80102ab6:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102ab7:	89 ca                	mov    %ecx,%edx
80102ab9:	ec                   	in     (%dx),%al
80102aba:	89 c6                	mov    %eax,%esi
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102abc:	89 da                	mov    %ebx,%edx
80102abe:	b8 0a 00 00 00       	mov    $0xa,%eax
80102ac3:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102ac4:	89 ca                	mov    %ecx,%edx
80102ac6:	ec                   	in     (%dx),%al

  // make sure CMOS doesn't modify time while we read it
  for(;;) {
    fill_rtcdate(&t1);
    if(cmos_read(CMOS_STATA) & CMOS_UIP)
80102ac7:	84 c0                	test   %al,%al
80102ac9:	78 9d                	js     80102a68 <cmostime+0x28>
  return inb(CMOS_RETURN);
80102acb:	0f b6 45 b7          	movzbl -0x49(%ebp),%eax
80102acf:	89 fa                	mov    %edi,%edx
80102ad1:	0f b6 fa             	movzbl %dl,%edi
80102ad4:	89 f2                	mov    %esi,%edx
80102ad6:	89 45 b8             	mov    %eax,-0x48(%ebp)
80102ad9:	0f b6 45 b6          	movzbl -0x4a(%ebp),%eax
80102add:	0f b6 f2             	movzbl %dl,%esi
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102ae0:	89 da                	mov    %ebx,%edx
80102ae2:	89 7d c8             	mov    %edi,-0x38(%ebp)
80102ae5:	89 45 bc             	mov    %eax,-0x44(%ebp)
80102ae8:	0f b6 45 b5          	movzbl -0x4b(%ebp),%eax
80102aec:	89 75 cc             	mov    %esi,-0x34(%ebp)
80102aef:	89 45 c0             	mov    %eax,-0x40(%ebp)
80102af2:	0f b6 45 b4          	movzbl -0x4c(%ebp),%eax
80102af6:	89 45 c4             	mov    %eax,-0x3c(%ebp)
80102af9:	31 c0                	xor    %eax,%eax
80102afb:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102afc:	89 ca                	mov    %ecx,%edx
80102afe:	ec                   	in     (%dx),%al
80102aff:	0f b6 c0             	movzbl %al,%eax
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102b02:	89 da                	mov    %ebx,%edx
80102b04:	89 45 d0             	mov    %eax,-0x30(%ebp)
80102b07:	b8 02 00 00 00       	mov    $0x2,%eax
80102b0c:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102b0d:	89 ca                	mov    %ecx,%edx
80102b0f:	ec                   	in     (%dx),%al
80102b10:	0f b6 c0             	movzbl %al,%eax
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102b13:	89 da                	mov    %ebx,%edx
80102b15:	89 45 d4             	mov    %eax,-0x2c(%ebp)
80102b18:	b8 04 00 00 00       	mov    $0x4,%eax
80102b1d:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102b1e:	89 ca                	mov    %ecx,%edx
80102b20:	ec                   	in     (%dx),%al
80102b21:	0f b6 c0             	movzbl %al,%eax
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102b24:	89 da                	mov    %ebx,%edx
80102b26:	89 45 d8             	mov    %eax,-0x28(%ebp)
80102b29:	b8 07 00 00 00       	mov    $0x7,%eax
80102b2e:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102b2f:	89 ca                	mov    %ecx,%edx
80102b31:	ec                   	in     (%dx),%al
80102b32:	0f b6 c0             	movzbl %al,%eax
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102b35:	89 da                	mov    %ebx,%edx
80102b37:	89 45 dc             	mov    %eax,-0x24(%ebp)
80102b3a:	b8 08 00 00 00       	mov    $0x8,%eax
80102b3f:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102b40:	89 ca                	mov    %ecx,%edx
80102b42:	ec                   	in     (%dx),%al
80102b43:	0f b6 c0             	movzbl %al,%eax
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102b46:	89 da                	mov    %ebx,%edx
80102b48:	89 45 e0             	mov    %eax,-0x20(%ebp)
80102b4b:	b8 09 00 00 00       	mov    $0x9,%eax
80102b50:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102b51:	89 ca                	mov    %ecx,%edx
80102b53:	ec                   	in     (%dx),%al
80102b54:	0f b6 c0             	movzbl %al,%eax
        continue;
    fill_rtcdate(&t2);
    if(memcmp(&t1, &t2, sizeof(t1)) == 0)
80102b57:	83 ec 04             	sub    $0x4,%esp
  return inb(CMOS_RETURN);
80102b5a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(memcmp(&t1, &t2, sizeof(t1)) == 0)
80102b5d:	8d 45 d0             	lea    -0x30(%ebp),%eax
80102b60:	6a 18                	push   $0x18
80102b62:	50                   	push   %eax
80102b63:	8d 45 b8             	lea    -0x48(%ebp),%eax
80102b66:	50                   	push   %eax
80102b67:	e8 44 21 00 00       	call   80104cb0 <memcmp>
80102b6c:	83 c4 10             	add    $0x10,%esp
80102b6f:	85 c0                	test   %eax,%eax
80102b71:	0f 85 f1 fe ff ff    	jne    80102a68 <cmostime+0x28>
      break;
  }

  // convert
  if(bcd) {
80102b77:	80 7d b3 00          	cmpb   $0x0,-0x4d(%ebp)
80102b7b:	75 78                	jne    80102bf5 <cmostime+0x1b5>
#define    CONV(x)     (t1.x = ((t1.x >> 4) * 10) + (t1.x & 0xf))
    CONV(second);
80102b7d:	8b 45 b8             	mov    -0x48(%ebp),%eax
80102b80:	89 c2                	mov    %eax,%edx
80102b82:	83 e0 0f             	and    $0xf,%eax
80102b85:	c1 ea 04             	shr    $0x4,%edx
80102b88:	8d 14 92             	lea    (%edx,%edx,4),%edx
80102b8b:	8d 04 50             	lea    (%eax,%edx,2),%eax
80102b8e:	89 45 b8             	mov    %eax,-0x48(%ebp)
    CONV(minute);
80102b91:	8b 45 bc             	mov    -0x44(%ebp),%eax
80102b94:	89 c2                	mov    %eax,%edx
80102b96:	83 e0 0f             	and    $0xf,%eax
80102b99:	c1 ea 04             	shr    $0x4,%edx
80102b9c:	8d 14 92             	lea    (%edx,%edx,4),%edx
80102b9f:	8d 04 50             	lea    (%eax,%edx,2),%eax
80102ba2:	89 45 bc             	mov    %eax,-0x44(%ebp)
    CONV(hour  );
80102ba5:	8b 45 c0             	mov    -0x40(%ebp),%eax
80102ba8:	89 c2                	mov    %eax,%edx
80102baa:	83 e0 0f             	and    $0xf,%eax
80102bad:	c1 ea 04             	shr    $0x4,%edx
80102bb0:	8d 14 92             	lea    (%edx,%edx,4),%edx
80102bb3:	8d 04 50             	lea    (%eax,%edx,2),%eax
80102bb6:	89 45 c0             	mov    %eax,-0x40(%ebp)
    CONV(day   );
80102bb9:	8b 45 c4             	mov    -0x3c(%ebp),%eax
80102bbc:	89 c2                	mov    %eax,%edx
80102bbe:	83 e0 0f             	and    $0xf,%eax
80102bc1:	c1 ea 04             	shr    $0x4,%edx
80102bc4:	8d 14 92             	lea    (%edx,%edx,4),%edx
80102bc7:	8d 04 50             	lea    (%eax,%edx,2),%eax
80102bca:	89 45 c4             	mov    %eax,-0x3c(%ebp)
    CONV(month );
80102bcd:	8b 45 c8             	mov    -0x38(%ebp),%eax
80102bd0:	89 c2                	mov    %eax,%edx
80102bd2:	83 e0 0f             	and    $0xf,%eax
80102bd5:	c1 ea 04             	shr    $0x4,%edx
80102bd8:	8d 14 92             	lea    (%edx,%edx,4),%edx
80102bdb:	8d 04 50             	lea    (%eax,%edx,2),%eax
80102bde:	89 45 c8             	mov    %eax,-0x38(%ebp)
    CONV(year  );
80102be1:	8b 45 cc             	mov    -0x34(%ebp),%eax
80102be4:	89 c2                	mov    %eax,%edx
80102be6:	83 e0 0f             	and    $0xf,%eax
80102be9:	c1 ea 04             	shr    $0x4,%edx
80102bec:	8d 14 92             	lea    (%edx,%edx,4),%edx
80102bef:	8d 04 50             	lea    (%eax,%edx,2),%eax
80102bf2:	89 45 cc             	mov    %eax,-0x34(%ebp)
#undef     CONV
  }

  *r = t1;
80102bf5:	8b 75 08             	mov    0x8(%ebp),%esi
80102bf8:	8b 45 b8             	mov    -0x48(%ebp),%eax
80102bfb:	89 06                	mov    %eax,(%esi)
80102bfd:	8b 45 bc             	mov    -0x44(%ebp),%eax
80102c00:	89 46 04             	mov    %eax,0x4(%esi)
80102c03:	8b 45 c0             	mov    -0x40(%ebp),%eax
80102c06:	89 46 08             	mov    %eax,0x8(%esi)
80102c09:	8b 45 c4             	mov    -0x3c(%ebp),%eax
80102c0c:	89 46 0c             	mov    %eax,0xc(%esi)
80102c0f:	8b 45 c8             	mov    -0x38(%ebp),%eax
80102c12:	89 46 10             	mov    %eax,0x10(%esi)
80102c15:	8b 45 cc             	mov    -0x34(%ebp),%eax
80102c18:	89 46 14             	mov    %eax,0x14(%esi)
  r->year += 2000;
80102c1b:	81 46 14 d0 07 00 00 	addl   $0x7d0,0x14(%esi)
}
80102c22:	8d 65 f4             	lea    -0xc(%ebp),%esp
80102c25:	5b                   	pop    %ebx
80102c26:	5e                   	pop    %esi
80102c27:	5f                   	pop    %edi
80102c28:	5d                   	pop    %ebp
80102c29:	c3                   	ret    
80102c2a:	66 90                	xchg   %ax,%ax
80102c2c:	66 90                	xchg   %ax,%ax
80102c2e:	66 90                	xchg   %ax,%ax

80102c30 <install_trans>:
static void
install_trans(void)
{
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
80102c30:	8b 0d e8 26 21 80    	mov    0x802126e8,%ecx
80102c36:	85 c9                	test   %ecx,%ecx
80102c38:	0f 8e 8a 00 00 00    	jle    80102cc8 <install_trans+0x98>
{
80102c3e:	55                   	push   %ebp
80102c3f:	89 e5                	mov    %esp,%ebp
80102c41:	57                   	push   %edi
  for (tail = 0; tail < log.lh.n; tail++) {
80102c42:	31 ff                	xor    %edi,%edi
{
80102c44:	56                   	push   %esi
80102c45:	53                   	push   %ebx
80102c46:	83 ec 0c             	sub    $0xc,%esp
80102c49:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
80102c50:	a1 d4 26 21 80       	mov    0x802126d4,%eax
80102c55:	83 ec 08             	sub    $0x8,%esp
80102c58:	01 f8                	add    %edi,%eax
80102c5a:	83 c0 01             	add    $0x1,%eax
80102c5d:	50                   	push   %eax
80102c5e:	ff 35 e4 26 21 80    	push   0x802126e4
80102c64:	e8 67 d4 ff ff       	call   801000d0 <bread>
80102c69:	89 c6                	mov    %eax,%esi
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
80102c6b:	58                   	pop    %eax
80102c6c:	5a                   	pop    %edx
80102c6d:	ff 34 bd ec 26 21 80 	push   -0x7fded914(,%edi,4)
80102c74:	ff 35 e4 26 21 80    	push   0x802126e4
  for (tail = 0; tail < log.lh.n; tail++) {
80102c7a:	83 c7 01             	add    $0x1,%edi
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
80102c7d:	e8 4e d4 ff ff       	call   801000d0 <bread>
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
80102c82:	83 c4 0c             	add    $0xc,%esp
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
80102c85:	89 c3                	mov    %eax,%ebx
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
80102c87:	8d 46 5c             	lea    0x5c(%esi),%eax
80102c8a:	68 00 02 00 00       	push   $0x200
80102c8f:	50                   	push   %eax
80102c90:	8d 43 5c             	lea    0x5c(%ebx),%eax
80102c93:	50                   	push   %eax
80102c94:	e8 67 20 00 00       	call   80104d00 <memmove>
    bwrite(dbuf);  // write dst to disk
80102c99:	89 1c 24             	mov    %ebx,(%esp)
80102c9c:	e8 0f d5 ff ff       	call   801001b0 <bwrite>
    brelse(lbuf);
80102ca1:	89 34 24             	mov    %esi,(%esp)
80102ca4:	e8 47 d5 ff ff       	call   801001f0 <brelse>
    brelse(dbuf);
80102ca9:	89 1c 24             	mov    %ebx,(%esp)
80102cac:	e8 3f d5 ff ff       	call   801001f0 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
80102cb1:	83 c4 10             	add    $0x10,%esp
80102cb4:	39 3d e8 26 21 80    	cmp    %edi,0x802126e8
80102cba:	7f 94                	jg     80102c50 <install_trans+0x20>
  }
}
80102cbc:	8d 65 f4             	lea    -0xc(%ebp),%esp
80102cbf:	5b                   	pop    %ebx
80102cc0:	5e                   	pop    %esi
80102cc1:	5f                   	pop    %edi
80102cc2:	5d                   	pop    %ebp
80102cc3:	c3                   	ret    
80102cc4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80102cc8:	c3                   	ret    
80102cc9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

80102cd0 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
80102cd0:	55                   	push   %ebp
80102cd1:	89 e5                	mov    %esp,%ebp
80102cd3:	53                   	push   %ebx
80102cd4:	83 ec 0c             	sub    $0xc,%esp
  struct buf *buf = bread(log.dev, log.start);
80102cd7:	ff 35 d4 26 21 80    	push   0x802126d4
80102cdd:	ff 35 e4 26 21 80    	push   0x802126e4
80102ce3:	e8 e8 d3 ff ff       	call   801000d0 <bread>
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
  for (i = 0; i < log.lh.n; i++) {
80102ce8:	83 c4 10             	add    $0x10,%esp
  struct buf *buf = bread(log.dev, log.start);
80102ceb:	89 c3                	mov    %eax,%ebx
  hb->n = log.lh.n;
80102ced:	a1 e8 26 21 80       	mov    0x802126e8,%eax
80102cf2:	89 43 5c             	mov    %eax,0x5c(%ebx)
  for (i = 0; i < log.lh.n; i++) {
80102cf5:	85 c0                	test   %eax,%eax
80102cf7:	7e 19                	jle    80102d12 <write_head+0x42>
80102cf9:	31 d2                	xor    %edx,%edx
80102cfb:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80102cff:	90                   	nop
    hb->block[i] = log.lh.block[i];
80102d00:	8b 0c 95 ec 26 21 80 	mov    -0x7fded914(,%edx,4),%ecx
80102d07:	89 4c 93 60          	mov    %ecx,0x60(%ebx,%edx,4)
  for (i = 0; i < log.lh.n; i++) {
80102d0b:	83 c2 01             	add    $0x1,%edx
80102d0e:	39 d0                	cmp    %edx,%eax
80102d10:	75 ee                	jne    80102d00 <write_head+0x30>
  }
  bwrite(buf);
80102d12:	83 ec 0c             	sub    $0xc,%esp
80102d15:	53                   	push   %ebx
80102d16:	e8 95 d4 ff ff       	call   801001b0 <bwrite>
  brelse(buf);
80102d1b:	89 1c 24             	mov    %ebx,(%esp)
80102d1e:	e8 cd d4 ff ff       	call   801001f0 <brelse>
}
80102d23:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80102d26:	83 c4 10             	add    $0x10,%esp
80102d29:	c9                   	leave  
80102d2a:	c3                   	ret    
80102d2b:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80102d2f:	90                   	nop

80102d30 <initlog>:
{
80102d30:	55                   	push   %ebp
80102d31:	89 e5                	mov    %esp,%ebp
80102d33:	53                   	push   %ebx
80102d34:	83 ec 2c             	sub    $0x2c,%esp
80102d37:	8b 5d 08             	mov    0x8(%ebp),%ebx
  initlock(&log.lock, "log");
80102d3a:	68 40 85 10 80       	push   $0x80108540
80102d3f:	68 a0 26 21 80       	push   $0x802126a0
80102d44:	e8 87 1c 00 00       	call   801049d0 <initlock>
  readsb(dev, &sb);
80102d49:	58                   	pop    %eax
80102d4a:	8d 45 dc             	lea    -0x24(%ebp),%eax
80102d4d:	5a                   	pop    %edx
80102d4e:	50                   	push   %eax
80102d4f:	53                   	push   %ebx
80102d50:	e8 db e7 ff ff       	call   80101530 <readsb>
  log.start = sb.logstart;
80102d55:	8b 45 ec             	mov    -0x14(%ebp),%eax
  struct buf *buf = bread(log.dev, log.start);
80102d58:	59                   	pop    %ecx
  log.dev = dev;
80102d59:	89 1d e4 26 21 80    	mov    %ebx,0x802126e4
  log.size = sb.nlog;
80102d5f:	8b 55 e8             	mov    -0x18(%ebp),%edx
  log.start = sb.logstart;
80102d62:	a3 d4 26 21 80       	mov    %eax,0x802126d4
  log.size = sb.nlog;
80102d67:	89 15 d8 26 21 80    	mov    %edx,0x802126d8
  struct buf *buf = bread(log.dev, log.start);
80102d6d:	5a                   	pop    %edx
80102d6e:	50                   	push   %eax
80102d6f:	53                   	push   %ebx
80102d70:	e8 5b d3 ff ff       	call   801000d0 <bread>
  for (i = 0; i < log.lh.n; i++) {
80102d75:	83 c4 10             	add    $0x10,%esp
  log.lh.n = lh->n;
80102d78:	8b 58 5c             	mov    0x5c(%eax),%ebx
80102d7b:	89 1d e8 26 21 80    	mov    %ebx,0x802126e8
  for (i = 0; i < log.lh.n; i++) {
80102d81:	85 db                	test   %ebx,%ebx
80102d83:	7e 1d                	jle    80102da2 <initlog+0x72>
80102d85:	31 d2                	xor    %edx,%edx
80102d87:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80102d8e:	66 90                	xchg   %ax,%ax
    log.lh.block[i] = lh->block[i];
80102d90:	8b 4c 90 60          	mov    0x60(%eax,%edx,4),%ecx
80102d94:	89 0c 95 ec 26 21 80 	mov    %ecx,-0x7fded914(,%edx,4)
  for (i = 0; i < log.lh.n; i++) {
80102d9b:	83 c2 01             	add    $0x1,%edx
80102d9e:	39 d3                	cmp    %edx,%ebx
80102da0:	75 ee                	jne    80102d90 <initlog+0x60>
  brelse(buf);
80102da2:	83 ec 0c             	sub    $0xc,%esp
80102da5:	50                   	push   %eax
80102da6:	e8 45 d4 ff ff       	call   801001f0 <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(); // if committed, copy from log to disk
80102dab:	e8 80 fe ff ff       	call   80102c30 <install_trans>
  log.lh.n = 0;
80102db0:	c7 05 e8 26 21 80 00 	movl   $0x0,0x802126e8
80102db7:	00 00 00 
  write_head(); // clear the log
80102dba:	e8 11 ff ff ff       	call   80102cd0 <write_head>
}
80102dbf:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80102dc2:	83 c4 10             	add    $0x10,%esp
80102dc5:	c9                   	leave  
80102dc6:	c3                   	ret    
80102dc7:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80102dce:	66 90                	xchg   %ax,%ax

80102dd0 <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
80102dd0:	55                   	push   %ebp
80102dd1:	89 e5                	mov    %esp,%ebp
80102dd3:	83 ec 14             	sub    $0x14,%esp
  acquire(&log.lock);
80102dd6:	68 a0 26 21 80       	push   $0x802126a0
80102ddb:	e8 c0 1d 00 00       	call   80104ba0 <acquire>
80102de0:	83 c4 10             	add    $0x10,%esp
80102de3:	eb 18                	jmp    80102dfd <begin_op+0x2d>
80102de5:	8d 76 00             	lea    0x0(%esi),%esi
  while(1){
    if(log.committing){
      sleep(&log, &log.lock);
80102de8:	83 ec 08             	sub    $0x8,%esp
80102deb:	68 a0 26 21 80       	push   $0x802126a0
80102df0:	68 a0 26 21 80       	push   $0x802126a0
80102df5:	e8 d6 16 00 00       	call   801044d0 <sleep>
80102dfa:	83 c4 10             	add    $0x10,%esp
    if(log.committing){
80102dfd:	a1 e0 26 21 80       	mov    0x802126e0,%eax
80102e02:	85 c0                	test   %eax,%eax
80102e04:	75 e2                	jne    80102de8 <begin_op+0x18>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
80102e06:	a1 dc 26 21 80       	mov    0x802126dc,%eax
80102e0b:	8b 15 e8 26 21 80    	mov    0x802126e8,%edx
80102e11:	83 c0 01             	add    $0x1,%eax
80102e14:	8d 0c 80             	lea    (%eax,%eax,4),%ecx
80102e17:	8d 14 4a             	lea    (%edx,%ecx,2),%edx
80102e1a:	83 fa 1e             	cmp    $0x1e,%edx
80102e1d:	7f c9                	jg     80102de8 <begin_op+0x18>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    } else {
      log.outstanding += 1;
      release(&log.lock);
80102e1f:	83 ec 0c             	sub    $0xc,%esp
      log.outstanding += 1;
80102e22:	a3 dc 26 21 80       	mov    %eax,0x802126dc
      release(&log.lock);
80102e27:	68 a0 26 21 80       	push   $0x802126a0
80102e2c:	e8 0f 1d 00 00       	call   80104b40 <release>
      break;
    }
  }
}
80102e31:	83 c4 10             	add    $0x10,%esp
80102e34:	c9                   	leave  
80102e35:	c3                   	ret    
80102e36:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80102e3d:	8d 76 00             	lea    0x0(%esi),%esi

80102e40 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
80102e40:	55                   	push   %ebp
80102e41:	89 e5                	mov    %esp,%ebp
80102e43:	57                   	push   %edi
80102e44:	56                   	push   %esi
80102e45:	53                   	push   %ebx
80102e46:	83 ec 18             	sub    $0x18,%esp
  int do_commit = 0;

  acquire(&log.lock);
80102e49:	68 a0 26 21 80       	push   $0x802126a0
80102e4e:	e8 4d 1d 00 00       	call   80104ba0 <acquire>
  log.outstanding -= 1;
80102e53:	a1 dc 26 21 80       	mov    0x802126dc,%eax
  if(log.committing)
80102e58:	8b 35 e0 26 21 80    	mov    0x802126e0,%esi
80102e5e:	83 c4 10             	add    $0x10,%esp
  log.outstanding -= 1;
80102e61:	8d 58 ff             	lea    -0x1(%eax),%ebx
80102e64:	89 1d dc 26 21 80    	mov    %ebx,0x802126dc
  if(log.committing)
80102e6a:	85 f6                	test   %esi,%esi
80102e6c:	0f 85 22 01 00 00    	jne    80102f94 <end_op+0x154>
    panic("log.committing");
  if(log.outstanding == 0){
80102e72:	85 db                	test   %ebx,%ebx
80102e74:	0f 85 f6 00 00 00    	jne    80102f70 <end_op+0x130>
    do_commit = 1;
    log.committing = 1;
80102e7a:	c7 05 e0 26 21 80 01 	movl   $0x1,0x802126e0
80102e81:	00 00 00 
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
80102e84:	83 ec 0c             	sub    $0xc,%esp
80102e87:	68 a0 26 21 80       	push   $0x802126a0
80102e8c:	e8 af 1c 00 00       	call   80104b40 <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
80102e91:	8b 0d e8 26 21 80    	mov    0x802126e8,%ecx
80102e97:	83 c4 10             	add    $0x10,%esp
80102e9a:	85 c9                	test   %ecx,%ecx
80102e9c:	7f 42                	jg     80102ee0 <end_op+0xa0>
    acquire(&log.lock);
80102e9e:	83 ec 0c             	sub    $0xc,%esp
80102ea1:	68 a0 26 21 80       	push   $0x802126a0
80102ea6:	e8 f5 1c 00 00       	call   80104ba0 <acquire>
    wakeup(&log);
80102eab:	c7 04 24 a0 26 21 80 	movl   $0x802126a0,(%esp)
    log.committing = 0;
80102eb2:	c7 05 e0 26 21 80 00 	movl   $0x0,0x802126e0
80102eb9:	00 00 00 
    wakeup(&log);
80102ebc:	e8 cf 16 00 00       	call   80104590 <wakeup>
    release(&log.lock);
80102ec1:	c7 04 24 a0 26 21 80 	movl   $0x802126a0,(%esp)
80102ec8:	e8 73 1c 00 00       	call   80104b40 <release>
80102ecd:	83 c4 10             	add    $0x10,%esp
}
80102ed0:	8d 65 f4             	lea    -0xc(%ebp),%esp
80102ed3:	5b                   	pop    %ebx
80102ed4:	5e                   	pop    %esi
80102ed5:	5f                   	pop    %edi
80102ed6:	5d                   	pop    %ebp
80102ed7:	c3                   	ret    
80102ed8:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80102edf:	90                   	nop
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
80102ee0:	a1 d4 26 21 80       	mov    0x802126d4,%eax
80102ee5:	83 ec 08             	sub    $0x8,%esp
80102ee8:	01 d8                	add    %ebx,%eax
80102eea:	83 c0 01             	add    $0x1,%eax
80102eed:	50                   	push   %eax
80102eee:	ff 35 e4 26 21 80    	push   0x802126e4
80102ef4:	e8 d7 d1 ff ff       	call   801000d0 <bread>
80102ef9:	89 c6                	mov    %eax,%esi
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
80102efb:	58                   	pop    %eax
80102efc:	5a                   	pop    %edx
80102efd:	ff 34 9d ec 26 21 80 	push   -0x7fded914(,%ebx,4)
80102f04:	ff 35 e4 26 21 80    	push   0x802126e4
  for (tail = 0; tail < log.lh.n; tail++) {
80102f0a:	83 c3 01             	add    $0x1,%ebx
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
80102f0d:	e8 be d1 ff ff       	call   801000d0 <bread>
    memmove(to->data, from->data, BSIZE);
80102f12:	83 c4 0c             	add    $0xc,%esp
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
80102f15:	89 c7                	mov    %eax,%edi
    memmove(to->data, from->data, BSIZE);
80102f17:	8d 40 5c             	lea    0x5c(%eax),%eax
80102f1a:	68 00 02 00 00       	push   $0x200
80102f1f:	50                   	push   %eax
80102f20:	8d 46 5c             	lea    0x5c(%esi),%eax
80102f23:	50                   	push   %eax
80102f24:	e8 d7 1d 00 00       	call   80104d00 <memmove>
    bwrite(to);  // write the log
80102f29:	89 34 24             	mov    %esi,(%esp)
80102f2c:	e8 7f d2 ff ff       	call   801001b0 <bwrite>
    brelse(from);
80102f31:	89 3c 24             	mov    %edi,(%esp)
80102f34:	e8 b7 d2 ff ff       	call   801001f0 <brelse>
    brelse(to);
80102f39:	89 34 24             	mov    %esi,(%esp)
80102f3c:	e8 af d2 ff ff       	call   801001f0 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
80102f41:	83 c4 10             	add    $0x10,%esp
80102f44:	3b 1d e8 26 21 80    	cmp    0x802126e8,%ebx
80102f4a:	7c 94                	jl     80102ee0 <end_op+0xa0>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
80102f4c:	e8 7f fd ff ff       	call   80102cd0 <write_head>
    install_trans(); // Now install writes to home locations
80102f51:	e8 da fc ff ff       	call   80102c30 <install_trans>
    log.lh.n = 0;
80102f56:	c7 05 e8 26 21 80 00 	movl   $0x0,0x802126e8
80102f5d:	00 00 00 
    write_head();    // Erase the transaction from the log
80102f60:	e8 6b fd ff ff       	call   80102cd0 <write_head>
80102f65:	e9 34 ff ff ff       	jmp    80102e9e <end_op+0x5e>
80102f6a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    wakeup(&log);
80102f70:	83 ec 0c             	sub    $0xc,%esp
80102f73:	68 a0 26 21 80       	push   $0x802126a0
80102f78:	e8 13 16 00 00       	call   80104590 <wakeup>
  release(&log.lock);
80102f7d:	c7 04 24 a0 26 21 80 	movl   $0x802126a0,(%esp)
80102f84:	e8 b7 1b 00 00       	call   80104b40 <release>
80102f89:	83 c4 10             	add    $0x10,%esp
}
80102f8c:	8d 65 f4             	lea    -0xc(%ebp),%esp
80102f8f:	5b                   	pop    %ebx
80102f90:	5e                   	pop    %esi
80102f91:	5f                   	pop    %edi
80102f92:	5d                   	pop    %ebp
80102f93:	c3                   	ret    
    panic("log.committing");
80102f94:	83 ec 0c             	sub    $0xc,%esp
80102f97:	68 44 85 10 80       	push   $0x80108544
80102f9c:	e8 df d3 ff ff       	call   80100380 <panic>
80102fa1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80102fa8:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80102faf:	90                   	nop

80102fb0 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
80102fb0:	55                   	push   %ebp
80102fb1:	89 e5                	mov    %esp,%ebp
80102fb3:	53                   	push   %ebx
80102fb4:	83 ec 04             	sub    $0x4,%esp
  int i;

  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
80102fb7:	8b 15 e8 26 21 80    	mov    0x802126e8,%edx
{
80102fbd:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
80102fc0:	83 fa 1d             	cmp    $0x1d,%edx
80102fc3:	0f 8f 85 00 00 00    	jg     8010304e <log_write+0x9e>
80102fc9:	a1 d8 26 21 80       	mov    0x802126d8,%eax
80102fce:	83 e8 01             	sub    $0x1,%eax
80102fd1:	39 c2                	cmp    %eax,%edx
80102fd3:	7d 79                	jge    8010304e <log_write+0x9e>
    panic("too big a transaction");
  if (log.outstanding < 1)
80102fd5:	a1 dc 26 21 80       	mov    0x802126dc,%eax
80102fda:	85 c0                	test   %eax,%eax
80102fdc:	7e 7d                	jle    8010305b <log_write+0xab>
    panic("log_write outside of trans");

  acquire(&log.lock);
80102fde:	83 ec 0c             	sub    $0xc,%esp
80102fe1:	68 a0 26 21 80       	push   $0x802126a0
80102fe6:	e8 b5 1b 00 00       	call   80104ba0 <acquire>
  for (i = 0; i < log.lh.n; i++) {
80102feb:	8b 15 e8 26 21 80    	mov    0x802126e8,%edx
80102ff1:	83 c4 10             	add    $0x10,%esp
80102ff4:	85 d2                	test   %edx,%edx
80102ff6:	7e 4a                	jle    80103042 <log_write+0x92>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
80102ff8:	8b 4b 08             	mov    0x8(%ebx),%ecx
  for (i = 0; i < log.lh.n; i++) {
80102ffb:	31 c0                	xor    %eax,%eax
80102ffd:	eb 08                	jmp    80103007 <log_write+0x57>
80102fff:	90                   	nop
80103000:	83 c0 01             	add    $0x1,%eax
80103003:	39 c2                	cmp    %eax,%edx
80103005:	74 29                	je     80103030 <log_write+0x80>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
80103007:	39 0c 85 ec 26 21 80 	cmp    %ecx,-0x7fded914(,%eax,4)
8010300e:	75 f0                	jne    80103000 <log_write+0x50>
      break;
  }
  log.lh.block[i] = b->blockno;
80103010:	89 0c 85 ec 26 21 80 	mov    %ecx,-0x7fded914(,%eax,4)
  if (i == log.lh.n)
    log.lh.n++;
  b->flags |= B_DIRTY; // prevent eviction
80103017:	83 0b 04             	orl    $0x4,(%ebx)
  release(&log.lock);
}
8010301a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  release(&log.lock);
8010301d:	c7 45 08 a0 26 21 80 	movl   $0x802126a0,0x8(%ebp)
}
80103024:	c9                   	leave  
  release(&log.lock);
80103025:	e9 16 1b 00 00       	jmp    80104b40 <release>
8010302a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  log.lh.block[i] = b->blockno;
80103030:	89 0c 95 ec 26 21 80 	mov    %ecx,-0x7fded914(,%edx,4)
    log.lh.n++;
80103037:	83 c2 01             	add    $0x1,%edx
8010303a:	89 15 e8 26 21 80    	mov    %edx,0x802126e8
80103040:	eb d5                	jmp    80103017 <log_write+0x67>
  log.lh.block[i] = b->blockno;
80103042:	8b 43 08             	mov    0x8(%ebx),%eax
80103045:	a3 ec 26 21 80       	mov    %eax,0x802126ec
  if (i == log.lh.n)
8010304a:	75 cb                	jne    80103017 <log_write+0x67>
8010304c:	eb e9                	jmp    80103037 <log_write+0x87>
    panic("too big a transaction");
8010304e:	83 ec 0c             	sub    $0xc,%esp
80103051:	68 53 85 10 80       	push   $0x80108553
80103056:	e8 25 d3 ff ff       	call   80100380 <panic>
    panic("log_write outside of trans");
8010305b:	83 ec 0c             	sub    $0xc,%esp
8010305e:	68 69 85 10 80       	push   $0x80108569
80103063:	e8 18 d3 ff ff       	call   80100380 <panic>
80103068:	66 90                	xchg   %ax,%ax
8010306a:	66 90                	xchg   %ax,%ax
8010306c:	66 90                	xchg   %ax,%ax
8010306e:	66 90                	xchg   %ax,%ax

80103070 <mpmain>:
}

// Common CPU setup code.
static void
mpmain(void)
{
80103070:	55                   	push   %ebp
80103071:	89 e5                	mov    %esp,%ebp
80103073:	53                   	push   %ebx
80103074:	83 ec 04             	sub    $0x4,%esp
  cprintf("cpu%d: starting %d\n", cpuid(), cpuid());
80103077:	e8 54 09 00 00       	call   801039d0 <cpuid>
8010307c:	89 c3                	mov    %eax,%ebx
8010307e:	e8 4d 09 00 00       	call   801039d0 <cpuid>
80103083:	83 ec 04             	sub    $0x4,%esp
80103086:	53                   	push   %ebx
80103087:	50                   	push   %eax
80103088:	68 84 85 10 80       	push   $0x80108584
8010308d:	e8 0e d6 ff ff       	call   801006a0 <cprintf>
  idtinit();       // load idt register
80103092:	e8 c9 32 00 00       	call   80106360 <idtinit>
  xchg(&(mycpu()->started), 1); // tell startothers() we're up
80103097:	e8 d4 08 00 00       	call   80103970 <mycpu>
8010309c:	89 c2                	mov    %eax,%edx
xchg(volatile uint *addr, uint newval)
{
  uint result;

  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
8010309e:	b8 01 00 00 00       	mov    $0x1,%eax
801030a3:	f0 87 82 a0 00 00 00 	lock xchg %eax,0xa0(%edx)
  scheduler();     // start running processes
801030aa:	e8 b1 0d 00 00       	call   80103e60 <scheduler>
801030af:	90                   	nop

801030b0 <mpenter>:
{
801030b0:	55                   	push   %ebp
801030b1:	89 e5                	mov    %esp,%ebp
801030b3:	83 ec 08             	sub    $0x8,%esp
  switchkvm();
801030b6:	e8 05 48 00 00       	call   801078c0 <switchkvm>
  seginit();
801030bb:	e8 f0 45 00 00       	call   801076b0 <seginit>
  lapicinit();
801030c0:	e8 9b f7 ff ff       	call   80102860 <lapicinit>
  mpmain();
801030c5:	e8 a6 ff ff ff       	call   80103070 <mpmain>
801030ca:	66 90                	xchg   %ax,%ax
801030cc:	66 90                	xchg   %ax,%ax
801030ce:	66 90                	xchg   %ax,%ax

801030d0 <main>:
{
801030d0:	8d 4c 24 04          	lea    0x4(%esp),%ecx
801030d4:	83 e4 f0             	and    $0xfffffff0,%esp
801030d7:	ff 71 fc             	push   -0x4(%ecx)
801030da:	55                   	push   %ebp
801030db:	89 e5                	mov    %esp,%ebp
801030dd:	53                   	push   %ebx
801030de:	51                   	push   %ecx
  kinit1(end, P2V(4*1024*1024)); // phys page allocator
801030df:	83 ec 08             	sub    $0x8,%esp
801030e2:	68 00 00 40 80       	push   $0x80400000
801030e7:	68 10 b6 21 80       	push   $0x8021b610
801030ec:	e8 8f f5 ff ff       	call   80102680 <kinit1>
  kvmalloc();      // kernel page table
801030f1:	e8 da 4c 00 00       	call   80107dd0 <kvmalloc>
  mpinit();        // detect other processors
801030f6:	e8 85 01 00 00       	call   80103280 <mpinit>
  lapicinit();     // interrupt controller
801030fb:	e8 60 f7 ff ff       	call   80102860 <lapicinit>
  seginit();       // segment descriptors
80103100:	e8 ab 45 00 00       	call   801076b0 <seginit>
  picinit();       // disable pic
80103105:	e8 76 03 00 00       	call   80103480 <picinit>
  ioapicinit();    // another interrupt controller
8010310a:	e8 d1 f2 ff ff       	call   801023e0 <ioapicinit>
  consoleinit();   // console hardware
8010310f:	e8 4c d9 ff ff       	call   80100a60 <consoleinit>
  uartinit();      // serial port
80103114:	e8 17 39 00 00       	call   80106a30 <uartinit>
  pinit();         // process table
80103119:	e8 32 08 00 00       	call   80103950 <pinit>
  tvinit();        // trap vectors
8010311e:	e8 bd 31 00 00       	call   801062e0 <tvinit>
  binit();         // buffer cache
80103123:	e8 18 cf ff ff       	call   80100040 <binit>
  fileinit();      // file table
80103128:	e8 f3 dc ff ff       	call   80100e20 <fileinit>
  ideinit();       // disk 
8010312d:	e8 9e f0 ff ff       	call   801021d0 <ideinit>

  // Write entry code to unused memory at 0x7000.
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = P2V(0x7000);
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);
80103132:	83 c4 0c             	add    $0xc,%esp
80103135:	68 8a 00 00 00       	push   $0x8a
8010313a:	68 8c b4 10 80       	push   $0x8010b48c
8010313f:	68 00 70 00 80       	push   $0x80007000
80103144:	e8 b7 1b 00 00       	call   80104d00 <memmove>

  for(c = cpus; c < cpus+ncpu; c++){
80103149:	83 c4 10             	add    $0x10,%esp
8010314c:	69 05 84 27 21 80 b0 	imul   $0xb0,0x80212784,%eax
80103153:	00 00 00 
80103156:	05 a0 27 21 80       	add    $0x802127a0,%eax
8010315b:	3d a0 27 21 80       	cmp    $0x802127a0,%eax
80103160:	76 7e                	jbe    801031e0 <main+0x110>
80103162:	bb a0 27 21 80       	mov    $0x802127a0,%ebx
80103167:	eb 20                	jmp    80103189 <main+0xb9>
80103169:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80103170:	69 05 84 27 21 80 b0 	imul   $0xb0,0x80212784,%eax
80103177:	00 00 00 
8010317a:	81 c3 b0 00 00 00    	add    $0xb0,%ebx
80103180:	05 a0 27 21 80       	add    $0x802127a0,%eax
80103185:	39 c3                	cmp    %eax,%ebx
80103187:	73 57                	jae    801031e0 <main+0x110>
    if(c == mycpu())  // We've started already.
80103189:	e8 e2 07 00 00       	call   80103970 <mycpu>
8010318e:	39 c3                	cmp    %eax,%ebx
80103190:	74 de                	je     80103170 <main+0xa0>
      continue;

    // Tell entryother.S what stack to use, where to enter, and what
    // pgdir to use. We cannot use kpgdir yet, because the AP processor
    // is running in low  memory, so we use entrypgdir for the APs too.
    stack = kalloc();
80103192:	e8 59 f5 ff ff       	call   801026f0 <kalloc>
    *(void**)(code-4) = stack + KSTACKSIZE;
    *(void(**)(void))(code-8) = mpenter;
    *(int**)(code-12) = (void *) V2P(entrypgdir);

    lapicstartap(c->apicid, V2P(code));
80103197:	83 ec 08             	sub    $0x8,%esp
    *(void(**)(void))(code-8) = mpenter;
8010319a:	c7 05 f8 6f 00 80 b0 	movl   $0x801030b0,0x80006ff8
801031a1:	30 10 80 
    *(int**)(code-12) = (void *) V2P(entrypgdir);
801031a4:	c7 05 f4 6f 00 80 00 	movl   $0x10a000,0x80006ff4
801031ab:	a0 10 00 
    *(void**)(code-4) = stack + KSTACKSIZE;
801031ae:	05 00 10 00 00       	add    $0x1000,%eax
801031b3:	a3 fc 6f 00 80       	mov    %eax,0x80006ffc
    lapicstartap(c->apicid, V2P(code));
801031b8:	0f b6 03             	movzbl (%ebx),%eax
801031bb:	68 00 70 00 00       	push   $0x7000
801031c0:	50                   	push   %eax
801031c1:	e8 ea f7 ff ff       	call   801029b0 <lapicstartap>

    // wait for cpu to finish mpmain()
    while(c->started == 0)
801031c6:	83 c4 10             	add    $0x10,%esp
801031c9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801031d0:	8b 83 a0 00 00 00    	mov    0xa0(%ebx),%eax
801031d6:	85 c0                	test   %eax,%eax
801031d8:	74 f6                	je     801031d0 <main+0x100>
801031da:	eb 94                	jmp    80103170 <main+0xa0>
801031dc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  kinit2(P2V(4*1024*1024), P2V(PHYSTOP)); // must come after startothers()
801031e0:	83 ec 08             	sub    $0x8,%esp
801031e3:	68 00 00 00 8e       	push   $0x8e000000
801031e8:	68 00 00 40 80       	push   $0x80400000
801031ed:	e8 2e f4 ff ff       	call   80102620 <kinit2>
  userinit();      // first user process
801031f2:	e8 29 08 00 00       	call   80103a20 <userinit>
  mpmain();        // finish this processor's setup
801031f7:	e8 74 fe ff ff       	call   80103070 <mpmain>
801031fc:	66 90                	xchg   %ax,%ax
801031fe:	66 90                	xchg   %ax,%ax

80103200 <mpsearch1>:
}

// Look for an MP structure in the len bytes at addr.
static struct mp*
mpsearch1(uint a, int len)
{
80103200:	55                   	push   %ebp
80103201:	89 e5                	mov    %esp,%ebp
80103203:	57                   	push   %edi
80103204:	56                   	push   %esi
  uchar *e, *p, *addr;

  addr = P2V(a);
80103205:	8d b0 00 00 00 80    	lea    -0x80000000(%eax),%esi
{
8010320b:	53                   	push   %ebx
  e = addr+len;
8010320c:	8d 1c 16             	lea    (%esi,%edx,1),%ebx
{
8010320f:	83 ec 0c             	sub    $0xc,%esp
  for(p = addr; p < e; p += sizeof(struct mp))
80103212:	39 de                	cmp    %ebx,%esi
80103214:	72 10                	jb     80103226 <mpsearch1+0x26>
80103216:	eb 50                	jmp    80103268 <mpsearch1+0x68>
80103218:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010321f:	90                   	nop
80103220:	89 fe                	mov    %edi,%esi
80103222:	39 fb                	cmp    %edi,%ebx
80103224:	76 42                	jbe    80103268 <mpsearch1+0x68>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
80103226:	83 ec 04             	sub    $0x4,%esp
80103229:	8d 7e 10             	lea    0x10(%esi),%edi
8010322c:	6a 04                	push   $0x4
8010322e:	68 98 85 10 80       	push   $0x80108598
80103233:	56                   	push   %esi
80103234:	e8 77 1a 00 00       	call   80104cb0 <memcmp>
80103239:	83 c4 10             	add    $0x10,%esp
8010323c:	85 c0                	test   %eax,%eax
8010323e:	75 e0                	jne    80103220 <mpsearch1+0x20>
80103240:	89 f2                	mov    %esi,%edx
80103242:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    sum += addr[i];
80103248:	0f b6 0a             	movzbl (%edx),%ecx
  for(i=0; i<len; i++)
8010324b:	83 c2 01             	add    $0x1,%edx
    sum += addr[i];
8010324e:	01 c8                	add    %ecx,%eax
  for(i=0; i<len; i++)
80103250:	39 fa                	cmp    %edi,%edx
80103252:	75 f4                	jne    80103248 <mpsearch1+0x48>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
80103254:	84 c0                	test   %al,%al
80103256:	75 c8                	jne    80103220 <mpsearch1+0x20>
      return (struct mp*)p;
  return 0;
}
80103258:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010325b:	89 f0                	mov    %esi,%eax
8010325d:	5b                   	pop    %ebx
8010325e:	5e                   	pop    %esi
8010325f:	5f                   	pop    %edi
80103260:	5d                   	pop    %ebp
80103261:	c3                   	ret    
80103262:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
80103268:	8d 65 f4             	lea    -0xc(%ebp),%esp
  return 0;
8010326b:	31 f6                	xor    %esi,%esi
}
8010326d:	5b                   	pop    %ebx
8010326e:	89 f0                	mov    %esi,%eax
80103270:	5e                   	pop    %esi
80103271:	5f                   	pop    %edi
80103272:	5d                   	pop    %ebp
80103273:	c3                   	ret    
80103274:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010327b:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
8010327f:	90                   	nop

80103280 <mpinit>:
  return conf;
}

void
mpinit(void)
{
80103280:	55                   	push   %ebp
80103281:	89 e5                	mov    %esp,%ebp
80103283:	57                   	push   %edi
80103284:	56                   	push   %esi
80103285:	53                   	push   %ebx
80103286:	83 ec 1c             	sub    $0x1c,%esp
  if((p = ((bda[0x0F]<<8)| bda[0x0E]) << 4)){
80103289:	0f b6 05 0f 04 00 80 	movzbl 0x8000040f,%eax
80103290:	0f b6 15 0e 04 00 80 	movzbl 0x8000040e,%edx
80103297:	c1 e0 08             	shl    $0x8,%eax
8010329a:	09 d0                	or     %edx,%eax
8010329c:	c1 e0 04             	shl    $0x4,%eax
8010329f:	75 1b                	jne    801032bc <mpinit+0x3c>
    p = ((bda[0x14]<<8)|bda[0x13])*1024;
801032a1:	0f b6 05 14 04 00 80 	movzbl 0x80000414,%eax
801032a8:	0f b6 15 13 04 00 80 	movzbl 0x80000413,%edx
801032af:	c1 e0 08             	shl    $0x8,%eax
801032b2:	09 d0                	or     %edx,%eax
801032b4:	c1 e0 0a             	shl    $0xa,%eax
    if((mp = mpsearch1(p-1024, 1024)))
801032b7:	2d 00 04 00 00       	sub    $0x400,%eax
    if((mp = mpsearch1(p, 1024)))
801032bc:	ba 00 04 00 00       	mov    $0x400,%edx
801032c1:	e8 3a ff ff ff       	call   80103200 <mpsearch1>
801032c6:	89 c3                	mov    %eax,%ebx
801032c8:	85 c0                	test   %eax,%eax
801032ca:	0f 84 40 01 00 00    	je     80103410 <mpinit+0x190>
  if((mp = mpsearch()) == 0 || mp->physaddr == 0)
801032d0:	8b 73 04             	mov    0x4(%ebx),%esi
801032d3:	85 f6                	test   %esi,%esi
801032d5:	0f 84 25 01 00 00    	je     80103400 <mpinit+0x180>
  if(memcmp(conf, "PCMP", 4) != 0)
801032db:	83 ec 04             	sub    $0x4,%esp
  conf = (struct mpconf*) P2V((uint) mp->physaddr);
801032de:	8d 86 00 00 00 80    	lea    -0x80000000(%esi),%eax
  if(memcmp(conf, "PCMP", 4) != 0)
801032e4:	6a 04                	push   $0x4
801032e6:	68 9d 85 10 80       	push   $0x8010859d
801032eb:	50                   	push   %eax
  conf = (struct mpconf*) P2V((uint) mp->physaddr);
801032ec:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  if(memcmp(conf, "PCMP", 4) != 0)
801032ef:	e8 bc 19 00 00       	call   80104cb0 <memcmp>
801032f4:	83 c4 10             	add    $0x10,%esp
801032f7:	85 c0                	test   %eax,%eax
801032f9:	0f 85 01 01 00 00    	jne    80103400 <mpinit+0x180>
  if(conf->version != 1 && conf->version != 4)
801032ff:	0f b6 86 06 00 00 80 	movzbl -0x7ffffffa(%esi),%eax
80103306:	3c 01                	cmp    $0x1,%al
80103308:	74 08                	je     80103312 <mpinit+0x92>
8010330a:	3c 04                	cmp    $0x4,%al
8010330c:	0f 85 ee 00 00 00    	jne    80103400 <mpinit+0x180>
  if(sum((uchar*)conf, conf->length) != 0)
80103312:	0f b7 96 04 00 00 80 	movzwl -0x7ffffffc(%esi),%edx
  for(i=0; i<len; i++)
80103319:	66 85 d2             	test   %dx,%dx
8010331c:	74 22                	je     80103340 <mpinit+0xc0>
8010331e:	8d 3c 32             	lea    (%edx,%esi,1),%edi
80103321:	89 f0                	mov    %esi,%eax
  sum = 0;
80103323:	31 d2                	xor    %edx,%edx
80103325:	8d 76 00             	lea    0x0(%esi),%esi
    sum += addr[i];
80103328:	0f b6 88 00 00 00 80 	movzbl -0x80000000(%eax),%ecx
  for(i=0; i<len; i++)
8010332f:	83 c0 01             	add    $0x1,%eax
    sum += addr[i];
80103332:	01 ca                	add    %ecx,%edx
  for(i=0; i<len; i++)
80103334:	39 c7                	cmp    %eax,%edi
80103336:	75 f0                	jne    80103328 <mpinit+0xa8>
  if(sum((uchar*)conf, conf->length) != 0)
80103338:	84 d2                	test   %dl,%dl
8010333a:	0f 85 c0 00 00 00    	jne    80103400 <mpinit+0x180>
  struct mpioapic *ioapic;

  if((conf = mpconfig(&mp)) == 0)
    panic("Expect to run on an SMP");
  ismp = 1;
  lapic = (uint*)conf->lapicaddr;
80103340:	8b 86 24 00 00 80    	mov    -0x7fffffdc(%esi),%eax
80103346:	a3 84 26 21 80       	mov    %eax,0x80212684
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
8010334b:	0f b7 96 04 00 00 80 	movzwl -0x7ffffffc(%esi),%edx
80103352:	8d 86 2c 00 00 80    	lea    -0x7fffffd4(%esi),%eax
  ismp = 1;
80103358:	be 01 00 00 00       	mov    $0x1,%esi
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
8010335d:	03 55 e4             	add    -0x1c(%ebp),%edx
80103360:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
80103363:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80103367:	90                   	nop
80103368:	39 d0                	cmp    %edx,%eax
8010336a:	73 15                	jae    80103381 <mpinit+0x101>
    switch(*p){
8010336c:	0f b6 08             	movzbl (%eax),%ecx
8010336f:	80 f9 02             	cmp    $0x2,%cl
80103372:	74 4c                	je     801033c0 <mpinit+0x140>
80103374:	77 3a                	ja     801033b0 <mpinit+0x130>
80103376:	84 c9                	test   %cl,%cl
80103378:	74 56                	je     801033d0 <mpinit+0x150>
      p += sizeof(struct mpioapic);
      continue;
    case MPBUS:
    case MPIOINTR:
    case MPLINTR:
      p += 8;
8010337a:	83 c0 08             	add    $0x8,%eax
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
8010337d:	39 d0                	cmp    %edx,%eax
8010337f:	72 eb                	jb     8010336c <mpinit+0xec>
    default:
      ismp = 0;
      break;
    }
  }
  if(!ismp)
80103381:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
80103384:	85 f6                	test   %esi,%esi
80103386:	0f 84 d9 00 00 00    	je     80103465 <mpinit+0x1e5>
    panic("Didn't find a suitable machine");

  if(mp->imcrp){
8010338c:	80 7b 0c 00          	cmpb   $0x0,0xc(%ebx)
80103390:	74 15                	je     801033a7 <mpinit+0x127>
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80103392:	b8 70 00 00 00       	mov    $0x70,%eax
80103397:	ba 22 00 00 00       	mov    $0x22,%edx
8010339c:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
8010339d:	ba 23 00 00 00       	mov    $0x23,%edx
801033a2:	ec                   	in     (%dx),%al
    // Bochs doesn't support IMCR, so this doesn't run on Bochs.
    // But it would on real hardware.
    outb(0x22, 0x70);   // Select IMCR
    outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
801033a3:	83 c8 01             	or     $0x1,%eax
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801033a6:	ee                   	out    %al,(%dx)
  }
}
801033a7:	8d 65 f4             	lea    -0xc(%ebp),%esp
801033aa:	5b                   	pop    %ebx
801033ab:	5e                   	pop    %esi
801033ac:	5f                   	pop    %edi
801033ad:	5d                   	pop    %ebp
801033ae:	c3                   	ret    
801033af:	90                   	nop
    switch(*p){
801033b0:	83 e9 03             	sub    $0x3,%ecx
801033b3:	80 f9 01             	cmp    $0x1,%cl
801033b6:	76 c2                	jbe    8010337a <mpinit+0xfa>
801033b8:	31 f6                	xor    %esi,%esi
801033ba:	eb ac                	jmp    80103368 <mpinit+0xe8>
801033bc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
      ioapicid = ioapic->apicno;
801033c0:	0f b6 48 01          	movzbl 0x1(%eax),%ecx
      p += sizeof(struct mpioapic);
801033c4:	83 c0 08             	add    $0x8,%eax
      ioapicid = ioapic->apicno;
801033c7:	88 0d 80 27 21 80    	mov    %cl,0x80212780
      continue;
801033cd:	eb 99                	jmp    80103368 <mpinit+0xe8>
801033cf:	90                   	nop
      if(ncpu < NCPU) {
801033d0:	8b 0d 84 27 21 80    	mov    0x80212784,%ecx
801033d6:	83 f9 07             	cmp    $0x7,%ecx
801033d9:	7f 19                	jg     801033f4 <mpinit+0x174>
        cpus[ncpu].apicid = proc->apicid;  // apicid may differ from ncpu
801033db:	69 f9 b0 00 00 00    	imul   $0xb0,%ecx,%edi
801033e1:	0f b6 58 01          	movzbl 0x1(%eax),%ebx
        ncpu++;
801033e5:	83 c1 01             	add    $0x1,%ecx
801033e8:	89 0d 84 27 21 80    	mov    %ecx,0x80212784
        cpus[ncpu].apicid = proc->apicid;  // apicid may differ from ncpu
801033ee:	88 9f a0 27 21 80    	mov    %bl,-0x7fded860(%edi)
      p += sizeof(struct mpproc);
801033f4:	83 c0 14             	add    $0x14,%eax
      continue;
801033f7:	e9 6c ff ff ff       	jmp    80103368 <mpinit+0xe8>
801033fc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    panic("Expect to run on an SMP");
80103400:	83 ec 0c             	sub    $0xc,%esp
80103403:	68 a2 85 10 80       	push   $0x801085a2
80103408:	e8 73 cf ff ff       	call   80100380 <panic>
8010340d:	8d 76 00             	lea    0x0(%esi),%esi
{
80103410:	bb 00 00 0f 80       	mov    $0x800f0000,%ebx
80103415:	eb 13                	jmp    8010342a <mpinit+0x1aa>
80103417:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010341e:	66 90                	xchg   %ax,%ax
  for(p = addr; p < e; p += sizeof(struct mp))
80103420:	89 f3                	mov    %esi,%ebx
80103422:	81 fe 00 00 10 80    	cmp    $0x80100000,%esi
80103428:	74 d6                	je     80103400 <mpinit+0x180>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
8010342a:	83 ec 04             	sub    $0x4,%esp
8010342d:	8d 73 10             	lea    0x10(%ebx),%esi
80103430:	6a 04                	push   $0x4
80103432:	68 98 85 10 80       	push   $0x80108598
80103437:	53                   	push   %ebx
80103438:	e8 73 18 00 00       	call   80104cb0 <memcmp>
8010343d:	83 c4 10             	add    $0x10,%esp
80103440:	85 c0                	test   %eax,%eax
80103442:	75 dc                	jne    80103420 <mpinit+0x1a0>
80103444:	89 da                	mov    %ebx,%edx
80103446:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010344d:	8d 76 00             	lea    0x0(%esi),%esi
    sum += addr[i];
80103450:	0f b6 0a             	movzbl (%edx),%ecx
  for(i=0; i<len; i++)
80103453:	83 c2 01             	add    $0x1,%edx
    sum += addr[i];
80103456:	01 c8                	add    %ecx,%eax
  for(i=0; i<len; i++)
80103458:	39 d6                	cmp    %edx,%esi
8010345a:	75 f4                	jne    80103450 <mpinit+0x1d0>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
8010345c:	84 c0                	test   %al,%al
8010345e:	75 c0                	jne    80103420 <mpinit+0x1a0>
80103460:	e9 6b fe ff ff       	jmp    801032d0 <mpinit+0x50>
    panic("Didn't find a suitable machine");
80103465:	83 ec 0c             	sub    $0xc,%esp
80103468:	68 bc 85 10 80       	push   $0x801085bc
8010346d:	e8 0e cf ff ff       	call   80100380 <panic>
80103472:	66 90                	xchg   %ax,%ax
80103474:	66 90                	xchg   %ax,%ax
80103476:	66 90                	xchg   %ax,%ax
80103478:	66 90                	xchg   %ax,%ax
8010347a:	66 90                	xchg   %ax,%ax
8010347c:	66 90                	xchg   %ax,%ax
8010347e:	66 90                	xchg   %ax,%ax

80103480 <picinit>:
80103480:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103485:	ba 21 00 00 00       	mov    $0x21,%edx
8010348a:	ee                   	out    %al,(%dx)
8010348b:	ba a1 00 00 00       	mov    $0xa1,%edx
80103490:	ee                   	out    %al,(%dx)
picinit(void)
{
  // mask all interrupts
  outb(IO_PIC1+1, 0xFF);
  outb(IO_PIC2+1, 0xFF);
}
80103491:	c3                   	ret    
80103492:	66 90                	xchg   %ax,%ax
80103494:	66 90                	xchg   %ax,%ax
80103496:	66 90                	xchg   %ax,%ax
80103498:	66 90                	xchg   %ax,%ax
8010349a:	66 90                	xchg   %ax,%ax
8010349c:	66 90                	xchg   %ax,%ax
8010349e:	66 90                	xchg   %ax,%ax

801034a0 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
801034a0:	55                   	push   %ebp
801034a1:	89 e5                	mov    %esp,%ebp
801034a3:	57                   	push   %edi
801034a4:	56                   	push   %esi
801034a5:	53                   	push   %ebx
801034a6:	83 ec 0c             	sub    $0xc,%esp
801034a9:	8b 5d 08             	mov    0x8(%ebp),%ebx
801034ac:	8b 75 0c             	mov    0xc(%ebp),%esi
  struct pipe *p;

  p = 0;
  *f0 = *f1 = 0;
801034af:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
801034b5:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
801034bb:	e8 80 d9 ff ff       	call   80100e40 <filealloc>
801034c0:	89 03                	mov    %eax,(%ebx)
801034c2:	85 c0                	test   %eax,%eax
801034c4:	0f 84 a8 00 00 00    	je     80103572 <pipealloc+0xd2>
801034ca:	e8 71 d9 ff ff       	call   80100e40 <filealloc>
801034cf:	89 06                	mov    %eax,(%esi)
801034d1:	85 c0                	test   %eax,%eax
801034d3:	0f 84 87 00 00 00    	je     80103560 <pipealloc+0xc0>
    goto bad;
  if((p = (struct pipe*)kalloc()) == 0)
801034d9:	e8 12 f2 ff ff       	call   801026f0 <kalloc>
801034de:	89 c7                	mov    %eax,%edi
801034e0:	85 c0                	test   %eax,%eax
801034e2:	0f 84 b0 00 00 00    	je     80103598 <pipealloc+0xf8>
    goto bad;
  p->readopen = 1;
801034e8:	c7 80 3c 02 00 00 01 	movl   $0x1,0x23c(%eax)
801034ef:	00 00 00 
  p->writeopen = 1;
  p->nwrite = 0;
  p->nread = 0;
  initlock(&p->lock, "pipe");
801034f2:	83 ec 08             	sub    $0x8,%esp
  p->writeopen = 1;
801034f5:	c7 80 40 02 00 00 01 	movl   $0x1,0x240(%eax)
801034fc:	00 00 00 
  p->nwrite = 0;
801034ff:	c7 80 38 02 00 00 00 	movl   $0x0,0x238(%eax)
80103506:	00 00 00 
  p->nread = 0;
80103509:	c7 80 34 02 00 00 00 	movl   $0x0,0x234(%eax)
80103510:	00 00 00 
  initlock(&p->lock, "pipe");
80103513:	68 db 85 10 80       	push   $0x801085db
80103518:	50                   	push   %eax
80103519:	e8 b2 14 00 00       	call   801049d0 <initlock>
  (*f0)->type = FD_PIPE;
8010351e:	8b 03                	mov    (%ebx),%eax
  (*f0)->pipe = p;
  (*f1)->type = FD_PIPE;
  (*f1)->readable = 0;
  (*f1)->writable = 1;
  (*f1)->pipe = p;
  return 0;
80103520:	83 c4 10             	add    $0x10,%esp
  (*f0)->type = FD_PIPE;
80103523:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f0)->readable = 1;
80103529:	8b 03                	mov    (%ebx),%eax
8010352b:	c6 40 08 01          	movb   $0x1,0x8(%eax)
  (*f0)->writable = 0;
8010352f:	8b 03                	mov    (%ebx),%eax
80103531:	c6 40 09 00          	movb   $0x0,0x9(%eax)
  (*f0)->pipe = p;
80103535:	8b 03                	mov    (%ebx),%eax
80103537:	89 78 0c             	mov    %edi,0xc(%eax)
  (*f1)->type = FD_PIPE;
8010353a:	8b 06                	mov    (%esi),%eax
8010353c:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f1)->readable = 0;
80103542:	8b 06                	mov    (%esi),%eax
80103544:	c6 40 08 00          	movb   $0x0,0x8(%eax)
  (*f1)->writable = 1;
80103548:	8b 06                	mov    (%esi),%eax
8010354a:	c6 40 09 01          	movb   $0x1,0x9(%eax)
  (*f1)->pipe = p;
8010354e:	8b 06                	mov    (%esi),%eax
80103550:	89 78 0c             	mov    %edi,0xc(%eax)
  if(*f0)
    fileclose(*f0);
  if(*f1)
    fileclose(*f1);
  return -1;
}
80103553:	8d 65 f4             	lea    -0xc(%ebp),%esp
  return 0;
80103556:	31 c0                	xor    %eax,%eax
}
80103558:	5b                   	pop    %ebx
80103559:	5e                   	pop    %esi
8010355a:	5f                   	pop    %edi
8010355b:	5d                   	pop    %ebp
8010355c:	c3                   	ret    
8010355d:	8d 76 00             	lea    0x0(%esi),%esi
  if(*f0)
80103560:	8b 03                	mov    (%ebx),%eax
80103562:	85 c0                	test   %eax,%eax
80103564:	74 1e                	je     80103584 <pipealloc+0xe4>
    fileclose(*f0);
80103566:	83 ec 0c             	sub    $0xc,%esp
80103569:	50                   	push   %eax
8010356a:	e8 91 d9 ff ff       	call   80100f00 <fileclose>
8010356f:	83 c4 10             	add    $0x10,%esp
  if(*f1)
80103572:	8b 06                	mov    (%esi),%eax
80103574:	85 c0                	test   %eax,%eax
80103576:	74 0c                	je     80103584 <pipealloc+0xe4>
    fileclose(*f1);
80103578:	83 ec 0c             	sub    $0xc,%esp
8010357b:	50                   	push   %eax
8010357c:	e8 7f d9 ff ff       	call   80100f00 <fileclose>
80103581:	83 c4 10             	add    $0x10,%esp
}
80103584:	8d 65 f4             	lea    -0xc(%ebp),%esp
  return -1;
80103587:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010358c:	5b                   	pop    %ebx
8010358d:	5e                   	pop    %esi
8010358e:	5f                   	pop    %edi
8010358f:	5d                   	pop    %ebp
80103590:	c3                   	ret    
80103591:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  if(*f0)
80103598:	8b 03                	mov    (%ebx),%eax
8010359a:	85 c0                	test   %eax,%eax
8010359c:	75 c8                	jne    80103566 <pipealloc+0xc6>
8010359e:	eb d2                	jmp    80103572 <pipealloc+0xd2>

801035a0 <pipeclose>:

void
pipeclose(struct pipe *p, int writable)
{
801035a0:	55                   	push   %ebp
801035a1:	89 e5                	mov    %esp,%ebp
801035a3:	56                   	push   %esi
801035a4:	53                   	push   %ebx
801035a5:	8b 5d 08             	mov    0x8(%ebp),%ebx
801035a8:	8b 75 0c             	mov    0xc(%ebp),%esi
  acquire(&p->lock);
801035ab:	83 ec 0c             	sub    $0xc,%esp
801035ae:	53                   	push   %ebx
801035af:	e8 ec 15 00 00       	call   80104ba0 <acquire>
  if(writable){
801035b4:	83 c4 10             	add    $0x10,%esp
801035b7:	85 f6                	test   %esi,%esi
801035b9:	74 65                	je     80103620 <pipeclose+0x80>
    p->writeopen = 0;
    wakeup(&p->nread);
801035bb:	83 ec 0c             	sub    $0xc,%esp
801035be:	8d 83 34 02 00 00    	lea    0x234(%ebx),%eax
    p->writeopen = 0;
801035c4:	c7 83 40 02 00 00 00 	movl   $0x0,0x240(%ebx)
801035cb:	00 00 00 
    wakeup(&p->nread);
801035ce:	50                   	push   %eax
801035cf:	e8 bc 0f 00 00       	call   80104590 <wakeup>
801035d4:	83 c4 10             	add    $0x10,%esp
  } else {
    p->readopen = 0;
    wakeup(&p->nwrite);
  }
  if(p->readopen == 0 && p->writeopen == 0){
801035d7:	8b 93 3c 02 00 00    	mov    0x23c(%ebx),%edx
801035dd:	85 d2                	test   %edx,%edx
801035df:	75 0a                	jne    801035eb <pipeclose+0x4b>
801035e1:	8b 83 40 02 00 00    	mov    0x240(%ebx),%eax
801035e7:	85 c0                	test   %eax,%eax
801035e9:	74 15                	je     80103600 <pipeclose+0x60>
    release(&p->lock);
    kfree((char*)p);
  } else
    release(&p->lock);
801035eb:	89 5d 08             	mov    %ebx,0x8(%ebp)
}
801035ee:	8d 65 f8             	lea    -0x8(%ebp),%esp
801035f1:	5b                   	pop    %ebx
801035f2:	5e                   	pop    %esi
801035f3:	5d                   	pop    %ebp
    release(&p->lock);
801035f4:	e9 47 15 00 00       	jmp    80104b40 <release>
801035f9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    release(&p->lock);
80103600:	83 ec 0c             	sub    $0xc,%esp
80103603:	53                   	push   %ebx
80103604:	e8 37 15 00 00       	call   80104b40 <release>
    kfree((char*)p);
80103609:	89 5d 08             	mov    %ebx,0x8(%ebp)
8010360c:	83 c4 10             	add    $0x10,%esp
}
8010360f:	8d 65 f8             	lea    -0x8(%ebp),%esp
80103612:	5b                   	pop    %ebx
80103613:	5e                   	pop    %esi
80103614:	5d                   	pop    %ebp
    kfree((char*)p);
80103615:	e9 16 ef ff ff       	jmp    80102530 <kfree>
8010361a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    wakeup(&p->nwrite);
80103620:	83 ec 0c             	sub    $0xc,%esp
80103623:	8d 83 38 02 00 00    	lea    0x238(%ebx),%eax
    p->readopen = 0;
80103629:	c7 83 3c 02 00 00 00 	movl   $0x0,0x23c(%ebx)
80103630:	00 00 00 
    wakeup(&p->nwrite);
80103633:	50                   	push   %eax
80103634:	e8 57 0f 00 00       	call   80104590 <wakeup>
80103639:	83 c4 10             	add    $0x10,%esp
8010363c:	eb 99                	jmp    801035d7 <pipeclose+0x37>
8010363e:	66 90                	xchg   %ax,%ax

80103640 <pipewrite>:

//PAGEBREAK: 40
int
pipewrite(struct pipe *p, char *addr, int n)
{
80103640:	55                   	push   %ebp
80103641:	89 e5                	mov    %esp,%ebp
80103643:	57                   	push   %edi
80103644:	56                   	push   %esi
80103645:	53                   	push   %ebx
80103646:	83 ec 28             	sub    $0x28,%esp
80103649:	8b 5d 08             	mov    0x8(%ebp),%ebx
  int i;

  acquire(&p->lock);
8010364c:	53                   	push   %ebx
8010364d:	e8 4e 15 00 00       	call   80104ba0 <acquire>
  for(i = 0; i < n; i++){
80103652:	8b 45 10             	mov    0x10(%ebp),%eax
80103655:	83 c4 10             	add    $0x10,%esp
80103658:	85 c0                	test   %eax,%eax
8010365a:	0f 8e c0 00 00 00    	jle    80103720 <pipewrite+0xe0>
80103660:	8b 45 0c             	mov    0xc(%ebp),%eax
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
80103663:	8b 8b 38 02 00 00    	mov    0x238(%ebx),%ecx
      if(p->readopen == 0 || myproc()->killed){
        release(&p->lock);
        return -1;
      }
      wakeup(&p->nread);
80103669:	8d bb 34 02 00 00    	lea    0x234(%ebx),%edi
8010366f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80103672:	03 45 10             	add    0x10(%ebp),%eax
80103675:	89 45 e0             	mov    %eax,-0x20(%ebp)
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
80103678:	8b 83 34 02 00 00    	mov    0x234(%ebx),%eax
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
8010367e:	8d b3 38 02 00 00    	lea    0x238(%ebx),%esi
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
80103684:	89 ca                	mov    %ecx,%edx
80103686:	05 00 02 00 00       	add    $0x200,%eax
8010368b:	39 c1                	cmp    %eax,%ecx
8010368d:	74 3f                	je     801036ce <pipewrite+0x8e>
8010368f:	eb 67                	jmp    801036f8 <pipewrite+0xb8>
80103691:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
      if(p->readopen == 0 || myproc()->killed){
80103698:	e8 53 03 00 00       	call   801039f0 <myproc>
8010369d:	8b 48 24             	mov    0x24(%eax),%ecx
801036a0:	85 c9                	test   %ecx,%ecx
801036a2:	75 34                	jne    801036d8 <pipewrite+0x98>
      wakeup(&p->nread);
801036a4:	83 ec 0c             	sub    $0xc,%esp
801036a7:	57                   	push   %edi
801036a8:	e8 e3 0e 00 00       	call   80104590 <wakeup>
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
801036ad:	58                   	pop    %eax
801036ae:	5a                   	pop    %edx
801036af:	53                   	push   %ebx
801036b0:	56                   	push   %esi
801036b1:	e8 1a 0e 00 00       	call   801044d0 <sleep>
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
801036b6:	8b 83 34 02 00 00    	mov    0x234(%ebx),%eax
801036bc:	8b 93 38 02 00 00    	mov    0x238(%ebx),%edx
801036c2:	83 c4 10             	add    $0x10,%esp
801036c5:	05 00 02 00 00       	add    $0x200,%eax
801036ca:	39 c2                	cmp    %eax,%edx
801036cc:	75 2a                	jne    801036f8 <pipewrite+0xb8>
      if(p->readopen == 0 || myproc()->killed){
801036ce:	8b 83 3c 02 00 00    	mov    0x23c(%ebx),%eax
801036d4:	85 c0                	test   %eax,%eax
801036d6:	75 c0                	jne    80103698 <pipewrite+0x58>
        release(&p->lock);
801036d8:	83 ec 0c             	sub    $0xc,%esp
801036db:	53                   	push   %ebx
801036dc:	e8 5f 14 00 00       	call   80104b40 <release>
        return -1;
801036e1:	83 c4 10             	add    $0x10,%esp
801036e4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
  }
  wakeup(&p->nread);  //DOC: pipewrite-wakeup1
  release(&p->lock);
  return n;
}
801036e9:	8d 65 f4             	lea    -0xc(%ebp),%esp
801036ec:	5b                   	pop    %ebx
801036ed:	5e                   	pop    %esi
801036ee:	5f                   	pop    %edi
801036ef:	5d                   	pop    %ebp
801036f0:	c3                   	ret    
801036f1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
801036f8:	8b 75 e4             	mov    -0x1c(%ebp),%esi
801036fb:	8d 4a 01             	lea    0x1(%edx),%ecx
801036fe:	81 e2 ff 01 00 00    	and    $0x1ff,%edx
80103704:	89 8b 38 02 00 00    	mov    %ecx,0x238(%ebx)
8010370a:	0f b6 06             	movzbl (%esi),%eax
  for(i = 0; i < n; i++){
8010370d:	83 c6 01             	add    $0x1,%esi
80103710:	89 75 e4             	mov    %esi,-0x1c(%ebp)
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
80103713:	88 44 13 34          	mov    %al,0x34(%ebx,%edx,1)
  for(i = 0; i < n; i++){
80103717:	3b 75 e0             	cmp    -0x20(%ebp),%esi
8010371a:	0f 85 58 ff ff ff    	jne    80103678 <pipewrite+0x38>
  wakeup(&p->nread);  //DOC: pipewrite-wakeup1
80103720:	83 ec 0c             	sub    $0xc,%esp
80103723:	8d 83 34 02 00 00    	lea    0x234(%ebx),%eax
80103729:	50                   	push   %eax
8010372a:	e8 61 0e 00 00       	call   80104590 <wakeup>
  release(&p->lock);
8010372f:	89 1c 24             	mov    %ebx,(%esp)
80103732:	e8 09 14 00 00       	call   80104b40 <release>
  return n;
80103737:	8b 45 10             	mov    0x10(%ebp),%eax
8010373a:	83 c4 10             	add    $0x10,%esp
8010373d:	eb aa                	jmp    801036e9 <pipewrite+0xa9>
8010373f:	90                   	nop

80103740 <piperead>:

int
piperead(struct pipe *p, char *addr, int n)
{
80103740:	55                   	push   %ebp
80103741:	89 e5                	mov    %esp,%ebp
80103743:	57                   	push   %edi
80103744:	56                   	push   %esi
80103745:	53                   	push   %ebx
80103746:	83 ec 18             	sub    $0x18,%esp
80103749:	8b 75 08             	mov    0x8(%ebp),%esi
8010374c:	8b 7d 0c             	mov    0xc(%ebp),%edi
  int i;

  acquire(&p->lock);
8010374f:	56                   	push   %esi
80103750:	8d 9e 34 02 00 00    	lea    0x234(%esi),%ebx
80103756:	e8 45 14 00 00       	call   80104ba0 <acquire>
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
8010375b:	8b 86 34 02 00 00    	mov    0x234(%esi),%eax
80103761:	83 c4 10             	add    $0x10,%esp
80103764:	39 86 38 02 00 00    	cmp    %eax,0x238(%esi)
8010376a:	74 2f                	je     8010379b <piperead+0x5b>
8010376c:	eb 37                	jmp    801037a5 <piperead+0x65>
8010376e:	66 90                	xchg   %ax,%ax
    if(myproc()->killed){
80103770:	e8 7b 02 00 00       	call   801039f0 <myproc>
80103775:	8b 48 24             	mov    0x24(%eax),%ecx
80103778:	85 c9                	test   %ecx,%ecx
8010377a:	0f 85 80 00 00 00    	jne    80103800 <piperead+0xc0>
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
80103780:	83 ec 08             	sub    $0x8,%esp
80103783:	56                   	push   %esi
80103784:	53                   	push   %ebx
80103785:	e8 46 0d 00 00       	call   801044d0 <sleep>
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
8010378a:	8b 86 38 02 00 00    	mov    0x238(%esi),%eax
80103790:	83 c4 10             	add    $0x10,%esp
80103793:	39 86 34 02 00 00    	cmp    %eax,0x234(%esi)
80103799:	75 0a                	jne    801037a5 <piperead+0x65>
8010379b:	8b 86 40 02 00 00    	mov    0x240(%esi),%eax
801037a1:	85 c0                	test   %eax,%eax
801037a3:	75 cb                	jne    80103770 <piperead+0x30>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
801037a5:	8b 55 10             	mov    0x10(%ebp),%edx
801037a8:	31 db                	xor    %ebx,%ebx
801037aa:	85 d2                	test   %edx,%edx
801037ac:	7f 20                	jg     801037ce <piperead+0x8e>
801037ae:	eb 2c                	jmp    801037dc <piperead+0x9c>
    if(p->nread == p->nwrite)
      break;
    addr[i] = p->data[p->nread++ % PIPESIZE];
801037b0:	8d 48 01             	lea    0x1(%eax),%ecx
801037b3:	25 ff 01 00 00       	and    $0x1ff,%eax
801037b8:	89 8e 34 02 00 00    	mov    %ecx,0x234(%esi)
801037be:	0f b6 44 06 34       	movzbl 0x34(%esi,%eax,1),%eax
801037c3:	88 04 1f             	mov    %al,(%edi,%ebx,1)
  for(i = 0; i < n; i++){  //DOC: piperead-copy
801037c6:	83 c3 01             	add    $0x1,%ebx
801037c9:	39 5d 10             	cmp    %ebx,0x10(%ebp)
801037cc:	74 0e                	je     801037dc <piperead+0x9c>
    if(p->nread == p->nwrite)
801037ce:	8b 86 34 02 00 00    	mov    0x234(%esi),%eax
801037d4:	3b 86 38 02 00 00    	cmp    0x238(%esi),%eax
801037da:	75 d4                	jne    801037b0 <piperead+0x70>
  }
  wakeup(&p->nwrite);  //DOC: piperead-wakeup
801037dc:	83 ec 0c             	sub    $0xc,%esp
801037df:	8d 86 38 02 00 00    	lea    0x238(%esi),%eax
801037e5:	50                   	push   %eax
801037e6:	e8 a5 0d 00 00       	call   80104590 <wakeup>
  release(&p->lock);
801037eb:	89 34 24             	mov    %esi,(%esp)
801037ee:	e8 4d 13 00 00       	call   80104b40 <release>
  return i;
801037f3:	83 c4 10             	add    $0x10,%esp
}
801037f6:	8d 65 f4             	lea    -0xc(%ebp),%esp
801037f9:	89 d8                	mov    %ebx,%eax
801037fb:	5b                   	pop    %ebx
801037fc:	5e                   	pop    %esi
801037fd:	5f                   	pop    %edi
801037fe:	5d                   	pop    %ebp
801037ff:	c3                   	ret    
      release(&p->lock);
80103800:	83 ec 0c             	sub    $0xc,%esp
      return -1;
80103803:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
      release(&p->lock);
80103808:	56                   	push   %esi
80103809:	e8 32 13 00 00       	call   80104b40 <release>
      return -1;
8010380e:	83 c4 10             	add    $0x10,%esp
}
80103811:	8d 65 f4             	lea    -0xc(%ebp),%esp
80103814:	89 d8                	mov    %ebx,%eax
80103816:	5b                   	pop    %ebx
80103817:	5e                   	pop    %esi
80103818:	5f                   	pop    %edi
80103819:	5d                   	pop    %ebp
8010381a:	c3                   	ret    
8010381b:	66 90                	xchg   %ax,%ax
8010381d:	66 90                	xchg   %ax,%ax
8010381f:	90                   	nop

80103820 <allocproc>:
// If found, change state to EMBRYO and initialize
// state required to run in the kernel.
// Otherwise return 0.
static struct proc*
allocproc(void)
{
80103820:	55                   	push   %ebp
80103821:	89 e5                	mov    %esp,%ebp
80103823:	53                   	push   %ebx
  struct proc *p;
  char *sp;

  acquire(&ptable.lock);

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80103824:	bb 94 2d 21 80       	mov    $0x80212d94,%ebx
{
80103829:	83 ec 10             	sub    $0x10,%esp
  acquire(&ptable.lock);
8010382c:	68 60 2d 21 80       	push   $0x80212d60
80103831:	e8 6a 13 00 00       	call   80104ba0 <acquire>
80103836:	83 c4 10             	add    $0x10,%esp
80103839:	eb 13                	jmp    8010384e <allocproc+0x2e>
8010383b:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
8010383f:	90                   	nop
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80103840:	81 c3 c0 01 00 00    	add    $0x1c0,%ebx
80103846:	81 fb 94 9d 21 80    	cmp    $0x80219d94,%ebx
8010384c:	74 7a                	je     801038c8 <allocproc+0xa8>
    if(p->state == UNUSED)
8010384e:	8b 43 0c             	mov    0xc(%ebx),%eax
80103851:	85 c0                	test   %eax,%eax
80103853:	75 eb                	jne    80103840 <allocproc+0x20>
  release(&ptable.lock);
  return 0;

found:
  p->state = EMBRYO;
  p->pid = nextpid++;
80103855:	a1 04 b0 10 80       	mov    0x8010b004,%eax

  release(&ptable.lock);
8010385a:	83 ec 0c             	sub    $0xc,%esp
  p->state = EMBRYO;
8010385d:	c7 43 0c 01 00 00 00 	movl   $0x1,0xc(%ebx)
  p->pid = nextpid++;
80103864:	89 43 10             	mov    %eax,0x10(%ebx)
80103867:	8d 50 01             	lea    0x1(%eax),%edx
  release(&ptable.lock);
8010386a:	68 60 2d 21 80       	push   $0x80212d60
  p->pid = nextpid++;
8010386f:	89 15 04 b0 10 80    	mov    %edx,0x8010b004
  release(&ptable.lock);
80103875:	e8 c6 12 00 00       	call   80104b40 <release>

  // Allocate kernel stack.
  if((p->kstack = kalloc()) == 0){
8010387a:	e8 71 ee ff ff       	call   801026f0 <kalloc>
8010387f:	83 c4 10             	add    $0x10,%esp
80103882:	89 43 08             	mov    %eax,0x8(%ebx)
80103885:	85 c0                	test   %eax,%eax
80103887:	74 58                	je     801038e1 <allocproc+0xc1>
    return 0;
  }
  sp = p->kstack + KSTACKSIZE;

  // Leave room for trap frame.
  sp -= sizeof *p->tf;
80103889:	8d 90 b4 0f 00 00    	lea    0xfb4(%eax),%edx
  sp -= 4;
  *(uint*)sp = (uint)trapret;

  sp -= sizeof *p->context;
  p->context = (struct context*)sp;
  memset(p->context, 0, sizeof *p->context);
8010388f:	83 ec 04             	sub    $0x4,%esp
  sp -= sizeof *p->context;
80103892:	05 9c 0f 00 00       	add    $0xf9c,%eax
  sp -= sizeof *p->tf;
80103897:	89 53 18             	mov    %edx,0x18(%ebx)
  *(uint*)sp = (uint)trapret;
8010389a:	c7 40 14 cd 62 10 80 	movl   $0x801062cd,0x14(%eax)
  p->context = (struct context*)sp;
801038a1:	89 43 1c             	mov    %eax,0x1c(%ebx)
  memset(p->context, 0, sizeof *p->context);
801038a4:	6a 14                	push   $0x14
801038a6:	6a 00                	push   $0x0
801038a8:	50                   	push   %eax
801038a9:	e8 b2 13 00 00       	call   80104c60 <memset>
  p->context->eip = (uint)forkret;
801038ae:	8b 43 1c             	mov    0x1c(%ebx),%eax

  return p;
801038b1:	83 c4 10             	add    $0x10,%esp
  p->context->eip = (uint)forkret;
801038b4:	c7 40 10 00 39 10 80 	movl   $0x80103900,0x10(%eax)
}
801038bb:	89 d8                	mov    %ebx,%eax
801038bd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801038c0:	c9                   	leave  
801038c1:	c3                   	ret    
801038c2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  release(&ptable.lock);
801038c8:	83 ec 0c             	sub    $0xc,%esp
  return 0;
801038cb:	31 db                	xor    %ebx,%ebx
  release(&ptable.lock);
801038cd:	68 60 2d 21 80       	push   $0x80212d60
801038d2:	e8 69 12 00 00       	call   80104b40 <release>
}
801038d7:	89 d8                	mov    %ebx,%eax
  return 0;
801038d9:	83 c4 10             	add    $0x10,%esp
}
801038dc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801038df:	c9                   	leave  
801038e0:	c3                   	ret    
    p->state = UNUSED;
801038e1:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
    return 0;
801038e8:	31 db                	xor    %ebx,%ebx
}
801038ea:	89 d8                	mov    %ebx,%eax
801038ec:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801038ef:	c9                   	leave  
801038f0:	c3                   	ret    
801038f1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801038f8:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801038ff:	90                   	nop

80103900 <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch here.  "Return" to user space.
void
forkret(void)
{
80103900:	55                   	push   %ebp
80103901:	89 e5                	mov    %esp,%ebp
80103903:	83 ec 14             	sub    $0x14,%esp
  static int first = 1;
  // Still holding ptable.lock from scheduler.
  release(&ptable.lock);
80103906:	68 60 2d 21 80       	push   $0x80212d60
8010390b:	e8 30 12 00 00       	call   80104b40 <release>

  if (first) {
80103910:	a1 00 b0 10 80       	mov    0x8010b000,%eax
80103915:	83 c4 10             	add    $0x10,%esp
80103918:	85 c0                	test   %eax,%eax
8010391a:	75 04                	jne    80103920 <forkret+0x20>
    iinit(ROOTDEV);
    initlog(ROOTDEV);
  }

  // Return to "caller", actually trapret (see allocproc).
}
8010391c:	c9                   	leave  
8010391d:	c3                   	ret    
8010391e:	66 90                	xchg   %ax,%ax
    first = 0;
80103920:	c7 05 00 b0 10 80 00 	movl   $0x0,0x8010b000
80103927:	00 00 00 
    iinit(ROOTDEV);
8010392a:	83 ec 0c             	sub    $0xc,%esp
8010392d:	6a 01                	push   $0x1
8010392f:	e8 3c dc ff ff       	call   80101570 <iinit>
    initlog(ROOTDEV);
80103934:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
8010393b:	e8 f0 f3 ff ff       	call   80102d30 <initlog>
}
80103940:	83 c4 10             	add    $0x10,%esp
80103943:	c9                   	leave  
80103944:	c3                   	ret    
80103945:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010394c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

80103950 <pinit>:
{
80103950:	55                   	push   %ebp
80103951:	89 e5                	mov    %esp,%ebp
80103953:	83 ec 10             	sub    $0x10,%esp
  initlock(&ptable.lock, "ptable");
80103956:	68 e0 85 10 80       	push   $0x801085e0
8010395b:	68 60 2d 21 80       	push   $0x80212d60
80103960:	e8 6b 10 00 00       	call   801049d0 <initlock>
}
80103965:	83 c4 10             	add    $0x10,%esp
80103968:	c9                   	leave  
80103969:	c3                   	ret    
8010396a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

80103970 <mycpu>:
{
80103970:	55                   	push   %ebp
80103971:	89 e5                	mov    %esp,%ebp
80103973:	56                   	push   %esi
80103974:	53                   	push   %ebx
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80103975:	9c                   	pushf  
80103976:	58                   	pop    %eax
  if(readeflags()&FL_IF)
80103977:	f6 c4 02             	test   $0x2,%ah
8010397a:	75 46                	jne    801039c2 <mycpu+0x52>
  apicid = lapicid();
8010397c:	e8 df ef ff ff       	call   80102960 <lapicid>
  for (i = 0; i < ncpu; ++i) {
80103981:	8b 35 84 27 21 80    	mov    0x80212784,%esi
80103987:	85 f6                	test   %esi,%esi
80103989:	7e 2a                	jle    801039b5 <mycpu+0x45>
8010398b:	31 d2                	xor    %edx,%edx
8010398d:	eb 08                	jmp    80103997 <mycpu+0x27>
8010398f:	90                   	nop
80103990:	83 c2 01             	add    $0x1,%edx
80103993:	39 f2                	cmp    %esi,%edx
80103995:	74 1e                	je     801039b5 <mycpu+0x45>
    if (cpus[i].apicid == apicid)
80103997:	69 ca b0 00 00 00    	imul   $0xb0,%edx,%ecx
8010399d:	0f b6 99 a0 27 21 80 	movzbl -0x7fded860(%ecx),%ebx
801039a4:	39 c3                	cmp    %eax,%ebx
801039a6:	75 e8                	jne    80103990 <mycpu+0x20>
}
801039a8:	8d 65 f8             	lea    -0x8(%ebp),%esp
      return &cpus[i];
801039ab:	8d 81 a0 27 21 80    	lea    -0x7fded860(%ecx),%eax
}
801039b1:	5b                   	pop    %ebx
801039b2:	5e                   	pop    %esi
801039b3:	5d                   	pop    %ebp
801039b4:	c3                   	ret    
  panic("unknown apicid\n");
801039b5:	83 ec 0c             	sub    $0xc,%esp
801039b8:	68 e7 85 10 80       	push   $0x801085e7
801039bd:	e8 be c9 ff ff       	call   80100380 <panic>
    panic("mycpu called with interrupts enabled\n");
801039c2:	83 ec 0c             	sub    $0xc,%esp
801039c5:	68 c4 86 10 80       	push   $0x801086c4
801039ca:	e8 b1 c9 ff ff       	call   80100380 <panic>
801039cf:	90                   	nop

801039d0 <cpuid>:
cpuid() {
801039d0:	55                   	push   %ebp
801039d1:	89 e5                	mov    %esp,%ebp
801039d3:	83 ec 08             	sub    $0x8,%esp
  return mycpu()-cpus;
801039d6:	e8 95 ff ff ff       	call   80103970 <mycpu>
}
801039db:	c9                   	leave  
  return mycpu()-cpus;
801039dc:	2d a0 27 21 80       	sub    $0x802127a0,%eax
801039e1:	c1 f8 04             	sar    $0x4,%eax
801039e4:	69 c0 a3 8b 2e ba    	imul   $0xba2e8ba3,%eax,%eax
}
801039ea:	c3                   	ret    
801039eb:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
801039ef:	90                   	nop

801039f0 <myproc>:
myproc(void) {
801039f0:	55                   	push   %ebp
801039f1:	89 e5                	mov    %esp,%ebp
801039f3:	53                   	push   %ebx
801039f4:	83 ec 04             	sub    $0x4,%esp
  pushcli();
801039f7:	e8 54 10 00 00       	call   80104a50 <pushcli>
  c = mycpu();
801039fc:	e8 6f ff ff ff       	call   80103970 <mycpu>
  p = c->proc;
80103a01:	8b 98 ac 00 00 00    	mov    0xac(%eax),%ebx
  popcli();
80103a07:	e8 94 10 00 00       	call   80104aa0 <popcli>
}
80103a0c:	89 d8                	mov    %ebx,%eax
80103a0e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80103a11:	c9                   	leave  
80103a12:	c3                   	ret    
80103a13:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80103a1a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

80103a20 <userinit>:
{
80103a20:	55                   	push   %ebp
80103a21:	89 e5                	mov    %esp,%ebp
80103a23:	53                   	push   %ebx
80103a24:	83 ec 04             	sub    $0x4,%esp
  p = allocproc();
80103a27:	e8 f4 fd ff ff       	call   80103820 <allocproc>
80103a2c:	89 c3                	mov    %eax,%ebx
  initproc = p;
80103a2e:	a3 94 9d 21 80       	mov    %eax,0x80219d94
  if((p->pgdir = setupkvm()) == 0)
80103a33:	e8 18 43 00 00       	call   80107d50 <setupkvm>
80103a38:	89 43 04             	mov    %eax,0x4(%ebx)
80103a3b:	85 c0                	test   %eax,%eax
80103a3d:	0f 84 bd 00 00 00    	je     80103b00 <userinit+0xe0>
  inituvm(p->pgdir, _binary_initcode_start, (int)_binary_initcode_size);
80103a43:	83 ec 04             	sub    $0x4,%esp
80103a46:	68 2c 00 00 00       	push   $0x2c
80103a4b:	68 60 b4 10 80       	push   $0x8010b460
80103a50:	50                   	push   %eax
80103a51:	e8 8a 3f 00 00       	call   801079e0 <inituvm>
  memset(p->tf, 0, sizeof(*p->tf));
80103a56:	83 c4 0c             	add    $0xc,%esp
  p->sz = PGSIZE;
80103a59:	c7 03 00 10 00 00    	movl   $0x1000,(%ebx)
  memset(p->tf, 0, sizeof(*p->tf));
80103a5f:	6a 4c                	push   $0x4c
80103a61:	6a 00                	push   $0x0
80103a63:	ff 73 18             	push   0x18(%ebx)
80103a66:	e8 f5 11 00 00       	call   80104c60 <memset>
  p->tf->cs = (SEG_UCODE << 3) | DPL_USER;
80103a6b:	8b 43 18             	mov    0x18(%ebx),%eax
80103a6e:	ba 1b 00 00 00       	mov    $0x1b,%edx
  safestrcpy(p->name, "initcode", sizeof(p->name));
80103a73:	83 c4 0c             	add    $0xc,%esp
  p->tf->ds = (SEG_UDATA << 3) | DPL_USER;
80103a76:	b9 23 00 00 00       	mov    $0x23,%ecx
  p->tf->cs = (SEG_UCODE << 3) | DPL_USER;
80103a7b:	66 89 50 3c          	mov    %dx,0x3c(%eax)
  p->tf->ds = (SEG_UDATA << 3) | DPL_USER;
80103a7f:	8b 43 18             	mov    0x18(%ebx),%eax
80103a82:	66 89 48 2c          	mov    %cx,0x2c(%eax)
  p->tf->es = p->tf->ds;
80103a86:	8b 43 18             	mov    0x18(%ebx),%eax
80103a89:	0f b7 50 2c          	movzwl 0x2c(%eax),%edx
80103a8d:	66 89 50 28          	mov    %dx,0x28(%eax)
  p->tf->ss = p->tf->ds;
80103a91:	8b 43 18             	mov    0x18(%ebx),%eax
80103a94:	0f b7 50 2c          	movzwl 0x2c(%eax),%edx
80103a98:	66 89 50 48          	mov    %dx,0x48(%eax)
  p->tf->eflags = FL_IF;
80103a9c:	8b 43 18             	mov    0x18(%ebx),%eax
80103a9f:	c7 40 40 00 02 00 00 	movl   $0x200,0x40(%eax)
  p->tf->esp = PGSIZE;
80103aa6:	8b 43 18             	mov    0x18(%ebx),%eax
80103aa9:	c7 40 44 00 10 00 00 	movl   $0x1000,0x44(%eax)
  p->tf->eip = 0;  // beginning of initcode.S
80103ab0:	8b 43 18             	mov    0x18(%ebx),%eax
80103ab3:	c7 40 38 00 00 00 00 	movl   $0x0,0x38(%eax)
  safestrcpy(p->name, "initcode", sizeof(p->name));
80103aba:	8d 43 6c             	lea    0x6c(%ebx),%eax
80103abd:	6a 10                	push   $0x10
80103abf:	68 10 86 10 80       	push   $0x80108610
80103ac4:	50                   	push   %eax
80103ac5:	e8 56 13 00 00       	call   80104e20 <safestrcpy>
  p->cwd = namei("/");
80103aca:	c7 04 24 19 86 10 80 	movl   $0x80108619,(%esp)
80103ad1:	e8 da e5 ff ff       	call   801020b0 <namei>
80103ad6:	89 43 68             	mov    %eax,0x68(%ebx)
  acquire(&ptable.lock);
80103ad9:	c7 04 24 60 2d 21 80 	movl   $0x80212d60,(%esp)
80103ae0:	e8 bb 10 00 00       	call   80104ba0 <acquire>
  p->state = RUNNABLE;
80103ae5:	c7 43 0c 03 00 00 00 	movl   $0x3,0xc(%ebx)
  release(&ptable.lock);
80103aec:	c7 04 24 60 2d 21 80 	movl   $0x80212d60,(%esp)
80103af3:	e8 48 10 00 00       	call   80104b40 <release>
}
80103af8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80103afb:	83 c4 10             	add    $0x10,%esp
80103afe:	c9                   	leave  
80103aff:	c3                   	ret    
    panic("userinit: out of memory?");
80103b00:	83 ec 0c             	sub    $0xc,%esp
80103b03:	68 f7 85 10 80       	push   $0x801085f7
80103b08:	e8 73 c8 ff ff       	call   80100380 <panic>
80103b0d:	8d 76 00             	lea    0x0(%esi),%esi

80103b10 <growproc>:
{
80103b10:	55                   	push   %ebp
80103b11:	89 e5                	mov    %esp,%ebp
80103b13:	56                   	push   %esi
80103b14:	53                   	push   %ebx
80103b15:	8b 75 08             	mov    0x8(%ebp),%esi
  pushcli();
80103b18:	e8 33 0f 00 00       	call   80104a50 <pushcli>
  c = mycpu();
80103b1d:	e8 4e fe ff ff       	call   80103970 <mycpu>
  p = c->proc;
80103b22:	8b 98 ac 00 00 00    	mov    0xac(%eax),%ebx
  popcli();
80103b28:	e8 73 0f 00 00       	call   80104aa0 <popcli>
  sz = curproc->sz;
80103b2d:	8b 03                	mov    (%ebx),%eax
  if(n > 0){
80103b2f:	85 f6                	test   %esi,%esi
80103b31:	7f 1d                	jg     80103b50 <growproc+0x40>
  } else if(n < 0){
80103b33:	75 3b                	jne    80103b70 <growproc+0x60>
  switchuvm(curproc);
80103b35:	83 ec 0c             	sub    $0xc,%esp
  curproc->sz = sz;
80103b38:	89 03                	mov    %eax,(%ebx)
  switchuvm(curproc);
80103b3a:	53                   	push   %ebx
80103b3b:	e8 90 3d 00 00       	call   801078d0 <switchuvm>
  return 0;
80103b40:	83 c4 10             	add    $0x10,%esp
80103b43:	31 c0                	xor    %eax,%eax
}
80103b45:	8d 65 f8             	lea    -0x8(%ebp),%esp
80103b48:	5b                   	pop    %ebx
80103b49:	5e                   	pop    %esi
80103b4a:	5d                   	pop    %ebp
80103b4b:	c3                   	ret    
80103b4c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    if((sz = allocuvm(curproc->pgdir, sz, sz + n)) == 0)
80103b50:	83 ec 04             	sub    $0x4,%esp
80103b53:	01 c6                	add    %eax,%esi
80103b55:	56                   	push   %esi
80103b56:	50                   	push   %eax
80103b57:	ff 73 04             	push   0x4(%ebx)
80103b5a:	e8 11 40 00 00       	call   80107b70 <allocuvm>
80103b5f:	83 c4 10             	add    $0x10,%esp
80103b62:	85 c0                	test   %eax,%eax
80103b64:	75 cf                	jne    80103b35 <growproc+0x25>
      return -1;
80103b66:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103b6b:	eb d8                	jmp    80103b45 <growproc+0x35>
80103b6d:	8d 76 00             	lea    0x0(%esi),%esi
    if((sz = deallocuvm(curproc->pgdir, sz, sz + n)) == 0)
80103b70:	83 ec 04             	sub    $0x4,%esp
80103b73:	01 c6                	add    %eax,%esi
80103b75:	56                   	push   %esi
80103b76:	50                   	push   %eax
80103b77:	ff 73 04             	push   0x4(%ebx)
80103b7a:	e8 21 41 00 00       	call   80107ca0 <deallocuvm>
80103b7f:	83 c4 10             	add    $0x10,%esp
80103b82:	85 c0                	test   %eax,%eax
80103b84:	75 af                	jne    80103b35 <growproc+0x25>
80103b86:	eb de                	jmp    80103b66 <growproc+0x56>
80103b88:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80103b8f:	90                   	nop

80103b90 <fork>:
fork(void) {
80103b90:	55                   	push   %ebp
80103b91:	89 e5                	mov    %esp,%ebp
80103b93:	57                   	push   %edi
80103b94:	56                   	push   %esi
80103b95:	53                   	push   %ebx
80103b96:	83 ec 1c             	sub    $0x1c,%esp
  pushcli();
80103b99:	e8 b2 0e 00 00       	call   80104a50 <pushcli>
  c = mycpu();
80103b9e:	e8 cd fd ff ff       	call   80103970 <mycpu>
  p = c->proc;
80103ba3:	8b 98 ac 00 00 00    	mov    0xac(%eax),%ebx
  popcli();
80103ba9:	e8 f2 0e 00 00       	call   80104aa0 <popcli>
    if ((np = allocproc()) == 0) {
80103bae:	e8 6d fc ff ff       	call   80103820 <allocproc>
80103bb3:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80103bb6:	85 c0                	test   %eax,%eax
80103bb8:	0f 84 68 02 00 00    	je     80103e26 <fork+0x296>
    if ((np->pgdir = copyuvm(curproc->pgdir, curproc->sz)) == 0) {
80103bbe:	83 ec 08             	sub    $0x8,%esp
80103bc1:	ff 33                	push   (%ebx)
80103bc3:	89 c6                	mov    %eax,%esi
80103bc5:	ff 73 04             	push   0x4(%ebx)
80103bc8:	e8 73 42 00 00       	call   80107e40 <copyuvm>
80103bcd:	83 c4 10             	add    $0x10,%esp
80103bd0:	89 46 04             	mov    %eax,0x4(%esi)
80103bd3:	85 c0                	test   %eax,%eax
80103bd5:	0f 84 57 02 00 00    	je     80103e32 <fork+0x2a2>
    np->sz = curproc->sz;
80103bdb:	8b 03                	mov    (%ebx),%eax
80103bdd:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
80103be0:	89 01                	mov    %eax,(%ecx)
    *np->tf = *curproc->tf;
80103be2:	8b 79 18             	mov    0x18(%ecx),%edi
    np->parent = curproc;
80103be5:	89 c8                	mov    %ecx,%eax
80103be7:	89 59 14             	mov    %ebx,0x14(%ecx)
    *np->tf = *curproc->tf;
80103bea:	b9 13 00 00 00       	mov    $0x13,%ecx
80103bef:	8b 73 18             	mov    0x18(%ebx),%esi
80103bf2:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
    np->tf->eax = 0;
80103bf4:	89 c7                	mov    %eax,%edi
    for (i = 0; i < NOFILE; i++) {
80103bf6:	31 f6                	xor    %esi,%esi
    np->tf->eax = 0;
80103bf8:	8b 40 18             	mov    0x18(%eax),%eax
80103bfb:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)
    for (i = 0; i < NOFILE; i++) {
80103c02:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
        if (curproc->ofile[i]) {
80103c08:	8b 44 b3 28          	mov    0x28(%ebx,%esi,4),%eax
80103c0c:	85 c0                	test   %eax,%eax
80103c0e:	74 10                	je     80103c20 <fork+0x90>
            np->ofile[i] = filedup(curproc->ofile[i]);
80103c10:	83 ec 0c             	sub    $0xc,%esp
80103c13:	50                   	push   %eax
80103c14:	e8 97 d2 ff ff       	call   80100eb0 <filedup>
80103c19:	83 c4 10             	add    $0x10,%esp
80103c1c:	89 44 b7 28          	mov    %eax,0x28(%edi,%esi,4)
    for (i = 0; i < NOFILE; i++) {
80103c20:	83 c6 01             	add    $0x1,%esi
80103c23:	83 fe 10             	cmp    $0x10,%esi
80103c26:	75 e0                	jne    80103c08 <fork+0x78>
    np->cwd = idup(curproc->cwd);
80103c28:	83 ec 0c             	sub    $0xc,%esp
80103c2b:	ff 73 68             	push   0x68(%ebx)
80103c2e:	8d 7b 7c             	lea    0x7c(%ebx),%edi
80103c31:	e8 2a db ff ff       	call   80101760 <idup>
80103c36:	8b 75 e4             	mov    -0x1c(%ebp),%esi
    safestrcpy(np->name, curproc->name, sizeof(curproc->name));
80103c39:	83 c4 0c             	add    $0xc,%esp
    np->cwd = idup(curproc->cwd);
80103c3c:	89 46 68             	mov    %eax,0x68(%esi)
    safestrcpy(np->name, curproc->name, sizeof(curproc->name));
80103c3f:	8d 43 6c             	lea    0x6c(%ebx),%eax
80103c42:	6a 10                	push   $0x10
80103c44:	50                   	push   %eax
80103c45:	8d 46 6c             	lea    0x6c(%esi),%eax
80103c48:	50                   	push   %eax
80103c49:	e8 d2 11 00 00       	call   80104e20 <safestrcpy>
    pid = np->pid;
80103c4e:	8b 46 10             	mov    0x10(%esi),%eax
80103c51:	89 f1                	mov    %esi,%ecx
    for (i = 0; i < curproc->num_mmap_regions; i++) {
80103c53:	83 c4 10             	add    $0x10,%esp
80103c56:	83 c1 7c             	add    $0x7c,%ecx
80103c59:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
    pid = np->pid;
80103c60:	89 45 d8             	mov    %eax,-0x28(%ebp)
    np->num_mmap_regions = curproc->num_mmap_regions;
80103c63:	8b 83 bc 01 00 00    	mov    0x1bc(%ebx),%eax
80103c69:	89 4d dc             	mov    %ecx,-0x24(%ebp)
80103c6c:	89 86 bc 01 00 00    	mov    %eax,0x1bc(%esi)
    for (i = 0; i < curproc->num_mmap_regions; i++) {
80103c72:	85 c0                	test   %eax,%eax
80103c74:	0f 8e 12 01 00 00    	jle    80103d8c <fork+0x1fc>
        *child_region = *parent_region;
80103c7a:	8b 07                	mov    (%edi),%eax
80103c7c:	8b 55 dc             	mov    -0x24(%ebp),%edx
80103c7f:	89 02                	mov    %eax,(%edx)
80103c81:	8b 47 04             	mov    0x4(%edi),%eax
80103c84:	89 42 04             	mov    %eax,0x4(%edx)
80103c87:	8b 47 08             	mov    0x8(%edi),%eax
80103c8a:	89 42 08             	mov    %eax,0x8(%edx)
80103c8d:	8b 47 0c             	mov    0xc(%edi),%eax
80103c90:	89 42 0c             	mov    %eax,0xc(%edx)
80103c93:	8b 47 10             	mov    0x10(%edi),%eax
80103c96:	89 42 10             	mov    %eax,0x10(%edx)
        if (!(parent_region->flags & MAP_ANONYMOUS)) {
80103c99:	8b 77 08             	mov    0x8(%edi),%esi
80103c9c:	83 e6 04             	and    $0x4,%esi
80103c9f:	75 0f                	jne    80103cb0 <fork+0x120>
            struct file *f = curproc->ofile[parent_region->fd];
80103ca1:	8b 47 0c             	mov    0xc(%edi),%eax
80103ca4:	8b 44 83 28          	mov    0x28(%ebx,%eax,4),%eax
            if (f) {
80103ca8:	85 c0                	test   %eax,%eax
80103caa:	0f 85 10 01 00 00    	jne    80103dc0 <fork+0x230>
        for (uint va = parent_region->start_addr;
80103cb0:	8b 37                	mov    (%edi),%esi
             va < parent_region->start_addr + parent_region->length;
80103cb2:	8b 47 04             	mov    0x4(%edi),%eax
80103cb5:	01 f0                	add    %esi,%eax
80103cb7:	39 c6                	cmp    %eax,%esi
80103cb9:	0f 83 b3 00 00 00    	jae    80103d72 <fork+0x1e2>
80103cbf:	89 f0                	mov    %esi,%eax
80103cc1:	89 fe                	mov    %edi,%esi
80103cc3:	89 c7                	mov    %eax,%edi
80103cc5:	eb 1c                	jmp    80103ce3 <fork+0x153>
80103cc7:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80103cce:	66 90                	xchg   %ax,%ax
80103cd0:	8b 46 04             	mov    0x4(%esi),%eax
             va += PGSIZE) {
80103cd3:	81 c7 00 10 00 00    	add    $0x1000,%edi
             va < parent_region->start_addr + parent_region->length;
80103cd9:	03 06                	add    (%esi),%eax
80103cdb:	39 f8                	cmp    %edi,%eax
80103cdd:	0f 86 8d 00 00 00    	jbe    80103d70 <fork+0x1e0>
            pte_t *pte = walkpgdir(curproc->pgdir, (void *)va, 0);
80103ce3:	83 ec 04             	sub    $0x4,%esp
80103ce6:	6a 00                	push   $0x0
80103ce8:	57                   	push   %edi
80103ce9:	ff 73 04             	push   0x4(%ebx)
80103cec:	e8 4f 3a 00 00       	call   80107740 <walkpgdir>
            if (pte && (*pte & PTE_P)) {
80103cf1:	83 c4 10             	add    $0x10,%esp
80103cf4:	85 c0                	test   %eax,%eax
80103cf6:	74 d8                	je     80103cd0 <fork+0x140>
80103cf8:	8b 00                	mov    (%eax),%eax
80103cfa:	a8 01                	test   $0x1,%al
80103cfc:	74 d2                	je     80103cd0 <fork+0x140>
                int perm = PTE_FLAGS(*pte);
80103cfe:	89 c1                	mov    %eax,%ecx
                if (mappages(np->pgdir, (void *)va, PGSIZE, pa, perm) < 0) {
80103d00:	83 ec 0c             	sub    $0xc,%esp
                uint pa = PTE_ADDR(*pte);
80103d03:	25 00 f0 ff ff       	and    $0xfffff000,%eax
                int perm = PTE_FLAGS(*pte);
80103d08:	81 e1 ff 0f 00 00    	and    $0xfff,%ecx
                if (mappages(np->pgdir, (void *)va, PGSIZE, pa, perm) < 0) {
80103d0e:	51                   	push   %ecx
80103d0f:	50                   	push   %eax
80103d10:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80103d13:	68 00 10 00 00       	push   $0x1000
80103d18:	57                   	push   %edi
80103d19:	ff 70 04             	push   0x4(%eax)
80103d1c:	e8 af 3a 00 00       	call   801077d0 <mappages>
80103d21:	83 c4 20             	add    $0x20,%esp
80103d24:	85 c0                	test   %eax,%eax
80103d26:	79 a8                	jns    80103cd0 <fork+0x140>
                    cprintf("fork: Failed to map page at va=0x%x\n", va);
80103d28:	83 ec 08             	sub    $0x8,%esp
80103d2b:	57                   	push   %edi
80103d2c:	68 ec 86 10 80       	push   $0x801086ec
80103d31:	e8 6a c9 ff ff       	call   801006a0 <cprintf>
                    goto bad;
80103d36:	83 c4 10             	add    $0x10,%esp
    freevm(np->pgdir);
80103d39:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
80103d3c:	83 ec 0c             	sub    $0xc,%esp
80103d3f:	ff 73 04             	push   0x4(%ebx)
80103d42:	e8 89 3f 00 00       	call   80107cd0 <freevm>
    kfree(np->kstack);
80103d47:	58                   	pop    %eax
80103d48:	ff 73 08             	push   0x8(%ebx)
80103d4b:	e8 e0 e7 ff ff       	call   80102530 <kfree>
    np->state = UNUSED;
80103d50:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
    return -1;
80103d57:	83 c4 10             	add    $0x10,%esp
80103d5a:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
}
80103d61:	8b 45 d8             	mov    -0x28(%ebp),%eax
80103d64:	8d 65 f4             	lea    -0xc(%ebp),%esp
80103d67:	5b                   	pop    %ebx
80103d68:	5e                   	pop    %esi
80103d69:	5f                   	pop    %edi
80103d6a:	5d                   	pop    %ebp
80103d6b:	c3                   	ret    
80103d6c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80103d70:	89 f7                	mov    %esi,%edi
    for (i = 0; i < curproc->num_mmap_regions; i++) {
80103d72:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
80103d76:	83 c7 14             	add    $0x14,%edi
80103d79:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103d7c:	83 45 dc 14          	addl   $0x14,-0x24(%ebp)
80103d80:	39 83 bc 01 00 00    	cmp    %eax,0x1bc(%ebx)
80103d86:	0f 8f ee fe ff ff    	jg     80103c7a <fork+0xea>
    acquire(&ptable.lock);
80103d8c:	83 ec 0c             	sub    $0xc,%esp
80103d8f:	68 60 2d 21 80       	push   $0x80212d60
80103d94:	e8 07 0e 00 00       	call   80104ba0 <acquire>
    np->state = RUNNABLE;
80103d99:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80103d9c:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
    release(&ptable.lock);
80103da3:	c7 04 24 60 2d 21 80 	movl   $0x80212d60,(%esp)
80103daa:	e8 91 0d 00 00       	call   80104b40 <release>
}
80103daf:	8b 45 d8             	mov    -0x28(%ebp),%eax
    return pid;
80103db2:	83 c4 10             	add    $0x10,%esp
}
80103db5:	8d 65 f4             	lea    -0xc(%ebp),%esp
80103db8:	5b                   	pop    %ebx
80103db9:	5e                   	pop    %esi
80103dba:	5f                   	pop    %edi
80103dbb:	5d                   	pop    %ebp
80103dbc:	c3                   	ret    
80103dbd:	8d 76 00             	lea    0x0(%esi),%esi
                child_region->fd = -1;
80103dc0:	c7 42 0c ff ff ff ff 	movl   $0xffffffff,0xc(%edx)
80103dc7:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80103dca:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
                    if (np->ofile[j] == 0) {
80103dd0:	8b 4c b2 28          	mov    0x28(%edx,%esi,4),%ecx
80103dd4:	85 c9                	test   %ecx,%ecx
80103dd6:	74 30                	je     80103e08 <fork+0x278>
                for (int j = 0; j < NOFILE; j++) {
80103dd8:	83 c6 01             	add    $0x1,%esi
80103ddb:	83 fe 10             	cmp    $0x10,%esi
80103dde:	75 f0                	jne    80103dd0 <fork+0x240>
                    cprintf("fork: Failed to duplicate file descriptor for mmap, fd=%d\n", parent_region->fd);
80103de0:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103de3:	83 ec 08             	sub    $0x8,%esp
80103de6:	8d 04 80             	lea    (%eax,%eax,4),%eax
80103de9:	ff b4 83 88 00 00 00 	push   0x88(%ebx,%eax,4)
80103df0:	68 14 87 10 80       	push   $0x80108714
80103df5:	e8 a6 c8 ff ff       	call   801006a0 <cprintf>
                    goto bad;
80103dfa:	83 c4 10             	add    $0x10,%esp
80103dfd:	e9 37 ff ff ff       	jmp    80103d39 <fork+0x1a9>
80103e02:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
                        np->ofile[j] = filedup(f);
80103e08:	83 ec 0c             	sub    $0xc,%esp
80103e0b:	50                   	push   %eax
80103e0c:	e8 9f d0 ff ff       	call   80100eb0 <filedup>
80103e11:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
                        child_region->fd = j;
80103e14:	83 c4 10             	add    $0x10,%esp
                        np->ofile[j] = filedup(f);
80103e17:	89 44 b1 28          	mov    %eax,0x28(%ecx,%esi,4)
                        child_region->fd = j;
80103e1b:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103e1e:	89 70 0c             	mov    %esi,0xc(%eax)
                if (child_region->fd == -1) {
80103e21:	e9 8a fe ff ff       	jmp    80103cb0 <fork+0x120>
        return -1;
80103e26:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
80103e2d:	e9 2f ff ff ff       	jmp    80103d61 <fork+0x1d1>
        kfree(np->kstack);
80103e32:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
80103e35:	83 ec 0c             	sub    $0xc,%esp
80103e38:	ff 73 08             	push   0x8(%ebx)
80103e3b:	e8 f0 e6 ff ff       	call   80102530 <kfree>
        np->kstack = 0;
80103e40:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
        return -1;
80103e47:	83 c4 10             	add    $0x10,%esp
        np->state = UNUSED;
80103e4a:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
        return -1;
80103e51:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
80103e58:	e9 04 ff ff ff       	jmp    80103d61 <fork+0x1d1>
80103e5d:	8d 76 00             	lea    0x0(%esi),%esi

80103e60 <scheduler>:
{
80103e60:	55                   	push   %ebp
80103e61:	89 e5                	mov    %esp,%ebp
80103e63:	57                   	push   %edi
80103e64:	56                   	push   %esi
80103e65:	53                   	push   %ebx
80103e66:	83 ec 0c             	sub    $0xc,%esp
  struct cpu *c = mycpu();
80103e69:	e8 02 fb ff ff       	call   80103970 <mycpu>
  c->proc = 0;
80103e6e:	c7 80 ac 00 00 00 00 	movl   $0x0,0xac(%eax)
80103e75:	00 00 00 
  struct cpu *c = mycpu();
80103e78:	89 c6                	mov    %eax,%esi
  c->proc = 0;
80103e7a:	8d 78 04             	lea    0x4(%eax),%edi
80103e7d:	8d 76 00             	lea    0x0(%esi),%esi
  asm volatile("sti");
80103e80:	fb                   	sti    
    acquire(&ptable.lock);
80103e81:	83 ec 0c             	sub    $0xc,%esp
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80103e84:	bb 94 2d 21 80       	mov    $0x80212d94,%ebx
    acquire(&ptable.lock);
80103e89:	68 60 2d 21 80       	push   $0x80212d60
80103e8e:	e8 0d 0d 00 00       	call   80104ba0 <acquire>
80103e93:	83 c4 10             	add    $0x10,%esp
80103e96:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80103e9d:	8d 76 00             	lea    0x0(%esi),%esi
      if(p->state != RUNNABLE)
80103ea0:	83 7b 0c 03          	cmpl   $0x3,0xc(%ebx)
80103ea4:	75 33                	jne    80103ed9 <scheduler+0x79>
      switchuvm(p);
80103ea6:	83 ec 0c             	sub    $0xc,%esp
      c->proc = p;
80103ea9:	89 9e ac 00 00 00    	mov    %ebx,0xac(%esi)
      switchuvm(p);
80103eaf:	53                   	push   %ebx
80103eb0:	e8 1b 3a 00 00       	call   801078d0 <switchuvm>
      swtch(&(c->scheduler), p->context);
80103eb5:	58                   	pop    %eax
80103eb6:	5a                   	pop    %edx
80103eb7:	ff 73 1c             	push   0x1c(%ebx)
80103eba:	57                   	push   %edi
      p->state = RUNNING;
80103ebb:	c7 43 0c 04 00 00 00 	movl   $0x4,0xc(%ebx)
      swtch(&(c->scheduler), p->context);
80103ec2:	e8 b4 0f 00 00       	call   80104e7b <swtch>
      switchkvm();
80103ec7:	e8 f4 39 00 00       	call   801078c0 <switchkvm>
      c->proc = 0;
80103ecc:	83 c4 10             	add    $0x10,%esp
80103ecf:	c7 86 ac 00 00 00 00 	movl   $0x0,0xac(%esi)
80103ed6:	00 00 00 
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80103ed9:	81 c3 c0 01 00 00    	add    $0x1c0,%ebx
80103edf:	81 fb 94 9d 21 80    	cmp    $0x80219d94,%ebx
80103ee5:	75 b9                	jne    80103ea0 <scheduler+0x40>
    release(&ptable.lock);
80103ee7:	83 ec 0c             	sub    $0xc,%esp
80103eea:	68 60 2d 21 80       	push   $0x80212d60
80103eef:	e8 4c 0c 00 00       	call   80104b40 <release>
    sti();
80103ef4:	83 c4 10             	add    $0x10,%esp
80103ef7:	eb 87                	jmp    80103e80 <scheduler+0x20>
80103ef9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

80103f00 <sched>:
{
80103f00:	55                   	push   %ebp
80103f01:	89 e5                	mov    %esp,%ebp
80103f03:	56                   	push   %esi
80103f04:	53                   	push   %ebx
  pushcli();
80103f05:	e8 46 0b 00 00       	call   80104a50 <pushcli>
  c = mycpu();
80103f0a:	e8 61 fa ff ff       	call   80103970 <mycpu>
  p = c->proc;
80103f0f:	8b 98 ac 00 00 00    	mov    0xac(%eax),%ebx
  popcli();
80103f15:	e8 86 0b 00 00       	call   80104aa0 <popcli>
  if(!holding(&ptable.lock))
80103f1a:	83 ec 0c             	sub    $0xc,%esp
80103f1d:	68 60 2d 21 80       	push   $0x80212d60
80103f22:	e8 d9 0b 00 00       	call   80104b00 <holding>
80103f27:	83 c4 10             	add    $0x10,%esp
80103f2a:	85 c0                	test   %eax,%eax
80103f2c:	74 4f                	je     80103f7d <sched+0x7d>
  if(mycpu()->ncli != 1)
80103f2e:	e8 3d fa ff ff       	call   80103970 <mycpu>
80103f33:	83 b8 a4 00 00 00 01 	cmpl   $0x1,0xa4(%eax)
80103f3a:	75 68                	jne    80103fa4 <sched+0xa4>
  if(p->state == RUNNING)
80103f3c:	83 7b 0c 04          	cmpl   $0x4,0xc(%ebx)
80103f40:	74 55                	je     80103f97 <sched+0x97>
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80103f42:	9c                   	pushf  
80103f43:	58                   	pop    %eax
  if(readeflags()&FL_IF)
80103f44:	f6 c4 02             	test   $0x2,%ah
80103f47:	75 41                	jne    80103f8a <sched+0x8a>
  intena = mycpu()->intena;
80103f49:	e8 22 fa ff ff       	call   80103970 <mycpu>
  swtch(&p->context, mycpu()->scheduler);
80103f4e:	83 c3 1c             	add    $0x1c,%ebx
  intena = mycpu()->intena;
80103f51:	8b b0 a8 00 00 00    	mov    0xa8(%eax),%esi
  swtch(&p->context, mycpu()->scheduler);
80103f57:	e8 14 fa ff ff       	call   80103970 <mycpu>
80103f5c:	83 ec 08             	sub    $0x8,%esp
80103f5f:	ff 70 04             	push   0x4(%eax)
80103f62:	53                   	push   %ebx
80103f63:	e8 13 0f 00 00       	call   80104e7b <swtch>
  mycpu()->intena = intena;
80103f68:	e8 03 fa ff ff       	call   80103970 <mycpu>
}
80103f6d:	83 c4 10             	add    $0x10,%esp
  mycpu()->intena = intena;
80103f70:	89 b0 a8 00 00 00    	mov    %esi,0xa8(%eax)
}
80103f76:	8d 65 f8             	lea    -0x8(%ebp),%esp
80103f79:	5b                   	pop    %ebx
80103f7a:	5e                   	pop    %esi
80103f7b:	5d                   	pop    %ebp
80103f7c:	c3                   	ret    
    panic("sched ptable.lock");
80103f7d:	83 ec 0c             	sub    $0xc,%esp
80103f80:	68 1b 86 10 80       	push   $0x8010861b
80103f85:	e8 f6 c3 ff ff       	call   80100380 <panic>
    panic("sched interruptible");
80103f8a:	83 ec 0c             	sub    $0xc,%esp
80103f8d:	68 47 86 10 80       	push   $0x80108647
80103f92:	e8 e9 c3 ff ff       	call   80100380 <panic>
    panic("sched running");
80103f97:	83 ec 0c             	sub    $0xc,%esp
80103f9a:	68 39 86 10 80       	push   $0x80108639
80103f9f:	e8 dc c3 ff ff       	call   80100380 <panic>
    panic("sched locks");
80103fa4:	83 ec 0c             	sub    $0xc,%esp
80103fa7:	68 2d 86 10 80       	push   $0x8010862d
80103fac:	e8 cf c3 ff ff       	call   80100380 <panic>
80103fb1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80103fb8:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80103fbf:	90                   	nop

80103fc0 <exit>:
{
80103fc0:	55                   	push   %ebp
80103fc1:	89 e5                	mov    %esp,%ebp
80103fc3:	57                   	push   %edi
80103fc4:	56                   	push   %esi
80103fc5:	53                   	push   %ebx
80103fc6:	83 ec 1c             	sub    $0x1c,%esp
  struct proc *curproc = myproc();
80103fc9:	e8 22 fa ff ff       	call   801039f0 <myproc>
80103fce:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  if (curproc == initproc)
80103fd1:	39 05 94 9d 21 80    	cmp    %eax,0x80219d94
80103fd7:	0f 84 5b 03 00 00    	je     80104338 <exit+0x378>
  for (int i = 0; i < curproc->num_mmap_regions; i++) {
80103fdd:	8d 70 7c             	lea    0x7c(%eax),%esi
80103fe0:	8b 80 bc 01 00 00    	mov    0x1bc(%eax),%eax
80103fe6:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
80103fed:	85 c0                	test   %eax,%eax
80103fef:	0f 8e b0 00 00 00    	jle    801040a5 <exit+0xe5>
80103ff5:	8d 76 00             	lea    0x0(%esi),%esi
          for (uint va = region->start_addr; va < region->start_addr + region->length; va += PGSIZE) {
80103ff8:	8b 1e                	mov    (%esi),%ebx
80103ffa:	8b 46 04             	mov    0x4(%esi),%eax
80103ffd:	01 d8                	add    %ebx,%eax
    if (region->flags & MAP_SHARED) {
80103fff:	f6 46 08 02          	testb  $0x2,0x8(%esi)
80104003:	74 1d                	je     80104022 <exit+0x62>
      if (region->fd >= 0) {
80104005:	8b 56 0c             	mov    0xc(%esi),%edx
80104008:	85 d2                	test   %edx,%edx
8010400a:	0f 88 e4 02 00 00    	js     801042f4 <exit+0x334>
        struct file *f = curproc->ofile[region->fd];
80104010:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
80104013:	8b 4c 91 28          	mov    0x28(%ecx,%edx,4),%ecx
80104017:	89 4d dc             	mov    %ecx,-0x24(%ebp)
        if (f) {
8010401a:	85 c9                	test   %ecx,%ecx
8010401c:	0f 85 1c 01 00 00    	jne    8010413e <exit+0x17e>
    for (uint va = region->start_addr; va < region->start_addr + region->length; va += PGSIZE) {
80104022:	39 c3                	cmp    %eax,%ebx
80104024:	73 66                	jae    8010408c <exit+0xcc>
80104026:	89 f7                	mov    %esi,%edi
80104028:	89 de                	mov    %ebx,%esi
8010402a:	eb 13                	jmp    8010403f <exit+0x7f>
8010402c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80104030:	8b 47 04             	mov    0x4(%edi),%eax
80104033:	81 c6 00 10 00 00    	add    $0x1000,%esi
80104039:	03 07                	add    (%edi),%eax
8010403b:	39 f0                	cmp    %esi,%eax
8010403d:	76 4b                	jbe    8010408a <exit+0xca>
      pte_t *pte = walkpgdir(curproc->pgdir, (void *)va, 0);
8010403f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80104042:	83 ec 04             	sub    $0x4,%esp
80104045:	6a 00                	push   $0x0
80104047:	56                   	push   %esi
80104048:	ff 70 04             	push   0x4(%eax)
8010404b:	e8 f0 36 00 00       	call   80107740 <walkpgdir>
      if (pte && (*pte & PTE_P)) {
80104050:	83 c4 10             	add    $0x10,%esp
      pte_t *pte = walkpgdir(curproc->pgdir, (void *)va, 0);
80104053:	89 c3                	mov    %eax,%ebx
      if (pte && (*pte & PTE_P)) {
80104055:	85 c0                	test   %eax,%eax
80104057:	74 d7                	je     80104030 <exit+0x70>
80104059:	8b 00                	mov    (%eax),%eax
8010405b:	a8 01                	test   $0x1,%al
8010405d:	74 d1                	je     80104030 <exit+0x70>
        uint pa = PTE_ADDR(*pte);
8010405f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
        kfree(P2V(pa));      // Free the physical page
80104064:	83 ec 0c             	sub    $0xc,%esp
    for (uint va = region->start_addr; va < region->start_addr + region->length; va += PGSIZE) {
80104067:	81 c6 00 10 00 00    	add    $0x1000,%esi
        kfree(P2V(pa));      // Free the physical page
8010406d:	05 00 00 00 80       	add    $0x80000000,%eax
80104072:	50                   	push   %eax
80104073:	e8 b8 e4 ff ff       	call   80102530 <kfree>
        *pte = 0;            // Clear the page table entry
80104078:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
    for (uint va = region->start_addr; va < region->start_addr + region->length; va += PGSIZE) {
8010407e:	8b 47 04             	mov    0x4(%edi),%eax
        *pte = 0;            // Clear the page table entry
80104081:	83 c4 10             	add    $0x10,%esp
    for (uint va = region->start_addr; va < region->start_addr + region->length; va += PGSIZE) {
80104084:	03 07                	add    (%edi),%eax
80104086:	39 f0                	cmp    %esi,%eax
80104088:	77 b5                	ja     8010403f <exit+0x7f>
8010408a:	89 fe                	mov    %edi,%esi
  for (int i = 0; i < curproc->num_mmap_regions; i++) {
8010408c:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
8010408f:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
80104093:	83 c6 14             	add    $0x14,%esi
80104096:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104099:	39 81 bc 01 00 00    	cmp    %eax,0x1bc(%ecx)
8010409f:	0f 8f 53 ff ff ff    	jg     80103ff8 <exit+0x38>
  curproc->num_mmap_regions = 0;
801040a5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  for (uint va = 0; va < 0x60000000; va += PGSIZE) {
801040a8:	31 f6                	xor    %esi,%esi
  curproc->num_mmap_regions = 0;
801040aa:	c7 80 bc 01 00 00 00 	movl   $0x0,0x1bc(%eax)
801040b1:	00 00 00 
  for (uint va = 0; va < 0x60000000; va += PGSIZE) {
801040b4:	eb 22                	jmp    801040d8 <exit+0x118>
801040b6:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801040bd:	8d 76 00             	lea    0x0(%esi),%esi
    *pte = 0; // Clear the page table entry
801040c0:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  for (uint va = 0; va < 0x60000000; va += PGSIZE) {
801040c6:	81 c6 00 10 00 00    	add    $0x1000,%esi
801040cc:	81 fe 00 00 00 60    	cmp    $0x60000000,%esi
801040d2:	0f 84 02 01 00 00    	je     801041da <exit+0x21a>
    pte_t *pte = walkpgdir(curproc->pgdir, (void *)va, 0);
801040d8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801040db:	83 ec 04             	sub    $0x4,%esp
801040de:	6a 00                	push   $0x0
801040e0:	56                   	push   %esi
801040e1:	ff 70 04             	push   0x4(%eax)
801040e4:	e8 57 36 00 00       	call   80107740 <walkpgdir>
    if (!pte || !(*pte & PTE_P)) {
801040e9:	83 c4 10             	add    $0x10,%esp
    pte_t *pte = walkpgdir(curproc->pgdir, (void *)va, 0);
801040ec:	89 c3                	mov    %eax,%ebx
    if (!pte || !(*pte & PTE_P)) {
801040ee:	85 c0                	test   %eax,%eax
801040f0:	74 d4                	je     801040c6 <exit+0x106>
801040f2:	8b 38                	mov    (%eax),%edi
801040f4:	f7 c7 01 00 00 00    	test   $0x1,%edi
801040fa:	74 ca                	je     801040c6 <exit+0x106>
    if (get_ref(pa) > 0) {
801040fc:	83 ec 0c             	sub    $0xc,%esp
    uint pa = PTE_ADDR(*pte);
801040ff:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
    if (get_ref(pa) > 0) {
80104105:	57                   	push   %edi
80104106:	e8 05 e4 ff ff       	call   80102510 <get_ref>
8010410b:	83 c4 10             	add    $0x10,%esp
8010410e:	85 c0                	test   %eax,%eax
80104110:	7e ae                	jle    801040c0 <exit+0x100>
      dec_ref(pa); // Decrement reference count
80104112:	83 ec 0c             	sub    $0xc,%esp
80104115:	57                   	push   %edi
80104116:	e8 d5 e3 ff ff       	call   801024f0 <dec_ref>
      if (get_ref(pa) == 0) {
8010411b:	89 3c 24             	mov    %edi,(%esp)
8010411e:	e8 ed e3 ff ff       	call   80102510 <get_ref>
80104123:	83 c4 10             	add    $0x10,%esp
80104126:	85 c0                	test   %eax,%eax
80104128:	75 96                	jne    801040c0 <exit+0x100>
        kfree((char *)P2V(pa)); // Free physical page if no references remain
8010412a:	83 ec 0c             	sub    $0xc,%esp
8010412d:	81 c7 00 00 00 80    	add    $0x80000000,%edi
80104133:	57                   	push   %edi
80104134:	e8 f7 e3 ff ff       	call   80102530 <kfree>
80104139:	83 c4 10             	add    $0x10,%esp
8010413c:	eb 82                	jmp    801040c0 <exit+0x100>
          for (uint va = region->start_addr; va < region->start_addr + region->length; va += PGSIZE) {
8010413e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
80104141:	39 c3                	cmp    %eax,%ebx
80104143:	72 22                	jb     80104167 <exit+0x1a7>
80104145:	e9 42 ff ff ff       	jmp    8010408c <exit+0xcc>
8010414a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
            if (pte && (*pte & PTE_P)) {
80104150:	8b 00                	mov    (%eax),%eax
              uint file_offset = va - region->start_addr;
80104152:	8b 16                	mov    (%esi),%edx
            if (pte && (*pte & PTE_P)) {
80104154:	a8 01                	test   $0x1,%al
80104156:	75 40                	jne    80104198 <exit+0x1d8>
          for (uint va = region->start_addr; va < region->start_addr + region->length; va += PGSIZE) {
80104158:	8b 46 04             	mov    0x4(%esi),%eax
8010415b:	81 c3 00 10 00 00    	add    $0x1000,%ebx
80104161:	01 d0                	add    %edx,%eax
80104163:	39 d8                	cmp    %ebx,%eax
80104165:	76 26                	jbe    8010418d <exit+0x1cd>
            pte_t *pte = walkpgdir(curproc->pgdir, (void *)va, 0);
80104167:	83 ec 04             	sub    $0x4,%esp
8010416a:	6a 00                	push   $0x0
8010416c:	53                   	push   %ebx
8010416d:	ff 77 04             	push   0x4(%edi)
80104170:	e8 cb 35 00 00       	call   80107740 <walkpgdir>
            if (pte && (*pte & PTE_P)) {
80104175:	83 c4 10             	add    $0x10,%esp
80104178:	85 c0                	test   %eax,%eax
8010417a:	75 d4                	jne    80104150 <exit+0x190>
8010417c:	8b 16                	mov    (%esi),%edx
          for (uint va = region->start_addr; va < region->start_addr + region->length; va += PGSIZE) {
8010417e:	8b 46 04             	mov    0x4(%esi),%eax
80104181:	81 c3 00 10 00 00    	add    $0x1000,%ebx
80104187:	01 d0                	add    %edx,%eax
80104189:	39 d8                	cmp    %ebx,%eax
8010418b:	77 da                	ja     80104167 <exit+0x1a7>
        for (uint va = region->start_addr; va < region->start_addr + region->length; va += PGSIZE) {
8010418d:	89 d3                	mov    %edx,%ebx
8010418f:	e9 8e fe ff ff       	jmp    80104022 <exit+0x62>
80104194:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
              uint file_offset = va - region->start_addr;
80104198:	89 d9                	mov    %ebx,%ecx
              uint pa = PTE_ADDR(*pte);
8010419a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
              if (filewrite(f, page_addr, PGSIZE) != PGSIZE) {
8010419f:	83 ec 04             	sub    $0x4,%esp
              uint file_offset = va - region->start_addr;
801041a2:	29 d1                	sub    %edx,%ecx
801041a4:	8b 55 dc             	mov    -0x24(%ebp),%edx
              char *page_addr = (char *)P2V(pa);
801041a7:	05 00 00 00 80       	add    $0x80000000,%eax
              uint file_offset = va - region->start_addr;
801041ac:	89 4a 14             	mov    %ecx,0x14(%edx)
              if (filewrite(f, page_addr, PGSIZE) != PGSIZE) {
801041af:	68 00 10 00 00       	push   $0x1000
801041b4:	50                   	push   %eax
801041b5:	52                   	push   %edx
801041b6:	e8 05 cf ff ff       	call   801010c0 <filewrite>
801041bb:	83 c4 10             	add    $0x10,%esp
801041be:	3d 00 10 00 00       	cmp    $0x1000,%eax
801041c3:	74 b7                	je     8010417c <exit+0x1bc>
                cprintf("exit: Failed to write back page at va=0x%x\n", va);
801041c5:	83 ec 08             	sub    $0x8,%esp
801041c8:	53                   	push   %ebx
801041c9:	68 50 87 10 80       	push   $0x80108750
801041ce:	e8 cd c4 ff ff       	call   801006a0 <cprintf>
801041d3:	8b 16                	mov    (%esi),%edx
801041d5:	83 c4 10             	add    $0x10,%esp
801041d8:	eb a4                	jmp    8010417e <exit+0x1be>
  lcr3(V2P(curproc->pgdir));
801041da:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
801041dd:	8b 41 04             	mov    0x4(%ecx),%eax
801041e0:	89 45 e0             	mov    %eax,-0x20(%ebp)
801041e3:	05 00 00 00 80       	add    $0x80000000,%eax
}

static inline void
lcr3(uint val)
{
  asm volatile("movl %0,%%cr3" : : "r" (val));
801041e8:	0f 22 d8             	mov    %eax,%cr3
  for (fd = 0; fd < NOFILE; fd++) {
801041eb:	8d 59 28             	lea    0x28(%ecx),%ebx
801041ee:	8d 79 68             	lea    0x68(%ecx),%edi
801041f1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    if (curproc->ofile[fd]) {
801041f8:	8b 03                	mov    (%ebx),%eax
801041fa:	85 c0                	test   %eax,%eax
801041fc:	74 12                	je     80104210 <exit+0x250>
      fileclose(curproc->ofile[fd]);
801041fe:	83 ec 0c             	sub    $0xc,%esp
80104201:	50                   	push   %eax
80104202:	e8 f9 cc ff ff       	call   80100f00 <fileclose>
      curproc->ofile[fd] = 0;
80104207:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
8010420d:	83 c4 10             	add    $0x10,%esp
  for (fd = 0; fd < NOFILE; fd++) {
80104210:	83 c3 04             	add    $0x4,%ebx
80104213:	39 df                	cmp    %ebx,%edi
80104215:	75 e1                	jne    801041f8 <exit+0x238>
  begin_op();
80104217:	e8 b4 eb ff ff       	call   80102dd0 <begin_op>
  iput(curproc->cwd);
8010421c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
8010421f:	83 ec 0c             	sub    $0xc,%esp
80104222:	ff 77 68             	push   0x68(%edi)
80104225:	e8 96 d6 ff ff       	call   801018c0 <iput>
  end_op();
8010422a:	e8 11 ec ff ff       	call   80102e40 <end_op>
  curproc->cwd = 0;
8010422f:	c7 47 68 00 00 00 00 	movl   $0x0,0x68(%edi)
  acquire(&ptable.lock);
80104236:	c7 04 24 60 2d 21 80 	movl   $0x80212d60,(%esp)
8010423d:	e8 5e 09 00 00       	call   80104ba0 <acquire>
  wakeup1(curproc->parent);
80104242:	8b 57 14             	mov    0x14(%edi),%edx
80104245:	83 c4 10             	add    $0x10,%esp
static void
wakeup1(void *chan)
{
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104248:	b8 94 2d 21 80       	mov    $0x80212d94,%eax
8010424d:	eb 0d                	jmp    8010425c <exit+0x29c>
8010424f:	90                   	nop
80104250:	05 c0 01 00 00       	add    $0x1c0,%eax
80104255:	3d 94 9d 21 80       	cmp    $0x80219d94,%eax
8010425a:	74 1e                	je     8010427a <exit+0x2ba>
    if(p->state == SLEEPING && p->chan == chan)
8010425c:	83 78 0c 02          	cmpl   $0x2,0xc(%eax)
80104260:	75 ee                	jne    80104250 <exit+0x290>
80104262:	3b 50 20             	cmp    0x20(%eax),%edx
80104265:	75 e9                	jne    80104250 <exit+0x290>
      p->state = RUNNABLE;
80104267:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
8010426e:	05 c0 01 00 00       	add    $0x1c0,%eax
80104273:	3d 94 9d 21 80       	cmp    $0x80219d94,%eax
80104278:	75 e2                	jne    8010425c <exit+0x29c>
      p->parent = initproc;
8010427a:	8b 0d 94 9d 21 80    	mov    0x80219d94,%ecx
  for (p = ptable.proc; p < &ptable.proc[NPROC]; p++) {
80104280:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
80104283:	ba 94 2d 21 80       	mov    $0x80212d94,%edx
80104288:	eb 14                	jmp    8010429e <exit+0x2de>
8010428a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
80104290:	81 c2 c0 01 00 00    	add    $0x1c0,%edx
80104296:	81 fa 94 9d 21 80    	cmp    $0x80219d94,%edx
8010429c:	74 3a                	je     801042d8 <exit+0x318>
    if (p->parent == curproc) {
8010429e:	39 5a 14             	cmp    %ebx,0x14(%edx)
801042a1:	75 ed                	jne    80104290 <exit+0x2d0>
      if (p->state == ZOMBIE)
801042a3:	83 7a 0c 05          	cmpl   $0x5,0xc(%edx)
      p->parent = initproc;
801042a7:	89 4a 14             	mov    %ecx,0x14(%edx)
      if (p->state == ZOMBIE)
801042aa:	75 e4                	jne    80104290 <exit+0x2d0>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
801042ac:	b8 94 2d 21 80       	mov    $0x80212d94,%eax
801042b1:	eb 11                	jmp    801042c4 <exit+0x304>
801042b3:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
801042b7:	90                   	nop
801042b8:	05 c0 01 00 00       	add    $0x1c0,%eax
801042bd:	3d 94 9d 21 80       	cmp    $0x80219d94,%eax
801042c2:	74 cc                	je     80104290 <exit+0x2d0>
    if(p->state == SLEEPING && p->chan == chan)
801042c4:	83 78 0c 02          	cmpl   $0x2,0xc(%eax)
801042c8:	75 ee                	jne    801042b8 <exit+0x2f8>
801042ca:	3b 48 20             	cmp    0x20(%eax),%ecx
801042cd:	75 e9                	jne    801042b8 <exit+0x2f8>
      p->state = RUNNABLE;
801042cf:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
801042d6:	eb e0                	jmp    801042b8 <exit+0x2f8>
  curproc->state = ZOMBIE;
801042d8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801042db:	c7 40 0c 05 00 00 00 	movl   $0x5,0xc(%eax)
  sched();
801042e2:	e8 19 fc ff ff       	call   80103f00 <sched>
  panic("zombie exit");
801042e7:	83 ec 0c             	sub    $0xc,%esp
801042ea:	68 68 86 10 80       	push   $0x80108668
801042ef:	e8 8c c0 ff ff       	call   80100380 <panic>
        for (uint va = region->start_addr; va < region->start_addr + region->length; va += PGSIZE) {
801042f4:	39 c3                	cmp    %eax,%ebx
801042f6:	0f 83 90 fd ff ff    	jae    8010408c <exit+0xcc>
801042fc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
801042ff:	90                   	nop
          pte_t *pte = walkpgdir(curproc->pgdir, (void *)va, 0);
80104300:	83 ec 04             	sub    $0x4,%esp
80104303:	6a 00                	push   $0x0
80104305:	53                   	push   %ebx
80104306:	ff 77 04             	push   0x4(%edi)
80104309:	e8 32 34 00 00       	call   80107740 <walkpgdir>
          if (pte && (*pte & PTE_P)) {
8010430e:	83 c4 10             	add    $0x10,%esp
80104311:	85 c0                	test   %eax,%eax
80104313:	74 0b                	je     80104320 <exit+0x360>
80104315:	f6 00 01             	testb  $0x1,(%eax)
80104318:	74 06                	je     80104320 <exit+0x360>
            *pte = 0; // Clear the page table entry
8010431a:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
        for (uint va = region->start_addr; va < region->start_addr + region->length; va += PGSIZE) {
80104320:	8b 16                	mov    (%esi),%edx
80104322:	8b 46 04             	mov    0x4(%esi),%eax
80104325:	81 c3 00 10 00 00    	add    $0x1000,%ebx
8010432b:	01 d0                	add    %edx,%eax
8010432d:	39 d8                	cmp    %ebx,%eax
8010432f:	77 cf                	ja     80104300 <exit+0x340>
80104331:	89 d3                	mov    %edx,%ebx
80104333:	e9 ea fc ff ff       	jmp    80104022 <exit+0x62>
    panic("init exiting");
80104338:	83 ec 0c             	sub    $0xc,%esp
8010433b:	68 5b 86 10 80       	push   $0x8010865b
80104340:	e8 3b c0 ff ff       	call   80100380 <panic>
80104345:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010434c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

80104350 <wait>:
{
80104350:	55                   	push   %ebp
80104351:	89 e5                	mov    %esp,%ebp
80104353:	56                   	push   %esi
80104354:	53                   	push   %ebx
  pushcli();
80104355:	e8 f6 06 00 00       	call   80104a50 <pushcli>
  c = mycpu();
8010435a:	e8 11 f6 ff ff       	call   80103970 <mycpu>
  p = c->proc;
8010435f:	8b b0 ac 00 00 00    	mov    0xac(%eax),%esi
  popcli();
80104365:	e8 36 07 00 00       	call   80104aa0 <popcli>
  acquire(&ptable.lock);
8010436a:	83 ec 0c             	sub    $0xc,%esp
8010436d:	68 60 2d 21 80       	push   $0x80212d60
80104372:	e8 29 08 00 00       	call   80104ba0 <acquire>
80104377:	83 c4 10             	add    $0x10,%esp
    havekids = 0;
8010437a:	31 c0                	xor    %eax,%eax
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010437c:	bb 94 2d 21 80       	mov    $0x80212d94,%ebx
80104381:	eb 13                	jmp    80104396 <wait+0x46>
80104383:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80104387:	90                   	nop
80104388:	81 c3 c0 01 00 00    	add    $0x1c0,%ebx
8010438e:	81 fb 94 9d 21 80    	cmp    $0x80219d94,%ebx
80104394:	74 1e                	je     801043b4 <wait+0x64>
      if(p->parent != curproc)
80104396:	39 73 14             	cmp    %esi,0x14(%ebx)
80104399:	75 ed                	jne    80104388 <wait+0x38>
      if(p->state == ZOMBIE){
8010439b:	83 7b 0c 05          	cmpl   $0x5,0xc(%ebx)
8010439f:	74 5f                	je     80104400 <wait+0xb0>
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801043a1:	81 c3 c0 01 00 00    	add    $0x1c0,%ebx
      havekids = 1;
801043a7:	b8 01 00 00 00       	mov    $0x1,%eax
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801043ac:	81 fb 94 9d 21 80    	cmp    $0x80219d94,%ebx
801043b2:	75 e2                	jne    80104396 <wait+0x46>
    if(!havekids || curproc->killed){
801043b4:	85 c0                	test   %eax,%eax
801043b6:	0f 84 9a 00 00 00    	je     80104456 <wait+0x106>
801043bc:	8b 46 24             	mov    0x24(%esi),%eax
801043bf:	85 c0                	test   %eax,%eax
801043c1:	0f 85 8f 00 00 00    	jne    80104456 <wait+0x106>
  pushcli();
801043c7:	e8 84 06 00 00       	call   80104a50 <pushcli>
  c = mycpu();
801043cc:	e8 9f f5 ff ff       	call   80103970 <mycpu>
  p = c->proc;
801043d1:	8b 98 ac 00 00 00    	mov    0xac(%eax),%ebx
  popcli();
801043d7:	e8 c4 06 00 00       	call   80104aa0 <popcli>
  if(p == 0)
801043dc:	85 db                	test   %ebx,%ebx
801043de:	0f 84 89 00 00 00    	je     8010446d <wait+0x11d>
  p->chan = chan;
801043e4:	89 73 20             	mov    %esi,0x20(%ebx)
  p->state = SLEEPING;
801043e7:	c7 43 0c 02 00 00 00 	movl   $0x2,0xc(%ebx)
  sched();
801043ee:	e8 0d fb ff ff       	call   80103f00 <sched>
  p->chan = 0;
801043f3:	c7 43 20 00 00 00 00 	movl   $0x0,0x20(%ebx)
}
801043fa:	e9 7b ff ff ff       	jmp    8010437a <wait+0x2a>
801043ff:	90                   	nop
        kfree(p->kstack);
80104400:	83 ec 0c             	sub    $0xc,%esp
        pid = p->pid;
80104403:	8b 73 10             	mov    0x10(%ebx),%esi
        kfree(p->kstack);
80104406:	ff 73 08             	push   0x8(%ebx)
80104409:	e8 22 e1 ff ff       	call   80102530 <kfree>
        p->kstack = 0;
8010440e:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
        freevm(p->pgdir);
80104415:	5a                   	pop    %edx
80104416:	ff 73 04             	push   0x4(%ebx)
80104419:	e8 b2 38 00 00       	call   80107cd0 <freevm>
        p->pid = 0;
8010441e:	c7 43 10 00 00 00 00 	movl   $0x0,0x10(%ebx)
        p->parent = 0;
80104425:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)
        p->name[0] = 0;
8010442c:	c6 43 6c 00          	movb   $0x0,0x6c(%ebx)
        p->killed = 0;
80104430:	c7 43 24 00 00 00 00 	movl   $0x0,0x24(%ebx)
        p->state = UNUSED;
80104437:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
        release(&ptable.lock);
8010443e:	c7 04 24 60 2d 21 80 	movl   $0x80212d60,(%esp)
80104445:	e8 f6 06 00 00       	call   80104b40 <release>
        return pid;
8010444a:	83 c4 10             	add    $0x10,%esp
}
8010444d:	8d 65 f8             	lea    -0x8(%ebp),%esp
80104450:	89 f0                	mov    %esi,%eax
80104452:	5b                   	pop    %ebx
80104453:	5e                   	pop    %esi
80104454:	5d                   	pop    %ebp
80104455:	c3                   	ret    
      release(&ptable.lock);
80104456:	83 ec 0c             	sub    $0xc,%esp
      return -1;
80104459:	be ff ff ff ff       	mov    $0xffffffff,%esi
      release(&ptable.lock);
8010445e:	68 60 2d 21 80       	push   $0x80212d60
80104463:	e8 d8 06 00 00       	call   80104b40 <release>
      return -1;
80104468:	83 c4 10             	add    $0x10,%esp
8010446b:	eb e0                	jmp    8010444d <wait+0xfd>
    panic("sleep");
8010446d:	83 ec 0c             	sub    $0xc,%esp
80104470:	68 74 86 10 80       	push   $0x80108674
80104475:	e8 06 bf ff ff       	call   80100380 <panic>
8010447a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

80104480 <yield>:
{
80104480:	55                   	push   %ebp
80104481:	89 e5                	mov    %esp,%ebp
80104483:	53                   	push   %ebx
80104484:	83 ec 10             	sub    $0x10,%esp
  acquire(&ptable.lock);  //DOC: yieldlock
80104487:	68 60 2d 21 80       	push   $0x80212d60
8010448c:	e8 0f 07 00 00       	call   80104ba0 <acquire>
  pushcli();
80104491:	e8 ba 05 00 00       	call   80104a50 <pushcli>
  c = mycpu();
80104496:	e8 d5 f4 ff ff       	call   80103970 <mycpu>
  p = c->proc;
8010449b:	8b 98 ac 00 00 00    	mov    0xac(%eax),%ebx
  popcli();
801044a1:	e8 fa 05 00 00       	call   80104aa0 <popcli>
  myproc()->state = RUNNABLE;
801044a6:	c7 43 0c 03 00 00 00 	movl   $0x3,0xc(%ebx)
  sched();
801044ad:	e8 4e fa ff ff       	call   80103f00 <sched>
  release(&ptable.lock);
801044b2:	c7 04 24 60 2d 21 80 	movl   $0x80212d60,(%esp)
801044b9:	e8 82 06 00 00       	call   80104b40 <release>
}
801044be:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801044c1:	83 c4 10             	add    $0x10,%esp
801044c4:	c9                   	leave  
801044c5:	c3                   	ret    
801044c6:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801044cd:	8d 76 00             	lea    0x0(%esi),%esi

801044d0 <sleep>:
{
801044d0:	55                   	push   %ebp
801044d1:	89 e5                	mov    %esp,%ebp
801044d3:	57                   	push   %edi
801044d4:	56                   	push   %esi
801044d5:	53                   	push   %ebx
801044d6:	83 ec 0c             	sub    $0xc,%esp
801044d9:	8b 7d 08             	mov    0x8(%ebp),%edi
801044dc:	8b 75 0c             	mov    0xc(%ebp),%esi
  pushcli();
801044df:	e8 6c 05 00 00       	call   80104a50 <pushcli>
  c = mycpu();
801044e4:	e8 87 f4 ff ff       	call   80103970 <mycpu>
  p = c->proc;
801044e9:	8b 98 ac 00 00 00    	mov    0xac(%eax),%ebx
  popcli();
801044ef:	e8 ac 05 00 00       	call   80104aa0 <popcli>
  if(p == 0)
801044f4:	85 db                	test   %ebx,%ebx
801044f6:	0f 84 87 00 00 00    	je     80104583 <sleep+0xb3>
  if(lk == 0)
801044fc:	85 f6                	test   %esi,%esi
801044fe:	74 76                	je     80104576 <sleep+0xa6>
  if(lk != &ptable.lock){  //DOC: sleeplock0
80104500:	81 fe 60 2d 21 80    	cmp    $0x80212d60,%esi
80104506:	74 50                	je     80104558 <sleep+0x88>
    acquire(&ptable.lock);  //DOC: sleeplock1
80104508:	83 ec 0c             	sub    $0xc,%esp
8010450b:	68 60 2d 21 80       	push   $0x80212d60
80104510:	e8 8b 06 00 00       	call   80104ba0 <acquire>
    release(lk);
80104515:	89 34 24             	mov    %esi,(%esp)
80104518:	e8 23 06 00 00       	call   80104b40 <release>
  p->chan = chan;
8010451d:	89 7b 20             	mov    %edi,0x20(%ebx)
  p->state = SLEEPING;
80104520:	c7 43 0c 02 00 00 00 	movl   $0x2,0xc(%ebx)
  sched();
80104527:	e8 d4 f9 ff ff       	call   80103f00 <sched>
  p->chan = 0;
8010452c:	c7 43 20 00 00 00 00 	movl   $0x0,0x20(%ebx)
    release(&ptable.lock);
80104533:	c7 04 24 60 2d 21 80 	movl   $0x80212d60,(%esp)
8010453a:	e8 01 06 00 00       	call   80104b40 <release>
    acquire(lk);
8010453f:	89 75 08             	mov    %esi,0x8(%ebp)
80104542:	83 c4 10             	add    $0x10,%esp
}
80104545:	8d 65 f4             	lea    -0xc(%ebp),%esp
80104548:	5b                   	pop    %ebx
80104549:	5e                   	pop    %esi
8010454a:	5f                   	pop    %edi
8010454b:	5d                   	pop    %ebp
    acquire(lk);
8010454c:	e9 4f 06 00 00       	jmp    80104ba0 <acquire>
80104551:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  p->chan = chan;
80104558:	89 7b 20             	mov    %edi,0x20(%ebx)
  p->state = SLEEPING;
8010455b:	c7 43 0c 02 00 00 00 	movl   $0x2,0xc(%ebx)
  sched();
80104562:	e8 99 f9 ff ff       	call   80103f00 <sched>
  p->chan = 0;
80104567:	c7 43 20 00 00 00 00 	movl   $0x0,0x20(%ebx)
}
8010456e:	8d 65 f4             	lea    -0xc(%ebp),%esp
80104571:	5b                   	pop    %ebx
80104572:	5e                   	pop    %esi
80104573:	5f                   	pop    %edi
80104574:	5d                   	pop    %ebp
80104575:	c3                   	ret    
    panic("sleep without lk");
80104576:	83 ec 0c             	sub    $0xc,%esp
80104579:	68 7a 86 10 80       	push   $0x8010867a
8010457e:	e8 fd bd ff ff       	call   80100380 <panic>
    panic("sleep");
80104583:	83 ec 0c             	sub    $0xc,%esp
80104586:	68 74 86 10 80       	push   $0x80108674
8010458b:	e8 f0 bd ff ff       	call   80100380 <panic>

80104590 <wakeup>:
}

// Wake up all processes sleeping on chan.
void
wakeup(void *chan)
{
80104590:	55                   	push   %ebp
80104591:	89 e5                	mov    %esp,%ebp
80104593:	53                   	push   %ebx
80104594:	83 ec 10             	sub    $0x10,%esp
80104597:	8b 5d 08             	mov    0x8(%ebp),%ebx
  acquire(&ptable.lock);
8010459a:	68 60 2d 21 80       	push   $0x80212d60
8010459f:	e8 fc 05 00 00       	call   80104ba0 <acquire>
801045a4:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
801045a7:	b8 94 2d 21 80       	mov    $0x80212d94,%eax
801045ac:	eb 0e                	jmp    801045bc <wakeup+0x2c>
801045ae:	66 90                	xchg   %ax,%ax
801045b0:	05 c0 01 00 00       	add    $0x1c0,%eax
801045b5:	3d 94 9d 21 80       	cmp    $0x80219d94,%eax
801045ba:	74 1e                	je     801045da <wakeup+0x4a>
    if(p->state == SLEEPING && p->chan == chan)
801045bc:	83 78 0c 02          	cmpl   $0x2,0xc(%eax)
801045c0:	75 ee                	jne    801045b0 <wakeup+0x20>
801045c2:	3b 58 20             	cmp    0x20(%eax),%ebx
801045c5:	75 e9                	jne    801045b0 <wakeup+0x20>
      p->state = RUNNABLE;
801045c7:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
801045ce:	05 c0 01 00 00       	add    $0x1c0,%eax
801045d3:	3d 94 9d 21 80       	cmp    $0x80219d94,%eax
801045d8:	75 e2                	jne    801045bc <wakeup+0x2c>
  wakeup1(chan);
  release(&ptable.lock);
801045da:	c7 45 08 60 2d 21 80 	movl   $0x80212d60,0x8(%ebp)
}
801045e1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801045e4:	c9                   	leave  
  release(&ptable.lock);
801045e5:	e9 56 05 00 00       	jmp    80104b40 <release>
801045ea:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

801045f0 <kill>:
// Kill the process with the given pid.
// Process won't exit until it returns
// to user space (see trap in trap.c).
int
kill(int pid)
{
801045f0:	55                   	push   %ebp
801045f1:	89 e5                	mov    %esp,%ebp
801045f3:	53                   	push   %ebx
801045f4:	83 ec 10             	sub    $0x10,%esp
801045f7:	8b 5d 08             	mov    0x8(%ebp),%ebx
  struct proc *p;

  acquire(&ptable.lock);
801045fa:	68 60 2d 21 80       	push   $0x80212d60
801045ff:	e8 9c 05 00 00       	call   80104ba0 <acquire>
80104604:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104607:	b8 94 2d 21 80       	mov    $0x80212d94,%eax
8010460c:	eb 0e                	jmp    8010461c <kill+0x2c>
8010460e:	66 90                	xchg   %ax,%ax
80104610:	05 c0 01 00 00       	add    $0x1c0,%eax
80104615:	3d 94 9d 21 80       	cmp    $0x80219d94,%eax
8010461a:	74 34                	je     80104650 <kill+0x60>
    if(p->pid == pid){
8010461c:	39 58 10             	cmp    %ebx,0x10(%eax)
8010461f:	75 ef                	jne    80104610 <kill+0x20>
      p->killed = 1;
      // Wake process from sleep if necessary.
      if(p->state == SLEEPING)
80104621:	83 78 0c 02          	cmpl   $0x2,0xc(%eax)
      p->killed = 1;
80104625:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
      if(p->state == SLEEPING)
8010462c:	75 07                	jne    80104635 <kill+0x45>
        p->state = RUNNABLE;
8010462e:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
      release(&ptable.lock);
80104635:	83 ec 0c             	sub    $0xc,%esp
80104638:	68 60 2d 21 80       	push   $0x80212d60
8010463d:	e8 fe 04 00 00       	call   80104b40 <release>
      return 0;
    }
  }
  release(&ptable.lock);
  return -1;
}
80104642:	8b 5d fc             	mov    -0x4(%ebp),%ebx
      return 0;
80104645:	83 c4 10             	add    $0x10,%esp
80104648:	31 c0                	xor    %eax,%eax
}
8010464a:	c9                   	leave  
8010464b:	c3                   	ret    
8010464c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  release(&ptable.lock);
80104650:	83 ec 0c             	sub    $0xc,%esp
80104653:	68 60 2d 21 80       	push   $0x80212d60
80104658:	e8 e3 04 00 00       	call   80104b40 <release>
}
8010465d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  return -1;
80104660:	83 c4 10             	add    $0x10,%esp
80104663:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104668:	c9                   	leave  
80104669:	c3                   	ret    
8010466a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

80104670 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
80104670:	55                   	push   %ebp
80104671:	89 e5                	mov    %esp,%ebp
80104673:	57                   	push   %edi
80104674:	56                   	push   %esi
80104675:	8d 75 e8             	lea    -0x18(%ebp),%esi
80104678:	53                   	push   %ebx
80104679:	bb 00 2e 21 80       	mov    $0x80212e00,%ebx
8010467e:	83 ec 3c             	sub    $0x3c,%esp
80104681:	eb 27                	jmp    801046aa <procdump+0x3a>
80104683:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80104687:	90                   	nop
    if(p->state == SLEEPING){
      getcallerpcs((uint*)p->context->ebp+2, pc);
      for(i=0; i<10 && pc[i] != 0; i++)
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
80104688:	83 ec 0c             	sub    $0xc,%esp
8010468b:	68 fb 8c 10 80       	push   $0x80108cfb
80104690:	e8 0b c0 ff ff       	call   801006a0 <cprintf>
80104695:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104698:	81 c3 c0 01 00 00    	add    $0x1c0,%ebx
8010469e:	81 fb 00 9e 21 80    	cmp    $0x80219e00,%ebx
801046a4:	0f 84 7e 00 00 00    	je     80104728 <procdump+0xb8>
    if(p->state == UNUSED)
801046aa:	8b 43 a0             	mov    -0x60(%ebx),%eax
801046ad:	85 c0                	test   %eax,%eax
801046af:	74 e7                	je     80104698 <procdump+0x28>
      state = "???";
801046b1:	ba 8b 86 10 80       	mov    $0x8010868b,%edx
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
801046b6:	83 f8 05             	cmp    $0x5,%eax
801046b9:	77 11                	ja     801046cc <procdump+0x5c>
801046bb:	8b 14 85 7c 87 10 80 	mov    -0x7fef7884(,%eax,4),%edx
      state = "???";
801046c2:	b8 8b 86 10 80       	mov    $0x8010868b,%eax
801046c7:	85 d2                	test   %edx,%edx
801046c9:	0f 44 d0             	cmove  %eax,%edx
    cprintf("%d %s %s", p->pid, state, p->name);
801046cc:	53                   	push   %ebx
801046cd:	52                   	push   %edx
801046ce:	ff 73 a4             	push   -0x5c(%ebx)
801046d1:	68 8f 86 10 80       	push   $0x8010868f
801046d6:	e8 c5 bf ff ff       	call   801006a0 <cprintf>
    if(p->state == SLEEPING){
801046db:	83 c4 10             	add    $0x10,%esp
801046de:	83 7b a0 02          	cmpl   $0x2,-0x60(%ebx)
801046e2:	75 a4                	jne    80104688 <procdump+0x18>
      getcallerpcs((uint*)p->context->ebp+2, pc);
801046e4:	83 ec 08             	sub    $0x8,%esp
801046e7:	8d 45 c0             	lea    -0x40(%ebp),%eax
801046ea:	8d 7d c0             	lea    -0x40(%ebp),%edi
801046ed:	50                   	push   %eax
801046ee:	8b 43 b0             	mov    -0x50(%ebx),%eax
801046f1:	8b 40 0c             	mov    0xc(%eax),%eax
801046f4:	83 c0 08             	add    $0x8,%eax
801046f7:	50                   	push   %eax
801046f8:	e8 f3 02 00 00       	call   801049f0 <getcallerpcs>
      for(i=0; i<10 && pc[i] != 0; i++)
801046fd:	83 c4 10             	add    $0x10,%esp
80104700:	8b 17                	mov    (%edi),%edx
80104702:	85 d2                	test   %edx,%edx
80104704:	74 82                	je     80104688 <procdump+0x18>
        cprintf(" %p", pc[i]);
80104706:	83 ec 08             	sub    $0x8,%esp
      for(i=0; i<10 && pc[i] != 0; i++)
80104709:	83 c7 04             	add    $0x4,%edi
        cprintf(" %p", pc[i]);
8010470c:	52                   	push   %edx
8010470d:	68 e1 80 10 80       	push   $0x801080e1
80104712:	e8 89 bf ff ff       	call   801006a0 <cprintf>
      for(i=0; i<10 && pc[i] != 0; i++)
80104717:	83 c4 10             	add    $0x10,%esp
8010471a:	39 fe                	cmp    %edi,%esi
8010471c:	75 e2                	jne    80104700 <procdump+0x90>
8010471e:	e9 65 ff ff ff       	jmp    80104688 <procdump+0x18>
80104723:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80104727:	90                   	nop
  }
}
80104728:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010472b:	5b                   	pop    %ebx
8010472c:	5e                   	pop    %esi
8010472d:	5f                   	pop    %edi
8010472e:	5d                   	pop    %ebp
8010472f:	c3                   	ret    

80104730 <proc_wmap>:

struct spinlock mmap_lock;

int proc_wmap(uint addr, int length, int flags, int fd) {
80104730:	55                   	push   %ebp
80104731:	89 e5                	mov    %esp,%ebp
80104733:	57                   	push   %edi
80104734:	56                   	push   %esi
80104735:	53                   	push   %ebx
80104736:	83 ec 1c             	sub    $0x1c,%esp
80104739:	8b 5d 08             	mov    0x8(%ebp),%ebx
  pushcli();
8010473c:	e8 0f 03 00 00       	call   80104a50 <pushcli>
  c = mycpu();
80104741:	e8 2a f2 ff ff       	call   80103970 <mycpu>
  p = c->proc;
80104746:	8b b0 ac 00 00 00    	mov    0xac(%eax),%esi
  popcli();
8010474c:	e8 4f 03 00 00       	call   80104aa0 <popcli>
    struct proc *curproc = myproc();
    acquire(&mmap_lock);  // Acquire the mmap lock
80104751:	83 ec 0c             	sub    $0xc,%esp
80104754:	68 20 2d 21 80       	push   $0x80212d20
80104759:	e8 42 04 00 00       	call   80104ba0 <acquire>

    // Ensure we do not exceed the maximum number of allowed mappings
    if (curproc->num_mmap_regions >= MAX_WMMAP_INFO) {
8010475e:	8b 86 bc 01 00 00    	mov    0x1bc(%esi),%eax
80104764:	83 c4 10             	add    $0x10,%esp
80104767:	89 45 e4             	mov    %eax,-0x1c(%ebp)
8010476a:	83 f8 0f             	cmp    $0xf,%eax
8010476d:	7f 65                	jg     801047d4 <proc_wmap+0xa4>
        release(&mmap_lock);  // Release lock before returning
        return FAILED;
    }

    // Check for overlapping regions
    for (int i = 0; i < curproc->num_mmap_regions; i++) {
8010476f:	85 c0                	test   %eax,%eax
80104771:	7e 36                	jle    801047a9 <proc_wmap+0x79>
80104773:	8b 7d e4             	mov    -0x1c(%ebp),%edi
        struct mmap_region *existing_region = &curproc->mmap_regions[i];
        uint end_addr = existing_region->start_addr + existing_region->length;
        if (!(addr + length <= existing_region->start_addr || addr >= end_addr)) {
80104776:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80104779:	8d 46 7c             	lea    0x7c(%esi),%eax
8010477c:	89 75 e0             	mov    %esi,-0x20(%ebp)
8010477f:	01 d9                	add    %ebx,%ecx
80104781:	8d 14 bf             	lea    (%edi,%edi,4),%edx
80104784:	8d 3c 90             	lea    (%eax,%edx,4),%edi
80104787:	89 ce                	mov    %ecx,%esi
80104789:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
        uint end_addr = existing_region->start_addr + existing_region->length;
80104790:	8b 10                	mov    (%eax),%edx
80104792:	8b 48 04             	mov    0x4(%eax),%ecx
80104795:	01 d1                	add    %edx,%ecx
        if (!(addr + length <= existing_region->start_addr || addr >= end_addr)) {
80104797:	39 cb                	cmp    %ecx,%ebx
80104799:	73 04                	jae    8010479f <proc_wmap+0x6f>
8010479b:	39 f2                	cmp    %esi,%edx
8010479d:	72 35                	jb     801047d4 <proc_wmap+0xa4>
    for (int i = 0; i < curproc->num_mmap_regions; i++) {
8010479f:	83 c0 14             	add    $0x14,%eax
801047a2:	39 c7                	cmp    %eax,%edi
801047a4:	75 ea                	jne    80104790 <proc_wmap+0x60>
801047a6:	8b 75 e0             	mov    -0x20(%ebp),%esi
            return FAILED;  // Overlap detected
        }
    }

    // Handle file descriptor and reference counting
    struct file *f = (flags & MAP_ANONYMOUS) ? 0 : curproc->ofile[fd];
801047a9:	8b 7d 10             	mov    0x10(%ebp),%edi
801047ac:	83 e7 04             	and    $0x4,%edi
801047af:	75 47                	jne    801047f8 <proc_wmap+0xc8>
801047b1:	8b 45 14             	mov    0x14(%ebp),%eax
801047b4:	8b 44 86 28          	mov    0x28(%esi,%eax,4),%eax
    if (f == 0 && !(flags & MAP_ANONYMOUS)) {
801047b8:	85 c0                	test   %eax,%eax
801047ba:	74 18                	je     801047d4 <proc_wmap+0xa4>
801047bc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

    int dup_fd = -1;
    if (!(flags & MAP_ANONYMOUS)) {
        dup_fd = -1;
        for (int i = 0; i < NOFILE; i++) {
            if (curproc->ofile[i] == 0) {
801047c0:	8b 54 be 28          	mov    0x28(%esi,%edi,4),%edx
801047c4:	85 d2                	test   %edx,%edx
801047c6:	0f 84 94 00 00 00    	je     80104860 <proc_wmap+0x130>
        for (int i = 0; i < NOFILE; i++) {
801047cc:	83 c7 01             	add    $0x1,%edi
801047cf:	83 ff 10             	cmp    $0x10,%edi
801047d2:	75 ec                	jne    801047c0 <proc_wmap+0x90>
        release(&mmap_lock);  // Release lock before returning
801047d4:	83 ec 0c             	sub    $0xc,%esp
801047d7:	68 20 2d 21 80       	push   $0x80212d20
801047dc:	e8 5f 03 00 00       	call   80104b40 <release>
        return FAILED;
801047e1:	83 c4 10             	add    $0x10,%esp
    region->fd = (flags & MAP_ANONYMOUS) ? -1 : dup_fd;  // Use the duplicated fd
    region->n_loaded_pages = 0;

    release(&mmap_lock);  // Release the mmap lock
    return addr;
801047e4:	8d 65 f4             	lea    -0xc(%ebp),%esp
        return FAILED;
801047e7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801047ec:	5b                   	pop    %ebx
801047ed:	5e                   	pop    %esi
801047ee:	5f                   	pop    %edi
801047ef:	5d                   	pop    %ebp
801047f0:	c3                   	ret    
801047f1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    struct mmap_region *region = &curproc->mmap_regions[curproc->num_mmap_regions++];
801047f8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
801047fb:	8d 47 01             	lea    0x1(%edi),%eax
801047fe:	89 86 bc 01 00 00    	mov    %eax,0x1bc(%esi)
    region->start_addr = addr;
80104804:	8d 04 bf             	lea    (%edi,%edi,4),%eax
    region->length = length;
80104807:	8b 7d 0c             	mov    0xc(%ebp),%edi
    region->start_addr = addr;
8010480a:	8d 04 86             	lea    (%esi,%eax,4),%eax
    region->length = length;
8010480d:	89 b8 80 00 00 00    	mov    %edi,0x80(%eax)
    region->flags = flags;
80104813:	8b 7d 10             	mov    0x10(%ebp),%edi
    region->start_addr = addr;
80104816:	89 58 7c             	mov    %ebx,0x7c(%eax)
    region->flags = flags;
80104819:	89 b8 84 00 00 00    	mov    %edi,0x84(%eax)
    region->fd = (flags & MAP_ANONYMOUS) ? -1 : dup_fd;  // Use the duplicated fd
8010481f:	bf ff ff ff ff       	mov    $0xffffffff,%edi
80104824:	8b 45 e4             	mov    -0x1c(%ebp),%eax
    release(&mmap_lock);  // Release the mmap lock
80104827:	83 ec 0c             	sub    $0xc,%esp
    region->fd = (flags & MAP_ANONYMOUS) ? -1 : dup_fd;  // Use the duplicated fd
8010482a:	8d 04 80             	lea    (%eax,%eax,4),%eax
8010482d:	8d 04 86             	lea    (%esi,%eax,4),%eax
80104830:	89 b8 88 00 00 00    	mov    %edi,0x88(%eax)
    region->n_loaded_pages = 0;
80104836:	c7 80 8c 00 00 00 00 	movl   $0x0,0x8c(%eax)
8010483d:	00 00 00 
    release(&mmap_lock);  // Release the mmap lock
80104840:	68 20 2d 21 80       	push   $0x80212d20
80104845:	e8 f6 02 00 00       	call   80104b40 <release>
    return addr;
8010484a:	83 c4 10             	add    $0x10,%esp
8010484d:	8d 65 f4             	lea    -0xc(%ebp),%esp
    return addr;
80104850:	89 d8                	mov    %ebx,%eax
80104852:	5b                   	pop    %ebx
80104853:	5e                   	pop    %esi
80104854:	5f                   	pop    %edi
80104855:	5d                   	pop    %ebp
80104856:	c3                   	ret    
80104857:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010485e:	66 90                	xchg   %ax,%ax
                curproc->ofile[i] = filedup(f);  // Duplicate the file descriptor
80104860:	83 ec 0c             	sub    $0xc,%esp
80104863:	50                   	push   %eax
80104864:	e8 47 c6 ff ff       	call   80100eb0 <filedup>
    region->flags = flags;
80104869:	83 c4 10             	add    $0x10,%esp
                curproc->ofile[i] = filedup(f);  // Duplicate the file descriptor
8010486c:	89 44 be 28          	mov    %eax,0x28(%esi,%edi,4)
    struct mmap_region *region = &curproc->mmap_regions[curproc->num_mmap_regions++];
80104870:	8b 96 bc 01 00 00    	mov    0x1bc(%esi),%edx
80104876:	8d 42 01             	lea    0x1(%edx),%eax
80104879:	89 55 e4             	mov    %edx,-0x1c(%ebp)
8010487c:	89 86 bc 01 00 00    	mov    %eax,0x1bc(%esi)
    region->start_addr = addr;
80104882:	8d 04 92             	lea    (%edx,%edx,4),%eax
    region->length = length;
80104885:	8b 55 0c             	mov    0xc(%ebp),%edx
    region->start_addr = addr;
80104888:	8d 04 86             	lea    (%esi,%eax,4),%eax
    region->length = length;
8010488b:	89 90 80 00 00 00    	mov    %edx,0x80(%eax)
    region->flags = flags;
80104891:	8b 55 10             	mov    0x10(%ebp),%edx
    region->start_addr = addr;
80104894:	89 58 7c             	mov    %ebx,0x7c(%eax)
    region->flags = flags;
80104897:	89 90 84 00 00 00    	mov    %edx,0x84(%eax)
    region->fd = (flags & MAP_ANONYMOUS) ? -1 : dup_fd;  // Use the duplicated fd
8010489d:	eb 85                	jmp    80104824 <proc_wmap+0xf4>
8010489f:	90                   	nop

801048a0 <initsleeplock>:
#include "spinlock.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
801048a0:	55                   	push   %ebp
801048a1:	89 e5                	mov    %esp,%ebp
801048a3:	53                   	push   %ebx
801048a4:	83 ec 0c             	sub    $0xc,%esp
801048a7:	8b 5d 08             	mov    0x8(%ebp),%ebx
  initlock(&lk->lk, "sleep lock");
801048aa:	68 94 87 10 80       	push   $0x80108794
801048af:	8d 43 04             	lea    0x4(%ebx),%eax
801048b2:	50                   	push   %eax
801048b3:	e8 18 01 00 00       	call   801049d0 <initlock>
  lk->name = name;
801048b8:	8b 45 0c             	mov    0xc(%ebp),%eax
  lk->locked = 0;
801048bb:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  lk->pid = 0;
}
801048c1:	83 c4 10             	add    $0x10,%esp
  lk->pid = 0;
801048c4:	c7 43 3c 00 00 00 00 	movl   $0x0,0x3c(%ebx)
  lk->name = name;
801048cb:	89 43 38             	mov    %eax,0x38(%ebx)
}
801048ce:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801048d1:	c9                   	leave  
801048d2:	c3                   	ret    
801048d3:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801048da:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

801048e0 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
801048e0:	55                   	push   %ebp
801048e1:	89 e5                	mov    %esp,%ebp
801048e3:	56                   	push   %esi
801048e4:	53                   	push   %ebx
801048e5:	8b 5d 08             	mov    0x8(%ebp),%ebx
  acquire(&lk->lk);
801048e8:	8d 73 04             	lea    0x4(%ebx),%esi
801048eb:	83 ec 0c             	sub    $0xc,%esp
801048ee:	56                   	push   %esi
801048ef:	e8 ac 02 00 00       	call   80104ba0 <acquire>
  while (lk->locked) {
801048f4:	8b 13                	mov    (%ebx),%edx
801048f6:	83 c4 10             	add    $0x10,%esp
801048f9:	85 d2                	test   %edx,%edx
801048fb:	74 16                	je     80104913 <acquiresleep+0x33>
801048fd:	8d 76 00             	lea    0x0(%esi),%esi
    sleep(lk, &lk->lk);
80104900:	83 ec 08             	sub    $0x8,%esp
80104903:	56                   	push   %esi
80104904:	53                   	push   %ebx
80104905:	e8 c6 fb ff ff       	call   801044d0 <sleep>
  while (lk->locked) {
8010490a:	8b 03                	mov    (%ebx),%eax
8010490c:	83 c4 10             	add    $0x10,%esp
8010490f:	85 c0                	test   %eax,%eax
80104911:	75 ed                	jne    80104900 <acquiresleep+0x20>
  }
  lk->locked = 1;
80104913:	c7 03 01 00 00 00    	movl   $0x1,(%ebx)
  lk->pid = myproc()->pid;
80104919:	e8 d2 f0 ff ff       	call   801039f0 <myproc>
8010491e:	8b 40 10             	mov    0x10(%eax),%eax
80104921:	89 43 3c             	mov    %eax,0x3c(%ebx)
  release(&lk->lk);
80104924:	89 75 08             	mov    %esi,0x8(%ebp)
}
80104927:	8d 65 f8             	lea    -0x8(%ebp),%esp
8010492a:	5b                   	pop    %ebx
8010492b:	5e                   	pop    %esi
8010492c:	5d                   	pop    %ebp
  release(&lk->lk);
8010492d:	e9 0e 02 00 00       	jmp    80104b40 <release>
80104932:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80104939:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

80104940 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
80104940:	55                   	push   %ebp
80104941:	89 e5                	mov    %esp,%ebp
80104943:	56                   	push   %esi
80104944:	53                   	push   %ebx
80104945:	8b 5d 08             	mov    0x8(%ebp),%ebx
  acquire(&lk->lk);
80104948:	8d 73 04             	lea    0x4(%ebx),%esi
8010494b:	83 ec 0c             	sub    $0xc,%esp
8010494e:	56                   	push   %esi
8010494f:	e8 4c 02 00 00       	call   80104ba0 <acquire>
  lk->locked = 0;
80104954:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  lk->pid = 0;
8010495a:	c7 43 3c 00 00 00 00 	movl   $0x0,0x3c(%ebx)
  wakeup(lk);
80104961:	89 1c 24             	mov    %ebx,(%esp)
80104964:	e8 27 fc ff ff       	call   80104590 <wakeup>
  release(&lk->lk);
80104969:	89 75 08             	mov    %esi,0x8(%ebp)
8010496c:	83 c4 10             	add    $0x10,%esp
}
8010496f:	8d 65 f8             	lea    -0x8(%ebp),%esp
80104972:	5b                   	pop    %ebx
80104973:	5e                   	pop    %esi
80104974:	5d                   	pop    %ebp
  release(&lk->lk);
80104975:	e9 c6 01 00 00       	jmp    80104b40 <release>
8010497a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

80104980 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
80104980:	55                   	push   %ebp
80104981:	89 e5                	mov    %esp,%ebp
80104983:	57                   	push   %edi
80104984:	31 ff                	xor    %edi,%edi
80104986:	56                   	push   %esi
80104987:	53                   	push   %ebx
80104988:	83 ec 18             	sub    $0x18,%esp
8010498b:	8b 5d 08             	mov    0x8(%ebp),%ebx
  int r;
  
  acquire(&lk->lk);
8010498e:	8d 73 04             	lea    0x4(%ebx),%esi
80104991:	56                   	push   %esi
80104992:	e8 09 02 00 00       	call   80104ba0 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
80104997:	8b 03                	mov    (%ebx),%eax
80104999:	83 c4 10             	add    $0x10,%esp
8010499c:	85 c0                	test   %eax,%eax
8010499e:	75 18                	jne    801049b8 <holdingsleep+0x38>
  release(&lk->lk);
801049a0:	83 ec 0c             	sub    $0xc,%esp
801049a3:	56                   	push   %esi
801049a4:	e8 97 01 00 00       	call   80104b40 <release>
  return r;
}
801049a9:	8d 65 f4             	lea    -0xc(%ebp),%esp
801049ac:	89 f8                	mov    %edi,%eax
801049ae:	5b                   	pop    %ebx
801049af:	5e                   	pop    %esi
801049b0:	5f                   	pop    %edi
801049b1:	5d                   	pop    %ebp
801049b2:	c3                   	ret    
801049b3:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
801049b7:	90                   	nop
  r = lk->locked && (lk->pid == myproc()->pid);
801049b8:	8b 5b 3c             	mov    0x3c(%ebx),%ebx
801049bb:	e8 30 f0 ff ff       	call   801039f0 <myproc>
801049c0:	39 58 10             	cmp    %ebx,0x10(%eax)
801049c3:	0f 94 c0             	sete   %al
801049c6:	0f b6 c0             	movzbl %al,%eax
801049c9:	89 c7                	mov    %eax,%edi
801049cb:	eb d3                	jmp    801049a0 <holdingsleep+0x20>
801049cd:	66 90                	xchg   %ax,%ax
801049cf:	90                   	nop

801049d0 <initlock>:
#include "proc.h"
#include "spinlock.h"

void
initlock(struct spinlock *lk, char *name)
{
801049d0:	55                   	push   %ebp
801049d1:	89 e5                	mov    %esp,%ebp
801049d3:	8b 45 08             	mov    0x8(%ebp),%eax
  lk->name = name;
801049d6:	8b 55 0c             	mov    0xc(%ebp),%edx
  lk->locked = 0;
801049d9:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->name = name;
801049df:	89 50 04             	mov    %edx,0x4(%eax)
  lk->cpu = 0;
801049e2:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
}
801049e9:	5d                   	pop    %ebp
801049ea:	c3                   	ret    
801049eb:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
801049ef:	90                   	nop

801049f0 <getcallerpcs>:
}

// Record the current call stack in pcs[] by following the %ebp chain.
void
getcallerpcs(void *v, uint pcs[])
{
801049f0:	55                   	push   %ebp
  uint *ebp;
  int i;

  ebp = (uint*)v - 2;
  for(i = 0; i < 10; i++){
801049f1:	31 d2                	xor    %edx,%edx
{
801049f3:	89 e5                	mov    %esp,%ebp
801049f5:	53                   	push   %ebx
  ebp = (uint*)v - 2;
801049f6:	8b 45 08             	mov    0x8(%ebp),%eax
{
801049f9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  ebp = (uint*)v - 2;
801049fc:	83 e8 08             	sub    $0x8,%eax
  for(i = 0; i < 10; i++){
801049ff:	90                   	nop
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
80104a00:	8d 98 00 00 00 80    	lea    -0x80000000(%eax),%ebx
80104a06:	81 fb fe ff ff 7f    	cmp    $0x7ffffffe,%ebx
80104a0c:	77 1a                	ja     80104a28 <getcallerpcs+0x38>
      break;
    pcs[i] = ebp[1];     // saved %eip
80104a0e:	8b 58 04             	mov    0x4(%eax),%ebx
80104a11:	89 1c 91             	mov    %ebx,(%ecx,%edx,4)
  for(i = 0; i < 10; i++){
80104a14:	83 c2 01             	add    $0x1,%edx
    ebp = (uint*)ebp[0]; // saved %ebp
80104a17:	8b 00                	mov    (%eax),%eax
  for(i = 0; i < 10; i++){
80104a19:	83 fa 0a             	cmp    $0xa,%edx
80104a1c:	75 e2                	jne    80104a00 <getcallerpcs+0x10>
  }
  for(; i < 10; i++)
    pcs[i] = 0;
}
80104a1e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104a21:	c9                   	leave  
80104a22:	c3                   	ret    
80104a23:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80104a27:	90                   	nop
  for(; i < 10; i++)
80104a28:	8d 04 91             	lea    (%ecx,%edx,4),%eax
80104a2b:	8d 51 28             	lea    0x28(%ecx),%edx
80104a2e:	66 90                	xchg   %ax,%ax
    pcs[i] = 0;
80104a30:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  for(; i < 10; i++)
80104a36:	83 c0 04             	add    $0x4,%eax
80104a39:	39 d0                	cmp    %edx,%eax
80104a3b:	75 f3                	jne    80104a30 <getcallerpcs+0x40>
}
80104a3d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104a40:	c9                   	leave  
80104a41:	c3                   	ret    
80104a42:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80104a49:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

80104a50 <pushcli>:
// it takes two popcli to undo two pushcli.  Also, if interrupts
// are off, then pushcli, popcli leaves them off.

void
pushcli(void)
{
80104a50:	55                   	push   %ebp
80104a51:	89 e5                	mov    %esp,%ebp
80104a53:	53                   	push   %ebx
80104a54:	83 ec 04             	sub    $0x4,%esp
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80104a57:	9c                   	pushf  
80104a58:	5b                   	pop    %ebx
  asm volatile("cli");
80104a59:	fa                   	cli    
  int eflags;

  eflags = readeflags();
  cli();
  if(mycpu()->ncli == 0)
80104a5a:	e8 11 ef ff ff       	call   80103970 <mycpu>
80104a5f:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80104a65:	85 c0                	test   %eax,%eax
80104a67:	74 17                	je     80104a80 <pushcli+0x30>
    mycpu()->intena = eflags & FL_IF;
  mycpu()->ncli += 1;
80104a69:	e8 02 ef ff ff       	call   80103970 <mycpu>
80104a6e:	83 80 a4 00 00 00 01 	addl   $0x1,0xa4(%eax)
}
80104a75:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104a78:	c9                   	leave  
80104a79:	c3                   	ret    
80104a7a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    mycpu()->intena = eflags & FL_IF;
80104a80:	e8 eb ee ff ff       	call   80103970 <mycpu>
80104a85:	81 e3 00 02 00 00    	and    $0x200,%ebx
80104a8b:	89 98 a8 00 00 00    	mov    %ebx,0xa8(%eax)
80104a91:	eb d6                	jmp    80104a69 <pushcli+0x19>
80104a93:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80104a9a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

80104aa0 <popcli>:

void
popcli(void)
{
80104aa0:	55                   	push   %ebp
80104aa1:	89 e5                	mov    %esp,%ebp
80104aa3:	83 ec 08             	sub    $0x8,%esp
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80104aa6:	9c                   	pushf  
80104aa7:	58                   	pop    %eax
  if(readeflags()&FL_IF)
80104aa8:	f6 c4 02             	test   $0x2,%ah
80104aab:	75 35                	jne    80104ae2 <popcli+0x42>
    panic("popcli - interruptible");
  if(--mycpu()->ncli < 0)
80104aad:	e8 be ee ff ff       	call   80103970 <mycpu>
80104ab2:	83 a8 a4 00 00 00 01 	subl   $0x1,0xa4(%eax)
80104ab9:	78 34                	js     80104aef <popcli+0x4f>
    panic("popcli");
  if(mycpu()->ncli == 0 && mycpu()->intena)
80104abb:	e8 b0 ee ff ff       	call   80103970 <mycpu>
80104ac0:	8b 90 a4 00 00 00    	mov    0xa4(%eax),%edx
80104ac6:	85 d2                	test   %edx,%edx
80104ac8:	74 06                	je     80104ad0 <popcli+0x30>
    sti();
}
80104aca:	c9                   	leave  
80104acb:	c3                   	ret    
80104acc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  if(mycpu()->ncli == 0 && mycpu()->intena)
80104ad0:	e8 9b ee ff ff       	call   80103970 <mycpu>
80104ad5:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
80104adb:	85 c0                	test   %eax,%eax
80104add:	74 eb                	je     80104aca <popcli+0x2a>
  asm volatile("sti");
80104adf:	fb                   	sti    
}
80104ae0:	c9                   	leave  
80104ae1:	c3                   	ret    
    panic("popcli - interruptible");
80104ae2:	83 ec 0c             	sub    $0xc,%esp
80104ae5:	68 9f 87 10 80       	push   $0x8010879f
80104aea:	e8 91 b8 ff ff       	call   80100380 <panic>
    panic("popcli");
80104aef:	83 ec 0c             	sub    $0xc,%esp
80104af2:	68 b6 87 10 80       	push   $0x801087b6
80104af7:	e8 84 b8 ff ff       	call   80100380 <panic>
80104afc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

80104b00 <holding>:
{
80104b00:	55                   	push   %ebp
80104b01:	89 e5                	mov    %esp,%ebp
80104b03:	56                   	push   %esi
80104b04:	53                   	push   %ebx
80104b05:	8b 75 08             	mov    0x8(%ebp),%esi
80104b08:	31 db                	xor    %ebx,%ebx
  pushcli();
80104b0a:	e8 41 ff ff ff       	call   80104a50 <pushcli>
  r = lock->locked && lock->cpu == mycpu();
80104b0f:	8b 06                	mov    (%esi),%eax
80104b11:	85 c0                	test   %eax,%eax
80104b13:	75 0b                	jne    80104b20 <holding+0x20>
  popcli();
80104b15:	e8 86 ff ff ff       	call   80104aa0 <popcli>
}
80104b1a:	89 d8                	mov    %ebx,%eax
80104b1c:	5b                   	pop    %ebx
80104b1d:	5e                   	pop    %esi
80104b1e:	5d                   	pop    %ebp
80104b1f:	c3                   	ret    
  r = lock->locked && lock->cpu == mycpu();
80104b20:	8b 5e 08             	mov    0x8(%esi),%ebx
80104b23:	e8 48 ee ff ff       	call   80103970 <mycpu>
80104b28:	39 c3                	cmp    %eax,%ebx
80104b2a:	0f 94 c3             	sete   %bl
  popcli();
80104b2d:	e8 6e ff ff ff       	call   80104aa0 <popcli>
  r = lock->locked && lock->cpu == mycpu();
80104b32:	0f b6 db             	movzbl %bl,%ebx
}
80104b35:	89 d8                	mov    %ebx,%eax
80104b37:	5b                   	pop    %ebx
80104b38:	5e                   	pop    %esi
80104b39:	5d                   	pop    %ebp
80104b3a:	c3                   	ret    
80104b3b:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80104b3f:	90                   	nop

80104b40 <release>:
{
80104b40:	55                   	push   %ebp
80104b41:	89 e5                	mov    %esp,%ebp
80104b43:	56                   	push   %esi
80104b44:	53                   	push   %ebx
80104b45:	8b 5d 08             	mov    0x8(%ebp),%ebx
  pushcli();
80104b48:	e8 03 ff ff ff       	call   80104a50 <pushcli>
  r = lock->locked && lock->cpu == mycpu();
80104b4d:	8b 03                	mov    (%ebx),%eax
80104b4f:	85 c0                	test   %eax,%eax
80104b51:	75 15                	jne    80104b68 <release+0x28>
  popcli();
80104b53:	e8 48 ff ff ff       	call   80104aa0 <popcli>
    panic("release");
80104b58:	83 ec 0c             	sub    $0xc,%esp
80104b5b:	68 bd 87 10 80       	push   $0x801087bd
80104b60:	e8 1b b8 ff ff       	call   80100380 <panic>
80104b65:	8d 76 00             	lea    0x0(%esi),%esi
  r = lock->locked && lock->cpu == mycpu();
80104b68:	8b 73 08             	mov    0x8(%ebx),%esi
80104b6b:	e8 00 ee ff ff       	call   80103970 <mycpu>
80104b70:	39 c6                	cmp    %eax,%esi
80104b72:	75 df                	jne    80104b53 <release+0x13>
  popcli();
80104b74:	e8 27 ff ff ff       	call   80104aa0 <popcli>
  lk->pcs[0] = 0;
80104b79:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
  lk->cpu = 0;
80104b80:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
  __sync_synchronize();
80104b87:	f0 83 0c 24 00       	lock orl $0x0,(%esp)
  asm volatile("movl $0, %0" : "+m" (lk->locked) : );
80104b8c:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
}
80104b92:	8d 65 f8             	lea    -0x8(%ebp),%esp
80104b95:	5b                   	pop    %ebx
80104b96:	5e                   	pop    %esi
80104b97:	5d                   	pop    %ebp
  popcli();
80104b98:	e9 03 ff ff ff       	jmp    80104aa0 <popcli>
80104b9d:	8d 76 00             	lea    0x0(%esi),%esi

80104ba0 <acquire>:
{
80104ba0:	55                   	push   %ebp
80104ba1:	89 e5                	mov    %esp,%ebp
80104ba3:	53                   	push   %ebx
80104ba4:	83 ec 04             	sub    $0x4,%esp
  pushcli(); // disable interrupts to avoid deadlock.
80104ba7:	e8 a4 fe ff ff       	call   80104a50 <pushcli>
  if(holding(lk))
80104bac:	8b 5d 08             	mov    0x8(%ebp),%ebx
  pushcli();
80104baf:	e8 9c fe ff ff       	call   80104a50 <pushcli>
  r = lock->locked && lock->cpu == mycpu();
80104bb4:	8b 03                	mov    (%ebx),%eax
80104bb6:	85 c0                	test   %eax,%eax
80104bb8:	75 7e                	jne    80104c38 <acquire+0x98>
  popcli();
80104bba:	e8 e1 fe ff ff       	call   80104aa0 <popcli>
  asm volatile("lock; xchgl %0, %1" :
80104bbf:	b9 01 00 00 00       	mov    $0x1,%ecx
80104bc4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  while(xchg(&lk->locked, 1) != 0)
80104bc8:	8b 55 08             	mov    0x8(%ebp),%edx
80104bcb:	89 c8                	mov    %ecx,%eax
80104bcd:	f0 87 02             	lock xchg %eax,(%edx)
80104bd0:	85 c0                	test   %eax,%eax
80104bd2:	75 f4                	jne    80104bc8 <acquire+0x28>
  __sync_synchronize();
80104bd4:	f0 83 0c 24 00       	lock orl $0x0,(%esp)
  lk->cpu = mycpu();
80104bd9:	8b 5d 08             	mov    0x8(%ebp),%ebx
80104bdc:	e8 8f ed ff ff       	call   80103970 <mycpu>
  getcallerpcs(&lk, lk->pcs);
80104be1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  ebp = (uint*)v - 2;
80104be4:	89 ea                	mov    %ebp,%edx
  lk->cpu = mycpu();
80104be6:	89 43 08             	mov    %eax,0x8(%ebx)
  for(i = 0; i < 10; i++){
80104be9:	31 c0                	xor    %eax,%eax
80104beb:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80104bef:	90                   	nop
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
80104bf0:	8d 9a 00 00 00 80    	lea    -0x80000000(%edx),%ebx
80104bf6:	81 fb fe ff ff 7f    	cmp    $0x7ffffffe,%ebx
80104bfc:	77 1a                	ja     80104c18 <acquire+0x78>
    pcs[i] = ebp[1];     // saved %eip
80104bfe:	8b 5a 04             	mov    0x4(%edx),%ebx
80104c01:	89 5c 81 0c          	mov    %ebx,0xc(%ecx,%eax,4)
  for(i = 0; i < 10; i++){
80104c05:	83 c0 01             	add    $0x1,%eax
    ebp = (uint*)ebp[0]; // saved %ebp
80104c08:	8b 12                	mov    (%edx),%edx
  for(i = 0; i < 10; i++){
80104c0a:	83 f8 0a             	cmp    $0xa,%eax
80104c0d:	75 e1                	jne    80104bf0 <acquire+0x50>
}
80104c0f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104c12:	c9                   	leave  
80104c13:	c3                   	ret    
80104c14:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  for(; i < 10; i++)
80104c18:	8d 44 81 0c          	lea    0xc(%ecx,%eax,4),%eax
80104c1c:	8d 51 34             	lea    0x34(%ecx),%edx
80104c1f:	90                   	nop
    pcs[i] = 0;
80104c20:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  for(; i < 10; i++)
80104c26:	83 c0 04             	add    $0x4,%eax
80104c29:	39 c2                	cmp    %eax,%edx
80104c2b:	75 f3                	jne    80104c20 <acquire+0x80>
}
80104c2d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104c30:	c9                   	leave  
80104c31:	c3                   	ret    
80104c32:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  r = lock->locked && lock->cpu == mycpu();
80104c38:	8b 5b 08             	mov    0x8(%ebx),%ebx
80104c3b:	e8 30 ed ff ff       	call   80103970 <mycpu>
80104c40:	39 c3                	cmp    %eax,%ebx
80104c42:	0f 85 72 ff ff ff    	jne    80104bba <acquire+0x1a>
  popcli();
80104c48:	e8 53 fe ff ff       	call   80104aa0 <popcli>
    panic("acquire");
80104c4d:	83 ec 0c             	sub    $0xc,%esp
80104c50:	68 c5 87 10 80       	push   $0x801087c5
80104c55:	e8 26 b7 ff ff       	call   80100380 <panic>
80104c5a:	66 90                	xchg   %ax,%ax
80104c5c:	66 90                	xchg   %ax,%ax
80104c5e:	66 90                	xchg   %ax,%ax

80104c60 <memset>:
#include "types.h"
#include "x86.h"

void*
memset(void *dst, int c, uint n)
{
80104c60:	55                   	push   %ebp
80104c61:	89 e5                	mov    %esp,%ebp
80104c63:	57                   	push   %edi
80104c64:	8b 55 08             	mov    0x8(%ebp),%edx
80104c67:	8b 4d 10             	mov    0x10(%ebp),%ecx
80104c6a:	53                   	push   %ebx
80104c6b:	8b 45 0c             	mov    0xc(%ebp),%eax
  if ((int)dst%4 == 0 && n%4 == 0){
80104c6e:	89 d7                	mov    %edx,%edi
80104c70:	09 cf                	or     %ecx,%edi
80104c72:	83 e7 03             	and    $0x3,%edi
80104c75:	75 29                	jne    80104ca0 <memset+0x40>
    c &= 0xFF;
80104c77:	0f b6 f8             	movzbl %al,%edi
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
80104c7a:	c1 e0 18             	shl    $0x18,%eax
80104c7d:	89 fb                	mov    %edi,%ebx
80104c7f:	c1 e9 02             	shr    $0x2,%ecx
80104c82:	c1 e3 10             	shl    $0x10,%ebx
80104c85:	09 d8                	or     %ebx,%eax
80104c87:	09 f8                	or     %edi,%eax
80104c89:	c1 e7 08             	shl    $0x8,%edi
80104c8c:	09 f8                	or     %edi,%eax
  asm volatile("cld; rep stosl" :
80104c8e:	89 d7                	mov    %edx,%edi
80104c90:	fc                   	cld    
80104c91:	f3 ab                	rep stos %eax,%es:(%edi)
  } else
    stosb(dst, c, n);
  return dst;
}
80104c93:	5b                   	pop    %ebx
80104c94:	89 d0                	mov    %edx,%eax
80104c96:	5f                   	pop    %edi
80104c97:	5d                   	pop    %ebp
80104c98:	c3                   	ret    
80104c99:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  asm volatile("cld; rep stosb" :
80104ca0:	89 d7                	mov    %edx,%edi
80104ca2:	fc                   	cld    
80104ca3:	f3 aa                	rep stos %al,%es:(%edi)
80104ca5:	5b                   	pop    %ebx
80104ca6:	89 d0                	mov    %edx,%eax
80104ca8:	5f                   	pop    %edi
80104ca9:	5d                   	pop    %ebp
80104caa:	c3                   	ret    
80104cab:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80104caf:	90                   	nop

80104cb0 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
80104cb0:	55                   	push   %ebp
80104cb1:	89 e5                	mov    %esp,%ebp
80104cb3:	56                   	push   %esi
80104cb4:	8b 75 10             	mov    0x10(%ebp),%esi
80104cb7:	8b 55 08             	mov    0x8(%ebp),%edx
80104cba:	53                   	push   %ebx
80104cbb:	8b 45 0c             	mov    0xc(%ebp),%eax
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
80104cbe:	85 f6                	test   %esi,%esi
80104cc0:	74 2e                	je     80104cf0 <memcmp+0x40>
80104cc2:	01 c6                	add    %eax,%esi
80104cc4:	eb 14                	jmp    80104cda <memcmp+0x2a>
80104cc6:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80104ccd:	8d 76 00             	lea    0x0(%esi),%esi
    if(*s1 != *s2)
      return *s1 - *s2;
    s1++, s2++;
80104cd0:	83 c0 01             	add    $0x1,%eax
80104cd3:	83 c2 01             	add    $0x1,%edx
  while(n-- > 0){
80104cd6:	39 f0                	cmp    %esi,%eax
80104cd8:	74 16                	je     80104cf0 <memcmp+0x40>
    if(*s1 != *s2)
80104cda:	0f b6 0a             	movzbl (%edx),%ecx
80104cdd:	0f b6 18             	movzbl (%eax),%ebx
80104ce0:	38 d9                	cmp    %bl,%cl
80104ce2:	74 ec                	je     80104cd0 <memcmp+0x20>
      return *s1 - *s2;
80104ce4:	0f b6 c1             	movzbl %cl,%eax
80104ce7:	29 d8                	sub    %ebx,%eax
  }

  return 0;
}
80104ce9:	5b                   	pop    %ebx
80104cea:	5e                   	pop    %esi
80104ceb:	5d                   	pop    %ebp
80104cec:	c3                   	ret    
80104ced:	8d 76 00             	lea    0x0(%esi),%esi
80104cf0:	5b                   	pop    %ebx
  return 0;
80104cf1:	31 c0                	xor    %eax,%eax
}
80104cf3:	5e                   	pop    %esi
80104cf4:	5d                   	pop    %ebp
80104cf5:	c3                   	ret    
80104cf6:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80104cfd:	8d 76 00             	lea    0x0(%esi),%esi

80104d00 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
80104d00:	55                   	push   %ebp
80104d01:	89 e5                	mov    %esp,%ebp
80104d03:	57                   	push   %edi
80104d04:	8b 55 08             	mov    0x8(%ebp),%edx
80104d07:	8b 4d 10             	mov    0x10(%ebp),%ecx
80104d0a:	56                   	push   %esi
80104d0b:	8b 75 0c             	mov    0xc(%ebp),%esi
  const char *s;
  char *d;

  s = src;
  d = dst;
  if(s < d && s + n > d){
80104d0e:	39 d6                	cmp    %edx,%esi
80104d10:	73 26                	jae    80104d38 <memmove+0x38>
80104d12:	8d 3c 0e             	lea    (%esi,%ecx,1),%edi
80104d15:	39 fa                	cmp    %edi,%edx
80104d17:	73 1f                	jae    80104d38 <memmove+0x38>
80104d19:	8d 41 ff             	lea    -0x1(%ecx),%eax
    s += n;
    d += n;
    while(n-- > 0)
80104d1c:	85 c9                	test   %ecx,%ecx
80104d1e:	74 0c                	je     80104d2c <memmove+0x2c>
      *--d = *--s;
80104d20:	0f b6 0c 06          	movzbl (%esi,%eax,1),%ecx
80104d24:	88 0c 02             	mov    %cl,(%edx,%eax,1)
    while(n-- > 0)
80104d27:	83 e8 01             	sub    $0x1,%eax
80104d2a:	73 f4                	jae    80104d20 <memmove+0x20>
  } else
    while(n-- > 0)
      *d++ = *s++;

  return dst;
}
80104d2c:	5e                   	pop    %esi
80104d2d:	89 d0                	mov    %edx,%eax
80104d2f:	5f                   	pop    %edi
80104d30:	5d                   	pop    %ebp
80104d31:	c3                   	ret    
80104d32:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    while(n-- > 0)
80104d38:	8d 04 0e             	lea    (%esi,%ecx,1),%eax
80104d3b:	89 d7                	mov    %edx,%edi
80104d3d:	85 c9                	test   %ecx,%ecx
80104d3f:	74 eb                	je     80104d2c <memmove+0x2c>
80104d41:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
      *d++ = *s++;
80104d48:	a4                   	movsb  %ds:(%esi),%es:(%edi)
    while(n-- > 0)
80104d49:	39 c6                	cmp    %eax,%esi
80104d4b:	75 fb                	jne    80104d48 <memmove+0x48>
}
80104d4d:	5e                   	pop    %esi
80104d4e:	89 d0                	mov    %edx,%eax
80104d50:	5f                   	pop    %edi
80104d51:	5d                   	pop    %ebp
80104d52:	c3                   	ret    
80104d53:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80104d5a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

80104d60 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
  return memmove(dst, src, n);
80104d60:	eb 9e                	jmp    80104d00 <memmove>
80104d62:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80104d69:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

80104d70 <strncmp>:
}

int
strncmp(const char *p, const char *q, uint n)
{
80104d70:	55                   	push   %ebp
80104d71:	89 e5                	mov    %esp,%ebp
80104d73:	56                   	push   %esi
80104d74:	8b 75 10             	mov    0x10(%ebp),%esi
80104d77:	8b 4d 08             	mov    0x8(%ebp),%ecx
80104d7a:	53                   	push   %ebx
80104d7b:	8b 55 0c             	mov    0xc(%ebp),%edx
  while(n > 0 && *p && *p == *q)
80104d7e:	85 f6                	test   %esi,%esi
80104d80:	74 2e                	je     80104db0 <strncmp+0x40>
80104d82:	01 d6                	add    %edx,%esi
80104d84:	eb 18                	jmp    80104d9e <strncmp+0x2e>
80104d86:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80104d8d:	8d 76 00             	lea    0x0(%esi),%esi
80104d90:	38 d8                	cmp    %bl,%al
80104d92:	75 14                	jne    80104da8 <strncmp+0x38>
    n--, p++, q++;
80104d94:	83 c2 01             	add    $0x1,%edx
80104d97:	83 c1 01             	add    $0x1,%ecx
  while(n > 0 && *p && *p == *q)
80104d9a:	39 f2                	cmp    %esi,%edx
80104d9c:	74 12                	je     80104db0 <strncmp+0x40>
80104d9e:	0f b6 01             	movzbl (%ecx),%eax
80104da1:	0f b6 1a             	movzbl (%edx),%ebx
80104da4:	84 c0                	test   %al,%al
80104da6:	75 e8                	jne    80104d90 <strncmp+0x20>
  if(n == 0)
    return 0;
  return (uchar)*p - (uchar)*q;
80104da8:	29 d8                	sub    %ebx,%eax
}
80104daa:	5b                   	pop    %ebx
80104dab:	5e                   	pop    %esi
80104dac:	5d                   	pop    %ebp
80104dad:	c3                   	ret    
80104dae:	66 90                	xchg   %ax,%ax
80104db0:	5b                   	pop    %ebx
    return 0;
80104db1:	31 c0                	xor    %eax,%eax
}
80104db3:	5e                   	pop    %esi
80104db4:	5d                   	pop    %ebp
80104db5:	c3                   	ret    
80104db6:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80104dbd:	8d 76 00             	lea    0x0(%esi),%esi

80104dc0 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
80104dc0:	55                   	push   %ebp
80104dc1:	89 e5                	mov    %esp,%ebp
80104dc3:	57                   	push   %edi
80104dc4:	56                   	push   %esi
80104dc5:	8b 75 08             	mov    0x8(%ebp),%esi
80104dc8:	53                   	push   %ebx
80104dc9:	8b 4d 10             	mov    0x10(%ebp),%ecx
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
80104dcc:	89 f0                	mov    %esi,%eax
80104dce:	eb 15                	jmp    80104de5 <strncpy+0x25>
80104dd0:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
80104dd4:	8b 7d 0c             	mov    0xc(%ebp),%edi
80104dd7:	83 c0 01             	add    $0x1,%eax
80104dda:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
80104dde:	88 50 ff             	mov    %dl,-0x1(%eax)
80104de1:	84 d2                	test   %dl,%dl
80104de3:	74 09                	je     80104dee <strncpy+0x2e>
80104de5:	89 cb                	mov    %ecx,%ebx
80104de7:	83 e9 01             	sub    $0x1,%ecx
80104dea:	85 db                	test   %ebx,%ebx
80104dec:	7f e2                	jg     80104dd0 <strncpy+0x10>
    ;
  while(n-- > 0)
80104dee:	89 c2                	mov    %eax,%edx
80104df0:	85 c9                	test   %ecx,%ecx
80104df2:	7e 17                	jle    80104e0b <strncpy+0x4b>
80104df4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    *s++ = 0;
80104df8:	83 c2 01             	add    $0x1,%edx
80104dfb:	89 c1                	mov    %eax,%ecx
80104dfd:	c6 42 ff 00          	movb   $0x0,-0x1(%edx)
  while(n-- > 0)
80104e01:	29 d1                	sub    %edx,%ecx
80104e03:	8d 4c 0b ff          	lea    -0x1(%ebx,%ecx,1),%ecx
80104e07:	85 c9                	test   %ecx,%ecx
80104e09:	7f ed                	jg     80104df8 <strncpy+0x38>
  return os;
}
80104e0b:	5b                   	pop    %ebx
80104e0c:	89 f0                	mov    %esi,%eax
80104e0e:	5e                   	pop    %esi
80104e0f:	5f                   	pop    %edi
80104e10:	5d                   	pop    %ebp
80104e11:	c3                   	ret    
80104e12:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80104e19:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

80104e20 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
80104e20:	55                   	push   %ebp
80104e21:	89 e5                	mov    %esp,%ebp
80104e23:	56                   	push   %esi
80104e24:	8b 55 10             	mov    0x10(%ebp),%edx
80104e27:	8b 75 08             	mov    0x8(%ebp),%esi
80104e2a:	53                   	push   %ebx
80104e2b:	8b 45 0c             	mov    0xc(%ebp),%eax
  char *os;

  os = s;
  if(n <= 0)
80104e2e:	85 d2                	test   %edx,%edx
80104e30:	7e 25                	jle    80104e57 <safestrcpy+0x37>
80104e32:	8d 5c 10 ff          	lea    -0x1(%eax,%edx,1),%ebx
80104e36:	89 f2                	mov    %esi,%edx
80104e38:	eb 16                	jmp    80104e50 <safestrcpy+0x30>
80104e3a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
80104e40:	0f b6 08             	movzbl (%eax),%ecx
80104e43:	83 c0 01             	add    $0x1,%eax
80104e46:	83 c2 01             	add    $0x1,%edx
80104e49:	88 4a ff             	mov    %cl,-0x1(%edx)
80104e4c:	84 c9                	test   %cl,%cl
80104e4e:	74 04                	je     80104e54 <safestrcpy+0x34>
80104e50:	39 d8                	cmp    %ebx,%eax
80104e52:	75 ec                	jne    80104e40 <safestrcpy+0x20>
    ;
  *s = 0;
80104e54:	c6 02 00             	movb   $0x0,(%edx)
  return os;
}
80104e57:	89 f0                	mov    %esi,%eax
80104e59:	5b                   	pop    %ebx
80104e5a:	5e                   	pop    %esi
80104e5b:	5d                   	pop    %ebp
80104e5c:	c3                   	ret    
80104e5d:	8d 76 00             	lea    0x0(%esi),%esi

80104e60 <strlen>:

int
strlen(const char *s)
{
80104e60:	55                   	push   %ebp
  int n;

  for(n = 0; s[n]; n++)
80104e61:	31 c0                	xor    %eax,%eax
{
80104e63:	89 e5                	mov    %esp,%ebp
80104e65:	8b 55 08             	mov    0x8(%ebp),%edx
  for(n = 0; s[n]; n++)
80104e68:	80 3a 00             	cmpb   $0x0,(%edx)
80104e6b:	74 0c                	je     80104e79 <strlen+0x19>
80104e6d:	8d 76 00             	lea    0x0(%esi),%esi
80104e70:	83 c0 01             	add    $0x1,%eax
80104e73:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
80104e77:	75 f7                	jne    80104e70 <strlen+0x10>
    ;
  return n;
}
80104e79:	5d                   	pop    %ebp
80104e7a:	c3                   	ret    

80104e7b <swtch>:
# a struct context, and save its address in *old.
# Switch stacks to new and pop previously-saved registers.

.globl swtch
swtch:
  movl 4(%esp), %eax
80104e7b:	8b 44 24 04          	mov    0x4(%esp),%eax
  movl 8(%esp), %edx
80104e7f:	8b 54 24 08          	mov    0x8(%esp),%edx

  # Save old callee-saved registers
  pushl %ebp
80104e83:	55                   	push   %ebp
  pushl %ebx
80104e84:	53                   	push   %ebx
  pushl %esi
80104e85:	56                   	push   %esi
  pushl %edi
80104e86:	57                   	push   %edi

  # Switch stacks
  movl %esp, (%eax)
80104e87:	89 20                	mov    %esp,(%eax)
  movl %edx, %esp
80104e89:	89 d4                	mov    %edx,%esp

  # Load new callee-saved registers
  popl %edi
80104e8b:	5f                   	pop    %edi
  popl %esi
80104e8c:	5e                   	pop    %esi
  popl %ebx
80104e8d:	5b                   	pop    %ebx
  popl %ebp
80104e8e:	5d                   	pop    %ebp
  ret
80104e8f:	c3                   	ret    

80104e90 <fetchint>:
// to a saved program counter, and then the first argument.

// Fetch the int at addr from the current process.
int
fetchint(uint addr, int *ip)
{
80104e90:	55                   	push   %ebp
80104e91:	89 e5                	mov    %esp,%ebp
80104e93:	53                   	push   %ebx
80104e94:	83 ec 04             	sub    $0x4,%esp
80104e97:	8b 5d 08             	mov    0x8(%ebp),%ebx
  struct proc *curproc = myproc();
80104e9a:	e8 51 eb ff ff       	call   801039f0 <myproc>

  if(addr >= curproc->sz || addr+4 > curproc->sz)
80104e9f:	8b 00                	mov    (%eax),%eax
80104ea1:	39 d8                	cmp    %ebx,%eax
80104ea3:	76 1b                	jbe    80104ec0 <fetchint+0x30>
80104ea5:	8d 53 04             	lea    0x4(%ebx),%edx
80104ea8:	39 d0                	cmp    %edx,%eax
80104eaa:	72 14                	jb     80104ec0 <fetchint+0x30>
    return -1;
  *ip = *(int*)(addr);
80104eac:	8b 45 0c             	mov    0xc(%ebp),%eax
80104eaf:	8b 13                	mov    (%ebx),%edx
80104eb1:	89 10                	mov    %edx,(%eax)
  return 0;
80104eb3:	31 c0                	xor    %eax,%eax
}
80104eb5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104eb8:	c9                   	leave  
80104eb9:	c3                   	ret    
80104eba:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    return -1;
80104ec0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104ec5:	eb ee                	jmp    80104eb5 <fetchint+0x25>
80104ec7:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80104ece:	66 90                	xchg   %ax,%ax

80104ed0 <fetchstr>:
// Fetch the nul-terminated string at addr from the current process.
// Doesn't actually copy the string - just sets *pp to point at it.
// Returns length of string, not including nul.
int
fetchstr(uint addr, char **pp)
{
80104ed0:	55                   	push   %ebp
80104ed1:	89 e5                	mov    %esp,%ebp
80104ed3:	53                   	push   %ebx
80104ed4:	83 ec 04             	sub    $0x4,%esp
80104ed7:	8b 5d 08             	mov    0x8(%ebp),%ebx
  char *s, *ep;
  struct proc *curproc = myproc();
80104eda:	e8 11 eb ff ff       	call   801039f0 <myproc>

  if(addr >= curproc->sz)
80104edf:	39 18                	cmp    %ebx,(%eax)
80104ee1:	76 2d                	jbe    80104f10 <fetchstr+0x40>
    return -1;
  *pp = (char*)addr;
80104ee3:	8b 55 0c             	mov    0xc(%ebp),%edx
80104ee6:	89 1a                	mov    %ebx,(%edx)
  ep = (char*)curproc->sz;
80104ee8:	8b 10                	mov    (%eax),%edx
  for(s = *pp; s < ep; s++){
80104eea:	39 d3                	cmp    %edx,%ebx
80104eec:	73 22                	jae    80104f10 <fetchstr+0x40>
80104eee:	89 d8                	mov    %ebx,%eax
80104ef0:	eb 0d                	jmp    80104eff <fetchstr+0x2f>
80104ef2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
80104ef8:	83 c0 01             	add    $0x1,%eax
80104efb:	39 c2                	cmp    %eax,%edx
80104efd:	76 11                	jbe    80104f10 <fetchstr+0x40>
    if(*s == 0)
80104eff:	80 38 00             	cmpb   $0x0,(%eax)
80104f02:	75 f4                	jne    80104ef8 <fetchstr+0x28>
      return s - *pp;
80104f04:	29 d8                	sub    %ebx,%eax
  }
  return -1;
}
80104f06:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104f09:	c9                   	leave  
80104f0a:	c3                   	ret    
80104f0b:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80104f0f:	90                   	nop
80104f10:	8b 5d fc             	mov    -0x4(%ebp),%ebx
    return -1;
80104f13:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104f18:	c9                   	leave  
80104f19:	c3                   	ret    
80104f1a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

80104f20 <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
80104f20:	55                   	push   %ebp
80104f21:	89 e5                	mov    %esp,%ebp
80104f23:	56                   	push   %esi
80104f24:	53                   	push   %ebx
  return fetchint((myproc()->tf->esp) + 4 + 4*n, ip);
80104f25:	e8 c6 ea ff ff       	call   801039f0 <myproc>
80104f2a:	8b 55 08             	mov    0x8(%ebp),%edx
80104f2d:	8b 40 18             	mov    0x18(%eax),%eax
80104f30:	8b 40 44             	mov    0x44(%eax),%eax
80104f33:	8d 1c 90             	lea    (%eax,%edx,4),%ebx
  struct proc *curproc = myproc();
80104f36:	e8 b5 ea ff ff       	call   801039f0 <myproc>
  return fetchint((myproc()->tf->esp) + 4 + 4*n, ip);
80104f3b:	8d 73 04             	lea    0x4(%ebx),%esi
  if(addr >= curproc->sz || addr+4 > curproc->sz)
80104f3e:	8b 00                	mov    (%eax),%eax
80104f40:	39 c6                	cmp    %eax,%esi
80104f42:	73 1c                	jae    80104f60 <argint+0x40>
80104f44:	8d 53 08             	lea    0x8(%ebx),%edx
80104f47:	39 d0                	cmp    %edx,%eax
80104f49:	72 15                	jb     80104f60 <argint+0x40>
  *ip = *(int*)(addr);
80104f4b:	8b 45 0c             	mov    0xc(%ebp),%eax
80104f4e:	8b 53 04             	mov    0x4(%ebx),%edx
80104f51:	89 10                	mov    %edx,(%eax)
  return 0;
80104f53:	31 c0                	xor    %eax,%eax
}
80104f55:	5b                   	pop    %ebx
80104f56:	5e                   	pop    %esi
80104f57:	5d                   	pop    %ebp
80104f58:	c3                   	ret    
80104f59:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    return -1;
80104f60:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  return fetchint((myproc()->tf->esp) + 4 + 4*n, ip);
80104f65:	eb ee                	jmp    80104f55 <argint+0x35>
80104f67:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80104f6e:	66 90                	xchg   %ax,%ax

80104f70 <argptr>:
// Fetch the nth word-sized system call argument as a pointer
// to a block of memory of size bytes.  Check that the pointer
// lies within the process address space.
int
argptr(int n, char **pp, int size)
{
80104f70:	55                   	push   %ebp
80104f71:	89 e5                	mov    %esp,%ebp
80104f73:	57                   	push   %edi
80104f74:	56                   	push   %esi
80104f75:	53                   	push   %ebx
80104f76:	83 ec 0c             	sub    $0xc,%esp
  int i;
  struct proc *curproc = myproc();
80104f79:	e8 72 ea ff ff       	call   801039f0 <myproc>
80104f7e:	89 c6                	mov    %eax,%esi
  return fetchint((myproc()->tf->esp) + 4 + 4*n, ip);
80104f80:	e8 6b ea ff ff       	call   801039f0 <myproc>
80104f85:	8b 55 08             	mov    0x8(%ebp),%edx
80104f88:	8b 40 18             	mov    0x18(%eax),%eax
80104f8b:	8b 40 44             	mov    0x44(%eax),%eax
80104f8e:	8d 1c 90             	lea    (%eax,%edx,4),%ebx
  struct proc *curproc = myproc();
80104f91:	e8 5a ea ff ff       	call   801039f0 <myproc>
  return fetchint((myproc()->tf->esp) + 4 + 4*n, ip);
80104f96:	8d 7b 04             	lea    0x4(%ebx),%edi
  if(addr >= curproc->sz || addr+4 > curproc->sz)
80104f99:	8b 00                	mov    (%eax),%eax
80104f9b:	39 c7                	cmp    %eax,%edi
80104f9d:	73 31                	jae    80104fd0 <argptr+0x60>
80104f9f:	8d 4b 08             	lea    0x8(%ebx),%ecx
80104fa2:	39 c8                	cmp    %ecx,%eax
80104fa4:	72 2a                	jb     80104fd0 <argptr+0x60>
 
  if(argint(n, &i) < 0)
    return -1;
  if(size < 0 || (uint)i >= curproc->sz || (uint)i+size > curproc->sz)
80104fa6:	8b 55 10             	mov    0x10(%ebp),%edx
  *ip = *(int*)(addr);
80104fa9:	8b 43 04             	mov    0x4(%ebx),%eax
  if(size < 0 || (uint)i >= curproc->sz || (uint)i+size > curproc->sz)
80104fac:	85 d2                	test   %edx,%edx
80104fae:	78 20                	js     80104fd0 <argptr+0x60>
80104fb0:	8b 16                	mov    (%esi),%edx
80104fb2:	39 c2                	cmp    %eax,%edx
80104fb4:	76 1a                	jbe    80104fd0 <argptr+0x60>
80104fb6:	8b 5d 10             	mov    0x10(%ebp),%ebx
80104fb9:	01 c3                	add    %eax,%ebx
80104fbb:	39 da                	cmp    %ebx,%edx
80104fbd:	72 11                	jb     80104fd0 <argptr+0x60>
    return -1;
  *pp = (char*)i;
80104fbf:	8b 55 0c             	mov    0xc(%ebp),%edx
80104fc2:	89 02                	mov    %eax,(%edx)
  return 0;
80104fc4:	31 c0                	xor    %eax,%eax
}
80104fc6:	83 c4 0c             	add    $0xc,%esp
80104fc9:	5b                   	pop    %ebx
80104fca:	5e                   	pop    %esi
80104fcb:	5f                   	pop    %edi
80104fcc:	5d                   	pop    %ebp
80104fcd:	c3                   	ret    
80104fce:	66 90                	xchg   %ax,%ax
    return -1;
80104fd0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104fd5:	eb ef                	jmp    80104fc6 <argptr+0x56>
80104fd7:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80104fde:	66 90                	xchg   %ax,%ax

80104fe0 <argstr>:
// Check that the pointer is valid and the string is nul-terminated.
// (There is no shared writable memory, so the string can't change
// between this check and being used by the kernel.)
int
argstr(int n, char **pp)
{
80104fe0:	55                   	push   %ebp
80104fe1:	89 e5                	mov    %esp,%ebp
80104fe3:	56                   	push   %esi
80104fe4:	53                   	push   %ebx
  return fetchint((myproc()->tf->esp) + 4 + 4*n, ip);
80104fe5:	e8 06 ea ff ff       	call   801039f0 <myproc>
80104fea:	8b 55 08             	mov    0x8(%ebp),%edx
80104fed:	8b 40 18             	mov    0x18(%eax),%eax
80104ff0:	8b 40 44             	mov    0x44(%eax),%eax
80104ff3:	8d 1c 90             	lea    (%eax,%edx,4),%ebx
  struct proc *curproc = myproc();
80104ff6:	e8 f5 e9 ff ff       	call   801039f0 <myproc>
  return fetchint((myproc()->tf->esp) + 4 + 4*n, ip);
80104ffb:	8d 73 04             	lea    0x4(%ebx),%esi
  if(addr >= curproc->sz || addr+4 > curproc->sz)
80104ffe:	8b 00                	mov    (%eax),%eax
80105000:	39 c6                	cmp    %eax,%esi
80105002:	73 44                	jae    80105048 <argstr+0x68>
80105004:	8d 53 08             	lea    0x8(%ebx),%edx
80105007:	39 d0                	cmp    %edx,%eax
80105009:	72 3d                	jb     80105048 <argstr+0x68>
  *ip = *(int*)(addr);
8010500b:	8b 5b 04             	mov    0x4(%ebx),%ebx
  struct proc *curproc = myproc();
8010500e:	e8 dd e9 ff ff       	call   801039f0 <myproc>
  if(addr >= curproc->sz)
80105013:	3b 18                	cmp    (%eax),%ebx
80105015:	73 31                	jae    80105048 <argstr+0x68>
  *pp = (char*)addr;
80105017:	8b 55 0c             	mov    0xc(%ebp),%edx
8010501a:	89 1a                	mov    %ebx,(%edx)
  ep = (char*)curproc->sz;
8010501c:	8b 10                	mov    (%eax),%edx
  for(s = *pp; s < ep; s++){
8010501e:	39 d3                	cmp    %edx,%ebx
80105020:	73 26                	jae    80105048 <argstr+0x68>
80105022:	89 d8                	mov    %ebx,%eax
80105024:	eb 11                	jmp    80105037 <argstr+0x57>
80105026:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010502d:	8d 76 00             	lea    0x0(%esi),%esi
80105030:	83 c0 01             	add    $0x1,%eax
80105033:	39 c2                	cmp    %eax,%edx
80105035:	76 11                	jbe    80105048 <argstr+0x68>
    if(*s == 0)
80105037:	80 38 00             	cmpb   $0x0,(%eax)
8010503a:	75 f4                	jne    80105030 <argstr+0x50>
      return s - *pp;
8010503c:	29 d8                	sub    %ebx,%eax
  int addr;
  if(argint(n, &addr) < 0)
    return -1;
  return fetchstr(addr, pp);
}
8010503e:	5b                   	pop    %ebx
8010503f:	5e                   	pop    %esi
80105040:	5d                   	pop    %ebp
80105041:	c3                   	ret    
80105042:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
80105048:	5b                   	pop    %ebx
    return -1;
80105049:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010504e:	5e                   	pop    %esi
8010504f:	5d                   	pop    %ebp
80105050:	c3                   	ret    
80105051:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80105058:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010505f:	90                   	nop

80105060 <syscall>:
[SYS_getwmapinfo] sys_getwmapinfo,
};

void
syscall(void)
{
80105060:	55                   	push   %ebp
80105061:	89 e5                	mov    %esp,%ebp
80105063:	53                   	push   %ebx
80105064:	83 ec 04             	sub    $0x4,%esp
  int num;
  struct proc *curproc = myproc();
80105067:	e8 84 e9 ff ff       	call   801039f0 <myproc>
8010506c:	89 c3                	mov    %eax,%ebx

  num = curproc->tf->eax;
8010506e:	8b 40 18             	mov    0x18(%eax),%eax
80105071:	8b 40 1c             	mov    0x1c(%eax),%eax
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
80105074:	8d 50 ff             	lea    -0x1(%eax),%edx
80105077:	83 fa 18             	cmp    $0x18,%edx
8010507a:	77 24                	ja     801050a0 <syscall+0x40>
8010507c:	8b 14 85 00 88 10 80 	mov    -0x7fef7800(,%eax,4),%edx
80105083:	85 d2                	test   %edx,%edx
80105085:	74 19                	je     801050a0 <syscall+0x40>
    curproc->tf->eax = syscalls[num]();
80105087:	ff d2                	call   *%edx
80105089:	89 c2                	mov    %eax,%edx
8010508b:	8b 43 18             	mov    0x18(%ebx),%eax
8010508e:	89 50 1c             	mov    %edx,0x1c(%eax)
  } else {
    cprintf("%d %s: unknown sys call %d\n",
            curproc->pid, curproc->name, num);
    curproc->tf->eax = -1;
  }
}
80105091:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80105094:	c9                   	leave  
80105095:	c3                   	ret    
80105096:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010509d:	8d 76 00             	lea    0x0(%esi),%esi
    cprintf("%d %s: unknown sys call %d\n",
801050a0:	50                   	push   %eax
            curproc->pid, curproc->name, num);
801050a1:	8d 43 6c             	lea    0x6c(%ebx),%eax
    cprintf("%d %s: unknown sys call %d\n",
801050a4:	50                   	push   %eax
801050a5:	ff 73 10             	push   0x10(%ebx)
801050a8:	68 cd 87 10 80       	push   $0x801087cd
801050ad:	e8 ee b5 ff ff       	call   801006a0 <cprintf>
    curproc->tf->eax = -1;
801050b2:	8b 43 18             	mov    0x18(%ebx),%eax
801050b5:	83 c4 10             	add    $0x10,%esp
801050b8:	c7 40 1c ff ff ff ff 	movl   $0xffffffff,0x1c(%eax)
}
801050bf:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801050c2:	c9                   	leave  
801050c3:	c3                   	ret    
801050c4:	66 90                	xchg   %ax,%ax
801050c6:	66 90                	xchg   %ax,%ax
801050c8:	66 90                	xchg   %ax,%ax
801050ca:	66 90                	xchg   %ax,%ax
801050cc:	66 90                	xchg   %ax,%ax
801050ce:	66 90                	xchg   %ax,%ax

801050d0 <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
801050d0:	55                   	push   %ebp
801050d1:	89 e5                	mov    %esp,%ebp
801050d3:	57                   	push   %edi
801050d4:	56                   	push   %esi
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
801050d5:	8d 7d da             	lea    -0x26(%ebp),%edi
{
801050d8:	53                   	push   %ebx
801050d9:	83 ec 34             	sub    $0x34,%esp
801050dc:	89 4d d0             	mov    %ecx,-0x30(%ebp)
801050df:	8b 4d 08             	mov    0x8(%ebp),%ecx
  if((dp = nameiparent(path, name)) == 0)
801050e2:	57                   	push   %edi
801050e3:	50                   	push   %eax
{
801050e4:	89 55 d4             	mov    %edx,-0x2c(%ebp)
801050e7:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  if((dp = nameiparent(path, name)) == 0)
801050ea:	e8 e1 cf ff ff       	call   801020d0 <nameiparent>
801050ef:	83 c4 10             	add    $0x10,%esp
801050f2:	85 c0                	test   %eax,%eax
801050f4:	0f 84 46 01 00 00    	je     80105240 <create+0x170>
    return 0;
  ilock(dp);
801050fa:	83 ec 0c             	sub    $0xc,%esp
801050fd:	89 c3                	mov    %eax,%ebx
801050ff:	50                   	push   %eax
80105100:	e8 8b c6 ff ff       	call   80101790 <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
80105105:	83 c4 0c             	add    $0xc,%esp
80105108:	6a 00                	push   $0x0
8010510a:	57                   	push   %edi
8010510b:	53                   	push   %ebx
8010510c:	e8 df cb ff ff       	call   80101cf0 <dirlookup>
80105111:	83 c4 10             	add    $0x10,%esp
80105114:	89 c6                	mov    %eax,%esi
80105116:	85 c0                	test   %eax,%eax
80105118:	74 56                	je     80105170 <create+0xa0>
    iunlockput(dp);
8010511a:	83 ec 0c             	sub    $0xc,%esp
8010511d:	53                   	push   %ebx
8010511e:	e8 fd c8 ff ff       	call   80101a20 <iunlockput>
    ilock(ip);
80105123:	89 34 24             	mov    %esi,(%esp)
80105126:	e8 65 c6 ff ff       	call   80101790 <ilock>
    if(type == T_FILE && ip->type == T_FILE)
8010512b:	83 c4 10             	add    $0x10,%esp
8010512e:	66 83 7d d4 02       	cmpw   $0x2,-0x2c(%ebp)
80105133:	75 1b                	jne    80105150 <create+0x80>
80105135:	66 83 7e 50 02       	cmpw   $0x2,0x50(%esi)
8010513a:	75 14                	jne    80105150 <create+0x80>
    panic("create: dirlink");

  iunlockput(dp);

  return ip;
}
8010513c:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010513f:	89 f0                	mov    %esi,%eax
80105141:	5b                   	pop    %ebx
80105142:	5e                   	pop    %esi
80105143:	5f                   	pop    %edi
80105144:	5d                   	pop    %ebp
80105145:	c3                   	ret    
80105146:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010514d:	8d 76 00             	lea    0x0(%esi),%esi
    iunlockput(ip);
80105150:	83 ec 0c             	sub    $0xc,%esp
80105153:	56                   	push   %esi
    return 0;
80105154:	31 f6                	xor    %esi,%esi
    iunlockput(ip);
80105156:	e8 c5 c8 ff ff       	call   80101a20 <iunlockput>
    return 0;
8010515b:	83 c4 10             	add    $0x10,%esp
}
8010515e:	8d 65 f4             	lea    -0xc(%ebp),%esp
80105161:	89 f0                	mov    %esi,%eax
80105163:	5b                   	pop    %ebx
80105164:	5e                   	pop    %esi
80105165:	5f                   	pop    %edi
80105166:	5d                   	pop    %ebp
80105167:	c3                   	ret    
80105168:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010516f:	90                   	nop
  if((ip = ialloc(dp->dev, type)) == 0)
80105170:	0f bf 45 d4          	movswl -0x2c(%ebp),%eax
80105174:	83 ec 08             	sub    $0x8,%esp
80105177:	50                   	push   %eax
80105178:	ff 33                	push   (%ebx)
8010517a:	e8 a1 c4 ff ff       	call   80101620 <ialloc>
8010517f:	83 c4 10             	add    $0x10,%esp
80105182:	89 c6                	mov    %eax,%esi
80105184:	85 c0                	test   %eax,%eax
80105186:	0f 84 cd 00 00 00    	je     80105259 <create+0x189>
  ilock(ip);
8010518c:	83 ec 0c             	sub    $0xc,%esp
8010518f:	50                   	push   %eax
80105190:	e8 fb c5 ff ff       	call   80101790 <ilock>
  ip->major = major;
80105195:	0f b7 45 d0          	movzwl -0x30(%ebp),%eax
80105199:	66 89 46 52          	mov    %ax,0x52(%esi)
  ip->minor = minor;
8010519d:	0f b7 45 cc          	movzwl -0x34(%ebp),%eax
801051a1:	66 89 46 54          	mov    %ax,0x54(%esi)
  ip->nlink = 1;
801051a5:	b8 01 00 00 00       	mov    $0x1,%eax
801051aa:	66 89 46 56          	mov    %ax,0x56(%esi)
  iupdate(ip);
801051ae:	89 34 24             	mov    %esi,(%esp)
801051b1:	e8 2a c5 ff ff       	call   801016e0 <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
801051b6:	83 c4 10             	add    $0x10,%esp
801051b9:	66 83 7d d4 01       	cmpw   $0x1,-0x2c(%ebp)
801051be:	74 30                	je     801051f0 <create+0x120>
  if(dirlink(dp, name, ip->inum) < 0)
801051c0:	83 ec 04             	sub    $0x4,%esp
801051c3:	ff 76 04             	push   0x4(%esi)
801051c6:	57                   	push   %edi
801051c7:	53                   	push   %ebx
801051c8:	e8 23 ce ff ff       	call   80101ff0 <dirlink>
801051cd:	83 c4 10             	add    $0x10,%esp
801051d0:	85 c0                	test   %eax,%eax
801051d2:	78 78                	js     8010524c <create+0x17c>
  iunlockput(dp);
801051d4:	83 ec 0c             	sub    $0xc,%esp
801051d7:	53                   	push   %ebx
801051d8:	e8 43 c8 ff ff       	call   80101a20 <iunlockput>
  return ip;
801051dd:	83 c4 10             	add    $0x10,%esp
}
801051e0:	8d 65 f4             	lea    -0xc(%ebp),%esp
801051e3:	89 f0                	mov    %esi,%eax
801051e5:	5b                   	pop    %ebx
801051e6:	5e                   	pop    %esi
801051e7:	5f                   	pop    %edi
801051e8:	5d                   	pop    %ebp
801051e9:	c3                   	ret    
801051ea:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    iupdate(dp);
801051f0:	83 ec 0c             	sub    $0xc,%esp
    dp->nlink++;  // for ".."
801051f3:	66 83 43 56 01       	addw   $0x1,0x56(%ebx)
    iupdate(dp);
801051f8:	53                   	push   %ebx
801051f9:	e8 e2 c4 ff ff       	call   801016e0 <iupdate>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
801051fe:	83 c4 0c             	add    $0xc,%esp
80105201:	ff 76 04             	push   0x4(%esi)
80105204:	68 84 88 10 80       	push   $0x80108884
80105209:	56                   	push   %esi
8010520a:	e8 e1 cd ff ff       	call   80101ff0 <dirlink>
8010520f:	83 c4 10             	add    $0x10,%esp
80105212:	85 c0                	test   %eax,%eax
80105214:	78 18                	js     8010522e <create+0x15e>
80105216:	83 ec 04             	sub    $0x4,%esp
80105219:	ff 73 04             	push   0x4(%ebx)
8010521c:	68 83 88 10 80       	push   $0x80108883
80105221:	56                   	push   %esi
80105222:	e8 c9 cd ff ff       	call   80101ff0 <dirlink>
80105227:	83 c4 10             	add    $0x10,%esp
8010522a:	85 c0                	test   %eax,%eax
8010522c:	79 92                	jns    801051c0 <create+0xf0>
      panic("create dots");
8010522e:	83 ec 0c             	sub    $0xc,%esp
80105231:	68 77 88 10 80       	push   $0x80108877
80105236:	e8 45 b1 ff ff       	call   80100380 <panic>
8010523b:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
8010523f:	90                   	nop
}
80105240:	8d 65 f4             	lea    -0xc(%ebp),%esp
    return 0;
80105243:	31 f6                	xor    %esi,%esi
}
80105245:	5b                   	pop    %ebx
80105246:	89 f0                	mov    %esi,%eax
80105248:	5e                   	pop    %esi
80105249:	5f                   	pop    %edi
8010524a:	5d                   	pop    %ebp
8010524b:	c3                   	ret    
    panic("create: dirlink");
8010524c:	83 ec 0c             	sub    $0xc,%esp
8010524f:	68 86 88 10 80       	push   $0x80108886
80105254:	e8 27 b1 ff ff       	call   80100380 <panic>
    panic("create: ialloc");
80105259:	83 ec 0c             	sub    $0xc,%esp
8010525c:	68 68 88 10 80       	push   $0x80108868
80105261:	e8 1a b1 ff ff       	call   80100380 <panic>
80105266:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010526d:	8d 76 00             	lea    0x0(%esi),%esi

80105270 <sys_dup>:
{
80105270:	55                   	push   %ebp
80105271:	89 e5                	mov    %esp,%ebp
80105273:	56                   	push   %esi
80105274:	53                   	push   %ebx
  if(argint(n, &fd) < 0)
80105275:	8d 45 f4             	lea    -0xc(%ebp),%eax
{
80105278:	83 ec 18             	sub    $0x18,%esp
  if(argint(n, &fd) < 0)
8010527b:	50                   	push   %eax
8010527c:	6a 00                	push   $0x0
8010527e:	e8 9d fc ff ff       	call   80104f20 <argint>
80105283:	83 c4 10             	add    $0x10,%esp
80105286:	85 c0                	test   %eax,%eax
80105288:	78 36                	js     801052c0 <sys_dup+0x50>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
8010528a:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
8010528e:	77 30                	ja     801052c0 <sys_dup+0x50>
80105290:	e8 5b e7 ff ff       	call   801039f0 <myproc>
80105295:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105298:	8b 74 90 28          	mov    0x28(%eax,%edx,4),%esi
8010529c:	85 f6                	test   %esi,%esi
8010529e:	74 20                	je     801052c0 <sys_dup+0x50>
  struct proc *curproc = myproc();
801052a0:	e8 4b e7 ff ff       	call   801039f0 <myproc>
  for(fd = 0; fd < NOFILE; fd++){
801052a5:	31 db                	xor    %ebx,%ebx
801052a7:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801052ae:	66 90                	xchg   %ax,%ax
    if(curproc->ofile[fd] == 0){
801052b0:	8b 54 98 28          	mov    0x28(%eax,%ebx,4),%edx
801052b4:	85 d2                	test   %edx,%edx
801052b6:	74 18                	je     801052d0 <sys_dup+0x60>
  for(fd = 0; fd < NOFILE; fd++){
801052b8:	83 c3 01             	add    $0x1,%ebx
801052bb:	83 fb 10             	cmp    $0x10,%ebx
801052be:	75 f0                	jne    801052b0 <sys_dup+0x40>
}
801052c0:	8d 65 f8             	lea    -0x8(%ebp),%esp
    return -1;
801052c3:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
}
801052c8:	89 d8                	mov    %ebx,%eax
801052ca:	5b                   	pop    %ebx
801052cb:	5e                   	pop    %esi
801052cc:	5d                   	pop    %ebp
801052cd:	c3                   	ret    
801052ce:	66 90                	xchg   %ax,%ax
  filedup(f);
801052d0:	83 ec 0c             	sub    $0xc,%esp
      curproc->ofile[fd] = f;
801052d3:	89 74 98 28          	mov    %esi,0x28(%eax,%ebx,4)
  filedup(f);
801052d7:	56                   	push   %esi
801052d8:	e8 d3 bb ff ff       	call   80100eb0 <filedup>
  return fd;
801052dd:	83 c4 10             	add    $0x10,%esp
}
801052e0:	8d 65 f8             	lea    -0x8(%ebp),%esp
801052e3:	89 d8                	mov    %ebx,%eax
801052e5:	5b                   	pop    %ebx
801052e6:	5e                   	pop    %esi
801052e7:	5d                   	pop    %ebp
801052e8:	c3                   	ret    
801052e9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

801052f0 <sys_read>:
{
801052f0:	55                   	push   %ebp
801052f1:	89 e5                	mov    %esp,%ebp
801052f3:	56                   	push   %esi
801052f4:	53                   	push   %ebx
  if(argint(n, &fd) < 0)
801052f5:	8d 5d f4             	lea    -0xc(%ebp),%ebx
{
801052f8:	83 ec 18             	sub    $0x18,%esp
  if(argint(n, &fd) < 0)
801052fb:	53                   	push   %ebx
801052fc:	6a 00                	push   $0x0
801052fe:	e8 1d fc ff ff       	call   80104f20 <argint>
80105303:	83 c4 10             	add    $0x10,%esp
80105306:	85 c0                	test   %eax,%eax
80105308:	78 5e                	js     80105368 <sys_read+0x78>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
8010530a:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
8010530e:	77 58                	ja     80105368 <sys_read+0x78>
80105310:	e8 db e6 ff ff       	call   801039f0 <myproc>
80105315:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105318:	8b 74 90 28          	mov    0x28(%eax,%edx,4),%esi
8010531c:	85 f6                	test   %esi,%esi
8010531e:	74 48                	je     80105368 <sys_read+0x78>
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80105320:	83 ec 08             	sub    $0x8,%esp
80105323:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105326:	50                   	push   %eax
80105327:	6a 02                	push   $0x2
80105329:	e8 f2 fb ff ff       	call   80104f20 <argint>
8010532e:	83 c4 10             	add    $0x10,%esp
80105331:	85 c0                	test   %eax,%eax
80105333:	78 33                	js     80105368 <sys_read+0x78>
80105335:	83 ec 04             	sub    $0x4,%esp
80105338:	ff 75 f0             	push   -0x10(%ebp)
8010533b:	53                   	push   %ebx
8010533c:	6a 01                	push   $0x1
8010533e:	e8 2d fc ff ff       	call   80104f70 <argptr>
80105343:	83 c4 10             	add    $0x10,%esp
80105346:	85 c0                	test   %eax,%eax
80105348:	78 1e                	js     80105368 <sys_read+0x78>
  return fileread(f, p, n);
8010534a:	83 ec 04             	sub    $0x4,%esp
8010534d:	ff 75 f0             	push   -0x10(%ebp)
80105350:	ff 75 f4             	push   -0xc(%ebp)
80105353:	56                   	push   %esi
80105354:	e8 d7 bc ff ff       	call   80101030 <fileread>
80105359:	83 c4 10             	add    $0x10,%esp
}
8010535c:	8d 65 f8             	lea    -0x8(%ebp),%esp
8010535f:	5b                   	pop    %ebx
80105360:	5e                   	pop    %esi
80105361:	5d                   	pop    %ebp
80105362:	c3                   	ret    
80105363:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80105367:	90                   	nop
    return -1;
80105368:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010536d:	eb ed                	jmp    8010535c <sys_read+0x6c>
8010536f:	90                   	nop

80105370 <sys_write>:
{
80105370:	55                   	push   %ebp
80105371:	89 e5                	mov    %esp,%ebp
80105373:	56                   	push   %esi
80105374:	53                   	push   %ebx
  if(argint(n, &fd) < 0)
80105375:	8d 5d f4             	lea    -0xc(%ebp),%ebx
{
80105378:	83 ec 18             	sub    $0x18,%esp
  if(argint(n, &fd) < 0)
8010537b:	53                   	push   %ebx
8010537c:	6a 00                	push   $0x0
8010537e:	e8 9d fb ff ff       	call   80104f20 <argint>
80105383:	83 c4 10             	add    $0x10,%esp
80105386:	85 c0                	test   %eax,%eax
80105388:	78 5e                	js     801053e8 <sys_write+0x78>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
8010538a:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
8010538e:	77 58                	ja     801053e8 <sys_write+0x78>
80105390:	e8 5b e6 ff ff       	call   801039f0 <myproc>
80105395:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105398:	8b 74 90 28          	mov    0x28(%eax,%edx,4),%esi
8010539c:	85 f6                	test   %esi,%esi
8010539e:	74 48                	je     801053e8 <sys_write+0x78>
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
801053a0:	83 ec 08             	sub    $0x8,%esp
801053a3:	8d 45 f0             	lea    -0x10(%ebp),%eax
801053a6:	50                   	push   %eax
801053a7:	6a 02                	push   $0x2
801053a9:	e8 72 fb ff ff       	call   80104f20 <argint>
801053ae:	83 c4 10             	add    $0x10,%esp
801053b1:	85 c0                	test   %eax,%eax
801053b3:	78 33                	js     801053e8 <sys_write+0x78>
801053b5:	83 ec 04             	sub    $0x4,%esp
801053b8:	ff 75 f0             	push   -0x10(%ebp)
801053bb:	53                   	push   %ebx
801053bc:	6a 01                	push   $0x1
801053be:	e8 ad fb ff ff       	call   80104f70 <argptr>
801053c3:	83 c4 10             	add    $0x10,%esp
801053c6:	85 c0                	test   %eax,%eax
801053c8:	78 1e                	js     801053e8 <sys_write+0x78>
  return filewrite(f, p, n);
801053ca:	83 ec 04             	sub    $0x4,%esp
801053cd:	ff 75 f0             	push   -0x10(%ebp)
801053d0:	ff 75 f4             	push   -0xc(%ebp)
801053d3:	56                   	push   %esi
801053d4:	e8 e7 bc ff ff       	call   801010c0 <filewrite>
801053d9:	83 c4 10             	add    $0x10,%esp
}
801053dc:	8d 65 f8             	lea    -0x8(%ebp),%esp
801053df:	5b                   	pop    %ebx
801053e0:	5e                   	pop    %esi
801053e1:	5d                   	pop    %ebp
801053e2:	c3                   	ret    
801053e3:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
801053e7:	90                   	nop
    return -1;
801053e8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801053ed:	eb ed                	jmp    801053dc <sys_write+0x6c>
801053ef:	90                   	nop

801053f0 <sys_close>:
{
801053f0:	55                   	push   %ebp
801053f1:	89 e5                	mov    %esp,%ebp
801053f3:	56                   	push   %esi
801053f4:	53                   	push   %ebx
  if(argint(n, &fd) < 0)
801053f5:	8d 45 f4             	lea    -0xc(%ebp),%eax
{
801053f8:	83 ec 18             	sub    $0x18,%esp
  if(argint(n, &fd) < 0)
801053fb:	50                   	push   %eax
801053fc:	6a 00                	push   $0x0
801053fe:	e8 1d fb ff ff       	call   80104f20 <argint>
80105403:	83 c4 10             	add    $0x10,%esp
80105406:	85 c0                	test   %eax,%eax
80105408:	78 3e                	js     80105448 <sys_close+0x58>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
8010540a:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
8010540e:	77 38                	ja     80105448 <sys_close+0x58>
80105410:	e8 db e5 ff ff       	call   801039f0 <myproc>
80105415:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105418:	8d 5a 08             	lea    0x8(%edx),%ebx
8010541b:	8b 74 98 08          	mov    0x8(%eax,%ebx,4),%esi
8010541f:	85 f6                	test   %esi,%esi
80105421:	74 25                	je     80105448 <sys_close+0x58>
  myproc()->ofile[fd] = 0;
80105423:	e8 c8 e5 ff ff       	call   801039f0 <myproc>
  fileclose(f);
80105428:	83 ec 0c             	sub    $0xc,%esp
  myproc()->ofile[fd] = 0;
8010542b:	c7 44 98 08 00 00 00 	movl   $0x0,0x8(%eax,%ebx,4)
80105432:	00 
  fileclose(f);
80105433:	56                   	push   %esi
80105434:	e8 c7 ba ff ff       	call   80100f00 <fileclose>
  return 0;
80105439:	83 c4 10             	add    $0x10,%esp
8010543c:	31 c0                	xor    %eax,%eax
}
8010543e:	8d 65 f8             	lea    -0x8(%ebp),%esp
80105441:	5b                   	pop    %ebx
80105442:	5e                   	pop    %esi
80105443:	5d                   	pop    %ebp
80105444:	c3                   	ret    
80105445:	8d 76 00             	lea    0x0(%esi),%esi
    return -1;
80105448:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010544d:	eb ef                	jmp    8010543e <sys_close+0x4e>
8010544f:	90                   	nop

80105450 <sys_fstat>:
{
80105450:	55                   	push   %ebp
80105451:	89 e5                	mov    %esp,%ebp
80105453:	56                   	push   %esi
80105454:	53                   	push   %ebx
  if(argint(n, &fd) < 0)
80105455:	8d 5d f4             	lea    -0xc(%ebp),%ebx
{
80105458:	83 ec 18             	sub    $0x18,%esp
  if(argint(n, &fd) < 0)
8010545b:	53                   	push   %ebx
8010545c:	6a 00                	push   $0x0
8010545e:	e8 bd fa ff ff       	call   80104f20 <argint>
80105463:	83 c4 10             	add    $0x10,%esp
80105466:	85 c0                	test   %eax,%eax
80105468:	78 46                	js     801054b0 <sys_fstat+0x60>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
8010546a:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
8010546e:	77 40                	ja     801054b0 <sys_fstat+0x60>
80105470:	e8 7b e5 ff ff       	call   801039f0 <myproc>
80105475:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105478:	8b 74 90 28          	mov    0x28(%eax,%edx,4),%esi
8010547c:	85 f6                	test   %esi,%esi
8010547e:	74 30                	je     801054b0 <sys_fstat+0x60>
  if(argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
80105480:	83 ec 04             	sub    $0x4,%esp
80105483:	6a 14                	push   $0x14
80105485:	53                   	push   %ebx
80105486:	6a 01                	push   $0x1
80105488:	e8 e3 fa ff ff       	call   80104f70 <argptr>
8010548d:	83 c4 10             	add    $0x10,%esp
80105490:	85 c0                	test   %eax,%eax
80105492:	78 1c                	js     801054b0 <sys_fstat+0x60>
  return filestat(f, st);
80105494:	83 ec 08             	sub    $0x8,%esp
80105497:	ff 75 f4             	push   -0xc(%ebp)
8010549a:	56                   	push   %esi
8010549b:	e8 40 bb ff ff       	call   80100fe0 <filestat>
801054a0:	83 c4 10             	add    $0x10,%esp
}
801054a3:	8d 65 f8             	lea    -0x8(%ebp),%esp
801054a6:	5b                   	pop    %ebx
801054a7:	5e                   	pop    %esi
801054a8:	5d                   	pop    %ebp
801054a9:	c3                   	ret    
801054aa:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    return -1;
801054b0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801054b5:	eb ec                	jmp    801054a3 <sys_fstat+0x53>
801054b7:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801054be:	66 90                	xchg   %ax,%ax

801054c0 <sys_link>:
{
801054c0:	55                   	push   %ebp
801054c1:	89 e5                	mov    %esp,%ebp
801054c3:	57                   	push   %edi
801054c4:	56                   	push   %esi
  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
801054c5:	8d 45 d4             	lea    -0x2c(%ebp),%eax
{
801054c8:	53                   	push   %ebx
801054c9:	83 ec 34             	sub    $0x34,%esp
  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
801054cc:	50                   	push   %eax
801054cd:	6a 00                	push   $0x0
801054cf:	e8 0c fb ff ff       	call   80104fe0 <argstr>
801054d4:	83 c4 10             	add    $0x10,%esp
801054d7:	85 c0                	test   %eax,%eax
801054d9:	0f 88 fb 00 00 00    	js     801055da <sys_link+0x11a>
801054df:	83 ec 08             	sub    $0x8,%esp
801054e2:	8d 45 d0             	lea    -0x30(%ebp),%eax
801054e5:	50                   	push   %eax
801054e6:	6a 01                	push   $0x1
801054e8:	e8 f3 fa ff ff       	call   80104fe0 <argstr>
801054ed:	83 c4 10             	add    $0x10,%esp
801054f0:	85 c0                	test   %eax,%eax
801054f2:	0f 88 e2 00 00 00    	js     801055da <sys_link+0x11a>
  begin_op();
801054f8:	e8 d3 d8 ff ff       	call   80102dd0 <begin_op>
  if((ip = namei(old)) == 0){
801054fd:	83 ec 0c             	sub    $0xc,%esp
80105500:	ff 75 d4             	push   -0x2c(%ebp)
80105503:	e8 a8 cb ff ff       	call   801020b0 <namei>
80105508:	83 c4 10             	add    $0x10,%esp
8010550b:	89 c3                	mov    %eax,%ebx
8010550d:	85 c0                	test   %eax,%eax
8010550f:	0f 84 e4 00 00 00    	je     801055f9 <sys_link+0x139>
  ilock(ip);
80105515:	83 ec 0c             	sub    $0xc,%esp
80105518:	50                   	push   %eax
80105519:	e8 72 c2 ff ff       	call   80101790 <ilock>
  if(ip->type == T_DIR){
8010551e:	83 c4 10             	add    $0x10,%esp
80105521:	66 83 7b 50 01       	cmpw   $0x1,0x50(%ebx)
80105526:	0f 84 b5 00 00 00    	je     801055e1 <sys_link+0x121>
  iupdate(ip);
8010552c:	83 ec 0c             	sub    $0xc,%esp
  ip->nlink++;
8010552f:	66 83 43 56 01       	addw   $0x1,0x56(%ebx)
  if((dp = nameiparent(new, name)) == 0)
80105534:	8d 7d da             	lea    -0x26(%ebp),%edi
  iupdate(ip);
80105537:	53                   	push   %ebx
80105538:	e8 a3 c1 ff ff       	call   801016e0 <iupdate>
  iunlock(ip);
8010553d:	89 1c 24             	mov    %ebx,(%esp)
80105540:	e8 2b c3 ff ff       	call   80101870 <iunlock>
  if((dp = nameiparent(new, name)) == 0)
80105545:	58                   	pop    %eax
80105546:	5a                   	pop    %edx
80105547:	57                   	push   %edi
80105548:	ff 75 d0             	push   -0x30(%ebp)
8010554b:	e8 80 cb ff ff       	call   801020d0 <nameiparent>
80105550:	83 c4 10             	add    $0x10,%esp
80105553:	89 c6                	mov    %eax,%esi
80105555:	85 c0                	test   %eax,%eax
80105557:	74 5b                	je     801055b4 <sys_link+0xf4>
  ilock(dp);
80105559:	83 ec 0c             	sub    $0xc,%esp
8010555c:	50                   	push   %eax
8010555d:	e8 2e c2 ff ff       	call   80101790 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
80105562:	8b 03                	mov    (%ebx),%eax
80105564:	83 c4 10             	add    $0x10,%esp
80105567:	39 06                	cmp    %eax,(%esi)
80105569:	75 3d                	jne    801055a8 <sys_link+0xe8>
8010556b:	83 ec 04             	sub    $0x4,%esp
8010556e:	ff 73 04             	push   0x4(%ebx)
80105571:	57                   	push   %edi
80105572:	56                   	push   %esi
80105573:	e8 78 ca ff ff       	call   80101ff0 <dirlink>
80105578:	83 c4 10             	add    $0x10,%esp
8010557b:	85 c0                	test   %eax,%eax
8010557d:	78 29                	js     801055a8 <sys_link+0xe8>
  iunlockput(dp);
8010557f:	83 ec 0c             	sub    $0xc,%esp
80105582:	56                   	push   %esi
80105583:	e8 98 c4 ff ff       	call   80101a20 <iunlockput>
  iput(ip);
80105588:	89 1c 24             	mov    %ebx,(%esp)
8010558b:	e8 30 c3 ff ff       	call   801018c0 <iput>
  end_op();
80105590:	e8 ab d8 ff ff       	call   80102e40 <end_op>
  return 0;
80105595:	83 c4 10             	add    $0x10,%esp
80105598:	31 c0                	xor    %eax,%eax
}
8010559a:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010559d:	5b                   	pop    %ebx
8010559e:	5e                   	pop    %esi
8010559f:	5f                   	pop    %edi
801055a0:	5d                   	pop    %ebp
801055a1:	c3                   	ret    
801055a2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    iunlockput(dp);
801055a8:	83 ec 0c             	sub    $0xc,%esp
801055ab:	56                   	push   %esi
801055ac:	e8 6f c4 ff ff       	call   80101a20 <iunlockput>
    goto bad;
801055b1:	83 c4 10             	add    $0x10,%esp
  ilock(ip);
801055b4:	83 ec 0c             	sub    $0xc,%esp
801055b7:	53                   	push   %ebx
801055b8:	e8 d3 c1 ff ff       	call   80101790 <ilock>
  ip->nlink--;
801055bd:	66 83 6b 56 01       	subw   $0x1,0x56(%ebx)
  iupdate(ip);
801055c2:	89 1c 24             	mov    %ebx,(%esp)
801055c5:	e8 16 c1 ff ff       	call   801016e0 <iupdate>
  iunlockput(ip);
801055ca:	89 1c 24             	mov    %ebx,(%esp)
801055cd:	e8 4e c4 ff ff       	call   80101a20 <iunlockput>
  end_op();
801055d2:	e8 69 d8 ff ff       	call   80102e40 <end_op>
  return -1;
801055d7:	83 c4 10             	add    $0x10,%esp
801055da:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801055df:	eb b9                	jmp    8010559a <sys_link+0xda>
    iunlockput(ip);
801055e1:	83 ec 0c             	sub    $0xc,%esp
801055e4:	53                   	push   %ebx
801055e5:	e8 36 c4 ff ff       	call   80101a20 <iunlockput>
    end_op();
801055ea:	e8 51 d8 ff ff       	call   80102e40 <end_op>
    return -1;
801055ef:	83 c4 10             	add    $0x10,%esp
801055f2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801055f7:	eb a1                	jmp    8010559a <sys_link+0xda>
    end_op();
801055f9:	e8 42 d8 ff ff       	call   80102e40 <end_op>
    return -1;
801055fe:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105603:	eb 95                	jmp    8010559a <sys_link+0xda>
80105605:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010560c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

80105610 <sys_unlink>:
{
80105610:	55                   	push   %ebp
80105611:	89 e5                	mov    %esp,%ebp
80105613:	57                   	push   %edi
80105614:	56                   	push   %esi
  if(argstr(0, &path) < 0)
80105615:	8d 45 c0             	lea    -0x40(%ebp),%eax
{
80105618:	53                   	push   %ebx
80105619:	83 ec 54             	sub    $0x54,%esp
  if(argstr(0, &path) < 0)
8010561c:	50                   	push   %eax
8010561d:	6a 00                	push   $0x0
8010561f:	e8 bc f9 ff ff       	call   80104fe0 <argstr>
80105624:	83 c4 10             	add    $0x10,%esp
80105627:	85 c0                	test   %eax,%eax
80105629:	0f 88 7a 01 00 00    	js     801057a9 <sys_unlink+0x199>
  begin_op();
8010562f:	e8 9c d7 ff ff       	call   80102dd0 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
80105634:	8d 5d ca             	lea    -0x36(%ebp),%ebx
80105637:	83 ec 08             	sub    $0x8,%esp
8010563a:	53                   	push   %ebx
8010563b:	ff 75 c0             	push   -0x40(%ebp)
8010563e:	e8 8d ca ff ff       	call   801020d0 <nameiparent>
80105643:	83 c4 10             	add    $0x10,%esp
80105646:	89 45 b4             	mov    %eax,-0x4c(%ebp)
80105649:	85 c0                	test   %eax,%eax
8010564b:	0f 84 62 01 00 00    	je     801057b3 <sys_unlink+0x1a3>
  ilock(dp);
80105651:	8b 7d b4             	mov    -0x4c(%ebp),%edi
80105654:	83 ec 0c             	sub    $0xc,%esp
80105657:	57                   	push   %edi
80105658:	e8 33 c1 ff ff       	call   80101790 <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
8010565d:	58                   	pop    %eax
8010565e:	5a                   	pop    %edx
8010565f:	68 84 88 10 80       	push   $0x80108884
80105664:	53                   	push   %ebx
80105665:	e8 66 c6 ff ff       	call   80101cd0 <namecmp>
8010566a:	83 c4 10             	add    $0x10,%esp
8010566d:	85 c0                	test   %eax,%eax
8010566f:	0f 84 fb 00 00 00    	je     80105770 <sys_unlink+0x160>
80105675:	83 ec 08             	sub    $0x8,%esp
80105678:	68 83 88 10 80       	push   $0x80108883
8010567d:	53                   	push   %ebx
8010567e:	e8 4d c6 ff ff       	call   80101cd0 <namecmp>
80105683:	83 c4 10             	add    $0x10,%esp
80105686:	85 c0                	test   %eax,%eax
80105688:	0f 84 e2 00 00 00    	je     80105770 <sys_unlink+0x160>
  if((ip = dirlookup(dp, name, &off)) == 0)
8010568e:	83 ec 04             	sub    $0x4,%esp
80105691:	8d 45 c4             	lea    -0x3c(%ebp),%eax
80105694:	50                   	push   %eax
80105695:	53                   	push   %ebx
80105696:	57                   	push   %edi
80105697:	e8 54 c6 ff ff       	call   80101cf0 <dirlookup>
8010569c:	83 c4 10             	add    $0x10,%esp
8010569f:	89 c3                	mov    %eax,%ebx
801056a1:	85 c0                	test   %eax,%eax
801056a3:	0f 84 c7 00 00 00    	je     80105770 <sys_unlink+0x160>
  ilock(ip);
801056a9:	83 ec 0c             	sub    $0xc,%esp
801056ac:	50                   	push   %eax
801056ad:	e8 de c0 ff ff       	call   80101790 <ilock>
  if(ip->nlink < 1)
801056b2:	83 c4 10             	add    $0x10,%esp
801056b5:	66 83 7b 56 00       	cmpw   $0x0,0x56(%ebx)
801056ba:	0f 8e 1c 01 00 00    	jle    801057dc <sys_unlink+0x1cc>
  if(ip->type == T_DIR && !isdirempty(ip)){
801056c0:	66 83 7b 50 01       	cmpw   $0x1,0x50(%ebx)
801056c5:	8d 7d d8             	lea    -0x28(%ebp),%edi
801056c8:	74 66                	je     80105730 <sys_unlink+0x120>
  memset(&de, 0, sizeof(de));
801056ca:	83 ec 04             	sub    $0x4,%esp
801056cd:	6a 10                	push   $0x10
801056cf:	6a 00                	push   $0x0
801056d1:	57                   	push   %edi
801056d2:	e8 89 f5 ff ff       	call   80104c60 <memset>
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801056d7:	6a 10                	push   $0x10
801056d9:	ff 75 c4             	push   -0x3c(%ebp)
801056dc:	57                   	push   %edi
801056dd:	ff 75 b4             	push   -0x4c(%ebp)
801056e0:	e8 bb c4 ff ff       	call   80101ba0 <writei>
801056e5:	83 c4 20             	add    $0x20,%esp
801056e8:	83 f8 10             	cmp    $0x10,%eax
801056eb:	0f 85 de 00 00 00    	jne    801057cf <sys_unlink+0x1bf>
  if(ip->type == T_DIR){
801056f1:	66 83 7b 50 01       	cmpw   $0x1,0x50(%ebx)
801056f6:	0f 84 94 00 00 00    	je     80105790 <sys_unlink+0x180>
  iunlockput(dp);
801056fc:	83 ec 0c             	sub    $0xc,%esp
801056ff:	ff 75 b4             	push   -0x4c(%ebp)
80105702:	e8 19 c3 ff ff       	call   80101a20 <iunlockput>
  ip->nlink--;
80105707:	66 83 6b 56 01       	subw   $0x1,0x56(%ebx)
  iupdate(ip);
8010570c:	89 1c 24             	mov    %ebx,(%esp)
8010570f:	e8 cc bf ff ff       	call   801016e0 <iupdate>
  iunlockput(ip);
80105714:	89 1c 24             	mov    %ebx,(%esp)
80105717:	e8 04 c3 ff ff       	call   80101a20 <iunlockput>
  end_op();
8010571c:	e8 1f d7 ff ff       	call   80102e40 <end_op>
  return 0;
80105721:	83 c4 10             	add    $0x10,%esp
80105724:	31 c0                	xor    %eax,%eax
}
80105726:	8d 65 f4             	lea    -0xc(%ebp),%esp
80105729:	5b                   	pop    %ebx
8010572a:	5e                   	pop    %esi
8010572b:	5f                   	pop    %edi
8010572c:	5d                   	pop    %ebp
8010572d:	c3                   	ret    
8010572e:	66 90                	xchg   %ax,%ax
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80105730:	83 7b 58 20          	cmpl   $0x20,0x58(%ebx)
80105734:	76 94                	jbe    801056ca <sys_unlink+0xba>
80105736:	be 20 00 00 00       	mov    $0x20,%esi
8010573b:	eb 0b                	jmp    80105748 <sys_unlink+0x138>
8010573d:	8d 76 00             	lea    0x0(%esi),%esi
80105740:	83 c6 10             	add    $0x10,%esi
80105743:	3b 73 58             	cmp    0x58(%ebx),%esi
80105746:	73 82                	jae    801056ca <sys_unlink+0xba>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80105748:	6a 10                	push   $0x10
8010574a:	56                   	push   %esi
8010574b:	57                   	push   %edi
8010574c:	53                   	push   %ebx
8010574d:	e8 4e c3 ff ff       	call   80101aa0 <readi>
80105752:	83 c4 10             	add    $0x10,%esp
80105755:	83 f8 10             	cmp    $0x10,%eax
80105758:	75 68                	jne    801057c2 <sys_unlink+0x1b2>
    if(de.inum != 0)
8010575a:	66 83 7d d8 00       	cmpw   $0x0,-0x28(%ebp)
8010575f:	74 df                	je     80105740 <sys_unlink+0x130>
    iunlockput(ip);
80105761:	83 ec 0c             	sub    $0xc,%esp
80105764:	53                   	push   %ebx
80105765:	e8 b6 c2 ff ff       	call   80101a20 <iunlockput>
    goto bad;
8010576a:	83 c4 10             	add    $0x10,%esp
8010576d:	8d 76 00             	lea    0x0(%esi),%esi
  iunlockput(dp);
80105770:	83 ec 0c             	sub    $0xc,%esp
80105773:	ff 75 b4             	push   -0x4c(%ebp)
80105776:	e8 a5 c2 ff ff       	call   80101a20 <iunlockput>
  end_op();
8010577b:	e8 c0 d6 ff ff       	call   80102e40 <end_op>
  return -1;
80105780:	83 c4 10             	add    $0x10,%esp
80105783:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105788:	eb 9c                	jmp    80105726 <sys_unlink+0x116>
8010578a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    dp->nlink--;
80105790:	8b 45 b4             	mov    -0x4c(%ebp),%eax
    iupdate(dp);
80105793:	83 ec 0c             	sub    $0xc,%esp
    dp->nlink--;
80105796:	66 83 68 56 01       	subw   $0x1,0x56(%eax)
    iupdate(dp);
8010579b:	50                   	push   %eax
8010579c:	e8 3f bf ff ff       	call   801016e0 <iupdate>
801057a1:	83 c4 10             	add    $0x10,%esp
801057a4:	e9 53 ff ff ff       	jmp    801056fc <sys_unlink+0xec>
    return -1;
801057a9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801057ae:	e9 73 ff ff ff       	jmp    80105726 <sys_unlink+0x116>
    end_op();
801057b3:	e8 88 d6 ff ff       	call   80102e40 <end_op>
    return -1;
801057b8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801057bd:	e9 64 ff ff ff       	jmp    80105726 <sys_unlink+0x116>
      panic("isdirempty: readi");
801057c2:	83 ec 0c             	sub    $0xc,%esp
801057c5:	68 a8 88 10 80       	push   $0x801088a8
801057ca:	e8 b1 ab ff ff       	call   80100380 <panic>
    panic("unlink: writei");
801057cf:	83 ec 0c             	sub    $0xc,%esp
801057d2:	68 ba 88 10 80       	push   $0x801088ba
801057d7:	e8 a4 ab ff ff       	call   80100380 <panic>
    panic("unlink: nlink < 1");
801057dc:	83 ec 0c             	sub    $0xc,%esp
801057df:	68 96 88 10 80       	push   $0x80108896
801057e4:	e8 97 ab ff ff       	call   80100380 <panic>
801057e9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

801057f0 <sys_open>:

int
sys_open(void)
{
801057f0:	55                   	push   %ebp
801057f1:	89 e5                	mov    %esp,%ebp
801057f3:	57                   	push   %edi
801057f4:	56                   	push   %esi
  char *path;
  int fd, omode;
  struct file *f;
  struct inode *ip;

  if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
801057f5:	8d 45 e0             	lea    -0x20(%ebp),%eax
{
801057f8:	53                   	push   %ebx
801057f9:	83 ec 24             	sub    $0x24,%esp
  if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
801057fc:	50                   	push   %eax
801057fd:	6a 00                	push   $0x0
801057ff:	e8 dc f7 ff ff       	call   80104fe0 <argstr>
80105804:	83 c4 10             	add    $0x10,%esp
80105807:	85 c0                	test   %eax,%eax
80105809:	0f 88 8e 00 00 00    	js     8010589d <sys_open+0xad>
8010580f:	83 ec 08             	sub    $0x8,%esp
80105812:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80105815:	50                   	push   %eax
80105816:	6a 01                	push   $0x1
80105818:	e8 03 f7 ff ff       	call   80104f20 <argint>
8010581d:	83 c4 10             	add    $0x10,%esp
80105820:	85 c0                	test   %eax,%eax
80105822:	78 79                	js     8010589d <sys_open+0xad>
    return -1;

  begin_op();
80105824:	e8 a7 d5 ff ff       	call   80102dd0 <begin_op>

  if(omode & O_CREATE){
80105829:	f6 45 e5 02          	testb  $0x2,-0x1b(%ebp)
8010582d:	75 79                	jne    801058a8 <sys_open+0xb8>
    if(ip == 0){
      end_op();
      return -1;
    }
  } else {
    if((ip = namei(path)) == 0){
8010582f:	83 ec 0c             	sub    $0xc,%esp
80105832:	ff 75 e0             	push   -0x20(%ebp)
80105835:	e8 76 c8 ff ff       	call   801020b0 <namei>
8010583a:	83 c4 10             	add    $0x10,%esp
8010583d:	89 c6                	mov    %eax,%esi
8010583f:	85 c0                	test   %eax,%eax
80105841:	0f 84 7e 00 00 00    	je     801058c5 <sys_open+0xd5>
      end_op();
      return -1;
    }
    ilock(ip);
80105847:	83 ec 0c             	sub    $0xc,%esp
8010584a:	50                   	push   %eax
8010584b:	e8 40 bf ff ff       	call   80101790 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
80105850:	83 c4 10             	add    $0x10,%esp
80105853:	66 83 7e 50 01       	cmpw   $0x1,0x50(%esi)
80105858:	0f 84 c2 00 00 00    	je     80105920 <sys_open+0x130>
      end_op();
      return -1;
    }
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
8010585e:	e8 dd b5 ff ff       	call   80100e40 <filealloc>
80105863:	89 c7                	mov    %eax,%edi
80105865:	85 c0                	test   %eax,%eax
80105867:	74 23                	je     8010588c <sys_open+0x9c>
  struct proc *curproc = myproc();
80105869:	e8 82 e1 ff ff       	call   801039f0 <myproc>
  for(fd = 0; fd < NOFILE; fd++){
8010586e:	31 db                	xor    %ebx,%ebx
    if(curproc->ofile[fd] == 0){
80105870:	8b 54 98 28          	mov    0x28(%eax,%ebx,4),%edx
80105874:	85 d2                	test   %edx,%edx
80105876:	74 60                	je     801058d8 <sys_open+0xe8>
  for(fd = 0; fd < NOFILE; fd++){
80105878:	83 c3 01             	add    $0x1,%ebx
8010587b:	83 fb 10             	cmp    $0x10,%ebx
8010587e:	75 f0                	jne    80105870 <sys_open+0x80>
    if(f)
      fileclose(f);
80105880:	83 ec 0c             	sub    $0xc,%esp
80105883:	57                   	push   %edi
80105884:	e8 77 b6 ff ff       	call   80100f00 <fileclose>
80105889:	83 c4 10             	add    $0x10,%esp
    iunlockput(ip);
8010588c:	83 ec 0c             	sub    $0xc,%esp
8010588f:	56                   	push   %esi
80105890:	e8 8b c1 ff ff       	call   80101a20 <iunlockput>
    end_op();
80105895:	e8 a6 d5 ff ff       	call   80102e40 <end_op>
    return -1;
8010589a:	83 c4 10             	add    $0x10,%esp
8010589d:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
801058a2:	eb 6d                	jmp    80105911 <sys_open+0x121>
801058a4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    ip = create(path, T_FILE, 0, 0);
801058a8:	83 ec 0c             	sub    $0xc,%esp
801058ab:	8b 45 e0             	mov    -0x20(%ebp),%eax
801058ae:	31 c9                	xor    %ecx,%ecx
801058b0:	ba 02 00 00 00       	mov    $0x2,%edx
801058b5:	6a 00                	push   $0x0
801058b7:	e8 14 f8 ff ff       	call   801050d0 <create>
    if(ip == 0){
801058bc:	83 c4 10             	add    $0x10,%esp
    ip = create(path, T_FILE, 0, 0);
801058bf:	89 c6                	mov    %eax,%esi
    if(ip == 0){
801058c1:	85 c0                	test   %eax,%eax
801058c3:	75 99                	jne    8010585e <sys_open+0x6e>
      end_op();
801058c5:	e8 76 d5 ff ff       	call   80102e40 <end_op>
      return -1;
801058ca:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
801058cf:	eb 40                	jmp    80105911 <sys_open+0x121>
801058d1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  }
  iunlock(ip);
801058d8:	83 ec 0c             	sub    $0xc,%esp
      curproc->ofile[fd] = f;
801058db:	89 7c 98 28          	mov    %edi,0x28(%eax,%ebx,4)
  iunlock(ip);
801058df:	56                   	push   %esi
801058e0:	e8 8b bf ff ff       	call   80101870 <iunlock>
  end_op();
801058e5:	e8 56 d5 ff ff       	call   80102e40 <end_op>

  f->type = FD_INODE;
801058ea:	c7 07 02 00 00 00    	movl   $0x2,(%edi)
  f->ip = ip;
  f->off = 0;
  f->readable = !(omode & O_WRONLY);
801058f0:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
801058f3:	83 c4 10             	add    $0x10,%esp
  f->ip = ip;
801058f6:	89 77 10             	mov    %esi,0x10(%edi)
  f->readable = !(omode & O_WRONLY);
801058f9:	89 d0                	mov    %edx,%eax
  f->off = 0;
801058fb:	c7 47 14 00 00 00 00 	movl   $0x0,0x14(%edi)
  f->readable = !(omode & O_WRONLY);
80105902:	f7 d0                	not    %eax
80105904:	83 e0 01             	and    $0x1,%eax
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
80105907:	83 e2 03             	and    $0x3,%edx
  f->readable = !(omode & O_WRONLY);
8010590a:	88 47 08             	mov    %al,0x8(%edi)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
8010590d:	0f 95 47 09          	setne  0x9(%edi)
  return fd;
}
80105911:	8d 65 f4             	lea    -0xc(%ebp),%esp
80105914:	89 d8                	mov    %ebx,%eax
80105916:	5b                   	pop    %ebx
80105917:	5e                   	pop    %esi
80105918:	5f                   	pop    %edi
80105919:	5d                   	pop    %ebp
8010591a:	c3                   	ret    
8010591b:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
8010591f:	90                   	nop
    if(ip->type == T_DIR && omode != O_RDONLY){
80105920:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
80105923:	85 c9                	test   %ecx,%ecx
80105925:	0f 84 33 ff ff ff    	je     8010585e <sys_open+0x6e>
8010592b:	e9 5c ff ff ff       	jmp    8010588c <sys_open+0x9c>

80105930 <sys_mkdir>:

int
sys_mkdir(void)
{
80105930:	55                   	push   %ebp
80105931:	89 e5                	mov    %esp,%ebp
80105933:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;

  begin_op();
80105936:	e8 95 d4 ff ff       	call   80102dd0 <begin_op>
  if(argstr(0, &path) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
8010593b:	83 ec 08             	sub    $0x8,%esp
8010593e:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105941:	50                   	push   %eax
80105942:	6a 00                	push   $0x0
80105944:	e8 97 f6 ff ff       	call   80104fe0 <argstr>
80105949:	83 c4 10             	add    $0x10,%esp
8010594c:	85 c0                	test   %eax,%eax
8010594e:	78 30                	js     80105980 <sys_mkdir+0x50>
80105950:	83 ec 0c             	sub    $0xc,%esp
80105953:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105956:	31 c9                	xor    %ecx,%ecx
80105958:	ba 01 00 00 00       	mov    $0x1,%edx
8010595d:	6a 00                	push   $0x0
8010595f:	e8 6c f7 ff ff       	call   801050d0 <create>
80105964:	83 c4 10             	add    $0x10,%esp
80105967:	85 c0                	test   %eax,%eax
80105969:	74 15                	je     80105980 <sys_mkdir+0x50>
    end_op();
    return -1;
  }
  iunlockput(ip);
8010596b:	83 ec 0c             	sub    $0xc,%esp
8010596e:	50                   	push   %eax
8010596f:	e8 ac c0 ff ff       	call   80101a20 <iunlockput>
  end_op();
80105974:	e8 c7 d4 ff ff       	call   80102e40 <end_op>
  return 0;
80105979:	83 c4 10             	add    $0x10,%esp
8010597c:	31 c0                	xor    %eax,%eax
}
8010597e:	c9                   	leave  
8010597f:	c3                   	ret    
    end_op();
80105980:	e8 bb d4 ff ff       	call   80102e40 <end_op>
    return -1;
80105985:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010598a:	c9                   	leave  
8010598b:	c3                   	ret    
8010598c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

80105990 <sys_mknod>:

int
sys_mknod(void)
{
80105990:	55                   	push   %ebp
80105991:	89 e5                	mov    %esp,%ebp
80105993:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip;
  char *path;
  int major, minor;

  begin_op();
80105996:	e8 35 d4 ff ff       	call   80102dd0 <begin_op>
  if((argstr(0, &path)) < 0 ||
8010599b:	83 ec 08             	sub    $0x8,%esp
8010599e:	8d 45 ec             	lea    -0x14(%ebp),%eax
801059a1:	50                   	push   %eax
801059a2:	6a 00                	push   $0x0
801059a4:	e8 37 f6 ff ff       	call   80104fe0 <argstr>
801059a9:	83 c4 10             	add    $0x10,%esp
801059ac:	85 c0                	test   %eax,%eax
801059ae:	78 60                	js     80105a10 <sys_mknod+0x80>
     argint(1, &major) < 0 ||
801059b0:	83 ec 08             	sub    $0x8,%esp
801059b3:	8d 45 f0             	lea    -0x10(%ebp),%eax
801059b6:	50                   	push   %eax
801059b7:	6a 01                	push   $0x1
801059b9:	e8 62 f5 ff ff       	call   80104f20 <argint>
  if((argstr(0, &path)) < 0 ||
801059be:	83 c4 10             	add    $0x10,%esp
801059c1:	85 c0                	test   %eax,%eax
801059c3:	78 4b                	js     80105a10 <sys_mknod+0x80>
     argint(2, &minor) < 0 ||
801059c5:	83 ec 08             	sub    $0x8,%esp
801059c8:	8d 45 f4             	lea    -0xc(%ebp),%eax
801059cb:	50                   	push   %eax
801059cc:	6a 02                	push   $0x2
801059ce:	e8 4d f5 ff ff       	call   80104f20 <argint>
     argint(1, &major) < 0 ||
801059d3:	83 c4 10             	add    $0x10,%esp
801059d6:	85 c0                	test   %eax,%eax
801059d8:	78 36                	js     80105a10 <sys_mknod+0x80>
     (ip = create(path, T_DEV, major, minor)) == 0){
801059da:	0f bf 45 f4          	movswl -0xc(%ebp),%eax
801059de:	83 ec 0c             	sub    $0xc,%esp
801059e1:	0f bf 4d f0          	movswl -0x10(%ebp),%ecx
801059e5:	ba 03 00 00 00       	mov    $0x3,%edx
801059ea:	50                   	push   %eax
801059eb:	8b 45 ec             	mov    -0x14(%ebp),%eax
801059ee:	e8 dd f6 ff ff       	call   801050d0 <create>
     argint(2, &minor) < 0 ||
801059f3:	83 c4 10             	add    $0x10,%esp
801059f6:	85 c0                	test   %eax,%eax
801059f8:	74 16                	je     80105a10 <sys_mknod+0x80>
    end_op();
    return -1;
  }
  iunlockput(ip);
801059fa:	83 ec 0c             	sub    $0xc,%esp
801059fd:	50                   	push   %eax
801059fe:	e8 1d c0 ff ff       	call   80101a20 <iunlockput>
  end_op();
80105a03:	e8 38 d4 ff ff       	call   80102e40 <end_op>
  return 0;
80105a08:	83 c4 10             	add    $0x10,%esp
80105a0b:	31 c0                	xor    %eax,%eax
}
80105a0d:	c9                   	leave  
80105a0e:	c3                   	ret    
80105a0f:	90                   	nop
    end_op();
80105a10:	e8 2b d4 ff ff       	call   80102e40 <end_op>
    return -1;
80105a15:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105a1a:	c9                   	leave  
80105a1b:	c3                   	ret    
80105a1c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

80105a20 <sys_chdir>:

int
sys_chdir(void)
{
80105a20:	55                   	push   %ebp
80105a21:	89 e5                	mov    %esp,%ebp
80105a23:	56                   	push   %esi
80105a24:	53                   	push   %ebx
80105a25:	83 ec 10             	sub    $0x10,%esp
  char *path;
  struct inode *ip;
  struct proc *curproc = myproc();
80105a28:	e8 c3 df ff ff       	call   801039f0 <myproc>
80105a2d:	89 c6                	mov    %eax,%esi
  
  begin_op();
80105a2f:	e8 9c d3 ff ff       	call   80102dd0 <begin_op>
  if(argstr(0, &path) < 0 || (ip = namei(path)) == 0){
80105a34:	83 ec 08             	sub    $0x8,%esp
80105a37:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105a3a:	50                   	push   %eax
80105a3b:	6a 00                	push   $0x0
80105a3d:	e8 9e f5 ff ff       	call   80104fe0 <argstr>
80105a42:	83 c4 10             	add    $0x10,%esp
80105a45:	85 c0                	test   %eax,%eax
80105a47:	78 77                	js     80105ac0 <sys_chdir+0xa0>
80105a49:	83 ec 0c             	sub    $0xc,%esp
80105a4c:	ff 75 f4             	push   -0xc(%ebp)
80105a4f:	e8 5c c6 ff ff       	call   801020b0 <namei>
80105a54:	83 c4 10             	add    $0x10,%esp
80105a57:	89 c3                	mov    %eax,%ebx
80105a59:	85 c0                	test   %eax,%eax
80105a5b:	74 63                	je     80105ac0 <sys_chdir+0xa0>
    end_op();
    return -1;
  }
  ilock(ip);
80105a5d:	83 ec 0c             	sub    $0xc,%esp
80105a60:	50                   	push   %eax
80105a61:	e8 2a bd ff ff       	call   80101790 <ilock>
  if(ip->type != T_DIR){
80105a66:	83 c4 10             	add    $0x10,%esp
80105a69:	66 83 7b 50 01       	cmpw   $0x1,0x50(%ebx)
80105a6e:	75 30                	jne    80105aa0 <sys_chdir+0x80>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
80105a70:	83 ec 0c             	sub    $0xc,%esp
80105a73:	53                   	push   %ebx
80105a74:	e8 f7 bd ff ff       	call   80101870 <iunlock>
  iput(curproc->cwd);
80105a79:	58                   	pop    %eax
80105a7a:	ff 76 68             	push   0x68(%esi)
80105a7d:	e8 3e be ff ff       	call   801018c0 <iput>
  end_op();
80105a82:	e8 b9 d3 ff ff       	call   80102e40 <end_op>
  curproc->cwd = ip;
80105a87:	89 5e 68             	mov    %ebx,0x68(%esi)
  return 0;
80105a8a:	83 c4 10             	add    $0x10,%esp
80105a8d:	31 c0                	xor    %eax,%eax
}
80105a8f:	8d 65 f8             	lea    -0x8(%ebp),%esp
80105a92:	5b                   	pop    %ebx
80105a93:	5e                   	pop    %esi
80105a94:	5d                   	pop    %ebp
80105a95:	c3                   	ret    
80105a96:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80105a9d:	8d 76 00             	lea    0x0(%esi),%esi
    iunlockput(ip);
80105aa0:	83 ec 0c             	sub    $0xc,%esp
80105aa3:	53                   	push   %ebx
80105aa4:	e8 77 bf ff ff       	call   80101a20 <iunlockput>
    end_op();
80105aa9:	e8 92 d3 ff ff       	call   80102e40 <end_op>
    return -1;
80105aae:	83 c4 10             	add    $0x10,%esp
80105ab1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105ab6:	eb d7                	jmp    80105a8f <sys_chdir+0x6f>
80105ab8:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80105abf:	90                   	nop
    end_op();
80105ac0:	e8 7b d3 ff ff       	call   80102e40 <end_op>
    return -1;
80105ac5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105aca:	eb c3                	jmp    80105a8f <sys_chdir+0x6f>
80105acc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

80105ad0 <sys_exec>:

int
sys_exec(void)
{
80105ad0:	55                   	push   %ebp
80105ad1:	89 e5                	mov    %esp,%ebp
80105ad3:	57                   	push   %edi
80105ad4:	56                   	push   %esi
  char *path, *argv[MAXARG];
  int i;
  uint uargv, uarg;

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
80105ad5:	8d 85 5c ff ff ff    	lea    -0xa4(%ebp),%eax
{
80105adb:	53                   	push   %ebx
80105adc:	81 ec a4 00 00 00    	sub    $0xa4,%esp
  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
80105ae2:	50                   	push   %eax
80105ae3:	6a 00                	push   $0x0
80105ae5:	e8 f6 f4 ff ff       	call   80104fe0 <argstr>
80105aea:	83 c4 10             	add    $0x10,%esp
80105aed:	85 c0                	test   %eax,%eax
80105aef:	0f 88 87 00 00 00    	js     80105b7c <sys_exec+0xac>
80105af5:	83 ec 08             	sub    $0x8,%esp
80105af8:	8d 85 60 ff ff ff    	lea    -0xa0(%ebp),%eax
80105afe:	50                   	push   %eax
80105aff:	6a 01                	push   $0x1
80105b01:	e8 1a f4 ff ff       	call   80104f20 <argint>
80105b06:	83 c4 10             	add    $0x10,%esp
80105b09:	85 c0                	test   %eax,%eax
80105b0b:	78 6f                	js     80105b7c <sys_exec+0xac>
    return -1;
  }
  memset(argv, 0, sizeof(argv));
80105b0d:	83 ec 04             	sub    $0x4,%esp
80105b10:	8d b5 68 ff ff ff    	lea    -0x98(%ebp),%esi
  for(i=0;; i++){
80105b16:	31 db                	xor    %ebx,%ebx
  memset(argv, 0, sizeof(argv));
80105b18:	68 80 00 00 00       	push   $0x80
80105b1d:	6a 00                	push   $0x0
80105b1f:	56                   	push   %esi
80105b20:	e8 3b f1 ff ff       	call   80104c60 <memset>
80105b25:	83 c4 10             	add    $0x10,%esp
80105b28:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80105b2f:	90                   	nop
    if(i >= NELEM(argv))
      return -1;
    if(fetchint(uargv+4*i, (int*)&uarg) < 0)
80105b30:	83 ec 08             	sub    $0x8,%esp
80105b33:	8d 85 64 ff ff ff    	lea    -0x9c(%ebp),%eax
80105b39:	8d 3c 9d 00 00 00 00 	lea    0x0(,%ebx,4),%edi
80105b40:	50                   	push   %eax
80105b41:	8b 85 60 ff ff ff    	mov    -0xa0(%ebp),%eax
80105b47:	01 f8                	add    %edi,%eax
80105b49:	50                   	push   %eax
80105b4a:	e8 41 f3 ff ff       	call   80104e90 <fetchint>
80105b4f:	83 c4 10             	add    $0x10,%esp
80105b52:	85 c0                	test   %eax,%eax
80105b54:	78 26                	js     80105b7c <sys_exec+0xac>
      return -1;
    if(uarg == 0){
80105b56:	8b 85 64 ff ff ff    	mov    -0x9c(%ebp),%eax
80105b5c:	85 c0                	test   %eax,%eax
80105b5e:	74 30                	je     80105b90 <sys_exec+0xc0>
      argv[i] = 0;
      break;
    }
    if(fetchstr(uarg, &argv[i]) < 0)
80105b60:	83 ec 08             	sub    $0x8,%esp
80105b63:	8d 14 3e             	lea    (%esi,%edi,1),%edx
80105b66:	52                   	push   %edx
80105b67:	50                   	push   %eax
80105b68:	e8 63 f3 ff ff       	call   80104ed0 <fetchstr>
80105b6d:	83 c4 10             	add    $0x10,%esp
80105b70:	85 c0                	test   %eax,%eax
80105b72:	78 08                	js     80105b7c <sys_exec+0xac>
  for(i=0;; i++){
80105b74:	83 c3 01             	add    $0x1,%ebx
    if(i >= NELEM(argv))
80105b77:	83 fb 20             	cmp    $0x20,%ebx
80105b7a:	75 b4                	jne    80105b30 <sys_exec+0x60>
      return -1;
  }
  return exec(path, argv);
}
80105b7c:	8d 65 f4             	lea    -0xc(%ebp),%esp
    return -1;
80105b7f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105b84:	5b                   	pop    %ebx
80105b85:	5e                   	pop    %esi
80105b86:	5f                   	pop    %edi
80105b87:	5d                   	pop    %ebp
80105b88:	c3                   	ret    
80105b89:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
      argv[i] = 0;
80105b90:	c7 84 9d 68 ff ff ff 	movl   $0x0,-0x98(%ebp,%ebx,4)
80105b97:	00 00 00 00 
  return exec(path, argv);
80105b9b:	83 ec 08             	sub    $0x8,%esp
80105b9e:	56                   	push   %esi
80105b9f:	ff b5 5c ff ff ff    	push   -0xa4(%ebp)
80105ba5:	e8 06 af ff ff       	call   80100ab0 <exec>
80105baa:	83 c4 10             	add    $0x10,%esp
}
80105bad:	8d 65 f4             	lea    -0xc(%ebp),%esp
80105bb0:	5b                   	pop    %ebx
80105bb1:	5e                   	pop    %esi
80105bb2:	5f                   	pop    %edi
80105bb3:	5d                   	pop    %ebp
80105bb4:	c3                   	ret    
80105bb5:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80105bbc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

80105bc0 <sys_pipe>:

int
sys_pipe(void)
{
80105bc0:	55                   	push   %ebp
80105bc1:	89 e5                	mov    %esp,%ebp
80105bc3:	57                   	push   %edi
80105bc4:	56                   	push   %esi
  int *fd;
  struct file *rf, *wf;
  int fd0, fd1;

  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
80105bc5:	8d 45 dc             	lea    -0x24(%ebp),%eax
{
80105bc8:	53                   	push   %ebx
80105bc9:	83 ec 20             	sub    $0x20,%esp
  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
80105bcc:	6a 08                	push   $0x8
80105bce:	50                   	push   %eax
80105bcf:	6a 00                	push   $0x0
80105bd1:	e8 9a f3 ff ff       	call   80104f70 <argptr>
80105bd6:	83 c4 10             	add    $0x10,%esp
80105bd9:	85 c0                	test   %eax,%eax
80105bdb:	78 4a                	js     80105c27 <sys_pipe+0x67>
    return -1;
  if(pipealloc(&rf, &wf) < 0)
80105bdd:	83 ec 08             	sub    $0x8,%esp
80105be0:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80105be3:	50                   	push   %eax
80105be4:	8d 45 e0             	lea    -0x20(%ebp),%eax
80105be7:	50                   	push   %eax
80105be8:	e8 b3 d8 ff ff       	call   801034a0 <pipealloc>
80105bed:	83 c4 10             	add    $0x10,%esp
80105bf0:	85 c0                	test   %eax,%eax
80105bf2:	78 33                	js     80105c27 <sys_pipe+0x67>
    return -1;
  fd0 = -1;
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
80105bf4:	8b 7d e0             	mov    -0x20(%ebp),%edi
  for(fd = 0; fd < NOFILE; fd++){
80105bf7:	31 db                	xor    %ebx,%ebx
  struct proc *curproc = myproc();
80105bf9:	e8 f2 dd ff ff       	call   801039f0 <myproc>
  for(fd = 0; fd < NOFILE; fd++){
80105bfe:	66 90                	xchg   %ax,%ax
    if(curproc->ofile[fd] == 0){
80105c00:	8b 74 98 28          	mov    0x28(%eax,%ebx,4),%esi
80105c04:	85 f6                	test   %esi,%esi
80105c06:	74 28                	je     80105c30 <sys_pipe+0x70>
  for(fd = 0; fd < NOFILE; fd++){
80105c08:	83 c3 01             	add    $0x1,%ebx
80105c0b:	83 fb 10             	cmp    $0x10,%ebx
80105c0e:	75 f0                	jne    80105c00 <sys_pipe+0x40>
    if(fd0 >= 0)
      myproc()->ofile[fd0] = 0;
    fileclose(rf);
80105c10:	83 ec 0c             	sub    $0xc,%esp
80105c13:	ff 75 e0             	push   -0x20(%ebp)
80105c16:	e8 e5 b2 ff ff       	call   80100f00 <fileclose>
    fileclose(wf);
80105c1b:	58                   	pop    %eax
80105c1c:	ff 75 e4             	push   -0x1c(%ebp)
80105c1f:	e8 dc b2 ff ff       	call   80100f00 <fileclose>
    return -1;
80105c24:	83 c4 10             	add    $0x10,%esp
80105c27:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105c2c:	eb 53                	jmp    80105c81 <sys_pipe+0xc1>
80105c2e:	66 90                	xchg   %ax,%ax
      curproc->ofile[fd] = f;
80105c30:	8d 73 08             	lea    0x8(%ebx),%esi
80105c33:	89 7c b0 08          	mov    %edi,0x8(%eax,%esi,4)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
80105c37:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  struct proc *curproc = myproc();
80105c3a:	e8 b1 dd ff ff       	call   801039f0 <myproc>
  for(fd = 0; fd < NOFILE; fd++){
80105c3f:	31 d2                	xor    %edx,%edx
80105c41:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    if(curproc->ofile[fd] == 0){
80105c48:	8b 4c 90 28          	mov    0x28(%eax,%edx,4),%ecx
80105c4c:	85 c9                	test   %ecx,%ecx
80105c4e:	74 20                	je     80105c70 <sys_pipe+0xb0>
  for(fd = 0; fd < NOFILE; fd++){
80105c50:	83 c2 01             	add    $0x1,%edx
80105c53:	83 fa 10             	cmp    $0x10,%edx
80105c56:	75 f0                	jne    80105c48 <sys_pipe+0x88>
      myproc()->ofile[fd0] = 0;
80105c58:	e8 93 dd ff ff       	call   801039f0 <myproc>
80105c5d:	c7 44 b0 08 00 00 00 	movl   $0x0,0x8(%eax,%esi,4)
80105c64:	00 
80105c65:	eb a9                	jmp    80105c10 <sys_pipe+0x50>
80105c67:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80105c6e:	66 90                	xchg   %ax,%ax
      curproc->ofile[fd] = f;
80105c70:	89 7c 90 28          	mov    %edi,0x28(%eax,%edx,4)
  }
  fd[0] = fd0;
80105c74:	8b 45 dc             	mov    -0x24(%ebp),%eax
80105c77:	89 18                	mov    %ebx,(%eax)
  fd[1] = fd1;
80105c79:	8b 45 dc             	mov    -0x24(%ebp),%eax
80105c7c:	89 50 04             	mov    %edx,0x4(%eax)
  return 0;
80105c7f:	31 c0                	xor    %eax,%eax
}
80105c81:	8d 65 f4             	lea    -0xc(%ebp),%esp
80105c84:	5b                   	pop    %ebx
80105c85:	5e                   	pop    %esi
80105c86:	5f                   	pop    %edi
80105c87:	5d                   	pop    %ebp
80105c88:	c3                   	ret    
80105c89:	66 90                	xchg   %ax,%ax
80105c8b:	66 90                	xchg   %ax,%ax
80105c8d:	66 90                	xchg   %ax,%ax
80105c8f:	90                   	nop

80105c90 <sys_fork>:
#include "file.h"

int
sys_fork(void)
{
  return fork();
80105c90:	e9 fb de ff ff       	jmp    80103b90 <fork>
80105c95:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80105c9c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

80105ca0 <sys_exit>:
}

int
sys_exit(void)
{
80105ca0:	55                   	push   %ebp
80105ca1:	89 e5                	mov    %esp,%ebp
80105ca3:	83 ec 08             	sub    $0x8,%esp
  exit();
80105ca6:	e8 15 e3 ff ff       	call   80103fc0 <exit>
  return 0;  // not reached
}
80105cab:	31 c0                	xor    %eax,%eax
80105cad:	c9                   	leave  
80105cae:	c3                   	ret    
80105caf:	90                   	nop

80105cb0 <sys_wait>:

int
sys_wait(void)
{
  return wait();
80105cb0:	e9 9b e6 ff ff       	jmp    80104350 <wait>
80105cb5:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80105cbc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

80105cc0 <sys_kill>:
}

int
sys_kill(void)
{
80105cc0:	55                   	push   %ebp
80105cc1:	89 e5                	mov    %esp,%ebp
80105cc3:	83 ec 20             	sub    $0x20,%esp
  int pid;

  if(argint(0, &pid) < 0)
80105cc6:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105cc9:	50                   	push   %eax
80105cca:	6a 00                	push   $0x0
80105ccc:	e8 4f f2 ff ff       	call   80104f20 <argint>
80105cd1:	83 c4 10             	add    $0x10,%esp
80105cd4:	85 c0                	test   %eax,%eax
80105cd6:	78 18                	js     80105cf0 <sys_kill+0x30>
    return -1;
  return kill(pid);
80105cd8:	83 ec 0c             	sub    $0xc,%esp
80105cdb:	ff 75 f4             	push   -0xc(%ebp)
80105cde:	e8 0d e9 ff ff       	call   801045f0 <kill>
80105ce3:	83 c4 10             	add    $0x10,%esp
}
80105ce6:	c9                   	leave  
80105ce7:	c3                   	ret    
80105ce8:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80105cef:	90                   	nop
80105cf0:	c9                   	leave  
    return -1;
80105cf1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105cf6:	c3                   	ret    
80105cf7:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80105cfe:	66 90                	xchg   %ax,%ax

80105d00 <sys_getpid>:

int
sys_getpid(void)
{
80105d00:	55                   	push   %ebp
80105d01:	89 e5                	mov    %esp,%ebp
80105d03:	83 ec 08             	sub    $0x8,%esp
  return myproc()->pid;
80105d06:	e8 e5 dc ff ff       	call   801039f0 <myproc>
80105d0b:	8b 40 10             	mov    0x10(%eax),%eax
}
80105d0e:	c9                   	leave  
80105d0f:	c3                   	ret    

80105d10 <sys_sbrk>:

int
sys_sbrk(void)
{
80105d10:	55                   	push   %ebp
80105d11:	89 e5                	mov    %esp,%ebp
80105d13:	53                   	push   %ebx
  int addr;
  int n;

  if(argint(0, &n) < 0)
80105d14:	8d 45 f4             	lea    -0xc(%ebp),%eax
{
80105d17:	83 ec 1c             	sub    $0x1c,%esp
  if(argint(0, &n) < 0)
80105d1a:	50                   	push   %eax
80105d1b:	6a 00                	push   $0x0
80105d1d:	e8 fe f1 ff ff       	call   80104f20 <argint>
80105d22:	83 c4 10             	add    $0x10,%esp
80105d25:	85 c0                	test   %eax,%eax
80105d27:	78 27                	js     80105d50 <sys_sbrk+0x40>
    return -1;
  addr = myproc()->sz;
80105d29:	e8 c2 dc ff ff       	call   801039f0 <myproc>
  if(growproc(n) < 0)
80105d2e:	83 ec 0c             	sub    $0xc,%esp
  addr = myproc()->sz;
80105d31:	8b 18                	mov    (%eax),%ebx
  if(growproc(n) < 0)
80105d33:	ff 75 f4             	push   -0xc(%ebp)
80105d36:	e8 d5 dd ff ff       	call   80103b10 <growproc>
80105d3b:	83 c4 10             	add    $0x10,%esp
80105d3e:	85 c0                	test   %eax,%eax
80105d40:	78 0e                	js     80105d50 <sys_sbrk+0x40>
    return -1;
  return addr;
}
80105d42:	89 d8                	mov    %ebx,%eax
80105d44:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80105d47:	c9                   	leave  
80105d48:	c3                   	ret    
80105d49:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    return -1;
80105d50:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
80105d55:	eb eb                	jmp    80105d42 <sys_sbrk+0x32>
80105d57:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80105d5e:	66 90                	xchg   %ax,%ax

80105d60 <sys_sleep>:

int
sys_sleep(void)
{
80105d60:	55                   	push   %ebp
80105d61:	89 e5                	mov    %esp,%ebp
80105d63:	53                   	push   %ebx
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
80105d64:	8d 45 f4             	lea    -0xc(%ebp),%eax
{
80105d67:	83 ec 1c             	sub    $0x1c,%esp
  if(argint(0, &n) < 0)
80105d6a:	50                   	push   %eax
80105d6b:	6a 00                	push   $0x0
80105d6d:	e8 ae f1 ff ff       	call   80104f20 <argint>
80105d72:	83 c4 10             	add    $0x10,%esp
80105d75:	85 c0                	test   %eax,%eax
80105d77:	0f 88 8a 00 00 00    	js     80105e07 <sys_sleep+0xa7>
    return -1;
  acquire(&tickslock);
80105d7d:	83 ec 0c             	sub    $0xc,%esp
80105d80:	68 c0 9d 21 80       	push   $0x80219dc0
80105d85:	e8 16 ee ff ff       	call   80104ba0 <acquire>
  ticks0 = ticks;
  while(ticks - ticks0 < n){
80105d8a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  ticks0 = ticks;
80105d8d:	8b 1d a0 9d 21 80    	mov    0x80219da0,%ebx
  while(ticks - ticks0 < n){
80105d93:	83 c4 10             	add    $0x10,%esp
80105d96:	85 d2                	test   %edx,%edx
80105d98:	75 27                	jne    80105dc1 <sys_sleep+0x61>
80105d9a:	eb 54                	jmp    80105df0 <sys_sleep+0x90>
80105d9c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    if(myproc()->killed){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
80105da0:	83 ec 08             	sub    $0x8,%esp
80105da3:	68 c0 9d 21 80       	push   $0x80219dc0
80105da8:	68 a0 9d 21 80       	push   $0x80219da0
80105dad:	e8 1e e7 ff ff       	call   801044d0 <sleep>
  while(ticks - ticks0 < n){
80105db2:	a1 a0 9d 21 80       	mov    0x80219da0,%eax
80105db7:	83 c4 10             	add    $0x10,%esp
80105dba:	29 d8                	sub    %ebx,%eax
80105dbc:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80105dbf:	73 2f                	jae    80105df0 <sys_sleep+0x90>
    if(myproc()->killed){
80105dc1:	e8 2a dc ff ff       	call   801039f0 <myproc>
80105dc6:	8b 40 24             	mov    0x24(%eax),%eax
80105dc9:	85 c0                	test   %eax,%eax
80105dcb:	74 d3                	je     80105da0 <sys_sleep+0x40>
      release(&tickslock);
80105dcd:	83 ec 0c             	sub    $0xc,%esp
80105dd0:	68 c0 9d 21 80       	push   $0x80219dc0
80105dd5:	e8 66 ed ff ff       	call   80104b40 <release>
  }
  release(&tickslock);
  return 0;
}
80105dda:	8b 5d fc             	mov    -0x4(%ebp),%ebx
      return -1;
80105ddd:	83 c4 10             	add    $0x10,%esp
80105de0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105de5:	c9                   	leave  
80105de6:	c3                   	ret    
80105de7:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80105dee:	66 90                	xchg   %ax,%ax
  release(&tickslock);
80105df0:	83 ec 0c             	sub    $0xc,%esp
80105df3:	68 c0 9d 21 80       	push   $0x80219dc0
80105df8:	e8 43 ed ff ff       	call   80104b40 <release>
  return 0;
80105dfd:	83 c4 10             	add    $0x10,%esp
80105e00:	31 c0                	xor    %eax,%eax
}
80105e02:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80105e05:	c9                   	leave  
80105e06:	c3                   	ret    
    return -1;
80105e07:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105e0c:	eb f4                	jmp    80105e02 <sys_sleep+0xa2>
80105e0e:	66 90                	xchg   %ax,%ax

80105e10 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
int
sys_uptime(void)
{
80105e10:	55                   	push   %ebp
80105e11:	89 e5                	mov    %esp,%ebp
80105e13:	53                   	push   %ebx
80105e14:	83 ec 10             	sub    $0x10,%esp
  uint xticks;

  acquire(&tickslock);
80105e17:	68 c0 9d 21 80       	push   $0x80219dc0
80105e1c:	e8 7f ed ff ff       	call   80104ba0 <acquire>
  xticks = ticks;
80105e21:	8b 1d a0 9d 21 80    	mov    0x80219da0,%ebx
  release(&tickslock);
80105e27:	c7 04 24 c0 9d 21 80 	movl   $0x80219dc0,(%esp)
80105e2e:	e8 0d ed ff ff       	call   80104b40 <release>
  return xticks;
}
80105e33:	89 d8                	mov    %ebx,%eax
80105e35:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80105e38:	c9                   	leave  
80105e39:	c3                   	ret    
80105e3a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

80105e40 <sys_wmap>:

uint
sys_wmap(void) {
80105e40:	55                   	push   %ebp
80105e41:	89 e5                	mov    %esp,%ebp
80105e43:	53                   	push   %ebx
    uint addr;
    int length, flags, fd;

    if (argint(0, (int*)&addr) < 0 || argint(1, &length) < 0 || argint(2, &flags) < 0 || argint(3, &fd) < 0) {
80105e44:	8d 45 e8             	lea    -0x18(%ebp),%eax
sys_wmap(void) {
80105e47:	83 ec 1c             	sub    $0x1c,%esp
    if (argint(0, (int*)&addr) < 0 || argint(1, &length) < 0 || argint(2, &flags) < 0 || argint(3, &fd) < 0) {
80105e4a:	50                   	push   %eax
80105e4b:	6a 00                	push   $0x0
80105e4d:	e8 ce f0 ff ff       	call   80104f20 <argint>
80105e52:	83 c4 10             	add    $0x10,%esp
80105e55:	85 c0                	test   %eax,%eax
80105e57:	78 77                	js     80105ed0 <sys_wmap+0x90>
80105e59:	83 ec 08             	sub    $0x8,%esp
80105e5c:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105e5f:	50                   	push   %eax
80105e60:	6a 01                	push   $0x1
80105e62:	e8 b9 f0 ff ff       	call   80104f20 <argint>
80105e67:	83 c4 10             	add    $0x10,%esp
80105e6a:	85 c0                	test   %eax,%eax
80105e6c:	78 62                	js     80105ed0 <sys_wmap+0x90>
80105e6e:	83 ec 08             	sub    $0x8,%esp
80105e71:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105e74:	50                   	push   %eax
80105e75:	6a 02                	push   $0x2
80105e77:	e8 a4 f0 ff ff       	call   80104f20 <argint>
80105e7c:	83 c4 10             	add    $0x10,%esp
80105e7f:	85 c0                	test   %eax,%eax
80105e81:	78 4d                	js     80105ed0 <sys_wmap+0x90>
80105e83:	83 ec 08             	sub    $0x8,%esp
80105e86:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105e89:	50                   	push   %eax
80105e8a:	6a 03                	push   $0x3
80105e8c:	e8 8f f0 ff ff       	call   80104f20 <argint>
80105e91:	83 c4 10             	add    $0x10,%esp
80105e94:	85 c0                	test   %eax,%eax
80105e96:	78 38                	js     80105ed0 <sys_wmap+0x90>
        return FAILED;
    }

    // Basic validation checks
    if (length <= 0 || !(flags & MAP_FIXED) || !(flags & MAP_SHARED)) {
80105e98:	8b 45 ec             	mov    -0x14(%ebp),%eax
80105e9b:	85 c0                	test   %eax,%eax
80105e9d:	7e 31                	jle    80105ed0 <sys_wmap+0x90>
80105e9f:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105ea2:	89 d1                	mov    %edx,%ecx
80105ea4:	83 e1 0a             	and    $0xa,%ecx
80105ea7:	83 f9 0a             	cmp    $0xa,%ecx
80105eaa:	75 24                	jne    80105ed0 <sys_wmap+0x90>
        return FAILED;
    }

    // Validate address if MAP_FIXED is set
    if (addr < 0x60000000 || addr >= 0x80000000) {
80105eac:	8b 4d e8             	mov    -0x18(%ebp),%ecx
80105eaf:	8d 99 00 00 00 a0    	lea    -0x60000000(%ecx),%ebx
80105eb5:	81 fb ff ff ff 1f    	cmp    $0x1fffffff,%ebx
80105ebb:	77 13                	ja     80105ed0 <sys_wmap+0x90>
        return FAILED;
    }

    return proc_wmap(addr, length, flags, fd);
80105ebd:	ff 75 f4             	push   -0xc(%ebp)
80105ec0:	52                   	push   %edx
80105ec1:	50                   	push   %eax
80105ec2:	51                   	push   %ecx
80105ec3:	e8 68 e8 ff ff       	call   80104730 <proc_wmap>
    return FAILED;
}
80105ec8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
    return proc_wmap(addr, length, flags, fd);
80105ecb:	83 c4 10             	add    $0x10,%esp
}
80105ece:	c9                   	leave  
80105ecf:	c3                   	ret    
80105ed0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
        return FAILED;
80105ed3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105ed8:	c9                   	leave  
80105ed9:	c3                   	ret    
80105eda:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

80105ee0 <sys_wunmap>:

// System call to remove a memory mapping
int
sys_wunmap(void) {
80105ee0:	55                   	push   %ebp
80105ee1:	89 e5                	mov    %esp,%ebp
80105ee3:	57                   	push   %edi
80105ee4:	56                   	push   %esi
    uint addr;
    if (argint(0, (int*)&addr) < 0) {
80105ee5:	8d 45 e4             	lea    -0x1c(%ebp),%eax
sys_wunmap(void) {
80105ee8:	53                   	push   %ebx
80105ee9:	83 ec 34             	sub    $0x34,%esp
    if (argint(0, (int*)&addr) < 0) {
80105eec:	50                   	push   %eax
80105eed:	6a 00                	push   $0x0
80105eef:	e8 2c f0 ff ff       	call   80104f20 <argint>
80105ef4:	83 c4 10             	add    $0x10,%esp
80105ef7:	85 c0                	test   %eax,%eax
80105ef9:	0f 88 02 02 00 00    	js     80106101 <sys_wunmap+0x221>
        return FAILED;
    }

    struct proc *curproc = myproc();
80105eff:	e8 ec da ff ff       	call   801039f0 <myproc>
80105f04:	89 c7                	mov    %eax,%edi
    struct mmap_region *region = 0;
    int region_index = -1;

    // Find the region with the matching start address
    for (int i = 0; i < curproc->num_mmap_regions; i++) {
80105f06:	8b 80 bc 01 00 00    	mov    0x1bc(%eax),%eax
80105f0c:	85 c0                	test   %eax,%eax
80105f0e:	0f 8e ed 01 00 00    	jle    80106101 <sys_wunmap+0x221>
        if (curproc->mmap_regions[i].start_addr == addr) {
80105f14:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80105f17:	8d 4f 7c             	lea    0x7c(%edi),%ecx
    for (int i = 0; i < curproc->num_mmap_regions; i++) {
80105f1a:	31 f6                	xor    %esi,%esi
80105f1c:	eb 10                	jmp    80105f2e <sys_wunmap+0x4e>
80105f1e:	66 90                	xchg   %ax,%ax
80105f20:	83 c6 01             	add    $0x1,%esi
80105f23:	83 c1 14             	add    $0x14,%ecx
80105f26:	39 c6                	cmp    %eax,%esi
80105f28:	0f 84 d3 01 00 00    	je     80106101 <sys_wunmap+0x221>
        if (curproc->mmap_regions[i].start_addr == addr) {
80105f2e:	8b 19                	mov    (%ecx),%ebx
80105f30:	39 d3                	cmp    %edx,%ebx
80105f32:	75 ec                	jne    80105f20 <sys_wunmap+0x40>
            break;
        }
    }

    // Check if a valid mapping was found and if addr is page-aligned
    if (!region || addr % PGSIZE != 0) {
80105f34:	89 5d d0             	mov    %ebx,-0x30(%ebp)
80105f37:	f7 c2 ff 0f 00 00    	test   $0xfff,%edx
80105f3d:	0f 85 be 01 00 00    	jne    80106101 <sys_wunmap+0x221>
    if (region->flags & MAP_SHARED) {
        if (region->fd >= 0) {
            // File-backed mapping: write back changes to the file
            struct file *f = curproc->ofile[region->fd];
            if (f) {
                for (uint va = region->start_addr; va < region->start_addr + region->length; va += PGSIZE) {
80105f43:	8d 0c b6             	lea    (%esi,%esi,4),%ecx
80105f46:	89 4d cc             	mov    %ecx,-0x34(%ebp)
80105f49:	8d 0c 8f             	lea    (%edi,%ecx,4),%ecx
80105f4c:	8b 99 80 00 00 00    	mov    0x80(%ecx),%ebx
80105f52:	89 4d c8             	mov    %ecx,-0x38(%ebp)
80105f55:	01 d3                	add    %edx,%ebx
80105f57:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
    if (region->flags & MAP_SHARED) {
80105f5a:	f6 81 84 00 00 00 02 	testb  $0x2,0x84(%ecx)
80105f61:	0f 85 e9 00 00 00    	jne    80106050 <sys_wunmap+0x170>
            }
        }
    }

    // Unmap and free each page in the mapping
    for (uint va = region->start_addr; va < region->start_addr + region->length; va += PGSIZE) {
80105f67:	8b 5d d0             	mov    -0x30(%ebp),%ebx
80105f6a:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80105f6d:	39 c3                	cmp    %eax,%ebx
80105f6f:	73 75                	jae    80105fe6 <sys_wunmap+0x106>
80105f71:	8d 04 b6             	lea    (%esi,%esi,4),%eax
80105f74:	89 7d d4             	mov    %edi,-0x2c(%ebp)
80105f77:	8d 14 87             	lea    (%edi,%eax,4),%edx
80105f7a:	89 75 d0             	mov    %esi,-0x30(%ebp)
80105f7d:	89 de                	mov    %ebx,%esi
80105f7f:	89 d7                	mov    %edx,%edi
80105f81:	eb 18                	jmp    80105f9b <sys_wunmap+0xbb>
80105f83:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80105f87:	90                   	nop
80105f88:	8b 87 80 00 00 00    	mov    0x80(%edi),%eax
80105f8e:	81 c6 00 10 00 00    	add    $0x1000,%esi
80105f94:	03 47 7c             	add    0x7c(%edi),%eax
80105f97:	39 f0                	cmp    %esi,%eax
80105f99:	76 45                	jbe    80105fe0 <sys_wunmap+0x100>
        pte_t *pte = walkpgdir(curproc->pgdir, (void*)va, 0);
80105f9b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80105f9e:	83 ec 04             	sub    $0x4,%esp
80105fa1:	6a 00                	push   $0x0
80105fa3:	56                   	push   %esi
80105fa4:	ff 70 04             	push   0x4(%eax)
80105fa7:	e8 94 17 00 00       	call   80107740 <walkpgdir>
        if (pte && (*pte & PTE_P)) {
80105fac:	83 c4 10             	add    $0x10,%esp
        pte_t *pte = walkpgdir(curproc->pgdir, (void*)va, 0);
80105faf:	89 c3                	mov    %eax,%ebx
        if (pte && (*pte & PTE_P)) {
80105fb1:	85 c0                	test   %eax,%eax
80105fb3:	74 d3                	je     80105f88 <sys_wunmap+0xa8>
80105fb5:	8b 00                	mov    (%eax),%eax
80105fb7:	a8 01                	test   $0x1,%al
80105fb9:	74 cd                	je     80105f88 <sys_wunmap+0xa8>
            uint pa = PTE_ADDR(*pte);
80105fbb:	25 00 f0 ff ff       	and    $0xfffff000,%eax
            kfree(P2V(pa));      // Free the physical page
80105fc0:	83 ec 0c             	sub    $0xc,%esp
80105fc3:	05 00 00 00 80       	add    $0x80000000,%eax
80105fc8:	50                   	push   %eax
80105fc9:	e8 62 c5 ff ff       	call   80102530 <kfree>
            *pte = 0;            // Clear the page table entry
80105fce:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
80105fd4:	83 c4 10             	add    $0x10,%esp
80105fd7:	eb af                	jmp    80105f88 <sys_wunmap+0xa8>
80105fd9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
        }
    }

    // Remove the mapping from the process's list by shifting entries
    for (int j = region_index; j < curproc->num_mmap_regions - 1; j++) {
80105fe0:	8b 7d d4             	mov    -0x2c(%ebp),%edi
80105fe3:	8b 75 d0             	mov    -0x30(%ebp),%esi
80105fe6:	8b 87 bc 01 00 00    	mov    0x1bc(%edi),%eax
80105fec:	8d 48 ff             	lea    -0x1(%eax),%ecx
80105fef:	39 ce                	cmp    %ecx,%esi
80105ff1:	7d 3a                	jge    8010602d <sys_wunmap+0x14d>
80105ff3:	8d 14 b6             	lea    (%esi,%esi,4),%edx
80105ff6:	8d 04 80             	lea    (%eax,%eax,4),%eax
80105ff9:	8d 54 97 7c          	lea    0x7c(%edi,%edx,4),%edx
80105ffd:	8d 5c 87 68          	lea    0x68(%edi,%eax,4),%ebx
80106001:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
        curproc->mmap_regions[j] = curproc->mmap_regions[j + 1];
80106008:	8b 42 14             	mov    0x14(%edx),%eax
    for (int j = region_index; j < curproc->num_mmap_regions - 1; j++) {
8010600b:	83 c2 14             	add    $0x14,%edx
        curproc->mmap_regions[j] = curproc->mmap_regions[j + 1];
8010600e:	89 42 ec             	mov    %eax,-0x14(%edx)
80106011:	8b 42 04             	mov    0x4(%edx),%eax
80106014:	89 42 f0             	mov    %eax,-0x10(%edx)
80106017:	8b 42 08             	mov    0x8(%edx),%eax
8010601a:	89 42 f4             	mov    %eax,-0xc(%edx)
8010601d:	8b 42 0c             	mov    0xc(%edx),%eax
80106020:	89 42 f8             	mov    %eax,-0x8(%edx)
80106023:	8b 42 10             	mov    0x10(%edx),%eax
80106026:	89 42 fc             	mov    %eax,-0x4(%edx)
    for (int j = region_index; j < curproc->num_mmap_regions - 1; j++) {
80106029:	39 d3                	cmp    %edx,%ebx
8010602b:	75 db                	jne    80106008 <sys_wunmap+0x128>
    }
    curproc->num_mmap_regions--;

    // Flush TLB to ensure changes take effect
    lcr3(V2P(curproc->pgdir));
8010602d:	8b 47 04             	mov    0x4(%edi),%eax
    curproc->num_mmap_regions--;
80106030:	89 8f bc 01 00 00    	mov    %ecx,0x1bc(%edi)
    lcr3(V2P(curproc->pgdir));
80106036:	05 00 00 00 80       	add    $0x80000000,%eax
  asm volatile("movl %0,%%cr3" : : "r" (val));
8010603b:	0f 22 d8             	mov    %eax,%cr3

    return SUCCESS;
}
8010603e:	8d 65 f4             	lea    -0xc(%ebp),%esp
    return SUCCESS;
80106041:	31 c0                	xor    %eax,%eax
}
80106043:	5b                   	pop    %ebx
80106044:	5e                   	pop    %esi
80106045:	5f                   	pop    %edi
80106046:	5d                   	pop    %ebp
80106047:	c3                   	ret    
80106048:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010604f:	90                   	nop
        if (region->fd >= 0) {
80106050:	8b 99 88 00 00 00    	mov    0x88(%ecx),%ebx
80106056:	85 db                	test   %ebx,%ebx
80106058:	0f 88 b2 00 00 00    	js     80106110 <sys_wunmap+0x230>
            struct file *f = curproc->ofile[region->fd];
8010605e:	8b 5c 9f 28          	mov    0x28(%edi,%ebx,4),%ebx
80106062:	89 5d c8             	mov    %ebx,-0x38(%ebp)
            if (f) {
80106065:	85 db                	test   %ebx,%ebx
80106067:	0f 84 fa fe ff ff    	je     80105f67 <sys_wunmap+0x87>
                for (uint va = region->start_addr; va < region->start_addr + region->length; va += PGSIZE) {
8010606d:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
80106070:	0f 83 76 ff ff ff    	jae    80105fec <sys_wunmap+0x10c>
80106076:	89 75 d4             	mov    %esi,-0x2c(%ebp)
80106079:	8b 5d d0             	mov    -0x30(%ebp),%ebx
8010607c:	8b 75 cc             	mov    -0x34(%ebp),%esi
8010607f:	eb 23                	jmp    801060a4 <sys_wunmap+0x1c4>
80106081:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80106088:	8d 14 b7             	lea    (%edi,%esi,4),%edx
8010608b:	81 c3 00 10 00 00    	add    $0x1000,%ebx
80106091:	8b 42 7c             	mov    0x7c(%edx),%eax
80106094:	8b 8a 80 00 00 00    	mov    0x80(%edx),%ecx
8010609a:	01 c1                	add    %eax,%ecx
8010609c:	39 d9                	cmp    %ebx,%ecx
8010609e:	0f 86 b9 00 00 00    	jbe    8010615d <sys_wunmap+0x27d>
                    pte_t *pte = walkpgdir(curproc->pgdir, (void *)va, 0);
801060a4:	83 ec 04             	sub    $0x4,%esp
801060a7:	6a 00                	push   $0x0
801060a9:	53                   	push   %ebx
801060aa:	ff 77 04             	push   0x4(%edi)
801060ad:	e8 8e 16 00 00       	call   80107740 <walkpgdir>
                    if (pte && (*pte & PTE_P)) {
801060b2:	83 c4 10             	add    $0x10,%esp
801060b5:	85 c0                	test   %eax,%eax
801060b7:	74 cf                	je     80106088 <sys_wunmap+0x1a8>
801060b9:	8b 00                	mov    (%eax),%eax
                        uint file_offset = va - region->start_addr;
801060bb:	8b 54 b7 7c          	mov    0x7c(%edi,%esi,4),%edx
                    if (pte && (*pte & PTE_P)) {
801060bf:	a8 01                	test   $0x1,%al
801060c1:	74 c5                	je     80106088 <sys_wunmap+0x1a8>
                        uint file_offset = va - region->start_addr;
801060c3:	89 d9                	mov    %ebx,%ecx
                        uint pa = PTE_ADDR(*pte);
801060c5:	25 00 f0 ff ff       	and    $0xfffff000,%eax
                        if (filewrite(f, page_addr, PGSIZE) != PGSIZE) {
801060ca:	83 ec 04             	sub    $0x4,%esp
                        uint file_offset = va - region->start_addr;
801060cd:	29 d1                	sub    %edx,%ecx
801060cf:	8b 55 c8             	mov    -0x38(%ebp),%edx
                        char *page_addr = (char *)P2V(pa);
801060d2:	05 00 00 00 80       	add    $0x80000000,%eax
                        uint file_offset = va - region->start_addr;
801060d7:	89 4a 14             	mov    %ecx,0x14(%edx)
                        if (filewrite(f, page_addr, PGSIZE) != PGSIZE) {
801060da:	68 00 10 00 00       	push   $0x1000
801060df:	50                   	push   %eax
801060e0:	52                   	push   %edx
801060e1:	e8 da af ff ff       	call   801010c0 <filewrite>
801060e6:	83 c4 10             	add    $0x10,%esp
801060e9:	3d 00 10 00 00       	cmp    $0x1000,%eax
801060ee:	74 98                	je     80106088 <sys_wunmap+0x1a8>
                            cprintf("wunmap: Failed to write back page at va=0x%x\n", va);
801060f0:	83 ec 08             	sub    $0x8,%esp
801060f3:	53                   	push   %ebx
801060f4:	68 cc 88 10 80       	push   $0x801088cc
801060f9:	e8 a2 a5 ff ff       	call   801006a0 <cprintf>
                            return FAILED;
801060fe:	83 c4 10             	add    $0x10,%esp
}
80106101:	8d 65 f4             	lea    -0xc(%ebp),%esp
                            return FAILED;
80106104:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80106109:	5b                   	pop    %ebx
8010610a:	5e                   	pop    %esi
8010610b:	5f                   	pop    %edi
8010610c:	5d                   	pop    %ebp
8010610d:	c3                   	ret    
8010610e:	66 90                	xchg   %ax,%ax
            for (uint va = region->start_addr; va < region->start_addr + region->length; va += PGSIZE) {
80106110:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
80106113:	0f 83 d3 fe ff ff    	jae    80105fec <sys_wunmap+0x10c>
80106119:	89 75 d4             	mov    %esi,-0x2c(%ebp)
8010611c:	8b 5d c8             	mov    -0x38(%ebp),%ebx
8010611f:	8b 75 d0             	mov    -0x30(%ebp),%esi
80106122:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
                pte_t *pte = walkpgdir(curproc->pgdir, (void *)va, 0);
80106128:	83 ec 04             	sub    $0x4,%esp
8010612b:	6a 00                	push   $0x0
8010612d:	56                   	push   %esi
8010612e:	ff 77 04             	push   0x4(%edi)
80106131:	e8 0a 16 00 00       	call   80107740 <walkpgdir>
                if (pte && (*pte & PTE_P)) {
80106136:	83 c4 10             	add    $0x10,%esp
80106139:	85 c0                	test   %eax,%eax
8010613b:	74 0b                	je     80106148 <sys_wunmap+0x268>
8010613d:	f6 00 01             	testb  $0x1,(%eax)
80106140:	74 06                	je     80106148 <sys_wunmap+0x268>
                    *pte = 0;  // Clear the page table entry
80106142:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
            for (uint va = region->start_addr; va < region->start_addr + region->length; va += PGSIZE) {
80106148:	8b 43 7c             	mov    0x7c(%ebx),%eax
8010614b:	8b 8b 80 00 00 00    	mov    0x80(%ebx),%ecx
80106151:	81 c6 00 10 00 00    	add    $0x1000,%esi
80106157:	01 c1                	add    %eax,%ecx
80106159:	39 f1                	cmp    %esi,%ecx
8010615b:	77 cb                	ja     80106128 <sys_wunmap+0x248>
8010615d:	8b 75 d4             	mov    -0x2c(%ebp),%esi
80106160:	89 45 d0             	mov    %eax,-0x30(%ebp)
80106163:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
80106166:	e9 fc fd ff ff       	jmp    80105f67 <sys_wunmap+0x87>
8010616b:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
8010616f:	90                   	nop

80106170 <sys_va2pa>:

uint
sys_va2pa(void) {
80106170:	55                   	push   %ebp
80106171:	89 e5                	mov    %esp,%ebp
80106173:	83 ec 20             	sub    $0x20,%esp
    uint va;
    if (argint(0, (int*)&va) < 0) {
80106176:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106179:	50                   	push   %eax
8010617a:	6a 00                	push   $0x0
8010617c:	e8 9f ed ff ff       	call   80104f20 <argint>
80106181:	83 c4 10             	add    $0x10,%esp
80106184:	85 c0                	test   %eax,%eax
80106186:	78 23                	js     801061ab <sys_va2pa+0x3b>
        return -1;
    }

    struct proc *curproc = myproc();
80106188:	e8 63 d8 ff ff       	call   801039f0 <myproc>
    pte_t *pte = walkpgdir(curproc->pgdir, (void*)va, 0);
8010618d:	83 ec 04             	sub    $0x4,%esp
80106190:	6a 00                	push   $0x0
80106192:	ff 75 f4             	push   -0xc(%ebp)
80106195:	ff 70 04             	push   0x4(%eax)
80106198:	e8 a3 15 00 00       	call   80107740 <walkpgdir>
    
    // Check if the page table entry exists and is present
    if (pte && (*pte & PTE_P)) {
8010619d:	83 c4 10             	add    $0x10,%esp
801061a0:	85 c0                	test   %eax,%eax
801061a2:	74 07                	je     801061ab <sys_va2pa+0x3b>
801061a4:	8b 10                	mov    (%eax),%edx
801061a6:	f6 c2 01             	test   $0x1,%dl
801061a9:	75 0d                	jne    801061b8 <sys_va2pa+0x48>
        return pa + offset;        // Return the full physical address
    }

    // If the virtual address does not map to a physical address, return -1
    return FAILED;
}
801061ab:	c9                   	leave  
        return -1;
801061ac:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801061b1:	c3                   	ret    
801061b2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
        uint offset = va % PGSIZE; // Calculate the offset within the page
801061b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
        uint pa = PTE_ADDR(*pte);  // Get the page frame number (base physical address)
801061bb:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
}
801061c1:	c9                   	leave  
        uint offset = va % PGSIZE; // Calculate the offset within the page
801061c2:	25 ff 0f 00 00       	and    $0xfff,%eax
        return pa + offset;        // Return the full physical address
801061c7:	09 d0                	or     %edx,%eax
}
801061c9:	c3                   	ret    
801061ca:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

801061d0 <sys_getwmapinfo>:

int 
sys_getwmapinfo(void) {
801061d0:	55                   	push   %ebp
801061d1:	89 e5                	mov    %esp,%ebp
801061d3:	57                   	push   %edi
801061d4:	56                   	push   %esi
    struct wmapinfo *wminfo;

    // Retrieve the user-provided pointer for wmapinfo structure
    if (argptr(0, (void*)&wminfo, sizeof(*wminfo)) < 0)
801061d5:	8d 45 e4             	lea    -0x1c(%ebp),%eax
sys_getwmapinfo(void) {
801061d8:	53                   	push   %ebx
801061d9:	83 ec 30             	sub    $0x30,%esp
    if (argptr(0, (void*)&wminfo, sizeof(*wminfo)) < 0)
801061dc:	68 c4 00 00 00       	push   $0xc4
801061e1:	50                   	push   %eax
801061e2:	6a 00                	push   $0x0
801061e4:	e8 87 ed ff ff       	call   80104f70 <argptr>
801061e9:	83 c4 10             	add    $0x10,%esp
801061ec:	85 c0                	test   %eax,%eax
801061ee:	0f 88 ba 00 00 00    	js     801062ae <sys_getwmapinfo+0xde>
        return FAILED;

    struct proc *curproc = myproc();
801061f4:	e8 f7 d7 ff ff       	call   801039f0 <myproc>
    int num_mmaps = curproc->num_mmap_regions;
801061f9:	8b 90 bc 01 00 00    	mov    0x1bc(%eax),%edx
    struct proc *curproc = myproc();
801061ff:	89 45 d4             	mov    %eax,-0x2c(%ebp)

    // Populate the wmapinfo structure with mappings information
    wminfo->total_mmaps = num_mmaps;
80106202:	8b 45 e4             	mov    -0x1c(%ebp),%eax
    int num_mmaps = curproc->num_mmap_regions;
80106205:	89 55 cc             	mov    %edx,-0x34(%ebp)
    wminfo->total_mmaps = num_mmaps;
80106208:	89 10                	mov    %edx,(%eax)

    for (int i = 0; i < num_mmaps && i < MAX_WMMAP_INFO; i++) {
8010620a:	85 d2                	test   %edx,%edx
8010620c:	0f 8e 92 00 00 00    	jle    801062a4 <sys_getwmapinfo+0xd4>
80106212:	8b 55 d4             	mov    -0x2c(%ebp),%edx
        struct mmap_region *region = &curproc->mmap_regions[i];
        wminfo->addr[i] = region->start_addr;
80106215:	8b 45 e4             	mov    -0x1c(%ebp),%eax
    for (int i = 0; i < num_mmaps && i < MAX_WMMAP_INFO; i++) {
80106218:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
8010621f:	8d 7a 7c             	lea    0x7c(%edx),%edi
80106222:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
        wminfo->addr[i] = region->start_addr;
80106228:	8b 17                	mov    (%edi),%edx
8010622a:	8b 4d d0             	mov    -0x30(%ebp),%ecx
8010622d:	89 54 88 04          	mov    %edx,0x4(%eax,%ecx,4)
        wminfo->length[i] = region->length;
80106231:	8b 5f 04             	mov    0x4(%edi),%ebx
80106234:	89 5c 88 44          	mov    %ebx,0x44(%eax,%ecx,4)

        // Calculate the number of loaded (physically allocated) pages in this mapping
        int loaded_pages = 0;
        for (uint va = region->start_addr; va < region->start_addr + region->length; va += PGSIZE) {
80106238:	8b 37                	mov    (%edi),%esi
8010623a:	01 f3                	add    %esi,%ebx
8010623c:	39 de                	cmp    %ebx,%esi
        int loaded_pages = 0;
8010623e:	bb 00 00 00 00       	mov    $0x0,%ebx
        for (uint va = region->start_addr; va < region->start_addr + region->length; va += PGSIZE) {
80106243:	73 42                	jae    80106287 <sys_getwmapinfo+0xb7>
        int loaded_pages = 0;
80106245:	89 f0                	mov    %esi,%eax
80106247:	89 fe                	mov    %edi,%esi
80106249:	89 c7                	mov    %eax,%edi
8010624b:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
8010624f:	90                   	nop
            pte_t *pte = walkpgdir(curproc->pgdir, (void*)va, 0);
80106250:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80106253:	83 ec 04             	sub    $0x4,%esp
80106256:	6a 00                	push   $0x0
80106258:	57                   	push   %edi
80106259:	ff 70 04             	push   0x4(%eax)
8010625c:	e8 df 14 00 00       	call   80107740 <walkpgdir>
            if (pte && (*pte & PTE_P)) {  // Check if page is present
80106261:	83 c4 10             	add    $0x10,%esp
80106264:	85 c0                	test   %eax,%eax
80106266:	74 0b                	je     80106273 <sys_getwmapinfo+0xa3>
80106268:	8b 00                	mov    (%eax),%eax
8010626a:	83 e0 01             	and    $0x1,%eax
                loaded_pages++;
8010626d:	83 f8 01             	cmp    $0x1,%eax
80106270:	83 db ff             	sbb    $0xffffffff,%ebx
        for (uint va = region->start_addr; va < region->start_addr + region->length; va += PGSIZE) {
80106273:	8b 46 04             	mov    0x4(%esi),%eax
80106276:	81 c7 00 10 00 00    	add    $0x1000,%edi
8010627c:	03 06                	add    (%esi),%eax
8010627e:	39 f8                	cmp    %edi,%eax
80106280:	77 ce                	ja     80106250 <sys_getwmapinfo+0x80>
            }
        }
        wminfo->n_loaded_pages[i] = loaded_pages;
80106282:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106285:	89 f7                	mov    %esi,%edi
80106287:	8b 4d d0             	mov    -0x30(%ebp),%ecx
    for (int i = 0; i < num_mmaps && i < MAX_WMMAP_INFO; i++) {
8010628a:	83 c7 14             	add    $0x14,%edi
        wminfo->n_loaded_pages[i] = loaded_pages;
8010628d:	89 9c 88 84 00 00 00 	mov    %ebx,0x84(%eax,%ecx,4)
    for (int i = 0; i < num_mmaps && i < MAX_WMMAP_INFO; i++) {
80106294:	83 c1 01             	add    $0x1,%ecx
80106297:	89 4d d0             	mov    %ecx,-0x30(%ebp)
8010629a:	39 4d cc             	cmp    %ecx,-0x34(%ebp)
8010629d:	7e 05                	jle    801062a4 <sys_getwmapinfo+0xd4>
8010629f:	83 f9 0f             	cmp    $0xf,%ecx
801062a2:	7e 84                	jle    80106228 <sys_getwmapinfo+0x58>
    }

    return SUCCESS;
801062a4:	31 c0                	xor    %eax,%eax
801062a6:	8d 65 f4             	lea    -0xc(%ebp),%esp
801062a9:	5b                   	pop    %ebx
801062aa:	5e                   	pop    %esi
801062ab:	5f                   	pop    %edi
801062ac:	5d                   	pop    %ebp
801062ad:	c3                   	ret    
        return FAILED;
801062ae:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801062b3:	eb f1                	jmp    801062a6 <sys_getwmapinfo+0xd6>

801062b5 <alltraps>:

  # vectors.S sends all traps here.
.globl alltraps
alltraps:
  # Build trap frame.
  pushl %ds
801062b5:	1e                   	push   %ds
  pushl %es
801062b6:	06                   	push   %es
  pushl %fs
801062b7:	0f a0                	push   %fs
  pushl %gs
801062b9:	0f a8                	push   %gs
  pushal
801062bb:	60                   	pusha  
  
  # Set up data segments.
  movw $(SEG_KDATA<<3), %ax
801062bc:	66 b8 10 00          	mov    $0x10,%ax
  movw %ax, %ds
801062c0:	8e d8                	mov    %eax,%ds
  movw %ax, %es
801062c2:	8e c0                	mov    %eax,%es

  # Call trap(tf), where tf=%esp
  pushl %esp
801062c4:	54                   	push   %esp
  call trap
801062c5:	e8 c6 00 00 00       	call   80106390 <trap>
  addl $4, %esp
801062ca:	83 c4 04             	add    $0x4,%esp

801062cd <trapret>:

  # Return falls through to trapret...
.globl trapret
trapret:
  popal
801062cd:	61                   	popa   
  popl %gs
801062ce:	0f a9                	pop    %gs
  popl %fs
801062d0:	0f a1                	pop    %fs
  popl %es
801062d2:	07                   	pop    %es
  popl %ds
801062d3:	1f                   	pop    %ds
  addl $0x8, %esp  # trapno and errcode
801062d4:	83 c4 08             	add    $0x8,%esp
  iret
801062d7:	cf                   	iret   
801062d8:	66 90                	xchg   %ax,%ax
801062da:	66 90                	xchg   %ax,%ax
801062dc:	66 90                	xchg   %ax,%ax
801062de:	66 90                	xchg   %ax,%ax

801062e0 <tvinit>:
struct spinlock tickslock;
uint ticks;

void
tvinit(void)
{
801062e0:	55                   	push   %ebp
  int i;

  for(i = 0; i < 256; i++)
801062e1:	31 c0                	xor    %eax,%eax
{
801062e3:	89 e5                	mov    %esp,%ebp
801062e5:	83 ec 08             	sub    $0x8,%esp
801062e8:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801062ef:	90                   	nop
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
801062f0:	8b 14 85 08 b0 10 80 	mov    -0x7fef4ff8(,%eax,4),%edx
801062f7:	c7 04 c5 02 9e 21 80 	movl   $0x8e000008,-0x7fde61fe(,%eax,8)
801062fe:	08 00 00 8e 
80106302:	66 89 14 c5 00 9e 21 	mov    %dx,-0x7fde6200(,%eax,8)
80106309:	80 
8010630a:	c1 ea 10             	shr    $0x10,%edx
8010630d:	66 89 14 c5 06 9e 21 	mov    %dx,-0x7fde61fa(,%eax,8)
80106314:	80 
  for(i = 0; i < 256; i++)
80106315:	83 c0 01             	add    $0x1,%eax
80106318:	3d 00 01 00 00       	cmp    $0x100,%eax
8010631d:	75 d1                	jne    801062f0 <tvinit+0x10>
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);

  initlock(&tickslock, "time");
8010631f:	83 ec 08             	sub    $0x8,%esp
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
80106322:	a1 08 b1 10 80       	mov    0x8010b108,%eax
80106327:	c7 05 02 a0 21 80 08 	movl   $0xef000008,0x8021a002
8010632e:	00 00 ef 
  initlock(&tickslock, "time");
80106331:	68 fa 88 10 80       	push   $0x801088fa
80106336:	68 c0 9d 21 80       	push   $0x80219dc0
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
8010633b:	66 a3 00 a0 21 80    	mov    %ax,0x8021a000
80106341:	c1 e8 10             	shr    $0x10,%eax
80106344:	66 a3 06 a0 21 80    	mov    %ax,0x8021a006
  initlock(&tickslock, "time");
8010634a:	e8 81 e6 ff ff       	call   801049d0 <initlock>
}
8010634f:	83 c4 10             	add    $0x10,%esp
80106352:	c9                   	leave  
80106353:	c3                   	ret    
80106354:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010635b:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
8010635f:	90                   	nop

80106360 <idtinit>:

void
idtinit(void)
{
80106360:	55                   	push   %ebp
  pd[0] = size-1;
80106361:	b8 ff 07 00 00       	mov    $0x7ff,%eax
80106366:	89 e5                	mov    %esp,%ebp
80106368:	83 ec 10             	sub    $0x10,%esp
8010636b:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
8010636f:	b8 00 9e 21 80       	mov    $0x80219e00,%eax
80106374:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
80106378:	c1 e8 10             	shr    $0x10,%eax
8010637b:	66 89 45 fe          	mov    %ax,-0x2(%ebp)
  asm volatile("lidt (%0)" : : "r" (pd));
8010637f:	8d 45 fa             	lea    -0x6(%ebp),%eax
80106382:	0f 01 18             	lidtl  (%eax)
  lidt(idt, sizeof(idt));
}
80106385:	c9                   	leave  
80106386:	c3                   	ret    
80106387:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010638e:	66 90                	xchg   %ax,%ax

80106390 <trap>:

//PAGEBREAK: 41
void trap(struct trapframe *tf) {
80106390:	55                   	push   %ebp
80106391:	89 e5                	mov    %esp,%ebp
80106393:	57                   	push   %edi
80106394:	56                   	push   %esi
80106395:	53                   	push   %ebx
80106396:	83 ec 1c             	sub    $0x1c,%esp
80106399:	8b 5d 08             	mov    0x8(%ebp),%ebx
    struct proc *curproc = myproc();
8010639c:	e8 4f d6 ff ff       	call   801039f0 <myproc>
801063a1:	89 c7                	mov    %eax,%edi

    if(tf->trapno == T_SYSCALL){
801063a3:	8b 43 30             	mov    0x30(%ebx),%eax
801063a6:	83 f8 40             	cmp    $0x40,%eax
801063a9:	0f 84 d1 00 00 00    	je     80106480 <trap+0xf0>
        if(curproc->killed)
            exit();
        return;
    }

    switch(tf->trapno){
801063af:	83 e8 0e             	sub    $0xe,%eax
801063b2:	83 f8 31             	cmp    $0x31,%eax
801063b5:	77 39                	ja     801063f0 <trap+0x60>
801063b7:	ff 24 85 7c 8b 10 80 	jmp    *-0x7fef7484(,%eax,4)
801063be:	66 90                	xchg   %ax,%ax
        kbdintr();
        lapiceoi();
        break;

    case T_IRQ0 + IRQ_COM1:
        uartintr();
801063c0:	e8 ab 07 00 00       	call   80106b70 <uartintr>
        lapiceoi();
801063c5:	e8 b6 c5 ff ff       	call   80102980 <lapiceoi>
                tf->err, cpuid(), tf->eip, rcr2());
        curproc->killed = 1;
    }

    // Force process exit if it has been killed and is in user space.
    if(curproc && curproc->killed && (tf->cs&3) == DPL_USER)
801063ca:	85 ff                	test   %edi,%edi
801063cc:	74 11                	je     801063df <trap+0x4f>
801063ce:	8b 4f 24             	mov    0x24(%edi),%ecx
801063d1:	85 c9                	test   %ecx,%ecx
801063d3:	75 62                	jne    80106437 <trap+0xa7>
        exit();

    // Force process to give up CPU on clock tick.
    if(curproc && curproc->state == RUNNING && tf->trapno == T_IRQ0+IRQ_TIMER)
801063d5:	83 7f 0c 04          	cmpl   $0x4,0xc(%edi)
801063d9:	0f 84 01 01 00 00    	je     801064e0 <trap+0x150>
        yield();

    // Check if the process has been killed since we yielded
    if(curproc && curproc->killed && (tf->cs&3) == DPL_USER)
        exit();
801063df:	8d 65 f4             	lea    -0xc(%ebp),%esp
801063e2:	5b                   	pop    %ebx
801063e3:	5e                   	pop    %esi
801063e4:	5f                   	pop    %edi
801063e5:	5d                   	pop    %ebp
801063e6:	c3                   	ret    
801063e7:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801063ee:	66 90                	xchg   %ax,%ax
        cprintf("cpu%d: spurious interrupt at %x:%x\n",
801063f0:	8b 73 38             	mov    0x38(%ebx),%esi
        if(curproc == 0 || (tf->cs&3) == 0){
801063f3:	85 ff                	test   %edi,%edi
801063f5:	0f 84 d6 05 00 00    	je     801069d1 <trap+0x641>
801063fb:	f6 43 3c 03          	testb  $0x3,0x3c(%ebx)
801063ff:	0f 84 cc 05 00 00    	je     801069d1 <trap+0x641>
  asm volatile("movl %%cr2,%0" : "=r" (val));
80106405:	0f 20 d2             	mov    %cr2,%edx
80106408:	89 55 e4             	mov    %edx,-0x1c(%ebp)
        cprintf("pid %d %s: trap %d err %d on cpu %d "
8010640b:	e8 c0 d5 ff ff       	call   801039d0 <cpuid>
80106410:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80106413:	52                   	push   %edx
80106414:	56                   	push   %esi
80106415:	50                   	push   %eax
                curproc->pid, curproc->name, tf->trapno,
80106416:	8d 47 6c             	lea    0x6c(%edi),%eax
        cprintf("pid %d %s: trap %d err %d on cpu %d "
80106419:	ff 73 34             	push   0x34(%ebx)
8010641c:	ff 73 30             	push   0x30(%ebx)
8010641f:	50                   	push   %eax
80106420:	ff 77 10             	push   0x10(%edi)
80106423:	68 10 8b 10 80       	push   $0x80108b10
80106428:	e8 73 a2 ff ff       	call   801006a0 <cprintf>
        curproc->killed = 1;
8010642d:	c7 47 24 01 00 00 00 	movl   $0x1,0x24(%edi)
80106434:	83 c4 20             	add    $0x20,%esp
    if(curproc && curproc->killed && (tf->cs&3) == DPL_USER)
80106437:	0f b7 43 3c          	movzwl 0x3c(%ebx),%eax
8010643b:	83 e0 03             	and    $0x3,%eax
8010643e:	66 83 f8 03          	cmp    $0x3,%ax
80106442:	75 91                	jne    801063d5 <trap+0x45>
        exit();
80106444:	e8 77 db ff ff       	call   80103fc0 <exit>
    if(curproc && curproc->state == RUNNING && tf->trapno == T_IRQ0+IRQ_TIMER)
80106449:	83 7f 0c 04          	cmpl   $0x4,0xc(%edi)
8010644d:	0f 84 8d 00 00 00    	je     801064e0 <trap+0x150>
80106453:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80106457:	90                   	nop
    if(curproc && curproc->killed && (tf->cs&3) == DPL_USER)
80106458:	8b 57 24             	mov    0x24(%edi),%edx
8010645b:	85 d2                	test   %edx,%edx
8010645d:	74 80                	je     801063df <trap+0x4f>
8010645f:	0f b7 43 3c          	movzwl 0x3c(%ebx),%eax
80106463:	83 e0 03             	and    $0x3,%eax
80106466:	66 83 f8 03          	cmp    $0x3,%ax
8010646a:	0f 85 6f ff ff ff    	jne    801063df <trap+0x4f>
80106470:	8d 65 f4             	lea    -0xc(%ebp),%esp
80106473:	5b                   	pop    %ebx
80106474:	5e                   	pop    %esi
80106475:	5f                   	pop    %edi
80106476:	5d                   	pop    %ebp
            exit();
80106477:	e9 44 db ff ff       	jmp    80103fc0 <exit>
8010647c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
        if(curproc->killed)
80106480:	8b 47 24             	mov    0x24(%edi),%eax
80106483:	85 c0                	test   %eax,%eax
80106485:	75 19                	jne    801064a0 <trap+0x110>
        curproc->tf = tf;
80106487:	89 5f 18             	mov    %ebx,0x18(%edi)
        syscall();
8010648a:	e8 d1 eb ff ff       	call   80105060 <syscall>
        if(curproc->killed)
8010648f:	8b 47 24             	mov    0x24(%edi),%eax
80106492:	85 c0                	test   %eax,%eax
80106494:	75 da                	jne    80106470 <trap+0xe0>
80106496:	8d 65 f4             	lea    -0xc(%ebp),%esp
80106499:	5b                   	pop    %ebx
8010649a:	5e                   	pop    %esi
8010649b:	5f                   	pop    %edi
8010649c:	5d                   	pop    %ebp
8010649d:	c3                   	ret    
8010649e:	66 90                	xchg   %ax,%ax
            exit();
801064a0:	e8 1b db ff ff       	call   80103fc0 <exit>
801064a5:	eb e0                	jmp    80106487 <trap+0xf7>
801064a7:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801064ae:	66 90                	xchg   %ax,%ax
        cprintf("cpu%d: spurious interrupt at %x:%x\n",
801064b0:	8b 53 38             	mov    0x38(%ebx),%edx
801064b3:	0f b7 73 3c          	movzwl 0x3c(%ebx),%esi
801064b7:	89 55 e4             	mov    %edx,-0x1c(%ebp)
801064ba:	e8 11 d5 ff ff       	call   801039d0 <cpuid>
801064bf:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801064c2:	52                   	push   %edx
801064c3:	56                   	push   %esi
801064c4:	50                   	push   %eax
801064c5:	68 64 89 10 80       	push   $0x80108964
801064ca:	e8 d1 a1 ff ff       	call   801006a0 <cprintf>
        lapiceoi();
801064cf:	e8 ac c4 ff ff       	call   80102980 <lapiceoi>
        break;
801064d4:	83 c4 10             	add    $0x10,%esp
801064d7:	e9 ee fe ff ff       	jmp    801063ca <trap+0x3a>
801064dc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    if(curproc && curproc->state == RUNNING && tf->trapno == T_IRQ0+IRQ_TIMER)
801064e0:	83 7b 30 20          	cmpl   $0x20,0x30(%ebx)
801064e4:	0f 85 6e ff ff ff    	jne    80106458 <trap+0xc8>
        yield();
801064ea:	e8 91 df ff ff       	call   80104480 <yield>
801064ef:	e9 64 ff ff ff       	jmp    80106458 <trap+0xc8>
801064f4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
        ideintr();
801064f8:	e8 53 bd ff ff       	call   80102250 <ideintr>
        lapiceoi();
801064fd:	e8 7e c4 ff ff       	call   80102980 <lapiceoi>
        break;
80106502:	e9 c3 fe ff ff       	jmp    801063ca <trap+0x3a>
80106507:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010650e:	66 90                	xchg   %ax,%ax
        kbdintr();
80106510:	e8 2b c3 ff ff       	call   80102840 <kbdintr>
        lapiceoi();
80106515:	e8 66 c4 ff ff       	call   80102980 <lapiceoi>
        break;
8010651a:	e9 ab fe ff ff       	jmp    801063ca <trap+0x3a>
8010651f:	90                   	nop
        if(cpuid() == 0){
80106520:	e8 ab d4 ff ff       	call   801039d0 <cpuid>
80106525:	85 c0                	test   %eax,%eax
80106527:	0f 85 98 fe ff ff    	jne    801063c5 <trap+0x35>
            acquire(&tickslock);
8010652d:	83 ec 0c             	sub    $0xc,%esp
80106530:	68 c0 9d 21 80       	push   $0x80219dc0
80106535:	e8 66 e6 ff ff       	call   80104ba0 <acquire>
            wakeup(&ticks);
8010653a:	c7 04 24 a0 9d 21 80 	movl   $0x80219da0,(%esp)
            ticks++;
80106541:	83 05 a0 9d 21 80 01 	addl   $0x1,0x80219da0
            wakeup(&ticks);
80106548:	e8 43 e0 ff ff       	call   80104590 <wakeup>
            release(&tickslock);
8010654d:	c7 04 24 c0 9d 21 80 	movl   $0x80219dc0,(%esp)
80106554:	e8 e7 e5 ff ff       	call   80104b40 <release>
80106559:	83 c4 10             	add    $0x10,%esp
        lapiceoi();
8010655c:	e9 64 fe ff ff       	jmp    801063c5 <trap+0x35>
80106561:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80106568:	0f 20 d0             	mov    %cr2,%eax
    cprintf("Page fault at va=0x%x\n", fault_addr);
8010656b:	83 ec 08             	sub    $0x8,%esp
8010656e:	89 c6                	mov    %eax,%esi
80106570:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80106573:	50                   	push   %eax
80106574:	68 ff 88 10 80       	push   $0x801088ff
80106579:	e8 22 a1 ff ff       	call   801006a0 <cprintf>
    if (fault_addr < 0x60000000) { // Apply COW logic
8010657e:	83 c4 10             	add    $0x10,%esp
80106581:	81 fe ff ff ff 5f    	cmp    $0x5fffffff,%esi
80106587:	0f 86 83 01 00 00    	jbe    80106710 <trap+0x380>
    for (int i = 0; i < curproc->num_mmap_regions; i++) {
8010658d:	8b 97 bc 01 00 00    	mov    0x1bc(%edi),%edx
80106593:	8d 47 7c             	lea    0x7c(%edi),%eax
80106596:	31 f6                	xor    %esi,%esi
80106598:	85 d2                	test   %edx,%edx
8010659a:	0f 8e 5e 02 00 00    	jle    801067fe <trap+0x46e>
801065a0:	89 7d e0             	mov    %edi,-0x20(%ebp)
801065a3:	89 d7                	mov    %edx,%edi
801065a5:	89 5d dc             	mov    %ebx,-0x24(%ebp)
801065a8:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
801065ab:	eb 11                	jmp    801065be <trap+0x22e>
801065ad:	8d 76 00             	lea    0x0(%esi),%esi
801065b0:	83 c6 01             	add    $0x1,%esi
801065b3:	83 c0 14             	add    $0x14,%eax
801065b6:	39 f7                	cmp    %esi,%edi
801065b8:	0f 84 3a 02 00 00    	je     801067f8 <trap+0x468>
        uint start = curproc->mmap_regions[i].start_addr;
801065be:	8b 10                	mov    (%eax),%edx
        uint end = start + curproc->mmap_regions[i].length;
801065c0:	8b 48 04             	mov    0x4(%eax),%ecx
801065c3:	01 d1                	add    %edx,%ecx
        if (fault_addr >= start && fault_addr < end) {
801065c5:	39 d9                	cmp    %ebx,%ecx
801065c7:	76 e7                	jbe    801065b0 <trap+0x220>
801065c9:	39 da                	cmp    %ebx,%edx
801065cb:	77 e3                	ja     801065b0 <trap+0x220>
        char *mem = kalloc();
801065cd:	8b 7d e0             	mov    -0x20(%ebp),%edi
801065d0:	e8 1b c1 ff ff       	call   801026f0 <kalloc>
801065d5:	89 c3                	mov    %eax,%ebx
        if (!mem) {
801065d7:	85 c0                	test   %eax,%eax
801065d9:	0f 84 c4 02 00 00    	je     801068a3 <trap+0x513>
    uint page_addr = PGROUNDDOWN(fault_addr); // Align to page boundary
801065df:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801065e2:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801065e7:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        if (!(region->flags & MAP_ANONYMOUS) && region->fd >= 0) {
801065ea:	8d 04 b6             	lea    (%esi,%esi,4),%eax
801065ed:	8d 04 87             	lea    (%edi,%eax,4),%eax
801065f0:	f6 80 84 00 00 00 04 	testb  $0x4,0x84(%eax)
801065f7:	0f 85 23 02 00 00    	jne    80106820 <trap+0x490>
801065fd:	8b 90 88 00 00 00    	mov    0x88(%eax),%edx
80106603:	85 d2                	test   %edx,%edx
80106605:	0f 88 15 02 00 00    	js     80106820 <trap+0x490>
            struct file *f = curproc->ofile[region->fd];
8010660b:	8b 4c 97 28          	mov    0x28(%edi,%edx,4),%ecx
8010660f:	89 4d e0             	mov    %ecx,-0x20(%ebp)
            if (!f) {
80106612:	85 c9                	test   %ecx,%ecx
80106614:	0f 84 87 03 00 00    	je     801069a1 <trap+0x611>
            if (!f->ip) {
8010661a:	8b 4d e0             	mov    -0x20(%ebp),%ecx
8010661d:	8b 49 10             	mov    0x10(%ecx),%ecx
80106620:	85 c9                	test   %ecx,%ecx
80106622:	0f 84 9e 03 00 00    	je     801069c6 <trap+0x636>
            int file_offset = page_addr - region->start_addr;
80106628:	8b 50 7c             	mov    0x7c(%eax),%edx
8010662b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010662e:	29 d0                	sub    %edx,%eax
80106630:	89 45 dc             	mov    %eax,-0x24(%ebp)
            if (file_offset >= f->ip->size) {
80106633:	8b 41 58             	mov    0x58(%ecx),%eax
80106636:	39 45 dc             	cmp    %eax,-0x24(%ebp)
80106639:	0f 83 e1 01 00 00    	jae    80106820 <trap+0x490>
                if (file_offset + PGSIZE > f->ip->size) {
8010663f:	8b 4d dc             	mov    -0x24(%ebp),%ecx
80106642:	81 c1 00 10 00 00    	add    $0x1000,%ecx
80106648:	39 c8                	cmp    %ecx,%eax
8010664a:	0f 83 a3 02 00 00    	jae    801068f3 <trap+0x563>
                memset(mem, 0, PGSIZE);  // Clear the page first
80106650:	83 ec 04             	sub    $0x4,%esp
                    bytes_to_read = f->ip->size - file_offset;
80106653:	2b 55 e4             	sub    -0x1c(%ebp),%edx
                memset(mem, 0, PGSIZE);  // Clear the page first
80106656:	68 00 10 00 00       	push   $0x1000
                    bytes_to_read = f->ip->size - file_offset;
8010665b:	01 d0                	add    %edx,%eax
                memset(mem, 0, PGSIZE);  // Clear the page first
8010665d:	6a 00                	push   $0x0
8010665f:	53                   	push   %ebx
                    bytes_to_read = f->ip->size - file_offset;
80106660:	89 45 d8             	mov    %eax,-0x28(%ebp)
                memset(mem, 0, PGSIZE);  // Clear the page first
80106663:	e8 f8 e5 ff ff       	call   80104c60 <memset>
                ilock(f->ip);
80106668:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010666b:	58                   	pop    %eax
8010666c:	ff 72 10             	push   0x10(%edx)
8010666f:	e8 1c b1 ff ff       	call   80101790 <ilock>
                if (readi(f->ip, mem, file_offset, bytes_to_read) != bytes_to_read) {
80106674:	8b 4d e0             	mov    -0x20(%ebp),%ecx
80106677:	ff 75 d8             	push   -0x28(%ebp)
8010667a:	ff 75 dc             	push   -0x24(%ebp)
8010667d:	53                   	push   %ebx
8010667e:	ff 71 10             	push   0x10(%ecx)
80106681:	e8 1a b4 ff ff       	call   80101aa0 <readi>
80106686:	83 c4 20             	add    $0x20,%esp
80106689:	3b 45 d8             	cmp    -0x28(%ebp),%eax
8010668c:	0f 85 2d 02 00 00    	jne    801068bf <trap+0x52f>
                iunlock(f->ip);
80106692:	8b 45 e0             	mov    -0x20(%ebp),%eax
80106695:	83 ec 0c             	sub    $0xc,%esp
80106698:	ff 70 10             	push   0x10(%eax)
8010669b:	e8 d0 b1 ff ff       	call   80101870 <iunlock>
                if (bytes_to_read < PGSIZE) {
801066a0:	8b 55 d8             	mov    -0x28(%ebp),%edx
801066a3:	83 c4 10             	add    $0x10,%esp
801066a6:	81 fa ff 0f 00 00    	cmp    $0xfff,%edx
801066ac:	7f 22                	jg     801066d0 <trap+0x340>
                    memset(mem + bytes_to_read, 0, PGSIZE - bytes_to_read);
801066ae:	b8 00 10 00 00       	mov    $0x1000,%eax
801066b3:	83 ec 04             	sub    $0x4,%esp
801066b6:	29 d0                	sub    %edx,%eax
801066b8:	50                   	push   %eax
801066b9:	89 d0                	mov    %edx,%eax
801066bb:	01 d8                	add    %ebx,%eax
801066bd:	6a 00                	push   $0x0
801066bf:	50                   	push   %eax
801066c0:	e8 9b e5 ff ff       	call   80104c60 <memset>
801066c5:	83 c4 10             	add    $0x10,%esp
801066c8:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801066cf:	90                   	nop
        if (mappages(curproc->pgdir, (char *)page_addr, PGSIZE, V2P(mem), PTE_W | PTE_U) < 0) {
801066d0:	83 ec 0c             	sub    $0xc,%esp
801066d3:	8d 83 00 00 00 80    	lea    -0x80000000(%ebx),%eax
801066d9:	6a 06                	push   $0x6
801066db:	50                   	push   %eax
801066dc:	68 00 10 00 00       	push   $0x1000
801066e1:	ff 75 e4             	push   -0x1c(%ebp)
801066e4:	ff 77 04             	push   0x4(%edi)
801066e7:	e8 e4 10 00 00       	call   801077d0 <mappages>
801066ec:	83 c4 20             	add    $0x20,%esp
801066ef:	85 c0                	test   %eax,%eax
801066f1:	0f 88 69 01 00 00    	js     80106860 <trap+0x4d0>
        region->n_loaded_pages++;
801066f7:	8d 04 b6             	lea    (%esi,%esi,4),%eax
801066fa:	83 84 87 8c 00 00 00 	addl   $0x1,0x8c(%edi,%eax,4)
80106701:	01 
        return; // Resume execution after handling the page fault
80106702:	e9 d8 fc ff ff       	jmp    801063df <trap+0x4f>
80106707:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010670e:	66 90                	xchg   %ax,%ax
        pte_t *pte = walkpgdir(curproc->pgdir, (void *)fault_addr, 0);
80106710:	83 ec 04             	sub    $0x4,%esp
80106713:	6a 00                	push   $0x0
80106715:	ff 75 e4             	push   -0x1c(%ebp)
80106718:	ff 77 04             	push   0x4(%edi)
8010671b:	e8 20 10 00 00       	call   80107740 <walkpgdir>
        if (!(*pte & PTE_P) || !*pte) {
80106720:	83 c4 10             	add    $0x10,%esp
        pte_t *pte = walkpgdir(curproc->pgdir, (void *)fault_addr, 0);
80106723:	89 c6                	mov    %eax,%esi
        if (!(*pte & PTE_P) || !*pte) {
80106725:	8b 00                	mov    (%eax),%eax
80106727:	a8 01                	test   $0x1,%al
80106729:	0f 84 11 01 00 00    	je     80106840 <trap+0x4b0>
        uint pa = PTE_ADDR(*pte); // Get the physical address
8010672f:	89 c3                	mov    %eax,%ebx
        cprintf("PTE found: pa=0x%x, flags=0x%x\n", pa, *pte);
80106731:	83 ec 04             	sub    $0x4,%esp
        uint pa = PTE_ADDR(*pte); // Get the physical address
80106734:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
        cprintf("PTE found: pa=0x%x, flags=0x%x\n", pa, *pte);
8010673a:	50                   	push   %eax
8010673b:	53                   	push   %ebx
8010673c:	68 bc 89 10 80       	push   $0x801089bc
80106741:	e8 5a 9f ff ff       	call   801006a0 <cprintf>
        if (*pte & PTE_COW) { // Check if it's a COW page
80106746:	83 c4 10             	add    $0x10,%esp
80106749:	f7 06 00 04 00 00    	testl  $0x400,(%esi)
8010674f:	0f 84 2f 01 00 00    	je     80106884 <trap+0x4f4>
            if (get_ref(pa) == 1) { // Reference count == 1
80106755:	83 ec 0c             	sub    $0xc,%esp
80106758:	53                   	push   %ebx
80106759:	e8 b2 bd ff ff       	call   80102510 <get_ref>
8010675e:	83 c4 10             	add    $0x10,%esp
80106761:	83 f8 01             	cmp    $0x1,%eax
80106764:	0f 84 f5 01 00 00    	je     8010695f <trap+0x5cf>
                char *new_page = kalloc();
8010676a:	e8 81 bf ff ff       	call   801026f0 <kalloc>
                if (!new_page) {
8010676f:	85 c0                	test   %eax,%eax
80106771:	0f 84 cc 01 00 00    	je     80106943 <trap+0x5b3>
                memmove(new_page, (char *)P2V(pa), PGSIZE);
80106777:	83 ec 04             	sub    $0x4,%esp
8010677a:	8d 8b 00 00 00 80    	lea    -0x80000000(%ebx),%ecx
80106780:	89 45 e0             	mov    %eax,-0x20(%ebp)
80106783:	68 00 10 00 00       	push   $0x1000
80106788:	51                   	push   %ecx
80106789:	50                   	push   %eax
8010678a:	89 4d dc             	mov    %ecx,-0x24(%ebp)
8010678d:	e8 6e e5 ff ff       	call   80104d00 <memmove>
                *pte = V2P(new_page) | PTE_FLAGS(*pte);
80106792:	8b 55 e0             	mov    -0x20(%ebp),%edx
80106795:	8b 06                	mov    (%esi),%eax
80106797:	81 c2 00 00 00 80    	add    $0x80000000,%edx
8010679d:	25 ff 0f 00 00       	and    $0xfff,%eax
801067a2:	09 d0                	or     %edx,%eax
801067a4:	89 55 e0             	mov    %edx,-0x20(%ebp)
                *pte &= ~PTE_COW;   // Remove COW flag
801067a7:	80 e4 fb             	and    $0xfb,%ah
801067aa:	83 c8 02             	or     $0x2,%eax
801067ad:	89 06                	mov    %eax,(%esi)
                lcr3(V2P(curproc->pgdir)); // Flush TLB
801067af:	8b 47 04             	mov    0x4(%edi),%eax
801067b2:	05 00 00 00 80       	add    $0x80000000,%eax
  asm volatile("movl %0,%%cr3" : : "r" (val));
801067b7:	0f 22 d8             	mov    %eax,%cr3
                dec_ref(pa);
801067ba:	89 1c 24             	mov    %ebx,(%esp)
801067bd:	e8 2e bd ff ff       	call   801024f0 <dec_ref>
                if (get_ref(pa) == 0) {
801067c2:	89 1c 24             	mov    %ebx,(%esp)
801067c5:	e8 46 bd ff ff       	call   80102510 <get_ref>
801067ca:	83 c4 10             	add    $0x10,%esp
801067cd:	8b 55 e0             	mov    -0x20(%ebp),%edx
801067d0:	8b 4d dc             	mov    -0x24(%ebp),%ecx
801067d3:	85 c0                	test   %eax,%eax
801067d5:	0f 84 b2 01 00 00    	je     8010698d <trap+0x5fd>
                cprintf("COW: Duplicated page, va=0x%x, new_pa=0x%x\n", fault_addr, V2P(new_page));
801067db:	83 ec 04             	sub    $0x4,%esp
801067de:	52                   	push   %edx
801067df:	ff 75 e4             	push   -0x1c(%ebp)
801067e2:	68 04 8a 10 80       	push   $0x80108a04
801067e7:	e8 b4 9e ff ff       	call   801006a0 <cprintf>
                return;
801067ec:	83 c4 10             	add    $0x10,%esp
801067ef:	e9 eb fb ff ff       	jmp    801063df <trap+0x4f>
801067f4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
801067f8:	8b 7d e0             	mov    -0x20(%ebp),%edi
801067fb:	8b 5d dc             	mov    -0x24(%ebp),%ebx
    cprintf("Page fault: Segmentation Fault at 0x%x\n", fault_addr);
801067fe:	83 ec 08             	sub    $0x8,%esp
80106801:	ff 75 e4             	push   -0x1c(%ebp)
80106804:	68 54 8b 10 80       	push   $0x80108b54
80106809:	e8 92 9e ff ff       	call   801006a0 <cprintf>
    curproc->killed = 1;
8010680e:	c7 47 24 01 00 00 00 	movl   $0x1,0x24(%edi)
    break;
80106815:	83 c4 10             	add    $0x10,%esp
80106818:	e9 1a fc ff ff       	jmp    80106437 <trap+0xa7>
8010681d:	8d 76 00             	lea    0x0(%esi),%esi
            memset(mem, 0, PGSIZE);  // Clear the page for anonymous mappings
80106820:	83 ec 04             	sub    $0x4,%esp
80106823:	68 00 10 00 00       	push   $0x1000
80106828:	6a 00                	push   $0x0
8010682a:	53                   	push   %ebx
8010682b:	e8 30 e4 ff ff       	call   80104c60 <memset>
80106830:	83 c4 10             	add    $0x10,%esp
80106833:	e9 98 fe ff ff       	jmp    801066d0 <trap+0x340>
80106838:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010683f:	90                   	nop
    cprintf("Page fault: PTE not present at va=0x%x, pte=0x%x\n", fault_addr, *pte);
80106840:	83 ec 04             	sub    $0x4,%esp
80106843:	50                   	push   %eax
80106844:	ff 75 e4             	push   -0x1c(%ebp)
80106847:	68 88 89 10 80       	push   $0x80108988
8010684c:	e8 4f 9e ff ff       	call   801006a0 <cprintf>
    curproc->killed = 1;
80106851:	c7 47 24 01 00 00 00 	movl   $0x1,0x24(%edi)
    return;
80106858:	83 c4 10             	add    $0x10,%esp
8010685b:	e9 7f fb ff ff       	jmp    801063df <trap+0x4f>
            kfree(mem);
80106860:	83 ec 0c             	sub    $0xc,%esp
80106863:	53                   	push   %ebx
80106864:	e8 c7 bc ff ff       	call   80102530 <kfree>
            cprintf("trap: mappages failed\n");
80106869:	c7 04 24 46 89 10 80 	movl   $0x80108946,(%esp)
80106870:	e8 2b 9e ff ff       	call   801006a0 <cprintf>
            curproc->killed = 1;
80106875:	c7 47 24 01 00 00 00 	movl   $0x1,0x24(%edi)
            return;
8010687c:	83 c4 10             	add    $0x10,%esp
8010687f:	e9 5b fb ff ff       	jmp    801063df <trap+0x4f>
            cprintf("Page fault: Non-COW fault at va=0x%x\n", fault_addr);
80106884:	83 ec 08             	sub    $0x8,%esp
80106887:	ff 75 e4             	push   -0x1c(%ebp)
8010688a:	68 30 8a 10 80       	push   $0x80108a30
8010688f:	e8 0c 9e ff ff       	call   801006a0 <cprintf>
            curproc->killed = 1; // Kill process for invalid non-COW access
80106894:	c7 47 24 01 00 00 00 	movl   $0x1,0x24(%edi)
            return;
8010689b:	83 c4 10             	add    $0x10,%esp
8010689e:	e9 3c fb ff ff       	jmp    801063df <trap+0x4f>
            cprintf("trap: out of memory\n");
801068a3:	83 ec 0c             	sub    $0xc,%esp
801068a6:	68 31 89 10 80       	push   $0x80108931
801068ab:	e8 f0 9d ff ff       	call   801006a0 <cprintf>
            curproc->killed = 1;
801068b0:	c7 47 24 01 00 00 00 	movl   $0x1,0x24(%edi)
            return;
801068b7:	83 c4 10             	add    $0x10,%esp
801068ba:	e9 20 fb ff ff       	jmp    801063df <trap+0x4f>
                    iunlock(f->ip);
801068bf:	8b 45 e0             	mov    -0x20(%ebp),%eax
801068c2:	83 ec 0c             	sub    $0xc,%esp
801068c5:	ff 70 10             	push   0x10(%eax)
801068c8:	e8 a3 af ff ff       	call   80101870 <iunlock>
                    kfree(mem);
801068cd:	89 1c 24             	mov    %ebx,(%esp)
801068d0:	e8 5b bc ff ff       	call   80102530 <kfree>
                    cprintf("trap: readi failed at offset %d\n", file_offset);
801068d5:	5b                   	pop    %ebx
801068d6:	5e                   	pop    %esi
801068d7:	ff 75 dc             	push   -0x24(%ebp)
801068da:	68 b8 8a 10 80       	push   $0x80108ab8
801068df:	e8 bc 9d ff ff       	call   801006a0 <cprintf>
                    curproc->killed = 1;
801068e4:	c7 47 24 01 00 00 00 	movl   $0x1,0x24(%edi)
                    return;
801068eb:	83 c4 10             	add    $0x10,%esp
801068ee:	e9 ec fa ff ff       	jmp    801063df <trap+0x4f>
                memset(mem, 0, PGSIZE);  // Clear the page first
801068f3:	83 ec 04             	sub    $0x4,%esp
801068f6:	68 00 10 00 00       	push   $0x1000
801068fb:	6a 00                	push   $0x0
801068fd:	53                   	push   %ebx
801068fe:	e8 5d e3 ff ff       	call   80104c60 <memset>
                ilock(f->ip);
80106903:	58                   	pop    %eax
80106904:	8b 45 e0             	mov    -0x20(%ebp),%eax
80106907:	ff 70 10             	push   0x10(%eax)
8010690a:	e8 81 ae ff ff       	call   80101790 <ilock>
                if (readi(f->ip, mem, file_offset, bytes_to_read) != bytes_to_read) {
8010690f:	8b 45 e0             	mov    -0x20(%ebp),%eax
80106912:	68 00 10 00 00       	push   $0x1000
80106917:	ff 75 dc             	push   -0x24(%ebp)
8010691a:	53                   	push   %ebx
8010691b:	ff 70 10             	push   0x10(%eax)
8010691e:	e8 7d b1 ff ff       	call   80101aa0 <readi>
80106923:	83 c4 20             	add    $0x20,%esp
80106926:	3d 00 10 00 00       	cmp    $0x1000,%eax
8010692b:	75 92                	jne    801068bf <trap+0x52f>
                iunlock(f->ip);
8010692d:	8b 45 e0             	mov    -0x20(%ebp),%eax
80106930:	83 ec 0c             	sub    $0xc,%esp
80106933:	ff 70 10             	push   0x10(%eax)
80106936:	e8 35 af ff ff       	call   80101870 <iunlock>
8010693b:	83 c4 10             	add    $0x10,%esp
8010693e:	e9 8d fd ff ff       	jmp    801066d0 <trap+0x340>
                    cprintf("Page fault: Out of memory\n");
80106943:	83 ec 0c             	sub    $0xc,%esp
80106946:	68 16 89 10 80       	push   $0x80108916
8010694b:	e8 50 9d ff ff       	call   801006a0 <cprintf>
                    curproc->killed = 1;
80106950:	c7 47 24 01 00 00 00 	movl   $0x1,0x24(%edi)
                    return;
80106957:	83 c4 10             	add    $0x10,%esp
8010695a:	e9 80 fa ff ff       	jmp    801063df <trap+0x4f>
                *pte &= ~PTE_COW;   // Remove COW flag
8010695f:	8b 06                	mov    (%esi),%eax
80106961:	80 e4 fb             	and    $0xfb,%ah
80106964:	83 c8 02             	or     $0x2,%eax
80106967:	89 06                	mov    %eax,(%esi)
                lcr3(V2P(curproc->pgdir)); // Flush TLB
80106969:	8b 47 04             	mov    0x4(%edi),%eax
8010696c:	05 00 00 00 80       	add    $0x80000000,%eax
80106971:	0f 22 d8             	mov    %eax,%cr3
                cprintf("COW: Made writable, va=0x%x, pa=0x%x\n", fault_addr, pa);
80106974:	83 ec 04             	sub    $0x4,%esp
80106977:	53                   	push   %ebx
80106978:	ff 75 e4             	push   -0x1c(%ebp)
8010697b:	68 dc 89 10 80       	push   $0x801089dc
80106980:	e8 1b 9d ff ff       	call   801006a0 <cprintf>
                return;
80106985:	83 c4 10             	add    $0x10,%esp
80106988:	e9 52 fa ff ff       	jmp    801063df <trap+0x4f>
                    kfree((char *)P2V(pa)); // Free if no references remain
8010698d:	83 ec 0c             	sub    $0xc,%esp
80106990:	51                   	push   %ecx
80106991:	e8 9a bb ff ff       	call   80102530 <kfree>
80106996:	8b 55 e0             	mov    -0x20(%ebp),%edx
80106999:	83 c4 10             	add    $0x10,%esp
8010699c:	e9 3a fe ff ff       	jmp    801067db <trap+0x44b>
            cprintf("trap: file descriptor %d not associated with any file\n", region->fd);
801069a1:	83 ec 08             	sub    $0x8,%esp
801069a4:	52                   	push   %edx
801069a5:	68 58 8a 10 80       	push   $0x80108a58
            cprintf("trap: file descriptor %d has no inode\n", region->fd);
801069aa:	e8 f1 9c ff ff       	call   801006a0 <cprintf>
            kfree(mem);
801069af:	89 1c 24             	mov    %ebx,(%esp)
801069b2:	e8 79 bb ff ff       	call   80102530 <kfree>
            curproc->killed = 1;
801069b7:	c7 47 24 01 00 00 00 	movl   $0x1,0x24(%edi)
            return;
801069be:	83 c4 10             	add    $0x10,%esp
801069c1:	e9 19 fa ff ff       	jmp    801063df <trap+0x4f>
            cprintf("trap: file descriptor %d has no inode\n", region->fd);
801069c6:	83 ec 08             	sub    $0x8,%esp
801069c9:	52                   	push   %edx
801069ca:	68 90 8a 10 80       	push   $0x80108a90
801069cf:	eb d9                	jmp    801069aa <trap+0x61a>
  asm volatile("movl %%cr2,%0" : "=r" (val));
801069d1:	0f 20 d7             	mov    %cr2,%edi
            cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
801069d4:	e8 f7 cf ff ff       	call   801039d0 <cpuid>
801069d9:	83 ec 0c             	sub    $0xc,%esp
801069dc:	57                   	push   %edi
801069dd:	56                   	push   %esi
801069de:	50                   	push   %eax
801069df:	ff 73 30             	push   0x30(%ebx)
801069e2:	68 dc 8a 10 80       	push   $0x80108adc
801069e7:	e8 b4 9c ff ff       	call   801006a0 <cprintf>
            panic("trap");
801069ec:	83 c4 14             	add    $0x14,%esp
801069ef:	68 5d 89 10 80       	push   $0x8010895d
801069f4:	e8 87 99 ff ff       	call   80100380 <panic>
801069f9:	66 90                	xchg   %ax,%ax
801069fb:	66 90                	xchg   %ax,%ax
801069fd:	66 90                	xchg   %ax,%ax
801069ff:	90                   	nop

80106a00 <uartgetc>:
}

static int
uartgetc(void)
{
  if(!uart)
80106a00:	a1 00 a6 21 80       	mov    0x8021a600,%eax
80106a05:	85 c0                	test   %eax,%eax
80106a07:	74 17                	je     80106a20 <uartgetc+0x20>
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80106a09:	ba fd 03 00 00       	mov    $0x3fd,%edx
80106a0e:	ec                   	in     (%dx),%al
    return -1;
  if(!(inb(COM1+5) & 0x01))
80106a0f:	a8 01                	test   $0x1,%al
80106a11:	74 0d                	je     80106a20 <uartgetc+0x20>
80106a13:	ba f8 03 00 00       	mov    $0x3f8,%edx
80106a18:	ec                   	in     (%dx),%al
    return -1;
  return inb(COM1+0);
80106a19:	0f b6 c0             	movzbl %al,%eax
80106a1c:	c3                   	ret    
80106a1d:	8d 76 00             	lea    0x0(%esi),%esi
    return -1;
80106a20:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80106a25:	c3                   	ret    
80106a26:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80106a2d:	8d 76 00             	lea    0x0(%esi),%esi

80106a30 <uartinit>:
{
80106a30:	55                   	push   %ebp
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80106a31:	31 c9                	xor    %ecx,%ecx
80106a33:	89 c8                	mov    %ecx,%eax
80106a35:	89 e5                	mov    %esp,%ebp
80106a37:	57                   	push   %edi
80106a38:	bf fa 03 00 00       	mov    $0x3fa,%edi
80106a3d:	56                   	push   %esi
80106a3e:	89 fa                	mov    %edi,%edx
80106a40:	53                   	push   %ebx
80106a41:	83 ec 1c             	sub    $0x1c,%esp
80106a44:	ee                   	out    %al,(%dx)
80106a45:	be fb 03 00 00       	mov    $0x3fb,%esi
80106a4a:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
80106a4f:	89 f2                	mov    %esi,%edx
80106a51:	ee                   	out    %al,(%dx)
80106a52:	b8 0c 00 00 00       	mov    $0xc,%eax
80106a57:	ba f8 03 00 00       	mov    $0x3f8,%edx
80106a5c:	ee                   	out    %al,(%dx)
80106a5d:	bb f9 03 00 00       	mov    $0x3f9,%ebx
80106a62:	89 c8                	mov    %ecx,%eax
80106a64:	89 da                	mov    %ebx,%edx
80106a66:	ee                   	out    %al,(%dx)
80106a67:	b8 03 00 00 00       	mov    $0x3,%eax
80106a6c:	89 f2                	mov    %esi,%edx
80106a6e:	ee                   	out    %al,(%dx)
80106a6f:	ba fc 03 00 00       	mov    $0x3fc,%edx
80106a74:	89 c8                	mov    %ecx,%eax
80106a76:	ee                   	out    %al,(%dx)
80106a77:	b8 01 00 00 00       	mov    $0x1,%eax
80106a7c:	89 da                	mov    %ebx,%edx
80106a7e:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80106a7f:	ba fd 03 00 00       	mov    $0x3fd,%edx
80106a84:	ec                   	in     (%dx),%al
  if(inb(COM1+5) == 0xFF)
80106a85:	3c ff                	cmp    $0xff,%al
80106a87:	74 78                	je     80106b01 <uartinit+0xd1>
  uart = 1;
80106a89:	c7 05 00 a6 21 80 01 	movl   $0x1,0x8021a600
80106a90:	00 00 00 
80106a93:	89 fa                	mov    %edi,%edx
80106a95:	ec                   	in     (%dx),%al
80106a96:	ba f8 03 00 00       	mov    $0x3f8,%edx
80106a9b:	ec                   	in     (%dx),%al
  ioapicenable(IRQ_COM1, 0);
80106a9c:	83 ec 08             	sub    $0x8,%esp
  for(p="xv6...\n"; *p; p++)
80106a9f:	bf 44 8c 10 80       	mov    $0x80108c44,%edi
80106aa4:	be fd 03 00 00       	mov    $0x3fd,%esi
  ioapicenable(IRQ_COM1, 0);
80106aa9:	6a 00                	push   $0x0
80106aab:	6a 04                	push   $0x4
80106aad:	e8 de b9 ff ff       	call   80102490 <ioapicenable>
  for(p="xv6...\n"; *p; p++)
80106ab2:	c6 45 e7 78          	movb   $0x78,-0x19(%ebp)
  ioapicenable(IRQ_COM1, 0);
80106ab6:	83 c4 10             	add    $0x10,%esp
80106ab9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  if(!uart)
80106ac0:	a1 00 a6 21 80       	mov    0x8021a600,%eax
80106ac5:	bb 80 00 00 00       	mov    $0x80,%ebx
80106aca:	85 c0                	test   %eax,%eax
80106acc:	75 14                	jne    80106ae2 <uartinit+0xb2>
80106ace:	eb 23                	jmp    80106af3 <uartinit+0xc3>
    microdelay(10);
80106ad0:	83 ec 0c             	sub    $0xc,%esp
80106ad3:	6a 0a                	push   $0xa
80106ad5:	e8 c6 be ff ff       	call   801029a0 <microdelay>
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80106ada:	83 c4 10             	add    $0x10,%esp
80106add:	83 eb 01             	sub    $0x1,%ebx
80106ae0:	74 07                	je     80106ae9 <uartinit+0xb9>
80106ae2:	89 f2                	mov    %esi,%edx
80106ae4:	ec                   	in     (%dx),%al
80106ae5:	a8 20                	test   $0x20,%al
80106ae7:	74 e7                	je     80106ad0 <uartinit+0xa0>
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80106ae9:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
80106aed:	ba f8 03 00 00       	mov    $0x3f8,%edx
80106af2:	ee                   	out    %al,(%dx)
  for(p="xv6...\n"; *p; p++)
80106af3:	0f b6 47 01          	movzbl 0x1(%edi),%eax
80106af7:	83 c7 01             	add    $0x1,%edi
80106afa:	88 45 e7             	mov    %al,-0x19(%ebp)
80106afd:	84 c0                	test   %al,%al
80106aff:	75 bf                	jne    80106ac0 <uartinit+0x90>
}
80106b01:	8d 65 f4             	lea    -0xc(%ebp),%esp
80106b04:	5b                   	pop    %ebx
80106b05:	5e                   	pop    %esi
80106b06:	5f                   	pop    %edi
80106b07:	5d                   	pop    %ebp
80106b08:	c3                   	ret    
80106b09:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

80106b10 <uartputc>:
  if(!uart)
80106b10:	a1 00 a6 21 80       	mov    0x8021a600,%eax
80106b15:	85 c0                	test   %eax,%eax
80106b17:	74 47                	je     80106b60 <uartputc+0x50>
{
80106b19:	55                   	push   %ebp
80106b1a:	89 e5                	mov    %esp,%ebp
80106b1c:	56                   	push   %esi
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80106b1d:	be fd 03 00 00       	mov    $0x3fd,%esi
80106b22:	53                   	push   %ebx
80106b23:	bb 80 00 00 00       	mov    $0x80,%ebx
80106b28:	eb 18                	jmp    80106b42 <uartputc+0x32>
80106b2a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    microdelay(10);
80106b30:	83 ec 0c             	sub    $0xc,%esp
80106b33:	6a 0a                	push   $0xa
80106b35:	e8 66 be ff ff       	call   801029a0 <microdelay>
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80106b3a:	83 c4 10             	add    $0x10,%esp
80106b3d:	83 eb 01             	sub    $0x1,%ebx
80106b40:	74 07                	je     80106b49 <uartputc+0x39>
80106b42:	89 f2                	mov    %esi,%edx
80106b44:	ec                   	in     (%dx),%al
80106b45:	a8 20                	test   $0x20,%al
80106b47:	74 e7                	je     80106b30 <uartputc+0x20>
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80106b49:	8b 45 08             	mov    0x8(%ebp),%eax
80106b4c:	ba f8 03 00 00       	mov    $0x3f8,%edx
80106b51:	ee                   	out    %al,(%dx)
}
80106b52:	8d 65 f8             	lea    -0x8(%ebp),%esp
80106b55:	5b                   	pop    %ebx
80106b56:	5e                   	pop    %esi
80106b57:	5d                   	pop    %ebp
80106b58:	c3                   	ret    
80106b59:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80106b60:	c3                   	ret    
80106b61:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80106b68:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80106b6f:	90                   	nop

80106b70 <uartintr>:

void
uartintr(void)
{
80106b70:	55                   	push   %ebp
80106b71:	89 e5                	mov    %esp,%ebp
80106b73:	83 ec 14             	sub    $0x14,%esp
  consoleintr(uartgetc);
80106b76:	68 00 6a 10 80       	push   $0x80106a00
80106b7b:	e8 00 9d ff ff       	call   80100880 <consoleintr>
}
80106b80:	83 c4 10             	add    $0x10,%esp
80106b83:	c9                   	leave  
80106b84:	c3                   	ret    

80106b85 <vector0>:
# generated by vectors.pl - do not edit
# handlers
.globl alltraps
.globl vector0
vector0:
  pushl $0
80106b85:	6a 00                	push   $0x0
  pushl $0
80106b87:	6a 00                	push   $0x0
  jmp alltraps
80106b89:	e9 27 f7 ff ff       	jmp    801062b5 <alltraps>

80106b8e <vector1>:
.globl vector1
vector1:
  pushl $0
80106b8e:	6a 00                	push   $0x0
  pushl $1
80106b90:	6a 01                	push   $0x1
  jmp alltraps
80106b92:	e9 1e f7 ff ff       	jmp    801062b5 <alltraps>

80106b97 <vector2>:
.globl vector2
vector2:
  pushl $0
80106b97:	6a 00                	push   $0x0
  pushl $2
80106b99:	6a 02                	push   $0x2
  jmp alltraps
80106b9b:	e9 15 f7 ff ff       	jmp    801062b5 <alltraps>

80106ba0 <vector3>:
.globl vector3
vector3:
  pushl $0
80106ba0:	6a 00                	push   $0x0
  pushl $3
80106ba2:	6a 03                	push   $0x3
  jmp alltraps
80106ba4:	e9 0c f7 ff ff       	jmp    801062b5 <alltraps>

80106ba9 <vector4>:
.globl vector4
vector4:
  pushl $0
80106ba9:	6a 00                	push   $0x0
  pushl $4
80106bab:	6a 04                	push   $0x4
  jmp alltraps
80106bad:	e9 03 f7 ff ff       	jmp    801062b5 <alltraps>

80106bb2 <vector5>:
.globl vector5
vector5:
  pushl $0
80106bb2:	6a 00                	push   $0x0
  pushl $5
80106bb4:	6a 05                	push   $0x5
  jmp alltraps
80106bb6:	e9 fa f6 ff ff       	jmp    801062b5 <alltraps>

80106bbb <vector6>:
.globl vector6
vector6:
  pushl $0
80106bbb:	6a 00                	push   $0x0
  pushl $6
80106bbd:	6a 06                	push   $0x6
  jmp alltraps
80106bbf:	e9 f1 f6 ff ff       	jmp    801062b5 <alltraps>

80106bc4 <vector7>:
.globl vector7
vector7:
  pushl $0
80106bc4:	6a 00                	push   $0x0
  pushl $7
80106bc6:	6a 07                	push   $0x7
  jmp alltraps
80106bc8:	e9 e8 f6 ff ff       	jmp    801062b5 <alltraps>

80106bcd <vector8>:
.globl vector8
vector8:
  pushl $8
80106bcd:	6a 08                	push   $0x8
  jmp alltraps
80106bcf:	e9 e1 f6 ff ff       	jmp    801062b5 <alltraps>

80106bd4 <vector9>:
.globl vector9
vector9:
  pushl $0
80106bd4:	6a 00                	push   $0x0
  pushl $9
80106bd6:	6a 09                	push   $0x9
  jmp alltraps
80106bd8:	e9 d8 f6 ff ff       	jmp    801062b5 <alltraps>

80106bdd <vector10>:
.globl vector10
vector10:
  pushl $10
80106bdd:	6a 0a                	push   $0xa
  jmp alltraps
80106bdf:	e9 d1 f6 ff ff       	jmp    801062b5 <alltraps>

80106be4 <vector11>:
.globl vector11
vector11:
  pushl $11
80106be4:	6a 0b                	push   $0xb
  jmp alltraps
80106be6:	e9 ca f6 ff ff       	jmp    801062b5 <alltraps>

80106beb <vector12>:
.globl vector12
vector12:
  pushl $12
80106beb:	6a 0c                	push   $0xc
  jmp alltraps
80106bed:	e9 c3 f6 ff ff       	jmp    801062b5 <alltraps>

80106bf2 <vector13>:
.globl vector13
vector13:
  pushl $13
80106bf2:	6a 0d                	push   $0xd
  jmp alltraps
80106bf4:	e9 bc f6 ff ff       	jmp    801062b5 <alltraps>

80106bf9 <vector14>:
.globl vector14
vector14:
  pushl $14
80106bf9:	6a 0e                	push   $0xe
  jmp alltraps
80106bfb:	e9 b5 f6 ff ff       	jmp    801062b5 <alltraps>

80106c00 <vector15>:
.globl vector15
vector15:
  pushl $0
80106c00:	6a 00                	push   $0x0
  pushl $15
80106c02:	6a 0f                	push   $0xf
  jmp alltraps
80106c04:	e9 ac f6 ff ff       	jmp    801062b5 <alltraps>

80106c09 <vector16>:
.globl vector16
vector16:
  pushl $0
80106c09:	6a 00                	push   $0x0
  pushl $16
80106c0b:	6a 10                	push   $0x10
  jmp alltraps
80106c0d:	e9 a3 f6 ff ff       	jmp    801062b5 <alltraps>

80106c12 <vector17>:
.globl vector17
vector17:
  pushl $17
80106c12:	6a 11                	push   $0x11
  jmp alltraps
80106c14:	e9 9c f6 ff ff       	jmp    801062b5 <alltraps>

80106c19 <vector18>:
.globl vector18
vector18:
  pushl $0
80106c19:	6a 00                	push   $0x0
  pushl $18
80106c1b:	6a 12                	push   $0x12
  jmp alltraps
80106c1d:	e9 93 f6 ff ff       	jmp    801062b5 <alltraps>

80106c22 <vector19>:
.globl vector19
vector19:
  pushl $0
80106c22:	6a 00                	push   $0x0
  pushl $19
80106c24:	6a 13                	push   $0x13
  jmp alltraps
80106c26:	e9 8a f6 ff ff       	jmp    801062b5 <alltraps>

80106c2b <vector20>:
.globl vector20
vector20:
  pushl $0
80106c2b:	6a 00                	push   $0x0
  pushl $20
80106c2d:	6a 14                	push   $0x14
  jmp alltraps
80106c2f:	e9 81 f6 ff ff       	jmp    801062b5 <alltraps>

80106c34 <vector21>:
.globl vector21
vector21:
  pushl $0
80106c34:	6a 00                	push   $0x0
  pushl $21
80106c36:	6a 15                	push   $0x15
  jmp alltraps
80106c38:	e9 78 f6 ff ff       	jmp    801062b5 <alltraps>

80106c3d <vector22>:
.globl vector22
vector22:
  pushl $0
80106c3d:	6a 00                	push   $0x0
  pushl $22
80106c3f:	6a 16                	push   $0x16
  jmp alltraps
80106c41:	e9 6f f6 ff ff       	jmp    801062b5 <alltraps>

80106c46 <vector23>:
.globl vector23
vector23:
  pushl $0
80106c46:	6a 00                	push   $0x0
  pushl $23
80106c48:	6a 17                	push   $0x17
  jmp alltraps
80106c4a:	e9 66 f6 ff ff       	jmp    801062b5 <alltraps>

80106c4f <vector24>:
.globl vector24
vector24:
  pushl $0
80106c4f:	6a 00                	push   $0x0
  pushl $24
80106c51:	6a 18                	push   $0x18
  jmp alltraps
80106c53:	e9 5d f6 ff ff       	jmp    801062b5 <alltraps>

80106c58 <vector25>:
.globl vector25
vector25:
  pushl $0
80106c58:	6a 00                	push   $0x0
  pushl $25
80106c5a:	6a 19                	push   $0x19
  jmp alltraps
80106c5c:	e9 54 f6 ff ff       	jmp    801062b5 <alltraps>

80106c61 <vector26>:
.globl vector26
vector26:
  pushl $0
80106c61:	6a 00                	push   $0x0
  pushl $26
80106c63:	6a 1a                	push   $0x1a
  jmp alltraps
80106c65:	e9 4b f6 ff ff       	jmp    801062b5 <alltraps>

80106c6a <vector27>:
.globl vector27
vector27:
  pushl $0
80106c6a:	6a 00                	push   $0x0
  pushl $27
80106c6c:	6a 1b                	push   $0x1b
  jmp alltraps
80106c6e:	e9 42 f6 ff ff       	jmp    801062b5 <alltraps>

80106c73 <vector28>:
.globl vector28
vector28:
  pushl $0
80106c73:	6a 00                	push   $0x0
  pushl $28
80106c75:	6a 1c                	push   $0x1c
  jmp alltraps
80106c77:	e9 39 f6 ff ff       	jmp    801062b5 <alltraps>

80106c7c <vector29>:
.globl vector29
vector29:
  pushl $0
80106c7c:	6a 00                	push   $0x0
  pushl $29
80106c7e:	6a 1d                	push   $0x1d
  jmp alltraps
80106c80:	e9 30 f6 ff ff       	jmp    801062b5 <alltraps>

80106c85 <vector30>:
.globl vector30
vector30:
  pushl $0
80106c85:	6a 00                	push   $0x0
  pushl $30
80106c87:	6a 1e                	push   $0x1e
  jmp alltraps
80106c89:	e9 27 f6 ff ff       	jmp    801062b5 <alltraps>

80106c8e <vector31>:
.globl vector31
vector31:
  pushl $0
80106c8e:	6a 00                	push   $0x0
  pushl $31
80106c90:	6a 1f                	push   $0x1f
  jmp alltraps
80106c92:	e9 1e f6 ff ff       	jmp    801062b5 <alltraps>

80106c97 <vector32>:
.globl vector32
vector32:
  pushl $0
80106c97:	6a 00                	push   $0x0
  pushl $32
80106c99:	6a 20                	push   $0x20
  jmp alltraps
80106c9b:	e9 15 f6 ff ff       	jmp    801062b5 <alltraps>

80106ca0 <vector33>:
.globl vector33
vector33:
  pushl $0
80106ca0:	6a 00                	push   $0x0
  pushl $33
80106ca2:	6a 21                	push   $0x21
  jmp alltraps
80106ca4:	e9 0c f6 ff ff       	jmp    801062b5 <alltraps>

80106ca9 <vector34>:
.globl vector34
vector34:
  pushl $0
80106ca9:	6a 00                	push   $0x0
  pushl $34
80106cab:	6a 22                	push   $0x22
  jmp alltraps
80106cad:	e9 03 f6 ff ff       	jmp    801062b5 <alltraps>

80106cb2 <vector35>:
.globl vector35
vector35:
  pushl $0
80106cb2:	6a 00                	push   $0x0
  pushl $35
80106cb4:	6a 23                	push   $0x23
  jmp alltraps
80106cb6:	e9 fa f5 ff ff       	jmp    801062b5 <alltraps>

80106cbb <vector36>:
.globl vector36
vector36:
  pushl $0
80106cbb:	6a 00                	push   $0x0
  pushl $36
80106cbd:	6a 24                	push   $0x24
  jmp alltraps
80106cbf:	e9 f1 f5 ff ff       	jmp    801062b5 <alltraps>

80106cc4 <vector37>:
.globl vector37
vector37:
  pushl $0
80106cc4:	6a 00                	push   $0x0
  pushl $37
80106cc6:	6a 25                	push   $0x25
  jmp alltraps
80106cc8:	e9 e8 f5 ff ff       	jmp    801062b5 <alltraps>

80106ccd <vector38>:
.globl vector38
vector38:
  pushl $0
80106ccd:	6a 00                	push   $0x0
  pushl $38
80106ccf:	6a 26                	push   $0x26
  jmp alltraps
80106cd1:	e9 df f5 ff ff       	jmp    801062b5 <alltraps>

80106cd6 <vector39>:
.globl vector39
vector39:
  pushl $0
80106cd6:	6a 00                	push   $0x0
  pushl $39
80106cd8:	6a 27                	push   $0x27
  jmp alltraps
80106cda:	e9 d6 f5 ff ff       	jmp    801062b5 <alltraps>

80106cdf <vector40>:
.globl vector40
vector40:
  pushl $0
80106cdf:	6a 00                	push   $0x0
  pushl $40
80106ce1:	6a 28                	push   $0x28
  jmp alltraps
80106ce3:	e9 cd f5 ff ff       	jmp    801062b5 <alltraps>

80106ce8 <vector41>:
.globl vector41
vector41:
  pushl $0
80106ce8:	6a 00                	push   $0x0
  pushl $41
80106cea:	6a 29                	push   $0x29
  jmp alltraps
80106cec:	e9 c4 f5 ff ff       	jmp    801062b5 <alltraps>

80106cf1 <vector42>:
.globl vector42
vector42:
  pushl $0
80106cf1:	6a 00                	push   $0x0
  pushl $42
80106cf3:	6a 2a                	push   $0x2a
  jmp alltraps
80106cf5:	e9 bb f5 ff ff       	jmp    801062b5 <alltraps>

80106cfa <vector43>:
.globl vector43
vector43:
  pushl $0
80106cfa:	6a 00                	push   $0x0
  pushl $43
80106cfc:	6a 2b                	push   $0x2b
  jmp alltraps
80106cfe:	e9 b2 f5 ff ff       	jmp    801062b5 <alltraps>

80106d03 <vector44>:
.globl vector44
vector44:
  pushl $0
80106d03:	6a 00                	push   $0x0
  pushl $44
80106d05:	6a 2c                	push   $0x2c
  jmp alltraps
80106d07:	e9 a9 f5 ff ff       	jmp    801062b5 <alltraps>

80106d0c <vector45>:
.globl vector45
vector45:
  pushl $0
80106d0c:	6a 00                	push   $0x0
  pushl $45
80106d0e:	6a 2d                	push   $0x2d
  jmp alltraps
80106d10:	e9 a0 f5 ff ff       	jmp    801062b5 <alltraps>

80106d15 <vector46>:
.globl vector46
vector46:
  pushl $0
80106d15:	6a 00                	push   $0x0
  pushl $46
80106d17:	6a 2e                	push   $0x2e
  jmp alltraps
80106d19:	e9 97 f5 ff ff       	jmp    801062b5 <alltraps>

80106d1e <vector47>:
.globl vector47
vector47:
  pushl $0
80106d1e:	6a 00                	push   $0x0
  pushl $47
80106d20:	6a 2f                	push   $0x2f
  jmp alltraps
80106d22:	e9 8e f5 ff ff       	jmp    801062b5 <alltraps>

80106d27 <vector48>:
.globl vector48
vector48:
  pushl $0
80106d27:	6a 00                	push   $0x0
  pushl $48
80106d29:	6a 30                	push   $0x30
  jmp alltraps
80106d2b:	e9 85 f5 ff ff       	jmp    801062b5 <alltraps>

80106d30 <vector49>:
.globl vector49
vector49:
  pushl $0
80106d30:	6a 00                	push   $0x0
  pushl $49
80106d32:	6a 31                	push   $0x31
  jmp alltraps
80106d34:	e9 7c f5 ff ff       	jmp    801062b5 <alltraps>

80106d39 <vector50>:
.globl vector50
vector50:
  pushl $0
80106d39:	6a 00                	push   $0x0
  pushl $50
80106d3b:	6a 32                	push   $0x32
  jmp alltraps
80106d3d:	e9 73 f5 ff ff       	jmp    801062b5 <alltraps>

80106d42 <vector51>:
.globl vector51
vector51:
  pushl $0
80106d42:	6a 00                	push   $0x0
  pushl $51
80106d44:	6a 33                	push   $0x33
  jmp alltraps
80106d46:	e9 6a f5 ff ff       	jmp    801062b5 <alltraps>

80106d4b <vector52>:
.globl vector52
vector52:
  pushl $0
80106d4b:	6a 00                	push   $0x0
  pushl $52
80106d4d:	6a 34                	push   $0x34
  jmp alltraps
80106d4f:	e9 61 f5 ff ff       	jmp    801062b5 <alltraps>

80106d54 <vector53>:
.globl vector53
vector53:
  pushl $0
80106d54:	6a 00                	push   $0x0
  pushl $53
80106d56:	6a 35                	push   $0x35
  jmp alltraps
80106d58:	e9 58 f5 ff ff       	jmp    801062b5 <alltraps>

80106d5d <vector54>:
.globl vector54
vector54:
  pushl $0
80106d5d:	6a 00                	push   $0x0
  pushl $54
80106d5f:	6a 36                	push   $0x36
  jmp alltraps
80106d61:	e9 4f f5 ff ff       	jmp    801062b5 <alltraps>

80106d66 <vector55>:
.globl vector55
vector55:
  pushl $0
80106d66:	6a 00                	push   $0x0
  pushl $55
80106d68:	6a 37                	push   $0x37
  jmp alltraps
80106d6a:	e9 46 f5 ff ff       	jmp    801062b5 <alltraps>

80106d6f <vector56>:
.globl vector56
vector56:
  pushl $0
80106d6f:	6a 00                	push   $0x0
  pushl $56
80106d71:	6a 38                	push   $0x38
  jmp alltraps
80106d73:	e9 3d f5 ff ff       	jmp    801062b5 <alltraps>

80106d78 <vector57>:
.globl vector57
vector57:
  pushl $0
80106d78:	6a 00                	push   $0x0
  pushl $57
80106d7a:	6a 39                	push   $0x39
  jmp alltraps
80106d7c:	e9 34 f5 ff ff       	jmp    801062b5 <alltraps>

80106d81 <vector58>:
.globl vector58
vector58:
  pushl $0
80106d81:	6a 00                	push   $0x0
  pushl $58
80106d83:	6a 3a                	push   $0x3a
  jmp alltraps
80106d85:	e9 2b f5 ff ff       	jmp    801062b5 <alltraps>

80106d8a <vector59>:
.globl vector59
vector59:
  pushl $0
80106d8a:	6a 00                	push   $0x0
  pushl $59
80106d8c:	6a 3b                	push   $0x3b
  jmp alltraps
80106d8e:	e9 22 f5 ff ff       	jmp    801062b5 <alltraps>

80106d93 <vector60>:
.globl vector60
vector60:
  pushl $0
80106d93:	6a 00                	push   $0x0
  pushl $60
80106d95:	6a 3c                	push   $0x3c
  jmp alltraps
80106d97:	e9 19 f5 ff ff       	jmp    801062b5 <alltraps>

80106d9c <vector61>:
.globl vector61
vector61:
  pushl $0
80106d9c:	6a 00                	push   $0x0
  pushl $61
80106d9e:	6a 3d                	push   $0x3d
  jmp alltraps
80106da0:	e9 10 f5 ff ff       	jmp    801062b5 <alltraps>

80106da5 <vector62>:
.globl vector62
vector62:
  pushl $0
80106da5:	6a 00                	push   $0x0
  pushl $62
80106da7:	6a 3e                	push   $0x3e
  jmp alltraps
80106da9:	e9 07 f5 ff ff       	jmp    801062b5 <alltraps>

80106dae <vector63>:
.globl vector63
vector63:
  pushl $0
80106dae:	6a 00                	push   $0x0
  pushl $63
80106db0:	6a 3f                	push   $0x3f
  jmp alltraps
80106db2:	e9 fe f4 ff ff       	jmp    801062b5 <alltraps>

80106db7 <vector64>:
.globl vector64
vector64:
  pushl $0
80106db7:	6a 00                	push   $0x0
  pushl $64
80106db9:	6a 40                	push   $0x40
  jmp alltraps
80106dbb:	e9 f5 f4 ff ff       	jmp    801062b5 <alltraps>

80106dc0 <vector65>:
.globl vector65
vector65:
  pushl $0
80106dc0:	6a 00                	push   $0x0
  pushl $65
80106dc2:	6a 41                	push   $0x41
  jmp alltraps
80106dc4:	e9 ec f4 ff ff       	jmp    801062b5 <alltraps>

80106dc9 <vector66>:
.globl vector66
vector66:
  pushl $0
80106dc9:	6a 00                	push   $0x0
  pushl $66
80106dcb:	6a 42                	push   $0x42
  jmp alltraps
80106dcd:	e9 e3 f4 ff ff       	jmp    801062b5 <alltraps>

80106dd2 <vector67>:
.globl vector67
vector67:
  pushl $0
80106dd2:	6a 00                	push   $0x0
  pushl $67
80106dd4:	6a 43                	push   $0x43
  jmp alltraps
80106dd6:	e9 da f4 ff ff       	jmp    801062b5 <alltraps>

80106ddb <vector68>:
.globl vector68
vector68:
  pushl $0
80106ddb:	6a 00                	push   $0x0
  pushl $68
80106ddd:	6a 44                	push   $0x44
  jmp alltraps
80106ddf:	e9 d1 f4 ff ff       	jmp    801062b5 <alltraps>

80106de4 <vector69>:
.globl vector69
vector69:
  pushl $0
80106de4:	6a 00                	push   $0x0
  pushl $69
80106de6:	6a 45                	push   $0x45
  jmp alltraps
80106de8:	e9 c8 f4 ff ff       	jmp    801062b5 <alltraps>

80106ded <vector70>:
.globl vector70
vector70:
  pushl $0
80106ded:	6a 00                	push   $0x0
  pushl $70
80106def:	6a 46                	push   $0x46
  jmp alltraps
80106df1:	e9 bf f4 ff ff       	jmp    801062b5 <alltraps>

80106df6 <vector71>:
.globl vector71
vector71:
  pushl $0
80106df6:	6a 00                	push   $0x0
  pushl $71
80106df8:	6a 47                	push   $0x47
  jmp alltraps
80106dfa:	e9 b6 f4 ff ff       	jmp    801062b5 <alltraps>

80106dff <vector72>:
.globl vector72
vector72:
  pushl $0
80106dff:	6a 00                	push   $0x0
  pushl $72
80106e01:	6a 48                	push   $0x48
  jmp alltraps
80106e03:	e9 ad f4 ff ff       	jmp    801062b5 <alltraps>

80106e08 <vector73>:
.globl vector73
vector73:
  pushl $0
80106e08:	6a 00                	push   $0x0
  pushl $73
80106e0a:	6a 49                	push   $0x49
  jmp alltraps
80106e0c:	e9 a4 f4 ff ff       	jmp    801062b5 <alltraps>

80106e11 <vector74>:
.globl vector74
vector74:
  pushl $0
80106e11:	6a 00                	push   $0x0
  pushl $74
80106e13:	6a 4a                	push   $0x4a
  jmp alltraps
80106e15:	e9 9b f4 ff ff       	jmp    801062b5 <alltraps>

80106e1a <vector75>:
.globl vector75
vector75:
  pushl $0
80106e1a:	6a 00                	push   $0x0
  pushl $75
80106e1c:	6a 4b                	push   $0x4b
  jmp alltraps
80106e1e:	e9 92 f4 ff ff       	jmp    801062b5 <alltraps>

80106e23 <vector76>:
.globl vector76
vector76:
  pushl $0
80106e23:	6a 00                	push   $0x0
  pushl $76
80106e25:	6a 4c                	push   $0x4c
  jmp alltraps
80106e27:	e9 89 f4 ff ff       	jmp    801062b5 <alltraps>

80106e2c <vector77>:
.globl vector77
vector77:
  pushl $0
80106e2c:	6a 00                	push   $0x0
  pushl $77
80106e2e:	6a 4d                	push   $0x4d
  jmp alltraps
80106e30:	e9 80 f4 ff ff       	jmp    801062b5 <alltraps>

80106e35 <vector78>:
.globl vector78
vector78:
  pushl $0
80106e35:	6a 00                	push   $0x0
  pushl $78
80106e37:	6a 4e                	push   $0x4e
  jmp alltraps
80106e39:	e9 77 f4 ff ff       	jmp    801062b5 <alltraps>

80106e3e <vector79>:
.globl vector79
vector79:
  pushl $0
80106e3e:	6a 00                	push   $0x0
  pushl $79
80106e40:	6a 4f                	push   $0x4f
  jmp alltraps
80106e42:	e9 6e f4 ff ff       	jmp    801062b5 <alltraps>

80106e47 <vector80>:
.globl vector80
vector80:
  pushl $0
80106e47:	6a 00                	push   $0x0
  pushl $80
80106e49:	6a 50                	push   $0x50
  jmp alltraps
80106e4b:	e9 65 f4 ff ff       	jmp    801062b5 <alltraps>

80106e50 <vector81>:
.globl vector81
vector81:
  pushl $0
80106e50:	6a 00                	push   $0x0
  pushl $81
80106e52:	6a 51                	push   $0x51
  jmp alltraps
80106e54:	e9 5c f4 ff ff       	jmp    801062b5 <alltraps>

80106e59 <vector82>:
.globl vector82
vector82:
  pushl $0
80106e59:	6a 00                	push   $0x0
  pushl $82
80106e5b:	6a 52                	push   $0x52
  jmp alltraps
80106e5d:	e9 53 f4 ff ff       	jmp    801062b5 <alltraps>

80106e62 <vector83>:
.globl vector83
vector83:
  pushl $0
80106e62:	6a 00                	push   $0x0
  pushl $83
80106e64:	6a 53                	push   $0x53
  jmp alltraps
80106e66:	e9 4a f4 ff ff       	jmp    801062b5 <alltraps>

80106e6b <vector84>:
.globl vector84
vector84:
  pushl $0
80106e6b:	6a 00                	push   $0x0
  pushl $84
80106e6d:	6a 54                	push   $0x54
  jmp alltraps
80106e6f:	e9 41 f4 ff ff       	jmp    801062b5 <alltraps>

80106e74 <vector85>:
.globl vector85
vector85:
  pushl $0
80106e74:	6a 00                	push   $0x0
  pushl $85
80106e76:	6a 55                	push   $0x55
  jmp alltraps
80106e78:	e9 38 f4 ff ff       	jmp    801062b5 <alltraps>

80106e7d <vector86>:
.globl vector86
vector86:
  pushl $0
80106e7d:	6a 00                	push   $0x0
  pushl $86
80106e7f:	6a 56                	push   $0x56
  jmp alltraps
80106e81:	e9 2f f4 ff ff       	jmp    801062b5 <alltraps>

80106e86 <vector87>:
.globl vector87
vector87:
  pushl $0
80106e86:	6a 00                	push   $0x0
  pushl $87
80106e88:	6a 57                	push   $0x57
  jmp alltraps
80106e8a:	e9 26 f4 ff ff       	jmp    801062b5 <alltraps>

80106e8f <vector88>:
.globl vector88
vector88:
  pushl $0
80106e8f:	6a 00                	push   $0x0
  pushl $88
80106e91:	6a 58                	push   $0x58
  jmp alltraps
80106e93:	e9 1d f4 ff ff       	jmp    801062b5 <alltraps>

80106e98 <vector89>:
.globl vector89
vector89:
  pushl $0
80106e98:	6a 00                	push   $0x0
  pushl $89
80106e9a:	6a 59                	push   $0x59
  jmp alltraps
80106e9c:	e9 14 f4 ff ff       	jmp    801062b5 <alltraps>

80106ea1 <vector90>:
.globl vector90
vector90:
  pushl $0
80106ea1:	6a 00                	push   $0x0
  pushl $90
80106ea3:	6a 5a                	push   $0x5a
  jmp alltraps
80106ea5:	e9 0b f4 ff ff       	jmp    801062b5 <alltraps>

80106eaa <vector91>:
.globl vector91
vector91:
  pushl $0
80106eaa:	6a 00                	push   $0x0
  pushl $91
80106eac:	6a 5b                	push   $0x5b
  jmp alltraps
80106eae:	e9 02 f4 ff ff       	jmp    801062b5 <alltraps>

80106eb3 <vector92>:
.globl vector92
vector92:
  pushl $0
80106eb3:	6a 00                	push   $0x0
  pushl $92
80106eb5:	6a 5c                	push   $0x5c
  jmp alltraps
80106eb7:	e9 f9 f3 ff ff       	jmp    801062b5 <alltraps>

80106ebc <vector93>:
.globl vector93
vector93:
  pushl $0
80106ebc:	6a 00                	push   $0x0
  pushl $93
80106ebe:	6a 5d                	push   $0x5d
  jmp alltraps
80106ec0:	e9 f0 f3 ff ff       	jmp    801062b5 <alltraps>

80106ec5 <vector94>:
.globl vector94
vector94:
  pushl $0
80106ec5:	6a 00                	push   $0x0
  pushl $94
80106ec7:	6a 5e                	push   $0x5e
  jmp alltraps
80106ec9:	e9 e7 f3 ff ff       	jmp    801062b5 <alltraps>

80106ece <vector95>:
.globl vector95
vector95:
  pushl $0
80106ece:	6a 00                	push   $0x0
  pushl $95
80106ed0:	6a 5f                	push   $0x5f
  jmp alltraps
80106ed2:	e9 de f3 ff ff       	jmp    801062b5 <alltraps>

80106ed7 <vector96>:
.globl vector96
vector96:
  pushl $0
80106ed7:	6a 00                	push   $0x0
  pushl $96
80106ed9:	6a 60                	push   $0x60
  jmp alltraps
80106edb:	e9 d5 f3 ff ff       	jmp    801062b5 <alltraps>

80106ee0 <vector97>:
.globl vector97
vector97:
  pushl $0
80106ee0:	6a 00                	push   $0x0
  pushl $97
80106ee2:	6a 61                	push   $0x61
  jmp alltraps
80106ee4:	e9 cc f3 ff ff       	jmp    801062b5 <alltraps>

80106ee9 <vector98>:
.globl vector98
vector98:
  pushl $0
80106ee9:	6a 00                	push   $0x0
  pushl $98
80106eeb:	6a 62                	push   $0x62
  jmp alltraps
80106eed:	e9 c3 f3 ff ff       	jmp    801062b5 <alltraps>

80106ef2 <vector99>:
.globl vector99
vector99:
  pushl $0
80106ef2:	6a 00                	push   $0x0
  pushl $99
80106ef4:	6a 63                	push   $0x63
  jmp alltraps
80106ef6:	e9 ba f3 ff ff       	jmp    801062b5 <alltraps>

80106efb <vector100>:
.globl vector100
vector100:
  pushl $0
80106efb:	6a 00                	push   $0x0
  pushl $100
80106efd:	6a 64                	push   $0x64
  jmp alltraps
80106eff:	e9 b1 f3 ff ff       	jmp    801062b5 <alltraps>

80106f04 <vector101>:
.globl vector101
vector101:
  pushl $0
80106f04:	6a 00                	push   $0x0
  pushl $101
80106f06:	6a 65                	push   $0x65
  jmp alltraps
80106f08:	e9 a8 f3 ff ff       	jmp    801062b5 <alltraps>

80106f0d <vector102>:
.globl vector102
vector102:
  pushl $0
80106f0d:	6a 00                	push   $0x0
  pushl $102
80106f0f:	6a 66                	push   $0x66
  jmp alltraps
80106f11:	e9 9f f3 ff ff       	jmp    801062b5 <alltraps>

80106f16 <vector103>:
.globl vector103
vector103:
  pushl $0
80106f16:	6a 00                	push   $0x0
  pushl $103
80106f18:	6a 67                	push   $0x67
  jmp alltraps
80106f1a:	e9 96 f3 ff ff       	jmp    801062b5 <alltraps>

80106f1f <vector104>:
.globl vector104
vector104:
  pushl $0
80106f1f:	6a 00                	push   $0x0
  pushl $104
80106f21:	6a 68                	push   $0x68
  jmp alltraps
80106f23:	e9 8d f3 ff ff       	jmp    801062b5 <alltraps>

80106f28 <vector105>:
.globl vector105
vector105:
  pushl $0
80106f28:	6a 00                	push   $0x0
  pushl $105
80106f2a:	6a 69                	push   $0x69
  jmp alltraps
80106f2c:	e9 84 f3 ff ff       	jmp    801062b5 <alltraps>

80106f31 <vector106>:
.globl vector106
vector106:
  pushl $0
80106f31:	6a 00                	push   $0x0
  pushl $106
80106f33:	6a 6a                	push   $0x6a
  jmp alltraps
80106f35:	e9 7b f3 ff ff       	jmp    801062b5 <alltraps>

80106f3a <vector107>:
.globl vector107
vector107:
  pushl $0
80106f3a:	6a 00                	push   $0x0
  pushl $107
80106f3c:	6a 6b                	push   $0x6b
  jmp alltraps
80106f3e:	e9 72 f3 ff ff       	jmp    801062b5 <alltraps>

80106f43 <vector108>:
.globl vector108
vector108:
  pushl $0
80106f43:	6a 00                	push   $0x0
  pushl $108
80106f45:	6a 6c                	push   $0x6c
  jmp alltraps
80106f47:	e9 69 f3 ff ff       	jmp    801062b5 <alltraps>

80106f4c <vector109>:
.globl vector109
vector109:
  pushl $0
80106f4c:	6a 00                	push   $0x0
  pushl $109
80106f4e:	6a 6d                	push   $0x6d
  jmp alltraps
80106f50:	e9 60 f3 ff ff       	jmp    801062b5 <alltraps>

80106f55 <vector110>:
.globl vector110
vector110:
  pushl $0
80106f55:	6a 00                	push   $0x0
  pushl $110
80106f57:	6a 6e                	push   $0x6e
  jmp alltraps
80106f59:	e9 57 f3 ff ff       	jmp    801062b5 <alltraps>

80106f5e <vector111>:
.globl vector111
vector111:
  pushl $0
80106f5e:	6a 00                	push   $0x0
  pushl $111
80106f60:	6a 6f                	push   $0x6f
  jmp alltraps
80106f62:	e9 4e f3 ff ff       	jmp    801062b5 <alltraps>

80106f67 <vector112>:
.globl vector112
vector112:
  pushl $0
80106f67:	6a 00                	push   $0x0
  pushl $112
80106f69:	6a 70                	push   $0x70
  jmp alltraps
80106f6b:	e9 45 f3 ff ff       	jmp    801062b5 <alltraps>

80106f70 <vector113>:
.globl vector113
vector113:
  pushl $0
80106f70:	6a 00                	push   $0x0
  pushl $113
80106f72:	6a 71                	push   $0x71
  jmp alltraps
80106f74:	e9 3c f3 ff ff       	jmp    801062b5 <alltraps>

80106f79 <vector114>:
.globl vector114
vector114:
  pushl $0
80106f79:	6a 00                	push   $0x0
  pushl $114
80106f7b:	6a 72                	push   $0x72
  jmp alltraps
80106f7d:	e9 33 f3 ff ff       	jmp    801062b5 <alltraps>

80106f82 <vector115>:
.globl vector115
vector115:
  pushl $0
80106f82:	6a 00                	push   $0x0
  pushl $115
80106f84:	6a 73                	push   $0x73
  jmp alltraps
80106f86:	e9 2a f3 ff ff       	jmp    801062b5 <alltraps>

80106f8b <vector116>:
.globl vector116
vector116:
  pushl $0
80106f8b:	6a 00                	push   $0x0
  pushl $116
80106f8d:	6a 74                	push   $0x74
  jmp alltraps
80106f8f:	e9 21 f3 ff ff       	jmp    801062b5 <alltraps>

80106f94 <vector117>:
.globl vector117
vector117:
  pushl $0
80106f94:	6a 00                	push   $0x0
  pushl $117
80106f96:	6a 75                	push   $0x75
  jmp alltraps
80106f98:	e9 18 f3 ff ff       	jmp    801062b5 <alltraps>

80106f9d <vector118>:
.globl vector118
vector118:
  pushl $0
80106f9d:	6a 00                	push   $0x0
  pushl $118
80106f9f:	6a 76                	push   $0x76
  jmp alltraps
80106fa1:	e9 0f f3 ff ff       	jmp    801062b5 <alltraps>

80106fa6 <vector119>:
.globl vector119
vector119:
  pushl $0
80106fa6:	6a 00                	push   $0x0
  pushl $119
80106fa8:	6a 77                	push   $0x77
  jmp alltraps
80106faa:	e9 06 f3 ff ff       	jmp    801062b5 <alltraps>

80106faf <vector120>:
.globl vector120
vector120:
  pushl $0
80106faf:	6a 00                	push   $0x0
  pushl $120
80106fb1:	6a 78                	push   $0x78
  jmp alltraps
80106fb3:	e9 fd f2 ff ff       	jmp    801062b5 <alltraps>

80106fb8 <vector121>:
.globl vector121
vector121:
  pushl $0
80106fb8:	6a 00                	push   $0x0
  pushl $121
80106fba:	6a 79                	push   $0x79
  jmp alltraps
80106fbc:	e9 f4 f2 ff ff       	jmp    801062b5 <alltraps>

80106fc1 <vector122>:
.globl vector122
vector122:
  pushl $0
80106fc1:	6a 00                	push   $0x0
  pushl $122
80106fc3:	6a 7a                	push   $0x7a
  jmp alltraps
80106fc5:	e9 eb f2 ff ff       	jmp    801062b5 <alltraps>

80106fca <vector123>:
.globl vector123
vector123:
  pushl $0
80106fca:	6a 00                	push   $0x0
  pushl $123
80106fcc:	6a 7b                	push   $0x7b
  jmp alltraps
80106fce:	e9 e2 f2 ff ff       	jmp    801062b5 <alltraps>

80106fd3 <vector124>:
.globl vector124
vector124:
  pushl $0
80106fd3:	6a 00                	push   $0x0
  pushl $124
80106fd5:	6a 7c                	push   $0x7c
  jmp alltraps
80106fd7:	e9 d9 f2 ff ff       	jmp    801062b5 <alltraps>

80106fdc <vector125>:
.globl vector125
vector125:
  pushl $0
80106fdc:	6a 00                	push   $0x0
  pushl $125
80106fde:	6a 7d                	push   $0x7d
  jmp alltraps
80106fe0:	e9 d0 f2 ff ff       	jmp    801062b5 <alltraps>

80106fe5 <vector126>:
.globl vector126
vector126:
  pushl $0
80106fe5:	6a 00                	push   $0x0
  pushl $126
80106fe7:	6a 7e                	push   $0x7e
  jmp alltraps
80106fe9:	e9 c7 f2 ff ff       	jmp    801062b5 <alltraps>

80106fee <vector127>:
.globl vector127
vector127:
  pushl $0
80106fee:	6a 00                	push   $0x0
  pushl $127
80106ff0:	6a 7f                	push   $0x7f
  jmp alltraps
80106ff2:	e9 be f2 ff ff       	jmp    801062b5 <alltraps>

80106ff7 <vector128>:
.globl vector128
vector128:
  pushl $0
80106ff7:	6a 00                	push   $0x0
  pushl $128
80106ff9:	68 80 00 00 00       	push   $0x80
  jmp alltraps
80106ffe:	e9 b2 f2 ff ff       	jmp    801062b5 <alltraps>

80107003 <vector129>:
.globl vector129
vector129:
  pushl $0
80107003:	6a 00                	push   $0x0
  pushl $129
80107005:	68 81 00 00 00       	push   $0x81
  jmp alltraps
8010700a:	e9 a6 f2 ff ff       	jmp    801062b5 <alltraps>

8010700f <vector130>:
.globl vector130
vector130:
  pushl $0
8010700f:	6a 00                	push   $0x0
  pushl $130
80107011:	68 82 00 00 00       	push   $0x82
  jmp alltraps
80107016:	e9 9a f2 ff ff       	jmp    801062b5 <alltraps>

8010701b <vector131>:
.globl vector131
vector131:
  pushl $0
8010701b:	6a 00                	push   $0x0
  pushl $131
8010701d:	68 83 00 00 00       	push   $0x83
  jmp alltraps
80107022:	e9 8e f2 ff ff       	jmp    801062b5 <alltraps>

80107027 <vector132>:
.globl vector132
vector132:
  pushl $0
80107027:	6a 00                	push   $0x0
  pushl $132
80107029:	68 84 00 00 00       	push   $0x84
  jmp alltraps
8010702e:	e9 82 f2 ff ff       	jmp    801062b5 <alltraps>

80107033 <vector133>:
.globl vector133
vector133:
  pushl $0
80107033:	6a 00                	push   $0x0
  pushl $133
80107035:	68 85 00 00 00       	push   $0x85
  jmp alltraps
8010703a:	e9 76 f2 ff ff       	jmp    801062b5 <alltraps>

8010703f <vector134>:
.globl vector134
vector134:
  pushl $0
8010703f:	6a 00                	push   $0x0
  pushl $134
80107041:	68 86 00 00 00       	push   $0x86
  jmp alltraps
80107046:	e9 6a f2 ff ff       	jmp    801062b5 <alltraps>

8010704b <vector135>:
.globl vector135
vector135:
  pushl $0
8010704b:	6a 00                	push   $0x0
  pushl $135
8010704d:	68 87 00 00 00       	push   $0x87
  jmp alltraps
80107052:	e9 5e f2 ff ff       	jmp    801062b5 <alltraps>

80107057 <vector136>:
.globl vector136
vector136:
  pushl $0
80107057:	6a 00                	push   $0x0
  pushl $136
80107059:	68 88 00 00 00       	push   $0x88
  jmp alltraps
8010705e:	e9 52 f2 ff ff       	jmp    801062b5 <alltraps>

80107063 <vector137>:
.globl vector137
vector137:
  pushl $0
80107063:	6a 00                	push   $0x0
  pushl $137
80107065:	68 89 00 00 00       	push   $0x89
  jmp alltraps
8010706a:	e9 46 f2 ff ff       	jmp    801062b5 <alltraps>

8010706f <vector138>:
.globl vector138
vector138:
  pushl $0
8010706f:	6a 00                	push   $0x0
  pushl $138
80107071:	68 8a 00 00 00       	push   $0x8a
  jmp alltraps
80107076:	e9 3a f2 ff ff       	jmp    801062b5 <alltraps>

8010707b <vector139>:
.globl vector139
vector139:
  pushl $0
8010707b:	6a 00                	push   $0x0
  pushl $139
8010707d:	68 8b 00 00 00       	push   $0x8b
  jmp alltraps
80107082:	e9 2e f2 ff ff       	jmp    801062b5 <alltraps>

80107087 <vector140>:
.globl vector140
vector140:
  pushl $0
80107087:	6a 00                	push   $0x0
  pushl $140
80107089:	68 8c 00 00 00       	push   $0x8c
  jmp alltraps
8010708e:	e9 22 f2 ff ff       	jmp    801062b5 <alltraps>

80107093 <vector141>:
.globl vector141
vector141:
  pushl $0
80107093:	6a 00                	push   $0x0
  pushl $141
80107095:	68 8d 00 00 00       	push   $0x8d
  jmp alltraps
8010709a:	e9 16 f2 ff ff       	jmp    801062b5 <alltraps>

8010709f <vector142>:
.globl vector142
vector142:
  pushl $0
8010709f:	6a 00                	push   $0x0
  pushl $142
801070a1:	68 8e 00 00 00       	push   $0x8e
  jmp alltraps
801070a6:	e9 0a f2 ff ff       	jmp    801062b5 <alltraps>

801070ab <vector143>:
.globl vector143
vector143:
  pushl $0
801070ab:	6a 00                	push   $0x0
  pushl $143
801070ad:	68 8f 00 00 00       	push   $0x8f
  jmp alltraps
801070b2:	e9 fe f1 ff ff       	jmp    801062b5 <alltraps>

801070b7 <vector144>:
.globl vector144
vector144:
  pushl $0
801070b7:	6a 00                	push   $0x0
  pushl $144
801070b9:	68 90 00 00 00       	push   $0x90
  jmp alltraps
801070be:	e9 f2 f1 ff ff       	jmp    801062b5 <alltraps>

801070c3 <vector145>:
.globl vector145
vector145:
  pushl $0
801070c3:	6a 00                	push   $0x0
  pushl $145
801070c5:	68 91 00 00 00       	push   $0x91
  jmp alltraps
801070ca:	e9 e6 f1 ff ff       	jmp    801062b5 <alltraps>

801070cf <vector146>:
.globl vector146
vector146:
  pushl $0
801070cf:	6a 00                	push   $0x0
  pushl $146
801070d1:	68 92 00 00 00       	push   $0x92
  jmp alltraps
801070d6:	e9 da f1 ff ff       	jmp    801062b5 <alltraps>

801070db <vector147>:
.globl vector147
vector147:
  pushl $0
801070db:	6a 00                	push   $0x0
  pushl $147
801070dd:	68 93 00 00 00       	push   $0x93
  jmp alltraps
801070e2:	e9 ce f1 ff ff       	jmp    801062b5 <alltraps>

801070e7 <vector148>:
.globl vector148
vector148:
  pushl $0
801070e7:	6a 00                	push   $0x0
  pushl $148
801070e9:	68 94 00 00 00       	push   $0x94
  jmp alltraps
801070ee:	e9 c2 f1 ff ff       	jmp    801062b5 <alltraps>

801070f3 <vector149>:
.globl vector149
vector149:
  pushl $0
801070f3:	6a 00                	push   $0x0
  pushl $149
801070f5:	68 95 00 00 00       	push   $0x95
  jmp alltraps
801070fa:	e9 b6 f1 ff ff       	jmp    801062b5 <alltraps>

801070ff <vector150>:
.globl vector150
vector150:
  pushl $0
801070ff:	6a 00                	push   $0x0
  pushl $150
80107101:	68 96 00 00 00       	push   $0x96
  jmp alltraps
80107106:	e9 aa f1 ff ff       	jmp    801062b5 <alltraps>

8010710b <vector151>:
.globl vector151
vector151:
  pushl $0
8010710b:	6a 00                	push   $0x0
  pushl $151
8010710d:	68 97 00 00 00       	push   $0x97
  jmp alltraps
80107112:	e9 9e f1 ff ff       	jmp    801062b5 <alltraps>

80107117 <vector152>:
.globl vector152
vector152:
  pushl $0
80107117:	6a 00                	push   $0x0
  pushl $152
80107119:	68 98 00 00 00       	push   $0x98
  jmp alltraps
8010711e:	e9 92 f1 ff ff       	jmp    801062b5 <alltraps>

80107123 <vector153>:
.globl vector153
vector153:
  pushl $0
80107123:	6a 00                	push   $0x0
  pushl $153
80107125:	68 99 00 00 00       	push   $0x99
  jmp alltraps
8010712a:	e9 86 f1 ff ff       	jmp    801062b5 <alltraps>

8010712f <vector154>:
.globl vector154
vector154:
  pushl $0
8010712f:	6a 00                	push   $0x0
  pushl $154
80107131:	68 9a 00 00 00       	push   $0x9a
  jmp alltraps
80107136:	e9 7a f1 ff ff       	jmp    801062b5 <alltraps>

8010713b <vector155>:
.globl vector155
vector155:
  pushl $0
8010713b:	6a 00                	push   $0x0
  pushl $155
8010713d:	68 9b 00 00 00       	push   $0x9b
  jmp alltraps
80107142:	e9 6e f1 ff ff       	jmp    801062b5 <alltraps>

80107147 <vector156>:
.globl vector156
vector156:
  pushl $0
80107147:	6a 00                	push   $0x0
  pushl $156
80107149:	68 9c 00 00 00       	push   $0x9c
  jmp alltraps
8010714e:	e9 62 f1 ff ff       	jmp    801062b5 <alltraps>

80107153 <vector157>:
.globl vector157
vector157:
  pushl $0
80107153:	6a 00                	push   $0x0
  pushl $157
80107155:	68 9d 00 00 00       	push   $0x9d
  jmp alltraps
8010715a:	e9 56 f1 ff ff       	jmp    801062b5 <alltraps>

8010715f <vector158>:
.globl vector158
vector158:
  pushl $0
8010715f:	6a 00                	push   $0x0
  pushl $158
80107161:	68 9e 00 00 00       	push   $0x9e
  jmp alltraps
80107166:	e9 4a f1 ff ff       	jmp    801062b5 <alltraps>

8010716b <vector159>:
.globl vector159
vector159:
  pushl $0
8010716b:	6a 00                	push   $0x0
  pushl $159
8010716d:	68 9f 00 00 00       	push   $0x9f
  jmp alltraps
80107172:	e9 3e f1 ff ff       	jmp    801062b5 <alltraps>

80107177 <vector160>:
.globl vector160
vector160:
  pushl $0
80107177:	6a 00                	push   $0x0
  pushl $160
80107179:	68 a0 00 00 00       	push   $0xa0
  jmp alltraps
8010717e:	e9 32 f1 ff ff       	jmp    801062b5 <alltraps>

80107183 <vector161>:
.globl vector161
vector161:
  pushl $0
80107183:	6a 00                	push   $0x0
  pushl $161
80107185:	68 a1 00 00 00       	push   $0xa1
  jmp alltraps
8010718a:	e9 26 f1 ff ff       	jmp    801062b5 <alltraps>

8010718f <vector162>:
.globl vector162
vector162:
  pushl $0
8010718f:	6a 00                	push   $0x0
  pushl $162
80107191:	68 a2 00 00 00       	push   $0xa2
  jmp alltraps
80107196:	e9 1a f1 ff ff       	jmp    801062b5 <alltraps>

8010719b <vector163>:
.globl vector163
vector163:
  pushl $0
8010719b:	6a 00                	push   $0x0
  pushl $163
8010719d:	68 a3 00 00 00       	push   $0xa3
  jmp alltraps
801071a2:	e9 0e f1 ff ff       	jmp    801062b5 <alltraps>

801071a7 <vector164>:
.globl vector164
vector164:
  pushl $0
801071a7:	6a 00                	push   $0x0
  pushl $164
801071a9:	68 a4 00 00 00       	push   $0xa4
  jmp alltraps
801071ae:	e9 02 f1 ff ff       	jmp    801062b5 <alltraps>

801071b3 <vector165>:
.globl vector165
vector165:
  pushl $0
801071b3:	6a 00                	push   $0x0
  pushl $165
801071b5:	68 a5 00 00 00       	push   $0xa5
  jmp alltraps
801071ba:	e9 f6 f0 ff ff       	jmp    801062b5 <alltraps>

801071bf <vector166>:
.globl vector166
vector166:
  pushl $0
801071bf:	6a 00                	push   $0x0
  pushl $166
801071c1:	68 a6 00 00 00       	push   $0xa6
  jmp alltraps
801071c6:	e9 ea f0 ff ff       	jmp    801062b5 <alltraps>

801071cb <vector167>:
.globl vector167
vector167:
  pushl $0
801071cb:	6a 00                	push   $0x0
  pushl $167
801071cd:	68 a7 00 00 00       	push   $0xa7
  jmp alltraps
801071d2:	e9 de f0 ff ff       	jmp    801062b5 <alltraps>

801071d7 <vector168>:
.globl vector168
vector168:
  pushl $0
801071d7:	6a 00                	push   $0x0
  pushl $168
801071d9:	68 a8 00 00 00       	push   $0xa8
  jmp alltraps
801071de:	e9 d2 f0 ff ff       	jmp    801062b5 <alltraps>

801071e3 <vector169>:
.globl vector169
vector169:
  pushl $0
801071e3:	6a 00                	push   $0x0
  pushl $169
801071e5:	68 a9 00 00 00       	push   $0xa9
  jmp alltraps
801071ea:	e9 c6 f0 ff ff       	jmp    801062b5 <alltraps>

801071ef <vector170>:
.globl vector170
vector170:
  pushl $0
801071ef:	6a 00                	push   $0x0
  pushl $170
801071f1:	68 aa 00 00 00       	push   $0xaa
  jmp alltraps
801071f6:	e9 ba f0 ff ff       	jmp    801062b5 <alltraps>

801071fb <vector171>:
.globl vector171
vector171:
  pushl $0
801071fb:	6a 00                	push   $0x0
  pushl $171
801071fd:	68 ab 00 00 00       	push   $0xab
  jmp alltraps
80107202:	e9 ae f0 ff ff       	jmp    801062b5 <alltraps>

80107207 <vector172>:
.globl vector172
vector172:
  pushl $0
80107207:	6a 00                	push   $0x0
  pushl $172
80107209:	68 ac 00 00 00       	push   $0xac
  jmp alltraps
8010720e:	e9 a2 f0 ff ff       	jmp    801062b5 <alltraps>

80107213 <vector173>:
.globl vector173
vector173:
  pushl $0
80107213:	6a 00                	push   $0x0
  pushl $173
80107215:	68 ad 00 00 00       	push   $0xad
  jmp alltraps
8010721a:	e9 96 f0 ff ff       	jmp    801062b5 <alltraps>

8010721f <vector174>:
.globl vector174
vector174:
  pushl $0
8010721f:	6a 00                	push   $0x0
  pushl $174
80107221:	68 ae 00 00 00       	push   $0xae
  jmp alltraps
80107226:	e9 8a f0 ff ff       	jmp    801062b5 <alltraps>

8010722b <vector175>:
.globl vector175
vector175:
  pushl $0
8010722b:	6a 00                	push   $0x0
  pushl $175
8010722d:	68 af 00 00 00       	push   $0xaf
  jmp alltraps
80107232:	e9 7e f0 ff ff       	jmp    801062b5 <alltraps>

80107237 <vector176>:
.globl vector176
vector176:
  pushl $0
80107237:	6a 00                	push   $0x0
  pushl $176
80107239:	68 b0 00 00 00       	push   $0xb0
  jmp alltraps
8010723e:	e9 72 f0 ff ff       	jmp    801062b5 <alltraps>

80107243 <vector177>:
.globl vector177
vector177:
  pushl $0
80107243:	6a 00                	push   $0x0
  pushl $177
80107245:	68 b1 00 00 00       	push   $0xb1
  jmp alltraps
8010724a:	e9 66 f0 ff ff       	jmp    801062b5 <alltraps>

8010724f <vector178>:
.globl vector178
vector178:
  pushl $0
8010724f:	6a 00                	push   $0x0
  pushl $178
80107251:	68 b2 00 00 00       	push   $0xb2
  jmp alltraps
80107256:	e9 5a f0 ff ff       	jmp    801062b5 <alltraps>

8010725b <vector179>:
.globl vector179
vector179:
  pushl $0
8010725b:	6a 00                	push   $0x0
  pushl $179
8010725d:	68 b3 00 00 00       	push   $0xb3
  jmp alltraps
80107262:	e9 4e f0 ff ff       	jmp    801062b5 <alltraps>

80107267 <vector180>:
.globl vector180
vector180:
  pushl $0
80107267:	6a 00                	push   $0x0
  pushl $180
80107269:	68 b4 00 00 00       	push   $0xb4
  jmp alltraps
8010726e:	e9 42 f0 ff ff       	jmp    801062b5 <alltraps>

80107273 <vector181>:
.globl vector181
vector181:
  pushl $0
80107273:	6a 00                	push   $0x0
  pushl $181
80107275:	68 b5 00 00 00       	push   $0xb5
  jmp alltraps
8010727a:	e9 36 f0 ff ff       	jmp    801062b5 <alltraps>

8010727f <vector182>:
.globl vector182
vector182:
  pushl $0
8010727f:	6a 00                	push   $0x0
  pushl $182
80107281:	68 b6 00 00 00       	push   $0xb6
  jmp alltraps
80107286:	e9 2a f0 ff ff       	jmp    801062b5 <alltraps>

8010728b <vector183>:
.globl vector183
vector183:
  pushl $0
8010728b:	6a 00                	push   $0x0
  pushl $183
8010728d:	68 b7 00 00 00       	push   $0xb7
  jmp alltraps
80107292:	e9 1e f0 ff ff       	jmp    801062b5 <alltraps>

80107297 <vector184>:
.globl vector184
vector184:
  pushl $0
80107297:	6a 00                	push   $0x0
  pushl $184
80107299:	68 b8 00 00 00       	push   $0xb8
  jmp alltraps
8010729e:	e9 12 f0 ff ff       	jmp    801062b5 <alltraps>

801072a3 <vector185>:
.globl vector185
vector185:
  pushl $0
801072a3:	6a 00                	push   $0x0
  pushl $185
801072a5:	68 b9 00 00 00       	push   $0xb9
  jmp alltraps
801072aa:	e9 06 f0 ff ff       	jmp    801062b5 <alltraps>

801072af <vector186>:
.globl vector186
vector186:
  pushl $0
801072af:	6a 00                	push   $0x0
  pushl $186
801072b1:	68 ba 00 00 00       	push   $0xba
  jmp alltraps
801072b6:	e9 fa ef ff ff       	jmp    801062b5 <alltraps>

801072bb <vector187>:
.globl vector187
vector187:
  pushl $0
801072bb:	6a 00                	push   $0x0
  pushl $187
801072bd:	68 bb 00 00 00       	push   $0xbb
  jmp alltraps
801072c2:	e9 ee ef ff ff       	jmp    801062b5 <alltraps>

801072c7 <vector188>:
.globl vector188
vector188:
  pushl $0
801072c7:	6a 00                	push   $0x0
  pushl $188
801072c9:	68 bc 00 00 00       	push   $0xbc
  jmp alltraps
801072ce:	e9 e2 ef ff ff       	jmp    801062b5 <alltraps>

801072d3 <vector189>:
.globl vector189
vector189:
  pushl $0
801072d3:	6a 00                	push   $0x0
  pushl $189
801072d5:	68 bd 00 00 00       	push   $0xbd
  jmp alltraps
801072da:	e9 d6 ef ff ff       	jmp    801062b5 <alltraps>

801072df <vector190>:
.globl vector190
vector190:
  pushl $0
801072df:	6a 00                	push   $0x0
  pushl $190
801072e1:	68 be 00 00 00       	push   $0xbe
  jmp alltraps
801072e6:	e9 ca ef ff ff       	jmp    801062b5 <alltraps>

801072eb <vector191>:
.globl vector191
vector191:
  pushl $0
801072eb:	6a 00                	push   $0x0
  pushl $191
801072ed:	68 bf 00 00 00       	push   $0xbf
  jmp alltraps
801072f2:	e9 be ef ff ff       	jmp    801062b5 <alltraps>

801072f7 <vector192>:
.globl vector192
vector192:
  pushl $0
801072f7:	6a 00                	push   $0x0
  pushl $192
801072f9:	68 c0 00 00 00       	push   $0xc0
  jmp alltraps
801072fe:	e9 b2 ef ff ff       	jmp    801062b5 <alltraps>

80107303 <vector193>:
.globl vector193
vector193:
  pushl $0
80107303:	6a 00                	push   $0x0
  pushl $193
80107305:	68 c1 00 00 00       	push   $0xc1
  jmp alltraps
8010730a:	e9 a6 ef ff ff       	jmp    801062b5 <alltraps>

8010730f <vector194>:
.globl vector194
vector194:
  pushl $0
8010730f:	6a 00                	push   $0x0
  pushl $194
80107311:	68 c2 00 00 00       	push   $0xc2
  jmp alltraps
80107316:	e9 9a ef ff ff       	jmp    801062b5 <alltraps>

8010731b <vector195>:
.globl vector195
vector195:
  pushl $0
8010731b:	6a 00                	push   $0x0
  pushl $195
8010731d:	68 c3 00 00 00       	push   $0xc3
  jmp alltraps
80107322:	e9 8e ef ff ff       	jmp    801062b5 <alltraps>

80107327 <vector196>:
.globl vector196
vector196:
  pushl $0
80107327:	6a 00                	push   $0x0
  pushl $196
80107329:	68 c4 00 00 00       	push   $0xc4
  jmp alltraps
8010732e:	e9 82 ef ff ff       	jmp    801062b5 <alltraps>

80107333 <vector197>:
.globl vector197
vector197:
  pushl $0
80107333:	6a 00                	push   $0x0
  pushl $197
80107335:	68 c5 00 00 00       	push   $0xc5
  jmp alltraps
8010733a:	e9 76 ef ff ff       	jmp    801062b5 <alltraps>

8010733f <vector198>:
.globl vector198
vector198:
  pushl $0
8010733f:	6a 00                	push   $0x0
  pushl $198
80107341:	68 c6 00 00 00       	push   $0xc6
  jmp alltraps
80107346:	e9 6a ef ff ff       	jmp    801062b5 <alltraps>

8010734b <vector199>:
.globl vector199
vector199:
  pushl $0
8010734b:	6a 00                	push   $0x0
  pushl $199
8010734d:	68 c7 00 00 00       	push   $0xc7
  jmp alltraps
80107352:	e9 5e ef ff ff       	jmp    801062b5 <alltraps>

80107357 <vector200>:
.globl vector200
vector200:
  pushl $0
80107357:	6a 00                	push   $0x0
  pushl $200
80107359:	68 c8 00 00 00       	push   $0xc8
  jmp alltraps
8010735e:	e9 52 ef ff ff       	jmp    801062b5 <alltraps>

80107363 <vector201>:
.globl vector201
vector201:
  pushl $0
80107363:	6a 00                	push   $0x0
  pushl $201
80107365:	68 c9 00 00 00       	push   $0xc9
  jmp alltraps
8010736a:	e9 46 ef ff ff       	jmp    801062b5 <alltraps>

8010736f <vector202>:
.globl vector202
vector202:
  pushl $0
8010736f:	6a 00                	push   $0x0
  pushl $202
80107371:	68 ca 00 00 00       	push   $0xca
  jmp alltraps
80107376:	e9 3a ef ff ff       	jmp    801062b5 <alltraps>

8010737b <vector203>:
.globl vector203
vector203:
  pushl $0
8010737b:	6a 00                	push   $0x0
  pushl $203
8010737d:	68 cb 00 00 00       	push   $0xcb
  jmp alltraps
80107382:	e9 2e ef ff ff       	jmp    801062b5 <alltraps>

80107387 <vector204>:
.globl vector204
vector204:
  pushl $0
80107387:	6a 00                	push   $0x0
  pushl $204
80107389:	68 cc 00 00 00       	push   $0xcc
  jmp alltraps
8010738e:	e9 22 ef ff ff       	jmp    801062b5 <alltraps>

80107393 <vector205>:
.globl vector205
vector205:
  pushl $0
80107393:	6a 00                	push   $0x0
  pushl $205
80107395:	68 cd 00 00 00       	push   $0xcd
  jmp alltraps
8010739a:	e9 16 ef ff ff       	jmp    801062b5 <alltraps>

8010739f <vector206>:
.globl vector206
vector206:
  pushl $0
8010739f:	6a 00                	push   $0x0
  pushl $206
801073a1:	68 ce 00 00 00       	push   $0xce
  jmp alltraps
801073a6:	e9 0a ef ff ff       	jmp    801062b5 <alltraps>

801073ab <vector207>:
.globl vector207
vector207:
  pushl $0
801073ab:	6a 00                	push   $0x0
  pushl $207
801073ad:	68 cf 00 00 00       	push   $0xcf
  jmp alltraps
801073b2:	e9 fe ee ff ff       	jmp    801062b5 <alltraps>

801073b7 <vector208>:
.globl vector208
vector208:
  pushl $0
801073b7:	6a 00                	push   $0x0
  pushl $208
801073b9:	68 d0 00 00 00       	push   $0xd0
  jmp alltraps
801073be:	e9 f2 ee ff ff       	jmp    801062b5 <alltraps>

801073c3 <vector209>:
.globl vector209
vector209:
  pushl $0
801073c3:	6a 00                	push   $0x0
  pushl $209
801073c5:	68 d1 00 00 00       	push   $0xd1
  jmp alltraps
801073ca:	e9 e6 ee ff ff       	jmp    801062b5 <alltraps>

801073cf <vector210>:
.globl vector210
vector210:
  pushl $0
801073cf:	6a 00                	push   $0x0
  pushl $210
801073d1:	68 d2 00 00 00       	push   $0xd2
  jmp alltraps
801073d6:	e9 da ee ff ff       	jmp    801062b5 <alltraps>

801073db <vector211>:
.globl vector211
vector211:
  pushl $0
801073db:	6a 00                	push   $0x0
  pushl $211
801073dd:	68 d3 00 00 00       	push   $0xd3
  jmp alltraps
801073e2:	e9 ce ee ff ff       	jmp    801062b5 <alltraps>

801073e7 <vector212>:
.globl vector212
vector212:
  pushl $0
801073e7:	6a 00                	push   $0x0
  pushl $212
801073e9:	68 d4 00 00 00       	push   $0xd4
  jmp alltraps
801073ee:	e9 c2 ee ff ff       	jmp    801062b5 <alltraps>

801073f3 <vector213>:
.globl vector213
vector213:
  pushl $0
801073f3:	6a 00                	push   $0x0
  pushl $213
801073f5:	68 d5 00 00 00       	push   $0xd5
  jmp alltraps
801073fa:	e9 b6 ee ff ff       	jmp    801062b5 <alltraps>

801073ff <vector214>:
.globl vector214
vector214:
  pushl $0
801073ff:	6a 00                	push   $0x0
  pushl $214
80107401:	68 d6 00 00 00       	push   $0xd6
  jmp alltraps
80107406:	e9 aa ee ff ff       	jmp    801062b5 <alltraps>

8010740b <vector215>:
.globl vector215
vector215:
  pushl $0
8010740b:	6a 00                	push   $0x0
  pushl $215
8010740d:	68 d7 00 00 00       	push   $0xd7
  jmp alltraps
80107412:	e9 9e ee ff ff       	jmp    801062b5 <alltraps>

80107417 <vector216>:
.globl vector216
vector216:
  pushl $0
80107417:	6a 00                	push   $0x0
  pushl $216
80107419:	68 d8 00 00 00       	push   $0xd8
  jmp alltraps
8010741e:	e9 92 ee ff ff       	jmp    801062b5 <alltraps>

80107423 <vector217>:
.globl vector217
vector217:
  pushl $0
80107423:	6a 00                	push   $0x0
  pushl $217
80107425:	68 d9 00 00 00       	push   $0xd9
  jmp alltraps
8010742a:	e9 86 ee ff ff       	jmp    801062b5 <alltraps>

8010742f <vector218>:
.globl vector218
vector218:
  pushl $0
8010742f:	6a 00                	push   $0x0
  pushl $218
80107431:	68 da 00 00 00       	push   $0xda
  jmp alltraps
80107436:	e9 7a ee ff ff       	jmp    801062b5 <alltraps>

8010743b <vector219>:
.globl vector219
vector219:
  pushl $0
8010743b:	6a 00                	push   $0x0
  pushl $219
8010743d:	68 db 00 00 00       	push   $0xdb
  jmp alltraps
80107442:	e9 6e ee ff ff       	jmp    801062b5 <alltraps>

80107447 <vector220>:
.globl vector220
vector220:
  pushl $0
80107447:	6a 00                	push   $0x0
  pushl $220
80107449:	68 dc 00 00 00       	push   $0xdc
  jmp alltraps
8010744e:	e9 62 ee ff ff       	jmp    801062b5 <alltraps>

80107453 <vector221>:
.globl vector221
vector221:
  pushl $0
80107453:	6a 00                	push   $0x0
  pushl $221
80107455:	68 dd 00 00 00       	push   $0xdd
  jmp alltraps
8010745a:	e9 56 ee ff ff       	jmp    801062b5 <alltraps>

8010745f <vector222>:
.globl vector222
vector222:
  pushl $0
8010745f:	6a 00                	push   $0x0
  pushl $222
80107461:	68 de 00 00 00       	push   $0xde
  jmp alltraps
80107466:	e9 4a ee ff ff       	jmp    801062b5 <alltraps>

8010746b <vector223>:
.globl vector223
vector223:
  pushl $0
8010746b:	6a 00                	push   $0x0
  pushl $223
8010746d:	68 df 00 00 00       	push   $0xdf
  jmp alltraps
80107472:	e9 3e ee ff ff       	jmp    801062b5 <alltraps>

80107477 <vector224>:
.globl vector224
vector224:
  pushl $0
80107477:	6a 00                	push   $0x0
  pushl $224
80107479:	68 e0 00 00 00       	push   $0xe0
  jmp alltraps
8010747e:	e9 32 ee ff ff       	jmp    801062b5 <alltraps>

80107483 <vector225>:
.globl vector225
vector225:
  pushl $0
80107483:	6a 00                	push   $0x0
  pushl $225
80107485:	68 e1 00 00 00       	push   $0xe1
  jmp alltraps
8010748a:	e9 26 ee ff ff       	jmp    801062b5 <alltraps>

8010748f <vector226>:
.globl vector226
vector226:
  pushl $0
8010748f:	6a 00                	push   $0x0
  pushl $226
80107491:	68 e2 00 00 00       	push   $0xe2
  jmp alltraps
80107496:	e9 1a ee ff ff       	jmp    801062b5 <alltraps>

8010749b <vector227>:
.globl vector227
vector227:
  pushl $0
8010749b:	6a 00                	push   $0x0
  pushl $227
8010749d:	68 e3 00 00 00       	push   $0xe3
  jmp alltraps
801074a2:	e9 0e ee ff ff       	jmp    801062b5 <alltraps>

801074a7 <vector228>:
.globl vector228
vector228:
  pushl $0
801074a7:	6a 00                	push   $0x0
  pushl $228
801074a9:	68 e4 00 00 00       	push   $0xe4
  jmp alltraps
801074ae:	e9 02 ee ff ff       	jmp    801062b5 <alltraps>

801074b3 <vector229>:
.globl vector229
vector229:
  pushl $0
801074b3:	6a 00                	push   $0x0
  pushl $229
801074b5:	68 e5 00 00 00       	push   $0xe5
  jmp alltraps
801074ba:	e9 f6 ed ff ff       	jmp    801062b5 <alltraps>

801074bf <vector230>:
.globl vector230
vector230:
  pushl $0
801074bf:	6a 00                	push   $0x0
  pushl $230
801074c1:	68 e6 00 00 00       	push   $0xe6
  jmp alltraps
801074c6:	e9 ea ed ff ff       	jmp    801062b5 <alltraps>

801074cb <vector231>:
.globl vector231
vector231:
  pushl $0
801074cb:	6a 00                	push   $0x0
  pushl $231
801074cd:	68 e7 00 00 00       	push   $0xe7
  jmp alltraps
801074d2:	e9 de ed ff ff       	jmp    801062b5 <alltraps>

801074d7 <vector232>:
.globl vector232
vector232:
  pushl $0
801074d7:	6a 00                	push   $0x0
  pushl $232
801074d9:	68 e8 00 00 00       	push   $0xe8
  jmp alltraps
801074de:	e9 d2 ed ff ff       	jmp    801062b5 <alltraps>

801074e3 <vector233>:
.globl vector233
vector233:
  pushl $0
801074e3:	6a 00                	push   $0x0
  pushl $233
801074e5:	68 e9 00 00 00       	push   $0xe9
  jmp alltraps
801074ea:	e9 c6 ed ff ff       	jmp    801062b5 <alltraps>

801074ef <vector234>:
.globl vector234
vector234:
  pushl $0
801074ef:	6a 00                	push   $0x0
  pushl $234
801074f1:	68 ea 00 00 00       	push   $0xea
  jmp alltraps
801074f6:	e9 ba ed ff ff       	jmp    801062b5 <alltraps>

801074fb <vector235>:
.globl vector235
vector235:
  pushl $0
801074fb:	6a 00                	push   $0x0
  pushl $235
801074fd:	68 eb 00 00 00       	push   $0xeb
  jmp alltraps
80107502:	e9 ae ed ff ff       	jmp    801062b5 <alltraps>

80107507 <vector236>:
.globl vector236
vector236:
  pushl $0
80107507:	6a 00                	push   $0x0
  pushl $236
80107509:	68 ec 00 00 00       	push   $0xec
  jmp alltraps
8010750e:	e9 a2 ed ff ff       	jmp    801062b5 <alltraps>

80107513 <vector237>:
.globl vector237
vector237:
  pushl $0
80107513:	6a 00                	push   $0x0
  pushl $237
80107515:	68 ed 00 00 00       	push   $0xed
  jmp alltraps
8010751a:	e9 96 ed ff ff       	jmp    801062b5 <alltraps>

8010751f <vector238>:
.globl vector238
vector238:
  pushl $0
8010751f:	6a 00                	push   $0x0
  pushl $238
80107521:	68 ee 00 00 00       	push   $0xee
  jmp alltraps
80107526:	e9 8a ed ff ff       	jmp    801062b5 <alltraps>

8010752b <vector239>:
.globl vector239
vector239:
  pushl $0
8010752b:	6a 00                	push   $0x0
  pushl $239
8010752d:	68 ef 00 00 00       	push   $0xef
  jmp alltraps
80107532:	e9 7e ed ff ff       	jmp    801062b5 <alltraps>

80107537 <vector240>:
.globl vector240
vector240:
  pushl $0
80107537:	6a 00                	push   $0x0
  pushl $240
80107539:	68 f0 00 00 00       	push   $0xf0
  jmp alltraps
8010753e:	e9 72 ed ff ff       	jmp    801062b5 <alltraps>

80107543 <vector241>:
.globl vector241
vector241:
  pushl $0
80107543:	6a 00                	push   $0x0
  pushl $241
80107545:	68 f1 00 00 00       	push   $0xf1
  jmp alltraps
8010754a:	e9 66 ed ff ff       	jmp    801062b5 <alltraps>

8010754f <vector242>:
.globl vector242
vector242:
  pushl $0
8010754f:	6a 00                	push   $0x0
  pushl $242
80107551:	68 f2 00 00 00       	push   $0xf2
  jmp alltraps
80107556:	e9 5a ed ff ff       	jmp    801062b5 <alltraps>

8010755b <vector243>:
.globl vector243
vector243:
  pushl $0
8010755b:	6a 00                	push   $0x0
  pushl $243
8010755d:	68 f3 00 00 00       	push   $0xf3
  jmp alltraps
80107562:	e9 4e ed ff ff       	jmp    801062b5 <alltraps>

80107567 <vector244>:
.globl vector244
vector244:
  pushl $0
80107567:	6a 00                	push   $0x0
  pushl $244
80107569:	68 f4 00 00 00       	push   $0xf4
  jmp alltraps
8010756e:	e9 42 ed ff ff       	jmp    801062b5 <alltraps>

80107573 <vector245>:
.globl vector245
vector245:
  pushl $0
80107573:	6a 00                	push   $0x0
  pushl $245
80107575:	68 f5 00 00 00       	push   $0xf5
  jmp alltraps
8010757a:	e9 36 ed ff ff       	jmp    801062b5 <alltraps>

8010757f <vector246>:
.globl vector246
vector246:
  pushl $0
8010757f:	6a 00                	push   $0x0
  pushl $246
80107581:	68 f6 00 00 00       	push   $0xf6
  jmp alltraps
80107586:	e9 2a ed ff ff       	jmp    801062b5 <alltraps>

8010758b <vector247>:
.globl vector247
vector247:
  pushl $0
8010758b:	6a 00                	push   $0x0
  pushl $247
8010758d:	68 f7 00 00 00       	push   $0xf7
  jmp alltraps
80107592:	e9 1e ed ff ff       	jmp    801062b5 <alltraps>

80107597 <vector248>:
.globl vector248
vector248:
  pushl $0
80107597:	6a 00                	push   $0x0
  pushl $248
80107599:	68 f8 00 00 00       	push   $0xf8
  jmp alltraps
8010759e:	e9 12 ed ff ff       	jmp    801062b5 <alltraps>

801075a3 <vector249>:
.globl vector249
vector249:
  pushl $0
801075a3:	6a 00                	push   $0x0
  pushl $249
801075a5:	68 f9 00 00 00       	push   $0xf9
  jmp alltraps
801075aa:	e9 06 ed ff ff       	jmp    801062b5 <alltraps>

801075af <vector250>:
.globl vector250
vector250:
  pushl $0
801075af:	6a 00                	push   $0x0
  pushl $250
801075b1:	68 fa 00 00 00       	push   $0xfa
  jmp alltraps
801075b6:	e9 fa ec ff ff       	jmp    801062b5 <alltraps>

801075bb <vector251>:
.globl vector251
vector251:
  pushl $0
801075bb:	6a 00                	push   $0x0
  pushl $251
801075bd:	68 fb 00 00 00       	push   $0xfb
  jmp alltraps
801075c2:	e9 ee ec ff ff       	jmp    801062b5 <alltraps>

801075c7 <vector252>:
.globl vector252
vector252:
  pushl $0
801075c7:	6a 00                	push   $0x0
  pushl $252
801075c9:	68 fc 00 00 00       	push   $0xfc
  jmp alltraps
801075ce:	e9 e2 ec ff ff       	jmp    801062b5 <alltraps>

801075d3 <vector253>:
.globl vector253
vector253:
  pushl $0
801075d3:	6a 00                	push   $0x0
  pushl $253
801075d5:	68 fd 00 00 00       	push   $0xfd
  jmp alltraps
801075da:	e9 d6 ec ff ff       	jmp    801062b5 <alltraps>

801075df <vector254>:
.globl vector254
vector254:
  pushl $0
801075df:	6a 00                	push   $0x0
  pushl $254
801075e1:	68 fe 00 00 00       	push   $0xfe
  jmp alltraps
801075e6:	e9 ca ec ff ff       	jmp    801062b5 <alltraps>

801075eb <vector255>:
.globl vector255
vector255:
  pushl $0
801075eb:	6a 00                	push   $0x0
  pushl $255
801075ed:	68 ff 00 00 00       	push   $0xff
  jmp alltraps
801075f2:	e9 be ec ff ff       	jmp    801062b5 <alltraps>
801075f7:	66 90                	xchg   %ax,%ax
801075f9:	66 90                	xchg   %ax,%ax
801075fb:	66 90                	xchg   %ax,%ax
801075fd:	66 90                	xchg   %ax,%ax
801075ff:	90                   	nop

80107600 <deallocuvm.part.0>:
// Deallocate user pages to bring the process size from oldsz to
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
int
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
80107600:	55                   	push   %ebp
80107601:	89 e5                	mov    %esp,%ebp
80107603:	57                   	push   %edi
80107604:	56                   	push   %esi
80107605:	53                   	push   %ebx
  uint a, pa;

  if(newsz >= oldsz)
    return oldsz;

  a = PGROUNDUP(newsz);
80107606:	8d 99 ff 0f 00 00    	lea    0xfff(%ecx),%ebx
8010760c:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
80107612:	83 ec 1c             	sub    $0x1c,%esp
80107615:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  for(; a  < oldsz; a += PGSIZE){
80107618:	39 d3                	cmp    %edx,%ebx
8010761a:	73 49                	jae    80107665 <deallocuvm.part.0+0x65>
8010761c:	89 c7                	mov    %eax,%edi
8010761e:	eb 0c                	jmp    8010762c <deallocuvm.part.0+0x2c>
    pte = walkpgdir(pgdir, (char*)a, 0);
    if(!pte)
      a = PGADDR(PDX(a) + 1, 0, 0) - PGSIZE;
80107620:	83 c0 01             	add    $0x1,%eax
80107623:	c1 e0 16             	shl    $0x16,%eax
80107626:	89 c3                	mov    %eax,%ebx
  for(; a  < oldsz; a += PGSIZE){
80107628:	39 da                	cmp    %ebx,%edx
8010762a:	76 39                	jbe    80107665 <deallocuvm.part.0+0x65>
  pde = &pgdir[PDX(va)];
8010762c:	89 d8                	mov    %ebx,%eax
8010762e:	c1 e8 16             	shr    $0x16,%eax
  if(*pde & PTE_P){
80107631:	8b 0c 87             	mov    (%edi,%eax,4),%ecx
80107634:	f6 c1 01             	test   $0x1,%cl
80107637:	74 e7                	je     80107620 <deallocuvm.part.0+0x20>
  return &pgtab[PTX(va)];
80107639:	89 de                	mov    %ebx,%esi
    pgtab = (pte_t*)P2V(PTE_ADDR(*pde));
8010763b:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
  return &pgtab[PTX(va)];
80107641:	c1 ee 0a             	shr    $0xa,%esi
80107644:	81 e6 fc 0f 00 00    	and    $0xffc,%esi
8010764a:	8d b4 31 00 00 00 80 	lea    -0x80000000(%ecx,%esi,1),%esi
    if(!pte)
80107651:	85 f6                	test   %esi,%esi
80107653:	74 cb                	je     80107620 <deallocuvm.part.0+0x20>
    else if((*pte & PTE_P) != 0){
80107655:	8b 06                	mov    (%esi),%eax
80107657:	a8 01                	test   $0x1,%al
80107659:	75 15                	jne    80107670 <deallocuvm.part.0+0x70>
  for(; a  < oldsz; a += PGSIZE){
8010765b:	81 c3 00 10 00 00    	add    $0x1000,%ebx
80107661:	39 da                	cmp    %ebx,%edx
80107663:	77 c7                	ja     8010762c <deallocuvm.part.0+0x2c>
      kfree(v);
      *pte = 0;
    }
  }
  return newsz;
}
80107665:	8b 45 e0             	mov    -0x20(%ebp),%eax
80107668:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010766b:	5b                   	pop    %ebx
8010766c:	5e                   	pop    %esi
8010766d:	5f                   	pop    %edi
8010766e:	5d                   	pop    %ebp
8010766f:	c3                   	ret    
      if(pa == 0)
80107670:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107675:	74 25                	je     8010769c <deallocuvm.part.0+0x9c>
      kfree(v);
80107677:	83 ec 0c             	sub    $0xc,%esp
      char *v = P2V(pa);
8010767a:	05 00 00 00 80       	add    $0x80000000,%eax
8010767f:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  for(; a  < oldsz; a += PGSIZE){
80107682:	81 c3 00 10 00 00    	add    $0x1000,%ebx
      kfree(v);
80107688:	50                   	push   %eax
80107689:	e8 a2 ae ff ff       	call   80102530 <kfree>
      *pte = 0;
8010768e:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  for(; a  < oldsz; a += PGSIZE){
80107694:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80107697:	83 c4 10             	add    $0x10,%esp
8010769a:	eb 8c                	jmp    80107628 <deallocuvm.part.0+0x28>
        panic("kfree");
8010769c:	83 ec 0c             	sub    $0xc,%esp
8010769f:	68 06 83 10 80       	push   $0x80108306
801076a4:	e8 d7 8c ff ff       	call   80100380 <panic>
801076a9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

801076b0 <seginit>:
{
801076b0:	55                   	push   %ebp
801076b1:	89 e5                	mov    %esp,%ebp
801076b3:	83 ec 18             	sub    $0x18,%esp
  c = &cpus[cpuid()];
801076b6:	e8 15 c3 ff ff       	call   801039d0 <cpuid>
  pd[0] = size-1;
801076bb:	ba 2f 00 00 00       	mov    $0x2f,%edx
801076c0:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
801076c6:	66 89 55 f2          	mov    %dx,-0xe(%ebp)
  c->gdt[SEG_KCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, 0);
801076ca:	c7 80 18 28 21 80 ff 	movl   $0xffff,-0x7fded7e8(%eax)
801076d1:	ff 00 00 
801076d4:	c7 80 1c 28 21 80 00 	movl   $0xcf9a00,-0x7fded7e4(%eax)
801076db:	9a cf 00 
  c->gdt[SEG_KDATA] = SEG(STA_W, 0, 0xffffffff, 0);
801076de:	c7 80 20 28 21 80 ff 	movl   $0xffff,-0x7fded7e0(%eax)
801076e5:	ff 00 00 
801076e8:	c7 80 24 28 21 80 00 	movl   $0xcf9200,-0x7fded7dc(%eax)
801076ef:	92 cf 00 
  c->gdt[SEG_UCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, DPL_USER);
801076f2:	c7 80 28 28 21 80 ff 	movl   $0xffff,-0x7fded7d8(%eax)
801076f9:	ff 00 00 
801076fc:	c7 80 2c 28 21 80 00 	movl   $0xcffa00,-0x7fded7d4(%eax)
80107703:	fa cf 00 
  c->gdt[SEG_UDATA] = SEG(STA_W, 0, 0xffffffff, DPL_USER);
80107706:	c7 80 30 28 21 80 ff 	movl   $0xffff,-0x7fded7d0(%eax)
8010770d:	ff 00 00 
80107710:	c7 80 34 28 21 80 00 	movl   $0xcff200,-0x7fded7cc(%eax)
80107717:	f2 cf 00 
  lgdt(c->gdt, sizeof(c->gdt));
8010771a:	05 10 28 21 80       	add    $0x80212810,%eax
  pd[1] = (uint)p;
8010771f:	66 89 45 f4          	mov    %ax,-0xc(%ebp)
  pd[2] = (uint)p >> 16;
80107723:	c1 e8 10             	shr    $0x10,%eax
80107726:	66 89 45 f6          	mov    %ax,-0xa(%ebp)
  asm volatile("lgdt (%0)" : : "r" (pd));
8010772a:	8d 45 f2             	lea    -0xe(%ebp),%eax
8010772d:	0f 01 10             	lgdtl  (%eax)
}
80107730:	c9                   	leave  
80107731:	c3                   	ret    
80107732:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80107739:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

80107740 <walkpgdir>:
{
80107740:	55                   	push   %ebp
80107741:	89 e5                	mov    %esp,%ebp
80107743:	57                   	push   %edi
80107744:	56                   	push   %esi
80107745:	53                   	push   %ebx
80107746:	83 ec 0c             	sub    $0xc,%esp
80107749:	8b 7d 0c             	mov    0xc(%ebp),%edi
  pde = &pgdir[PDX(va)];
8010774c:	8b 55 08             	mov    0x8(%ebp),%edx
8010774f:	89 fe                	mov    %edi,%esi
80107751:	c1 ee 16             	shr    $0x16,%esi
80107754:	8d 34 b2             	lea    (%edx,%esi,4),%esi
  if(*pde & PTE_P){
80107757:	8b 1e                	mov    (%esi),%ebx
80107759:	f6 c3 01             	test   $0x1,%bl
8010775c:	74 22                	je     80107780 <walkpgdir+0x40>
    pgtab = (pte_t*)P2V(PTE_ADDR(*pde));
8010775e:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
80107764:	81 c3 00 00 00 80    	add    $0x80000000,%ebx
  return &pgtab[PTX(va)];
8010776a:	89 f8                	mov    %edi,%eax
}
8010776c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  return &pgtab[PTX(va)];
8010776f:	c1 e8 0a             	shr    $0xa,%eax
80107772:	25 fc 0f 00 00       	and    $0xffc,%eax
80107777:	01 d8                	add    %ebx,%eax
}
80107779:	5b                   	pop    %ebx
8010777a:	5e                   	pop    %esi
8010777b:	5f                   	pop    %edi
8010777c:	5d                   	pop    %ebp
8010777d:	c3                   	ret    
8010777e:	66 90                	xchg   %ax,%ax
    if(!alloc || (pgtab = (pte_t*)kalloc()) == 0)
80107780:	8b 45 10             	mov    0x10(%ebp),%eax
80107783:	85 c0                	test   %eax,%eax
80107785:	74 31                	je     801077b8 <walkpgdir+0x78>
80107787:	e8 64 af ff ff       	call   801026f0 <kalloc>
8010778c:	89 c3                	mov    %eax,%ebx
8010778e:	85 c0                	test   %eax,%eax
80107790:	74 26                	je     801077b8 <walkpgdir+0x78>
    memset(pgtab, 0, PGSIZE);
80107792:	83 ec 04             	sub    $0x4,%esp
80107795:	68 00 10 00 00       	push   $0x1000
8010779a:	6a 00                	push   $0x0
8010779c:	50                   	push   %eax
8010779d:	e8 be d4 ff ff       	call   80104c60 <memset>
    *pde = V2P(pgtab) | PTE_P | PTE_W | PTE_U;
801077a2:	8d 83 00 00 00 80    	lea    -0x80000000(%ebx),%eax
801077a8:	83 c4 10             	add    $0x10,%esp
801077ab:	83 c8 07             	or     $0x7,%eax
801077ae:	89 06                	mov    %eax,(%esi)
801077b0:	eb b8                	jmp    8010776a <walkpgdir+0x2a>
801077b2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
}
801077b8:	8d 65 f4             	lea    -0xc(%ebp),%esp
      return 0;
801077bb:	31 c0                	xor    %eax,%eax
}
801077bd:	5b                   	pop    %ebx
801077be:	5e                   	pop    %esi
801077bf:	5f                   	pop    %edi
801077c0:	5d                   	pop    %ebp
801077c1:	c3                   	ret    
801077c2:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801077c9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

801077d0 <mappages>:
{
801077d0:	55                   	push   %ebp
801077d1:	89 e5                	mov    %esp,%ebp
801077d3:	57                   	push   %edi
801077d4:	56                   	push   %esi
801077d5:	53                   	push   %ebx
801077d6:	83 ec 1c             	sub    $0x1c,%esp
801077d9:	8b 45 0c             	mov    0xc(%ebp),%eax
  last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
801077dc:	8b 55 10             	mov    0x10(%ebp),%edx
  a = (char*)PGROUNDDOWN((uint)va);
801077df:	89 c3                	mov    %eax,%ebx
  last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
801077e1:	8d 44 10 ff          	lea    -0x1(%eax,%edx,1),%eax
801077e5:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  a = (char*)PGROUNDDOWN((uint)va);
801077ea:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
801077f0:	89 45 e0             	mov    %eax,-0x20(%ebp)
801077f3:	8b 45 14             	mov    0x14(%ebp),%eax
801077f6:	29 d8                	sub    %ebx,%eax
801077f8:	89 45 e4             	mov    %eax,-0x1c(%ebp)
801077fb:	eb 3a                	jmp    80107837 <mappages+0x67>
801077fd:	8d 76 00             	lea    0x0(%esi),%esi
  return &pgtab[PTX(va)];
80107800:	89 da                	mov    %ebx,%edx
    pgtab = (pte_t*)P2V(PTE_ADDR(*pde));
80107802:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  return &pgtab[PTX(va)];
80107807:	c1 ea 0a             	shr    $0xa,%edx
8010780a:	81 e2 fc 0f 00 00    	and    $0xffc,%edx
80107810:	8d 84 10 00 00 00 80 	lea    -0x80000000(%eax,%edx,1),%eax
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
80107817:	85 c0                	test   %eax,%eax
80107819:	74 75                	je     80107890 <mappages+0xc0>
    if(*pte & PTE_P)
8010781b:	f6 00 01             	testb  $0x1,(%eax)
8010781e:	0f 85 86 00 00 00    	jne    801078aa <mappages+0xda>
    *pte = pa | perm | PTE_P;
80107824:	0b 75 18             	or     0x18(%ebp),%esi
80107827:	83 ce 01             	or     $0x1,%esi
8010782a:	89 30                	mov    %esi,(%eax)
    if(a == last)
8010782c:	3b 5d e0             	cmp    -0x20(%ebp),%ebx
8010782f:	74 6f                	je     801078a0 <mappages+0xd0>
    a += PGSIZE;
80107831:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  for(;;){
80107837:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  pde = &pgdir[PDX(va)];
8010783a:	8b 4d 08             	mov    0x8(%ebp),%ecx
8010783d:	8d 34 18             	lea    (%eax,%ebx,1),%esi
80107840:	89 d8                	mov    %ebx,%eax
80107842:	c1 e8 16             	shr    $0x16,%eax
80107845:	8d 3c 81             	lea    (%ecx,%eax,4),%edi
  if(*pde & PTE_P){
80107848:	8b 07                	mov    (%edi),%eax
8010784a:	a8 01                	test   $0x1,%al
8010784c:	75 b2                	jne    80107800 <mappages+0x30>
    if(!alloc || (pgtab = (pte_t*)kalloc()) == 0)
8010784e:	e8 9d ae ff ff       	call   801026f0 <kalloc>
80107853:	85 c0                	test   %eax,%eax
80107855:	74 39                	je     80107890 <mappages+0xc0>
    memset(pgtab, 0, PGSIZE);
80107857:	83 ec 04             	sub    $0x4,%esp
8010785a:	89 45 dc             	mov    %eax,-0x24(%ebp)
8010785d:	68 00 10 00 00       	push   $0x1000
80107862:	6a 00                	push   $0x0
80107864:	50                   	push   %eax
80107865:	e8 f6 d3 ff ff       	call   80104c60 <memset>
    *pde = V2P(pgtab) | PTE_P | PTE_W | PTE_U;
8010786a:	8b 55 dc             	mov    -0x24(%ebp),%edx
  return &pgtab[PTX(va)];
8010786d:	83 c4 10             	add    $0x10,%esp
    *pde = V2P(pgtab) | PTE_P | PTE_W | PTE_U;
80107870:	8d 82 00 00 00 80    	lea    -0x80000000(%edx),%eax
80107876:	83 c8 07             	or     $0x7,%eax
80107879:	89 07                	mov    %eax,(%edi)
  return &pgtab[PTX(va)];
8010787b:	89 d8                	mov    %ebx,%eax
8010787d:	c1 e8 0a             	shr    $0xa,%eax
80107880:	25 fc 0f 00 00       	and    $0xffc,%eax
80107885:	01 d0                	add    %edx,%eax
80107887:	eb 92                	jmp    8010781b <mappages+0x4b>
80107889:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
}
80107890:	8d 65 f4             	lea    -0xc(%ebp),%esp
      return -1;
80107893:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80107898:	5b                   	pop    %ebx
80107899:	5e                   	pop    %esi
8010789a:	5f                   	pop    %edi
8010789b:	5d                   	pop    %ebp
8010789c:	c3                   	ret    
8010789d:	8d 76 00             	lea    0x0(%esi),%esi
801078a0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  return 0;
801078a3:	31 c0                	xor    %eax,%eax
}
801078a5:	5b                   	pop    %ebx
801078a6:	5e                   	pop    %esi
801078a7:	5f                   	pop    %edi
801078a8:	5d                   	pop    %ebp
801078a9:	c3                   	ret    
      panic("remap");
801078aa:	83 ec 0c             	sub    $0xc,%esp
801078ad:	68 4c 8c 10 80       	push   $0x80108c4c
801078b2:	e8 c9 8a ff ff       	call   80100380 <panic>
801078b7:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801078be:	66 90                	xchg   %ax,%ax

801078c0 <switchkvm>:
  lcr3(V2P(kpgdir));   // switch to the kernel page table
801078c0:	a1 04 a6 21 80       	mov    0x8021a604,%eax
801078c5:	05 00 00 00 80       	add    $0x80000000,%eax
  asm volatile("movl %0,%%cr3" : : "r" (val));
801078ca:	0f 22 d8             	mov    %eax,%cr3
}
801078cd:	c3                   	ret    
801078ce:	66 90                	xchg   %ax,%ax

801078d0 <switchuvm>:
{
801078d0:	55                   	push   %ebp
801078d1:	89 e5                	mov    %esp,%ebp
801078d3:	57                   	push   %edi
801078d4:	56                   	push   %esi
801078d5:	53                   	push   %ebx
801078d6:	83 ec 1c             	sub    $0x1c,%esp
801078d9:	8b 75 08             	mov    0x8(%ebp),%esi
  if(p == 0)
801078dc:	85 f6                	test   %esi,%esi
801078de:	0f 84 cb 00 00 00    	je     801079af <switchuvm+0xdf>
  if(p->kstack == 0)
801078e4:	8b 46 08             	mov    0x8(%esi),%eax
801078e7:	85 c0                	test   %eax,%eax
801078e9:	0f 84 da 00 00 00    	je     801079c9 <switchuvm+0xf9>
  if(p->pgdir == 0)
801078ef:	8b 46 04             	mov    0x4(%esi),%eax
801078f2:	85 c0                	test   %eax,%eax
801078f4:	0f 84 c2 00 00 00    	je     801079bc <switchuvm+0xec>
  pushcli();
801078fa:	e8 51 d1 ff ff       	call   80104a50 <pushcli>
  mycpu()->gdt[SEG_TSS] = SEG16(STS_T32A, &mycpu()->ts,
801078ff:	e8 6c c0 ff ff       	call   80103970 <mycpu>
80107904:	89 c3                	mov    %eax,%ebx
80107906:	e8 65 c0 ff ff       	call   80103970 <mycpu>
8010790b:	89 c7                	mov    %eax,%edi
8010790d:	e8 5e c0 ff ff       	call   80103970 <mycpu>
80107912:	83 c7 08             	add    $0x8,%edi
80107915:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80107918:	e8 53 c0 ff ff       	call   80103970 <mycpu>
8010791d:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
80107920:	ba 67 00 00 00       	mov    $0x67,%edx
80107925:	66 89 bb 9a 00 00 00 	mov    %di,0x9a(%ebx)
8010792c:	83 c0 08             	add    $0x8,%eax
8010792f:	66 89 93 98 00 00 00 	mov    %dx,0x98(%ebx)
  mycpu()->ts.iomb = (ushort) 0xFFFF;
80107936:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  mycpu()->gdt[SEG_TSS] = SEG16(STS_T32A, &mycpu()->ts,
8010793b:	83 c1 08             	add    $0x8,%ecx
8010793e:	c1 e8 18             	shr    $0x18,%eax
80107941:	c1 e9 10             	shr    $0x10,%ecx
80107944:	88 83 9f 00 00 00    	mov    %al,0x9f(%ebx)
8010794a:	88 8b 9c 00 00 00    	mov    %cl,0x9c(%ebx)
80107950:	b9 99 40 00 00       	mov    $0x4099,%ecx
80107955:	66 89 8b 9d 00 00 00 	mov    %cx,0x9d(%ebx)
  mycpu()->ts.ss0 = SEG_KDATA << 3;
8010795c:	bb 10 00 00 00       	mov    $0x10,%ebx
  mycpu()->gdt[SEG_TSS].s = 0;
80107961:	e8 0a c0 ff ff       	call   80103970 <mycpu>
80107966:	80 a0 9d 00 00 00 ef 	andb   $0xef,0x9d(%eax)
  mycpu()->ts.ss0 = SEG_KDATA << 3;
8010796d:	e8 fe bf ff ff       	call   80103970 <mycpu>
80107972:	66 89 58 10          	mov    %bx,0x10(%eax)
  mycpu()->ts.esp0 = (uint)p->kstack + KSTACKSIZE;
80107976:	8b 5e 08             	mov    0x8(%esi),%ebx
80107979:	81 c3 00 10 00 00    	add    $0x1000,%ebx
8010797f:	e8 ec bf ff ff       	call   80103970 <mycpu>
80107984:	89 58 0c             	mov    %ebx,0xc(%eax)
  mycpu()->ts.iomb = (ushort) 0xFFFF;
80107987:	e8 e4 bf ff ff       	call   80103970 <mycpu>
8010798c:	66 89 78 6e          	mov    %di,0x6e(%eax)
  asm volatile("ltr %0" : : "r" (sel));
80107990:	b8 28 00 00 00       	mov    $0x28,%eax
80107995:	0f 00 d8             	ltr    %ax
  lcr3(V2P(p->pgdir));  // switch to process's address space
80107998:	8b 46 04             	mov    0x4(%esi),%eax
8010799b:	05 00 00 00 80       	add    $0x80000000,%eax
  asm volatile("movl %0,%%cr3" : : "r" (val));
801079a0:	0f 22 d8             	mov    %eax,%cr3
}
801079a3:	8d 65 f4             	lea    -0xc(%ebp),%esp
801079a6:	5b                   	pop    %ebx
801079a7:	5e                   	pop    %esi
801079a8:	5f                   	pop    %edi
801079a9:	5d                   	pop    %ebp
  popcli();
801079aa:	e9 f1 d0 ff ff       	jmp    80104aa0 <popcli>
    panic("switchuvm: no process");
801079af:	83 ec 0c             	sub    $0xc,%esp
801079b2:	68 52 8c 10 80       	push   $0x80108c52
801079b7:	e8 c4 89 ff ff       	call   80100380 <panic>
    panic("switchuvm: no pgdir");
801079bc:	83 ec 0c             	sub    $0xc,%esp
801079bf:	68 7d 8c 10 80       	push   $0x80108c7d
801079c4:	e8 b7 89 ff ff       	call   80100380 <panic>
    panic("switchuvm: no kstack");
801079c9:	83 ec 0c             	sub    $0xc,%esp
801079cc:	68 68 8c 10 80       	push   $0x80108c68
801079d1:	e8 aa 89 ff ff       	call   80100380 <panic>
801079d6:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801079dd:	8d 76 00             	lea    0x0(%esi),%esi

801079e0 <inituvm>:
{
801079e0:	55                   	push   %ebp
801079e1:	89 e5                	mov    %esp,%ebp
801079e3:	57                   	push   %edi
801079e4:	56                   	push   %esi
801079e5:	53                   	push   %ebx
801079e6:	83 ec 1c             	sub    $0x1c,%esp
801079e9:	8b 75 10             	mov    0x10(%ebp),%esi
801079ec:	8b 55 08             	mov    0x8(%ebp),%edx
801079ef:	8b 7d 0c             	mov    0xc(%ebp),%edi
  if(sz >= PGSIZE)
801079f2:	81 fe ff 0f 00 00    	cmp    $0xfff,%esi
801079f8:	77 50                	ja     80107a4a <inituvm+0x6a>
801079fa:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  mem = kalloc();
801079fd:	e8 ee ac ff ff       	call   801026f0 <kalloc>
  memset(mem, 0, PGSIZE);
80107a02:	83 ec 04             	sub    $0x4,%esp
80107a05:	68 00 10 00 00       	push   $0x1000
  mem = kalloc();
80107a0a:	89 c3                	mov    %eax,%ebx
  memset(mem, 0, PGSIZE);
80107a0c:	6a 00                	push   $0x0
80107a0e:	50                   	push   %eax
80107a0f:	e8 4c d2 ff ff       	call   80104c60 <memset>
  mappages(pgdir, 0, PGSIZE, V2P(mem), PTE_W|PTE_U);
80107a14:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80107a17:	8d 83 00 00 00 80    	lea    -0x80000000(%ebx),%eax
80107a1d:	c7 04 24 06 00 00 00 	movl   $0x6,(%esp)
80107a24:	50                   	push   %eax
80107a25:	68 00 10 00 00       	push   $0x1000
80107a2a:	6a 00                	push   $0x0
80107a2c:	52                   	push   %edx
80107a2d:	e8 9e fd ff ff       	call   801077d0 <mappages>
  memmove(mem, init, sz);
80107a32:	89 75 10             	mov    %esi,0x10(%ebp)
80107a35:	83 c4 20             	add    $0x20,%esp
80107a38:	89 7d 0c             	mov    %edi,0xc(%ebp)
80107a3b:	89 5d 08             	mov    %ebx,0x8(%ebp)
}
80107a3e:	8d 65 f4             	lea    -0xc(%ebp),%esp
80107a41:	5b                   	pop    %ebx
80107a42:	5e                   	pop    %esi
80107a43:	5f                   	pop    %edi
80107a44:	5d                   	pop    %ebp
  memmove(mem, init, sz);
80107a45:	e9 b6 d2 ff ff       	jmp    80104d00 <memmove>
    panic("inituvm: more than a page");
80107a4a:	83 ec 0c             	sub    $0xc,%esp
80107a4d:	68 91 8c 10 80       	push   $0x80108c91
80107a52:	e8 29 89 ff ff       	call   80100380 <panic>
80107a57:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80107a5e:	66 90                	xchg   %ax,%ax

80107a60 <loaduvm>:
{
80107a60:	55                   	push   %ebp
80107a61:	89 e5                	mov    %esp,%ebp
80107a63:	57                   	push   %edi
80107a64:	56                   	push   %esi
80107a65:	53                   	push   %ebx
80107a66:	83 ec 1c             	sub    $0x1c,%esp
80107a69:	8b 55 0c             	mov    0xc(%ebp),%edx
    if((uint) addr % PGSIZE != 0)
80107a6c:	f7 c2 ff 0f 00 00    	test   $0xfff,%edx
80107a72:	0f 85 e5 00 00 00    	jne    80107b5d <loaduvm+0xfd>
    if (flags & PTE_W)   // Writable flag is typically bit 1 in ELF
80107a78:	8b 45 1c             	mov    0x1c(%ebp),%eax
80107a7b:	83 e0 02             	and    $0x2,%eax
        perm |= PTE_W; // Add write permission if set
80107a7e:	83 f8 01             	cmp    $0x1,%eax
80107a81:	19 c0                	sbb    %eax,%eax
80107a83:	83 e0 fe             	and    $0xfffffffe,%eax
80107a86:	83 c0 06             	add    $0x6,%eax
80107a89:	89 45 d8             	mov    %eax,-0x28(%ebp)
    for(i = 0; i < sz; i += PGSIZE){
80107a8c:	8b 45 18             	mov    0x18(%ebp),%eax
80107a8f:	85 c0                	test   %eax,%eax
80107a91:	0f 84 af 00 00 00    	je     80107b46 <loaduvm+0xe6>
80107a97:	8b 75 18             	mov    0x18(%ebp),%esi
80107a9a:	89 f0                	mov    %esi,%eax
80107a9c:	01 d0                	add    %edx,%eax
80107a9e:	89 45 e0             	mov    %eax,-0x20(%ebp)
        if(readi(ip, P2V(pa), offset + i, n) != n)
80107aa1:	8b 45 14             	mov    0x14(%ebp),%eax
80107aa4:	01 f0                	add    %esi,%eax
80107aa6:	89 45 dc             	mov    %eax,-0x24(%ebp)
80107aa9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  pde = &pgdir[PDX(va)];
80107ab0:	8b 45 e0             	mov    -0x20(%ebp),%eax
  if(*pde & PTE_P){
80107ab3:	8b 4d 08             	mov    0x8(%ebp),%ecx
80107ab6:	29 f0                	sub    %esi,%eax
  pde = &pgdir[PDX(va)];
80107ab8:	89 c2                	mov    %eax,%edx
80107aba:	c1 ea 16             	shr    $0x16,%edx
  if(*pde & PTE_P){
80107abd:	8b 14 91             	mov    (%ecx,%edx,4),%edx
80107ac0:	f6 c2 01             	test   $0x1,%dl
80107ac3:	75 13                	jne    80107ad8 <loaduvm+0x78>
            panic("loaduvm: address should exist");
80107ac5:	83 ec 0c             	sub    $0xc,%esp
80107ac8:	68 ab 8c 10 80       	push   $0x80108cab
80107acd:	e8 ae 88 ff ff       	call   80100380 <panic>
80107ad2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  return &pgtab[PTX(va)];
80107ad8:	c1 e8 0a             	shr    $0xa,%eax
    pgtab = (pte_t*)P2V(PTE_ADDR(*pde));
80107adb:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
  return &pgtab[PTX(va)];
80107ae1:	25 fc 0f 00 00       	and    $0xffc,%eax
80107ae6:	8d bc 02 00 00 00 80 	lea    -0x80000000(%edx,%eax,1),%edi
        if((pte = walkpgdir(pgdir, addr + i, 0)) == 0)
80107aed:	85 ff                	test   %edi,%edi
80107aef:	74 d4                	je     80107ac5 <loaduvm+0x65>
        pa = PTE_ADDR(*pte);
80107af1:	8b 1f                	mov    (%edi),%ebx
        if(readi(ip, P2V(pa), offset + i, n) != n)
80107af3:	8b 45 dc             	mov    -0x24(%ebp),%eax
        if(sz - i < PGSIZE)
80107af6:	ba 00 10 00 00       	mov    $0x1000,%edx
        pa = PTE_ADDR(*pte);
80107afb:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
        if(sz - i < PGSIZE)
80107b01:	81 fe ff 0f 00 00    	cmp    $0xfff,%esi
80107b07:	0f 46 d6             	cmovbe %esi,%edx
        if(readi(ip, P2V(pa), offset + i, n) != n)
80107b0a:	29 f0                	sub    %esi,%eax
80107b0c:	52                   	push   %edx
80107b0d:	50                   	push   %eax
80107b0e:	8d 83 00 00 00 80    	lea    -0x80000000(%ebx),%eax
80107b14:	50                   	push   %eax
80107b15:	ff 75 10             	push   0x10(%ebp)
80107b18:	89 55 e4             	mov    %edx,-0x1c(%ebp)
80107b1b:	e8 80 9f ff ff       	call   80101aa0 <readi>
80107b20:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80107b23:	83 c4 10             	add    $0x10,%esp
80107b26:	39 d0                	cmp    %edx,%eax
80107b28:	75 26                	jne    80107b50 <loaduvm+0xf0>
    for(i = 0; i < sz; i += PGSIZE){
80107b2a:	8b 45 18             	mov    0x18(%ebp),%eax
        *pte = (pa | perm | PTE_P);  // Set the physical address with new flags
80107b2d:	0b 5d d8             	or     -0x28(%ebp),%ebx
    for(i = 0; i < sz; i += PGSIZE){
80107b30:	81 ee 00 10 00 00    	sub    $0x1000,%esi
        *pte = (pa | perm | PTE_P);  // Set the physical address with new flags
80107b36:	83 cb 01             	or     $0x1,%ebx
80107b39:	89 1f                	mov    %ebx,(%edi)
    for(i = 0; i < sz; i += PGSIZE){
80107b3b:	29 f0                	sub    %esi,%eax
80107b3d:	39 45 18             	cmp    %eax,0x18(%ebp)
80107b40:	0f 87 6a ff ff ff    	ja     80107ab0 <loaduvm+0x50>
}
80107b46:	8d 65 f4             	lea    -0xc(%ebp),%esp
    return 0;
80107b49:	31 c0                	xor    %eax,%eax
}
80107b4b:	5b                   	pop    %ebx
80107b4c:	5e                   	pop    %esi
80107b4d:	5f                   	pop    %edi
80107b4e:	5d                   	pop    %ebp
80107b4f:	c3                   	ret    
80107b50:	8d 65 f4             	lea    -0xc(%ebp),%esp
            return -1;
80107b53:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80107b58:	5b                   	pop    %ebx
80107b59:	5e                   	pop    %esi
80107b5a:	5f                   	pop    %edi
80107b5b:	5d                   	pop    %ebp
80107b5c:	c3                   	ret    
        panic("loaduvm: addr must be page aligned");
80107b5d:	83 ec 0c             	sub    $0xc,%esp
80107b60:	68 4c 8d 10 80       	push   $0x80108d4c
80107b65:	e8 16 88 ff ff       	call   80100380 <panic>
80107b6a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

80107b70 <allocuvm>:
{
80107b70:	55                   	push   %ebp
80107b71:	89 e5                	mov    %esp,%ebp
80107b73:	57                   	push   %edi
80107b74:	56                   	push   %esi
80107b75:	53                   	push   %ebx
80107b76:	83 ec 1c             	sub    $0x1c,%esp
  if(newsz >= KERNBASE)
80107b79:	8b 7d 10             	mov    0x10(%ebp),%edi
80107b7c:	85 ff                	test   %edi,%edi
80107b7e:	0f 88 bc 00 00 00    	js     80107c40 <allocuvm+0xd0>
  if(newsz < oldsz)
80107b84:	3b 7d 0c             	cmp    0xc(%ebp),%edi
80107b87:	0f 82 a3 00 00 00    	jb     80107c30 <allocuvm+0xc0>
  a = PGROUNDUP(oldsz);
80107b8d:	8b 45 0c             	mov    0xc(%ebp),%eax
80107b90:	8d b0 ff 0f 00 00    	lea    0xfff(%eax),%esi
80107b96:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
  for(; a < newsz; a += PGSIZE){
80107b9c:	39 75 10             	cmp    %esi,0x10(%ebp)
80107b9f:	0f 86 8e 00 00 00    	jbe    80107c33 <allocuvm+0xc3>
80107ba5:	89 7d e4             	mov    %edi,-0x1c(%ebp)
80107ba8:	8b 7d 08             	mov    0x8(%ebp),%edi
80107bab:	eb 43                	jmp    80107bf0 <allocuvm+0x80>
80107bad:	8d 76 00             	lea    0x0(%esi),%esi
    memset(mem, 0, PGSIZE);
80107bb0:	83 ec 04             	sub    $0x4,%esp
80107bb3:	68 00 10 00 00       	push   $0x1000
80107bb8:	6a 00                	push   $0x0
80107bba:	50                   	push   %eax
80107bbb:	e8 a0 d0 ff ff       	call   80104c60 <memset>
    if(mappages(pgdir, (char*)a, PGSIZE, V2P(mem), PTE_W|PTE_U) < 0){
80107bc0:	8d 83 00 00 00 80    	lea    -0x80000000(%ebx),%eax
80107bc6:	c7 04 24 06 00 00 00 	movl   $0x6,(%esp)
80107bcd:	50                   	push   %eax
80107bce:	68 00 10 00 00       	push   $0x1000
80107bd3:	56                   	push   %esi
80107bd4:	57                   	push   %edi
80107bd5:	e8 f6 fb ff ff       	call   801077d0 <mappages>
80107bda:	83 c4 20             	add    $0x20,%esp
80107bdd:	85 c0                	test   %eax,%eax
80107bdf:	78 6f                	js     80107c50 <allocuvm+0xe0>
  for(; a < newsz; a += PGSIZE){
80107be1:	81 c6 00 10 00 00    	add    $0x1000,%esi
80107be7:	39 75 10             	cmp    %esi,0x10(%ebp)
80107bea:	0f 86 a0 00 00 00    	jbe    80107c90 <allocuvm+0x120>
    mem = kalloc();
80107bf0:	e8 fb aa ff ff       	call   801026f0 <kalloc>
80107bf5:	89 c3                	mov    %eax,%ebx
    if(mem == 0){
80107bf7:	85 c0                	test   %eax,%eax
80107bf9:	75 b5                	jne    80107bb0 <allocuvm+0x40>
      cprintf("allocuvm out of memory\n");
80107bfb:	83 ec 0c             	sub    $0xc,%esp
80107bfe:	68 c9 8c 10 80       	push   $0x80108cc9
80107c03:	e8 98 8a ff ff       	call   801006a0 <cprintf>
  if(newsz >= oldsz)
80107c08:	8b 45 0c             	mov    0xc(%ebp),%eax
80107c0b:	83 c4 10             	add    $0x10,%esp
80107c0e:	39 45 10             	cmp    %eax,0x10(%ebp)
80107c11:	74 2d                	je     80107c40 <allocuvm+0xd0>
80107c13:	8b 55 10             	mov    0x10(%ebp),%edx
80107c16:	89 c1                	mov    %eax,%ecx
80107c18:	8b 45 08             	mov    0x8(%ebp),%eax
      return 0;
80107c1b:	31 ff                	xor    %edi,%edi
80107c1d:	e8 de f9 ff ff       	call   80107600 <deallocuvm.part.0>
}
80107c22:	8d 65 f4             	lea    -0xc(%ebp),%esp
80107c25:	89 f8                	mov    %edi,%eax
80107c27:	5b                   	pop    %ebx
80107c28:	5e                   	pop    %esi
80107c29:	5f                   	pop    %edi
80107c2a:	5d                   	pop    %ebp
80107c2b:	c3                   	ret    
80107c2c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    return oldsz;
80107c30:	8b 7d 0c             	mov    0xc(%ebp),%edi
}
80107c33:	8d 65 f4             	lea    -0xc(%ebp),%esp
80107c36:	89 f8                	mov    %edi,%eax
80107c38:	5b                   	pop    %ebx
80107c39:	5e                   	pop    %esi
80107c3a:	5f                   	pop    %edi
80107c3b:	5d                   	pop    %ebp
80107c3c:	c3                   	ret    
80107c3d:	8d 76 00             	lea    0x0(%esi),%esi
80107c40:	8d 65 f4             	lea    -0xc(%ebp),%esp
    return 0;
80107c43:	31 ff                	xor    %edi,%edi
}
80107c45:	5b                   	pop    %ebx
80107c46:	89 f8                	mov    %edi,%eax
80107c48:	5e                   	pop    %esi
80107c49:	5f                   	pop    %edi
80107c4a:	5d                   	pop    %ebp
80107c4b:	c3                   	ret    
80107c4c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
      cprintf("allocuvm out of memory (2)\n");
80107c50:	83 ec 0c             	sub    $0xc,%esp
80107c53:	68 e1 8c 10 80       	push   $0x80108ce1
80107c58:	e8 43 8a ff ff       	call   801006a0 <cprintf>
  if(newsz >= oldsz)
80107c5d:	8b 45 0c             	mov    0xc(%ebp),%eax
80107c60:	83 c4 10             	add    $0x10,%esp
80107c63:	39 45 10             	cmp    %eax,0x10(%ebp)
80107c66:	74 0d                	je     80107c75 <allocuvm+0x105>
80107c68:	89 c1                	mov    %eax,%ecx
80107c6a:	8b 55 10             	mov    0x10(%ebp),%edx
80107c6d:	8b 45 08             	mov    0x8(%ebp),%eax
80107c70:	e8 8b f9 ff ff       	call   80107600 <deallocuvm.part.0>
      kfree(mem);
80107c75:	83 ec 0c             	sub    $0xc,%esp
      return 0;
80107c78:	31 ff                	xor    %edi,%edi
      kfree(mem);
80107c7a:	53                   	push   %ebx
80107c7b:	e8 b0 a8 ff ff       	call   80102530 <kfree>
      return 0;
80107c80:	83 c4 10             	add    $0x10,%esp
}
80107c83:	8d 65 f4             	lea    -0xc(%ebp),%esp
80107c86:	89 f8                	mov    %edi,%eax
80107c88:	5b                   	pop    %ebx
80107c89:	5e                   	pop    %esi
80107c8a:	5f                   	pop    %edi
80107c8b:	5d                   	pop    %ebp
80107c8c:	c3                   	ret    
80107c8d:	8d 76 00             	lea    0x0(%esi),%esi
80107c90:	8b 7d e4             	mov    -0x1c(%ebp),%edi
80107c93:	8d 65 f4             	lea    -0xc(%ebp),%esp
80107c96:	5b                   	pop    %ebx
80107c97:	5e                   	pop    %esi
80107c98:	89 f8                	mov    %edi,%eax
80107c9a:	5f                   	pop    %edi
80107c9b:	5d                   	pop    %ebp
80107c9c:	c3                   	ret    
80107c9d:	8d 76 00             	lea    0x0(%esi),%esi

80107ca0 <deallocuvm>:
{
80107ca0:	55                   	push   %ebp
80107ca1:	89 e5                	mov    %esp,%ebp
80107ca3:	8b 55 0c             	mov    0xc(%ebp),%edx
80107ca6:	8b 4d 10             	mov    0x10(%ebp),%ecx
80107ca9:	8b 45 08             	mov    0x8(%ebp),%eax
  if(newsz >= oldsz)
80107cac:	39 d1                	cmp    %edx,%ecx
80107cae:	73 10                	jae    80107cc0 <deallocuvm+0x20>
}
80107cb0:	5d                   	pop    %ebp
80107cb1:	e9 4a f9 ff ff       	jmp    80107600 <deallocuvm.part.0>
80107cb6:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80107cbd:	8d 76 00             	lea    0x0(%esi),%esi
80107cc0:	89 d0                	mov    %edx,%eax
80107cc2:	5d                   	pop    %ebp
80107cc3:	c3                   	ret    
80107cc4:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80107ccb:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80107ccf:	90                   	nop

80107cd0 <freevm>:

// Free a page table and all the physical memory pages
// in the user part.
void
freevm(pde_t *pgdir)
{
80107cd0:	55                   	push   %ebp
80107cd1:	89 e5                	mov    %esp,%ebp
80107cd3:	57                   	push   %edi
80107cd4:	56                   	push   %esi
80107cd5:	53                   	push   %ebx
80107cd6:	83 ec 0c             	sub    $0xc,%esp
80107cd9:	8b 75 08             	mov    0x8(%ebp),%esi
  uint i;

  if(pgdir == 0)
80107cdc:	85 f6                	test   %esi,%esi
80107cde:	74 59                	je     80107d39 <freevm+0x69>
  if(newsz >= oldsz)
80107ce0:	31 c9                	xor    %ecx,%ecx
80107ce2:	ba 00 00 00 80       	mov    $0x80000000,%edx
80107ce7:	89 f0                	mov    %esi,%eax
80107ce9:	89 f3                	mov    %esi,%ebx
80107ceb:	e8 10 f9 ff ff       	call   80107600 <deallocuvm.part.0>
    panic("freevm: no pgdir");
  deallocuvm(pgdir, KERNBASE, 0);
  for(i = 0; i < NPDENTRIES; i++){
80107cf0:	8d be 00 10 00 00    	lea    0x1000(%esi),%edi
80107cf6:	eb 0f                	jmp    80107d07 <freevm+0x37>
80107cf8:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80107cff:	90                   	nop
80107d00:	83 c3 04             	add    $0x4,%ebx
80107d03:	39 df                	cmp    %ebx,%edi
80107d05:	74 23                	je     80107d2a <freevm+0x5a>
    if(pgdir[i] & PTE_P){
80107d07:	8b 03                	mov    (%ebx),%eax
80107d09:	a8 01                	test   $0x1,%al
80107d0b:	74 f3                	je     80107d00 <freevm+0x30>
      char * v = P2V(PTE_ADDR(pgdir[i]));
80107d0d:	25 00 f0 ff ff       	and    $0xfffff000,%eax
      kfree(v);
80107d12:	83 ec 0c             	sub    $0xc,%esp
  for(i = 0; i < NPDENTRIES; i++){
80107d15:	83 c3 04             	add    $0x4,%ebx
      char * v = P2V(PTE_ADDR(pgdir[i]));
80107d18:	05 00 00 00 80       	add    $0x80000000,%eax
      kfree(v);
80107d1d:	50                   	push   %eax
80107d1e:	e8 0d a8 ff ff       	call   80102530 <kfree>
80107d23:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NPDENTRIES; i++){
80107d26:	39 df                	cmp    %ebx,%edi
80107d28:	75 dd                	jne    80107d07 <freevm+0x37>
    }
  }
  kfree((char*)pgdir);
80107d2a:	89 75 08             	mov    %esi,0x8(%ebp)
}
80107d2d:	8d 65 f4             	lea    -0xc(%ebp),%esp
80107d30:	5b                   	pop    %ebx
80107d31:	5e                   	pop    %esi
80107d32:	5f                   	pop    %edi
80107d33:	5d                   	pop    %ebp
  kfree((char*)pgdir);
80107d34:	e9 f7 a7 ff ff       	jmp    80102530 <kfree>
    panic("freevm: no pgdir");
80107d39:	83 ec 0c             	sub    $0xc,%esp
80107d3c:	68 fd 8c 10 80       	push   $0x80108cfd
80107d41:	e8 3a 86 ff ff       	call   80100380 <panic>
80107d46:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80107d4d:	8d 76 00             	lea    0x0(%esi),%esi

80107d50 <setupkvm>:
{
80107d50:	55                   	push   %ebp
80107d51:	89 e5                	mov    %esp,%ebp
80107d53:	56                   	push   %esi
80107d54:	53                   	push   %ebx
  if((pgdir = (pde_t*)kalloc()) == 0)
80107d55:	e8 96 a9 ff ff       	call   801026f0 <kalloc>
80107d5a:	89 c6                	mov    %eax,%esi
80107d5c:	85 c0                	test   %eax,%eax
80107d5e:	74 42                	je     80107da2 <setupkvm+0x52>
  memset(pgdir, 0, PGSIZE);
80107d60:	83 ec 04             	sub    $0x4,%esp
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80107d63:	bb 20 b4 10 80       	mov    $0x8010b420,%ebx
  memset(pgdir, 0, PGSIZE);
80107d68:	68 00 10 00 00       	push   $0x1000
80107d6d:	6a 00                	push   $0x0
80107d6f:	50                   	push   %eax
80107d70:	e8 eb ce ff ff       	call   80104c60 <memset>
80107d75:	83 c4 10             	add    $0x10,%esp
                (uint)k->phys_start, k->perm) < 0) {
80107d78:	8b 43 04             	mov    0x4(%ebx),%eax
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
80107d7b:	8b 53 08             	mov    0x8(%ebx),%edx
80107d7e:	83 ec 0c             	sub    $0xc,%esp
80107d81:	ff 73 0c             	push   0xc(%ebx)
80107d84:	29 c2                	sub    %eax,%edx
80107d86:	50                   	push   %eax
80107d87:	52                   	push   %edx
80107d88:	ff 33                	push   (%ebx)
80107d8a:	56                   	push   %esi
80107d8b:	e8 40 fa ff ff       	call   801077d0 <mappages>
80107d90:	83 c4 20             	add    $0x20,%esp
80107d93:	85 c0                	test   %eax,%eax
80107d95:	78 19                	js     80107db0 <setupkvm+0x60>
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80107d97:	83 c3 10             	add    $0x10,%ebx
80107d9a:	81 fb 60 b4 10 80    	cmp    $0x8010b460,%ebx
80107da0:	75 d6                	jne    80107d78 <setupkvm+0x28>
}
80107da2:	8d 65 f8             	lea    -0x8(%ebp),%esp
80107da5:	89 f0                	mov    %esi,%eax
80107da7:	5b                   	pop    %ebx
80107da8:	5e                   	pop    %esi
80107da9:	5d                   	pop    %ebp
80107daa:	c3                   	ret    
80107dab:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80107daf:	90                   	nop
      freevm(pgdir);
80107db0:	83 ec 0c             	sub    $0xc,%esp
80107db3:	56                   	push   %esi
      return 0;
80107db4:	31 f6                	xor    %esi,%esi
      freevm(pgdir);
80107db6:	e8 15 ff ff ff       	call   80107cd0 <freevm>
      return 0;
80107dbb:	83 c4 10             	add    $0x10,%esp
}
80107dbe:	8d 65 f8             	lea    -0x8(%ebp),%esp
80107dc1:	89 f0                	mov    %esi,%eax
80107dc3:	5b                   	pop    %ebx
80107dc4:	5e                   	pop    %esi
80107dc5:	5d                   	pop    %ebp
80107dc6:	c3                   	ret    
80107dc7:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80107dce:	66 90                	xchg   %ax,%ax

80107dd0 <kvmalloc>:
{
80107dd0:	55                   	push   %ebp
80107dd1:	89 e5                	mov    %esp,%ebp
80107dd3:	83 ec 08             	sub    $0x8,%esp
  kpgdir = setupkvm();
80107dd6:	e8 75 ff ff ff       	call   80107d50 <setupkvm>
80107ddb:	a3 04 a6 21 80       	mov    %eax,0x8021a604
  lcr3(V2P(kpgdir));   // switch to the kernel page table
80107de0:	05 00 00 00 80       	add    $0x80000000,%eax
80107de5:	0f 22 d8             	mov    %eax,%cr3
}
80107de8:	c9                   	leave  
80107de9:	c3                   	ret    
80107dea:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

80107df0 <clearpteu>:

// Clear PTE_U on a page. Used to create an inaccessible
// page beneath the user stack.
void
clearpteu(pde_t *pgdir, char *uva)
{
80107df0:	55                   	push   %ebp
80107df1:	89 e5                	mov    %esp,%ebp
80107df3:	83 ec 08             	sub    $0x8,%esp
80107df6:	8b 45 0c             	mov    0xc(%ebp),%eax
  if(*pde & PTE_P){
80107df9:	8b 55 08             	mov    0x8(%ebp),%edx
  pde = &pgdir[PDX(va)];
80107dfc:	89 c1                	mov    %eax,%ecx
80107dfe:	c1 e9 16             	shr    $0x16,%ecx
  if(*pde & PTE_P){
80107e01:	8b 14 8a             	mov    (%edx,%ecx,4),%edx
80107e04:	f6 c2 01             	test   $0x1,%dl
80107e07:	75 17                	jne    80107e20 <clearpteu+0x30>
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
  if(pte == 0)
    panic("clearpteu");
80107e09:	83 ec 0c             	sub    $0xc,%esp
80107e0c:	68 0e 8d 10 80       	push   $0x80108d0e
80107e11:	e8 6a 85 ff ff       	call   80100380 <panic>
80107e16:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80107e1d:	8d 76 00             	lea    0x0(%esi),%esi
  return &pgtab[PTX(va)];
80107e20:	c1 e8 0a             	shr    $0xa,%eax
    pgtab = (pte_t*)P2V(PTE_ADDR(*pde));
80107e23:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
  return &pgtab[PTX(va)];
80107e29:	25 fc 0f 00 00       	and    $0xffc,%eax
80107e2e:	8d 84 02 00 00 00 80 	lea    -0x80000000(%edx,%eax,1),%eax
  if(pte == 0)
80107e35:	85 c0                	test   %eax,%eax
80107e37:	74 d0                	je     80107e09 <clearpteu+0x19>
  *pte &= ~PTE_U;
80107e39:	83 20 fb             	andl   $0xfffffffb,(%eax)
}
80107e3c:	c9                   	leave  
80107e3d:	c3                   	ret    
80107e3e:	66 90                	xchg   %ax,%ax

80107e40 <copyuvm>:

// Given a parent process's page table, create a copy
// of it for a child.
pde_t*
copyuvm(pde_t *pgdir, uint sz)
{
80107e40:	55                   	push   %ebp
80107e41:	89 e5                	mov    %esp,%ebp
80107e43:	57                   	push   %edi
80107e44:	56                   	push   %esi
80107e45:	53                   	push   %ebx
80107e46:	83 ec 1c             	sub    $0x1c,%esp
    pde_t *d;
    pte_t *pte;
    uint pa, i, flags;

    if ((d = setupkvm()) == 0)
80107e49:	e8 02 ff ff ff       	call   80107d50 <setupkvm>
80107e4e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80107e51:	85 c0                	test   %eax,%eax
80107e53:	0f 84 ab 00 00 00    	je     80107f04 <copyuvm+0xc4>
        return 0;

    for (i = 0; i < sz; i += PGSIZE) {
80107e59:	8b 45 0c             	mov    0xc(%ebp),%eax
80107e5c:	85 c0                	test   %eax,%eax
80107e5e:	0f 84 95 00 00 00    	je     80107ef9 <copyuvm+0xb9>
80107e64:	31 ff                	xor    %edi,%edi
80107e66:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80107e6d:	8d 76 00             	lea    0x0(%esi),%esi
  if(*pde & PTE_P){
80107e70:	8b 55 08             	mov    0x8(%ebp),%edx
  pde = &pgdir[PDX(va)];
80107e73:	89 f8                	mov    %edi,%eax
80107e75:	c1 e8 16             	shr    $0x16,%eax
  if(*pde & PTE_P){
80107e78:	8b 04 82             	mov    (%edx,%eax,4),%eax
80107e7b:	a8 01                	test   $0x1,%al
80107e7d:	75 11                	jne    80107e90 <copyuvm+0x50>
        if ((pte = walkpgdir(pgdir, (void *)i, 0)) == 0) {
            panic("copyuvm: pte should exist");
80107e7f:	83 ec 0c             	sub    $0xc,%esp
80107e82:	68 18 8d 10 80       	push   $0x80108d18
80107e87:	e8 f4 84 ff ff       	call   80100380 <panic>
80107e8c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  return &pgtab[PTX(va)];
80107e90:	89 fa                	mov    %edi,%edx
    pgtab = (pte_t*)P2V(PTE_ADDR(*pde));
80107e92:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  return &pgtab[PTX(va)];
80107e97:	c1 ea 0a             	shr    $0xa,%edx
80107e9a:	81 e2 fc 0f 00 00    	and    $0xffc,%edx
80107ea0:	8d 8c 10 00 00 00 80 	lea    -0x80000000(%eax,%edx,1),%ecx
        if ((pte = walkpgdir(pgdir, (void *)i, 0)) == 0) {
80107ea7:	85 c9                	test   %ecx,%ecx
80107ea9:	74 d4                	je     80107e7f <copyuvm+0x3f>
        }
        if (!(*pte & PTE_P)) {
80107eab:	8b 01                	mov    (%ecx),%eax
80107ead:	a8 01                	test   $0x1,%al
80107eaf:	0f 84 9b 00 00 00    	je     80107f50 <copyuvm+0x110>
            panic("copyuvm: page not present");
        }

        pa = PTE_ADDR(*pte);
80107eb5:	89 c6                	mov    %eax,%esi
80107eb7:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
        flags = PTE_FLAGS(*pte);

        if (flags & PTE_W) {
80107ebd:	a8 02                	test   $0x2,%al
80107ebf:	75 4f                	jne    80107f10 <copyuvm+0xd0>
        flags = PTE_FLAGS(*pte);
80107ec1:	25 ff 0f 00 00       	and    $0xfff,%eax
80107ec6:	89 c3                	mov    %eax,%ebx
            flags &= ~PTE_W;  // Clear the writable flag for the child
            flags |= PTE_COW; // Add the COW flag for the child
        }

        // Increment the reference count for the shared physical page
        inc_ref(pa);
80107ec8:	83 ec 0c             	sub    $0xc,%esp
80107ecb:	56                   	push   %esi
80107ecc:	e8 ff a5 ff ff       	call   801024d0 <inc_ref>

        // Map the page in the child’s page table
        if (mappages(d, (void *)i, PGSIZE, pa, flags) < 0) {
80107ed1:	89 1c 24             	mov    %ebx,(%esp)
80107ed4:	56                   	push   %esi
80107ed5:	68 00 10 00 00       	push   $0x1000
80107eda:	57                   	push   %edi
80107edb:	ff 75 e4             	push   -0x1c(%ebp)
80107ede:	e8 ed f8 ff ff       	call   801077d0 <mappages>
80107ee3:	83 c4 20             	add    $0x20,%esp
80107ee6:	85 c0                	test   %eax,%eax
80107ee8:	78 46                	js     80107f30 <copyuvm+0xf0>
    for (i = 0; i < sz; i += PGSIZE) {
80107eea:	81 c7 00 10 00 00    	add    $0x1000,%edi
80107ef0:	39 7d 0c             	cmp    %edi,0xc(%ebp)
80107ef3:	0f 87 77 ff ff ff    	ja     80107e70 <copyuvm+0x30>
            goto bad;
        }
    }

    // Flush the TLB for the parent to apply COW changes
    lcr3(V2P(pgdir));
80107ef9:	8b 45 08             	mov    0x8(%ebp),%eax
80107efc:	05 00 00 00 80       	add    $0x80000000,%eax
80107f01:	0f 22 d8             	mov    %eax,%cr3
    return d;

bad:
    freevm(d);
    return 0;
}
80107f04:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80107f07:	8d 65 f4             	lea    -0xc(%ebp),%esp
80107f0a:	5b                   	pop    %ebx
80107f0b:	5e                   	pop    %esi
80107f0c:	5f                   	pop    %edi
80107f0d:	5d                   	pop    %ebp
80107f0e:	c3                   	ret    
80107f0f:	90                   	nop
            *pte &= ~PTE_W;   // Clear the writable flag in the parent
80107f10:	89 c3                	mov    %eax,%ebx
            flags &= ~PTE_W;  // Clear the writable flag for the child
80107f12:	25 fd 0f 00 00       	and    $0xffd,%eax
            *pte &= ~PTE_W;   // Clear the writable flag in the parent
80107f17:	83 e3 fd             	and    $0xfffffffd,%ebx
            flags |= PTE_COW; // Add the COW flag for the child
80107f1a:	80 cc 04             	or     $0x4,%ah
            *pte |= PTE_COW;  // Add the COW flag in the parent
80107f1d:	80 cf 04             	or     $0x4,%bh
80107f20:	89 19                	mov    %ebx,(%ecx)
            flags |= PTE_COW; // Add the COW flag for the child
80107f22:	89 c3                	mov    %eax,%ebx
80107f24:	eb a2                	jmp    80107ec8 <copyuvm+0x88>
80107f26:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80107f2d:	8d 76 00             	lea    0x0(%esi),%esi
    freevm(d);
80107f30:	83 ec 0c             	sub    $0xc,%esp
80107f33:	ff 75 e4             	push   -0x1c(%ebp)
80107f36:	e8 95 fd ff ff       	call   80107cd0 <freevm>
    return 0;
80107f3b:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80107f42:	83 c4 10             	add    $0x10,%esp
}
80107f45:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80107f48:	8d 65 f4             	lea    -0xc(%ebp),%esp
80107f4b:	5b                   	pop    %ebx
80107f4c:	5e                   	pop    %esi
80107f4d:	5f                   	pop    %edi
80107f4e:	5d                   	pop    %ebp
80107f4f:	c3                   	ret    
            panic("copyuvm: page not present");
80107f50:	83 ec 0c             	sub    $0xc,%esp
80107f53:	68 32 8d 10 80       	push   $0x80108d32
80107f58:	e8 23 84 ff ff       	call   80100380 <panic>
80107f5d:	8d 76 00             	lea    0x0(%esi),%esi

80107f60 <uva2ka>:

//PAGEBREAK!
// Map user virtual address to kernel address.
char*
uva2ka(pde_t *pgdir, char *uva)
{
80107f60:	55                   	push   %ebp
80107f61:	89 e5                	mov    %esp,%ebp
80107f63:	8b 45 0c             	mov    0xc(%ebp),%eax
  if(*pde & PTE_P){
80107f66:	8b 55 08             	mov    0x8(%ebp),%edx
  pde = &pgdir[PDX(va)];
80107f69:	89 c1                	mov    %eax,%ecx
80107f6b:	c1 e9 16             	shr    $0x16,%ecx
  if(*pde & PTE_P){
80107f6e:	8b 14 8a             	mov    (%edx,%ecx,4),%edx
80107f71:	f6 c2 01             	test   $0x1,%dl
80107f74:	0f 84 00 01 00 00    	je     8010807a <uva2ka.cold>
  return &pgtab[PTX(va)];
80107f7a:	c1 e8 0c             	shr    $0xc,%eax
    pgtab = (pte_t*)P2V(PTE_ADDR(*pde));
80107f7d:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
  if((*pte & PTE_P) == 0)
    return 0;
  if((*pte & PTE_U) == 0)
    return 0;
  return (char*)P2V(PTE_ADDR(*pte));
}
80107f83:	5d                   	pop    %ebp
  return &pgtab[PTX(va)];
80107f84:	25 ff 03 00 00       	and    $0x3ff,%eax
  if((*pte & PTE_P) == 0)
80107f89:	8b 84 82 00 00 00 80 	mov    -0x80000000(%edx,%eax,4),%eax
  if((*pte & PTE_U) == 0)
80107f90:	89 c2                	mov    %eax,%edx
  return (char*)P2V(PTE_ADDR(*pte));
80107f92:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  if((*pte & PTE_U) == 0)
80107f97:	83 e2 05             	and    $0x5,%edx
  return (char*)P2V(PTE_ADDR(*pte));
80107f9a:	05 00 00 00 80       	add    $0x80000000,%eax
80107f9f:	83 fa 05             	cmp    $0x5,%edx
80107fa2:	ba 00 00 00 00       	mov    $0x0,%edx
80107fa7:	0f 45 c2             	cmovne %edx,%eax
}
80107faa:	c3                   	ret    
80107fab:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80107faf:	90                   	nop

80107fb0 <copyout>:
// Copy len bytes from p to user address va in page table pgdir.
// Most useful when pgdir is not the current page table.
// uva2ka ensures this only works for PTE_U pages.
int
copyout(pde_t *pgdir, uint va, void *p, uint len)
{
80107fb0:	55                   	push   %ebp
80107fb1:	89 e5                	mov    %esp,%ebp
80107fb3:	57                   	push   %edi
80107fb4:	56                   	push   %esi
80107fb5:	53                   	push   %ebx
80107fb6:	83 ec 0c             	sub    $0xc,%esp
80107fb9:	8b 75 14             	mov    0x14(%ebp),%esi
80107fbc:	8b 45 0c             	mov    0xc(%ebp),%eax
80107fbf:	8b 55 10             	mov    0x10(%ebp),%edx
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
  while(len > 0){
80107fc2:	85 f6                	test   %esi,%esi
80107fc4:	75 51                	jne    80108017 <copyout+0x67>
80107fc6:	e9 a5 00 00 00       	jmp    80108070 <copyout+0xc0>
80107fcb:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80107fcf:	90                   	nop
  return (char*)P2V(PTE_ADDR(*pte));
80107fd0:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
80107fd6:	8d 8b 00 00 00 80    	lea    -0x80000000(%ebx),%ecx
    va0 = (uint)PGROUNDDOWN(va);
    pa0 = uva2ka(pgdir, (char*)va0);
    if(pa0 == 0)
80107fdc:	81 fb 00 00 00 80    	cmp    $0x80000000,%ebx
80107fe2:	74 75                	je     80108059 <copyout+0xa9>
      return -1;
    n = PGSIZE - (va - va0);
80107fe4:	89 fb                	mov    %edi,%ebx
    if(n > len)
      n = len;
    memmove(pa0 + (va - va0), buf, n);
80107fe6:	89 55 10             	mov    %edx,0x10(%ebp)
    n = PGSIZE - (va - va0);
80107fe9:	29 c3                	sub    %eax,%ebx
80107feb:	81 c3 00 10 00 00    	add    $0x1000,%ebx
80107ff1:	39 f3                	cmp    %esi,%ebx
80107ff3:	0f 47 de             	cmova  %esi,%ebx
    memmove(pa0 + (va - va0), buf, n);
80107ff6:	29 f8                	sub    %edi,%eax
80107ff8:	83 ec 04             	sub    $0x4,%esp
80107ffb:	01 c1                	add    %eax,%ecx
80107ffd:	53                   	push   %ebx
80107ffe:	52                   	push   %edx
80107fff:	51                   	push   %ecx
80108000:	e8 fb cc ff ff       	call   80104d00 <memmove>
    len -= n;
    buf += n;
80108005:	8b 55 10             	mov    0x10(%ebp),%edx
    va = va0 + PGSIZE;
80108008:	8d 87 00 10 00 00    	lea    0x1000(%edi),%eax
  while(len > 0){
8010800e:	83 c4 10             	add    $0x10,%esp
    buf += n;
80108011:	01 da                	add    %ebx,%edx
  while(len > 0){
80108013:	29 de                	sub    %ebx,%esi
80108015:	74 59                	je     80108070 <copyout+0xc0>
  if(*pde & PTE_P){
80108017:	8b 5d 08             	mov    0x8(%ebp),%ebx
  pde = &pgdir[PDX(va)];
8010801a:	89 c1                	mov    %eax,%ecx
    va0 = (uint)PGROUNDDOWN(va);
8010801c:	89 c7                	mov    %eax,%edi
  pde = &pgdir[PDX(va)];
8010801e:	c1 e9 16             	shr    $0x16,%ecx
    va0 = (uint)PGROUNDDOWN(va);
80108021:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
  if(*pde & PTE_P){
80108027:	8b 0c 8b             	mov    (%ebx,%ecx,4),%ecx
8010802a:	f6 c1 01             	test   $0x1,%cl
8010802d:	0f 84 4e 00 00 00    	je     80108081 <copyout.cold>
  return &pgtab[PTX(va)];
80108033:	89 fb                	mov    %edi,%ebx
    pgtab = (pte_t*)P2V(PTE_ADDR(*pde));
80108035:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
  return &pgtab[PTX(va)];
8010803b:	c1 eb 0c             	shr    $0xc,%ebx
8010803e:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
  if((*pte & PTE_P) == 0)
80108044:	8b 9c 99 00 00 00 80 	mov    -0x80000000(%ecx,%ebx,4),%ebx
  if((*pte & PTE_U) == 0)
8010804b:	89 d9                	mov    %ebx,%ecx
8010804d:	83 e1 05             	and    $0x5,%ecx
80108050:	83 f9 05             	cmp    $0x5,%ecx
80108053:	0f 84 77 ff ff ff    	je     80107fd0 <copyout+0x20>
  }
  return 0;
}
80108059:	8d 65 f4             	lea    -0xc(%ebp),%esp
      return -1;
8010805c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80108061:	5b                   	pop    %ebx
80108062:	5e                   	pop    %esi
80108063:	5f                   	pop    %edi
80108064:	5d                   	pop    %ebp
80108065:	c3                   	ret    
80108066:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010806d:	8d 76 00             	lea    0x0(%esi),%esi
80108070:	8d 65 f4             	lea    -0xc(%ebp),%esp
  return 0;
80108073:	31 c0                	xor    %eax,%eax
}
80108075:	5b                   	pop    %ebx
80108076:	5e                   	pop    %esi
80108077:	5f                   	pop    %edi
80108078:	5d                   	pop    %ebp
80108079:	c3                   	ret    

8010807a <uva2ka.cold>:
  if((*pte & PTE_P) == 0)
8010807a:	a1 00 00 00 00       	mov    0x0,%eax
8010807f:	0f 0b                	ud2    

80108081 <copyout.cold>:
80108081:	a1 00 00 00 00       	mov    0x0,%eax
80108086:	0f 0b                	ud2    
