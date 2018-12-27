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
	pword #1
	plw2var _x
	pword #1
	plw2var _y
	pword #1
	plw2var _dx
	pword #1
	plw2var _dy
	pword #0
	plw2var _i
	jsr _Lcls
_Lloop:
	pword #81
	pword #1024
	pwvar _x
	addw
	pword #40
	pwvar _y
	mulw
	addw
	poke
	jsr _Lwait_frame
	pword #32
	pword #1024
	pwvar _x
	addw
	pword #40
	pwvar _y
	mulw
	addw
	poke
	pwvar _x
	pword #0
	cmpweq
	pla
	bne *+5
	jmp _J1
	pword #1
	plw2var _dx
_J1:
	pwvar _x
	pword #39
	cmpweq
	pla
	bne *+5
	jmp _J2
	pword #1
	negw
	plw2var _dx
_J2:
	pwvar _y
	pword #0
	cmpweq
	pla
	bne *+5
	jmp _J3
	pword #1
	plw2var _dy
_J3:
	pwvar _y
	pword #24
	cmpweq
	pla
	bne *+5
	jmp _J4
	pword #1
	negw
	plw2var _dy
_J4:
	pwvar _x
	pwvar _dx
	addw
	plw2var _x
	pwvar _y
	pwvar _dy
	addw
	plw2var _y
	jmp _Lloop
_Lcls:
	pword #32
	pword #1024
	pwvar _i
	addw
	poke
	pwvar _i
	pword #1
	addw
	plw2var _i
	pwvar _i
	pword #1000
	cmpwlt
	pla
	bne *+5
	jmp _J5
	jmp _Lcls
_J5:
	rts
_Lwait_frame:
	pword #53266
	peek
	pword #250
	cmpwlt
	pla
	bne *+5
	jmp _J6
	jmp _Lwait_frame
_J6:
	rts
prg_end:
	rts
data_start:
data_end:
	;--------------
	SEG.U variables
	ORG data_end+1
_x	DS.B 2
_y	DS.B 2
_dx	DS.B 2
_dy	DS.B 2
_i	DS.B 2

