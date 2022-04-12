; Simple test for the NeoPixel peripheral

ORG 0
    LOADI  0
    OUT    PXL_A
Loop:
	LOAD adding
    OUT    PXL_D
	LOAD adding
	ADDI 1000
	STORE adding
    JUMP   Loop
    

; IO address constants
Switches:  EQU 000
LEDs:      EQU 001
Timer:     EQU 002
Hex0:      EQU 004
Hex1:      EQU 005
adding:		DW 0
PXL_A:     EQU &H0B0
PXL_D:     EQU &H0B1