
bin/kernel：     文件格式 elf64-littleriscv


Disassembly of section .text:

0000000080200000 <kern_entry>:
#include <memlayout.h>

    .section .text,"ax",%progbits
    .globl kern_entry
kern_entry:
    la sp, bootstacktop
    80200000:	00004117          	auipc	sp,0x4
    80200004:	00010113          	mv	sp,sp

    tail kern_init
    80200008:	0040006f          	j	8020000c <kern_init>

000000008020000c <kern_init>:
int kern_init(void) __attribute__((noreturn));
void grade_backtrace(void);

int kern_init(void) {
    extern char edata[], end[];
    memset(edata, 0, end - edata);
    8020000c:	00004517          	auipc	a0,0x4
    80200010:	00450513          	addi	a0,a0,4 # 80204010 <edata>
    80200014:	00004617          	auipc	a2,0x4
    80200018:	01460613          	addi	a2,a2,20 # 80204028 <end>
int kern_init(void) {
    8020001c:	1141                	addi	sp,sp,-16
    memset(edata, 0, end - edata);
    8020001e:	8e09                	sub	a2,a2,a0
    80200020:	4581                	li	a1,0
int kern_init(void) {
    80200022:	e406                	sd	ra,8(sp)
    memset(edata, 0, end - edata);
    80200024:	1fd000ef          	jal	ra,80200a20 <memset>

    cons_init();  // init the console
    80200028:	118000ef          	jal	ra,80200140 <cons_init>

    const char *message = "(THU.CST) os is loading ...\n";
    cprintf("%s\n\n", message);
    8020002c:	00001597          	auipc	a1,0x1
    80200030:	a0c58593          	addi	a1,a1,-1524 # 80200a38 <etext+0x6>
    80200034:	00001517          	auipc	a0,0x1
    80200038:	a2450513          	addi	a0,a0,-1500 # 80200a58 <etext+0x26>
    8020003c:	030000ef          	jal	ra,8020006c <cprintf>

    print_kerninfo();
    80200040:	060000ef          	jal	ra,802000a0 <print_kerninfo>

    // grade_backtrace();

    idt_init();  // init interrupt descriptor table
    80200044:	10c000ef          	jal	ra,80200150 <idt_init>

    // rdtime in mbare mode crashes
    //clock_init();  // init clock interrupt

    intr_enable();  // enable irq interrupt
    80200048:	102000ef          	jal	ra,8020014a <intr_enable>
    
    //asm volatile("ebreak"::);
    
    asm volatile("mret"::);
    8020004c:	30200073          	mret
    
    while (1)
        ;
    80200050:	a001                	j	80200050 <kern_init+0x44>

0000000080200052 <cputch>:

/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void cputch(int c, int *cnt) {
    80200052:	1141                	addi	sp,sp,-16
    80200054:	e022                	sd	s0,0(sp)
    80200056:	e406                	sd	ra,8(sp)
    80200058:	842e                	mv	s0,a1
    cons_putc(c);
    8020005a:	0e8000ef          	jal	ra,80200142 <cons_putc>
    (*cnt)++;
    8020005e:	401c                	lw	a5,0(s0)
}
    80200060:	60a2                	ld	ra,8(sp)
    (*cnt)++;
    80200062:	2785                	addiw	a5,a5,1
    80200064:	c01c                	sw	a5,0(s0)
}
    80200066:	6402                	ld	s0,0(sp)
    80200068:	0141                	addi	sp,sp,16
    8020006a:	8082                	ret

000000008020006c <cprintf>:
 * cprintf - formats a string and writes it to stdout
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int cprintf(const char *fmt, ...) {
    8020006c:	711d                	addi	sp,sp,-96
    va_list ap;
    int cnt;
    va_start(ap, fmt);
    8020006e:	02810313          	addi	t1,sp,40 # 80204028 <end>
int cprintf(const char *fmt, ...) {
    80200072:	f42e                	sd	a1,40(sp)
    80200074:	f832                	sd	a2,48(sp)
    80200076:	fc36                	sd	a3,56(sp)
    vprintfmt((void *)cputch, &cnt, fmt, ap);
    80200078:	862a                	mv	a2,a0
    8020007a:	004c                	addi	a1,sp,4
    8020007c:	00000517          	auipc	a0,0x0
    80200080:	fd650513          	addi	a0,a0,-42 # 80200052 <cputch>
    80200084:	869a                	mv	a3,t1
int cprintf(const char *fmt, ...) {
    80200086:	ec06                	sd	ra,24(sp)
    80200088:	e0ba                	sd	a4,64(sp)
    8020008a:	e4be                	sd	a5,72(sp)
    8020008c:	e8c2                	sd	a6,80(sp)
    8020008e:	ecc6                	sd	a7,88(sp)
    va_start(ap, fmt);
    80200090:	e41a                	sd	t1,8(sp)
    int cnt = 0;
    80200092:	c202                	sw	zero,4(sp)
    vprintfmt((void *)cputch, &cnt, fmt, ap);
    80200094:	586000ef          	jal	ra,8020061a <vprintfmt>
    cnt = vcprintf(fmt, ap);
    va_end(ap);
    return cnt;
}
    80200098:	60e2                	ld	ra,24(sp)
    8020009a:	4512                	lw	a0,4(sp)
    8020009c:	6125                	addi	sp,sp,96
    8020009e:	8082                	ret

00000000802000a0 <print_kerninfo>:
/* *
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void print_kerninfo(void) {
    802000a0:	1141                	addi	sp,sp,-16
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
    802000a2:	00001517          	auipc	a0,0x1
    802000a6:	9be50513          	addi	a0,a0,-1602 # 80200a60 <etext+0x2e>
void print_kerninfo(void) {
    802000aa:	e406                	sd	ra,8(sp)
    cprintf("Special kernel symbols:\n");
    802000ac:	fc1ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  entry  0x%016x (virtual)\n", kern_init);
    802000b0:	00000597          	auipc	a1,0x0
    802000b4:	f5c58593          	addi	a1,a1,-164 # 8020000c <kern_init>
    802000b8:	00001517          	auipc	a0,0x1
    802000bc:	9c850513          	addi	a0,a0,-1592 # 80200a80 <etext+0x4e>
    802000c0:	fadff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  etext  0x%016x (virtual)\n", etext);
    802000c4:	00001597          	auipc	a1,0x1
    802000c8:	96e58593          	addi	a1,a1,-1682 # 80200a32 <etext>
    802000cc:	00001517          	auipc	a0,0x1
    802000d0:	9d450513          	addi	a0,a0,-1580 # 80200aa0 <etext+0x6e>
    802000d4:	f99ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  edata  0x%016x (virtual)\n", edata);
    802000d8:	00004597          	auipc	a1,0x4
    802000dc:	f3858593          	addi	a1,a1,-200 # 80204010 <edata>
    802000e0:	00001517          	auipc	a0,0x1
    802000e4:	9e050513          	addi	a0,a0,-1568 # 80200ac0 <etext+0x8e>
    802000e8:	f85ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  end    0x%016x (virtual)\n", end);
    802000ec:	00004597          	auipc	a1,0x4
    802000f0:	f3c58593          	addi	a1,a1,-196 # 80204028 <end>
    802000f4:	00001517          	auipc	a0,0x1
    802000f8:	9ec50513          	addi	a0,a0,-1556 # 80200ae0 <etext+0xae>
    802000fc:	f71ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n",
            (end - kern_init + 1023) / 1024);
    80200100:	00004597          	auipc	a1,0x4
    80200104:	32758593          	addi	a1,a1,807 # 80204427 <end+0x3ff>
    80200108:	00000797          	auipc	a5,0x0
    8020010c:	f0478793          	addi	a5,a5,-252 # 8020000c <kern_init>
    80200110:	40f587b3          	sub	a5,a1,a5
    cprintf("Kernel executable memory footprint: %dKB\n",
    80200114:	43f7d593          	srai	a1,a5,0x3f
}
    80200118:	60a2                	ld	ra,8(sp)
    cprintf("Kernel executable memory footprint: %dKB\n",
    8020011a:	3ff5f593          	andi	a1,a1,1023
    8020011e:	95be                	add	a1,a1,a5
    80200120:	85a9                	srai	a1,a1,0xa
    80200122:	00001517          	auipc	a0,0x1
    80200126:	9de50513          	addi	a0,a0,-1570 # 80200b00 <etext+0xce>
}
    8020012a:	0141                	addi	sp,sp,16
    cprintf("Kernel executable memory footprint: %dKB\n",
    8020012c:	f41ff06f          	j	8020006c <cprintf>

0000000080200130 <clock_set_next_event>:
volatile size_t ticks;

static inline uint64_t get_cycles(void) {
#if __riscv_xlen == 64
    uint64_t n;
    __asm__ __volatile__("rdtime %0" : "=r"(n));
    80200130:	c0102573          	rdtime	a0
    ticks = 0;

    cprintf("++ setup timer interrupts\n");
}

void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
    80200134:	67e1                	lui	a5,0x18
    80200136:	6a078793          	addi	a5,a5,1696 # 186a0 <BASE_ADDRESS-0x801e7960>
    8020013a:	953e                	add	a0,a0,a5
    8020013c:	0870006f          	j	802009c2 <sbi_set_timer>

0000000080200140 <cons_init>:

/* serial_intr - try to feed input characters from serial port */
void serial_intr(void) {}

/* cons_init - initializes the console devices */
void cons_init(void) {}
    80200140:	8082                	ret

0000000080200142 <cons_putc>:

/* cons_putc - print a single character @c to console devices */
void cons_putc(int c) { sbi_console_putchar((unsigned char)c); }
    80200142:	0ff57513          	andi	a0,a0,255
    80200146:	0610006f          	j	802009a6 <sbi_console_putchar>

000000008020014a <intr_enable>:
#include <intr.h>
#include <riscv.h>

/* intr_enable - enable irq interrupt */
void intr_enable(void) { set_csr(sstatus, SSTATUS_SIE); }
    8020014a:	100167f3          	csrrsi	a5,sstatus,2
    8020014e:	8082                	ret

0000000080200150 <idt_init>:
 */
void idt_init(void) {
    extern void __alltraps(void);
    /* Set sscratch register to 0, indicating to exception vector that we are
     * presently executing in the kernel */
    write_csr(sscratch, 0);
    80200150:	14005073          	csrwi	sscratch,0
    /* Set the exception vector address */
    write_csr(stvec, &__alltraps);
    80200154:	00000797          	auipc	a5,0x0
    80200158:	3a478793          	addi	a5,a5,932 # 802004f8 <__alltraps>
    8020015c:	10579073          	csrw	stvec,a5
}
    80200160:	8082                	ret

0000000080200162 <print_regs>:
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
    cprintf("  cause    0x%08x\n", tf->cause);
}

void print_regs(struct pushregs *gpr) {
    cprintf("  zero     0x%08x\n", gpr->zero);
    80200162:	610c                	ld	a1,0(a0)
void print_regs(struct pushregs *gpr) {
    80200164:	1141                	addi	sp,sp,-16
    80200166:	e022                	sd	s0,0(sp)
    80200168:	842a                	mv	s0,a0
    cprintf("  zero     0x%08x\n", gpr->zero);
    8020016a:	00001517          	auipc	a0,0x1
    8020016e:	ace50513          	addi	a0,a0,-1330 # 80200c38 <etext+0x206>
void print_regs(struct pushregs *gpr) {
    80200172:	e406                	sd	ra,8(sp)
    cprintf("  zero     0x%08x\n", gpr->zero);
    80200174:	ef9ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  ra       0x%08x\n", gpr->ra);
    80200178:	640c                	ld	a1,8(s0)
    8020017a:	00001517          	auipc	a0,0x1
    8020017e:	ad650513          	addi	a0,a0,-1322 # 80200c50 <etext+0x21e>
    80200182:	eebff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  sp       0x%08x\n", gpr->sp);
    80200186:	680c                	ld	a1,16(s0)
    80200188:	00001517          	auipc	a0,0x1
    8020018c:	ae050513          	addi	a0,a0,-1312 # 80200c68 <etext+0x236>
    80200190:	eddff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  gp       0x%08x\n", gpr->gp);
    80200194:	6c0c                	ld	a1,24(s0)
    80200196:	00001517          	auipc	a0,0x1
    8020019a:	aea50513          	addi	a0,a0,-1302 # 80200c80 <etext+0x24e>
    8020019e:	ecfff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  tp       0x%08x\n", gpr->tp);
    802001a2:	700c                	ld	a1,32(s0)
    802001a4:	00001517          	auipc	a0,0x1
    802001a8:	af450513          	addi	a0,a0,-1292 # 80200c98 <etext+0x266>
    802001ac:	ec1ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  t0       0x%08x\n", gpr->t0);
    802001b0:	740c                	ld	a1,40(s0)
    802001b2:	00001517          	auipc	a0,0x1
    802001b6:	afe50513          	addi	a0,a0,-1282 # 80200cb0 <etext+0x27e>
    802001ba:	eb3ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  t1       0x%08x\n", gpr->t1);
    802001be:	780c                	ld	a1,48(s0)
    802001c0:	00001517          	auipc	a0,0x1
    802001c4:	b0850513          	addi	a0,a0,-1272 # 80200cc8 <etext+0x296>
    802001c8:	ea5ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  t2       0x%08x\n", gpr->t2);
    802001cc:	7c0c                	ld	a1,56(s0)
    802001ce:	00001517          	auipc	a0,0x1
    802001d2:	b1250513          	addi	a0,a0,-1262 # 80200ce0 <etext+0x2ae>
    802001d6:	e97ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  s0       0x%08x\n", gpr->s0);
    802001da:	602c                	ld	a1,64(s0)
    802001dc:	00001517          	auipc	a0,0x1
    802001e0:	b1c50513          	addi	a0,a0,-1252 # 80200cf8 <etext+0x2c6>
    802001e4:	e89ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  s1       0x%08x\n", gpr->s1);
    802001e8:	642c                	ld	a1,72(s0)
    802001ea:	00001517          	auipc	a0,0x1
    802001ee:	b2650513          	addi	a0,a0,-1242 # 80200d10 <etext+0x2de>
    802001f2:	e7bff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  a0       0x%08x\n", gpr->a0);
    802001f6:	682c                	ld	a1,80(s0)
    802001f8:	00001517          	auipc	a0,0x1
    802001fc:	b3050513          	addi	a0,a0,-1232 # 80200d28 <etext+0x2f6>
    80200200:	e6dff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  a1       0x%08x\n", gpr->a1);
    80200204:	6c2c                	ld	a1,88(s0)
    80200206:	00001517          	auipc	a0,0x1
    8020020a:	b3a50513          	addi	a0,a0,-1222 # 80200d40 <etext+0x30e>
    8020020e:	e5fff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  a2       0x%08x\n", gpr->a2);
    80200212:	702c                	ld	a1,96(s0)
    80200214:	00001517          	auipc	a0,0x1
    80200218:	b4450513          	addi	a0,a0,-1212 # 80200d58 <etext+0x326>
    8020021c:	e51ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  a3       0x%08x\n", gpr->a3);
    80200220:	742c                	ld	a1,104(s0)
    80200222:	00001517          	auipc	a0,0x1
    80200226:	b4e50513          	addi	a0,a0,-1202 # 80200d70 <etext+0x33e>
    8020022a:	e43ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  a4       0x%08x\n", gpr->a4);
    8020022e:	782c                	ld	a1,112(s0)
    80200230:	00001517          	auipc	a0,0x1
    80200234:	b5850513          	addi	a0,a0,-1192 # 80200d88 <etext+0x356>
    80200238:	e35ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  a5       0x%08x\n", gpr->a5);
    8020023c:	7c2c                	ld	a1,120(s0)
    8020023e:	00001517          	auipc	a0,0x1
    80200242:	b6250513          	addi	a0,a0,-1182 # 80200da0 <etext+0x36e>
    80200246:	e27ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  a6       0x%08x\n", gpr->a6);
    8020024a:	604c                	ld	a1,128(s0)
    8020024c:	00001517          	auipc	a0,0x1
    80200250:	b6c50513          	addi	a0,a0,-1172 # 80200db8 <etext+0x386>
    80200254:	e19ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  a7       0x%08x\n", gpr->a7);
    80200258:	644c                	ld	a1,136(s0)
    8020025a:	00001517          	auipc	a0,0x1
    8020025e:	b7650513          	addi	a0,a0,-1162 # 80200dd0 <etext+0x39e>
    80200262:	e0bff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  s2       0x%08x\n", gpr->s2);
    80200266:	684c                	ld	a1,144(s0)
    80200268:	00001517          	auipc	a0,0x1
    8020026c:	b8050513          	addi	a0,a0,-1152 # 80200de8 <etext+0x3b6>
    80200270:	dfdff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  s3       0x%08x\n", gpr->s3);
    80200274:	6c4c                	ld	a1,152(s0)
    80200276:	00001517          	auipc	a0,0x1
    8020027a:	b8a50513          	addi	a0,a0,-1142 # 80200e00 <etext+0x3ce>
    8020027e:	defff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  s4       0x%08x\n", gpr->s4);
    80200282:	704c                	ld	a1,160(s0)
    80200284:	00001517          	auipc	a0,0x1
    80200288:	b9450513          	addi	a0,a0,-1132 # 80200e18 <etext+0x3e6>
    8020028c:	de1ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  s5       0x%08x\n", gpr->s5);
    80200290:	744c                	ld	a1,168(s0)
    80200292:	00001517          	auipc	a0,0x1
    80200296:	b9e50513          	addi	a0,a0,-1122 # 80200e30 <etext+0x3fe>
    8020029a:	dd3ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  s6       0x%08x\n", gpr->s6);
    8020029e:	784c                	ld	a1,176(s0)
    802002a0:	00001517          	auipc	a0,0x1
    802002a4:	ba850513          	addi	a0,a0,-1112 # 80200e48 <etext+0x416>
    802002a8:	dc5ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  s7       0x%08x\n", gpr->s7);
    802002ac:	7c4c                	ld	a1,184(s0)
    802002ae:	00001517          	auipc	a0,0x1
    802002b2:	bb250513          	addi	a0,a0,-1102 # 80200e60 <etext+0x42e>
    802002b6:	db7ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  s8       0x%08x\n", gpr->s8);
    802002ba:	606c                	ld	a1,192(s0)
    802002bc:	00001517          	auipc	a0,0x1
    802002c0:	bbc50513          	addi	a0,a0,-1092 # 80200e78 <etext+0x446>
    802002c4:	da9ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  s9       0x%08x\n", gpr->s9);
    802002c8:	646c                	ld	a1,200(s0)
    802002ca:	00001517          	auipc	a0,0x1
    802002ce:	bc650513          	addi	a0,a0,-1082 # 80200e90 <etext+0x45e>
    802002d2:	d9bff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  s10      0x%08x\n", gpr->s10);
    802002d6:	686c                	ld	a1,208(s0)
    802002d8:	00001517          	auipc	a0,0x1
    802002dc:	bd050513          	addi	a0,a0,-1072 # 80200ea8 <etext+0x476>
    802002e0:	d8dff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  s11      0x%08x\n", gpr->s11);
    802002e4:	6c6c                	ld	a1,216(s0)
    802002e6:	00001517          	auipc	a0,0x1
    802002ea:	bda50513          	addi	a0,a0,-1062 # 80200ec0 <etext+0x48e>
    802002ee:	d7fff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  t3       0x%08x\n", gpr->t3);
    802002f2:	706c                	ld	a1,224(s0)
    802002f4:	00001517          	auipc	a0,0x1
    802002f8:	be450513          	addi	a0,a0,-1052 # 80200ed8 <etext+0x4a6>
    802002fc:	d71ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  t4       0x%08x\n", gpr->t4);
    80200300:	746c                	ld	a1,232(s0)
    80200302:	00001517          	auipc	a0,0x1
    80200306:	bee50513          	addi	a0,a0,-1042 # 80200ef0 <etext+0x4be>
    8020030a:	d63ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  t5       0x%08x\n", gpr->t5);
    8020030e:	786c                	ld	a1,240(s0)
    80200310:	00001517          	auipc	a0,0x1
    80200314:	bf850513          	addi	a0,a0,-1032 # 80200f08 <etext+0x4d6>
    80200318:	d55ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  t6       0x%08x\n", gpr->t6);
    8020031c:	7c6c                	ld	a1,248(s0)
}
    8020031e:	6402                	ld	s0,0(sp)
    80200320:	60a2                	ld	ra,8(sp)
    cprintf("  t6       0x%08x\n", gpr->t6);
    80200322:	00001517          	auipc	a0,0x1
    80200326:	bfe50513          	addi	a0,a0,-1026 # 80200f20 <etext+0x4ee>
}
    8020032a:	0141                	addi	sp,sp,16
    cprintf("  t6       0x%08x\n", gpr->t6);
    8020032c:	d41ff06f          	j	8020006c <cprintf>

0000000080200330 <print_trapframe>:
void print_trapframe(struct trapframe *tf) {
    80200330:	1141                	addi	sp,sp,-16
    80200332:	e022                	sd	s0,0(sp)
    cprintf("trapframe at %p\n", tf);
    80200334:	85aa                	mv	a1,a0
void print_trapframe(struct trapframe *tf) {
    80200336:	842a                	mv	s0,a0
    cprintf("trapframe at %p\n", tf);
    80200338:	00001517          	auipc	a0,0x1
    8020033c:	c0050513          	addi	a0,a0,-1024 # 80200f38 <etext+0x506>
void print_trapframe(struct trapframe *tf) {
    80200340:	e406                	sd	ra,8(sp)
    cprintf("trapframe at %p\n", tf);
    80200342:	d2bff0ef          	jal	ra,8020006c <cprintf>
    print_regs(&tf->gpr);
    80200346:	8522                	mv	a0,s0
    80200348:	e1bff0ef          	jal	ra,80200162 <print_regs>
    cprintf("  status   0x%08x\n", tf->status);
    8020034c:	10043583          	ld	a1,256(s0)
    80200350:	00001517          	auipc	a0,0x1
    80200354:	c0050513          	addi	a0,a0,-1024 # 80200f50 <etext+0x51e>
    80200358:	d15ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  epc      0x%08x\n", tf->epc);
    8020035c:	10843583          	ld	a1,264(s0)
    80200360:	00001517          	auipc	a0,0x1
    80200364:	c0850513          	addi	a0,a0,-1016 # 80200f68 <etext+0x536>
    80200368:	d05ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
    8020036c:	11043583          	ld	a1,272(s0)
    80200370:	00001517          	auipc	a0,0x1
    80200374:	c1050513          	addi	a0,a0,-1008 # 80200f80 <etext+0x54e>
    80200378:	cf5ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  cause    0x%08x\n", tf->cause);
    8020037c:	11843583          	ld	a1,280(s0)
}
    80200380:	6402                	ld	s0,0(sp)
    80200382:	60a2                	ld	ra,8(sp)
    cprintf("  cause    0x%08x\n", tf->cause);
    80200384:	00001517          	auipc	a0,0x1
    80200388:	c1450513          	addi	a0,a0,-1004 # 80200f98 <etext+0x566>
}
    8020038c:	0141                	addi	sp,sp,16
    cprintf("  cause    0x%08x\n", tf->cause);
    8020038e:	cdfff06f          	j	8020006c <cprintf>

0000000080200392 <interrupt_handler>:

void interrupt_handler(struct trapframe *tf) {
    intptr_t cause = (tf->cause << 1) >> 1;
    80200392:	11853783          	ld	a5,280(a0)
    80200396:	577d                	li	a4,-1
    80200398:	8305                	srli	a4,a4,0x1
    8020039a:	8ff9                	and	a5,a5,a4
    switch (cause) {
    8020039c:	472d                	li	a4,11
    8020039e:	06f76f63          	bltu	a4,a5,8020041c <interrupt_handler+0x8a>
    802003a2:	00000717          	auipc	a4,0x0
    802003a6:	78a70713          	addi	a4,a4,1930 # 80200b2c <etext+0xfa>
    802003aa:	078a                	slli	a5,a5,0x2
    802003ac:	97ba                	add	a5,a5,a4
    802003ae:	439c                	lw	a5,0(a5)
    802003b0:	97ba                	add	a5,a5,a4
    802003b2:	8782                	jr	a5
            break;
        case IRQ_H_SOFT:
            cprintf("Hypervisor software interrupt\n");
            break;
        case IRQ_M_SOFT:
            cprintf("Machine software interrupt\n");
    802003b4:	00001517          	auipc	a0,0x1
    802003b8:	83450513          	addi	a0,a0,-1996 # 80200be8 <etext+0x1b6>
    802003bc:	cb1ff06f          	j	8020006c <cprintf>
            cprintf("Hypervisor software interrupt\n");
    802003c0:	00001517          	auipc	a0,0x1
    802003c4:	80850513          	addi	a0,a0,-2040 # 80200bc8 <etext+0x196>
    802003c8:	ca5ff06f          	j	8020006c <cprintf>
            cprintf("User software interrupt\n");
    802003cc:	00000517          	auipc	a0,0x0
    802003d0:	7bc50513          	addi	a0,a0,1980 # 80200b88 <etext+0x156>
    802003d4:	c99ff06f          	j	8020006c <cprintf>
            cprintf("Supervisor software interrupt\n");
    802003d8:	00000517          	auipc	a0,0x0
    802003dc:	7d050513          	addi	a0,a0,2000 # 80200ba8 <etext+0x176>
    802003e0:	c8dff06f          	j	8020006c <cprintf>
            break;
        case IRQ_U_EXT:
            cprintf("User software interrupt\n");
            break;
        case IRQ_S_EXT:
            cprintf("Supervisor external interrupt\n");
    802003e4:	00001517          	auipc	a0,0x1
    802003e8:	83450513          	addi	a0,a0,-1996 # 80200c18 <etext+0x1e6>
    802003ec:	c81ff06f          	j	8020006c <cprintf>
void interrupt_handler(struct trapframe *tf) {
    802003f0:	1141                	addi	sp,sp,-16
    802003f2:	e406                	sd	ra,8(sp)
            clock_set_next_event();
    802003f4:	d3dff0ef          	jal	ra,80200130 <clock_set_next_event>
            if (++ticks % TICK_NUM == 0) {
    802003f8:	00004797          	auipc	a5,0x4
    802003fc:	c2878793          	addi	a5,a5,-984 # 80204020 <ticks>
    80200400:	639c                	ld	a5,0(a5)
    80200402:	06400713          	li	a4,100
    80200406:	0785                	addi	a5,a5,1
    80200408:	02e7f733          	remu	a4,a5,a4
    8020040c:	00004697          	auipc	a3,0x4
    80200410:	c0f6ba23          	sd	a5,-1004(a3) # 80204020 <ticks>
    80200414:	c711                	beqz	a4,80200420 <interrupt_handler+0x8e>
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
    80200416:	60a2                	ld	ra,8(sp)
    80200418:	0141                	addi	sp,sp,16
    8020041a:	8082                	ret
            print_trapframe(tf);
    8020041c:	f15ff06f          	j	80200330 <print_trapframe>
    cprintf("%d ticks\n", TICK_NUM);
    80200420:	06400593          	li	a1,100
    80200424:	00000517          	auipc	a0,0x0
    80200428:	7e450513          	addi	a0,a0,2020 # 80200c08 <etext+0x1d6>
    8020042c:	c41ff0ef          	jal	ra,8020006c <cprintf>
                if(++num == 10){
    80200430:	00004797          	auipc	a5,0x4
    80200434:	be078793          	addi	a5,a5,-1056 # 80204010 <edata>
    80200438:	639c                	ld	a5,0(a5)
    8020043a:	4729                	li	a4,10
    8020043c:	0785                	addi	a5,a5,1
    8020043e:	00004697          	auipc	a3,0x4
    80200442:	bcf6b923          	sd	a5,-1070(a3) # 80204010 <edata>
    80200446:	fce798e3          	bne	a5,a4,80200416 <interrupt_handler+0x84>
}
    8020044a:	60a2                	ld	ra,8(sp)
    8020044c:	0141                	addi	sp,sp,16
                  sbi_shutdown();
    8020044e:	5900006f          	j	802009de <sbi_shutdown>

0000000080200452 <exception_handler>:

void exception_handler(struct trapframe *tf) {
    switch (tf->cause) {
    80200452:	11853783          	ld	a5,280(a0)
    80200456:	472d                	li	a4,11
    80200458:	02f76863          	bltu	a4,a5,80200488 <exception_handler+0x36>
    8020045c:	4705                	li	a4,1
    8020045e:	00f71733          	sll	a4,a4,a5
    80200462:	6785                	lui	a5,0x1
    80200464:	17cd                	addi	a5,a5,-13
    80200466:	8ff9                	and	a5,a5,a4
    80200468:	ef99                	bnez	a5,80200486 <exception_handler+0x34>
void exception_handler(struct trapframe *tf) {
    8020046a:	1141                	addi	sp,sp,-16
    8020046c:	e022                	sd	s0,0(sp)
    8020046e:	e406                	sd	ra,8(sp)
    80200470:	00877793          	andi	a5,a4,8
    80200474:	842a                	mv	s0,a0
    80200476:	e3b1                	bnez	a5,802004ba <exception_handler+0x68>
    80200478:	8b11                	andi	a4,a4,4
    8020047a:	eb09                	bnez	a4,8020048c <exception_handler+0x3a>
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
    8020047c:	6402                	ld	s0,0(sp)
    8020047e:	60a2                	ld	ra,8(sp)
    80200480:	0141                	addi	sp,sp,16
            print_trapframe(tf);
    80200482:	eafff06f          	j	80200330 <print_trapframe>
    80200486:	8082                	ret
    80200488:	ea9ff06f          	j	80200330 <print_trapframe>
            cprintf("Illegal instruction\n");
    8020048c:	00000517          	auipc	a0,0x0
    80200490:	6d450513          	addi	a0,a0,1748 # 80200b60 <etext+0x12e>
    80200494:	bd9ff0ef          	jal	ra,8020006c <cprintf>
            cprintf("  epc      0x%08x\n", tf->epc);
    80200498:	10843583          	ld	a1,264(s0)
    8020049c:	00001517          	auipc	a0,0x1
    802004a0:	acc50513          	addi	a0,a0,-1332 # 80200f68 <etext+0x536>
    802004a4:	bc9ff0ef          	jal	ra,8020006c <cprintf>
            tf->epc += 4;
    802004a8:	10843783          	ld	a5,264(s0)
}
    802004ac:	60a2                	ld	ra,8(sp)
            tf->epc += 4;
    802004ae:	0791                	addi	a5,a5,4
    802004b0:	10f43423          	sd	a5,264(s0)
}
    802004b4:	6402                	ld	s0,0(sp)
    802004b6:	0141                	addi	sp,sp,16
    802004b8:	8082                	ret
            cprintf("breakpoint\n");
    802004ba:	00000517          	auipc	a0,0x0
    802004be:	6be50513          	addi	a0,a0,1726 # 80200b78 <etext+0x146>
    802004c2:	babff0ef          	jal	ra,8020006c <cprintf>
            cprintf("  epc      0x%08x\n", tf->epc);
    802004c6:	10843583          	ld	a1,264(s0)
    802004ca:	00001517          	auipc	a0,0x1
    802004ce:	a9e50513          	addi	a0,a0,-1378 # 80200f68 <etext+0x536>
    802004d2:	b9bff0ef          	jal	ra,8020006c <cprintf>
            tf->epc += 2;
    802004d6:	10843783          	ld	a5,264(s0)
}
    802004da:	60a2                	ld	ra,8(sp)
            tf->epc += 2;
    802004dc:	0789                	addi	a5,a5,2
    802004de:	10f43423          	sd	a5,264(s0)
}
    802004e2:	6402                	ld	s0,0(sp)
    802004e4:	0141                	addi	sp,sp,16
    802004e6:	8082                	ret

00000000802004e8 <trap>:

/* trap_dispatch - dispatch based on what type of trap occurred */
static inline void trap_dispatch(struct trapframe *tf) {
    if ((intptr_t)tf->cause < 0) {
    802004e8:	11853783          	ld	a5,280(a0)
    802004ec:	0007c463          	bltz	a5,802004f4 <trap+0xc>
        // interrupts
        interrupt_handler(tf);
    } else {
        // exceptions
        exception_handler(tf);
    802004f0:	f63ff06f          	j	80200452 <exception_handler>
        interrupt_handler(tf);
    802004f4:	e9fff06f          	j	80200392 <interrupt_handler>

00000000802004f8 <__alltraps>:
    .endm

    .globl __alltraps
.align(2)
__alltraps:
    SAVE_ALL
    802004f8:	14011073          	csrw	sscratch,sp
    802004fc:	712d                	addi	sp,sp,-288
    802004fe:	e002                	sd	zero,0(sp)
    80200500:	e406                	sd	ra,8(sp)
    80200502:	ec0e                	sd	gp,24(sp)
    80200504:	f012                	sd	tp,32(sp)
    80200506:	f416                	sd	t0,40(sp)
    80200508:	f81a                	sd	t1,48(sp)
    8020050a:	fc1e                	sd	t2,56(sp)
    8020050c:	e0a2                	sd	s0,64(sp)
    8020050e:	e4a6                	sd	s1,72(sp)
    80200510:	e8aa                	sd	a0,80(sp)
    80200512:	ecae                	sd	a1,88(sp)
    80200514:	f0b2                	sd	a2,96(sp)
    80200516:	f4b6                	sd	a3,104(sp)
    80200518:	f8ba                	sd	a4,112(sp)
    8020051a:	fcbe                	sd	a5,120(sp)
    8020051c:	e142                	sd	a6,128(sp)
    8020051e:	e546                	sd	a7,136(sp)
    80200520:	e94a                	sd	s2,144(sp)
    80200522:	ed4e                	sd	s3,152(sp)
    80200524:	f152                	sd	s4,160(sp)
    80200526:	f556                	sd	s5,168(sp)
    80200528:	f95a                	sd	s6,176(sp)
    8020052a:	fd5e                	sd	s7,184(sp)
    8020052c:	e1e2                	sd	s8,192(sp)
    8020052e:	e5e6                	sd	s9,200(sp)
    80200530:	e9ea                	sd	s10,208(sp)
    80200532:	edee                	sd	s11,216(sp)
    80200534:	f1f2                	sd	t3,224(sp)
    80200536:	f5f6                	sd	t4,232(sp)
    80200538:	f9fa                	sd	t5,240(sp)
    8020053a:	fdfe                	sd	t6,248(sp)
    8020053c:	14001473          	csrrw	s0,sscratch,zero
    80200540:	100024f3          	csrr	s1,sstatus
    80200544:	14102973          	csrr	s2,sepc
    80200548:	143029f3          	csrr	s3,stval
    8020054c:	14202a73          	csrr	s4,scause
    80200550:	e822                	sd	s0,16(sp)
    80200552:	e226                	sd	s1,256(sp)
    80200554:	e64a                	sd	s2,264(sp)
    80200556:	ea4e                	sd	s3,272(sp)
    80200558:	ee52                	sd	s4,280(sp)

    move  a0, sp
    8020055a:	850a                	mv	a0,sp
    jal trap
    8020055c:	f8dff0ef          	jal	ra,802004e8 <trap>

0000000080200560 <__trapret>:
    # sp should be the same as before "jal trap"

    .globl __trapret
__trapret:
    RESTORE_ALL
    80200560:	6492                	ld	s1,256(sp)
    80200562:	6932                	ld	s2,264(sp)
    80200564:	10049073          	csrw	sstatus,s1
    80200568:	14191073          	csrw	sepc,s2
    8020056c:	60a2                	ld	ra,8(sp)
    8020056e:	61e2                	ld	gp,24(sp)
    80200570:	7202                	ld	tp,32(sp)
    80200572:	72a2                	ld	t0,40(sp)
    80200574:	7342                	ld	t1,48(sp)
    80200576:	73e2                	ld	t2,56(sp)
    80200578:	6406                	ld	s0,64(sp)
    8020057a:	64a6                	ld	s1,72(sp)
    8020057c:	6546                	ld	a0,80(sp)
    8020057e:	65e6                	ld	a1,88(sp)
    80200580:	7606                	ld	a2,96(sp)
    80200582:	76a6                	ld	a3,104(sp)
    80200584:	7746                	ld	a4,112(sp)
    80200586:	77e6                	ld	a5,120(sp)
    80200588:	680a                	ld	a6,128(sp)
    8020058a:	68aa                	ld	a7,136(sp)
    8020058c:	694a                	ld	s2,144(sp)
    8020058e:	69ea                	ld	s3,152(sp)
    80200590:	7a0a                	ld	s4,160(sp)
    80200592:	7aaa                	ld	s5,168(sp)
    80200594:	7b4a                	ld	s6,176(sp)
    80200596:	7bea                	ld	s7,184(sp)
    80200598:	6c0e                	ld	s8,192(sp)
    8020059a:	6cae                	ld	s9,200(sp)
    8020059c:	6d4e                	ld	s10,208(sp)
    8020059e:	6dee                	ld	s11,216(sp)
    802005a0:	7e0e                	ld	t3,224(sp)
    802005a2:	7eae                	ld	t4,232(sp)
    802005a4:	7f4e                	ld	t5,240(sp)
    802005a6:	7fee                	ld	t6,248(sp)
    802005a8:	6142                	ld	sp,16(sp)
    # return from supervisor call
    sret
    802005aa:	10200073          	sret

00000000802005ae <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
    802005ae:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
    802005b2:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
    802005b4:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
    802005b8:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
    802005ba:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
    802005be:	f022                	sd	s0,32(sp)
    802005c0:	ec26                	sd	s1,24(sp)
    802005c2:	e84a                	sd	s2,16(sp)
    802005c4:	f406                	sd	ra,40(sp)
    802005c6:	e44e                	sd	s3,8(sp)
    802005c8:	84aa                	mv	s1,a0
    802005ca:	892e                	mv	s2,a1
    802005cc:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
    802005d0:	2a01                	sext.w	s4,s4

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
    802005d2:	03067e63          	bleu	a6,a2,8020060e <printnum+0x60>
    802005d6:	89be                	mv	s3,a5
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
    802005d8:	00805763          	blez	s0,802005e6 <printnum+0x38>
    802005dc:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
    802005de:	85ca                	mv	a1,s2
    802005e0:	854e                	mv	a0,s3
    802005e2:	9482                	jalr	s1
        while (-- width > 0)
    802005e4:	fc65                	bnez	s0,802005dc <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
    802005e6:	1a02                	slli	s4,s4,0x20
    802005e8:	020a5a13          	srli	s4,s4,0x20
    802005ec:	00001797          	auipc	a5,0x1
    802005f0:	b5478793          	addi	a5,a5,-1196 # 80201140 <error_string+0x38>
    802005f4:	9a3e                	add	s4,s4,a5
}
    802005f6:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
    802005f8:	000a4503          	lbu	a0,0(s4)
}
    802005fc:	70a2                	ld	ra,40(sp)
    802005fe:	69a2                	ld	s3,8(sp)
    80200600:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
    80200602:	85ca                	mv	a1,s2
    80200604:	8326                	mv	t1,s1
}
    80200606:	6942                	ld	s2,16(sp)
    80200608:	64e2                	ld	s1,24(sp)
    8020060a:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
    8020060c:	8302                	jr	t1
        printnum(putch, putdat, result, base, width - 1, padc);
    8020060e:	03065633          	divu	a2,a2,a6
    80200612:	8722                	mv	a4,s0
    80200614:	f9bff0ef          	jal	ra,802005ae <printnum>
    80200618:	b7f9                	j	802005e6 <printnum+0x38>

000000008020061a <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
    8020061a:	7119                	addi	sp,sp,-128
    8020061c:	f4a6                	sd	s1,104(sp)
    8020061e:	f0ca                	sd	s2,96(sp)
    80200620:	e8d2                	sd	s4,80(sp)
    80200622:	e4d6                	sd	s5,72(sp)
    80200624:	e0da                	sd	s6,64(sp)
    80200626:	fc5e                	sd	s7,56(sp)
    80200628:	f862                	sd	s8,48(sp)
    8020062a:	f06a                	sd	s10,32(sp)
    8020062c:	fc86                	sd	ra,120(sp)
    8020062e:	f8a2                	sd	s0,112(sp)
    80200630:	ecce                	sd	s3,88(sp)
    80200632:	f466                	sd	s9,40(sp)
    80200634:	ec6e                	sd	s11,24(sp)
    80200636:	892a                	mv	s2,a0
    80200638:	84ae                	mv	s1,a1
    8020063a:	8d32                	mv	s10,a2
    8020063c:	8ab6                	mv	s5,a3
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
    8020063e:	5b7d                	li	s6,-1
        lflag = altflag = 0;

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
    80200640:	00001a17          	auipc	s4,0x1
    80200644:	96ca0a13          	addi	s4,s4,-1684 # 80200fac <etext+0x57a>
                for (width -= strnlen(p, precision); width > 0; width --) {
                    putch(padc, putdat);
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
                if (altflag && (ch < ' ' || ch > '~')) {
    80200648:	05e00b93          	li	s7,94
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
    8020064c:	00001c17          	auipc	s8,0x1
    80200650:	abcc0c13          	addi	s8,s8,-1348 # 80201108 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
    80200654:	000d4503          	lbu	a0,0(s10)
    80200658:	02500793          	li	a5,37
    8020065c:	001d0413          	addi	s0,s10,1
    80200660:	00f50e63          	beq	a0,a5,8020067c <vprintfmt+0x62>
            if (ch == '\0') {
    80200664:	c521                	beqz	a0,802006ac <vprintfmt+0x92>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
    80200666:	02500993          	li	s3,37
    8020066a:	a011                	j	8020066e <vprintfmt+0x54>
            if (ch == '\0') {
    8020066c:	c121                	beqz	a0,802006ac <vprintfmt+0x92>
            putch(ch, putdat);
    8020066e:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
    80200670:	0405                	addi	s0,s0,1
            putch(ch, putdat);
    80200672:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
    80200674:	fff44503          	lbu	a0,-1(s0)
    80200678:	ff351ae3          	bne	a0,s3,8020066c <vprintfmt+0x52>
    8020067c:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
    80200680:	02000793          	li	a5,32
        lflag = altflag = 0;
    80200684:	4981                	li	s3,0
    80200686:	4801                	li	a6,0
        width = precision = -1;
    80200688:	5cfd                	li	s9,-1
    8020068a:	5dfd                	li	s11,-1
        switch (ch = *(unsigned char *)fmt ++) {
    8020068c:	05500593          	li	a1,85
                if (ch < '0' || ch > '9') {
    80200690:	4525                	li	a0,9
        switch (ch = *(unsigned char *)fmt ++) {
    80200692:	fdd6069b          	addiw	a3,a2,-35
    80200696:	0ff6f693          	andi	a3,a3,255
    8020069a:	00140d13          	addi	s10,s0,1
    8020069e:	20d5e563          	bltu	a1,a3,802008a8 <vprintfmt+0x28e>
    802006a2:	068a                	slli	a3,a3,0x2
    802006a4:	96d2                	add	a3,a3,s4
    802006a6:	4294                	lw	a3,0(a3)
    802006a8:	96d2                	add	a3,a3,s4
    802006aa:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
    802006ac:	70e6                	ld	ra,120(sp)
    802006ae:	7446                	ld	s0,112(sp)
    802006b0:	74a6                	ld	s1,104(sp)
    802006b2:	7906                	ld	s2,96(sp)
    802006b4:	69e6                	ld	s3,88(sp)
    802006b6:	6a46                	ld	s4,80(sp)
    802006b8:	6aa6                	ld	s5,72(sp)
    802006ba:	6b06                	ld	s6,64(sp)
    802006bc:	7be2                	ld	s7,56(sp)
    802006be:	7c42                	ld	s8,48(sp)
    802006c0:	7ca2                	ld	s9,40(sp)
    802006c2:	7d02                	ld	s10,32(sp)
    802006c4:	6de2                	ld	s11,24(sp)
    802006c6:	6109                	addi	sp,sp,128
    802006c8:	8082                	ret
    if (lflag >= 2) {
    802006ca:	4705                	li	a4,1
    802006cc:	008a8593          	addi	a1,s5,8
    802006d0:	01074463          	blt	a4,a6,802006d8 <vprintfmt+0xbe>
    else if (lflag) {
    802006d4:	26080363          	beqz	a6,8020093a <vprintfmt+0x320>
        return va_arg(*ap, unsigned long);
    802006d8:	000ab603          	ld	a2,0(s5)
    802006dc:	46c1                	li	a3,16
    802006de:	8aae                	mv	s5,a1
    802006e0:	a06d                	j	8020078a <vprintfmt+0x170>
            goto reswitch;
    802006e2:	00144603          	lbu	a2,1(s0)
            altflag = 1;
    802006e6:	4985                	li	s3,1
        switch (ch = *(unsigned char *)fmt ++) {
    802006e8:	846a                	mv	s0,s10
            goto reswitch;
    802006ea:	b765                	j	80200692 <vprintfmt+0x78>
            putch(va_arg(ap, int), putdat);
    802006ec:	000aa503          	lw	a0,0(s5)
    802006f0:	85a6                	mv	a1,s1
    802006f2:	0aa1                	addi	s5,s5,8
    802006f4:	9902                	jalr	s2
            break;
    802006f6:	bfb9                	j	80200654 <vprintfmt+0x3a>
    if (lflag >= 2) {
    802006f8:	4705                	li	a4,1
    802006fa:	008a8993          	addi	s3,s5,8
    802006fe:	01074463          	blt	a4,a6,80200706 <vprintfmt+0xec>
    else if (lflag) {
    80200702:	22080463          	beqz	a6,8020092a <vprintfmt+0x310>
        return va_arg(*ap, long);
    80200706:	000ab403          	ld	s0,0(s5)
            if ((long long)num < 0) {
    8020070a:	24044463          	bltz	s0,80200952 <vprintfmt+0x338>
            num = getint(&ap, lflag);
    8020070e:	8622                	mv	a2,s0
    80200710:	8ace                	mv	s5,s3
    80200712:	46a9                	li	a3,10
    80200714:	a89d                	j	8020078a <vprintfmt+0x170>
            err = va_arg(ap, int);
    80200716:	000aa783          	lw	a5,0(s5)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
    8020071a:	4719                	li	a4,6
            err = va_arg(ap, int);
    8020071c:	0aa1                	addi	s5,s5,8
            if (err < 0) {
    8020071e:	41f7d69b          	sraiw	a3,a5,0x1f
    80200722:	8fb5                	xor	a5,a5,a3
    80200724:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
    80200728:	1ad74363          	blt	a4,a3,802008ce <vprintfmt+0x2b4>
    8020072c:	00369793          	slli	a5,a3,0x3
    80200730:	97e2                	add	a5,a5,s8
    80200732:	639c                	ld	a5,0(a5)
    80200734:	18078d63          	beqz	a5,802008ce <vprintfmt+0x2b4>
                printfmt(putch, putdat, "%s", p);
    80200738:	86be                	mv	a3,a5
    8020073a:	00001617          	auipc	a2,0x1
    8020073e:	ab660613          	addi	a2,a2,-1354 # 802011f0 <error_string+0xe8>
    80200742:	85a6                	mv	a1,s1
    80200744:	854a                	mv	a0,s2
    80200746:	240000ef          	jal	ra,80200986 <printfmt>
    8020074a:	b729                	j	80200654 <vprintfmt+0x3a>
            lflag ++;
    8020074c:	00144603          	lbu	a2,1(s0)
    80200750:	2805                	addiw	a6,a6,1
        switch (ch = *(unsigned char *)fmt ++) {
    80200752:	846a                	mv	s0,s10
            goto reswitch;
    80200754:	bf3d                	j	80200692 <vprintfmt+0x78>
    if (lflag >= 2) {
    80200756:	4705                	li	a4,1
    80200758:	008a8593          	addi	a1,s5,8
    8020075c:	01074463          	blt	a4,a6,80200764 <vprintfmt+0x14a>
    else if (lflag) {
    80200760:	1e080263          	beqz	a6,80200944 <vprintfmt+0x32a>
        return va_arg(*ap, unsigned long);
    80200764:	000ab603          	ld	a2,0(s5)
    80200768:	46a1                	li	a3,8
    8020076a:	8aae                	mv	s5,a1
    8020076c:	a839                	j	8020078a <vprintfmt+0x170>
            putch('0', putdat);
    8020076e:	03000513          	li	a0,48
    80200772:	85a6                	mv	a1,s1
    80200774:	e03e                	sd	a5,0(sp)
    80200776:	9902                	jalr	s2
            putch('x', putdat);
    80200778:	85a6                	mv	a1,s1
    8020077a:	07800513          	li	a0,120
    8020077e:	9902                	jalr	s2
            num = (unsigned long long)va_arg(ap, void *);
    80200780:	0aa1                	addi	s5,s5,8
    80200782:	ff8ab603          	ld	a2,-8(s5)
            goto number;
    80200786:	6782                	ld	a5,0(sp)
    80200788:	46c1                	li	a3,16
            printnum(putch, putdat, num, base, width, padc);
    8020078a:	876e                	mv	a4,s11
    8020078c:	85a6                	mv	a1,s1
    8020078e:	854a                	mv	a0,s2
    80200790:	e1fff0ef          	jal	ra,802005ae <printnum>
            break;
    80200794:	b5c1                	j	80200654 <vprintfmt+0x3a>
            if ((p = va_arg(ap, char *)) == NULL) {
    80200796:	000ab603          	ld	a2,0(s5)
    8020079a:	0aa1                	addi	s5,s5,8
    8020079c:	1c060663          	beqz	a2,80200968 <vprintfmt+0x34e>
            if (width > 0 && padc != '-') {
    802007a0:	00160413          	addi	s0,a2,1
    802007a4:	17b05c63          	blez	s11,8020091c <vprintfmt+0x302>
    802007a8:	02d00593          	li	a1,45
    802007ac:	14b79263          	bne	a5,a1,802008f0 <vprintfmt+0x2d6>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
    802007b0:	00064783          	lbu	a5,0(a2)
    802007b4:	0007851b          	sext.w	a0,a5
    802007b8:	c905                	beqz	a0,802007e8 <vprintfmt+0x1ce>
    802007ba:	000cc563          	bltz	s9,802007c4 <vprintfmt+0x1aa>
    802007be:	3cfd                	addiw	s9,s9,-1
    802007c0:	036c8263          	beq	s9,s6,802007e4 <vprintfmt+0x1ca>
                    putch('?', putdat);
    802007c4:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
    802007c6:	18098463          	beqz	s3,8020094e <vprintfmt+0x334>
    802007ca:	3781                	addiw	a5,a5,-32
    802007cc:	18fbf163          	bleu	a5,s7,8020094e <vprintfmt+0x334>
                    putch('?', putdat);
    802007d0:	03f00513          	li	a0,63
    802007d4:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
    802007d6:	0405                	addi	s0,s0,1
    802007d8:	fff44783          	lbu	a5,-1(s0)
    802007dc:	3dfd                	addiw	s11,s11,-1
    802007de:	0007851b          	sext.w	a0,a5
    802007e2:	fd61                	bnez	a0,802007ba <vprintfmt+0x1a0>
            for (; width > 0; width --) {
    802007e4:	e7b058e3          	blez	s11,80200654 <vprintfmt+0x3a>
    802007e8:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
    802007ea:	85a6                	mv	a1,s1
    802007ec:	02000513          	li	a0,32
    802007f0:	9902                	jalr	s2
            for (; width > 0; width --) {
    802007f2:	e60d81e3          	beqz	s11,80200654 <vprintfmt+0x3a>
    802007f6:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
    802007f8:	85a6                	mv	a1,s1
    802007fa:	02000513          	li	a0,32
    802007fe:	9902                	jalr	s2
            for (; width > 0; width --) {
    80200800:	fe0d94e3          	bnez	s11,802007e8 <vprintfmt+0x1ce>
    80200804:	bd81                	j	80200654 <vprintfmt+0x3a>
    if (lflag >= 2) {
    80200806:	4705                	li	a4,1
    80200808:	008a8593          	addi	a1,s5,8
    8020080c:	01074463          	blt	a4,a6,80200814 <vprintfmt+0x1fa>
    else if (lflag) {
    80200810:	12080063          	beqz	a6,80200930 <vprintfmt+0x316>
        return va_arg(*ap, unsigned long);
    80200814:	000ab603          	ld	a2,0(s5)
    80200818:	46a9                	li	a3,10
    8020081a:	8aae                	mv	s5,a1
    8020081c:	b7bd                	j	8020078a <vprintfmt+0x170>
    8020081e:	00144603          	lbu	a2,1(s0)
            padc = '-';
    80200822:	02d00793          	li	a5,45
        switch (ch = *(unsigned char *)fmt ++) {
    80200826:	846a                	mv	s0,s10
    80200828:	b5ad                	j	80200692 <vprintfmt+0x78>
            putch(ch, putdat);
    8020082a:	85a6                	mv	a1,s1
    8020082c:	02500513          	li	a0,37
    80200830:	9902                	jalr	s2
            break;
    80200832:	b50d                	j	80200654 <vprintfmt+0x3a>
            precision = va_arg(ap, int);
    80200834:	000aac83          	lw	s9,0(s5)
            goto process_precision;
    80200838:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
    8020083c:	0aa1                	addi	s5,s5,8
        switch (ch = *(unsigned char *)fmt ++) {
    8020083e:	846a                	mv	s0,s10
            if (width < 0)
    80200840:	e40dd9e3          	bgez	s11,80200692 <vprintfmt+0x78>
                width = precision, precision = -1;
    80200844:	8de6                	mv	s11,s9
    80200846:	5cfd                	li	s9,-1
    80200848:	b5a9                	j	80200692 <vprintfmt+0x78>
            goto reswitch;
    8020084a:	00144603          	lbu	a2,1(s0)
            padc = '0';
    8020084e:	03000793          	li	a5,48
        switch (ch = *(unsigned char *)fmt ++) {
    80200852:	846a                	mv	s0,s10
            goto reswitch;
    80200854:	bd3d                	j	80200692 <vprintfmt+0x78>
                precision = precision * 10 + ch - '0';
    80200856:	fd060c9b          	addiw	s9,a2,-48
                ch = *fmt;
    8020085a:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
    8020085e:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
    80200860:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
    80200864:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
    80200868:	fcd56ce3          	bltu	a0,a3,80200840 <vprintfmt+0x226>
            for (precision = 0; ; ++ fmt) {
    8020086c:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
    8020086e:	002c969b          	slliw	a3,s9,0x2
                ch = *fmt;
    80200872:	00044603          	lbu	a2,0(s0)
                precision = precision * 10 + ch - '0';
    80200876:	0196873b          	addw	a4,a3,s9
    8020087a:	0017171b          	slliw	a4,a4,0x1
    8020087e:	0117073b          	addw	a4,a4,a7
                if (ch < '0' || ch > '9') {
    80200882:	fd06069b          	addiw	a3,a2,-48
                precision = precision * 10 + ch - '0';
    80200886:	fd070c9b          	addiw	s9,a4,-48
                ch = *fmt;
    8020088a:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
    8020088e:	fcd57fe3          	bleu	a3,a0,8020086c <vprintfmt+0x252>
    80200892:	b77d                	j	80200840 <vprintfmt+0x226>
            if (width < 0)
    80200894:	fffdc693          	not	a3,s11
    80200898:	96fd                	srai	a3,a3,0x3f
    8020089a:	00ddfdb3          	and	s11,s11,a3
    8020089e:	00144603          	lbu	a2,1(s0)
    802008a2:	2d81                	sext.w	s11,s11
        switch (ch = *(unsigned char *)fmt ++) {
    802008a4:	846a                	mv	s0,s10
    802008a6:	b3f5                	j	80200692 <vprintfmt+0x78>
            putch('%', putdat);
    802008a8:	85a6                	mv	a1,s1
    802008aa:	02500513          	li	a0,37
    802008ae:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
    802008b0:	fff44703          	lbu	a4,-1(s0)
    802008b4:	02500793          	li	a5,37
    802008b8:	8d22                	mv	s10,s0
    802008ba:	d8f70de3          	beq	a4,a5,80200654 <vprintfmt+0x3a>
    802008be:	02500713          	li	a4,37
    802008c2:	1d7d                	addi	s10,s10,-1
    802008c4:	fffd4783          	lbu	a5,-1(s10)
    802008c8:	fee79de3          	bne	a5,a4,802008c2 <vprintfmt+0x2a8>
    802008cc:	b361                	j	80200654 <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
    802008ce:	00001617          	auipc	a2,0x1
    802008d2:	91260613          	addi	a2,a2,-1774 # 802011e0 <error_string+0xd8>
    802008d6:	85a6                	mv	a1,s1
    802008d8:	854a                	mv	a0,s2
    802008da:	0ac000ef          	jal	ra,80200986 <printfmt>
    802008de:	bb9d                	j	80200654 <vprintfmt+0x3a>
                p = "(null)";
    802008e0:	00001617          	auipc	a2,0x1
    802008e4:	8f860613          	addi	a2,a2,-1800 # 802011d8 <error_string+0xd0>
            if (width > 0 && padc != '-') {
    802008e8:	00001417          	auipc	s0,0x1
    802008ec:	8f140413          	addi	s0,s0,-1807 # 802011d9 <error_string+0xd1>
                for (width -= strnlen(p, precision); width > 0; width --) {
    802008f0:	8532                	mv	a0,a2
    802008f2:	85e6                	mv	a1,s9
    802008f4:	e032                	sd	a2,0(sp)
    802008f6:	e43e                	sd	a5,8(sp)
    802008f8:	102000ef          	jal	ra,802009fa <strnlen>
    802008fc:	40ad8dbb          	subw	s11,s11,a0
    80200900:	6602                	ld	a2,0(sp)
    80200902:	01b05d63          	blez	s11,8020091c <vprintfmt+0x302>
    80200906:	67a2                	ld	a5,8(sp)
    80200908:	2781                	sext.w	a5,a5
    8020090a:	e43e                	sd	a5,8(sp)
                    putch(padc, putdat);
    8020090c:	6522                	ld	a0,8(sp)
    8020090e:	85a6                	mv	a1,s1
    80200910:	e032                	sd	a2,0(sp)
                for (width -= strnlen(p, precision); width > 0; width --) {
    80200912:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
    80200914:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
    80200916:	6602                	ld	a2,0(sp)
    80200918:	fe0d9ae3          	bnez	s11,8020090c <vprintfmt+0x2f2>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
    8020091c:	00064783          	lbu	a5,0(a2)
    80200920:	0007851b          	sext.w	a0,a5
    80200924:	e8051be3          	bnez	a0,802007ba <vprintfmt+0x1a0>
    80200928:	b335                	j	80200654 <vprintfmt+0x3a>
        return va_arg(*ap, int);
    8020092a:	000aa403          	lw	s0,0(s5)
    8020092e:	bbf1                	j	8020070a <vprintfmt+0xf0>
        return va_arg(*ap, unsigned int);
    80200930:	000ae603          	lwu	a2,0(s5)
    80200934:	46a9                	li	a3,10
    80200936:	8aae                	mv	s5,a1
    80200938:	bd89                	j	8020078a <vprintfmt+0x170>
    8020093a:	000ae603          	lwu	a2,0(s5)
    8020093e:	46c1                	li	a3,16
    80200940:	8aae                	mv	s5,a1
    80200942:	b5a1                	j	8020078a <vprintfmt+0x170>
    80200944:	000ae603          	lwu	a2,0(s5)
    80200948:	46a1                	li	a3,8
    8020094a:	8aae                	mv	s5,a1
    8020094c:	bd3d                	j	8020078a <vprintfmt+0x170>
                    putch(ch, putdat);
    8020094e:	9902                	jalr	s2
    80200950:	b559                	j	802007d6 <vprintfmt+0x1bc>
                putch('-', putdat);
    80200952:	85a6                	mv	a1,s1
    80200954:	02d00513          	li	a0,45
    80200958:	e03e                	sd	a5,0(sp)
    8020095a:	9902                	jalr	s2
                num = -(long long)num;
    8020095c:	8ace                	mv	s5,s3
    8020095e:	40800633          	neg	a2,s0
    80200962:	46a9                	li	a3,10
    80200964:	6782                	ld	a5,0(sp)
    80200966:	b515                	j	8020078a <vprintfmt+0x170>
            if (width > 0 && padc != '-') {
    80200968:	01b05663          	blez	s11,80200974 <vprintfmt+0x35a>
    8020096c:	02d00693          	li	a3,45
    80200970:	f6d798e3          	bne	a5,a3,802008e0 <vprintfmt+0x2c6>
    80200974:	00001417          	auipc	s0,0x1
    80200978:	86540413          	addi	s0,s0,-1947 # 802011d9 <error_string+0xd1>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
    8020097c:	02800513          	li	a0,40
    80200980:	02800793          	li	a5,40
    80200984:	bd1d                	j	802007ba <vprintfmt+0x1a0>

0000000080200986 <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
    80200986:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
    80200988:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
    8020098c:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
    8020098e:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
    80200990:	ec06                	sd	ra,24(sp)
    80200992:	f83a                	sd	a4,48(sp)
    80200994:	fc3e                	sd	a5,56(sp)
    80200996:	e0c2                	sd	a6,64(sp)
    80200998:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
    8020099a:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
    8020099c:	c7fff0ef          	jal	ra,8020061a <vprintfmt>
}
    802009a0:	60e2                	ld	ra,24(sp)
    802009a2:	6161                	addi	sp,sp,80
    802009a4:	8082                	ret

00000000802009a6 <sbi_console_putchar>:

int sbi_console_getchar(void) {
    return sbi_call(SBI_CONSOLE_GETCHAR, 0, 0, 0);
}
void sbi_console_putchar(unsigned char ch) {
    sbi_call(SBI_CONSOLE_PUTCHAR, ch, 0, 0);
    802009a6:	00003797          	auipc	a5,0x3
    802009aa:	65a78793          	addi	a5,a5,1626 # 80204000 <bootstacktop>
    __asm__ volatile (
    802009ae:	6398                	ld	a4,0(a5)
    802009b0:	4781                	li	a5,0
    802009b2:	88ba                	mv	a7,a4
    802009b4:	852a                	mv	a0,a0
    802009b6:	85be                	mv	a1,a5
    802009b8:	863e                	mv	a2,a5
    802009ba:	00000073          	ecall
    802009be:	87aa                	mv	a5,a0
}
    802009c0:	8082                	ret

00000000802009c2 <sbi_set_timer>:

void sbi_set_timer(unsigned long long stime_value) {
    sbi_call(SBI_SET_TIMER, stime_value, 0, 0);
    802009c2:	00003797          	auipc	a5,0x3
    802009c6:	65678793          	addi	a5,a5,1622 # 80204018 <SBI_SET_TIMER>
    __asm__ volatile (
    802009ca:	6398                	ld	a4,0(a5)
    802009cc:	4781                	li	a5,0
    802009ce:	88ba                	mv	a7,a4
    802009d0:	852a                	mv	a0,a0
    802009d2:	85be                	mv	a1,a5
    802009d4:	863e                	mv	a2,a5
    802009d6:	00000073          	ecall
    802009da:	87aa                	mv	a5,a0
}
    802009dc:	8082                	ret

00000000802009de <sbi_shutdown>:


void sbi_shutdown(void)
{
    sbi_call(SBI_SHUTDOWN,0,0,0);
    802009de:	00003797          	auipc	a5,0x3
    802009e2:	62a78793          	addi	a5,a5,1578 # 80204008 <SBI_SHUTDOWN>
    __asm__ volatile (
    802009e6:	6398                	ld	a4,0(a5)
    802009e8:	4781                	li	a5,0
    802009ea:	88ba                	mv	a7,a4
    802009ec:	853e                	mv	a0,a5
    802009ee:	85be                	mv	a1,a5
    802009f0:	863e                	mv	a2,a5
    802009f2:	00000073          	ecall
    802009f6:	87aa                	mv	a5,a0
    802009f8:	8082                	ret

00000000802009fa <strnlen>:
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
    while (cnt < len && *s ++ != '\0') {
    802009fa:	c185                	beqz	a1,80200a1a <strnlen+0x20>
    802009fc:	00054783          	lbu	a5,0(a0)
    80200a00:	cf89                	beqz	a5,80200a1a <strnlen+0x20>
    size_t cnt = 0;
    80200a02:	4781                	li	a5,0
    80200a04:	a021                	j	80200a0c <strnlen+0x12>
    while (cnt < len && *s ++ != '\0') {
    80200a06:	00074703          	lbu	a4,0(a4)
    80200a0a:	c711                	beqz	a4,80200a16 <strnlen+0x1c>
        cnt ++;
    80200a0c:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
    80200a0e:	00f50733          	add	a4,a0,a5
    80200a12:	fef59ae3          	bne	a1,a5,80200a06 <strnlen+0xc>
    }
    return cnt;
}
    80200a16:	853e                	mv	a0,a5
    80200a18:	8082                	ret
    size_t cnt = 0;
    80200a1a:	4781                	li	a5,0
}
    80200a1c:	853e                	mv	a0,a5
    80200a1e:	8082                	ret

0000000080200a20 <memset>:
memset(void *s, char c, size_t n) {
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
#else
    char *p = s;
    while (n -- > 0) {
    80200a20:	ca01                	beqz	a2,80200a30 <memset+0x10>
    80200a22:	962a                	add	a2,a2,a0
    char *p = s;
    80200a24:	87aa                	mv	a5,a0
        *p ++ = c;
    80200a26:	0785                	addi	a5,a5,1
    80200a28:	feb78fa3          	sb	a1,-1(a5)
    while (n -- > 0) {
    80200a2c:	fec79de3          	bne	a5,a2,80200a26 <memset+0x6>
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
    80200a30:	8082                	ret
