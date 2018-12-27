KERNAL_PRINTCHR	EQU $e716

RESERVED_STACK_POINTER DC.B 0

; init program: save stack pointer
	MAC init_program
	tsx
	stx RESERVED_STACK_POINTER
	ENDM

; end program: restorre stack pointer and exit
	MAC halt
	ldx RESERVED_STACK_POINTER
	txs
	rts
	ENDM

; setup default mem layout for xprom runtime environment
STDLIB_MEMSETUP SUBROUTINE
	lda #$36
	sta $01
	rts

; print null-terminated petscii string
STDLIB_PRINT SUBROUTINE
	sta $6f         ; store string start low byte
    sty $70         ; store string start high byte
    ldy #$00		; set length to 0
.1:
    lda ($6f),y     ; get byte from string
    beq .2		    ; exit loop if null byte [EOS] 
    jsr KERNAL_PRINTCHR
    iny             
    bne .1
.2:
	rts
	
; convert byte type decimal petscii
STDLIB_BYTE_TO_PETSCII SUBROUTINE
	ldy #$2f
  	ldx #$3a
  	sec
.1: iny
  	sbc #100
  	bcs .1
.2: dex
  	adc #10
  	bmi .2
  	adc #$2f
  	rts
  	
; print byte type as decimal
STDLIB_PRINT_BYTE SUBROUTINE
	jsr STDLIB_BYTE_TO_PETSCII
	pha
	tya
	cmp #$30
	beq .skip
	jsr KERNAL_PRINTCHR
.skip
	txa
	cmp #$30
	beq .skip2
	jsr KERNAL_PRINTCHR
.skip2
	pla
	jsr KERNAL_PRINTCHR
	rts
	
	; opcode for print byte as decimal  	
	MAC stdlib_printb
	pla
	jsr STDLIB_PRINT_BYTE
	ENDM

; print word as petscii decimal
STDLIB_PRINT_WORD SUBROUTINE
	lda #<.tt
	sta $6f         ; store dividend_ptr_lb
	lda #>.tt
    sta $70         ; store dividend_ptr_hb
	
	;sta reserved2
	;sty reserved2+1
	
	lda reserved2+1
	bpl .skip1
	; negate number and print "-"
	twoscomplement reserved2
	lda #$2d
	jsr KERNAL_PRINTCHR
.skip1
	ldy #$00
.loop:
	lda ($6f),y
	sta reserved0
	iny
	lda ($6f),y
	sta reserved0+1
	
	tya
	pha

	jsr NUCL_DIV16
	
	pla
	tay
	
	lda reserved2
	beq .skip
	clc
	adc #$30
	jsr KERNAL_PRINTCHR
.skip:
	iny	
	cpy #$08	
	beq .end	
	lda reserved5
	sta reserved2
	lda reserved5+1
	sta reserved2+1
	jmp .loop	
.end:
	lda reserved5
	clc
	adc #$30
	jsr KERNAL_PRINTCHR
	rts
.tt	DC.W #10000
.ot DC.W #1000
.oh DC.W #100
.tn DC.W #10

	; opcode for print word as decimal  	
	MAC stdlib_printw
	pla
	sta reserved2+1
	pla
	sta reserved2
	jsr STDLIB_PRINT_WORD
	ENDM

	MAC stdlib_putstr
    pla
    tay
    pla
    jsr STDLIB_PRINT
	ENDM

	MAC stdlib_putchar
    pla
    jsr KERNAL_PRINTCHR
	ENDM