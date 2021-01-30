
********************************
* Start regular words 1
********************************

*
* Word "execute" - call machine-language subroutine
*

WORD31 ASC 'execute '
 DW EXECUTE

EXECUTE JSR POPDATA
 STY PNTR
 STX PNTR+1

 LDA AREGVAL
 LDX XREGVAL
 LDY YREGVAL
 JMP (PNTR)

*
* Word "areg" - push location of A-register variable
*

WORD32 ASC 'areg '
 DW AREG

AREG LDY #AREGVAL
 LDX #/AREGVAL
 JMP PUSHDATA

AREGVAL HEX 00

*
* Word "xreg" - push location of X-register variable
*

WORD33 ASC 'xreg '
 DW XREG

XREG LDY #XREGVAL
 LDX #/XREGVAL
 JMP PUSHDATA

XREGVAL HEX 00

*
* Word "yreg" - push location of Y-register variable
*

WORD34 ASC 'yreg '
 DW YREG

YREG LDY #YREGVAL
 LDX #/YREGVAL
 JMP PUSHDATA

YREGVAL HEX 00

*
* Word "words" - List out all defined words
*

WORD35 ASC 'words '
 DW WORDS

WORDS JMP LISTWRDS

*
* Word ".s" - dump out data stack
*

WORD36 ASC '.s '
 DW DOT_S

DOT_S LDA DATITEMS
 BEQ :EMPTY

 STA PNTR
 LDA #$FF
 STA PNTR+1

:LOOP LDY PNTR+1
 LDA DATAAREA,Y
 TAX
 DEY
 LDA DATAAREA,Y
 DEY
 STY PNTR+1
 TAY
 JSR PRTSIGND
 DEC PNTR
 BNE :LOOP
 RTS

:EMPTY JSR MSGOUT
 HEX 8D
 ASC "Data stack empty",8D00
 RTS

*
* Subroutine to print out number in signed format
*
* Called by: DOT_S, DOT_R, DOT
*

PRTSIGND TXA
 BPL :POSITIV

 LDA #"-"
 JSR COUT
 TYA
 EOR #$FF
 CLC
 ADC #01
 TAY
 TXA
 EOR #$FF
 ADC #00
 TAX

:POSITIV JMP PRTDEC

*
* Word ".r" - dump out data stack
*

WORD37 ASC '.r '
 DW DOT_R

DOT_R LDA RETITEMS
 BEQ :EMPTY

 STA PNTR
 LDA #$FF
 STA PNTR+1

:LOOP LDY PNTR+1
 LDA RETNAREA,Y
 TAX
 DEY
 LDA RETNAREA,Y
 DEY
 STY PNTR+1
 TAY
 JSR PRTSIGND
 DEC PNTR
 BNE :LOOP
 RTS

:EMPTY JSR MSGOUT
 HEX 8D
 ASC "Return stack empty",8D00
 RTS

*
* Word "!" - Store number at pointer
*

WORD38 ASC '! '
 DW EXCLAM

EXCLAM JSR POPDATA
 STY PNTR
 STX PNTR+1
 JSR POPDATA
 TYA
 STA (PNTR)
 LDY #$01
 TXA
 STA (PNTR),Y
 RTS

*
* Word "@" - Fetch number at pointer
*

WORD39 ASC '@ '
 DW ATSIGN

ATSIGN JSR POPDATA
 STY PNTR
 STX PNTR+1
 LDY #$01
 LDA (PNTR),Y
 TAX
 LDA (PNTR)
 TAY
 JMP PUSHDATA

*
* Word "c!" - Store byte at pointer
*

WORD40 ASC 'c! '
 DW CSTORE

CSTORE JSR POPDATA
 STY PNTR
 STX PNTR+1
 JSR POPDATA
 TYA
 STA (PNTR)
 RTS

*
* Word "c@" - Fetch byte at pointer
*

WORD41 ASC 'c@ '
 DW CFETCH

CFETCH JSR POPDATA
 STY PNTR
 STX PNTR+1
 LDA (PNTR)
 TAY
 LDX #$00
 JMP PUSHDATA

*
* Word "+!" - Add given value to contents of given address
*

WORD42 ASC '+! '
 DW PLUSQMRK

PLUSQMRK JSR POPDATA ; Fetch address
 STY PNTR
 STX PNTR+1

 JSR POPDATA ; Fetch value to add

 TYA
 CLC
 ADC (PNTR)
 STA (PNTR)
 TXA
 LDY #01
 ADC (PNTR),Y
 STA (PNTR),Y

 RTS

*
* Word "?" - Print contents of address
*

WORD43 ASC '? '
 DW QMARK

QMARK JSR POPDATA
 STY PNTR
 STX PNTR+1
 LDY #$01
 LDA (PNTR),Y
 TAX
 LDA (PNTR)
 TAY
 JMP PRTSIGND

*
* Word "dup" - Duplicate top number on stack
*

WORD44 ASC 'dup '
 DW DUP

DUP JSR POPDATA
 STY PNTR
 STX PNTR+1
 JSR PUSHDATA
 LDY PNTR
 LDX PNTR+1
 JMP PUSHDATA

*
* Word "drop" - Discard top item on stack
*

WORD45 ASC 'drop '
 DW DROP

DROP JMP POPDATA

*
* Word "swap" - Reverses top two stack items
*

WORD46 ASC 'swap '
 DW SWAP

SWAP JSR POPDATA
 STY PNTR
 STX PNTR+1
 JSR POPDATA
 STY PNTR2
 STX PNTR2+1
 LDY PNTR
 LDX PNTR+1
 JSR PUSHDATA
 LDY PNTR2
 LDX PNTR2+1
 JMP PUSHDATA

*
* Word "over" - Makes a copy of the 2nd item
*                 and pushes it to top
*

WORD47 ASC 'over '
 DW OVER

OVER JSR POPDATA
 STY PNTR2
 STX PNTR2+1
 JSR POPDATA
 STY PNTR
 STX PNTR+1
 JSR PUSHDATA
 LDY PNTR2
 LDX PNTR2+1
 JSR PUSHDATA
 LDY PNTR
 LDX PNTR+1
 JMP PUSHDATA

*
* Word "rot" - Rotate the third item to top
*

WORD48 ASC 'rot '
 DW ROT

ROT JSR POPDATA
 STY PNTR3
 STX PNTR3+1
 JSR POPDATA
 STY PNTR2
 STX PNTR2+1
 JSR POPDATA
 STY PNTR
 STX PNTR+1

 LDY PNTR2
 LDX PNTR2+1
 JSR PUSHDATA
 LDY PNTR3
 LDX PNTR3+1
 JSR PUSHDATA
 LDY PNTR
 LDX PNTR+1
 JMP PUSHDATA

*
* Word ">r" - Moves value from data stack to return stack
*

WORD49 ASC '>r '
 DW TOR

TOR JSR POPDATA
 JMP PUSHRETN

*
* Word "r>" - Moves value from return stack to data stack
*

WORD50 ASC 'r> '
 DW RFROM

RFROM JSR POPRETN
 JMP PUSHDATA

*
* Word "r@" - Copy value from return stack to data stack
*

R1 HEX 00
R2 HEX 00

WORD51 ASC 'r@ '
 DW RFETCH

RFETCH JSR POPRETN
 STX R1
 STY R2
 JSR PUSHRETN
 LDX R1
 LDY R2
 JMP PUSHDATA

*
* Word "." - Print out top number on stack as signed integer
*

WORD52 ASC '. '
 DW DOT

DOT JSR POPDATA
 JMP PRTSIGND

*
* Word "u." - print out top number on stack as unsigned int
*

WORD53 ASC 'u. '
 DW U_DOT

U_DOT JSR POPDATA
 JMP PRTDEC

*
* Word "not" - do logical NOT on top number
*
* Note: Bypasses POPDATA, PUSHDATA for speed
*

WORD54 ASC 'not '
 DW NOT

NOT LDA DATITEMS ; Make sure there's something on stack
 BEQ :ERROR ;   to negate

 LDY DATSTACK
 LDA DATAAREA+1,Y
 ORA DATAAREA+2,Y
 BNE :FALSE
 LDA #$FF
 HEX 2C ; BIT trick
:FALSE LDA #00
 STA DATAAREA+1,Y
 STA DATAAREA+2,Y
 RTS

:ERROR LDA #04 ; "Data stack underflow"
 JMP PRTERR

*
* Word "and" - perform logical AND on top two stack items
*

WORD55 ASC 'and '
 DW AND

AND JSR POPDATA
 STY TEMP
 TXA
 ORA TEMP
 STA TEMP
 BEQ :FALSE

 JSR POPDATA
 STY TEMP
 TXA
 ORA TEMP
 STA TEMP
 BEQ :FALSE2

 LDX #$FF
 LDY #$FF
 JMP PUSHDATA

:FALSE JSR POPDATA
:FALSE2 LDX #$00
 LDY #$00
 JMP PUSHDATA

*
* Word "or" - Perform logical OR on top two stack items
*

WORD56 ASC 'or '
 DW OR

OR JSR POPDATA
 STY TEMP
 TXA
 ORA TEMP
 STA TEMP
 JSR POPDATA
 TYA
 ORA TEMP
 STA TEMP
 TXA
 ORA TEMP
 STA TEMP
 BNE :TRUE
 LDX #$00
 LDY #$00
 JMP PUSHDATA

:TRUE LDX #$FF
 LDY #$FF
 JMP PUSHDATA

*
* Word "xor" - Do logical XOR on top two stack items
*

WORD57 ASC 'xor '
 DW XOR

XOR JSR POPDATA
 STY TEMP
 TXA
 ORA TEMP
 BEQ :ZERO
 LDA #$FF
 HEX 2C
:ZERO LDA #$00
 STA TEMP

 JSR POPDATA
 STY TEMP2
 TXA
 ORA TEMP2
 BEQ :ZERO2
 LDA #$FF
 HEX 2C
:ZERO2 LDA #$00
 EOR TEMP
 TAY
 TAX
 JMP PUSHDATA

*
* Word "+" - Add two numbers on stack,
*            leave result on stack
*

WORD58 ASC '+ '
 DW ADD

ADD JSR POPDATA
 STY TEMP
 STX TEMP+1
 JSR POPDATA
 TYA
 CLC
 ADC TEMP
 TAY
 TXA
 ADC TEMP+1
 TAX
 JMP PUSHDATA

*
* Word "-" - Subtract top word from next-top word,
*            leave result on stack
*

WORD59 ASC '- '
 DW MINUS

MINUS JSR POPDATA
 STY TEMP
 STX TEMP+1
 JSR POPDATA
 TYA
 SEC
 SBC TEMP
 TAY
 TXA
 SBC TEMP+1
 TAX
 JMP PUSHDATA

*
* Word "*" - Multiply two numbers on stack,
*            leave result on stack (signed)
*

WORD60 ASC '* '
 DW ASTERISK

ASTERISK JSR GETNUMS ; Fetch two signed integers

 STZ TEMP
 LDY #00

 LDX #16
:LOOP LSR PNTR+1
 ROR PNTR
 BCC :SKIPADD
 TYA
 CLC
 ADC PNTR2
 TAY
 LDA PNTR2+1
 ADC TEMP
 STA TEMP
:SKIPADD ASL PNTR2
 ROL PNTR2+1
 DEX
 BNE :LOOP

 LDX TEMP
 BIT TEMP2 ; Check for negative
 BPL :NOTNEG

 TYA
 EOR #$FF
 CLC
 ADC #01
 TAY
 TXA
 EOR #$FF
 ADC #00
 TAX

:NOTNEG JMP PUSHDATA

*
* GETNUMS - subroutine for fetching two signed numbers
*             (called by ASTERISK, SLASH, MOD)
*

GETNUMS JSR POPDATA ; Get first number and store sign
 TXA
 BPL :POS

 LDA #$FF
 STA TEMP2
 TYA
 EOR #$FF
 CLC
 ADC #01
 STA PNTR
 TXA
 EOR #$FF
 ADC #00
 STA PNTR+1
 BRA :MERGE

:POS STZ TEMP2
 STY PNTR
 STX PNTR+1

:MERGE JSR POPDATA ; Get second number and store sign
 TXA
 BPL :POS2

 LDA TEMP2
 EOR #$FF ; Invert high bit of TEMP2
 STA TEMP2

 TYA
 EOR #$FF
 CLC
 ADC #01
 STA PNTR2
 TXA
 EOR #$FF
 ADC #00
 STA PNTR2+1
 RTS

:POS2 STY PNTR2
 STX PNTR2+1
 RTS

*
* Word "/" - Divide two numbers on stack,
*            leave result on stack
*

WORD61 ASC '/ '
 DW SLASH

SLASH JSR GETNUMS

 JSR DIVSUB

 LDY PNTR2
 LDX PNTR2+1
 BIT TEMP2
 BPL :POSITIV

 TYA
 EOR #$FF
 CLC
 ADC #01
 TAY
 TXA
 EOR #$FF
 ADC #00
 TAX

:POSITIV JMP PUSHDATA

*
* DIVSUB - subroutine for division
*            (called by SLASH, MOD)
*

DIVSUB LDA PNTR
 ORA PNTR+1
 BEQ :ERROR
 STZ PNTR3
 STZ PNTR3+1

 LDX #16
:LOOP ASL PNTR2
 ROL PNTR2+1
 ROL PNTR3
 ROL PNTR3+1
 LDA PNTR3
 SEC
 SBC PNTR
 TAY
 LDA PNTR3+1
 SBC PNTR+1
 BCC :NOGOOD
 STA PNTR3+1
 STY PNTR3
 LDA PNTR2
 ORA #01
 STA PNTR2
:NOGOOD DEX
 BNE :LOOP

 RTS

:ERROR LDA #$0E ; "Division by zero"
 JMP PRTERR

*
* Word "mod" - Divide two numbers on stack,
*              leave modulus on stack
*

WORD62 ASC 'mod '
 DW MOD

MOD JSR POPDATA ; Get first number and ignore sign
 TXA
 BPL :POS

 TYA
 EOR #$FF
 CLC
 ADC #01
 STA PNTR
 TXA
 EOR #$FF
 ADC #00
 STA PNTR+1
 BRA :MERGE

:POS STY PNTR
 STX PNTR+1

:MERGE JSR POPDATA ; Get second number and store sign
 TXA
 BPL :POS2

 LDA #$FF
 STA TEMP2
 TYA
 EOR #$FF
 CLC
 ADC #01
 STA PNTR2
 TXA
 EOR #$FF
 ADC #00
 STA PNTR2+1
 BRA :MERGE2

:POS2 STZ TEMP2
 STY PNTR2
 STX PNTR2+1

:MERGE2 JSR DIVSUB

 LDY PNTR3 ; Set sign of modulus to same as dividend
 LDX PNTR3+1
 BIT TEMP2
 BPL :POSITIV

 TYA
 EOR #$FF
 CLC
 ADC #01
 TAY
 TXA
 EOR #$FF
 ADC #00
 TAX

:POSITIV JMP PUSHDATA

********************************
* End regular words 1
********************************
