#include <reg932.inc>
	CSEG AT 200H // FIND A SAFE PLACE TO PACE DB VALUES
NOTES: DB 64,21, 64,21, 64,20, 64,18, 64,18, 64,20, 64,21, 64,24, 64,27, 64,27, 64,24, 64,21, 64,21, 64,24, 64,24
	
    LCALL START_MUSIC
    LCALL DONE

START_MUSIC:   			
SETB PSW.3
SETB PSW.4
MOV C,P2.0  		
SONG: MOV DPTR, #200H
MOV R0,#0FH
READ_NOTES: CLR A
	MOVC A, @A+DPTR
	MOV R1, A
	CLR A
	INC DPTR
	MOVC A, @A+DPTR
	MOV R6, A
	LCALL PLAY_NOTE
	LCALL PAUSE
	INC DPTR
	DJNZ R0, READ_NOTES
    CLR PSW.3 //SWITCH TO REGISTER BANK 0
    CLR PSW.4
RET

PLAY_NOTE: 
	MOV 13, R6
	MOV 14, R1
	MOV R3, #20
	TIME_LOOP1:
	MOV R7, #10
	TIME_LOOP2:
	MOV R1, 14
	FREQ_LOOP1:
	MOV R6, 13
	FREQ_LOOP0:NOP
	DJNZ R6, FREQ_LOOP0
	DJNZ R1, FREQ_LOOP1
	CPL P1.7
	DJNZ R7, TIME_LOOP2
	DJNZ R3, TIME_LOOP1
RET

PAUSE:
  MOV R3, #30
  TIME1: MOV R7, #20
  TIME2: NOP
  DJNZ R7, TIME2
  DJNZ R3, TIME1
RET
