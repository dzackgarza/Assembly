; ************************************************************* 
; Student Name: Zack Garza
; COMSC-260 Spring 2015
; Date: 2/12/2015
; Assignment #3
; Version of Visual Studio used (2010)(2012)(2013): VS 2013
; Did program compile? Yes
; Did program produce correct results? Yes
;
; Estimate of time in hours to complete assignment: 3
;  
; Short description of what program does: 
;   Practice loops and if/else statements with jmp and cmp.
;   Generates a random number in the range Ah to Eh using Randomize
;   and RandomRange functions, and the user will try to guess the number.
;   (Note - the numbers are entered in hex, so entering 11 is actually 17d!
;  ************************************************************* 


; *************************SETUP*****************************
.386								                    ; identifies minimum CPU for this program

.MODEL flat,stdcall				              ; flat - protected mode program
									                      ; stdcall - enables calling of MS_windows programs

.STACK 4096							                ; allocate 4096 bytes (1000h) for stack
;	(default stack size for 32 bit implementation is 1MB without .STACK directive 
;   - default works for most situations)
; *************************************************************


; *******************MACROS********************************

;mPrtStr
;usage: mPrtStr nameOfString
;ie to display a 0 terminated string named message say:
;mPrtStr message

;Macro definition of mPrtStr. Wherever mPrtStr appears in the code
;it will  be replaced with 

mPrtStr  MACRO  arg1                ;arg1 is replaced by the name of string to be displayed
		     push   edx				          ;save edx
         mov    edx, offset arg1    ;address of str to display should be in edx
         call   WriteString         ;display 0 terminated string
         pop    edx				          ;restore edx
ENDM

;Wherever "mPrtStr message" appears in the code it will  be replaced with 
;push edx
;mov edx, offset arg1   
;call WriteString       
;pop edx

;arg1 is replaced with message if that is the name of the string passed in.
; *************************************************************


; *************************PROTOTYPES*****************************
ExitProcess PROTO,dwExitCode:DWORD      ; from Win32 api not Irvine

ReadChar PROTO						              ; Irvine code for getting a single char from keyboard
									                      ; Character is stored in the al register.
									                      ; Can be used to pause program execution until key is hit.

ReadHex PROTO                           ; Irvine code to read 32 bit hex number from console
                                        ; and store it into eax

WriteString PROTO				                ; write null-terminated string to console
									                      ; edx contains the address of the string to write
									                      ; before calling WriteString put the address of the string to write into edx
									                      ; e.g. mov edx, offset message ;address of message is copied to edx

RandomRange PROTO                       ; Returns an unsigned pseudo-random 32-bit integer
                                        ; in EAX, between 0 and n-1. If n = 10 a random number
                                        ; in the range 0-9 is generated. If n = F a random number
                                        ; in the range 0-E is generated.
                                        ;
                                        ; Input parameter: EAX = n.

Randomize PROTO                         ; Re-seeds the random number generator with the current time
                                        ; in seconds
DumpRegs PROTO						              ; Irvine code for printing registers to the screen

WriteHex PROTO						              ; write the number stored in eax to the console as a hex number
									                      ; before calling WriteHex put the number to write into eax

WriteDec PROTO                          ; Irvine code to write number stored in eax
                                        ; to console in decimal

ExitProcess PROTO,dwExitCode:DWORD	    ; exit to the operating system

WriteChar PROTO						              ; Irvine code for printing a single char to the console.
									                      ; Character to be printed must be in the al regist
; ************************************************************* 


;************************DATA SEGMENT***************************
.data

LF		          equ		  0Ah				                                      ; Line Feed as a symbolic constant.

introStr	      BYTE	  "Program 3 by Zack Garza", LF, LF, 0
askStr	        BYTE	  "Guess a hex number in the range A - E.", 0
guessStr	      BYTE	  "Guess: ", 0
tooHighStr      BYTE	  "Too High! (Guess lower)", LF, 0
tooLowStr	      BYTE	  "Too Low! (Guess higher)", LF, 0
correctStr      BYTE	  "Correct!!", LF, 0
doAnotherStr	  BYTE	  "Do another? ('y' or 'Y' to continue. Any other character to exit)", LF, LF, 0
registerStr     BYTE    "Contents of Registers: ", LF, 0
exitStr         BYTE    "Press any key to exit..", LF, 0
; ************************************************************* 


;************************CODE SEGMENT****************************
.code
; Usable registers:
;	eax (ax, ah, al)	[Accumulator, used for arithmetic]
;	ebx (bx, bh, bl)	[Base, used as pointer to data]
;	ecx (cx ,ch, cl)	[Counter, used in loops and shifts/rotations]
;	edx	(cx, ch, cl)	[Data, used in arithmetic and I/O]
;	esi (si)			    [Source, used as a source in stream operations]
;	edi (di)			    [Destination, also used in stream operations]

; Printing strings: use 'mPrtStr message'

; Basic Structure:
;   1. Display a opening message
;   2. Seed the random number generator by calling Randomize
;   3. Enter outer loop (loop1:)
;   4. Display "guess a hex number" message"
;   5. Enter loop2
;   6. Initialize eax with range of 0Fh
;   7. Get the random number (RandomRange)
;   8. if the random number is less than Ah repeat steps 5, 6 and 7. Otherwise proceed to step 9
;   9. enter loop3
;   10. display "guess" message
;   11. get guess from user (ReadHex)
;   12. You should code a series of if/else statements that compares the user's guess to the random number generated and takes
;       appropriate action depending on whether the guess was correct(print "Correct!!" and ask the user to input 'y' or 'Y' to continue
;       (ReadChar), high (print "Too High! (Guess lower)" and repeat loop3) or low (print "Too Low! (Guess higher)" and repeat loop3).
;   13. If the user enters 'Y' or 'y', repeat loop1 (step 3) else quit (exit to dos with ExitProcess).
; All of this is done inside of a doWhile loop.

main PROC
    mPrtStr introStr                            ; Prints "Program 3 by Zack Garza"                                  (1)

    call    Randomize                           ; Start by seeding the RNG                                          (2)

outerLoop:                                      ; Main outer loop (Loop1), loops until user chooses to exit.        (3)
    mPrtStr askStr                              ; Prints "Guess a hex number in the range A - E".                   (4)

generateRandom:                                 ; Jump back here if the random number is not in the right range.    (5)
    mov     eax,        0Fh                     ; Ceiling of the range in which random #s are generated.            (6)
    call    RandomRange                         ; Move a random number from the range [0,Eh] into eax.              (7)

    cmp     eax,        0Ah                     ; Check to see if random number is greater than A                   (8)
    jb      generateRandom                      ; If not, keep generating random numbers until we get one between A and E.
    
    mov     ebx,        eax                     ; Store the random number in ebx, as ReadHex will overwrite it.

    mov     al,         LF                      ; Move the linefeed into al to move the console to the next line.
    call    WriteChar                           ; Write the linefeed from al.

getGuess:                                       ; Jump here to get a new guess from the user.                       (9)
    mPrtStr guessStr                            ; Prints "Guess: "                                                  (10)

    call    ReadHex                             ; Stores guess in eax                                               (11)

    cmp     eax,        ebx                     ; Compare eax (Guess) to ebx (Random Number)                        (12)
    jb      tooLow                              ; If eax < ebx (Guess < Random #), goto "tooLow" label
    ja      tooHigh                             ; Else, if eax > ebx (Guess > Random #), goto "tooHigh" label
                                                ; Else, eax == ebx (Guess == Random #), so continue

    mPrtStr correctStr                          ; Prints "Guess a hex number in the range A - E
    jmp     askToRepeat                         ; Ask the user if they want to guess again with a new number.

tooLow:                                         ; Jump here if Guess < Random #
    mPrtStr tooLowStr                           ; Prints "Too Low!! (Guess higher)"
    jmp     getGuess                            ; Loop back up to get a new guess.

tooHigh:                                        ; Jump here if Guess > Random #
    mPrtStr tooHighStr                          ; Prints "Too High!! (Guess lower)"
    jmp     getGuess                            ; Loop back up to get a new guess.

askToRepeat:                                    ; Jump here when the guess matches the random #                     (13)
    mov     al,         LF                      ; Move the linefeed into al to move the console to the next line
    call    WriteChar                           ; Write the linefeed from al

    mPrtStr doAnotherStr                        ; Prints "Do another? ('y' or 'Y' to continue. Any other character to exit)".

    call    ReadChar                            ; Reads a character from keyboard and stores it in al.
    cmp     al,         'y'                     ; First, check to see if input was a lowercase 'y'
    je      outerLoop                           ; If so, loop (generate a new number and ask for a new guess)
    cmp     al,         'Y'                     ; If char wasn't a loewrcase 'y', check for the uppercase 'Y' 
    je      outerLoop                           ; Perform the same jump if so.
                                                ; Any other character breaks the outermost loop here.

    mPrtStr registerStr                         ; Prints "Contents of Registers: ".
    call	  DumpRegs				                    ; Displays contents of registers.

    mPrtStr exitStr                             ; Prints "Press any key to exit..".
	  call	  ReadChar				                    ; Pauses until key is pressed.
	  INVOKE	ExitProcess,0			                  ; Exits.

main ENDP

END main
;  *************************************************************