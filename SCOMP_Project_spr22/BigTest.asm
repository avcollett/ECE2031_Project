; Simple test for the NeoPixel peripheral

ORG 0
Start:
		IN 	   Switches
		ADDI   -1
		JZero  Demo1
		ADDI   -1
		JZero  Demo2
		ADDI   -1
		JZero  Demo3
		
		OUT	   INC_REV
		LOADI  7
		OUT    PXL_A

		LOADI  10
		OUT    PXL_D
		ADDI   100
		OUT    PXL_D
		ADDI   100
		OUT    PXL_D
		ADDI   100
		OUT    PXL_D
		ADDI   100
		OUT    PXL_D
		ADDI   100
		OUT    PXL_D
		ADDI   100
		OUT    PXL_D
		ADDI   100
		OUT    PXL_D
		JUMP   End
		
Demo1:	
		LOADI  10
		OUT    PXL_ALL
		NOP		
		NOP		
		NOP		
		NOP		
		NOP
		NOP
		NOP
		NOP
		NOP
		NOP
		NOP
		NOP
		LOADI  &H006F
		OUT    PXL_24_G
		LOADI  &HFF00
		OUT    PXL_24_RB
		LOADI  &H006F
		OUT    PXL_24_G
		LOADI  &HFF00
		OUT    PXL_24_RB
		JUMP   End
		
Demo2:	
		LOADI  1
		OUT    PXL_A

		LOADI  10
		OUT    PXL_D
		
		LOADI  1
		OUT    PXL_A
		
		IN	   PXL_D
		
		OUT    Hex0
		OUT    PXL_D
		JUMP   End

Demo3:	
	
		LOADI  0
		OUT    PXL_A
		
		LOADI  10
		OUT    PXL_D
		ADDI   100
		OUT    PXL_D
		ADDI   100
		OUT    PXL_D
		ADDI   100
		OUT    PXL_D
		ADDI   100
		OUT    PXL_D
		ADDI   100
		OUT    PXL_D
		ADDI   100
		OUT    PXL_D
		ADDI   100
		OUT    PXL_D
		JUMP   End
		
End:
		JUMP   End

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
