addi x1, x0, 7
addi x2, x0, 6
addi x3, x0, 0
addi x4, x0, 0
beq x4, x2, 16
add x3, x3, x1
addi x4, x4, 1
beq x0, x0, -12
add x5, x0, x3
sd x3, 0(x0)
ld x6, 0(x0)
add x0, x0, x0
add x0, x0, x0
add x0, x0, x0
add x0, x0, x0
