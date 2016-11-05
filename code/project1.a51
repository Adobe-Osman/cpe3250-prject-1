	#include<reg932.inc>
	
	RANDREG EQU 0X20
		
	CSEG AT 0

	MOV R2, #0
	MOV P3M1, #00H
    MOV P3M2, #00H
    MOV P2M1, #00H
    MOV P2M2, #00H
    MOV P1M1, #00H
    MOV P1M2, #00H
    MOV P0M1, #00H
    MOV P0M2, #00H

MAIN:
	JB P2.0, NO_DEC

WAIT1:
	JNB P2.0, WAIT1
	DEC R2
	CJNE R2, #0FFH, LED
	ACALL BEEP 
	MOV R2, #15
	SJMP LED

NO_DEC:
	JB P0.1, MAIN

WAIT2:
	JNB P0.1, WAIT2
	INC R2
	CJNE R2, #16, LED
	ACALL BEEP
	MOV R2, #0
	SJMP LED
	
LED:
	MOV A, R2
	CPL A
	RRC A
	MOV P0.6, C
	RRC A
	MOV P2.7, C
	RRC A
	MOV P0.5, C
	RRC A
	MOV P2.4, C
	SJMP MAIN
	
	
; this mostly came from trial and error
; and seeing what sounded good for a beep
; reference canvas tutorial for this
BEEP: 
	MOV R0, #100
S1:	CPL P1.7
	ACALL SDELAY
	DJNZ R0, S1
	
	RET
	
SDELAY: 
	MOV R1, #100
D1: MOV R2, #10
D2: DJNZ R2, D2
	DJNZ R1, D1
	RET


; note this a port from http://pjrc.com/tech/8051/rand.asm
; returns a random value in the A  register from 0 to 9, inclusive.
; note needs a seed value (equated at the top)
RNG:
	MOV	A, RANDREG
	JNZ	RAND8B
	CPL	A
	MOV	RANDREG, A
RAND8B:	ANL	A, #10111000B
	MOV	C, PSW.0
	MOV	A, RANDREG
	RLC	A
	MOV	RANDREG, A
	MOV B, #10D
	DIV AB
	MOV A, B

	RET

; enables a row of lights with a delay of ~75 ms 
; read documenation how this works, but for now a quick summary..
; mov into A bit-string for the first 8 lights
; move into c for the ninth light
; i.e. A = 10101010 C = 1
; enables a huge X of lights
LIGHTS:
	CPL A
	CPL C
	
	RLC A
	MOV P2.4, C
	
	RLC A
	MOV P0.5, C
	
	RLC A
	MOV P2.7, C
	
	RLC A
	MOV P0.6, C
	
	RLC A
	MOV P1.6, C
	
	RLC A
	MOV P0.4, C
	
	RLC A
	MOV P2.5, C
	
	RLC A
	MOV P0.7, C
	
	RLC A
	MOV P2.6, C
	
	MOV A, #00D
	MOV B, #00D
	ACALL EDELAY
	
	RET
	
; envokes a timer delay
; A = high, B = 0
; use formula from class to determine dla
DELAY:
	MOV TMOD, #01D
	MOV TL0, B
	MOV TH0, A
	
	SETB TR0
	
DLLOOP:
	JNB TF0, DLLOOP
	
	CLR TR0
	CLR TF0
	
	RET

; Extended delay, uses timers on the 8051
; A = high of the timer, B = low of the timer
; And R7 is the multiple of iterations
; it's basically DELAY * SOME CONSTANT
EDELAY:
EDLOOP:
	ACALL DELAY
	DJNZ R7, EDLOOP
	RET

; USES REGISTERS A, B, R6, R7
; light sequence for the next level
NEXTLEVEL:
	MOV R6, #2D
LLOOP:
	MOV A, #10101010B
	SETB C
	MOV R7, #20D
	ACALL LIGHTS
	
	MOV A, #10101010B
	CPL A
	CLR C
	MOV R7, #20D
	ACALL LIGHTS
	
	DJNZ R6, LLOOP
	
	MOV A, #0D
	CLR C
	ACALL LIGHTS
	
	RET

; USES REGISTERS R6, R7, A, B
; light sequence for the losing state
; bright flash of lights twice
LOST:
	MOV R6, #2D

LOLOOP:
	MOV A, #0FFH
	SETB C
	MOV R7, #20D
	ACALL LIGHTS
	
	CLR A 
	CLR C
	MOV R7, #20D
	ACALL LIGHTS

	DJNZ R6, LOLOOP
	
	RET

; USES REGISTERS R6, R7, A, B
; light sequence for the winning state
WINNER:
	/* LIGHT SPIRAL PART I	*/
	MOV R6, #3D
	
	MOV A, #00000000B
    CLR C
	MOV R7, 6
	ACALL LIGHTS
	
    MOV A, #10000000B
    CLR C
	MOV R7, 6
	ACALL LIGHTS
	
    MOV A, #11000000B
    CLR C
	MOV R7, 6
	ACALL LIGHTS
	
    MOV A, #11100000B
    CLR C
	MOV R7, 6
	ACALL LIGHTS
	
    MOV A, #11100100B
    CLR C
	MOV R7, 6
	ACALL LIGHTS
	
    MOV A, #11100100B
    SETB C
	MOV R7, 6
	ACALL LIGHTS
	
    MOV A, #11100101B
    SETB C
	MOV R7, 6
	ACALL LIGHTS
	
    MOV A, #11100111B
    SETB C
	MOV R7, 6
	ACALL LIGHTS

    MOV A, #11110111B
    SETB C
	MOV R7, 6
	ACALL LIGHTS
	
    MOV A, #11111111B
    SETB C
	MOV R7, 6
	ACALL LIGHTS
	
	/* LIGHT SPIRAL PART II	*/

	MOV A, #00000000B
	CLR C
	MOV R7, 6
	CPL A
	CPL C
	ACALL LIGHTS

	MOV A, #10000000B
	CLR C
	MOV R7, 6
	CPL A
	CPL C
	ACALL LIGHTS

	MOV A, #11000000B
	CLR C
	MOV R7, 6
	CPL A
	CPL C
	ACALL LIGHTS

	MOV A, #11100000B
	CLR C
	MOV R7, 6
	CPL A
	CPL C
	ACALL LIGHTS

	MOV A, #11100100B
	CLR C
	MOV R7, 6
	CPL A
	CPL C
	ACALL LIGHTS

	MOV A, #11100100B
	SETB C
	MOV R7, 6
	CPL A
	CPL C
	ACALL LIGHTS

	MOV A, #11100101B
	SETB C
	MOV R7, 6
	CPL A
	CPL C
	ACALL LIGHTS

	MOV A, #11100111B
	SETB C
	MOV R7, 6
	CPL A
	CPL C
	ACALL LIGHTS

	MOV A, #11110111B
	SETB C
	MOV R7, 6
	CPL A
	CPL C
	ACALL LIGHTS

	MOV A, #11111111B
	SETB C
	MOV R7, 6
	CPL A
	CPL C
	ACALL LIGHTS
	
	/* FULL LIGHT SPIRAL */
	MOV R6, #8D
	MOV R5, #5D
L1:
	MOV A, #10101010B
	SETB C
	MOV R7, 6
	ACALL LIGHTS
	
	MOV A, #01011101B
	CLR C
	MOV R7, 6
	ACALL LIGHTS
	
	DJNZ R5, L1
	
	/* Blowing Os */
	MOV R6, #8D
	MOV R5, #7D
L2:
	MOV A, #11110111B
	SETB C
	MOV R7, 6
	ACALL LIGHTS
	
	MOV A, #00001000B
	CLR C
	MOV R7, 6
	ACALL LIGHTS
	DJNZ R5, L2
	
	/* transitions well into..*/
	MOV A, #11110111B
	SETB C
	MOV R7, 6
	ACALL LIGHTS
	
	/* The windmill */
	MOV R6, #6D
	MOV R5, #7D
	
L3:
	MOV A, #10001000B
	SETB C
	MOV R7, 6
	ACALL LIGHTS
	
	MOV A, #01001001B
	CLR C
	MOV R7, 6
	ACALL LIGHTS
	
	MOV A, #00101010B
	CLR C
	MOV R7, 6
	ACALL LIGHTS
	
	MOV A, #00011100B
	CLR C
	MOV R7, 6
	ACALL LIGHTS
	
	DJNZ R5, L3
	
	/* again transition */
	MOV A, #10001000B
	SETB C
	MOV R7, 6
	ACALL LIGHTS
	
	/* C'mon Kage, bring the thundaaa */
	MOV R6, #6D
	MOV R5, #3D
	
L4:
	MOV A, #10000000B
	CLR C
	MOV R7, 6
	ACALL LIGHTS
	
	
	MOV A, #11010000B
	CLR C
	MOV R7, 6
	ACALL LIGHTS
	
	
	MOV A, #11111010B
	CLR C
	MOV R7, 6
	ACALL LIGHTS
	
	
	MOV A, #11111111B
	CLR C
	MOV R7, 6
	ACALL LIGHTS
	
	
	MOV A, #11111111B
	SETB C
	MOV R7, 6
	ACALL LIGHTS
	
	; role reversal 
	
	MOV A, #10000000B
	CLR C
	CPL A
	CPL C
	MOV R7, 6
	ACALL LIGHTS
	
	
	MOV A, #11010000B
	CLR C
	CPL A
	CPL C
	MOV R7, 6
	ACALL LIGHTS
	
	
	MOV A, #11111010B
	CLR C
	CPL A
	CPL C
	MOV R7, 6
	ACALL LIGHTS
	
	
	MOV A, #11111111B
	CLR C
	CPL A
	CPL C
	MOV R7, 6
	ACALL LIGHTS
	
	
	MOV A, #11111111B
	SETB C
	CPL A
	CPL C
	MOV R7, 6
	ACALL LIGHTS
	
	DJNZ R5, L4
	RET
	
	
	END
