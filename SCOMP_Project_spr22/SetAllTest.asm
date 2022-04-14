; Simple test for the NeoPixel peripheral

ORG 0

	LOADI  1
    OUT    PXL_A
	LOADI  16
	OUT PXL_D
	
	
	
	LOADI 1
	OUT PXL_A
	IN PXL_D
	STORE variable
	

	LOADI 3
	OUT PXL_A
	LOAD variable
	OUT PXL_D

	

	

    

; IO address constants
Switches:  EQU 000
LEDs:      EQU 001
Timer:     EQU 002
Hex0:      EQU 004
Hex1:      EQU 005

PXL_A:     EQU &H0B0
PXL_D:     EQU &H0B1
PXL_24:    EQU &H0B2
PXL_ALL:   EQU &H0B3
INC_REV:   EQU &H0B4
variable:  DW  0