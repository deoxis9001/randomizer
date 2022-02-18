.thumb
push	{r4, lr}
mov	r4, r0

@ spawn the bomb
ldr	r3, =0x801B27C
mov	lr, r3
.short	0xF800

@ get the player's facing direction, which is passed to the bomb
ldrb	r0, [r4, #0x14]
lsl	r0, #2

@ store it as the bombchu's walking direction
strb	r0, [r4, #0x15]

@ advance to next action
ldrb	r0, [r4, #0x0C]
mov	r0, #2
strb	r0, [r4, #0x0C]

@ give the chu a hitbox
mov	r0, r4
ldr	r3, =#0x80176A4
mov	lr, r3
.short	0xF800
ldrb	r0, [r4, #0x10]
mov	r1, #0x80
orr	r0, r1
strb	r0, [r4, #0x10]

pop	{r4}
pop	{r0}
bx	r0
