************************************
*
*  New QForth words, start 30-Jun-95
*
*  RTK,  last mod: 17-Jan-98
*
************************************

PRBYTE EQU $FDDA
PRNTAX EQU $F941
T1 EQU $F6 ; temporary storage
T2 EQU $F7
T3 EQU $F8
T4 EQU $F9

*
* Word "3+"  -  increment TOS by 3
*

WORD107 ASC '3+ '
 DW THREEP
THREEP LDA DATITEMS
 BEQ :ERROR
 LDX DATSTACK
 LDA DATAAREA+1,X
 INC
 INC
 INC
 STA DATAAREA+1,X
 BNE :SKIPINC
 INC DATAAREA+2,X
:SKIPINC RTS
:ERROR LDA #04
 JMP PRTERR


*
* Word "3-"  -  decrement TOS by 3
*

WORD108 ASC '3- '
 DW THREEM
THREEM LDA DATITEMS
 BEQ :ERROR
 LDX DATSTACK
 LDA DATAAREA+1,X
 SEC
 SBC #03
 STA DATAAREA+1,X
 BCS :SKIPDEC
 DEC DATAAREA+2,X
:SKIPDEC RTS
:ERROR LDA #04 ; "Data stack underflow"
 JMP PRTERR


*
* Word "4+  -  increment TOS by 4
*

WORD109 ASC '4+ '
 DW FOURP
FOURP LDA DATITEMS
 BEQ :ERROR
 LDX DATSTACK
 LDA DATAAREA+1,X
 INC
 INC
 INC
 INC
 STA DATAAREA+1,X
 BNE :SKIPINC
 INC DATAAREA+2,X
:SKIPINC RTS
:ERROR LDA #04
 JMP PRTERR


*
* Word "4-"  -  decrement TOS by 4
*

WORD110 ASC '4- '
 DW FOURM
FOURM LDA DATITEMS
 BEQ :ERROR
 LDX DATSTACK
 LDA DATAAREA+1,X
 SEC
 SBC #04
 STA DATAAREA+1,X
 BCS :SKIPDEC
 DEC DATAAREA+2,X
:SKIPDEC RTS
:ERROR LDA #04
 JMP PRTERR


*
* Word "k"  -  put counter of third loop on the stack
*

WORD111 ASC 'k '
 DW K
K LDA RETITEMS
 BEQ :ERROR ; Nothing on the return stack
 LDX RETSTACK
 LDA RETNAREA+11,X
 TAY
 LDA RETNAREA+12,X
 TAX
 JMP PUSHDATA
:ERROR LDA #06
 JMP PRTERR

*
* Word "type"  --  normal Forth type ( addr len -- )
*

WORD116 ASC 'type '
 DW TYPE0
TYPE0 JSR POPDATA ; get length
 STY T1
 STX T2 ; save it
 JSR POPDATA ; get base address
 STY T3
 STX T4 ; save it too
* put addr+len+1 in T1 T2
 CLC
 LDA T1
 ADC T3
 STA T1
 LDA T2
 ADC T4
 STA T2
* print characters from T3 T4 to T1 T2
 LDX #00
:LOOP1 LDA (T3,X) ; get a character
 JSR COUT ; and print it
 CLC  ; increment address
 LDA T3
 ADC #01
 STA T3
 LDA T4
 ADC #00
 STA T4
 LDA T3 ; compare T3 T4 to T1 T2
 CMP T1
 BNE :LOOP1
 LDA T4
 CMP T2
 BNE :LOOP1
 RTS


*
* 'count' -- make counted string into ( addr len )
*

WORD117 ASC 'count '
 DW COUNT0
COUNT0 JSR POPDATA
 STY T1 ; save addr in T1 T2
 STX T2
 LDX #00
 LDA (T1,X) ; get count and save in T3
 STA T3
 CLC
 LDA T1 ; addr = addr + 1
 ADC #01
 STA T1
 LDA T2
 ADC #00
 STA T2
 LDY T1 ; push addr+1
 LDX T2
 JSR PUSHDATA
 LDX #00 ; push count
 LDY T3
 JSR PUSHDATA
 RTS


*
* 'here' -- return end-of-system+1
*

WORD119 ASC 'here '
 DW HERE0
HERE0 CLC
 LDA $E6 ; add 1 to end-of-system
 ADC #01
 STA T1
 LDA $E7
 ADC #00
 TAX
 LDY T1
 JSR PUSHDATA ; and push on stack
 RTS


*
* 'disp' -- display a null terminated string
*

WORD120 ASC 'disp '
 DW DISP
DISP JSR POPDATA
 STY T1
 STX T2
 LDX #00
:LOOP LDA (T1,X) ; get a char
 CMP #00 ; is it '\0'?
 BEQ :EXIT ; yes, exit
 JSR COUT ; no, print it
 CLC
 LDA T1
 ADC #01
 STA T1
 LDA T2
 ADC #00
 STA T2
 BRA :LOOP
:EXIT RTS

*
* 'depth' - return number of items on data stack
*

WORD127 ASC 'depth '
 DW DPTH
DPTH LDY DATITEMS
 LDX #00
 JMP PUSHDATA


