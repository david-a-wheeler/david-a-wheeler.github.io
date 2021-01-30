
********************************
* Start special compiler words 1
********************************

*
* Subroutine for adding words
*

ADDSUB JSR SETCEOS ; Set compiler output to end-of-system

 LDA COUTPUT ; Set up PNTR for ADDWORD call
 STA PNTR3
 LDA COUTPUT+1
 STA PNTR3+1

:LOOP LDA (WORDPNTR) ; Output word text
 CMP #$20
 BEQ :EOL
 CMP #$0D
 BEQ :EOL
 JSR OUTBYTE
 INC WORDPNTR
 BNE :LOOP
 INC WORDPNTR+1
 BRA :LOOP
:EOL LDA #$20 ; Append trailing space
 JSR OUTBYTE

 JMP ADDWORD ; Add word to dictionary
;   (CALCHASH has already been called)

*
* Subroutine for outputting word text
*

TEXTOUT LDY #$00 ; Output variable's name
:LOOP LDA (WORDPNTR),Y
 CMP #$0D
 BEQ :END
 CMP #$20
 BEQ :END
 JSR OUTBYTE
 INY
 BRA :LOOP

:END RTS

*
* Subroutine to resume execution after text string
*

RESUME LDY #$FF
:LOOP INY
 LDA (WORDPNTR),Y
 CMP #$20
 BNE :LOOP
 TYA
 CLC
 ADC WORDPNTR
 TAY
 LDX WORDPNTR+1
 BCC :NOINC
 INX
:NOINC PHX
 PHY
 RTS

*
* Word ":" - Define new word
*

WORD2 ASC ': '
 DW COLON

COLON BRK ; Special executable compiler word

 BIT COMPILE ; Make sure we're not already compiling
 BPL :NOTCOMP
 LDA #$08 ; "Cannot define colon definition
 JMP PRTERR ;  within another colon definition"

:NOTCOMP LDA #$FF ; Set compiling flag and
 STA COMPILE ;  "compile next word" flag
 STA CFLAG1
 RTS

* Word ":" - 2nd half (compiler subroutine)

COLON2 STZ CFLAG1 ; Clear out "Add word" flag
 JSR CHKNUM ; Make sure it isn't a number
 BCC :NOTNUM
 LDA #$09 ; "Cannot define number as new word"
 JMP PRTERR

:NOTNUM JSR CALCHASH ; Make sure it isn't in vocabulary already
 JSR CHKWORD
 BCC :ISNEW
 STZ COMPILE ; So GETSEINIT won't forget last word
 LDA #$0A ; "Word already defined"
 JMP PRTERR

:ISNEW JSR ADDSUB ; Add this word to vocabulary

 LDA COUTPUT ; Calculate pointer to address of routine
 CLC
 ADC #$02
 TAY
 LDA COUTPUT+1
 ADC #$00
 PHA
 TYA
 JSR OUTBYTE
 PLA
 JMP OUTBYTE

*
* Word ";" - End colon definition (compiler subroutine)
*

WORD3 ASC '; '
 DW SEMICLN

SEMICLN BRK ; Special executable compiler subroutine

 LDA COMPILE
 BNE :OK

 LDA #$0B ; "Semicolon without colon"
 JMP PRTERR

:OK LDA #$60 ; Add RTS to colon definition
 JSR OUTBYTE
 STZ COMPILE
 JMP SETEOSC ; Set end-of-system to compiler output

*
* Word "variable" - allocate space for a variable
*

WORD4 ASC 'variable '
 DW VARIABLE

VARIABLE BRK ; Special executable compiler subroutine

 JSR SKIP2SPC ; Skip past this word ("variable")
 JSR SKIPSPCS ; Skip to variable to define
 JSR CHKNUM ; Make sure it isn't a number
 BCC :NOTNUM
 LDA #$12 ; "Cannot define number as variable"
 JMP PRTERR

:NOTNUM LDA #$20 ; JSR VARSUB
 JSR OUTBYTE
 LDA #VARSUB
 JSR OUTBYTE
 LDA #/VARSUB
 JSR OUTBYTE

 JSR TEXTOUT ; Output variable's name

 TYA
 BEQ :ERROR
 LDA #$20
 JMP OUTBYTE

:ERROR LDA #$15 ; "No word following 'variable'"
 JMP PRTERR

*

VARSUB PLA
 STA WORDPNTR
 PLA
 STA WORDPNTR+1

 INC WORDPNTR
 BNE :SKIPINC
 INC WORDPNTR+1

:SKIPINC JSR CALCHASH ; Make sure it isn't in vocabulary already
 JSR CHKWORD
 BCC :ISNEW
 LDA #$0A ; "Word already defined"
 JMP PRTERR

:ISNEW JSR SETCEOS ; Set compiler output to end-of-system
 JSR ADDSUB ; Add this word to vocabulary

 LDA COUTPUT ; Calculate pointer to address of routine
 CLC
 ADC #$02
 TAY
 LDA COUTPUT+1
 ADC #$00
 PHA
 TYA
 JSR OUTBYTE
 PLA
 JSR OUTBYTE

 LDA COUTPUT ; Calculate variable location
 CLC
 ADC #$07
 STA PNTR
 LDA COUTPUT+1
 ADC #$00
 STA PNTR+1

 LDA #$A0 ; LDY #variable location
 JSR OUTBYTE
 LDA PNTR
 JSR OUTBYTE

 LDA #$A2 ; LDX #/variable location
 JSR OUTBYTE
 LDA PNTR+1
 JSR OUTBYTE

 LDA #$4C ; JMP PUSHDATA
 JSR OUTBYTE
 LDA #PUSHDATA
 JSR OUTBYTE
 LDA #/PUSHDATA
 JSR OUTBYTE

 LDA #$00 ; Reserve space for variable
 JSR OUTBYTE
 JSR OUTBYTE

 JSR SETEOSC ; Set end-of-system to compiler output

 JMP RESUME ; Resume execution after variable text

*
* Word "constant" - create a constant
*

WORD5 ASC 'constant '
 DW CONSTANT

CONSTANT BRK ; Special executable compiler subroutine

 JSR SKIP2SPC ; Skip past this word ("constant")
 JSR SKIPSPCS ; Skip to constant to define
 JSR CHKNUM ; Make sure it isn't a number
 BCC :NOTNUM
 LDA #$13 ; "Cannot define number as constant"
 JMP PRTERR

:NOTNUM LDA #$20 ; JSR CONSTSUB
 JSR OUTBYTE
 LDA #CONSTSUB
 JSR OUTBYTE
 LDA #/CONSTSUB
 JSR OUTBYTE

 JSR TEXTOUT ; Output constant's name

 TYA
 BEQ :ERROR
 LDA #$20
 JMP OUTBYTE

:ERROR LDA #$15 ; "No word following 'constant'"
 JMP PRTERR

*

CONSTSUB PLA
 STA WORDPNTR
 PLA
 STA WORDPNTR+1

 INC WORDPNTR
 BNE :SKIPINC
 INC WORDPNTR+1

:SKIPINC JSR CALCHASH ; Make sure it isn't in vocabulary already
 JSR CHKWORD
 BCC :ISNEW
 LDA #$0A ; "Word already defined"
 JMP PRTERR

:ISNEW JSR SETCEOS ; Set compiler output to end-of-system
 JSR ADDSUB ; Add this word to vocabulary

 LDA COUTPUT ; Calculate pointer to address of routine
 CLC
 ADC #$02
 TAY
 LDA COUTPUT+1
 ADC #$00
 PHA
 TYA
 JSR OUTBYTE
 PLA
 JSR OUTBYTE

 JSR POPDATA ; GET constant value
 STY PNTR
 STX PNTR+1

 LDA #$A0 ; LDY #constant value
 JSR OUTBYTE
 LDA PNTR
 JSR OUTBYTE

 LDA #$A2 ; LDX #/constant value
 JSR OUTBYTE
 LDA PNTR+1
 JSR OUTBYTE

 LDA #$4C ; JMP PUSHDATA
 JSR OUTBYTE
 LDA #PUSHDATA
 JSR OUTBYTE
 LDA #/PUSHDATA
 JSR OUTBYTE

 JSR SETEOSC ; Set end-of-system to compiler output

 JMP RESUME ; Resume execution after constant text

*
* Word "create" - create new word
*

WORD6 ASC 'create '
 DW CREATE

CREATE BRK ; Special executable compiler subroutine

 JSR SKIP2SPC ; Skip past this word ("create")
 JSR SKIPSPCS ; Skip to word to create
 JSR CHKNUM ; Make sure it isn't a number
 BCC :NOTNUM
 LDA #$14 ; "Cannot define number as array"
 JMP PRTERR

:NOTNUM LDA #$20 ; JSR CREATSUB
 JSR OUTBYTE
 LDA #CREATSUB
 JSR OUTBYTE
 LDA #/CREATSUB
 JSR OUTBYTE

 JSR TEXTOUT ; Output constant's name

 TYA
 BEQ :ERROR
 LDA #$20
 JMP OUTBYTE

:ERROR LDA #$15 ; "No word following 'create'"
 JMP PRTERR

*

CREATSUB PLA
 STA WORDPNTR
 PLA
 STA WORDPNTR+1

 INC WORDPNTR
 BNE :SKIPINC
 INC WORDPNTR+1

:SKIPINC JSR CALCHASH ; Make sure it isn't in vocabulary already
 JSR CHKWORD
 BCC :ISNEW
 LDA #$0A ; "Word already defined"
 JMP PRTERR

:ISNEW JSR SETCEOS ; Set compiler output to end-of-system
 JSR ADDSUB ; Add this word to vocabulary

 LDA COUTPUT ; Calculate pointer to address of routine
 CLC
 ADC #$02
 TAY
 LDA COUTPUT+1
 ADC #$00
 TAX
 TYA
 JSR OUTBYTE
 TXA
 JSR OUTBYTE

 LDA COUTPUT ; Calculate address of storage area
 CLC
 ADC #$07
 TAY
 LDA COUTPUT+1
 ADC #$00
 TAX

 LDA #$A0 ; LDY #storage area
 JSR OUTBYTE
 TYA
 JSR OUTBYTE

 LDA #$A2 ; LDX #/storage area
 JSR OUTBYTE
 TXA
 JSR OUTBYTE

 LDA #$4C ; JMP PUSHDATA
 JSR OUTBYTE
 LDA #PUSHDATA
 JSR OUTBYTE
 LDA #/PUSHDATA
 JSR OUTBYTE

 JSR SETEOSC ; Set end-of-system to compiler output

 JMP RESUME ; Resume execution after constant text

*
* Word "allot" - allot space for data
*

WORD7 ASC 'allot '
 DW ALLOT

ALLOT JSR POPDATA ; Figure out how many bytes to allot
 TYA
 CLC
 ADC EOSPNTR
 STA EOSPNTR
 TXA
 ADC EOSPNTR+1
 STA EOSPNTR+1
 RTS

*
* Word "," - Compile stack value into next two bytes
*

WORD8 ASC ', '
 DW COMMA

COMMA JSR SETCEOS ; Set compiler output to end-of-system
 JSR POPDATA
 TYA
 JSR OUTBYTE
 TXA
 JSR OUTBYTE
 JMP SETEOSC ; Set end-of-system to compiler output

*
* Word "c," - Compile stack value into next byte
*

WORD9 ASC 'c, '
 DW CCOMMA

CCOMMA JSR SETCEOS ; Set compiler output to end-of-system
 JSR POPDATA
 TYA
 JSR OUTBYTE
 JMP SETEOSC ; Set end-of-system to compiler output


*
* Word "forget" - undefine words
*

WORD10 ASC 'forget '
 DW FORGET

FORGET BRK ; Special executable compiler subroutine

 JSR SKIP2SPC ; Skip past this word ("forget")
 JSR SKIPSPCS ; Skip to word to forget
 JSR CHKNUM ; Make sure it isn't a number
 BCC :NOTNUM
 LDA #$16 ; "Cannot forget number 'xxx'"
 JMP PRTERR

:NOTNUM LDA #$20 ; JSR FRGTSUB
 JSR OUTBYTE
 LDA #FRGTSUB
 JSR OUTBYTE
 LDA #/FRGTSUB
 JSR OUTBYTE

 JSR TEXTOUT ; Output word's name

 TYA
 BEQ :ERROR
 LDA #$20
 JMP OUTBYTE

:ERROR LDA #$15 ; "No word following 'forget'"
 JMP PRTERR

*

FRGTSUB PLA
 STA WORDPNTR
 PLA
 STA WORDPNTR+1

 INC WORDPNTR
 BNE :SKIPINC
 INC WORDPNTR+1

:SKIPINC JSR CALCHASH ; Calculate hash of word
 JSR CHKWORD ; Make sure it's in dictionary
 BCS :LOOP

 LDA #$07 ; "Word 'xxx' not found"
 JMP PRTERR

:LOOP JSR FRGTLAST ; Forget last word

 LDY #$02 ; Until we forget the one we want
 LDA (LISTPNTR),Y
 CMP PNTR2
 BNE :LOOP
 INY
 LDA (LISTPNTR),Y
 CMP PNTR2+1
 BNE :LOOP

 LDA PNTR2 ; Reset compiler end-of-system
 STA EOSPNTR ;   and reclaim space
 LDA PNTR2+1
 STA EOSPNTR+1


 JMP RESUME ; Resume execution after constant text

********************************
* End special compiler words 1
********************************
