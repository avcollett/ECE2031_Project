; Simple test for the NeoPixel peripheral

ORG 0
Start:
		
		IN 	   Switches
	
		JZero  Demo1
		ADDI   -1
		JZero  Demo2
		ADDI   -1
		JZero  Demo3
		ADDI   -1
		JZero  Demo4
		
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
		
		loadi 128
Wait:  
		Addi -1
		jpos Wait
		
		

		LOADI  &H006F
		OUT    PXL_24_B
		LOADI  &HFF00
		OUT    PXL_24_GR
		LOADI  &H006F
		OUT    PXL_24_B
		LOADI  &HFF00
		OUT    PXL_24_GR
		JUMP   End
		
Demo2:	
		LOADI  1
		OUT    PXL_A

		LOADI  5000
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
		
		
Demo4:

		LOADI  &H006F
		OUT    PXL_24_B
		LOADI  &HFF00
		OUT    PXL_ALL_24
	JUMP End
		
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
PXL_24_GR:  EQU &H0B4
PXL_24_B:   EQU &H0B5
PXL_ALL_24: EQU &H0B6