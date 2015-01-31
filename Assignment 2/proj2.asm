; ************************************************************* 
; Student Name: Zack Garza
; COMSC-260 Spring 2015
; Date: 2/4/2015
; Assignment #2
; Version of Visual Studio used (2010)(2012)(2013): VS 2013
; Did program compile? Yes
; Did program produce correct results? Yes
;
; Estimate of time in hours to complete assignment: 
;  
; Short description of what program does:
;
; Calculates the expression num1+((num2*num3)%num4)-(num5/num6)
;  ************************************************************* 


; *************************SETUP*****************************
.386								; identifies minimum CPU for this program

.MODEL flat,stdcall					; flat - protected mode program
									; stdcall - enables calling of MS_windows programs

.STACK 4096							; allocate 4096 bytes (1000h) for stack
;	(default stack size for 32 bit implementation is 1MB without .STACK directive 
;   - default works for most situations)
;  ************************************************************* 


; *************************PROTOTYPES*****************************
ExitProcess PROTO,dwExitCode:DWORD  ; from Win32 api not Irvine

DumpRegs PROTO						; Irvine code for printing registers to the screen

ReadChar PROTO						; Irvine code for getting a single char from keyboard
									; Character is stored in the al register.
									; Can be used to pause program execution until key is hit.
;  ************************************************************* 


;************************DATA SEGMENT***************************
.data
	LF		equ		0Ah				; Line Feed as a symbolic constant.

	num1	DWORD	6D1BB2h			; 32 bit Unsigned
	num2	DWORD	4CC4h			; 
	num3	DWORD	0F898h			;
	num4	DWORD	25h				;
	num5	DWORD	6CF3B47Bh		;
	num6	DWORD	0CDB5h			;

	string1	BYTE	"Program 2 by Zack Garza.", 0, LF	;
	string2	BYTE	"Hit any key to exit.", 0, LF		;

; ************************************************************* 


;************************CODE SEGMENT****************************
.code

main PROC
; Usable registers:
;	eax (ax, ah, al)	[Accumulator, used for arithmetic]
;	ebx (bx, bh, bl)	[Base, used as pointer to data]
;	ecx (cx ,ch, cl)	[Counter, used in loops and shifts/rotations]
;	edx	(cx, ch, cl)	[Data, used in arithmetic and I/O]
;	esi (si)			[Source, used as a source in stream operations]
;	edi (di)			[Destination, also used in stream operations]

; Calculates the expression num1+((num2*num3)%num4)-(num5/num6)

	mov eax, num2		; num2 * num3
	mul num3			;
						; Assert eax = 4A8B7460h

	div num4			; % num4
						; Assert eax = 203C4E0	(quotient)
						; Assert edx = 0		(remainder)

	mov esi, num1		; num1 + (above stuff)
	add esi, edx		; Just add the remainder from above.
						; Assert esi = 6D1BB2h

	mov eax, num5		; - (num5 / num6)
	div num6			; 
						; Assert edx = 8796h
						;
	sub esi, eax		; Final result will be held in esi
						; Assert esi	= 6C941Ch

    call	DumpRegs				; display registers
	call	ReadChar				; pause until key input is received 
	INVOKE	ExitProcess,0			; exit

main ENDP

END main
;  *************************************************************