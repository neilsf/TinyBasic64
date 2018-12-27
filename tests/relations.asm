	PROCESSOR 6502

	SEG UPSTART
	ORG $0801
	DC.W next_line
	DC.W 2018
	HEX 9e
	IF prg_start
	DC.B [prg_start]d
	ENDIF
	HEX 00
next_line:
	HEX 00 00
	;--------------------
	INCDIR "/home/neils/Workspace/TinyBasic64/lib"
	INCLUDE "nucleus.asm"
	INCLUDE "stdlib.asm"
prg_start:
	init_program
	pword #587
	negw
	plw2var _a
	pword #35
	plw2var _b
	pwvar _a
	pwvar _b
	cmpwlt
	pla
	bne *+5
	jmp _J1
	lda #<_S1
	pha
	lda #>_S1
	pha
	stdlib_putstr
_J1:
	pwvar _a
	pwvar _b
	cmpwlte
	pla
	bne *+5
	jmp _J2
	lda #<_S2
	pha
	lda #>_S2
	pha
	stdlib_putstr
_J2:
	pwvar _a
	pwvar _b
	cmpwgt
	pla
	bne *+5
	jmp _J3
	lda #<_S3
	pha
	lda #>_S3
	pha
	stdlib_putstr
_J3:
	pwvar _a
	pwvar _b
	cmpwgte
	pla
	bne *+5
	jmp _J4
	lda #<_S4
	pha
	lda #>_S4
	pha
	stdlib_putstr
_J4:
	pwvar _a
	pwvar _b
	cmpweq
	pla
	bne *+5
	jmp _J5
	lda #<_S5
	pha
	lda #>_S5
	pha
	stdlib_putstr
_J5:
	pwvar _a
	pwvar _b
	cmpwneq
	pla
	bne *+5
	jmp _J6
	lda #<_S6
	pha
	lda #>_S6
	pha
	stdlib_putstr
_J6:
	pwvar _b
	pwvar _a
	cmpwlt
	pla
	bne *+5
	jmp _J7
	lda #<_S7
	pha
	lda #>_S7
	pha
	stdlib_putstr
_J7:
	pwvar _b
	pwvar _a
	cmpwlte
	pla
	bne *+5
	jmp _J8
	lda #<_S8
	pha
	lda #>_S8
	pha
	stdlib_putstr
_J8:
	pwvar _b
	pwvar _a
	cmpwgt
	pla
	bne *+5
	jmp _J9
	lda #<_S9
	pha
	lda #>_S9
	pha
	stdlib_putstr
_J9:
	pwvar _b
	pwvar _a
	cmpwgte
	pla
	bne *+5
	jmp _J10
	lda #<_S10
	pha
	lda #>_S10
	pha
	stdlib_putstr
_J10:
	pwvar _b
	pwvar _a
	cmpweq
	pla
	bne *+5
	jmp _J11
	lda #<_S11
	pha
	lda #>_S11
	pha
	stdlib_putstr
_J11:
	pwvar _b
	pwvar _a
	cmpwneq
	pla
	bne *+5
	jmp _J12
	lda #<_S12
	pha
	lda #>_S12
	pha
	stdlib_putstr
_J12:
	pword #4223
	negw
	plw2var _x
	pword #4223
	negw
	plw2var _y
	pwvar _x
	pwvar _y
	cmpweq
	pla
	bne *+5
	jmp _J13
	lda #<_S13
	pha
	lda #>_S13
	pha
	stdlib_putstr
_J13:
	pwvar _x
	pwvar _y
	cmpwneq
	pla
	bne *+5
	jmp _J14
	lda #<_S14
	pha
	lda #>_S14
	pha
	stdlib_putstr
_J14:
	pwvar _x
	pwvar _y
	cmpwlte
	pla
	bne *+5
	jmp _J15
	lda #<_S15
	pha
	lda #>_S15
	pha
	stdlib_putstr
_J15:
	pwvar _x
	pwvar _y
	cmpwgte
	pla
	bne *+5
	jmp _J16
	lda #<_S16
	pha
	lda #>_S16
	pha
	stdlib_putstr
_J16:
prg_end:
	rts
data_start:
_S1 HEX 41 20 3C 20 42 20 49 53 20 54 52 55 45 0D 00
_S2 HEX 41 20 3C 3D 20 42 20 49 53 20 54 52 55 45 0D 00
_S3 HEX 41 20 3E 20 42 20 49 53 20 54 52 55 45 0D 00
_S4 HEX 41 20 3E 3D 20 42 20 49 53 20 54 52 55 45 0D 00
_S5 HEX 41 20 3D 20 42 20 49 53 20 54 52 55 45 0D 00
_S6 HEX 41 20 3C 3E 20 42 20 49 53 20 54 52 55 45 0D 00
_S7 HEX 42 20 3C 20 41 20 49 53 20 54 52 55 45 0D 00
_S8 HEX 42 20 3C 3D 20 41 20 49 53 20 54 52 55 45 0D 00
_S9 HEX 42 20 3E 20 41 20 49 53 20 54 52 55 45 0D 00
_S10 HEX 42 20 3E 3D 20 41 20 49 53 20 54 52 55 45 0D 00
_S11 HEX 42 20 3D 20 41 20 49 53 20 54 52 55 45 0D 00
_S12 HEX 42 20 3C 3E 20 41 20 49 53 20 54 52 55 45 0D 00
_S13 HEX 58 20 3D 20 59 20 49 53 20 54 52 55 45 0D 00
_S14 HEX 58 20 3C 3E 20 59 20 49 53 20 54 52 55 45 0D 00
_S15 HEX 58 20 3C 3D 20 59 20 49 53 20 54 52 55 45 0D 00
_S16 HEX 58 20 3E 3D 20 59 20 49 53 20 54 52 55 45 0D 00
data_end:
	;--------------
	SEG.U variables
	ORG data_end+1
_a	DS.B 2
_b	DS.B 2
_x	DS.B 2
_y	DS.B 2

