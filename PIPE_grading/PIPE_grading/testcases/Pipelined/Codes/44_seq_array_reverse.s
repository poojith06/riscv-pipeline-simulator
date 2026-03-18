addi x1, x0, 10
addi x2, x0, 20
addi x3, x0, 30
addi x4, x0, 40
addi x5, x0, 50
sd x1, 0(x0)
sd x2, 8(x0)
sd x3, 16(x0)
sd x4, 24(x0)
sd x5, 32(x0)
addi x6, x0, 0
addi x7, x0, 32
addi x8, x0, 16
beq x6, x8, 32
ld x9, 0(x6)
ld x10, 0(x7)
sd x10, 0(x6)
sd x9, 0(x7)
addi x6, x6, 8
addi x7, x7, -8
beq x0, x0, -28
ld x11, 0(x0)
ld x12, 8(x0)
ld x13, 16(x0)
ld x14, 24(x0)
ld x15, 32(x0)
add x0, x0, x0
add x0, x0, x0
add x0, x0, x0
add x0, x0, x0
