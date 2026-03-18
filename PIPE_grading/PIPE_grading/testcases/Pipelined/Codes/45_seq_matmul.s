addi x1, x0, 2
addi x2, x0, 3
addi x3, x0, 4
addi x4, x0, 1
sd x1, 0(x0)
sd x2, 8(x0)
sd x3, 16(x0)
sd x4, 24(x0)
addi x5, x0, 1
addi x6, x0, 2
addi x7, x0, 3
addi x8, x0, 4
sd x5, 32(x0)
sd x6, 40(x0)
sd x7, 48(x0)
sd x8, 56(x0)
addi x9, x0, 0
addi x10, x0, 0
beq x10, x5, 16
add x9, x9, x1
addi x10, x10, 1
beq x0, x0, -12
add x11, x0, x9
addi x9, x0, 0
addi x10, x0, 0
beq x10, x7, 16
add x9, x9, x2
addi x10, x10, 1
beq x0, x0, -12
add x12, x11, x9
sd x12, 64(x0)
addi x9, x0, 0
addi x10, x0, 0
beq x10, x6, 16
add x9, x9, x1
addi x10, x10, 1
beq x0, x0, -12
add x11, x0, x9
addi x9, x0, 0
addi x10, x0, 0
beq x10, x8, 16
add x9, x9, x2
addi x10, x10, 1
beq x0, x0, -12
add x13, x11, x9
sd x13, 72(x0)
addi x9, x0, 0
addi x10, x0, 0
beq x10, x5, 16
add x9, x9, x3
addi x10, x10, 1
beq x0, x0, -12
add x11, x0, x9
addi x9, x0, 0
addi x10, x0, 0
beq x10, x7, 16
add x9, x9, x4
addi x10, x10, 1
beq x0, x0, -12
add x14, x11, x9
sd x14, 80(x0)
addi x9, x0, 0
addi x10, x0, 0
beq x10, x6, 16
add x9, x9, x3
addi x10, x10, 1
beq x0, x0, -12
add x11, x0, x9
addi x9, x0, 0
addi x10, x0, 0
beq x10, x8, 16
add x9, x9, x4
addi x10, x10, 1
beq x0, x0, -12
add x15, x11, x9
sd x15, 88(x0)
ld x16, 0(x0)
ld x17, 8(x0)
ld x18, 16(x0)
ld x19, 24(x0)
ld x20, 32(x0)
ld x21, 40(x0)
ld x22, 48(x0)
ld x23, 56(x0)
ld x24, 64(x0)
ld x25, 72(x0)
ld x26, 80(x0)
ld x27, 88(x0)
add x28, x24, x27
add x29, x24, x25
add x30, x26, x27
add x31, x29, x30
sd x28, 96(x0)
sd x29, 104(x0)
sd x30, 112(x0)
sd x31, 120(x0)
and x9, x24, x25
or x10, x24, x25
and x11, x26, x27
or x1, x26, x27
sd x9, 128(x0)
sd x10, 136(x0)
sd x11, 144(x0)
sd x1, 152(x0)
addi x2, x0, 0
addi x3, x0, 0
beq x3, x27, 16
add x2, x2, x24
addi x3, x3, 1
beq x0, x0, -12
add x4, x0, x2
addi x2, x0, 0
addi x3, x0, 0
beq x3, x26, 16
add x2, x2, x25
addi x3, x3, 1
beq x0, x0, -12
sub x5, x4, x2
sd x5, 160(x0)
ld x1, 96(x0)
ld x2, 104(x0)
ld x3, 112(x0)
ld x4, 120(x0)
ld x5, 160(x0)
ld x6, 128(x0)
ld x7, 136(x0)
ld x8, 144(x0)
add x0, x0, x0
add x0, x0, x0
add x0, x0, x0
add x0, x0, x0
