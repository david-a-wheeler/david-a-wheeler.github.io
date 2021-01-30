 LST OFF

*
* QForth 2.0
*
* by Toshiyasu Morita
*
*   Started: January 7, 1988 @ 8:07 am (v1.0)
* Rewritten:   April 7, 1988 @ 5:22 am (v2.0)
*
*
* Version 2.1 by Ronald T. Kneusel
* June 1996
*
* Version 2.2 (bug fix), 13-Oct-96, RTK
*
* Version 2.2.1 (minimal version), 26-Dec-97, RTK
* Version 2.3 (2+ bug), 11-Mar-00, RTK
*        Version 2.4      (+loop bug), 22-Jan-04, RTK
*

VERSION EQU $02

 ORG $2100 ; N.B. new program origin

 XC ; 65C02 opcodes enabled

*
* Zero page usage
*

PNTR EQU $00
PNTR2 EQU $02
PNTR3 EQU $04
PNTR4 EQU $06
TEMP EQU $08
TEMP2 EQU $0A
TEMP3 EQU $0C

WORDPNTR EQU $E0 ; Pointer to word currently executing
LISTPNTR EQU $E2 ; Pointer to free area of linked list
HASH EQU $E4 ; Hash value of word currently executing

EOSPNTR EQU $E6 ; Pointer to end of system
COUTPUT EQU $E8 ; Compiler output pointer

CMPSTACK EQU $EA ; Compiler stack pointer
CM2STACK EQU $EB ; Compiler stack 2 pointer
RETSTACK EQU $EC ; Return stack pointer
DATSTACK EQU $EE ; Data stack pointer

CMPITEMS EQU $F0 ; Number of items on compiler stack
CM2ITEMS EQU $F1 ; Number of items on compiler stack 2
RETITEMS EQU $F2 ; Number of items on return stack
DATITEMS EQU $F4 ; Number of items on data stack

CPNTR EQU $F6 ; Pointer to string to print (MSGOUT)

FILEPNTR EQU $F8 ; Pointer to input file input data

*
* New memory usage
*
* $0200-$02FF: Text input buffer
*
* $0800-$0AFF: QForth runtime scratchpad (PAD)
*
* $0B00-$0BFF: Compiler immediate object code area
*
* $0C00-$0CFF: Runtime data stack
* $0D00-$0DFF: Runtime return stack
* $0E00-$0EFF: Compiler stack 1
* $0F00-$0FFF: Compiler stack 2
* $1000-$10FF: Hash table array
* $1100-$20FF: Word pointer area
* $2100-$????: QForth system area
* $??+1-.....: Dictionary

*
* Program equates
*

INPUT EQU $200

PADAREA EQU $800

CSCRATCH EQU $B00

HASHTBLL EQU $1000 ; Hashed array of linked lists
HASHTBLH EQU $1080

DATAAREA EQU $0C00 ; Data stack pointer base area
RETNAREA EQU $0D00 ; Return stack pointer base area
COMPAREA EQU $0E00 ; Compiler stack pointer base area
CMP2AREA EQU $0F00 ; Compiler stack 2 pointer base area

LINKLIST EQU $1100 ; Linked list pointer initial value

MLI EQU $BF00
BITMAP EQU $BF58
MACHID EQU $BF98
IBAKVER EQU $BFFC
IVERSION EQU $BFFD

*
* Hardware equates
*

*KYBD EQU $C000
*STROBE EQU $C010

*
* ROM equates
*

ROMGETKY EQU $FD0C
CROUT1 EQU $FD8B
ROMCOUT EQU $FDED

*
* Start of code
*

 JMP MAIN
 JMP POPDATA
 JMP PUSHDATA

********************************
* Start interface to ROMs
********************************

*
* Character output
*

COUT PHA
 PHX
 PHY
 ORA #$80
 JSR ROMCOUT
 PLY
 PLX
 PLA
 RTS

*
* Get character
*

GETKEY PHX
 PHY
 JSR ROMGETKY
 AND #$7F
 PLY
 PLX
 RTS

********************************
* End interface to ROMs
********************************

********************************
* Start global subroutines
********************************

*
* Output string terminated by null
*

MSGOUT PLA
 STA CPNTR
 PLA
 STA CPNTR+1
:LOOP INC CPNTR
 BNE :SKIPINC
 INC CPNTR+1
:SKIPINC LDA (CPNTR)
 BEQ :END
 JSR COUT
 BRA :LOOP
:END LDA CPNTR+1
 PHA
 LDA CPNTR
 PHA
 RTS

********************************
* End global subroutines
********************************

********************************
* Start stacks manipulation subroutines
********************************

*
* Initialize stacks
*

INITSTACKS
 LDA #$FF ; Initialize data stack
 STA DATSTACK ; Initialize data stack
 STZ DATITEMS

 STA RETSTACK ; Initalize runtime return stack
 STZ RETITEMS

 STA CMPSTACK ; Initialize compiler stacks
 STA CM2STACK
 STZ CMPITEMS
 STZ CM2ITEMS
 RTS

*
* Push number onto compiler stack
*

PUSHCOMP TXA
 LDX CMPSTACK
 STA COMPAREA,X
 DEX
 TYA
 STA COMPAREA,X
 DEX
 STX CMPSTACK
 INC CMPITEMS
 BEQ :ERROR
 RTS

:ERROR LDA #01
 JMP PRTERR

*
* Pop number from compiler stack
*

POPCOMP LDA CMPITEMS
 BEQ :ERROR
 DEC CMPITEMS
 LDX CMPSTACK
 INX
 LDA COMPAREA,X
 TAY
 INX
 STX CMPSTACK
 LDA COMPAREA,X
 TAX
 RTS

:ERROR LDA #02
 JMP PRTERR

*
* Push number onto compiler stack 2
*

PUSHCMP2 TXA
 LDX CM2STACK
 STA CMP2AREA,X
 DEX
 TYA
 STA CMP2AREA,X
 DEX
 STX CM2STACK
 INC CM2ITEMS
 BEQ :ERROR
 RTS

:ERROR LDA #01
 JMP PRTERR

*
* Pop number from compiler stack 2
*

POPCMP2 LDA CM2ITEMS
 BEQ :ERROR
 DEC CM2ITEMS
 LDX CM2STACK
 INX
 LDA CMP2AREA,X
 TAY
 INX
 STX CM2STACK
 LDA CMP2AREA,X
 TAX
 RTS

:ERROR LDA #02
 JMP PRTERR

*
* Push number onto data stack
*

PUSHDATA TXA
 LDX DATSTACK
 STA DATAAREA,X
 DEX
 TYA
 STA DATAAREA,X
 DEX
 STX DATSTACK
 INC DATITEMS
 BEQ :ERROR
 RTS

:ERROR LDA #03
 JMP PRTERR

*
* Pop number from data stack
*

POPDATA LDA DATITEMS
 BEQ :ERROR
 DEC DATITEMS
 LDX DATSTACK
 INX
 LDA DATAAREA,X
 TAY
 INX
 STX DATSTACK
 LDA DATAAREA,X
 TAX
 RTS

:ERROR LDA #04
 JMP PRTERR

*
* Push number onto return stack
*

PUSHRETN TXA
 LDX RETSTACK
 STA RETNAREA,X
 DEX
 TYA
 STA RETNAREA,X
 DEX
 STX RETSTACK
 INC RETITEMS
 BEQ :ERROR
 RTS

:ERROR LDA #05
 JMP PRTERR

*
* Pop number from return stack
*

POPRETN LDA RETITEMS
 BEQ :ERROR
 DEC RETITEMS
 LDX RETSTACK
 INX
 LDA RETNAREA,X
 TAY
 INX
 STX RETSTACK
 LDA RETNAREA,X
 TAX
 RTS

:ERROR LDA #06
 JMP PRTERR

********************************
* End stack manipulation subroutines
********************************

********************************
* Start compiler output management subroutines
********************************

*
* Set compiler output to scratchpad immediate object area
*

SETSCR LDA #CSCRATCH
 STA COUTPUT
 LDA #/CSCRATCH
 STA COUTPUT+1
 RTS

*
* Set compiler output to end-of-system
*

SETCEOS LDA EOSPNTR
 STA COUTPUT
 LDA EOSPNTR+1
 STA COUTPUT+1
 RTS

*
* Set end of system to compiler otuput
*

SETEOSC LDA COUTPUT
 STA EOSPNTR
 LDA COUTPUT+1
 STA EOSPNTR+1
 RTS

*
* Output compiler data
*

OUTBYTE STA (COUTPUT)
 INC COUTPUT
 BNE :SKIPINC
 INC COUTPUT+1
:SKIPINC RTS

********************************
* End compiler output management subroutines
********************************

********************************
* Start vocabulary maintenance subroutines
********************************

*
* Linked list node consists of four bytes:
*
* (Word pointer to next node, null if tail node) +
* (word pointer to text)
*

*
* Clear vocabulary
*

CLRVOCAB LDX #$7F
:LOOP STZ HASHTBLL,X
 STZ HASHTBLH,X
 DEX
 BPL :LOOP

 LDA #LINKLIST
 STA LISTPNTR
 LDA #/LINKLIST
 STA LISTPNTR+1

 RTS

*
* Calculate hash value of word at (WORDPNTR)
*

CALCHASH LDA WORDPNTR
 STA PNTR
 LDA WORDPNTR+1
 STA PNTR+1

CALCHSH2 STZ HASH
 LDY #$00
 LDA (PNTR),Y
:LOOP EOR HASH
 STA HASH
 INY
 LDA (PNTR),Y
 CMP #' '
 BEQ :FINIS
 CMP #$0D
 BNE :LOOP

:FINIS LDA HASH
 AND #$7F
 STA HASH
 RTS

*
* See if word at (WORDPNTR) already exists
*
* Note: CALCHASH must be called before CHKWORD
*

CHKWORD LDY HASH
 LDA HASHTBLL,Y ; See if first link exists
 ORA HASHTBLH,Y
 BNE :CHECK

 CLC ; First link doesn't exist
 RTS ;   so word isn't in vocabulary

:CHECK LDA HASHTBLL,Y ; Fetch pointer to linked list
 STA PNTR
 LDA HASHTBLH,Y
 STA PNTR+1

 LDY #$01

:OUTER INY ; Fetch pointer to text
 LDA (PNTR),Y
 STA PNTR2
 INY
 LDA (PNTR),Y
 STA PNTR2+1

 LDY #$FF ; See if texts are identical
:INNER INY
 LDA (PNTR2),Y
 CMP #' '
 BEQ :END?
 CMP (WORDPNTR),Y
 BEQ :INNER

 BRA :NEXT

:END? LDA (WORDPNTR),Y
 CMP #' '
 BEQ :FOUND
 CMP #$0D
 BEQ :FOUND

:NEXT LDA (PNTR) ; See if pointer to next node exists
 TAX
 LDY #$01
 LDA (PNTR),Y
 STX PNTR
 STA PNTR+1
 ORA PNTR
 BNE :OUTER

 CLC ; Word not in vocabulary
 RTS

:FOUND INY ; Found, so leave address of routine in
 LDA (PNTR2),Y ;    PNTR and set carry
 STA PNTR
 INY
 LDA (PNTR2),Y
 STA PNTR+1

 RTS

*
* Add word to vocabulary
*
* Note: CALCHASH must be called before ADDWORD
*

ADDWORD LDY HASH ; See if there is initial pointer
 LDA HASHTBLL,Y
 ORA HASHTBLH,Y
 BNE :TRAVERS

 LDA LISTPNTR ; Create initial pointer
 STA HASHTBLL,Y
 LDA LISTPNTR+1
 STA HASHTBLH,Y
 LDY #$01
 BRA :CREATE

:TRAVERS LDA HASHTBLL,Y ; Must traverse linked list to find
 STA PNTR ;   tail node to tack new node onto
 LDA HASHTBLH,Y
 STA PNTR+1

 LDY #$01

:LOOP LDA (PNTR)
 TAX
 ORA (PNTR),Y
 BEQ :TAILFND

 LDA (PNTR),Y
 STA PNTR+1
 STX PNTR
 BRA :LOOP

:TAILFND LDA LISTPNTR
 STA (PNTR)
 LDA LISTPNTR+1
 STA (PNTR),Y

:CREATE LDA #$00 ; Pointer to next node = null
 STA (LISTPNTR)
 STA (LISTPNTR),Y
 LDA PNTR3
 INY
 STA (LISTPNTR),Y
 LDA PNTR3+1
 INY
 STA (LISTPNTR),Y

 LDA LISTPNTR ; Move list pointer to next free space
 CLC
 ADC #$04
 STA LISTPNTR
 BCC :SKIPINC
 INC LISTPNTR+1

:SKIPINC RTS

*
* Forget last defined word
*

FRGTLAST LDA LISTPNTR ; Throw away last node
 SEC
 SBC #$04
 STA LISTPNTR
 BCS :SKIPDEC
 DEC LISTPNTR+1

:SKIPDEC LDY #$02 ; Set up pointer to word text
 LDA (LISTPNTR),Y
 STA PNTR
 INY
 LDA (LISTPNTR),Y
 STA PNTR+1

 JSR CALCHSH2 ; Calculate hash value

 LDX HASH ; Is it initial pointer?
 LDA HASHTBLL,X
 STA PNTR
 TAY
 LDA HASHTBLH,X
 STA PNTR+1
 CMP LISTPNTR+1
 BNE :TRAVERS
 CPY LISTPNTR
 BNE :TRAVERS

 STZ HASHTBLL,X ; Easy to kill initial pointer
 STZ HASHTBLH,X
 RTS

:TRAVERS LDY #$01 ; Check against next node
:LOOP LDA (PNTR)
 TAX
 LDA (PNTR),Y
 CMP LISTPNTR+1
 BNE :GONEXT
 CPX LISTPNTR
 BNE :GONEXT

 LDA #$00 ; Kill this link
 STA (PNTR)
 STA (PNTR),Y
 RTS

:GONEXT STX PNTR ; Go to next node
 STA PNTR+1
 BRA :LOOP

*
* List all words
*

LISTWRDS LDA #$8D ; Skip a line for neatness
 JSR COUT

 LDA #LINKLIST ; Start at beginning of list
 STA PNTR
 LDA #/LINKLIST
 STA PNTR+1

 LDA #$05 ; Five words per line (4 to 0)
 STA TEMP

:OUTER LDY #$02 ; Fetch pointer to word name
 LDA (PNTR),Y
 STA PNTR2
 INY
 LDA (PNTR),Y
 STA PNTR2+1

 LDX #16 ; Print word name
 LDY #$00
:INNER LDA (PNTR2),Y
 CMP #$20
 BEQ :ENDTEXT
 CMP #$0D
 BEQ :ENDTEXT
 JSR COUT
 INY
 DEX
 BRA :INNER

:ENDTEXT TXA ; Justify it to 16 characters
 BMI :NEXTWRD
 BEQ :NEXTWRD
:TINY LDA #' '
 JSR COUT
 DEX
 BNE :TINY

:NEXTWRD LDA PNTR ; Move PNTR to next node
 CLC
 ADC #$04
 STA PNTR
 BCC :SKIPINC
 INC PNTR+1

:SKIPINC DEC TEMP
 BNE :NORESET

* LDA KYBD ; Check for ctrl-S
* BIT STROBE
* CMP #$93
* BNE :NOTPAUS
*:PAUSE LDA KYBD
* BPL :PAUSE
* BIT STROBE

:NOTPAUS LDA #$05
 STA TEMP

:NORESET LDA PNTR ; See if we're at end of list yet
 CMP LISTPNTR
 BNE :OUTER
 LDA PNTR+1
 CMP LISTPNTR+1
 BNE :OUTER

 LDA TEMP ; If we're at end of line, no <CR>
 CMP #$05 ;   otherwise one <CR>s
 BEQ :NOCR
 LDA #$8D
 JMP COUT
:NOCR RTS

*
* Load default system words
*

LOADWRDS JSR CLRVOCAB

 LDA #SYSWORDS
 STA PNTR4
 LDA #/SYSWORDS
 STA PNTR4+1

:LOOP LDA (PNTR4)
 STA WORDPNTR
 STA PNTR3
 LDY #$01
 LDA (PNTR4),Y
 STA WORDPNTR+1
 STA PNTR3+1
 ORA WORDPNTR
 BEQ :FINIS

 JSR CALCHASH
 JSR ADDWORD

 LDA PNTR4
 CLC
 ADC #$02
 STA PNTR4
 BCC :LOOP
 INC PNTR4+1
 BRA :LOOP

:FINIS RTS

SYSWORDS DW WORD2
 DW WORD3
 DW WORD4
 DW WORD5
 DW WORD6
 DW WORD7
 DW WORD8
 DW WORD9
 DW WORD10
 DW WORD11
 DW WORD12
 DW WORD13
 DW WORD14
 DW WORD15
 DW WORD16
 DW WORD17
 DW WORD18
 DW WORD19
 DW WORD20
 DW WORD21
 DW WORD22
 DW WORD23
 DW WORD24
 DW WORD25
 DW WORD26
 DW WORD27
 DW WORD28
 DW WORD29
 DW WORD30
 DW WORD31
 DW WORD32
 DW WORD33
 DW WORD34
 DW WORD35
 DW WORD36
 DW WORD37
 DW WORD38
 DW WORD39
 DW WORD40
 DW WORD41
 DW WORD42
 DW WORD43
 DW WORD44
 DW WORD45
 DW WORD46
 DW WORD47
 DW WORD48
 DW WORD49
 DW WORD50
 DW WORD51
 DW WORD52
 DW WORD53
 DW WORD54
 DW WORD55
 DW WORD56
 DW WORD57
 DW WORD58
 DW WORD59
 DW WORD60
 DW WORD61
 DW WORD62
 DW WORD63
 DW WORD64
 DW WORD65
 DW WORD66
 DW WORD67
 DW WORD68
 DW WORD69
 DW WORD70
 DW WORD71
 DW WORD72
 DW WORD73
 DW WORD74
 DW WORD75
 DW WORD76
 DW WORD77
 DW WORD78
 DW WORD79
 DW WORD80
 DW WORD81
 DW WORD82
 DW WORD83
 DW WORD87
 DW WORD89
 DW WORD90
 DW WORD91
 DW WORD92
 DW WORD93
 DW WORD94
 DW WORD95
 DW WORD96
 DW WORD98
 DW WORD107
 DW WORD108
 DW WORD109
 DW WORD110
 DW WORD111
 DW WORD116
 DW WORD117
 DW WORD119
 DW WORD120
 DW WORD127

 HEX 0000 ; End of SYSWORDS marker

********************************
* End vocabulary maintenance subroutines
********************************

********************************
* Start command interpreter
********************************

*
* Get a string of input
*

GETLN JSR DPTH ; # stack items
 JSR DOT ; print it
 LDA #08
 JSR COUT
 LDA #">"
 JSR COUT

 LDY #$00
:LOOP JSR GETKEY
 CMP #$7F ; Delete key
 BEQ :DELETE
 CMP #''
 BNE :NOTBKSP
:DELETE TYA ; If no characters then don't do anything
 BEQ :LOOP
 DEY
 LDA #$88
 JSR COUT
 BRA :LOOP

:NOTBKSP CMP #''
 BNE :NOTCTLX
:LOOP2 TYA
 BEQ :LOOP
 DEY
 LDA #$88
 JSR COUT
 BRA :LOOP2

:NOTCTLX CMP #$0D ; Return
 BNE :NOTRTN
 STA INPUT,Y
 JSR COUT
 RTS

:NOTRTN CMP #$20
 BCC :LOOP
 STA INPUT,Y
 INY
 JSR COUT
 BRA :LOOP

*
* Skip spaces
*

SKIPSPCS LDA (WORDPNTR)
 BEQ :EXIT
 CMP #$20
 BNE :EXIT
 INC WORDPNTR
 BNE SKIPSPCS
 INC WORDPNTR+1
 BRA SKIPSPCS
:EXIT RTS

*
* Skip to a space
*

SKIP2SPC LDA (WORDPNTR)
 BEQ :EXIT
 CMP #$0D
 BEQ :EXIT
 CMP #$20
 BEQ :EXIT
 INC WORDPNTR
 BNE SKIP2SPC
 INC WORDPNTR+1
 BRA SKIP2SPC
:EXIT RTS

*
* Check to see if string is a number
*

CHKNUM LDY #00
 LDA (WORDPNTR) ; First character can be '-'
 CMP #'-'
 BNE :ENTRY
 INY
 LDA (WORDPNTR),Y ; If first character is '-' then
 BRA :ENTRY ;     second character must be number

:LOOP LDA (WORDPNTR),Y
 CMP #' '
 BEQ :YES
 CMP #$0D ; Carriage return
 BEQ :YES
:ENTRY CMP #'0'
 BCC :RTS ; Carry already clear
 CMP #'9'+1
 BCS :NO
 INY
 BRA :LOOP

:NO CLC ; String is not a number
:RTS RTS

:YES SEC ; String is a number
 RTS

*
* Decode a number
*

DECODNUM LDA (WORDPNTR) ; Set negative flag if appropriate
 CMP #'-'
 BNE :POSITIV
 LDA #$FF
 STA TEMP
 LDY #00
 BRA :MERGE

:POSITIV STZ TEMP
 LDY #$FF

:MERGE STZ PNTR ; Clear out current value of number
 STZ PNTR+1

:LOOP INY
 LDA (WORDPNTR),Y
 CMP #' '
 BEQ :FINIS
 CMP #$0D
 BEQ :FINIS

 TAX
 ASL PNTR ; PNTR = PNTR * 10
 ROL PNTR+1 ;   (PNTR = (PNTR * 2) + (PNTR * 8))
 LDA PNTR+1
 STA PNTR2+1
 LDA PNTR
 STA PNTR2
 ASL
 ROL PNTR+1
 ASL
 ROL PNTR+1
 CLC
 ADC PNTR2
 STA PNTR
 LDA PNTR+1
 ADC PNTR2+1
 STA PNTR+1
 TXA

 SEC
 SBC #'0'
 CLC
 ADC PNTR
 STA PNTR
 BCC :LOOP
 INC PNTR+1
 BRA :LOOP

:FINIS BIT TEMP ; Check if negative flag set
 BPL :NOTNEG

 LDA PNTR ; Return twos complement
 EOR #$FF
 CLC
 ADC #01
 STA PNTR
 LDA PNTR+1
 EOR #$FF
 ADC #00
 STA PNTR+1

:NOTNEG RTS

*
* Compile a number
*

COMPNUM LDA #$A0 ; LDY #immediate
 JSR OUTBYTE
 LDA PNTR
 JSR OUTBYTE
 LDA #$A2 ; LDX #immediate
 JSR OUTBYTE
 LDA PNTR+1
 JSR OUTBYTE
 LDA #$20 ; JSR absolute (PUSHDATA)
 JSR OUTBYTE
 LDA #PUSHDATA
 JSR OUTBYTE
 LDA #/PUSHDATA
 JMP OUTBYTE

*
* Main command loop
*

CFLAG1 HEX 00 ; Compile next word flag
COMPILE HEX 00 ; Inside colon definition flag

FILE HEX 00 ; File flag.  Left in but unused

CMDINIT ; Entry point
 LDX #$FF
 TXS

 JSR INITSTACKS ; Initialize stacks

 JSR SETSCR ; Set compiler output to scratch area

:NOCLOSE LDA COMPILE ; If we were in the middle of a new word
 BPL CMDLOOP
 STZ COMPILE

 JSR FRGTLAST ;   erase the word


CMDLOOP JSR GETLN ; Get a line of input

INTERP LDA #$60
 STA CSCRATCH

 STZ WORDPNTR ; Set scan pointer to beginning of string
 LDA #$02
 STA WORDPNTR+1
:LOOP JSR SKIPSPCS ; Skip spaces to word
 LDA (WORDPNTR)
 CMP #$0D
 BEQ :FINIS

 BIT CFLAG1 ; See if we need to compile this
 BPL :NOCOMP
 JSR COLON2 ; Define new word
 JSR SKIP2SPC
 BRA :LOOP

:NOCOMP JSR CHKNUM ; See if it's a number
 BCC :NOTNUM

 JSR DECODNUM ; Decode number
 JSR COMPNUM ; Compile number
 JSR SKIP2SPC ; Skip past number to space
 BRA :LOOP

:NOTNUM JSR CALCHASH ; Calculate hash of word
 JSR CHKWORD ; See if word is in vocabulary
 BCC :ERROR

 LDA (PNTR) ; If first byte is not a BRK ($00) then it's
 BNE :NOTSPCL ;   a normal executable word (not special)

 INC PNTR ; Execute special compiler word
 BNE :SKIPINC ;   (skip over BRK instruction first)
 INC PNTR+1
:SKIPINC JSR :JMPTOIT
 JSR SKIP2SPC ; Skip past word to space
 BRA :LOOP

:JMPTOIT JMP (PNTR)

:NOTSPCL LDA #$20 ; Compile this word into a JSR
 JSR OUTBYTE
 LDA PNTR
 JSR OUTBYTE
 LDA PNTR+1
 JSR OUTBYTE
 JSR SKIP2SPC ; Skip past word to space
 BRA :LOOP

:FINIS BIT COMPILE ; If we're compiling then don't execute
 BMI :NOEXEC ;   scratchpad code
 LDA #$60 ; RTS instruction
 JSR OUTBYTE
 JSR CSCRATCH
 JSR SETSCR
:NOEXEC BIT FILE ; If we're not doing a file
 BPL CMDLOOP ;   get more input
 RTS ; Otherwise return for more data

:ERROR LDA #$07 ; "Unknown word"
 JMP PRTERR

********************************
* End command interpreter
********************************

********************************
* Start error handler
********************************

*
* Print out error text
*

PRTERR PHA
 JSR MSGOUT
 HEX 8D87
 ASC "Error - ",00

 LDA #ERRTXT-1
 STA PNTR
 LDA #/ERRTXT-1
 STA PNTR+1
 PLX

:LOOP INC PNTR
 BNE :SKIPINC
 INC PNTR+1
:SKIPINC LDA (PNTR)
 BMI :LOOP
 DEX
 BNE :LOOP

 LDY #$01
:LOOP2 LDA (PNTR),Y
 BPL :ENDLINE
 CMP #$80
 BNE :NORMAL

 PHY
 LDA #$A2 ; Double quote
 JSR COUT
 LDY #$00
:LOOP3 LDA (WORDPNTR),Y
 CMP #$20
 BEQ :ENDWRD
 CMP #$0D
 BEQ :ENDWRD
 JSR COUT
 INY
 BRA :LOOP3
:ENDWRD LDA #$A2 ; Double quote
 JSR COUT
 PLY
 INY
 BRA :LOOP2

:NORMAL JSR COUT
 INY
 BRA :LOOP2
:ENDLINE JSR COUT
 LDA #$8D
 JSR COUT
 JMP CMDINIT

ERRTXT HEX 00

 DCI "Compiler stack overflow" ; $01

 DCI "Compiler stack underflow" ; $02

 DCI "Data stack overflow" ; $03

 DCI "Data stack underflow" ; $04

 DCI "Return stack overflow" ; $05

 DCI "Return stack underflow" ; $06

 ASC "Word " ; $07
 HEX 80
 DCI " not defined"

 ASC "Can't define colon definition " ; $08
 DCI "within another colon definition"

 ASC "Can't define number ",80 ; $09
 DCI " as new word"

 DCI "Word already defined" ; $0A

 DCI "Semicolon without colon" ; $0B

 DCI "No ending quote found for expression" ; $0C

 DCI "No matching right parentheses for comment" ; $0D

 DCI "Division by zero" ; $0E

 HEX 80 ; $0F
 ASC " without ",A2
 ASC "do",22

 HEX 80 ; $10
 ASC " without ",A2
 ASC "begin",22

 ASC "Can't define variable inside " ; $11
 DCI "colon definition"

 DCI "Can't define number as variable" ; $12

 DCI "Can't define number as constant" ; $13

 DCI "Can't define number as storage" ; $14

 ASC "No word following ",8020 ; $15

 ASC "Can't forget number ",8020 ; $16

 DCI "No filename after 'read'" ; $17

 DCI "Can't read a non-text file" ; $18

 ASC "Quote without matching .",22 ; $19

 ASC "Right parentheses without matching " ; $1A
 DCI "left parentheses"

********************************
* End error handler
********************************

********************************
* Start QForth initialization subroutines
********************************

*
* Initialize pointers
*

INITPNTR
 LDA #PROGEND ; Initalize end-of-system pointer
 STA EOSPNTR
 LDA #/PROGEND
 STA EOSPNTR+1

 RTS ; Compiler stacks are initialized by
;   CMDLOOP so don't do it

*
* Initalize QForth
*

QINIT JSR INITPNTR
 JSR LOADWRDS
 RTS

********************************
* End QForth initalization subroutines
********************************




********************************

MAIN CLD
 LDX #$FF ; Reset stack
 TXS

* LDA #:RESET ; Set up reset vector
* STA RESET
* LDA #/:RESET
* STA RESET+1
* EOR #$A5
* STA POWERUP

* LDX #$00 ; Clear out bitmap of pages used
*:LOOP STZ BITMAP,X
* DEX
* BPL :LOOP

 STZ IBAKVER ; Version number $00 of ProDOS is ok
 LDA #VERSION ; Version of this interpreter
 STA IVERSION

 JSR QINIT ; Initialize Qforth data

*:RESET LDA $C036 ; Kick GS into fast mode
* ORA #$80
* STA $C036
* JSR $FE89
* JSR $FE93

* LDA MACHID ; Check for 80 col card
* AND #%00000010
* BEQ :NO80COL

*:RESET LDA #$A0 ; $C300 outputs accumulator
* JSR $C300

:RESET JSR MSGOUT
 HEX 8D
 ASC "QForth 2.0, Toshiyasu Morita, 1988",8D
 ASC "Version 2.4, Ronald T. Kneusel, 2004",8D
 ASC "Freeware",8D8D00
 JMP CMDINIT

********************************************************
* OS interface removed in this version.  RTK, 24-Dec-97
********************************************************

********************************
* Start library for words
********************************

*
* Print word in decimal
*

PRTDEC STX TEMP
 STZ TEMP3 ; Zero flag

 LDX #$04
:OUTER STZ TEMP2 ; Current place value counter
:INNER INC TEMP2
 TYA
 SEC
 SBC DECPWRL,X
 TAY
 LDA TEMP
 SBC DECPWRH,X
 STA TEMP
 BCS :INNER
 TYA
 ADC DECPWRL,X
 TAY
 LDA TEMP
 ADC DECPWRH,X
 STA TEMP

 DEC TEMP2
 BNE :PRT
 BIT TEMP3
 BPL :SKIPPRT
:PRT LDA TEMP2
 CLC
 ADC #$B0
 JSR COUT
 SEC
 ROR TEMP3
:SKIPPRT DEX
 BPL :OUTER
 BIT TEMP3
 BPL :ZERO
:SPC LDA #" " ; Print a space at end
 JMP COUT

:ZERO LDA #"0"
 JSR COUT
 BRA :SPC

DECPWRL DFB #1,#10,#100,#1000,#10000

DECPWRH DFB #/1,#/10,#/100,#/1000,#/10000

********************************
* End library for words
********************************

********************************
* Start special compiler words
********************************

 PUT QF.SPCLWRDS1
 PUT QF.SPCLWRDS2

********************************
* End special compiler words
********************************

********************************
* Start regular words
********************************

 PUT QF.REGWRDS1
 PUT QF.REGWRDS2

********************************
* End regular words
********************************

********************************
* Start RTK's additions
********************************

 PUT QF.NEWWRDS

********************************
* End RTK's additions
********************************

PROGEND

 SAV MINI.QFORTH
