; Simple test for the NeoPixel peripheral

ORG 0

	LOADI  0
    OUT    PXL_A
	LOADI  10
Loop:
    
    OUT    PXL_D
	ADDI   10
    JUMP   Loop

; IO address constants
Switches:  EQU 000
LEDs:      EQU 001
Timer:     EQU 002
Hex0:      EQU 004
Hex1:      EQU 005
PXL_A:     EQU &H0B0
PXL_D:     EQU &H0B1