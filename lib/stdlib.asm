KERNAL_PRINTCHR	EQU $e716
KERNAL_GETIN EQU $ffe4	
INPUT_MAXCHARS EQU $06

RESERVED_STACK_POINTER DC.B 0

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
	
	lda #$00
	sta reserved6	; has a non-zero char been printed?
	
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

	jsr NUCL_DIVU16
	
	lda reserved2
	ora reserved6
	beq .skip
	inc reserved6
	lda reserved2
	jsr STDLIB_PRINT_BYTE
.skip:
	pla
	tay
	iny	
	cpy #$08	
	beq .end	
	lda reserved4
	sta reserved2
	lda reserved4+1
	sta reserved2+1
	jmp .loop	
.end:
	lda reserved4
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
	
STDLIB_INPUT SUBROUTINE
	
.init:
	ldx #INPUT_MAXCHARS
	lda #$00
.loop:
	sta input_str,x
	dex
	bpl .loop
	lda #$00
	sta input_counter
	lda #62
	jsr KERNAL_PRINTCHR
.again:
	lda #228
	jsr KERNAL_PRINTCHR
.input:
	jsr KERNAL_GETIN
	beq .input
	
	cmp #$14
	beq .input_delete

	cmp #$0d
	beq .input_done

	ldx input_counter
	cpx #INPUT_MAXCHARS
	beq .input
	
	jmp .input_filter

.reg:
    inc input_counter
	ldx input_counter
	dex
	sta input_str,x
	
.output:	
	pha
	lda #20
	jsr KERNAL_PRINTCHR
	pla
	jsr KERNAL_PRINTCHR
	jmp .again
	
.input_delete:
	pha
	lda input_counter
	bne .skip
	pla
	jmp .input
.skip:
	pla
	dec input_counter
	jmp .output
	
.input_filter:
	cmp #$2d
	beq .minus
	
	cmp #$3a
	bcc .ok1
	jmp .input
.ok1:
	cmp #$30
	bcs .ok2
	jmp .input
.ok2:
	jmp .reg
.minus:
	ldx input_counter
	bne *+5
	jmp .reg
	jmp .input
	
	
.input_done:
	lda #20
	jsr KERNAL_PRINTCHR
	lda input_counter
	jsr STDLIB_STRVAL
	lda input_err
	beq .input_success
	jmp .init
.input_success:
	rts
	
input_counter DC.B $00
input_str HEX 00 00 00 00 00 00 00
input_val HEX 00 00
input_err HEX 00

STDLIB_STRVAL SUBROUTINE
	tax
	beq .error
		
	lda #$00
	sta .digit_counter
	sta input_err
		
	lda input_str-1,x	
	cmp #$2d
	beq .error
	sec
	sbc #$30	
	sta reserved0
	lda #$00	
	sta reserved1	
	sta reserved2	
	sta reserved3
			
.loop:
	inc .digit_counter
	dex
	beq .done
	lda input_str-1,x
	cmp #$2d
	beq .minus
	sec
	sbc #$30
	sta reserved2
	lda #$00
	sta reserved3
	jsr .mult
	clc
	lda reserved2
	adc reserved0
	sta reserved0
	lda reserved3
	adc reserved1
	sta reserved1
	jmp .loop
	
.done:
	rts
.minus
	lda reserved0
	pha
	lda reserved1
	pha
	negw
	pla
	sta reserved1
	pla
	sta reserved0
	rts
	
.error
	lda #<.redo
	ldy #>.redo
	jsr STDLIB_PRINT
	inc input_err
	rts
	
.mult
	ldy .digit_counter
.mult10
	clc
	rol reserved2	; x2
	rol reserved2+1
    
    lda reserved2	; save to temp
    sta reserved4
    lda reserved2+1
    sta reserved4+1
    
    clc
	rol reserved2	; x2
	rol reserved2+1
	
	clc
	rol reserved2	; x2
	rol reserved2+1
        
	clc
    lda reserved4
    adc reserved2
    sta reserved2
    lda reserved4+1
    adc reserved2+1
    sta reserved2+1
    
    dey
    bne .mult10
    rts
	
.digit_counter HEX 00
.redo HEX 0d 52 45 44 4F 00

	MAC input
	jsr STDLIB_INPUT
	lda reserved0
	pha
	lda reserved1
	pha
	lda #13
	jsr KERNAL_PRINTCHR
	ENDM