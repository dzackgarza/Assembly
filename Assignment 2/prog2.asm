; ************************************************************* 
; Student Name: Zack Garza
; COMSC-260 Spring 2015
; Date: 2/4/2015
; Assignment #2
; Version of Visual Studio used (2010)(2012)(2013): VS 2013
; Did program compile? Yes
; Did program produce correct results? Yes
;
; Estimate of time in hours to complete assignment: 5
;  
; Short description of what program does: 
; Calculates the following arithmetic expression:
;       num1 + ( ( num2 * num3 ) % num4 ) - ( num5 / num6 )
; And prints out the operations as hexadecimal digits. 
;  ************************************************************* 


; *************************SETUP*****************************
.386								; identifies minimum CPU for this program

.MODEL flat,stdcall				              ; flat - protected mode program
									                      ; stdcall - enables calling of MS_windows programs

.STACK 4096							                ; allocate 4096 bytes (1000h) for stack
;	(default stack size for 32 bit implementation is 1MB without .STACK directive 
;   - default works for most situations)
;  ************************************************************* 


; *************************PROTOTYPES*****************************
ExitProcess PROTO,dwExitCode:DWORD      ; from Win32 api not Irvine

DumpRegs PROTO						              ; Irvine code for printing registers to the screen

WriteHex PROTO						              ; write the number stored in eax to the console as a hex number
									                      ; before calling WriteHex put the number to write into eax

WriteString PROTO				                ; write null-terminated string to console
									                      ; edx contains the address of the string to write
									                      ; before calling WriteString put the address of the string to write into edx
									                      ; e.g. mov edx, offset message ;address of message is copied to edx

ExitProcess PROTO,dwExitCode:DWORD	    ; exit to the operating system

ReadChar PROTO						              ; Irvine code for getting a single char from keyboard
									                      ; Character is stored in the al register.
									                      ; Can be used to pause program execution until key is hit.

WriteChar PROTO						              ; Irvine code for printing a single char to the console.
									                      ; Character to be printed must be in the al regist
;  ************************************************************* 


;************************DATA SEGMENT***************************
.data
	LF		equ		0Ah				                                    ; Line Feed as a symbolic constant.

	num1	DWORD	6D1BB2h			                                  ; 32 bit Unsigned
	num2	DWORD	4CC4h			                                    ; 
	num3	DWORD	0F898h			                                  ;
	num4	DWORD	25h				                                    ;
	num5	DWORD	6CF3B47Bh		                                  ;
	num6	DWORD	0CDB5h			                                  ;

	introString	  BYTE	  "Program 2 by Zack Garza.", 0, LF	  ;
	exitString	  BYTE	  "Hit any key to exit.", 0, LF		    ;
	hPlus		      BYTE	  "h + ", 0	                          ;
	hTimes		    BYTE	  "h * ", 0		                        ;
	hMod		      BYTE	  "h % ", 0		                        ;
	hMinus		    BYTE	  "h - ", 0		                        ;
	hDiv		      BYTE	  "h / ", 0		                        ;
	hEquals		    BYTE	  "h = ", 0		                        ;
	period		    BYTE	  ".", 0			                        ;
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
	
	
	mov edx, offset introString		; Write "Program 2 by *name*"
	call WriteString				  ;

	mov eax, num1					    ; Write "num1 + ..."
	call WriteHex					    ; (Done here because by the time we get num1 into eax, 
	mov edx, offset hPlus			;   num2 has already been processed - but the calculation
	call WriteString				  ;   and printing of num2 can both be done with num2 in eax.
									          ;   So, it saves a few instructions to just make the isolated print call now.)

	mov eax, num2					    ; Write "num2 * ..." and calculate num2 * num3
	call WriteHex					    ; 
	mov edx, offset hTimes		;
	call WriteString				  ;
									          ;
	mul num3						      ; => eax = num2 * num3
									          ; Assert eax = 4A8B7460h ( = num2 * num3)

	div num4						      ; Calculate (num2 * num3) % num4
									          ; Assert eax = 203C4E0	(quotient)
									          ; Assert edx = 0		(remainder)*

	mov esi, num1					    ; Calculate num1 + (num2 * num3 % num4)
	add esi, edx					    ; Just add the remainder from above.
									          ; Assert esi = 6D1BB2h

									          ; Now we'll go back and print a few of the numbers we missed
	mov eax, num3					    ; Write "num3 % ..." 
	call WriteHex					    ; Note: eax can be overwritten here, since we only needed 
	mov edx, offset hMod			;   the remainder edx above.
	call WriteString				  ;

	mov eax, num4					    ; Write "num4 - ..."
	call WriteHex					    ;
	mov edx, offset hMinus		;
	call WriteString				  ;

	mov eax, num5					    ; Write "num5 / ..." and calculate num5 / num6
	call WriteHex					    ;
	mov edx, offset hDiv			;
	call WriteString				  ;
	
	xor edx, edx					    ; Set edx to zero to clear it from earlier string printing.
	div num6						      ; => edx = eax	/ num6
									          ; => edx = num5 / num6
									          ; Assert edx = 8796h (num5 / num6)
							
									          ; Calculate (num1 + num2 * num3 % num4) - (num5 / num6)
									          ;
	sub esi, eax					    ; => esi =	esi							-	eax
									          ; => esi =	(num1 + num2 * num3 % num4) -	(num5 / num6)
									          ; Assert esi = 6C941Ch

	mov eax, num6					    ; Write "num6 = "
	call WriteHex					    ;
	mov edx, offset hEquals		;
	call WriteString				  ;

	mov eax, esi					    ; Write final evaluation
	call WriteHex					    ;
	mov edx, offset period		;
	call WriteString				  ;

  call	DumpRegs				    ; display registers
	call	ReadChar				    ; pause until key input is received 
	INVOKE	ExitProcess,0			; exit

main ENDP

END main
;  *************************************************************