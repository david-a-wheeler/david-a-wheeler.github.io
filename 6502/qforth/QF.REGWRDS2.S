
********************************
* Start regular words 2
********************************

*
* Word "abs" - return absolute value of top stack item
*

WORD63 ASC 'abs '
 DW ABS

ABS JSR POPDATA
 TXA
 BPL GLOB_PUSH

NEGATSUB TYA
 EOR #$FF
 CLC
 ADC #01
 TAY
 TXA
 EOR #$FF
 ADC #00
 TAX

GLOB_PUSH JMP PUSHDATA

*
* Word "negate" - negate top value on stack
*

WORD64 ASC 'negate '
 DW NEGATE

NEGATE JSR POPDATA
 BRA NEGATSUB

*
* Word "<" - comparison operator
*

WORD65 ASC '< '
 DW LESSTHAN

LESSTHAN JSR POPDATA ; Fetch first signed integer
 STY PNTR
 STX PNTR+1

 JSR POPDATA ; Fetch second signed integer

 TXA ; Actual comparison done here
 EOR PNTR+1
 AND #$80
 BEQ :SAMESGN

 TXA
 BMI :TRUE
 BRA :FALSE

:SAMESGN CPX PNTR+1
 BNE :NOCHKLO
 CPY PNTR
:NOCHKLO BCC :TRUE

:FALSE LDY #$00
 LDX #$00
 JMP PUSHDATA

:TRUE LDY #$FF
 LDX #$FF
 JMP PUSHDATA

*
* Word ">" - comparison operator
*

WORD66 ASC '> '
 DW MORETHAN

MORETHAN JSR POPDATA ; Fetch first signed integer
 STY PNTR
 STX PNTR+1

 JSR POPDATA ; Fetch second signed integer

 TXA ; Actual comparison done here
 EOR PNTR+1
 AND #$80
 BEQ :SAME

 TXA
 BPL :TRUE
 BRA :FALSE

:SAME CPX PNTR+1
 BNE :NOCHKLO
 CPY PNTR
:NOCHKLO BCC :FALSE
 BEQ :FALSE

:TRUE LDY #$FF
 LDX #$FF
 JMP PUSHDATA

:FALSE LDY #$00
 LDX #$00
 JMP PUSHDATA

*
* Word "=" - comparison operator
*
* Note: bypasses POPDATA, PUSHDATA for speed
*

WORD67 ASC '= '
 DW EQUAL

EQUAL LDA DATITEMS ; Make sure there's at least
 CMP #02 ;   two items on stack
 BCC :ERROR

 LDY DATSTACK
 LDA DATAAREA+1,Y
 CMP DATAAREA+3,Y
 BNE :FALSE
 LDA DATAAREA+2,Y
 CMP DATAAREA+4,Y
 BNE :FALSE

 LDA #$FF
 HEX 2C
:FALSE LDA #00
 STA DATAAREA+3,Y
 STA DATAAREA+4,Y

 INY ; Adjust data stack pointer
 INY
 STY DATSTACK

:SKIPINC DEC DATITEMS ; Adjust data items pointer
 RTS

:ERROR LDA #04 ; "Data stack underflow"
 JMP PRTERR

*
* Word "<>" - comparison operator
*
* Note: bypasses POPDATA, PUSHDATA for speed
*

WORD68 ASC '<> '
 DW NOTEQUAL

NOTEQUAL LDA DATITEMS ; Make sure there's at least
 CMP #02 ;   two items on stack
 BCC :ERROR

 LDY DATSTACK
 LDA DATAAREA+1,Y
 CMP DATAAREA+3,Y
 BNE :TRUE
 LDA DATAAREA+2,Y
 CMP DATAAREA+4,Y
 BNE :TRUE

 LDA #00
 HEX 2C
:TRUE LDA #$FF
 STA DATAAREA+3,Y
 STA DATAAREA+4,Y

 INY ; Adjust data stack pointer
 INY
 STY DATSTACK

:SKIPINC DEC DATITEMS ; Adjust data items pointer
 RTS

:ERROR LDA #04 ; "Data stack underflow"
 JMP PRTERR

*
* Word "U<" - unsigned compare
*

WORD69 ASC 'u< '
 DW ULESS

ULESS JSR POPDATA
 STY PNTR
 STX PNTR+1

 JSR POPDATA
 CPX PNTR+1
 BCC :TRUE
 BEQ :CHKLOW
 BCS :FALSE

:CHKLOW CPY PNTR
 BCC :TRUE

:FALSE LDY #00
 LDX #00
 JMP PUSHDATA

:TRUE LDY #$FF
 LDX #$FF
 JMP PUSHDATA

*
* Word "0=" - compare to zero
*

WORD70 ASC '0= '
 DW ZEROEQUA

ZEROEQUA JSR POPDATA
 TXA
 BNE :FALSE
 TYA
 BNE :FALSE
 LDA #$FF
 HEX 2C ; BIT trick
:FALSE LDA #00
 TAX
 TAY
 JMP PUSHDATA

*
* Word "0<" - compare negative
*

WORD71 ASC '0< '
 DW NEGATIVE

NEGATIVE JSR POPDATA
 TXA
 BPL :FALSE
 LDA #$FF
 HEX 2C ; BIT trick
:FALSE LDA #00
 TAX
 TAY
 JMP PUSHDATA

*
* Word "0>" - check positive
*

WORD72 ASC '0> '
 DW POSITIVE

POSITIVE JSR POPDATA
 TXA
 BNE :NOTZERO
 TYA
 BNE :NOTZERO
 BRA :FALSE

:NOTZERO TXA
 BMI :FALSE
 LDA #$FF
 HEX 2C ; BIT trick
:FALSE LDA #00
 TAX
 TAY
 JMP PUSHDATA

*
* Word "false" - push 0 on stack
*

WORD73 ASC 'false '
 DW FALSE

FALSE LDY #$00
 LDX #$00
 JMP PUSHDATA

*
* Word "true" - push -1 on stack
*

WORD74 ASC 'true '
 DW TRUE

TRUE LDY #$FF
 LDX #$FF
 JMP PUSHDATA

*
* Word "1+" - increment top item on stack
*
* Note: bypasses POPDATA, PUSHDATA for speed
*

WORD75 ASC '1+ '
 DW ONEPLUS

ONEPLUS LDA DATITEMS ; Make sure there's something on stack
 BEQ :ERROR ;   to increment

 LDX DATSTACK
 INC DATAAREA+1,X
 BNE :SKIPINC
 INC DATAAREA+2,X
:SKIPINC RTS

:ERROR LDA #04 ; "Data stack underflow"
 JMP PRTERR

*
* Word "1-" - decrement top item on stack
*
* Note: bypasses POPDATA, PUSHDATA for speed
*

WORD76 ASC '1- '
 DW ONEMINUS

ONEMINUS LDA DATITEMS ; Make sure there's something on stack
 BEQ :ERROR ;   to decrement

 LDX DATSTACK
 LDA DATAAREA+1,X
 BNE :SKIPDEC
 DEC DATAAREA+2,X
:SKIPDEC DEC DATAAREA+1,X
 RTS

:ERROR LDA #04 ; "Data stack underflow"
 JMP PRTERR

*
* Word "2+" - increment top item on stack by 2
*
* Note: bypasses POPDATA, PUSHDATA for speed
*

WORD77 ASC '2+ '
 DW TWOPLUS

TWOPLUS LDA DATITEMS ; Make sure there's something on stack
 BEQ :ERROR ;   to increment

 LDX DATSTACK
 LDA DATAAREA+1,X
 CLC
 ADC #02
 STA DATAAREA+1,X
 BCC :SKIPINC
 INC DATAAREA+2,X
:SKIPINC RTS

:ERROR LDA #04 ; "Data stack underflow"
 JMP PRTERR

*
* Word "2-" - decrement top item on stack by 2
*
* Note: bypasses POPDATA, PUSHDATA for speed
*

WORD78 ASC '2- '
 DW TWOMINUS

TWOMINUS LDA DATITEMS ; Make sure there's something on stack
 BEQ :ERROR ;   to decrement

 LDX DATSTACK
 LDA DATAAREA+1,X
 SEC
 SBC #02
 STA DATAAREA+1,X
 BCS :SKIPDEC
 DEC DATAAREA+2,X
:SKIPDEC RTS

:ERROR LDA #04 ; "Data stack underflow"
 JMP PRTERR

*
* Word "2*" - do arithmetic shift left on top stack item
*
* Note: bypasses POPDATA, PUSHDATA for speed
*

WORD79 ASC '2* '
 DW TWOMULT

TWOMULT LDA DATITEMS ; Make sure there's something on stack
 BEQ :ERROR ;   to multiply

 LDX DATSTACK
 ASL DATAAREA+1,X
 ROL DATAAREA+2,X
 RTS

:ERROR LDA #04 ; "Data stack underflow"
 JMP PRTERR

*
* Word "2/" - do logical shift right on top stack item
*
* Note: bypasses POPDATA, PUSHDATA for speed
*

WORD80 ASC '2/ '
 DW TWODIV

TWODIV LDA DATITEMS ; Make sure there's something on stack
 BEQ :ERROR ;   to multiply

 LDX DATSTACK
 LSR DATAAREA+2,X
 ROR DATAAREA+1,X
 RTS

:ERROR LDA #04 ; "Data stack underflow"
 JMP PRTERR

*
* Word "b.and" - performs binary AND
*

WORD81 ASC 'b.and '
 DW B_AND

B_AND JSR POPDATA
 STY PNTR
 STX PNTR+1
 JSR POPDATA
 TYA
 AND PNTR
 TAY
 TXA
 AND PNTR+1
 TAX
 JMP PUSHDATA

*
* Word "b.or" - performs binary OR
*

WORD82 ASC 'b.or '
 DW B_OR

B_OR JSR POPDATA
 STY PNTR
 STX PNTR+1
 JSR POPDATA
 TYA
 ORA PNTR
 TAY
 TXA
 ORA PNTR+1
 TAX
 JMP PUSHDATA

*
* Word "b.clr" - performs twos complement then AND
*

WORD83 ASC 'b.clr '
 DW B_CLR

B_CLR JSR POPDATA
 TYA
 EOR #$FF
 STA PNTR
 TXA
 EOR #$FF
 STA PNTR+1
 JSR POPDATA
 TYA
 AND PNTR
 TAY
 TXA
 AND PNTR+1
 TAX
 JMP PUSHDATA

*
* Word "key" - Wait for a key
*

WORD87 ASC 'key '
 DW KEY

KEY JSR GETKEY
 TAY
 LDX #00
 JMP PUSHDATA

*
* Word "expect" - awaits characters from keyboard
*

WORD89 ASC 'expect '
 DW EXPECT

EXPECT JSR POPDATA ; Get number of characters max
 STY PNTR2
 STX PNTR2+1

 JSR POPDATA ; Get address to store characters
 STY PNTR
 STX PNTR+1

 STZ SPANVAL ; Current number of keys
 STZ SPANVAL+1

:LOOP JSR GETKEY ; Get a key

 CMP #$08
 BEQ :BACK
 CMP #$7F
 BNE :NOTBACK
:BACK LDA SPANVAL ; Make sure we have characters to erase
 ORA SPANVAL+1
 BEQ :LOOP
 LDA SPANVAL ; Decrement number of characters
 BNE :SKIPDEC
 DEC SPANVAL+1
:SKIPDEC DEC SPANVAL
 LDA #$08 ; Erase previous character on screen
 JSR COUT
 LDA #' '
 JSR COUT
 LDA #$08
 JSR COUT
 BRA :LOOP

:NOTBACK CMP #$0D
 BNE :NOTRETN
 RTS

:NOTRETN LDY SPANVAL ; Make sure we haven't reached
 CPY PNTR2 ;   maximum # of characters yet
 BNE :OK
 LDY SPANVAL+1
 CPY PNTR2+1
 BEQ :LOOP

:OK TAY ; Store character at address
 LDA PNTR
 CLC
 ADC SPANVAL
 STA PNTR3
 LDA PNTR+1
 ADC SPANVAL+1
 STA PNTR3+1
 TYA
 STA (PNTR3)

 JSR COUT ; Echo key to screen

 INC SPANVAL ; Increment character count
 BNE :SKIPINC
 INC SPANVAL+1

:SKIPINC BRA :LOOP

*
* Word "span" - returns number of characters received by expect
*

WORD90 ASC 'span '
 DW SPAN

SPAN LDY SPANVAL
 LDX SPANVAL+1
 JMP PUSHDATA

SPANVAL HEX 0000

*
* Word "emit" - outputs character value on stack, low byte
*

WORD91 ASC 'emit '
 DW EMIT

EMIT JSR POPDATA
 TYA
 JMP COUT

*
* Word "space" - outputs space
*

WORD92 ASC 'space '
 DW SPACE

SPACE LDA #' '
PRT JMP COUT

*
* Word "spaces" - outputs multiples spaces
*

WORD93 ASC 'spaces '
 DW SPACES

SPACES JSR POPDATA
 STY PNTR
 STX PNTR+1

 LDA #" "

:LOOP LDX PNTR
 BNE :SKIPDEC
 DEC PNTR+1
 LDX PNTR+1
 CPX #$FF
 BEQ :FINIS
:SKIPDEC DEC PNTR
 JSR COUT
 BRA :LOOP

:FINIS RTS

*
* Word "cr" - outputs return
*

WORD94 ASC 'cr '
 DW CR

CR LDA #$8D
 BRA PRT

*
* Word "fill" - fills memory with value
*

WORD95 ASC 'fill '
 DW FILL

FILL JSR POPDATA ; Fetch fill value
 STY TEMP

FILL2 JSR POPDATA ; Fetch fill counter
 PHY
 PHX
 JSR POPDATA ; Fetch fill address
 STY PNTR
 STX PNTR+1

 LDA TEMP ; Set up fill value

 PLX ; Check if any pages
 BEQ :NOPAGE

 LDY #00 ; Fill in pages
:LOOP STA (PNTR),Y
 INY
 BNE :LOOP
 INC PNTR+1
 DEX
 BNE :LOOP

:NOPAGE PLX ; Fill in fractional pages
 BEQ :FINIS
 LDY #00
:LOOP2 STA (PNTR),Y
 INY
 DEX
 BNE :LOOP2

:FINIS RTS

*
* Word "erase" - fills memory with zeros
*

WORD96 ASC 'erase '
 DW ERASE

ERASE LDA #00
 STA TEMP
 JMP FILL2

*
* Word "bye" - exits Qforth
*

WORD98 ASC 'bye '
 DW BYE

* BYE JMP $3D0 ; jump to the DOS exit to BASIC
BYE JMP $FF69 ; jump to the monitor, kills DOS

********************************
* End regular words 2
********************************
