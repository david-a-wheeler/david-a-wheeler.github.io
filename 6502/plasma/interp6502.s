.DEFINE	EQU	=
.DEFINE	DB	.BYTE
.DEFINE	DW	.WORD
.DEFINE	DS	.RES

TRON    EQU     $FF

ESTKSZ	EQU	$40
ESTK	EQU	$80
ESTKL	EQU	ESTK
ESTKH	EQU	ESTK+1
PC	EQU	ESTK+ESTKSZ
PCL	EQU	PC
PCH	EQU	PC+1
FP	EQU	PC+2
FPL	EQU	FP
FPH	EQU	FP+1
TMP	EQU	FP+2
TMPL	EQU	TMP
TMPH	EQU	TMP+1
NPARMS	EQU	TMPL
FRMSZ	EQU	TMPH

        JMP     PLASMA
        DB      $EE,$EE
        DB      65,00
        DS      64
;*
;* INIT AND ENTER INTO PLASMA BYTECODE INTERPRETER
;*   Y:A = ADDRESS OF INITAL FRAME POINTER
;*
PLASMA:	LDA     #$00
	LDY	#$BF
	STA     FPL
	STY	FPH
	LDX     #$FE
	TXS
        LDX	#ESTKSZ
	STX	ESP
;	LDA     TRON
;	BNE     TRACE
;	JMP	FETCHOP
    JSR START
    DEX
    DEX
    LDA #$FF
    STA ESTKL,X
    STA ESTKH,X ; EXIT 0
;*
;* EXIT TO NATIVE CODE
;*
EXIT:	JSR	$BF00
	DB	$65
	DW	PARMTABLE
PARMTABLE:
	DB	4
	DB	0
ESP:	DB	0
;*
;* ENTER INTO INTERPRETER
;*
INTERP:
;        LDA     TRON
;        BNE     TRACE
        PLA
	STA	PC
	PLA
	STA	PC+1
    LDY	#$00
	INC     PCL
	BNE     FETCHOP
	INC     PCH
FETCHOP: ; LDY #$00
	LDA	(PC),Y
	STA	JSROP+1
    JSR JSROP
        INC     PCL
        BNE     FETCHOP
	INC	PCH
        BNE     FETCHOP
JSROP:	JMP     (OPTBL)
;TRACE:	PLA
;	STA	PC
;	PLA
;	STA	PC+1
;	INC     PCL
;	BNE     TRACEOP
;	INC     PCH
;TRACEOP:TXA
;        PHA
;        LDA     PCH
;        LDX     PCL
;        JSR     $F941
;        LDA     #$BA
;        JSR     $FDED
;        LDY	#$00
;	LDA	(PC),Y
;	JSR     $FDDA
;	JSR     $FD8E
;        PLA
;        TAX
;        LDY	#$00
;	LDA	(PC),Y
;	TAY
;	LDA	OPTBL,Y
;	STA	JSRTOP+1
;	LDA	OPTBL+1,Y
;	STA	JSRTOP+2
;JSRTOP:	JSR     $0000
;        INC     PCL
;        BNE     TRACEOP
;	INC	PCH
;        BNE     TRACEOP
_IJMPTMP: JMP	(TMP)
;*
;* SHIFT TOS-1 LEFT BY 1, ADD TO TOS-1
;*
IDXW:	LDA	ESTKL,X
        ASL
	ROL	ESTKH,X
	CLC
	ADC	ESTKL+2,X
	STA	ESTKL+2,X
	LDA	ESTKH,X
	ADC	ESTKH+2,X
	STA	ESTKH+2,X
	INX
	INX
	RTS
;*
;* ADD TOS TO TOS-1
;*
IDXB:
;*
;* ADD TOS TO TOS-1
;*
ADD:	LDA	ESTKL,X
	CLC
	ADC	ESTKL+2,X
	STA	ESTKL+2,X
	LDA	ESTKH,X
	ADC	ESTKH+2,X
	STA	ESTKH+2,X
	INX
	INX
	RTS
;*
;* SUB TOS FROM TOS-1
;*
SUB:	LDA	ESTKL+2,X
	SEC
	SBC	ESTKL,X
	STA	ESTKL+2,X
	LDA	ESTKH+2,X
	SBC	ESTKH,X
	STA	ESTKH+2,X
	INX
	INX
	RTS
;*
;* MUL TOS-1 BY TOS
;*
MUL:	LDY	#$00
	STY	TMPL		; PRODL
	STY	TMPH		; PRODH
	LDY	#$10
MUL1:	LSR	ESTKH,X		; MULTPLRH
	ROR	ESTKL,X		; MULTPLRL
	BCC	MUL2
	LDA	ESTKL+2,X	; MULTPLNDL
	CLC
	ADC	TMPL		; PRODL
	STA	TMPL
	LDA	ESTKH+2,X	; MULTPLNDH
	ADC	TMPH		; PRODH
	STA	TMPH
MUL2:	ASL	ESTKL+2,X	; MULTPLNDL
	ROL	ESTKH+2,X	; MULTPLNDH
	DEY
	BNE	MUL1
	INX
	INX
	LDA	TMPL		; PRODL
	STA	ESTKL,X
	LDA	TMPH		; PRODH
	STA	ESTKH,X
	RTS
;*
;* OPCODE TABLE
;*
    DS $11
OPTBL:	DW	ZERO,ADD,SUB,MUL,DIV,MOD,INCR,DECR	; 00 02 04 06 08 0A 0C 0E
	DW	NEG,COMP,BAND,IOR,XOR,SHL,SHR,IDXW	; 10 12 14 16 18 1A 1C 1E
        DW	NOT,LOR,LAND,LAA,LLA,CB,CW,IDXB		; 20 22 24 26 28 2A 2C 2E
	DW	DROP,DUP,OVER,SWAP,BRLT,BRGT,BREQ,BRNE	; 30 32 34 36 38 3A 3C 3E
        DW	ISEQ,ISNE,ISGT,ISLT,ISGE,ISLE,BRFLS,BRTRU; 40 42 44 46 48 4A 4C 4E
	DW	JUMP,IJMP,CALL,ICAL,ENTER,LEAVE,RET,EXIT; 50 52 54 56 58 5A 5C 5E
	DW	LB,LW,LLB,LLW,LAB,LAW,DLB,DLW		; 60 62 64 66 68 6A 6C 6E
	DW	SB,SW,SLB,SLW,SAB,SAW,DAB,DAW		; 70 72 74 76 78 7A 7C 7E
;*
;* INTERNAL DIVIDE ALGORITHM
;*
_DIV:	LDA	ESTKH,X
	AND	#$80
	STA	DVSIGN
	BPL	_DIV1
	JSR	NEG
	INC	DVSIGN
_DIV1:	LDA	ESTKH+2,X
	BPL	_DIV2
	INX
	INX
	JSR	NEG
	DEX
	DEX
	INC	DVSIGN
	BNE     _DIV3
_DIV2:  ORA	ESTKL+2,X	; DVDNDL
        BNE     _DIV3
        STA     TMPL
        STA     TMPH
        TYA
        RTS
_DIV3:  LDY	#$11		; #BITS+1
	LDA	#$00
	STA	TMPL		; REMNDRL
	STA	TMPH		; REMNDRH
_DIV4:	ASL	ESTKL+2,X	; DVDNDL
	ROL	ESTKH+2,X	; DVDNDH
	DEY
	BCC     _DIV4
	STY	ESTKL-2,X
_DIV5:  ROL	TMPL		; REMNDRL
	ROL	TMPH		; REMNDRH
	LDA	TMPL		; REMNDRL
	SEC
	SBC	ESTKL,X		; DVSRL
	TAY
	LDA	TMPH		; REMNDRH
	SBC	ESTKH,X		; DVSRH
	BCC	_DIV6
	STA	TMPH		; REMNDRH
	STY	TMPL		; REMNDRL
_DIV6:	ROL	ESTKL+2,X	; DVDNDL
	ROL	ESTKH+2,X	; DVDNDH
	DEC	ESTKL-2,X
	BNE	_DIV5
        LDY     #$00
	RTS
DVSIGN:	DB	0
;*
;* DIV TOS-1 BY TOS
;*
DIV:	JSR	_DIV
	INX
	INX
	LSR	DVSIGN		; SIGN(RESULT) = (SIGN(DIVIDEND) + SIGN(DIVISOR)) & 1
	BCS	NEG
	RTS
;*
;* MOD TOS-1 BY TOS
;*
MOD:	JSR	_DIV
	INX
	INX
	LDA	TMPL		; REMNDRL
	STA	ESTKL,X
	LDA	TMPH		; REMNDRH
	STA	ESTKH,X
	LDA	DVSIGN		; REMAINDER IS SIGN OF DIVIDEND
	BMI	NEG
	RTS
;*
;* NEGATE TOS
;*
NEG:	LDA	#$00
	SEC
	SBC	ESTKL,X
	STA	ESTKL,X
	LDA	#$00
	SBC	ESTKH,X
	STA	ESTKH,X
	RTS
;*
;* INCREMENT TOS
;*
INCR:	INC	ESTKL,X
	BNE	INCR1
	INC	ESTKH,X
INCR1:	RTS
;*
;* DECREMENT TOS
;*
DECR:	LDA	ESTKL,X
	BNE	DECR1
	DEC	ESTKH,X
DECR1:	DEC	ESTKL,X
	RTS
;*
;* BITWISE COMPLIMENT TOS
;*
COMP:	LDA	#$FF
	EOR	ESTKL,X
	STA	ESTKL,X
	LDA	#$FF
	EOR	ESTKH,X
	STA	ESTKH,X
	RTS
;*
;* BITWISE AND TOS TO TOS-1
;*
BAND:	LDA	ESTKL+2,X
	AND	ESTKL,X
	STA	ESTKL+2,X
	LDA	ESTKH+2,X
	AND	ESTKH,X
	STA	ESTKH+2,X
	INX
	INX
	RTS
;*
;* INCLUSIVE OR TOS TO TOS-1
;*
IOR:	LDA	ESTKL+2,X
	ORA	ESTKL,X
	STA	ESTKL+2,X
	LDA	ESTKH+2,X
	ORA	ESTKH,X
	STA	ESTKH+2,X
	INX
	INX
	RTS
;*
;* EXLUSIVE OR TOS TO TOS-1
;*
XOR:	LDA	ESTKL+2,X
	EOR	ESTKL,X
	STA	ESTKL+2,X
	LDA	ESTKH+2,X
	EOR	ESTKH,X
	STA	ESTKH+2,X
	INX
	INX
	RTS
;*
;* SHIFT TOS-1 LEFT BY TOS
;*
SHL:	LDA	ESTKL,X
        CMP     #$08
        BCC     SHL1
        LDY     ESTKL+2,X
        STY     ESTKH+2,X
        LDY     #$00
        STY     ESTKL+2,X
        SBC     #$08
SHL1:	TAY
        BEQ     SHL3
SHL2:	ASL	ESTKL+2,X
	ROL	ESTKH+2,X
	DEY
	BNE	SHL2
SHL3:	INX
	INX
	RTS
;*
;* SHIFT TOS-1 RIGHT BY TOS
;*
SHR:	LDA	ESTKL,X
        CMP     #$08
        BCC     SHR2
        LDY     ESTKH+2,X
        STY     ESTKL+2,X
        CPY     #$80
        LDY     #$00
        BCC     SHR1
        DEY
SHR1:   STY     ESTKH+2,X
        SEC
        SBC     #$08
SHR2:   TAY
        BEQ     SHR4
	LDA	ESTKH+2,X
SHR3:	CMP	#$80
	ROR
	ROR	ESTKL+2,X
	DEY
	BNE     SHR3
	STA     ESTKH+2,X
SHR4:	INX
	INX
	RTS
;*
;* LOGICAL NOT
;*
NOT:	LDA     ESTKL,X
        ORA     ESTKH,X
        BNE     NOT1
        LDA     #$FF
	STA     ESTKL,X
        STA     ESTKH,X
        RTS
NOT1:   LDA     #$00
	STA     ESTKL,X
        STA     ESTKH,X
        RTS
;*
;* LOGICAL AND
;*
LAND:	LDA     ESTKL,X
        ORA     ESTKH,X
        BEQ     LAND1
        LDA     ESTKL+2,X
        ORA     ESTKH+2,X
        BEQ     LAND1
        LDA     #$FF
LAND1:	STA     ESTKL+2,X
        STA     ESTKH+2,X
        INX
        INX
        RTS
;*
;* LOGICAL OR
;*
LOR:	LDA     ESTKL,X
        ORA     ESTKH,X
        ORA     ESTKL+2,X
        ORA     ESTKH+2,X
        BEQ     LOR1
        LDA     #$FF
LOR1:	STA     ESTKL+2,X
        STA     ESTKH+2,X
;*
;* DROP TOS
;*
DROP:	INX
        INX
	RTS
;*
;* DUPLICATE TOS
;*
DUP:	DEX
	DEX
	LDA	ESTKL+2,X
	STA	ESTKL,X
	LDA	ESTKH+2,X
	STA	ESTKH,X
	RTS
;*
;* OVER TOS-1 TO TOS
;*
OVER:	DEX
	DEX
	LDA	ESTKL+4,X
	STA	ESTKL,X
	LDA	ESTKH+4,X
	STA	ESTKH,X
	RTS
;*
;* SWAP TOS WITH TOS-1
;*
SWAP:	LDA	ESTKL+2,X
	STA	ESTKL,X
	LDA	ESTKL,X
	STA	ESTKL+2,X
	LDA	ESTKH+2,X
	STA	ESTKH,X
	LDA	ESTKH,X
	STA	ESTKH+2,X
	RTS
;*
;* CONSTANT
;*
ZERO:   DEX
        DEX
	LDA	#$00
	STA	ESTKL,X
	STA	ESTKH,X
	RTS
CB:	DEX
        DEX
	INC	PCL
	BNE	CB1
	INC	PCH
CB1:	; LDY	#$00
	LDA	(PC),Y
	STA	ESTKL,X
	STY	ESTKH,X
	RTS
LAA:                             ; THIS IS FOR THE LOADER TO REPLACE ABS TAG WITH ADDRESS
CW:	DEX
        DEX
	INC	PCL
	BNE	CW1
	INC	PCH
CW1:	; LDY	#$00
	LDA	(PC),Y
	STA	ESTKL,X
	INC	PCL
	BNE	CW2
	INC	PCH
CW2:	LDA	(PC),Y
	STA	ESTKH,X
	RTS
;*
;* LOAD VALUE FROM ADDRESS TAG
;*
LB:	LDA     (ESTK,X)
	LDY     #$00
	STA     ESTKL,X
	STY     ESTKH,X
	RTS
LW:	LDA     (ESTK,X)
        INC     ESTKL,X
        BNE     LW1
        INC     ESTKH,X
LW1:	TAY
        LDA     (ESTK,X)
        STY     ESTKL,X
        STA     ESTKH,X
        LDY     #$00
        RTS
;*
;* LOAD ADDRESS OF LOCAL FRAME OFFSET
;*
LLA:	INC	PCL
	BNE	LLA1
	INC	PCH
LLA1:	; LDY	#$00
	LDA	(PC),Y
_LLA:	DEX
        DEX
	CLC
	ADC	FPL
	STA	ESTKL,X
	LDA     #$00
	ADC	FPH
	STA	ESTKH,X
	RTS
;*
;* LOAD VALUE FROM LOCAL FRAME OFFSET
;*
LLB:	INC	PCL
	BNE	LLB1
	INC	PCH
LLB1:	; LDY	#$00
	LDA	(PC),Y
        TAY
_LLB:	DEX
        DEX
        LDA	(FP),Y
	LDY	#$00
	STA	ESTKL,X
	STY	ESTKH,X
	RTS
LLW:	INC	PCL
	BNE	LLW1
	INC	PCH
LLW1:	; LDY	#$00
	LDA	(PC),Y
        TAY
_LLW:	DEX
        DEX
        LDA	(FP),Y
	STA	ESTKL,X
	INY
	LDA	(FP),Y
	STA	ESTKH,X
        LDY     #$00
	RTS
;*
;* LOAD VALUE FROM ABSOLUTE ADDRESS
;*
LAB:	INC	PCL
	BNE	LAB1
	INC	PCH
LAB1:	; LDY	#$00
	LDA	(PC),Y
	STA	TMPL
	INC	PCL
	BNE	LAB2
	INC	PCH
LAB2:	LDA	(PC),Y
	STA	TMPH
	LDA	(TMP),Y
_PUSHYA: DEX
	DEX
	STA	ESTKL,X
	STY	ESTKH,X
	RTS
_PULLYA: LDY	ESTKH,X
_PULLA:	LDA	ESTKL,X
	INX
	INX
	RTS
LAW:	INC	PC
	BNE	LAW1
	INC	PCH
LAW1:	; LDY	#$00
	LDA	(PC),Y
	STA	TMPL
	INC	PCL
	BNE	LAW2
	INC	PCH
LAW2:	LDA	(PC),Y
	STA	TMPH
	DEX
	DEX
	LDA	(TMP),Y
	STA	ESTKL,X
	INY
	LDA	(TMP),Y
	STA	ESTKH,X
        LDY     #$00
	RTS
;*
;* STORE VALUE TO ADDRESS
;*
SB:	LDA	ESTKL,X
	STA	(ESTK+2,X)
        INX
        INX
	INX
	INX
	RTS
SW:	LDA	ESTKL,X
	STA	(ESTK+2,X)
	INC     ESTKL+2,X
	BNE     SW1
	INC     ESTKH+2,X
SW1:	LDA	ESTKH,X
	STA	(ESTK+2,X)
	INX
	INX
	INX
	INX
	RTS
;*
;* STORE VALUE TO LOCAL FRAME OFFSET
;*
SLB:	INC	PCL
	BNE	SLB1
	INC	PCH
SLB1:	; LDY	#$00
	LDA	(PC),Y
        TAY
_SLB:	LDA	ESTKL,X
	STA	(FP),Y
	INX
	INX
        LDY     #$00
	RTS
SLW:	INC	PCL
	BNE	SLW1
	INC	PCH
SLW1:	; LDY	#$00
	LDA	(PC),Y
        TAY
_SLW:	LDA	ESTKL,X
	STA	(FP),Y
	INY
	LDA	ESTKH,X
	STA	(FP),Y
	INX
	INX
        LDY     #$00
	RTS
;*
;* STORE VALUE TO LOCAL FRAME OFFSET WITHOUT POPPING STACK
;*
DLB:	INC	PCL
	BNE	DLB1
	INC	PCH
DLB1:	; LDY	#$00
	LDA	(PC),Y
        TAY
_DLB:	LDA	ESTKL,X
	STA	(FP),Y
        LDY     #$00
	RTS
DLW:	INC	PCL
	BNE	DLW1
	INC	PCH
DLW1:	LDY	#$00
	LDA	(PC),Y
        TAY
_DLW:	LDA	ESTKL,X
	STA	(FP),Y
	INY
	LDA	ESTKH,X
	STA	(FP),Y
        LDY     #$00
	RTS
;*
;* STORE VALUE TO ABSOLUTE ADDRESS
;*
SAB:	INC	PCL
	BNE	SAB1
	INC	PCH
SAB1:	; LDY	#$00
	LDA	(PC),Y
	STA	TMPL
	INC	PCL
	BNE	SAB2
	INC	PCH
SAB2:	LDA	(PC),Y
	STA	TMPH
_SAB:	LDA	ESTKL,X
	STA	(TMP),Y
	INX
	INX
	RTS
SAW:	INC	PCL
	BNE	SAW1
	INC	PCH
SAW1:	; LDY	#$00
	LDA	(PC),Y
	STA	TMPL
	INC	PCL
	BNE	SAW2
	INC	PCH
SAW2:	LDA	(PC),Y
	STA	TMPH
	LDA	ESTKL,X
	STA	(TMP),Y
	INY
	LDA	ESTKH,X
	STA	(TMP),Y
	INX
	INX
        DEY
	RTS
;*
;* STORE VALUE TO ABSOLUTE ADDRESS WITHOUT POPPING STACK
;*
DAB:	INC	PCL
	BNE	DAB1
	INC	PCH
DAB1:	; LDY	#$00
	LDA	(PC),Y
	STA	TMPL
	INC	PCL
	BNE	DAB2
	INC	PCH
DAB2:	LDA	(PC),Y
	STA	TMPH
	LDA	ESTKL,X
	STA	(TMP),Y
	RTS
DAW:	INC	PCL
	BNE	DAW1
	INC	PCH
DAW1:	; LDY	#$00
	LDA	(PC),Y
	STA	TMPL
	INC	PCL
	BNE	DAW2
	INC	PCH
DAW2:	LDA	(PC),Y
	STA	TMPH
	LDA	ESTKL,X
	STA	(TMP),Y
	INY
	LDA	ESTKH,X
	STA	(TMP),Y
        DEY
	RTS
;*
;* COMPARES
;*
ISEQ:	LDY     #$00
        LDA     ESTKL,X
        CMP     ESTKL+2,X
        BNE     ISEQ1
        LDA     ESTKH,X
        CMP     ESTKH+2,X
        BNE     ISEQ1
        DEY
ISEQ1:	STY     ESTKL+2,X
        STY     ESTKH+2,X
        INX
        INX
        LDY     #$00
        RTS
ISNE:	LDY     #$FF
        LDA     ESTKL,X
        CMP     ESTKL+2,X
        BNE     ISNE1
        LDA     ESTKH,X
        CMP     ESTKH+2,X
        BNE     ISNE1
        INY
ISNE1:	STY     ESTKL+2,X
        STY     ESTKH+2,X
        INX
        INX
        LDY     #$00
        RTS
ISGE:	LDY     #$00
	LDA     ESTKL+2,X
	CMP     ESTKL,X
	LDA     ESTKH+2,X
	SBC     ESTKH,X
	BVC	ISGE1
	EOR	#$80
ISGE1:	BMI     ISGE2
	DEY
ISGE2:	STY     ESTKL+2,X
        STY     ESTKH+2,X
        INX
        INX
        LDY     #$00
        RTS
ISGT:	LDY     #$00
	LDA     ESTKL,X
	CMP     ESTKL+2,X
	LDA     ESTKH,X
	SBC     ESTKH+2,X
	BVC	ISGT1
	EOR	#$80
ISGT1:	BPL     ISGT2
	DEY
ISGT2:	STY     ESTKL+2,X
        STY     ESTKH+2,X
        INX
        INX
        LDY     #$00
        RTS
ISLE:	LDY     #$00
	LDA     ESTKL,X
	CMP     ESTKL+2,X
	LDA     ESTKH,X
	SBC     ESTKH+2,X
	BVC	ISLE1
	EOR	#$80
ISLE1:	BMI     ISLE2
	DEY
ISLE2:	STY     ESTKL+2,X
        STY     ESTKH+2,X
        INX
        INX
        LDY     #$00
        RTS
ISLT:	LDY     #$00
	LDA     ESTKL+2,X
	CMP     ESTKL,X
	LDA     ESTKH+2,X
	SBC     ESTKH,X
	BVC	ISLT1
	EOR	#$80
ISLT1:	BPL     ISLT2
	DEY
ISLT2:	STY     ESTKL+2,X
        STY     ESTKH+2,X
        INX
        INX
        LDY     #$00
        RTS
;*
;* BRANCHES
;*
BRTRU:	INX
        INX
	LDA	ESTKH-2,X
	ORA	ESTKL-2,X
	BEQ	NOBRNCH
JUMP:	STX	ESP
	LDY	#$01
	LDA	(PC),Y
	TAX
	INY
	LDA	(PC),Y
	STX	PCL
	STA	PCH
	LDX	ESP
	PLA
	PLA
        LDY     #$00
	JMP	FETCHOP
BRFLS:	INX
        INX
	LDA	ESTKH-2,X
	ORA	ESTKL-2,X
	BEQ	JUMP
NOBRNCH: LDA	#$02
	CLC
	ADC	PCL
	STA	PCL
	BCC	NOBRA1
	INC	PCH
NOBRA1:	RTS
BREQ:	INX
	INX
;	INX
;	INX
	LDA	ESTKL-2,X
	CMP	ESTKL,X
	BNE	NOBRNCH
	LDA	ESTKL-2,X
	CMP	ESTKL,X
	BEQ	JUMP
	BNE	NOBRNCH
BRNE:	INX
	INX
;	INX
;	INX
	LDA	ESTKL-2,X
	CMP	ESTKL,X
	BNE	JUMP
	LDA	ESTKL-2,X
	CMP	ESTKL,X
	BEQ	NOBRNCH
	BNE	JUMP
BRGT:	INX
	INX
;	INX
;	INX
	LDA	ESTKL-2,X
	CMP	ESTKL,X
	LDA	ESTKH-2,X
	SBC	ESTKH,X
	BMI	JUMP
	BPL	NOBRNCH
BRLT:	INX
	INX
;	INX
;	INX
	LDA	ESTKL,X
	CMP	ESTKL-2,X
	LDA	ESTKH,X
	SBC	ESTKH-2,X
	BMI	JUMP
	BPL	NOBRNCH
;*
;* INDIRECT JUMP TO ADDRESS
;*
IJMP:	PLA
	PLA
	LDA	ESTKL,X
	STA	PCL
	LDA	ESTKH,X
	STA	PCH
	INX
	INX
	JMP	FETCHOP
;*
;* CALL INTO ABSOLUTE ADDRESS
;*
CALL:	INC	PCL
	BNE	CALL1
	INC	PCH
CALL1:	; LDY	#$00
	LDA	(PC),Y
	STA	TMPL
	INC	PCL
	BNE	CALL2
	INC	PCH
CALL2:	LDA	(PC),Y
	STA	TMPH
        LDA	PCH
	PHA
	LDA	PCL
	PHA
	JSR     _IJMPTMP
	PLA
	STA	PCL
	PLA
	STA	PCH
	LDY	#$00
	RTS
;*
;* INDIRECT CALL INTO ADDRESS WITH PARAM COUNT
;*
ICAL:	INC	PCL
	BNE	ICAL1
	INC	PCH
ICAL1:	; LDY	#$00
        LDA     (PC),Y
        STA     TMPL
        TXA
        LSR             ; CARRY BETTER BE 0
	ADC	TMPL
	ASL
	TAY
	LDA	PCH
	PHA
	LDA     PCL
	PHA
	LDA	ESTKL,Y
	STA	TMPL
	LDA	ESTKH,Y
	STA	TMPH
	JSR     _IJMPTMP
	LDA     ESTKL,X
	STA     ESTKL+2,X
	LDA     ESTKH,X
	STA     ESTKH+2,X
	INX
	INX
	PLA
	STA	PCL
	PLA
	STA	PCH
	LDY     #$00
	RTS
;*
;* ENTER FUNCTION WITH FRAME SIZE AND PARAM COUNT
;*
ENTER:	; LDY     #$00
        INC     PCL
        BNE     ENTER1
        INC     PCH
ENTER1:	LDA     (PC),Y
        STA     FRMSZ
        INC     PCL
        BNE     ENTER2
        INC	PCH
ENTER2:	LDA	(PC),Y
	STA	NPARMS
_ENTER:	LDA     FPL
        PHA
        SEC
        SBC     FRMSZ
        STA     FPL
        LDA     FPH
        PHA
        SBC     #$00
        STA     FPH
        LDY	#$01
        PLA
        STA     (FP),Y
        DEY
        PLA
        STA     (FP),Y
        LDA     NPARMS
        BEQ     ENTER4
        ASL
        TAY
        INY
ENTER3:	LDA     ESTKH,X
        STA     (FP),Y
        DEY
        LDA     ESTKL,X
        STA     (FP),Y
        DEY
        INX
        INX
        DEC     TMPL
        BNE     ENTER3
ENTER4:	LDY     #$00
	RTS
;*
;* LEAVE FUNCTION
;*
LEAVE:	PLA
	PLA
_LEAVE:	LDY     #$00
        LDA     (FP),Y
        INY
        PHA
        LDA     (FP),Y
        STA     FPH
        PLA
        STA     FPL
 	LDY     #$00
        RTS
RET:	PLA
	PLA
        RTS
;***********************************************
;*
;* CALL 6502 ROUTINE
;* ROMCALL(AREG, XREG, YREG, STATUS, ADDR)
;*
;***********************************************
REGVALS: DS	4
C0000:	PHP
	LDA	ESTKL,X
	STA	TMPL
	LDA	ESTKH,X
	INX
	INX
	STA	TMPH
	LDA	ESTKL,X
	INX
	INX
	PHA
	LDA	ESTKL,X
	INX
	INX
	TAY
	LDA	ESTKL+2,X
	PHA
	LDA	ESTKL,X
	INX
	INX
	STX	ESP
	TAX
	PLA
	PLP
	JSR     _IJMPTMP
	PHP
	STA	REGVALS+0
	STX	REGVALS+1
	STY	REGVALS+2
	PLA
	STA	REGVALS+3
	LDX	ESP
	LDA     #<REGVALS
	LDY     #>REGVALS
	STA     ESTKL,X
	STY     ESTKH,X
	PLP
	LDY     #$00
	RTS
;***********************************************
;*
;* CALL PRODOS
;* SYSCALL(CMD, PARAMS)
;*
;***********************************************
C0001:	LDA	ESTKL,X
	LDY	ESTKH,X
	STA	PARAMS
	STY	PARAMS+1
	INX
	INX
	LDA	ESTKL,X
	STA	CMD
	STX	ESP
	JSR	$BF00
CMD:	DB	00
PARAMS:	DW	0000
	LDX	ESP
	STA	ESTKL,X
	LDY	#$00
	STY	ESTKH,X
	RTS
;***********************************************
;*
;* SET MEMORY TO VALUE
;* MEMSET(VALUE, ADDR, SIZE)
;*
;***********************************************
C0002:	LDY	ESTKL,X
        INY
        INC     ESTKH,X
SETMEM: DEY
	BNE	:+
	DEC	ESTKH,X
	BEQ	MEMEXIT
:	LDA	ESTKL+4,X
	STA	(ESTK+2,X)
	INC	ESTKL+2,X
	BNE	:+
	INC	ESTKH+2,X
:	DEY
	BNE	:+
	DEC	ESTKH,X
	BEQ	MEMEXIT
:	LDA	ESTKH+4,X
	STA	(ESTK+2,X)
	INC	ESTKL+2,X
	BNE	SETMEM
	INC	ESTKH+2,X
	BNE	SETMEM
MEMEXIT: INX
	INX
	INX
	INX
	RTS
;***********************************************
;*
;* COPY MEMORY
;*
;* MEMCPY(SRCADDR, DSTADDR, SIZE)
;*
;***********************************************
C0003:	LDY	ESTKL,X
    BNE     :+
	LDA	ESTKH,X
	BEQ	MEMEXIT
:	LDA	ESTKH+4,X
	CMP	ESTKH+2,X
	BCC	REVCPY
	BNE	FORCPY
	LDA	ESTKL+4,X
	CMP	ESTKL+2,X
	BCS	FORCPY
REVCPY:				; REVERSE DIRECTION COPY
;	CLC
	TYA
	ADC	ESTKL+2,X
	STA	ESTKL+2,X
	LDA	ESTKH,X
	ADC	ESTKH+2,X
	STA	ESTKH+2,X
	CLC
	TYA
	ADC	ESTKL+4,X
	STA	ESTKL+4,X
	LDA	ESTKH,X
	ADC	ESTKH+4,X
	STA	ESTKH+4,X
        INC     ESTKH,X
REVCPYLP:
	LDA	ESTKL+2,X
	BNE	:+
	DEC	ESTKH+2,X
:	DEC	ESTKL+2,X
	LDA	ESTKL+4,X
	BNE	:+
	DEC	ESTKH+4,X
:	DEC	ESTKL+4,X
	LDA	(ESTK+4,X)
	STA	(ESTK+2,X)
	DEY
	BNE	REVCPYLP
	DEC	ESTKH,X
	BNE	REVCPYLP
	BEQ	MEMEXIT
FORCPY: INC     ESTKH,X
FORCPYLP:
	LDA	(ESTK+4,X)
	STA	(ESTK+2,X)
	INC	ESTKL+2,X
	BNE	:+
	INC	ESTKH+2,X
:	INC	ESTKL+4,X
	BNE	:+
	INC	ESTKH+4,X
:	DEY
	BNE	FORCPYLP
	DEC	ESTKH,X
	BNE	FORCPYLP
	BEQ	MEMEXIT
;***********************************************
;*
;* CHAR OUT
;* COUT(CHAR)
;*
;***********************************************
C0004:	LDA	ESTKL,X
_COUT:	ORA	#$80
	STX	ESP
	JSR	$FDED
	LDX	ESP
	LDY     #$00
	RTS
;***********************************************
;*
;* CHAR OUT
;* COUT(CHAR)
;*
;***********************************************
C0005:  STX     ESP
        JSR     $FD0C
        LDX     ESP
        DEX
        DEX
        LDY     #$00
        STA     ESTKL,X
        STY     ESTKH,X
        RTS
;***********************************************
;*
;* PRINT STRING
;* PRSTR(STR)
;*
;***********************************************
C0006:	LDA	(ESTK,X)
	STA	TMP
	BEQ	:++
_PRS1:	INC	ESTKL,X
	BNE	:+
	INC	ESTKH,X
:	LDA	(ESTK,X)
	JSR	_COUT
	DEC	TMP
	BNE	_PRS1
:	RTS
;***********************************************
;*
;* READ STRING
;* STR = RDSTR(PROMPTCHAR)
;*
;***********************************************
C0007:  LDA     ESTKL,X
        STA     $33
        STX     ESP
        JSR     $FD6A
        STX     $01FF
        LDX     ESP
        LDA     #$FF
        STA     ESTKL,X
        LDA     #$01
        STA     ESTKH,X
	LDY     #$00
        RTS
