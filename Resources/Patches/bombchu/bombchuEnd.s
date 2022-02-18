.thumb
push	{lr}

@ reset the camera target, only if this chu is the current target
ldr	r1, =#0x3000C20
ldr	r2, [r1]
cmp	r2, r0
bne	noReset
ldr	r2, =#0x3001160
str	r2, [r1]
@ allow link to move again
mov	r0, #0
ldr	r1, =#0x3003F8A
strb	r0, [r1]
noReset:

@ run the normal bomb exploding
ldr	r3, =#0x801B3B8
mov	lr, r3
.short	0xF800

pop	{r0}
bx	r0
