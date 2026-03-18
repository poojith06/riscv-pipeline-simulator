addi x1, x0, 0
addi x2, x0, 1
addi x3, x0, 0
addi x4, x0, 6
addi x5, x0, 0
sd x1, 0(x3)
sd x2, 8(x3)
addi x3, x3, 16
add x6, x1, x2
sd x6, 0(x3)
add x1, x0, x2
add x2, x0, x6
addi x3, x3, 8
addi x5, x5, 1
beq x5, x4, 8
beq x0, x0, -28
addi x7, x0, 0
ld x8, 0(x7)
ld x9, 8(x7)
ld x10, 16(x7)
ld x11, 24(x7)
ld x12, 32(x7)
ld x13, 40(x7)
ld x14, 48(x7)
ld x15, 56(x7)
add x0, x0, x0
add x0, x0, x0
add x0, x0, x0
add x0, x0, x0
