addi x1, x0, 1
addi x1, x0, 2
addi x1, x0, 3
add x2, x1, x1
sub x3, x2, x1
add x4, x3, x2
and x5, x4, x3
or x6, x4, x3
sd x4, 0(x0)
ld x7, 0(x0)
add x8, x7, x0
sd x8, 8(x0)
ld x9, 8(x0)
add x10, x9, x7
addi x11, x0, 6
addi x12, x0, 6
beq x11, x12, 12
addi x13, x0, 111
addi x14, x0, 222
addi x15, x0, 77
addi x16, x0, 77
addi x0, x0, 999
add x17, x0, x15
addi x18, x0, 10
sd x18, 16(x0)
ld x19, 16(x0)
beq x19, x18, 12
addi x20, x0, 111
addi x21, x0, 222
addi x22, x0, 88
addi x23, x0, 88
beq x22, x23, 8
addi x24, x0, 333
addi x25, x0, 55
sd x25, 24(x0)
ld x26, 24(x0)
addi x27, x0, 1
add x26, x26, x27
sd x26, 32(x0)
ld x28, 32(x0)
addi x29, x0, 0
addi x30, x0, 4
addi x29, x29, 1
beq x29, x30, 8
beq x0, x0, -8
add x31, x29, x28
ld x20, 0(x0)
ld x21, 8(x0)
ld x13, 16(x0)
ld x14, 24(x0)
ld x24, 32(x0)
add x0, x0, x0
add x0, x0, x0
add x0, x0, x0
add x0, x0, x0
