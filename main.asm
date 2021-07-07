#make_bin#

; BIN is plain binary format similar to .com format, but not limited to 1 segment;
; All values between # are directives, these values are saved into a separate .binf file.
; Before loading .bin file emulator reads .binf file with the same file name.

; All directives are optional, if you don't need them, delete them.

; set loading address, .bin file will be loaded to this address:
#LOAD_SEGMENT=FFFFh#
#LOAD_OFFSET=0000h#

; set entry point:
#CS=0000h#	; same as loading segment
#IP=0000h#	; same as loading offset

; set segment registers
#DS=0000h#	; same as loading segment
#ES=0000h#	; same as loading segment

; set stack
#SS=0000h#	; same as loading segment
#SP=FFFEh#	; set to top of loading segment

; set general registers (optional)
#AX=0000h#
#BX=0000h#
#CX=0000h#
#DX=0000h#
#SI=0000h#
#DI=0000h#
#BP=0000h#

; add your code here
;jump to the start of the code - reset address is kept at 0000:0000
;as this is only a limited simulation
		jmp     st1  ;takes 3 bytes
		db		253 dup(0)
		
;We are keeping INT 40h  ;256 + 4 (1k=1024) (1024-256-4 = 764)
		dw		b_isr
		dw 		0000
		db		764 dup(0)

;Data Declarations
		PORTA1 	EQU 00h
		PORTB1 	EQU 02h
		PORTC1 	EQU 04h
		CREG1 	EQU 06h

		PORTA2 	EQU 08h
		PORTB2 	EQU 0Ah
		PORTC2 	EQU 0Ch
		CREG2 	EQU 0Eh
		
		PIC1	EQU	80h
		PIC2	EQU	82h
		
		MAXCHOC EQU 50 ;Max no of perks
		
;Weights of the chocolates
;100/1024 = 0.09765625
		PWT		EQU	92		;9gms -> 92.16 ~ 92  
		FSWT	EQU	184		;18gms -> 184.32 ~ 184
		INWT	EQU	276		;27gms -> 276.48 ~ 276
		DMWT	EQU	368		;36gms -> 368.64 ~ 368
		
;Main Program
st1:	cli

;Initialize DS,ES,SS to start of RAM
		MOV AX,0100h  ;Start of ram = 0100 as 2k ROM chips in the start
		MOV DS,AX
		MOV ES,AX
		MOV SS,AX
		MOV SP,0FFFEh

;Initialize ports
		MOV AL,9Ah 	
		OUT CREG1,AL
		
		MOV AL,80h	
		OUT CREG2,AL
		
		MOV AL,11111111b
		OUT PORTA2,AL


;TURN OFF ALL LEDs  
		MOV AL,01h
		OUT CREG2,AL
		
		MOV AL,03h
		OUT CREG2,AL
		
		MOV AL,05h
		OUT CREG2,AL
		
		MOV AL,07h
		OUT CREG2,AL

;Initialize all Stepper Motors to pos 1  (Sanity check)
		MOV AL,05h	;	PERK MOTOR
		OUT PORTC2,AL 
		
		MOV AL,15h ;	FIVE STAR MOTOR
		OUT PORTC2,AL
		
		MOV AL,25h	;	DAIRY MILK MOTOR
		OUT PORTC2,AL
		
		MOV AL,35h	;	COIN MOTOR
		OUT PORTC2,AL

;Initialize 8259
		MOV AL,13h
		OUT PIC1,AL

		MOV AL,40h
		OUT PIC2,AL
		
		MOV AL,03h
		OUT PIC2,AL

		MOV AL,0FEh
		OUT PIC2,AL
		
;Load Count of Chocolates
		MOV AX,MAXCHOC
		MOV [200h],AX 	;Perk count
		MOV [202h],AX	;Five star
		MOV [204h],AX	;Dairy milk
		MOV AX,0
		MOV [206h],AX	;Chocolate code
		MOV AX,0
		MOV [208h],AX	;Weight of coins

		STI  ;Turing on interrupts
		
;loop till isr, MuP in Idle State
X1:		JMP		X1


check_c:
		IN AL,PORTC1
		AND AL,0F0h ;Mask lower nibble
		MOV BL,AL
		AND BL,00010000b
		CMP BL,10h
		JNE X2
		MOV [206h],1h  	;If perk then 1
		RET
X2:		MOV BL,AL
		AND BL,00100000b
		CMP BL,20h
		JNE X3
		MOV [206h],2h	;If five star then 2
		RET
X3:		MOV [206h],3h	;If dairy milk then 3
		RET


;Dispense Perk
disp_p:
		MOV DX, PORTC2
		MOV AL, 00000101b
		OUT DX,AL

		MOV CX, 0ffffh     ; Delay  (around 0.236s)
loopy1a:loop loopy1a   ;

		MOV AL, 00001001b
		OUT DX,AL

		MOV CX, 0ffffh     ; Delay again
loopy2a:loop loopy2a   ;

		MOV AL, 00001010b
		OUT DX,AL

		MOV CX, 0ffffh     ; Delay again
loopy3a:loop loopy3a   ;

		MOV AL, 00000110b
		OUT DX,AL

		MOV CX, 0ffffh     ; Delay again
loopy4a:loop loopy4a   ;
		RET


;Dispense Five Star
disp_fs:
		MOV DX, PORTC2
		MOV AL, 00010101b
		OUT DX,AL

		MOV CX, 0ffffh     ; Delay (around 0.236s)
loopy1b:loop loopy1b   ;

		MOV AL, 00011001b
		OUT DX,AL

		MOV CX, 0ffffh     ; Delay again
loopy2b:loop loopy2b   ;

		MOV AL, 00011010b
		OUT DX,AL

		MOV CX, 0ffffh     ; Delay again
loopy3b:loop loopy3b   ;

		MOV AL, 00010110b
		OUT DX,AL

		MOV CX, 0ffffh     ; Delay again
loopy4b:loop loopy4b   ;
		RET


;Dispense Dairy Milk
disp_dm:
		MOV DX, PORTC2
		MOV AL, 00100101b
		OUT DX,AL

		MOV CX, 0ffffh     ; Delay (around 0.236s)
loopy1c:loop loopy1c   ;

		MOV AL, 00101001b
		OUT DX,AL

		MOV CX, 0ffffh     ; Delay again
loopy2c:loop loopy2c   ;

		MOV AL, 00101010b
		OUT DX,AL

		MOV CX, 0ffffh     ; Delay again
loopy3c:loop loopy3c   ;

		MOV AL, 00100110b
		OUT DX,AL

		MOV CX, 0ffffh     ; Delay again
loopy4c:loop loopy4c   ;
		RET


;Move Coins from weight sensor
disp_c:
		MOV DX, PORTC2
		MOV AL, 00110101b
		OUT DX,AL

		MOV CX, 0ffffh     ; Delay (around 0.236s)
loopy1d:loop loopy1d   ;

		MOV AL, 00111001b
		OUT DX,AL

		MOV CX, 0ffffh     ; Delay again
loopy2d:loop loopy2d   ;

		MOV AL, 00111010b
		OUT DX,AL

		MOV CX, 0ffffh     ; Delay again
loopy3d:loop loopy3d   ;

		MOV AL, 00110110b
		OUT DX,AL

		MOV CX, 0ffffh     ; Delay again
loopy4d:loop loopy4d   ;

		;Make Weight and code 0
		MOV AX,0
		MOV [206h],AX	;Chocolate code
		MOV AX,0
		MOV [208h],AX	;Weight of coins
		
		RET


read_w:	;CS' LOW
		MOV AL,11111110b
		OUT PORTA2,AL
		;WR' LOW,  		Need not bother 50 ns keep WR LOW
		MOV AL,11111100b
		OUT PORTA2,AL
		;WR' HIGH
		MOV AL,11111110b
		OUT PORTA2,AL
		;CS'	HIGH
		MOV AL,11111111b
		OUT PORTA2,AL
;wait for atleast 6micro secs before
;1 cycle = 0.2microsecs and one nop is 3 cycles
;one nop = 0.6microsecs so 10*nop = 6microsecs
		NOP
		NOP
		NOP
		NOP
		NOP
		NOP
		NOP
		NOP
		;CS' LOW
		MOV AL,11111110b
		OUT PORTA2,AL
		;RD' LOW
		MOV AL,11111010b
		OUT PORTA2,AL
		;Data available
		IN AL,PORTB1
		MOV [208h],AL
		IN AL,PORTA1
		MOV [209h],AL
		;Make CS' and RD' high again
		MOV AL,11111110b
		OUT PORTA2,AL
		MOV AL,11111111b
		OUT PORTA2,AL
		RET


;sub-routine for 0.2s delay 
delay_w:MOV CX,55554 ; delay generated will be approx 0.2 secs
XN:		LOOP XN
		RET
		

;sub-routine for 2s delay 
delay_l:MOV DL,10
XO:		MOV CX,55554 ; delay generated will be approx 0.2 secs
XP:		LOOP XP
		DEC	DL
        JNZ	XO
		RET

;Wrong input subroutine
wr_in:
		;TURN OFF INSUFFICIENT COINS LED
		;Using BSR
		;00000111
		MOV AL,07h
		OUT PORTC1,AL
		;Turn on Wrong Input LED
		MOV AL,11110111b
		OUT PORTA2,AL
		;Delay for 2 secs
		CALL delay_l
		;Turn off Wrong Input LED
		MOV AL,11111111b
		OUT PORTA2,AL
		CALL disp_c
		
		;Make Weight and code 0
		MOV AX,0
		MOV [206h],AX	;Chocolate code
		MOV AX,0
		MOV [208h],AX	;Weight of coins
		
		RET
		
		
		
		
b_isr:  CALL check_c
		;TURN ON INSUFFICIENT COINS LED
		;Using BSR
		;00000110
		MOV AL,06h
		OUT PORTC1,AL
		
Z1:		CALL read_w
		MOV BX,[208h]
		CALL delay_w
		CMP BX, 0
		JE Z1  ;Read until we get a non zero value
		CMP BX, PWT
		JE Z2  ;If weight not equal to PWT, next steps, or else take further weight
		
		;Wrong input call
		CALL wr_in
		IRET

Z2:		MOV BX,[206h]
		CMP BX,1 ;Check for choc=perk
		JNE Z3
		;TURN OFF INSUFFICIENT COINS LED
		;Using BSR
		;00000111
		MOV AL,07h
		OUT PORTC1,AL
		;Move coins off weight sensor
		CALL disp_c
		;Dispense Chocolate
		CALL disp_p
		;Decrement No of chocolates
		DEC [200h]
		;Check if chocolates are over
		MOV BX,[200h]
		CMP BX,0
		JNE Z3A:
		;TURN ON INSUFFICIENT PERK LED
		;Using BSR
		;00000000
		MOV AL,00h
		OUT PORTC1,AL
Z3A:	IRET

Z3:		CALL delay_w
		CALL read_w
		MOV BX,[208h]
		CMP BX,PWT
		;Run until next input not equal to perk wt
		JE	Z3
		
		;Mov new weight
		MOV BX,[208h]
		CMP BX, FSWT
		;Check if next wt is equal to five star
		JE Z4
		
		CALL wr_in
		IRET

Z4:		MOV BX,[206h]
		;Check for choc=five star
		CMP BX,2 
		JNE Z5
		;TURN OFF INSUFFICIENT COINS LED
		;Using BSR
		;00000111
		MOV AL,07h
		OUT PORTC1,AL
		;Move coins off weight sensor
		CALL disp_c
		;Dispense Chocolate
		CALL disp_fs
		;Decrement No of chocolates
		DEC [202h]
		;Check if chocolates are over
		MOV BX,[202h]
		CMP BX,0
		JNE Z4A:
		;TURN ON INSUFFICIENT FIVE STAR LED
		;Using BSR
		;00000010
		MOV AL,02h
		OUT PORTC1,AL
Z4A:	IRET
		
Z5:		CALL delay_w
		CALL read_w
		MOV BX,[208h]
		CMP BX,FSWT
		;Run until next wt not equal to five star wt
		JE Z5
		
		;Mov new weight
		MOV BX,[208h]
		CMP BX, INWT
		;Check if next wt is equal to intermediate wt
		JE Z6
		
		CALL wr_in
		IRET
		
Z6:		CALL delay_w
		CALL read_w
		MOV BX,[208h]
		CMP BX,INWT
		;Run until next wt not equal to intermediate wt 
		JE Z6
		
		;Mov new weight
		MOV BX,[208h]
		CMP BX, DMWT
		;Check if next wt is equal to intermediate wt
		JE Z7
		
		CALL wr_in
		IRET
		
Z7:		;TURN OFF INSUFFICIENT COINS LED
		;Using BSR
		;00000111
		MOV AL,07h
		OUT PORTC1,AL
		;Move coins off weight sensor
		CALL disp_c
		;Dispense Chocolate
		CALL disp_dm
		;Decrement No of chocolates
		DEC [204h]
		;Check if chocolates are over
		MOV BX,[204h]
		CMP BX,0
		JNE Z7A:
		;TURN ON INSUFFICIENT DAIRY Milk LED
		;Using BSR
		;00000110
		MOV AL,03h
		OUT PORTC1,AL
Z7A:	IRET
		
		
;Eg: 0.2s
;;delay calculation
; no. of cycles for loop = 18 if taken/ 5 if not taken = 55553 x 18 + 5
;no. of cycles for ret 16
;no. of cycles for call 19
;no. of cycles for mov 4 
;clock speed 5 MHz - 1 clock cycle 0.2us
;total no.cycles delay = clkcycles for call + mov cx,imm + (content of cx-1)*18+5 + ret
;= (19 +4+ 18*55,553+5+16)0.2us = 0.1999996s  
