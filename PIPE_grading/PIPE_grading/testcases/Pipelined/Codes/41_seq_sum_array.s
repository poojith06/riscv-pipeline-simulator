addi x1, x0, 1
addi x2, x0, 2
addi x3, x0, 3
addi x4, x0, 4
addi x5, x0, 5
sd x1, 0(x0)
sd x2, 8(x0)
sd x3, 16(x0)
sd x4, 24(x0)
sd x5, 32(x0)
addi x6, x0, 0
addi x7, x0, 0
addi x8, x0, 40
ld x9, 0(x7)
add x6, x6, x9
addi x7, x7, 8
beq x7, x8, 8
beq x0, x0, -16
add x10, x0, x6
add x0, x0, x0
add x0, x0, x0
add x0, x0, x0
add x0, x0, x0
