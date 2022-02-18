.equ bombchuNormalGraphics, bombchuTable+4
.equ bombchuExplodingGraphics, bombchuNormalGraphics+4
.thumb

push	{r4, lr}
mov	r4, r0

@ check if this is the first time the bombs run, if so, set the bomb type in a safe spot
ldrb	r0, [r4, #0x0A]
cmp	r0, #0
bne	notFirst
mov	r0, #0x68
ldrb	r0, [r4, r0]
strb	r0, [r4, #0x0A]
notFirst:

@ check if this is normal bombs
ldrb	r0, [r4, #0x0A]
cmp	r0, #8
beq	chu

@if so then continue as vanilla
vanilla:
ldr	r0, =#0x801B20C
ldr	r0, [r0]
ldrb	r1, [r4, #0x0C]
ldr	r3, =#0x801B1BC
mov	lr, r3
.short	0xF800

@ otherwise we do our bombchu stuff
chu:
ldr	r0, bombchuTable
ldrb	r1, [r4, #0x0C]
lsl	r1, #2
ldr	r1, [r0, r1]
mov	r0, r4
ldr	r3, =#0x8000F3C
mov	lr, r3
.short	0xF800

@ do our extra chu stuff...
@ get the right image, normal if palette is 1, exploding if it's 0
ldrb	r0, [r4, #0x1A]
lsl	r0, #32 - 4
lsr	r0, #32 - 4
cmp	r0, #1
beq	normal

exploding:
ldr	r0, bombchuExplodingGraphics
b	getFacing

normal:
ldr	r0, bombchuNormalGraphics

@ now get the offset of the specific pose we need
getFacing:
ldrb	r1, [r4, #0x14]
lsr	r1, #1

@if up
cmp	r1, #0
beq	doneFacing

@if right
add	r0, #0xC0
cmp	r1, #1
beq	doneFacing

@if down
add	r0, #0xC0
cmp	r1, #2
beq	doneFacing

@if none of the above, it has to be left
add	r0, #0xC0

doneFacing:

@ and load it to vram
ldr	r1, =0x6011800
mov	r2, #0xC0 - 4
loop:
ldr	r3, [r0, r2]
str	r3, [r1, r2]
sub	r2, #4
bhs	loop

@ return
ldr	r3, =#0x801B1C8
mov	lr, r3
.short	0xF800

.align
.ltorg
bombchuTable:
@POIN bombchuTable
@POIN bombchuNormalGraphics
@POIN bombchuExplodingGraphics
