;  Comment block below must be filled out completely for each assignment
;  ************************************************************* 
;  Student Name: Zack Garza
;  COMSC-260 Spring 2015
;  Date: 1/21/2015
;  Assignment #1
;  Version of Visual Studio used (2010)(2012)(2013): VS 2013
;  Did program compile? Yes
;  Did program produce correct results? Yes
;
;  Estimate of time in hours to complete assignment: 3
;  
;  Short description of what program does:
;		Exercises in assigning to registers and adding numbers.




.386								; identifies minimum CPU for this program

.MODEL flat,stdcall					; flat - protected mode program
									; stdcall - enables calling of MS_windows programs

; allocate memory for stack
; (default stack size for 32 bit implementation is 1MB without .STACK directive 
;  - default works for most situations)

.STACK 4096							; allocate 4096 bytes (1000h) for stack

;*************************PROTOTYPES*****************************

ExitProcess PROTO,dwExitCode:DWORD  ;from Win32 api not Irvine

DumpRegs PROTO						;Irvine code for printing registers to the screen

ReadChar PROTO						;Irvine code for getting a single char from keyboard
									;Character is stored in the al register.
									;Can be used to pause program execution until key is hit.

;************************DATA SEGMENT***************************

.data

	num1	WORD	0F8FEh			; 2 byte, unsigned
	num2	WORD	0FDC6h			; 0->65,535

;************************CODE SEGMENT****************************

.code

; Shortcut Macro, saves some keystrokes on adding numbers with
;	differing sizes.

; esi is used as a scratch register (since it has the proper size to add to eax)
; Preconditions: destination is an 8 byte register, addend is <= 8 bytes.
addToRegister	macro	destination, addend
				movzx	esi, addend				; Upconvert addend to 8 bytes
				add		destination, esi		; Add it to destination
				endm

; The actual program, from the assignment.
main PROC

	; ************* Part 1: Assign Variables *************

	mov		eax,0E2A6FFFDh			; 4 bytes, in an 8 byte register
	mov		ecx,0FFFFFFFFh			; 4 bytes, in an 8 byte register
	mov		edx,0FFFFFFFFh			; 4 bytes, in an 8 byte register
	mov		ch,254					; 1 byte,  in a 2 byte register
	mov		cl,11111001b			; 1 byte,  in a 2 byte register
	mov		bx,0FFE7h				; 2 bytes, in a 2 byte register
		

	; ************* Part 2: Perform Addition *************
	
	; The total will be stored in edx.
	; First, copy the first argument (and zero out, due to previous assignment)

	; edx = num1 ...
	movzx			edx,num1				
	
	; + num2 ...
	addToRegister	edx, num2		; Upconvert num2 to 8 bytes, then add to edx

	; + eax ...
	add				edx,eax			; Same size, so just add directly		

	; + bx ...
	addToRegister	edx, bx			; Upconvert bx to 8 bytes, then add to edx
	
	; + ch 
	addToRegister	edx, ch			; Upconvert ch to 8 bytes, then add to edx			

	; + cl.
	addToRegister	edx, cl			; Upconvert cl to 8 bytes, then add to edx			

	; Assert edx = E2A9F89F  (Reuslt from calculator)

    call	DumpRegs				; display registers
	call	ReadChar				; pause until key input is received 
	INVOKE	ExitProcess,0			; exit

main ENDP

END main