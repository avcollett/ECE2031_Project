; Simple test for the NeoPixel peripheral

ORG 0
	LOADI  10
    OUT    PXL_ALL
	LOADI  10
	LOADI  10
	LOADI  10
	LOADI  &H006F
	OUT    PXL_24_G
	LOADI  &HFF00
	OUT    PXL_24_RB
	LOADI  &H006F
	OUT    PXL_24_G
	LOADI  &HFF00
	OUT    PXL_24_RB
	
	
	

    

; IO address constants
Switches:  EQU 000
LEDs:      EQU 001
Timer:     EQU 002
Hex0:      EQU 004
Hex1:      EQU 005

PXL_A:     EQU &H0B0
PXL_D:     EQU &H0B1

PXL_ALL:   EQU &H0B2
INC_REV:   EQU &H0B3
PXL_24_RB:  EQU &H0B4
PXL_24_G:   EQU &H0B5
