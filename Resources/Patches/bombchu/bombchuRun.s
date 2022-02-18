.equ bombchuTransitionList, bombchuSlowList+4
.equ bombchuIgnoreList, bombchuTransitionList+4
.equ bombchuSpeed, bombchuIgnoreList+4
.thumb
push	{r4-r7, lr}
mov	r1, r8
push	{r1}
mov	r4, r0

@ reset collisions
mov	r0, #0
strh	r0, [r4, #0x2A]

@ restore speed
ldr	r0, bombchuSpeed
strh	r0, [r4, #0x24]

@ check tile standing on
mov	r0, r4
mov	r1, #0
mov	r2, #0
ldr	r3, =#0x8079C14
mov	lr, r3
.short	0xF800
mov	r5, r0

@ also check next tile
ldrb	r0, [r4, #0x15]
bl	getNextTile
mov	r6, r0

@ and also check previous tile
ldrb	r0, [r4, #0x15]
add	r0, #0x10
bl	getNextTile
mov	r7, r0

@ check for minish corridor exceptions
bl	minishTunnels
mov	r8, r0

@ go invisible if needed
ldrb	r0, [r4, #0x0B]
cmp	r0, #0
beq	notInvisible

invisible:
ldrb	r0, [r4, #0x19]
mov	r1, #1
bic	r0, r1
mov	r1, #2
orr	r0, r1
strb	r0, [r4, #0x19]
b	doneInvisible

notInvisible:
ldrb	r0, [r4, #0x19]
mov	r1, #1
and	r1, r0
bne	doneInvisible
mov	r1, #2
bic	r0, r1
strb	r0, [r4, #0x19]
doneInvisible:

@ make the chu fall in pits
mov	r0, r4
ldr	r3, =#0x80044C6
mov	lr, r3
.short	0xF800
cmp	r0, #0
beq	notFallen
@ the chu fell, reset camera if needed
ldr	r1, =#0x3000C20
ldr	r2, [r1]
cmp	r2, r4
bne	noReset
ldr	r2, =#0x3001160
str	r2, [r1]
@ allow link to move again
mov	r0, #0
ldr	r1, =#0x3003F8A
strb	r0, [r1]
noReset:
@ and end
b	end
notFallen:

@ check if we have control:
@ check that enough frames have passed since the chu was planted
ldrb	r0, [r4, #0x0E]
cmp	r0, #0x91
bhs	noControl

@ check if link is available
ldr	r1, =#0x3001160
ldrb	r0, [r1, #0x0C]
cmp	r0, #1
bne	noControl

@ check if link has been hit
mov	r0, #0x3D
ldsb	r0, [r1, r0]
cmp	r0, #0
bgt	noControl

@ check if we have bombchus in the a button
ldr	r0, =#0x2002AC0 + 0x34
ldr	r1, =#0x3000FF0
ldrh	r1, [r1]
ldrb	r2, [r0, #0x00]
cmp	r2, #8
bne	notA
mov	r2, #1
and	r2, r1
bne	control
notA:

@ and check if we have them in the b button
ldrb	r2, [r0, #0x01]
cmp	r2, #8
bne	noControl
mov	r2, #2
and	r2, r1
beq	noControl

control:
@ copy link's direction, unless he's still 0xFF, or the chu's invisible
ldrb	r0, [r4, #0x0B]
cmp	r0, #0
bne	noCopy
ldr	r1, =#0x3001160
ldrb	r0, [r1, #0x15]
cmp	 r0, #0xFF
beq	noCopy
strb	r0, [r4, #0x15]
ldrb	r0, [r1, #0x14]
strb	r0, [r4, #0x14]
noCopy:

@ stop link from moving
mov	r0, #0x88
ldr	r1, =#0x3003F8A
strb	r0, [r1]

@ set the camera target, only if the current target is link
ldr	r0, =#0x3000C20
ldr	r1, [r0]
ldr	r2, =#0x3001160
cmp	r1, r2
bne	doneControl
str	r4, [r0]
b	doneControl

noControl:
@ the chu fell, reset camera if needed
ldr	r1, =#0x3000C20
ldr	r2, [r1]
cmp	r2, r4
bne	doneControl
ldr	r2, =#0x3001160
str	r2, [r1]

@ allow link to move again
mov	r0, #0
ldr	r1, =#0x3003F8A
strb	r0, [r1]

doneControl:

@ check if tile should halve speed
ldr	r0, bombchuSlowList
speedLoop:
	ldrb	r1, [r0]
	cmp	r1, #0
	beq	doneSpeed
	cmp	r1, r5
	beq	halveSpeed
	cmp	r1, r6
	beq	halveSpeed
	cmp	r1, r7
	beq	halveSpeed
	add	r0, #1
	b	speedLoop
	
	halveSpeed:
	ldrh	r0, [r4, #0x24]
	lsr	r0, #1
	strh	r0, [r4, #0x24]
doneSpeed:

@ check if tile is transition
ldr	r0, bombchuTransitionList
transitionLoop:
	ldrb	r1, [r0]
	cmp	r1, #0
	beq	doneTransition
	cmp	r1, r5
	beq	setTransition
	cmp	r1, r6
	beq	setTransition
	cmp	r1, r7
	beq	setTransition
	add	r0, #1
	b	transitionLoop
	
	setTransition:
	mov	r0, #3
	mov	r1, #0x38
	strb	r0, [r4, r1]
doneTransition:

@ move the chu:
@ if it's a wall, ignore any collision and just move
ldr	r0, bombchuIgnoreList
ignoreLoop:
	ldrb	r1, [r0]
	cmp	r1, #0
	beq	doneIgnore
	cmp	r1, r5
	beq	moveWall
	cmp	r1, r6
	beq	moveWall
	cmp	r1, r7
	beq	moveWall
	add	r0, #1
	b	ignoreLoop
doneIgnore:

@ check for minish corridor exceptions
mov	r0, r8
cmp	r0, #0
bne	moveWall

@ check if invisible, if so, do not check for collisions
ldrb	r0, [r4, #0x0B]
cmp	r0, #0
bne	moveWall

@ this routine updates collisions, uses a push/pop wrapper, handwritten?
mov	r0, r4
ldr	r3, =#0x8008648
mov	lr, r3
.short	0xF800

@ check if the chu collided with a wall, if so, explode
ldrh	r0, [r4, #0x2A]
cmp	r0, #0
bne	explode

@ this movement routine does not update collisions
moveWall:
mov	r0, r4
ldrh	r1, [r4, #0x24]
ldrb	r2, [r4, #0x15]
ldr	r3, =#0x8002892
mov	lr, r3
.short	0xF800

@ also check for collision with enemies
mov	r0, #0x44
ldrb	r0, [r4, r0]
cmp	r0, #0x0A
beq	explode

@ and return
end:
pop	{r0}
mov	r8, r0
pop	{r4-r7}
pop	{r0}
bx	r0

@ make the chu explode
explode:
ldrb	r0, [r4, #0x0E]
cmp	r0, #0
bhi	skipFuse
ldrb	r0, [r4, #0x0F]
cmp	r0, #2
bls	end
skipFuse:
mov	r0, #2
strb	r0, [r4, #0x0C]
mov	r0, #0
strb	r0, [r4, #0x0D]
strb	r0, [r4, #0x0E]
mov	r0, #2
strb	r0, [r4, #0x0F]
b	end

getNextTile:
push	{lr}
mov	r1, #0
mov	r2, #0
cmp	r0, #0x20
blo	noMod
sub	r0, #0x20
noMod:
cmp	r0, #0xFF
bhs	nexttile
lsl	r0, #32 - 5
lsr	r0, #32 - 5

cmp	r0, #0x00
beq	up
cmp	r0, #0x04
beq	up
cmp	r0, #0x1C
beq	up
b	doneup

up:
mov	r2, #8
neg	r2, r2
b	donedown
doneup:

cmp	r0, #0x0C
beq	down
cmp	r0, #0x10
beq	down
cmp	r0, #0x14
beq	down
b	donedown

down:
mov	r2, #8
donedown:

cmp	r0, #0x04
beq	right
cmp	r0, #0x08
beq	right
cmp	r0, #0x0C
beq	right
b	doneright

right:
mov	r1, #8
b	doneleft
doneright:

cmp	r0, #0x14
beq	left
cmp	r0, #0x18
beq	left
cmp	r0, #0x1C
beq	left
b	doneleft

left:
mov	r1, #8
neg	r1, r1
doneleft:

nexttile:
mov	r0, r4
ldr	r3, =#0x8079C14
mov	lr, r3
.short	0xF800
pop	{r1}
bx	r1

minishTunnels:
@ 8 (bottom entrance) and 9 (top entrance) are only ignored when going vertical
@ A (right entrance) and B (left entrance) when going horizontal
ldrb	r0, [r4, #0x15]
cmp	r0, #0xFF
beq	noMovement

lsl	r0, #32 - 5
lsr	r0, #32 - 5

cmp	r0, #0x00
beq	upTunnel
cmp	r0, #0x04
beq	upTunnel
cmp	r0, #0x1C
beq	upTunnel
b	doneupTunnel

upTunnel:
cmp	r5, #0x08
beq	goInvisible
cmp	r7, #0x09
beq	stopInvisible
cmp	r6, #0x08
beq	yesMovement
cmp	r6, #0x09
beq	yesMovement
cmp	r7, #0x08
beq	yesMovement
cmp	r5, #0x09
beq	yesMovement
b	noMovement
doneupTunnel:

cmp	r0, #0x0C
beq	downTunnel
cmp	r0, #0x10
beq	downTunnel
cmp	r0, #0x14
beq	downTunnel
b	donedownTunnel

downTunnel:
cmp	r5, #0x09
beq	goInvisible
cmp	r7, #0x08
beq	stopInvisible
cmp	r6, #0x09
beq	yesMovement
cmp	r6, #0x08
beq	yesMovement
cmp	r7, #0x09
beq	yesMovement
cmp	r5, #0x08
beq	yesMovement
b	noMovement
donedownTunnel:

cmp	r0, #0x04
beq	rightTunnel
cmp	r0, #0x08
beq	rightTunnel
cmp	r0, #0x0C
beq	rightTunnel
b	donerightTunnel

rightTunnel:
cmp	r5, #0x0B
beq	goInvisible
cmp	r7, #0x0A
beq	stopInvisible
cmp	r6, #0x0B
beq	yesMovement
cmp	r6, #0x0A
beq	yesMovement
cmp	r7, #0x0B
beq	yesMovement
cmp	r5, #0x0A
beq	yesMovement
b	noMovement
donerightTunnel:

cmp	r0, #0x14
beq	leftTunnel
cmp	r0, #0x18
beq	leftTunnel
cmp	r0, #0x1C
beq	leftTunnel
b	doneleftTunnel

leftTunnel:
cmp	r5, #0x0A
beq	goInvisible
cmp	r7, #0x0B
beq	stopInvisible
cmp	r6, #0x0A
beq	yesMovement
cmp	r6, #0x0B
beq	yesMovement
cmp	r7, #0x0A
beq	yesMovement
cmp	r5, #0x0B
beq	yesMovement
b	noMovement
doneleftTunnel:

b	noMovement

goInvisible:
mov	r0, #1
strb	r0, [r4, #0x0B]
b	yesMovement

stopInvisible:
mov	r0, #0
strb	r0, [r4, #0x0B]
b	yesMovement

yesMovement:
mov	r0, #1
bx	lr

noMovement:
mov	r0, #0
bx	lr

.align
.ltorg
bombchuSlowList:
@POIN bombchuSlowList
@POIN bombchuTransitionList
@POIN bombchuIgnoreList
@WORD bombchuSpeed
