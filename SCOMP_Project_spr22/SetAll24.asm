; Simple test for the NeoPixel peripheral

ORG 0

	;LOADI  &H006F
	;OUT    PXL_24_B
	;LOADI  &HFF00
	;OUT    PXL_ALL_24
	
	LOADI  &H006F
	OUT    PXL_24_B
	LOADI  &HFF00
	OUT    PXL_24_GR
	
End:
	Jump End
	
	

    

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
PXL_24_GR:  EQU &H0B4
PXL_24_B:   EQU &H0B5
PXL_ALL_24: EQU &H0B6
