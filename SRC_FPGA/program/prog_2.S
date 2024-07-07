.include "user_define.h"
.global _start
.section .text
_start:
        li  x5, 0x5
        addi x6 , x5 , 0x6
        li x7, 0xb
        beq x7 , x6 , PASSc1
        bne x7 , x6 , FAIL
PASSc1:
        ori x9 , x9 , 0x1
        j _startc2
_startc2:
        li  x5, 0x5
        addi x6, x5 , 0
        li x7, 0x5
        beq x7 , x6 , PASSc2
        bne x7 , x6 , FAIL
PASSc2:
        j _startc3
_startc3:
        li  x5, 0x5
        xori x6, x5 , 0x6
        li x7, 0x3
        beq x7 , x6 , PASSc3
        bne x7 , x6 , FAIL
PASSc3:
        j _startc4
_startc4:
        li  x5, 0x5
        ori x6 , x5 , 0x6
        li x7, 0x7
        beq x7 , x6 , PASSc4
        bne x7 , x6 , FAIL
PASSc4:
        j _startc5
_startc5:
        li  x5, 0x5
        slti x6 , x5 , 0x5
        li x7, 0
        beq x7 , x6 , PASSc5
        bne x7 , x6 , FAIL
PASSc5:
	li x6 , 0x0
        j Delay
FAIL:
        andi x9 , x9 , -2
        li x6 , 0x0
        j Delay
Delay:
	li  x5, 0
        addi x6, x6,0x1
        li  x7, 0x989680
        beq x7 ,x6 ,DONE
        bne x7 ,x6 ,WAIT
WAIT:
        j Delay
DONE:
        j m_start
m_start: 
	li x4, 0x5
	li x5, 0x2
	mul x6, x5,x4	
	li x7 , 0xa
	beq x7 , x6 , PASSc51
	bne x7 , x6 , FAIL_m
PASSc51:
	ori x9 , x9 , 0x2
	li x6 , 0x0
	j Delay_1
FAIL_m:
	andi x9 , x9 ,-3 
	li x6 , 0x0
   	j Delay_1
Delay_1:
        li  x5, 0
        addi x6, x6,0x1
        li  x7, 0x989680
        beq x7 ,x6 ,DONE_1
        bne x7 ,x6 ,WAIT_1
WAIT_1:
        j Delay_1
DONE_1:
        j compress

compress:
	c.li x4, 5
	c.li x5, 10
	c.add x5, x4
	c.li x7, 15
	beq x7, x5 ,PASSc6
	bne x7, x5 ,FAIL_c
PASSc6:
	ori x9 ,x9 ,0x4
	li x6 , 0x0
	j Delay_2
FAIL_c:
	andi x9, x9, -5
	li x6 , 0x0
	j Delay_2
Delay_2:
        li  x5, 0
        addi x6, x6,0x1
        li  x7, 0x989680
        beq x7 ,x6 ,DONE_2
        bne x7 ,x6 ,WAIT_2
WAIT_2:
        j Delay_2

DONE_2:
        j atomic
atomic:
	addi x4, x0, 5
	addi x5, x0, 7
	addi x6, x0, 0
	addi x7, x0, 8
	addi x8, x0, 16
	addi x10, x0, 32
	addi x11, x0, 40
	addi x12, x0, 48
	addi x13, x0, 56
	addi x14, x0, 64
	addi x15, x0, 72
	addi x16, x0, 15
	addi x17, x0, 31
	addi x18, x0, 50
	addi x19, x0, 80
	addi x20, x0, 99
	addi x21, x0, 64
	sd x4 , 0(x6)
	sd x5 , 0(x7)
	sd x16 , 0(x8)
	sd x18 , 0(x10)
	amoadd.w x23, x5, (x6)    # x23 <= 5 , MEM[x6]  <= 12
	ld x23 , 0(x6)
	li x7 , 12
	beq x7, x23, PASSc7
	bne x7, x23, FAIL_a
PASSc7:
	ori x9,x9,0x8
	j FINISH
FAIL_a:
	andi x9, x9 , -9
	j FINISH
FINISH:
	j FINISH
