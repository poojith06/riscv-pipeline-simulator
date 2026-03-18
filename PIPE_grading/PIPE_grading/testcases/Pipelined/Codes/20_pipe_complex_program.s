addi x1, x0, 5
add x2, x1, x1
add x3, x2, x1
addi x4, x0, 3
sub x5, x3, x4
sd x5, 0(x0)
ld x6, 0(x0)
add x7, x6, x0
addi x8, x0, 7
addi x9, x0, 7
beq x8, x9, 12
addi x10, x0, 1
addi x11, x0, 2
addi x12, x0, 42
add x0, x12, x12
add x13, x0, x12
addi x14, x0, 0
addi x15, x0, 3
addi x14, x14, 1
beq x14, x15, 8
beq x0, x0, -8
add x16, x14, x7
sd x16, 8(x0)
ld x17, 8(x0)
add x18, x17, x16
add x0, x0, x0
add x0, x0, x0
add x0, x0, x0
add x0, x0, x0
