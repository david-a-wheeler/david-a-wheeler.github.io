
********************************
* Start special compiler words 2
********************************

*
* Word "if" - Conditional execution (compiler subroutine)
*

WORD11 ASC 'if '
 DW IF

IF BRK ; Special executable compiler subroutine

 LDA #$20 ; JSR IF
 JSR OUTBYTE
 LDA #IFSUB
 JSR OUTBYTE
 LDA #/IFSUB
 JSR OUTBYTE
 LDA #$D0 ; BNE (three bytes ahead to true (nonzero))
 JSR OUTBYTE
 LDA #$03
 JSR OUTBYTE
 LDA #$4C ; JMP (to false (zero))
 JSR OUTBYTE

 LDY COUTPUT ; Push patch location
 LDX COUTPUT+1
 JSR PUSHCOMP
 LDY #$01 ; Compiler state $0001 (wait for ELSE)
 LDX #$00
 JSR PUSHCOMP

 LDA #$00 ; (JMP) $0000
 JSR OUTBYTE
 JSR OUTBYTE
 RTS

*

IFSUB JSR POPDATA
 STX TEMP
 TYA
 ORA TEMP
 RTS

*
* Word "else" - False part of conditional (compiler subroutine)
*

WORD12 ASC 'else '
 DW ELSE

ELSE BRK ; Special executable compiler subroutine

 JSR POPCOMP
 CPY #$01
 BEQ :OK

 LDA #$06 ; "ELSE without matching IF"
 JMP PRTERR

:OK JSR POPCOMP ; Fetch the patch location for IF
 STY PNTR
 STX PNTR+1

 LDA #$4C ; Compile JMP to where execution merges
 JSR OUTBYTE

 LDY COUTPUT ; Push patch location
 LDX COUTPUT+1
 JSR PUSHCOMP
 LDY #$02 ; Compiler state $0002 (waiting for THEN)
 LDX #$00
 JSR PUSHCOMP

 LDA #$00 ; (JMP) $0000
 JSR OUTBYTE
 JSR OUTBYTE

 LDA COUTPUT ; Patch the JMP to false section for IF
 STA (PNTR)
 LDY #$01
 LDA COUTPUT+1
 STA (PNTR),Y
 RTS

*
* Word "then" - Resume execution after conditional
*

WORD13 ASC 'then '
 DW THEN

THEN BRK ; Special executable compiler subroutine

 JSR POPCOMP ; Should be in compiler state $0002
 CPY #$01
 BEQ :OK ; bug fix - thanks Toshi!
 CPY #$02
 BEQ :OK

 LDA #$07
 JMP PRTERR

:OK JSR POPCOMP
 STY PNTR
 STX PNTR+1
 LDA COUTPUT
 STA (PNTR)
 LDA COUTPUT+1
 LDY #$01
 STA (PNTR),Y
 RTS

*
* Word "do" - Start of DO - LOOP/+LOOP
*

WORD14 ASC 'do '
 DW DO

DO BRK ; Special executable compiler subroutine

 LDA #$20 ; JSR DOSUB
 JSR OUTBYTE
 LDA #DOSUB
 JSR OUTBYTE
 LDA #/DOSUB
 JSR OUTBYTE

 LDY COUTPUT ; Push address to LOOP/+LOOP back to
 LDX COUTPUT+1
 JSR PUSHCMP2

 LDY #$03 ; Compiler state $0003 - waiting for
 LDX #$00 ;   LEAVE, LOOP or +LOOP
 JMP PUSHCMP2

*

DOSUB JSR POPDATA ; Get loop initial counter value
 JSR PUSHRETN ; Push it to return stack
 JSR POPDATA ; Get loop limit counter value
 JMP PUSHRETN ; Push it to return stack

*
* Subroutine PATCHLV used by LOOP/+LOOP to patch LEAVES
*

PATCHLV JSR POPCMP2
 CPY #$04 ; Check for LEAVEs to be patched
 BNE :NOTLEAV

 JSR POPCMP2 ; There is a LEAVE to be patched
 STY PNTR
 STX PNTR+1

 LDA COUTPUT
 CLC
 ADC #$08
 STA (PNTR)

 LDA COUTPUT+1
 ADC #$00
 LDY #$01
 STA (PNTR),Y
 BRA PATCHLV

:NOTLEAV JMP PUSHCMP2 ; It's not a $0004 so push it back
;   and exit

*
* Word "loop" - End of DO-LOOP
*

WORD15 ASC 'loop '
 DW LOOP

LOOP BRK ; Special executable compiler subroutine

 JSR PATCHLV ; Patch any LEAVEs that need to be done

 JSR POPCMP2 ; Should be in compiler state $0003
 CPY #$03
 BEQ :OK

 LDA #$0F ; "LOOP without DO"
 JMP PRTERR

:OK LDA #$20 ; JSR LOOPSUB
 JSR OUTBYTE
 LDA #LOOPSUB
 JSR OUTBYTE
 LDA #/LOOPSUB
 JSR OUTBYTE

 LDA #$F0 ; BEQ three bytes ahead
 JSR OUTBYTE
 LDA #$03
 JSR OUTBYTE

 LDA #$4C ; JMP (patch area)
 JSR OUTBYTE
 JSR POPCMP2
 STX TEMP
 TYA
 JSR OUTBYTE
 LDA TEMP
 JMP OUTBYTE

*

LOOPSUB JSR POPRETN ; Pop loop counter limit value
 STY PNTR
 STX PNTR+1
 JSR POPRETN ; Pop loop counter current value
 INY
 BNE :SKIPINC
 INX
:SKIPINC CPY PNTR
 BNE :NOTFIN
 CPX PNTR+1
 BNE :NOTFIN
 RTS

:NOTFIN JSR PUSHRETN
 LDY PNTR
 LDX PNTR+1
 JSR PUSHRETN
 LDA #$FF ; Make BNE true
 RTS

*
* Word "+loop" - End of DO-+LOOP
*

WORD16 ASC '+loop '
 DW PLOOP

PLOOP BRK ; Special executable compiler subroutine

 JSR PATCHLV ; Patch any LEAVEs that need to be done

 JSR POPCMP2 ; Should be in compiler state $0003
 CPY #$03
 BEQ :OK

 LDA #$0F ; "+LOOP without DO"
 JMP PRTERR

:OK LDA #$20 ; JSR PLOOPSUB
 JSR OUTBYTE
 LDA #PLOOPSUB
 JSR OUTBYTE
 LDA #/PLOOPSUB
 JSR OUTBYTE

 LDA #$F0 ; BEQ three bytes ahead
 JSR OUTBYTE
 LDA #$03
 JSR OUTBYTE

 LDA #$4C ; JMP (patch area)
 JSR OUTBYTE
 JSR POPCMP2
 STX TEMP
 TYA
 JSR OUTBYTE
 LDA TEMP
 JMP OUTBYTE

*

PLOOPSUB JSR POPRETN ; Pop loop counter limit value
 STY PNTR
 STX PNTR+1
 JSR POPRETN ; Pop loop counter current value
 STY PNTR2
 STX PNTR2+1
 JSR POPDATA ; Pop increment value
 TYA
 CLC
 ADC PNTR2
 TAY
 TXA
 ADC PNTR2+1
 TAX

 TXA  23JAN04, RTK
 EOR PNTR+1
 AND #$80
 BEQ :SAME
 TXA
 BPL :DONE
 BRA :NOTFIN
:SAME CPX PNTR+1
 BNE :NOCHKLO
 CPY PNTR
:NOCHKLO BCC :NOTFIN
 BEQ :NOTFIN
:DONE LDA #0
 RTS

:NOTFIN JSR PUSHRETN
 LDY PNTR
 LDX PNTR+1
 JSR PUSHRETN
 LDA #$FF ; Make BNE true
 RTS

*
* Word "leave" - Terminate DO - LOOP/+LOOP immediately
*

WORD17 ASC 'leave '
 DW LEAVE

LEAVE BRK ; Special executable compiler word

 JSR POPCMP2 ; Should be in compiler state $0003
 CPY #$03 ;   (waiting for a LOOP/+LOOP)
 BEQ :OK ;   or in state $0004
 CPY #$04 ;   (other LEAVEs on stack)
 BEQ :OK

 LDA #$0F ; "LEAVE without DO"
 JMP PRTERR

:OK JSR PUSHCMP2 ; Push compiler state $0003 back on stack

 LDA #$4C ; JMP absolute (to be patched)
 JSR OUTBYTE

 LDY COUTPUT ; Patch area
 LDX COUTPUT+1
 JSR PUSHCMP2
 LDY #$04 ; Set compiler state $0004
 LDX #$00
 JSR PUSHCMP2

 LDA #$00 ; Finish off JMP
 JSR OUTBYTE
 JMP OUTBYTE

*
* Word "i" - get counter value of innermost loop
*            and leave it on the stack
*

WORD18 ASC 'i '
 DW I

I LDA RETITEMS
 BEQ :ERROR

 LDX RETSTACK
 LDA RETNAREA+3,X
 TAY
 LDA RETNAREA+4,X
 TAX
 JMP PUSHDATA

:ERROR LDA #06 ; "Return stack underflow"
 JMP PRTERR

*
* Word "j" - get counter value of next innermost loop
*            and leave it on the stack
*

WORD19 ASC 'j '
 DW J

J LDA RETITEMS
 BEQ :ERROR

 LDX RETSTACK
 LDA RETNAREA+7,X
 TAY
 LDA RETNAREA+8,X
 TAX
 JMP PUSHDATA

:ERROR LDA #06 ; "Return stack underflow"
 JMP PRTERR

*
* Word "begin" - part of BEGIN - UNTIL/WHILE-REPEAT
*

WORD20 ASC 'begin '
 DW BEGIN


BEGIN BRK ; Special executable compiler code

 LDY COUTPUT ; Save marker location
 LDX COUTPUT+1
 JSR PUSHCOMP

 LDY #$04 ; Set compiler state $0004
 LDX #$00
 JMP PUSHCOMP

*
* Word "until" - part of BEGIN-UNTIL
*

WORD21 ASC 'until '
 DW UNTIL

UNTIL BRK ; Special executable compiler code

 JSR POPCOMP ; Make sure we're in compiler state $0004
 CPY #$04
 BEQ :OK

 LDA #$10 ; "UNTIL without BEGIN"
 JMP PRTERR

:OK LDA #$20 ; JSR IFSUB (borrow it since it's same)
 JSR OUTBYTE
 LDA #IFSUB
 JSR OUTBYTE
 LDA #/IFSUB
 JSR OUTBYTE

 LDA #$D0 ; BNE (three bytes ahead)
 JSR OUTBYTE
 LDA #$03
 JSR OUTBYTE

 LDA #$4C ; JMP (marker location)
 JSR OUTBYTE
 JSR POPCOMP
 STX TEMP
 TYA
 JSR OUTBYTE
 LDA TEMP
 JMP OUTBYTE

*
* Word "while" - part of BEGIN-WHILE-REPEAT
*

WORD22 ASC 'while '
 DW WHILE

WHILE BRK  ; Special executable compiler code

 JSR POPCOMP ; Make sure we're in compiler state $0004
 CPY #$04
 BEQ :OK

 LDA #$10 ; "while without begin"
 JMP PRTERR

:OK LDA #$20 ; JSR IFSUB
 JSR OUTBYTE
 LDA #IFSUB
 JSR OUTBYTE
 LDA #/IFSUB
 JSR OUTBYTE

 LDA #$D0 ; BNE (three bytes ahead)
 JSR OUTBYTE
 LDA #$03
 JSR OUTBYTE

 LDA #$4C ; JMP (out of loop - patch area)
 JSR OUTBYTE

 LDY COUTPUT ; Push patch area onto compiler stack
 LDX COUTPUT+1
 JSR PUSHCOMP

 LDA #$00 ; Finish off JMP instruction
 JSR OUTBYTE
 JSR OUTBYTE

 LDY #$05 ; Set compiler mode $0005
 LDX #$00
 JMP PUSHCOMP

*
* Word "repeat" - part of BEGIN-WHILE-REPEAT
*

WORD23 ASC 'repeat '
 DW REPEAT

REPEAT BRK ; Special executable compiler word

 JSR POPCOMP ; Make sure we're in compiler state $0005
 CPY #$05
 BEQ :OK

 LDA #$11 ; "repeat without begin-while"
 JMP PRTERR

:OK LDA #$4C ; JMP (back to beginning)
 JSR OUTBYTE

 JSR POPCOMP ; Pop patch area out of loop
 STY PNTR2
 STX PNTR2+1

 JSR POPCOMP ; Pop marked area for beginning
 STX TEMP ;   and finish off JMP
 TYA
 JSR OUTBYTE
 LDA TEMP
 JSR OUTBYTE

 LDA COUTPUT ; Patch area for out of loop
 STA (PNTR2)
 LDA COUTPUT+1
 LDY #$01
 STA (PNTR2),Y

 RTS

*
* Subroutine used by ." and lit"
*

STROUT STA TEMP2
 STX TEMP3
 JSR SKIP2SPC ; Skip to string

 LDA (WORDPNTR)
 CMP #$0D
 BEQ :ERROR

 INC WORDPNTR
 BNE :SKIPINC
 INC WORDPNTR+1

:SKIPINC LDA (WORDPNTR)
 CMP #$0D
 BEQ :ERROR

 LDY #$FF ; Look for ending quote
:LOOP INY
 LDA (WORDPNTR),Y
 CMP #$0D
 BEQ :ERROR
 CMP TEMP3 ; Delimiter
 BNE :LOOP

 STY TEMP ; Save string length
 BIT TEMP2
 BPL :NOCOUNT
 TYA
 JSR OUTBYTE

:NOCOUNT TYA ; Output string
 TAX
 LDY #$00
:LOOP2 LDA (WORDPNTR),Y
 JSR OUTBYTE
 INY
 DEX
 BNE :LOOP2

 BIT TEMP2 ; Null-terminate if necessary
 BMI :NONULL
 TXA
 JSR OUTBYTE

:NONULL LDA TEMP ; Update WORDPNTR
 SEC
 ADC WORDPNTR
 STA WORDPNTR
 BCC :SKPINC2
 INC WORDPNTR+1

:SKPINC2 RTS

:ERROR LDA #$0C ; "No ending quote found for expression"
 JMP PRTERR

*
* Word /."/ - Print out a text string
*

WORD24 ASC '.'
 ASC '"'
 ASC ' '
 DW PRDQUOTE

PRDQUOTE BRK ; Special executable compiler word

 LDA #$20 ; JSR MSGOUT
 JSR OUTBYTE
 LDA #MSGOUT
 JSR OUTBYTE
 LDA #/MSGOUT
 JSR OUTBYTE

 LDA #$00
 LDX #$22
 JMP STROUT

:ERROR LDA #$0C ; "No ending quote found for .""
 JMP PRTERR

*
* Word /"/ - End of print string
*

WORD25 ASC '" '
 DW QUOTE

QUOTE BRK ; Special executable compiler word

 LDA #$19 ; /End quote without ."/
 JMP PRTERR

*
* Word "string" - compiles counted string literal
*                   into dictionary
*

WORD26 ASC 'string '
 DW STRING

STRING BRK ; Special executable compiler word

 LDA #$20 ; JSR STRSUB
 JSR OUTBYTE
 LDA #STRSUB
 JSR OUTBYTE
 LDA #/STRSUB
 JSR OUTBYTE

 LDA #$00
 LDX #$7E ; Tilde
 JMP STROUT

*

STRSUB PLA
 STA WORDPNTR
 PLA
 STA WORDPNTR+1

 LDY #$01 ; Output variable's name
:LOOP LDA (WORDPNTR),Y
 BEQ :EOL
 JSR OUTBYTE
 INY
 BRA :LOOP

:EOL TYA
 CLC
 ADC WORDPNTR
 TAX
 LDA WORDPNTR+1
 ADC #$00
 PHA
 PHX
 RTS

*
* Word /lit"/ - compiles counted string, returns address
*

WORD27 ASC 'lit'
 HEX 22
 ASC ' '
 DW LITQUOTE

LITQUOTE BRK ; Special executable compiler word

 LDA COUTPUT
 CLC
 ADC #$09
 STA PNTR
 LDA COUTPUT+1
 ADC #$00
 STA PNTR+1

 LDA #$A0 ; LDY #string
 JSR OUTBYTE
 LDA COUTPUT
 LDA PNTR
 JSR OUTBYTE

 LDA #$A2 ; LDX #/string
 JSR OUTBYTE
 LDA PNTR+1
 JSR OUTBYTE

 LDA #$20 ; JSR PUSHDATA
 JSR OUTBYTE
 LDA #PUSHDATA
 JSR OUTBYTE
 LDA #/PUSHDATA
 JSR OUTBYTE

 LDA #$80 ; BRA opcode
 JSR OUTBYTE
 LDA COUTPUT
 STA PNTR2
 LDA COUTPUT+1
 STA PNTR2+1
 LDA #$00
 JSR OUTBYTE

 LDA #$80 ; Output string
 LDX #$22 ; Double quote
 JSR STROUT

 LDA TEMP
 INC
 STA (PNTR2)
 RTS

*
* Word "(" - Start of comment
*

WORD28 ASC '( '
 DW LEFTPAR

LEFTPAR BRK ; Special executable compiler word

 LDY #$FF ; Find right parentheses
:LOOP INY
 LDA (WORDPNTR),Y
 CMP #$0D
 BEQ :ERROR
 CMP #')'
 BNE :LOOP

 INY ; Move word text pointer past
 TYA ;   right parentheses
 CLC
 ADC WORDPNTR
 STA WORDPNTR
 BNE :SKIPINC
 INC WORDPNTR+1
:SKIPINC RTS

:ERROR JMP PRTERR ; "No matching right parentheses
 ;    for comment"
; (Accumulator is already $0D)

*
* Word ")" - End of comment
*

WORD29 ASC ') '
 DW RIGHTPAR

RIGHTPAR LDA #$1A ; "Right parentheses without matching
 JMP PRTERR ;    left parentheses"

*
* Word "'" - Throw address of next word on stack
*

WORD30 HEX 27
 ASC ' '
 DW TICK

TICK BRK ; Special executable compiler word

 JSR SKIP2SPC ; Move pointer to next word
 JSR SKIPSPCS

 LDA #$20 ; JSR TICKSUB
 JSR OUTBYTE
 LDA #TICKSUB
 JSR OUTBYTE
 LDA #/TICKSUB
 JSR OUTBYTE

 JSR TEXTOUT ; Output word text

 LDA #' ' ; Space-terminate text
 JSR OUTBYTE

 JMP SKIP2SPC ; Move pointer past word

*

TICKSUB PLA ; Fetch text address
 STA WORDPNTR
 PLA
 STA WORDPNTR+1

 INC WORDPNTR
 BNE :SKIPINC
 INC WORDPNTR+1

:SKIPINC JSR CALCHASH ; Calculate hash of text
 JSR CHKWORD ; Look it up
 BCC :ERROR

 LDY PNTR ; Throw address of word on stack
 LDX PNTR+1
 JSR PUSHDATA

 JMP RESUME ; Resume execution after text

:ERROR LDA #07 ; "Word not found"
 JMP PRTERR

********************************
* End special compiler words 2
********************************
