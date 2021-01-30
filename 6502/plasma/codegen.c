#include <stdio.h>
#include "tokens.h"
#include "codegen.h"

#define SYNC_TOS                {if(opt==2)sync_tos();else if(evalstk_status){evalstk_status=0;printf("\tJSR\t_PUSHYA\n");}}
#define SYNC_YTOS               {if(opt==2)sync_ytos();}
#define SYNC_ATOS               {if(opt==2)sync_atos();}
#define INVALID_YA              {evalstk_status = 0;}
#define VALID_YA                {evalstk_status |= YA_VALID_TOS;}
#define VALID_Y                 {evalstk_status = (evalstk_status | Y_VALID_TOS) & ~A_VALID_TOS;}
#define VALID_A                 {evalstk_status = (evalstk_status | A_VALID_TOS) & ~Y_VALID_TOS;}
#define VALID_TOS               {evalstk_status = 0;}
#define INVALID_TOS             {evalstk_status |= TOS_NEEDS_UPDATE;}
#define INVALID_YTOS            {evalstk_status |= YTOS_NEEDS_UPDATE;}
#define INVALID_ATOS            {evalstk_status |= ATOS_NEEDS_UPDATE;}
#define LOAD_YA                 {if(opt==2){load_ya();}else{if(evalstk_status)printf(";");printf("\tLDA\tESTKL,X\n\tLDY\tESTKH,X\n");}}
#define LOAD_Y                  {if(opt==2){load_y(); }else{if(evalstk_status)printf(";");printf("\tLDY\tESTKH,X\n");}}
#define LOAD_A                  {if(opt==2){load_a(); }else{if(evalstk_status)printf(";");printf("\tLDA\tESTKL,X\n");}}
#define POP_YA                  {if(opt==2){pop_ya(); }else{if(evalstk_status){evalstk_status=0;printf(";\t_PUSHYA\t");}printf("\tJSR\t_PULLYA\n");}}
#define POP_A                   {if(opt==2){pop_a();  }else{if(evalstk_status){evalstk_status=0;printf(";\t_PUSHYA\t");}printf("\tJSR\t_PULLA\n");}}
#define PUSH_YA                 {if(opt==2){vsp-=2;}evalstk_status=TOS_NEEDS_UPDATE|YA_VALID_TOS;}
#define ATOS_NEEDS_UPDATE       (1 << 0)
#define YTOS_NEEDS_UPDATE       (1 << 1)
#define TOS_NEEDS_UPDATE        (ATOS_NEEDS_UPDATE|YTOS_NEEDS_UPDATE)
#define A_VALID_TOS             (1 << 2)
#define Y_VALID_TOS             (1 << 3)
#define YA_VALID_TOS            (A_VALID_TOS|Y_VALID_TOS)

int evalstk_status = 0;
int vsp = 0;
int opt = 0;
int outflags = 0;

void pushya(void)
{
	PUSH_YA
}
void sync_tos(void)
{
        if (evalstk_status & ATOS_NEEDS_UPDATE)
        {
                if (!(evalstk_status & A_VALID_TOS))
                        printf("Bad ATOS sync!\n");
                printf("\tSTA\tESTKL%+d,X\n", vsp);
                evalstk_status &= ~ATOS_NEEDS_UPDATE;
        }
        if (evalstk_status & YTOS_NEEDS_UPDATE)
        {
                if (!(evalstk_status & Y_VALID_TOS))
                        printf("Bad YTOS sync!\n");
                printf("\tSTY\tESTKH%+d,X\n", vsp);
                evalstk_status &= ~YTOS_NEEDS_UPDATE;
        }
}
void sync_ytos(void)
{
        if (evalstk_status & YTOS_NEEDS_UPDATE)
        {
                if (!(evalstk_status & Y_VALID_TOS))
                        printf("Bad YTOS sync!\n");
                printf("\tSTY\tESTKH%+d,X\n", vsp);
                evalstk_status &= ~YTOS_NEEDS_UPDATE;
        }
}
void sync_atos(void)
{
        if (evalstk_status & ATOS_NEEDS_UPDATE)
        {
                if (!(evalstk_status & A_VALID_TOS))
                        printf("Bad ATOS sync!\n");
                printf("\tSTA\tESTKL%+d,X\n", vsp);
                evalstk_status &= ~ATOS_NEEDS_UPDATE;
        }
}
void load_ya(void)
{
        if (!(evalstk_status & A_VALID_TOS))
        {
                printf("\tLDA\tESTKL%+d,X\n", vsp);
                evalstk_status |= A_VALID_TOS;
        }
        if (!(evalstk_status & Y_VALID_TOS))
        {
                printf("\tLDY\tESTKH%+d,X\n", vsp);
                evalstk_status = Y_VALID_TOS;
        }
}
void load_y(void)
{
        if (!(evalstk_status & Y_VALID_TOS))
        {
                printf("\tLDY\tESTKH%+d,X\n", vsp);
                evalstk_status = Y_VALID_TOS;
        }
}
void load_a(void)
{
        if (!(evalstk_status & A_VALID_TOS))
        {
                printf("\tLDA\tESTKL%+d,X\n", vsp);
                evalstk_status |= A_VALID_TOS;
        }
}
void pop_ya(void)
{
        if (!(evalstk_status & A_VALID_TOS))
        {
                printf("\tLDA\tESTKL%+d,X\n", vsp);
        }
        if (!(evalstk_status & Y_VALID_TOS))
        {
                printf("\tLDY\tESTKH%+d,X\n", vsp);
        }
        vsp += 2;
        evalstk_status = 0;
}
void pop_a(void)
{
        if (!(evalstk_status & A_VALID_TOS))
                printf("\tLDA\tESTKL%+d,X\n", vsp);
        vsp += 2;
        evalstk_status = 0;
}
int optimization(int newopt)
{
        int oldopt = opt;
        opt = newopt;
        vsp = 0;
        INVALID_YA;
        return (oldopt);
}
static int vsp_saved;
void vsp_save(void)
{
        vsp_saved = vsp;
}
void vsp_restore(void)
{
        vsp = vsp_saved;
}
void emit_flags(int flags)
{
	outflags = flags;
}
void emit_header(void)
{
		if (outflags & EDASM)
		        printf("; EDASM COMPATIBLE OUTPUT\n");
		else
		        printf("\t.INCLUDE\t\"interp6502.s\"\n");
}
void emit_comment(char *s)
{
		if (!(outflags & EDASM))
		        printf("\t\t\t\t\t; %s\n", s);
}
void emit_asm(char *s)
{
	printf("%s\n", s);
}
void emit_idlocal(char *name, int value)
{
		if (!(outflags & EDASM))
		        printf("\t\t\t\t\t; %s = %d\n", name, value);
}
void emit_idglobal(int value, int size, char *name)
{
        if (size == 0)
		{
				if (outflags & EDASM)
         		       printf("D%04d: EQU * ; %s\n", value, name);
				else
         		       printf("D%04d:\t\t\t\t\t; %s\n", value, name);
		}
        else
		{
				if (outflags & EDASM)
		                printf("D%04d: DS %d ; %s\n", value, size, name);
				else
		                printf("D%04d:\tDS\t%d\t\t\t; %s\n", value, size, name);
		}
}
void emit_idfunc(int value, char *name)
{
		if (outflags & EDASM)
		        printf("C%04d: EQU * ; %s()\n", value, name);
		else
		        printf("C%04d:\t\t\t\t\t; %s()\n", value, name);
}
void emit_idconst(char *name, int value)
{
		if (!(outflags & EDASM))
		        printf("\t\t\t\t\t; %s = %d\n", name, value);
}
int emit_data(int vartype, int consttype, long constval, int constsize)
{
        int datasize, i;
        char *str;
        if (consttype == 0)
        {
                datasize = constsize;
                printf("\tDS\t$%02X\n", constsize);
        }
        else if (consttype == STRING_TYPE)
        {
                datasize = constsize;
                str = (char *)constval;
                printf("\tDB\t$%02X\n", --constsize);
                while (constsize-- > 0)
                {
                        printf("\tDB\t$%02X", *str++);
                        for (i = 0; i < 7; i++)
                        {
                                if (constsize-- > 0)
                                        printf(",$%02X", *str++);
                                else
                                        break;
                        }
                        printf("\n");
                }
        }
        else if (consttype == TAG_TYPE)
        {
        		datasize = 2;
                if (constval & 0x8000)
                        printf("\tDW\tC%04ld\t; C%04ld\n", constval & 0x7FFF, constval & 0x7FFF);
                else
                        printf("\tDW\tD%04ld\t; D%04ld\n", constval, constval);
        }
        else
        {
                if (vartype == WORD_TYPE)
                {
                        datasize = 2;
                        printf("\tDW\t$%04lX\n", constval & 0xFFFF);
                }
                else
                {
                        datasize = 1;
                        printf("\tDB\t$%02lX\n", constval & 0xFF);
                }
        }
        return (datasize);
}
void emit_codetag(int tag)
{
        if (opt > 0)
        {
                SYNC_TOS;
                INVALID_YA;
        }
		if (outflags & EDASM)
		        printf("C%04d: EQU *\n", tag);
		else
		        printf("C%04d:\n", tag);
}
void emit_const(int cval)
{
        if (opt > 0)
        {
                int lo = cval & 0xFF;
                int hi = (cval >> 8) & 0xFF;
                SYNC_TOS;
                printf("\tLDA\t#$%02X\n", lo);
                if (hi == lo)
                        printf("\tTAY\n");
                else
                        printf("\tLDY\t#$%02X\n", hi);
                PUSH_YA;
        }
        else
        {
                if (cval == 0)
                        printf("\tDB\t$00\t\t\t; ZERO\n");
                else if (cval > 0 && cval < 256)
                        printf("\tDB\t$2A,$%02X\t\t\t; CB\t%d\n", cval, cval);
                else
                        printf("\tDB\t$2C,$%02X,$%02X\t\t; CW\t%d\n", cval&0xFF,(cval>>8)&0xFF, cval);
        }
}
void emit_lb(void)
{
        if (opt == 2)
        {
                SYNC_TOS;
                printf("\tLDA\t(ESTK%+d,X)\n", vsp);
                printf("\tLDY\t#$00\n");
                VALID_YA;
                INVALID_TOS;
        }
        else if (opt == 1)
        {
                SYNC_TOS;
//                printf("\tLDA\t(ESTKL,X)\n");
//                printf("\tLDY\t#$00\n");
//                printf("\tSTA\tESTKL,X\n");
//                printf("\tSTY\tESTKH,X\n");
                printf("\tJSR\tLB\n");
        }
        else
                printf("\tDB\t$60\t\t\t; LB\n");
}
void emit_lw(void)
{
        if (opt == 2)
        {
                SYNC_TOS;
                printf("\tLDA\t(ESTK%+d,X)\n", vsp);
                printf("\tINC\tESTKL%+d,X\n", vsp);
                printf("\tBNE\t:+\n");
                printf("\tINC\tESTKH%+d,X\n", vsp);
                printf(":\tTAY\n");
                printf("\tLDA\t(ESTK%+d,X)\n", vsp);
//                printf("\tSTY\tESTKL%+d,X\n", vsp);
                printf("\tSTA\tESTKH%+d,X\n", vsp);
                printf("\tTYA\n");
                INVALID_YA;
                VALID_A;
                INVALID_ATOS;
        }
        else if (opt == 1)
        {
                SYNC_TOS;
                printf("\tJSR\tLW\n");
        }
        else
                printf("\tDB\t$62\t\t\t; LW\n");
}
void emit_llb(int index)
{
        if (opt == 2)
        {
                SYNC_TOS;
                printf("\tLDY\t#$%02X\n", index);
                printf("\tLDA\t(FP),Y\n");
                printf("\tLDY\t#$00\n");
                PUSH_YA;
        }
        else if (opt == 1)
        {
                SYNC_TOS;
                printf("\tLDY\t#$%02X\n", index);
                printf("\tJSR\t_LLB\n");
        }
        else
                printf("\tDB\t$64,$%02X\t\t\t; LLB\t%d\n", index, index);
}
void emit_llw(int index)
{
        if (opt == 2)
        {
                SYNC_TOS;
                vsp -= 2;
                printf("\tLDY\t#$%02X\n", index+1);
                printf("\tLDA\t(FP),Y\n");
                printf("\tDEY\n");
                printf("\tSTA\tESTKH%+d,X\n", vsp);
                printf("\tLDA\t(FP),Y\n");
                VALID_A;
                INVALID_ATOS;
        }
        else if (opt == 1)
        {
                SYNC_TOS;
                printf("\tLDY\t#$%02X\n", index);
                printf("\tJSR\t_LLW\n");
        }
        else
                printf("\tDB\t$66,$%02X\t\t\t; LLW\t%d\n", index, index);
}
void emit_lab(int tag)
{
        if (opt > 0)
        {
                SYNC_TOS;
                printf("\tLDA\tD%04d\n", tag);
                printf("\tLDY\t#$00\n");
                PUSH_YA;
        }
        else
		{
				if (outflags & EDASM)
		                printf("\tDB\t$68,>D%04d,<D%04d\t; LAB\tD%04d\n", tag, tag, tag);
				else
		                printf("\tDB\t$68,<D%04d,>D%04d\t; LAB\tD%04d\n", tag, tag, tag);
		}
}
void emit_law(int tag)
{
        if (opt > 0)
        {
                SYNC_TOS;
                printf("\tLDA\tD%04d\n",   tag);
                printf("\tLDY\tD%04d+1\n", tag);
                PUSH_YA;
        }
        else
		{
				if (outflags & EDASM)
		                printf("\tDB\t$6A,>D%04d,<D%04d\t; LAW\tD%04d\n", tag, tag, tag);
				else
		                printf("\tDB\t$6A,<D%04d,>D%04d\t; LAW\tD%04d\n", tag, tag, tag);
		}
}
void emit_sb(void)
{
        if (opt == 2)
        {
                POP_A;
                printf("\tSTA\t(ESTK%+d,X)\n", vsp);
                vsp += 2;
        }
        else if (opt == 1)
        {
                SYNC_TOS;
                printf("\tJSR\tSB\n");
        }
        else
                printf("\tDB\t$70\t\t\t; SB\n");
}
void emit_sw(void)
{
        if (opt == 2)
        {
                POP_YA;
                printf("\tSTA\t(ESTK%+d,X)\n", vsp);
                printf("\tINC\tESTKL%+d,X\n", vsp);
                printf("\tBNE\t:+\n");
                printf("\tINC\tESTKH%+d,X\n", vsp);
                printf(":\tTYA\n");
                printf("\tSTA\t(ESTK%+d,X)\n", vsp);
                vsp += 2;
        }
        else if (opt == 1)
        {
                SYNC_TOS;
                printf("\tJSR\tSW\n");
        }
        else
                printf("\tDB\t$72\t\t\t; SW\n");
}
void emit_slb(int index)
{
        if (opt == 2)
        {
                POP_A;
                printf("\tLDY\t#$%02X\n", index);
                printf("\tSTA\t(FP),Y\n");
        }
        else if (opt == 1)
        {
                SYNC_TOS;
                printf("\tLDY\t#$%02X\n", index);
                printf("\tJSR\t_SLB\n");
        }
        else
                printf("\tDB\t$74,$%02X\t\t\t; SLB\t%d\n", index, index);
}
void emit_slw(int index)
{
        if (opt == 2)
        {
                SYNC_ATOS;
                LOAD_Y;
                printf("\tTYA\n");
                printf("\tLDY\t#$%02X\n", index+1);
                printf("\tSTA\t(FP),Y\n");
                printf("\tDEY\n");
                printf("\tLDA\tESTKL%+d,X\n", vsp);
                printf("\tSTA\t(FP),Y\n");
                INVALID_YA;
                vsp += 2;
        }
        else if (opt == 1)
        {
                SYNC_TOS;
                printf("\tLDY\t#$%02X\n", index);
                printf("\tJSR\t_SLW\n");
        }
        else
                printf("\tDB\t$76,$%02X\t\t\t; SLW\t%d\n", index, index);
}
void emit_dlb(int index)
{
        if (opt == 2)
        {
                SYNC_YTOS;
                LOAD_A;
                printf("\tLDY\t#$%02X\n", index);
                printf("\tSTA\t(FP),Y\n");
                VALID_A;
        }
        else if (opt == 1)
        {
                SYNC_TOS;
                printf("\tLDY\t#$%02X\n", index);
                printf("\tLDA\tESTKL,X\n");
                printf("\tSTA\t(FP),Y\n");
        }
        else
                printf("\tDB\t$6C,$%02X\t\t\t; DLB\t%d\n", index, index);
}
void emit_dlw(int index)
{
        if (opt == 2)
        {
                SYNC_ATOS;
                LOAD_Y;
                printf("\tTYA\n");
                printf("\tLDY\t#$%02X\n", index+1);
                printf("\tSTA\t(FP),Y\n");
                printf("\tDEY\n");
                printf("\tLDA\tESTKL%+d,X\n", vsp);
                printf("\tSTA\t(FP),Y\n");
                VALID_A;
        }
        else if (opt == 1)
        {
                SYNC_TOS;
                printf("\tLDY\t#$%02X\n", index);
                printf("\tLDA\tESTKL,X\n");
                printf("\tSTA\t(FP),Y\n");
                printf("\tINY\n");
                printf("\tLDA\tESTKH,X\n");
                printf("\tSTA\t(FP),Y\n");
//                printf("\tJSR\t_DLW\n");
        }
        else
                printf("\tDB\t$6E,$%02X\t\t\t; DLW\t%d\n", index, index);
}
void emit_sab(int tag)
{
        if (opt > 0)
        {
                POP_A;
                printf("\tSTA\tD%04d\n", tag);
        }
        else
		{
				if (outflags & EDASM)
		                printf("\tDB\t$78,>D%04d,<D%04d\t; SAB\tD%04d\n", tag, tag, tag);
				else
		                printf("\tDB\t$78,<D%04d,>D%04d\t; SAB\tD%04d\n", tag, tag, tag);
		}
}
void emit_saw(int tag)
{
        if (opt > 0)
        {
                POP_YA;
                printf("\tSTA\tD%04d\n", tag);
                printf("\tSTY\tD%04d+1\n", tag);
        }
        else
		{
				if (outflags & EDASM)
		                printf("\tDB\t$7A,>D%04d,<D%04d\t; SAW\tD%04d\n", tag, tag, tag);
				else
		                printf("\tDB\t$7A,<D%04d,>D%04d\t; SAW\tD%04d\n", tag, tag, tag);
		}
}
void emit_dab(int tag)
{
        if (opt > 0)
        {
                LOAD_A;
                printf("\tSTA\tD%04d\n", tag);
        }
        else
		{
				if (outflags & EDASM)
		                printf("\tDB\t$7C,>D%04d,<D%04d\t; DAB\tD%04d\n", tag, tag, tag);
				else
		                printf("\tDB\t$7C,<D%04d,>D%04d\t; DAB\tD%04d\n", tag, tag, tag);
		}
}
void emit_daw(int tag)
{
        if (opt > 0)
        {
                LOAD_YA;
                printf("\tSTA\tD%04d\n", tag);
                printf("\tSTY\tD%04d+1\n", tag);
        }
        else
		{
				if (outflags & EDASM)
		                printf("\tDB\t$7E,>D%04d,<D%04d\t; DAW\tD%04d\n", tag, tag, tag);
				else
		                printf("\tDB\t$7E,<D%04d,>D%04d\t; DAW\tD%04d\n", tag, tag, tag);
		}
}
void emit_localaddr(int index)
{
        if (opt == 2)
        {
                SYNC_TOS;
                vsp -= 2;
                printf("\tLDA\t#$%02X\n", index);
                printf("\tCLC\n");
                printf("\tADC\tFPL\n");
                printf("\tSTA\tESTKL%+d,X\n", vsp);
                printf("\tLDA\t#$00\n");
                printf("\tADC\tFPH\n");
                printf("\tSTA\tESTKH%+d,X\n", vsp);
                INVALID_YA;
        }
        else if (opt == 1)
        {
                SYNC_TOS;
                printf("\tLDA\t#$%02X\n", index);
                printf("\tJSR\t_LLA\n");
        }
        else
                printf("\tDB\t$28,$%02X\t\t\t; LLA\t%d\n", index, index);
}
void emit_globaladdr(int tag, int type)
{
        if (opt > 0)
        {
                SYNC_TOS;
                printf("\tLDA\t#<D%04d\n", tag);
                printf("\tLDY\t#>D%04d\n", tag);
                PUSH_YA;
        }
        else
        {
                if (type & FUNC_TYPE)
				{
						if (outflags & EDASM)
        		                printf("\tDB\t$26,>C%04d,<C%04d\t; LAA\tC%04d\n", tag, tag, tag);
						else
        		                printf("\tDB\t$26,<C%04d,>C%04d\t; LAA\tC%04d\n", tag, tag, tag);
				}
                else
				{
						if (outflags & EDASM)
		                        printf("\tDB\t$26,>D%04d,<D%04d\t; LAA\tD%04d\n", tag, tag, tag);
						else
		                        printf("\tDB\t$26,<D%04d,>D%04d\t; LAA\tD%04d\n", tag, tag, tag);
				}
        }
}
void emit_globaladdrofst(int tag, int ofst, int type)
{
        if (opt > 0)
        {
                SYNC_TOS;
                printf("\tLDA\t#<D%04d+%d\n", tag, ofst);
                printf("\tLDY\t#>D%04d+%d\n", tag, ofst);
                PUSH_YA;
        }
        else
        {
                if (type & FUNC_TYPE)
				{
						if (outflags & EDASM)
		                        printf("\tDB\t$26,>C%04d+%d,<C%04d+%d\t; LAA\tC%04d+%d\n", tag, ofst, tag, ofst, tag, ofst);
						else
		                        printf("\tDB\t$26,<(C%04d+%d),>(C%04d+%d)\t; LAA\tC%04d+%d\n", tag, ofst, tag, ofst, tag, ofst);
				}
                else
				{
						if (outflags & EDASM)
		                        printf("\tDB\t$26,>D%04d+%d,<D%04d+%d\t; LAA\tD%04d+%d\n", tag, ofst, tag, ofst, tag, ofst);
						else
		                        printf("\tDB\t$26,<(D%04d+%d),>(D%04d+%d)\t; LAA\tD%04d+%d\n", tag, ofst, tag, ofst, tag, ofst);
				}
        }
}
void emit_indexbyte(void)
{
        if (opt == 2)
        {
                SYNC_YTOS;
                LOAD_A;
                printf("\tCLC\n");
                printf("\tADC\tESTKL%+d,X\n", vsp + 2);
                printf("\tSTA\tESTKL%+d,X\n", vsp + 2);
                printf("\tLDA\tESTKH%+d,X\n", vsp);
                printf("\tADC\tESTKH%+d,X\n", vsp + 2);
                printf("\tSTA\tESTKH%+d,X\n", vsp + 2);
                INVALID_YA;
                vsp += 2;
        }
        else if (opt == 1)
        {
                SYNC_TOS;
                printf("\tJSR\tIDXB\n");
        }
        else
                printf("\tDB\t$2E\t\t\t; IDXB\n");
}
void emit_indexword(void)
{
        if (opt == 2)
        {
                SYNC_YTOS;
                LOAD_A;
                printf("\tASL\n");
                printf("\tROL\tESTKH%+d,X\n", vsp);
                printf("\tCLC\n");
                printf("\tADC\tESTKL%+d,X\n", vsp + 2);
                printf("\tSTA\tESTKL%+d,X\n", vsp + 2);
                printf("\tLDA\tESTKH%+d,X\n", vsp);
                printf("\tADC\tESTKH%+d,X\n", vsp + 2);
                printf("\tSTA\tESTKH%+d,X\n", vsp + 2);
                INVALID_YA;
                vsp += 2;
        }
        else if (opt == 1)
        {
                SYNC_TOS;
                printf("\tJSR\tIDXW\n");
        }
        else
                printf("\tDB\t$1E\t\t\t; IDXW\n");
}
void emit_brfls(int tag)
{
        if (opt > 0)
        {
//                SYNC_YTOS;
//                LOAD_A;
//                printf("\tORA\tESTKH%+d,X\n", vsp);
                POP_YA;
                printf("\tCMP\t#$00\n");
                printf("\tBNE\t:+\n");
                printf("\tCPY\t#$00\n");
                printf("\tBNE\t:+\n");
                printf("\tJMP\tC%04d\n", tag);
                printf(":\n");
                INVALID_YA;
        }
        else
		{
				if (outflags & EDASM)
		                printf("\tDB\t$4C,>C%04d,<C%04d\t; BRFLS\tC%04d\n", tag, tag, tag);
				else
		                printf("\tDB\t$4C,<C%04d,>C%04d\t; BRFLS\tC%04d\n", tag, tag, tag);
		}
}
void emit_brtru(int tag)
{
        if (opt > 0)
        {
//                SYNC_YTOS;
//                LOAD_A;
//                printf("\tORA\tESTKH%+d,X\n", vsp);
                POP_YA;
                printf("\tCMP\t#$00\n");
                printf("\tBNE\t:+\n");
                printf("\tCPY\t#$00\n");
                printf("\tBEQ\t:++\n");
                printf(":\tJMP\tC%04d\n", tag);
                printf(":\n");
                INVALID_YA;
        }
        else
		{
				if (outflags & EDASM)
		                printf("\tDB\t$4E,>C%04d,<C%04d\t; BRTRU\tC%04d\n", tag, tag, tag);
				else
		                printf("\tDB\t$4E,<C%04d,>C%04d\t; BRTRU\tC%04d\n", tag, tag, tag);
		}
}
void emit_jump(int tag)
{
        if (opt > 0)
        {
                SYNC_TOS;
                printf("\tJMP\tC%04d\n", tag);
                INVALID_YA;
        }
        else
		{
				if (outflags & EDASM)
		                printf("\tDB\t$50,>C%04d,<C%04d\t; JUMP\tC%04d\n", tag, tag, tag);
				else
		                printf("\tDB\t$50,<C%04d,>C%04d\t; JUMP\tC%04d\n", tag, tag, tag);
		}
}
void emit_breq(int tag)
{
        if (opt == 2)
        {
                POP_YA;
                printf("\tCMP\tESTKL%+d,X\n", vsp);
                printf("\tBNE\t:+\n");
                printf("\tTYA\n");
                printf("\tCMP\tESTKH%+d,X\n", vsp);
                printf("\tBNE\t:+\n");
                printf("\tJMP\tC%04d\n", tag);
                printf(":\n");
                INVALID_YA;
//                vsp += 2;
        }
        else if (opt == 1)
        {
                POP_YA;
//                printf("\tINX\n\tINXn");
                printf("\tCMP\tESTKL,X\n");
                printf("\tBNE\t:+\n");
                printf("\tTYA\n");
                printf("\tCMP\tESTKH,X\n");
                printf("\tBNE\t:+\n");
                printf("\tJMP\tC%04d\n", tag);
                printf(":\n");
        }
        else
		{
				if (outflags & EDASM)
		                printf("\tDB\t$3C,>C%04d,<C%04d\t; BREQ\tC%04d\n", tag, tag, tag);
				else
		                printf("\tDB\t$3C,<C%04d,>C%04d\t; BREQ\tC%04d\n", tag, tag, tag);
		}
}
void emit_brne(int tag)
{
        if (opt == 2)
        {
                POP_YA;
                printf("\tCMP\tESTKL%+d,X\n", vsp);
                printf("\tBNE\t:+\n");
                printf("\tTYA\n");
                printf("\tCMP\tESTKH%+d,X\n", vsp);
                printf("\tBEQ\t:++\n");
                printf(":\tJMP\tC%04d\n", tag);
                printf(":\n");
                INVALID_YA;
//                vsp += 2;
        }
        else if (opt == 1)
        {
                POP_YA;
//                printf("\tINX\n\tINXn");
                printf("\tCMP\tESTKL,X\n");
                printf("\tBNE\t:+\n");
                printf("\tTYA\n");
                printf("\tCMP\tESTKH,X\n");
                printf("\tBEQ\t:++\n");
                printf(":\tJMP\tC%04d\n", tag);
                printf(":\n");
        }
        else
		{
				if (outflags & EDASM)
		                printf("\tDB\t$3E,>C%04d,<C%04d\t; BRNE\tC%04d\n", tag, tag, tag);
				else
		                printf("\tDB\t$3E,<C%04d,>C%04d\t; BRNE\tC%04d\n", tag, tag, tag);
		}
}
void emit_brlt(int tag)
{
        if (opt == 2)
        {
                SYNC_TOS;
                printf("\tLDA\tESTKL%+d,X\n", vsp + 2);
                printf("\tCMP\tESTKL%+d,X\n", vsp);
                printf("\tLDA\tESTKH%+d,X\n", vsp + 2);
                printf("\tSBC\tESTKH%+d,X\n", vsp);
                printf("\tBPL\t:+\n");
                printf("\tJMP\tC%04d\n", tag);
                printf(":\n");
                INVALID_YA;
                vsp += 2;
        }
        else if (opt == 1)
        {
                SYNC_TOS;
//                printf("\tINX\n\tINX\n");
                printf("\tINX\n\tINX\n");
                printf("\tLDA\tESTKL,X\n");
                printf("\tCMP\tESTKL-2,X\n");
                printf("\tLDA\tESTKH,X\n");
                printf("\tSBC\tESTKH-2,X\n");
                printf("\tBPL\t:+\n");
                printf("\tJMP\tC%04d\n", tag);
                printf(":\n");
        }
        else
		{
				if (outflags & EDASM)
		                printf("\tDB\t$38,>C%04d,<C%04d\t; BRLT\tC%04d\n", tag, tag, tag);
				else
		                printf("\tDB\t$38,<C%04d,>C%04d\t; BRLT\tC%04d\n", tag, tag, tag);
		}
}
void emit_brgt(int tag)
{
        if (opt == 2)
        {
                POP_YA;
                printf("\tCMP\tESTKL%+d,X\n", vsp);
                printf("\tTYA\n");
                printf("\tSBC\tESTKH%+d,X\n", vsp);
                printf("\tBPL\t:+\n");
                printf("\tJMP\tC%04d\n", tag);
                printf(":\n");
                INVALID_YA;
//                vsp += 2;
        }
        else if (opt == 1)
        {
                SYNC_TOS;
//                printf("\tINX\n\tINX\n");
                printf("\tINX\n\tINX\n");
                printf("\tLDA\tESTKL-2,X\n");
                printf("\tCMP\tESTKL,X\n");
                printf("\tLDA\tESTKH-2,X\n");
                printf("\tSBC\tESTKH,X\n");
                printf("\tBPL\t:+\n");
                printf("\tJMP\tC%04d\n", tag);
                printf(":\n");
        }
        else
		{
				if (outflags & EDASM)
		                printf("\tDB\t$3A,>C%04d,<C%04d\t; BRGT\tC%04d\n", tag, tag, tag);
				else
		                printf("\tDB\t$3A,<C%04d,>C%04d\t; BRGT\tC%04d\n", tag, tag, tag);
		}
}
void emit_call(int tag, int cparams)
{
        if (opt == 2)
        {
                SYNC_TOS;
                if (vsp < 0)
                {
                        printf("\tTXA\n\tPHA\n");
                        printf("\tSEC\n\tSBC\t#%d\n", -vsp);
                        printf("\tTAX\n");
                        (tag & 0x8000) ? printf("\tJSR\tD%04d\n", tag & 0x7FFF) : printf("\tJSR\tC%04d\n", tag);
                        printf("\tPLA\n\tTAX\n");
                }
                else
                {
                        (tag & 0x8000) ? printf("\tJSR\tD%04d\n", tag & 0x7FFF) : printf("\tJSR\tC%04d\n", tag);
                        printf("\tINX\n\tINX\n");
                }
                vsp += cparams*2 - 2;
                INVALID_YA;
        }
        else if (opt == 1)
        {
                SYNC_TOS;
                printf("\tJSR\tC%04d\n", tag);
        }
        else
		{
				if (outflags & EDASM)
		                (tag & 0x8000) ? printf("\tDB\t$54,>D%04d,<D%04d\t; CALL\tD%04d\n", tag&0x7FFF, tag&0x7FFF, tag&0x7FFF)
        		                       : printf("\tDB\t$54,>C%04d,<C%04d\t; CALL\tC%04d\n", tag, tag, tag);
				else
		                (tag & 0x8000) ? printf("\tDB\t$54,<D%04d,>D%04d\t; CALL\tD%04d\n", tag&0x7FFF, tag&0x7FFF, tag&0x7FFF)
        		                       : printf("\tDB\t$54,<C%04d,>C%04d\t; CALL\tC%04d\n", tag, tag, tag);
		}
}
void emit_ical(int cparams)
{
        if (opt == 2)
        {
                SYNC_TOS;
                printf("\tLDA\tESTKL%+d,X\n", vsp+cparams*2);
                printf("\tLDY\tESTKH%+d,X\n", vsp+cparams*2);
                printf("\tSTA\tTMPL\n");
                printf("\tSTY\tTMPH\n");
                if (vsp < 0)
                {
                        printf("\tTXA\n\tPHA\n");
                        printf("\tSEC\n\tSBC\t#%d\n" , -vsp);
                        printf("\tTAX\n");
                        printf("\tJSR\t_IJMPTMP\n");
                        printf("\tPLA\n\tTAX\n");
                }
                else
                        printf("\tJSR\t_IJMPTMP\n");
                vsp += cparams*2;
                printf("\tLDA\tESTKL%+d,X\n", vsp-2);
                printf("\tLDY\tESTKH%+d,X\n", vsp-2);
                VALID_YA;
                INVALID_TOS;
        }
        else if (opt == 1)
        {
                SYNC_TOS;
                printf("\tLDA\tESTKL%+d,X\n", cparams*2);
                printf("\tLDY\tESTKH%+d,X\n", cparams*2);
                printf("\tSTA\tTMPL\n");
                printf("\tSTY\tTMPH\n");
                printf("\tJSR\t_IJMPTMP\n");
                printf("\tJSR\t_PULLYA\n");
                printf("\tINX\n\tINX\n");
                printf("\tJSR\t_PUSHYA\n");
        }
        else
                printf("\tDB\t$56,$%02X\t\t\t; ICAL\t%d\n", cparams, cparams);
}
void emit_leave(int framesize)
{
        if (framesize > 2)
        {
                if (opt == 2)
                {
                        SYNC_TOS;
                        printf("\tDEX\n\tDEX\n\tJMP\t_LEAVE\n");
                        INVALID_YA;
                }
                else if (opt == 1)
                {
		                SYNC_TOS;
                        printf("\tJMP\t_LEAVE\n");
                }
                else
                        printf("\tDB\t$5A\t\t\t; LEAVE\n");
        }
        else
        {
                if (opt == 2)
                {
                        SYNC_TOS;
                        printf("\tDEX\n\tDEX\n\tRTS\n");
                        INVALID_YA;
                }
                else if (opt == 1)
                {
		                SYNC_TOS;
                        printf("\tRTS\n");
                }
                else
                        printf("\tDB\t$5C\t\t\t; RET\n");
        }
}
void emit_def(int defopt)
{
        opt = defopt;
        if (opt == 0)
                printf("\tJSR\tINTERP\n");
}
void emit_enter(int framesize, int cparams)
{
        if (framesize > 2)
        {
                if (opt > 0)
                {
                        printf("\tLDA\t#%d\n", framesize);
                        printf("\tSTA\tFRMSZ\n");
                        printf("\tLDA\t#%d\n", cparams);
                        printf("\tSTA\tNPARMS\n");
                        printf("\tJSR\t_ENTER\n");
                        INVALID_YA;
                }
                else
                        printf("\tDB\t$58,$%02X,$%02X\t\t; ENTER\t%d,%d\n", framesize, cparams, framesize, cparams);
        }
}
void emit_start(void)
{
        printf("START:\tJSR\tINTERP\n");
        INVALID_YA;
}
void emit_exit(void)
{
        if (opt > 0)
        {
                SYNC_TOS;
                printf("\tJMP\tEXIT\n");
                INVALID_YA;
        }
        else
                printf("\tDB\t$5E\t\t\t; EXIT\n");
}
void emit_dup(void)
{
        if (opt == 2)
        {
                SYNC_TOS;
                LOAD_YA;
                PUSH_YA;
        }
        else if (opt == 1)
                printf("\tJSR\tDUP\n");
        else
                printf("\tDB\t$32\t\t\t; DUP\n");
}
void emit_over(void)
{
        if (opt == 2)
        {
                SYNC_TOS;
                printf("\tLDA\tESTKL%+d,X\n", vsp+2);
                printf("\tLDY\tESTKH%+d,X\n", vsp+2);
                PUSH_YA;
        }
        else if (opt == 1)
        {
                SYNC_TOS;
                printf("\tJSR\tOVER\n");
        }
        else
                printf("\tDB\t$34\t\t\t; OVER\n");
}
void emit_drop(void)
{
        if (opt == 2)
        {
                vsp += 2;
                INVALID_YA;
        }
        else if (opt == 1)
        {
                if (evalstk_status)
                {
                	evalstk_status = 0;
	                printf("\t\t\t\t\t; DROP\n");
	            }
                else
	                printf("\tINX\t\t\t\t; DROP\n\tINX\n");
	    }
        else
                printf("\tDB\t$30\t\t\t; DROP\n");
}
int emit_unaryop(int op)
{
        switch (op)
        {
                case NEG_TOKEN:
                        if (opt == 2)
                        {
                                SYNC_TOS;
                                printf("\tLDA\t#$00\n");
                                printf("\tSEC\n");
                                printf("\tSBC\tESTKL%+d,X\n", vsp);
                                printf("\tSTA\tESTKL%+d,X\n", vsp);
                                printf("\tLDA\t#$00\n");
                                printf("\tSBC\tESTKH%+d,X\n", vsp);
                                printf("\tTAY\n");
                                VALID_Y;
                                INVALID_YTOS;
                        }
                        else if (opt == 1)
                        {
				                SYNC_TOS;
                                printf("\tJSR\tNEG\n");
                        }
                        else
                                printf("\tDB\t$10\t\t\t; NEG\n");
                        break;
                case COMP_TOKEN:
                        if (opt == 2)
                        {
                                LOAD_YA;
                                printf("\tEOR\t#$FF\n");
                                printf("\tSTA\tESTKL%+d,X\n", vsp);
                                printf("\tTYA");
                                printf("\tEOR\t#$FF\n");
                                printf("\tTAY\n");
                                VALID_Y;
                                INVALID_YTOS;
                        }
                        else if (opt == 1)
                        {
				                SYNC_TOS;
                                printf("\tJSR\tCOMP\n");
                        }
                        else
                                printf("\tDB\t$12\t\t\t; COMP\n");
                        break;
                case LOGIC_NOT_TOKEN:
                        if (opt == 2)
                        {
                                SYNC_YTOS;
                                LOAD_A;
                                printf("\tLDY\t#$00\n");
                                printf("\tORA\tESTKH%+d,X\n", vsp);
                                printf("\tBNE\t:+\n");
                                printf("\tDEY\n");
                                printf(":\tTYA\n");
                                VALID_YA;
                                INVALID_YTOS;
                        }
                        else if (opt == 1)
                        {
				                SYNC_TOS;
                                printf("\tJSR\tNOT\n");
                        }
                        else
                                printf("\tDB\t$20\t\t\t; NOT\n");
                        break;
                case INC_TOKEN:
                        if (opt == 2)
                        {
                                SYNC_TOS;
                                printf("\tINC\tESTKL%+d,X\n", vsp);
                                printf("\tBNE\t:+\n");
                                printf("\tINC\tESTKH%+d,X\n", vsp);
                                printf(":\n");
                                INVALID_YA;
                        }
                        else if (opt == 1)
                        {
				                SYNC_TOS;
                                printf("\tJSR\tINCR\n");
                        }
                        else
                                printf("\tDB\t$0C\t\t\t; INCR\n");
                        break;
                case DEC_TOKEN:
                        if (opt == 2)
                        {
                                SYNC_TOS;
                                LOAD_A;
                                printf("\tCMP\t#$00\n");
                                printf("\tBNE\t:+\n");
                                printf("\tDEC\tESTKH%+d,X\n", vsp);
                                printf(":\tDEC\tESTKL%+d,X\n", vsp);
                                INVALID_YA;
                        }
                        else if (opt == 1)
                        {
				                SYNC_TOS;
                                printf("\tJSR\tDECR\n");
                        }
                        else
                                printf("\tDB\t$0E\t\t\t; DECR\n");
                        break;
                case BPTR_TOKEN:
                        emit_lb();
                        break;
                case WPTR_TOKEN:
                        emit_lw();
                        break;
                default:
                        printf("emit_unaryop(%c) ? \n", op  & 0x7F);
                        return (0);
        }
        return (1);
}
int emit_op(t_token op)
{
        switch (op)
        {
                case MUL_TOKEN:
                        if (opt == 2)
                        {
                                SYNC_TOS;
                                printf("\tTXA\n\tPHA\n");
                                printf("\tSEC\n\tSBC\t#%d\n", -vsp);
                                printf("\tTAX\n");
                                printf("\tJSR\tMUL\n");
                                printf("\tPLA\n\tTAX\n");
                                INVALID_YA;
                                vsp += 2;
                        }
                        else if (opt == 1)
                        {
				                SYNC_TOS;
                                printf("\tJSR\tMUL\n");
                        }
                        else
                                printf("\tDB\t$06\t\t\t; MUL\n");
                        break;
                case DIV_TOKEN:
                        if (opt == 2)
                        {
                                SYNC_TOS;
                                printf("\tTXA\n\tPHA\n");
                                printf("\tSEC\n\tSBC\t#%d\n", -vsp);
                                printf("\tTAX\n");
                                printf("\tJSR\tDIV\n");
                                printf("\tPLA\n\tTAX\n");
                                INVALID_YA;
                                vsp += 2;
                        }
                        else if (opt == 1)
                        {
				                SYNC_TOS;
                                printf("\tJSR\tDIV\n");
                        }
                        else
                                printf("\tDB\t$08\t\t\t; DIV\n");
                        break;
                case MOD_TOKEN:
                        if (opt == 2)
                        {
                                SYNC_TOS;
                                printf("\tTXA\n\tPHA\n");
                                printf("\tSEC\n\tSBC\t#%d\n", -vsp);
                                printf("\tTAX\n");
                                printf("\tJSR\tMOD\n");
                                printf("\tPLA\n\tTAX\n");
                                INVALID_YA;
                                vsp += 2;
                        }
                        else if (opt == 1)
                        {
				                SYNC_TOS;
                                printf("\tJSR\tMOD\n");
                        }
                        else
                                printf("\tDB\t$0A\t\t\t; MOD\n");
                        break;
                case ADD_TOKEN:
                        if (opt == 2)
                        {
                                POP_YA;
                                printf("\tCLC\n");
                                printf("\tADC\tESTKL%+d,X\n", vsp);
                                printf("\tSTA\tESTKL%+d,X\n", vsp);
                                printf("\tTYA\n");
                                printf("\tADC\tESTKH%+d,X\n", vsp);
                                printf("\tTAY\n");
                                VALID_Y;
                                INVALID_YTOS;
                        }
                        else if (opt == 1)
                        {
				                SYNC_TOS;
                                printf("\tJSR\tADD\n");
                        }
                        else
                                printf("\tDB\t$02\t\t\t; ADD\n");
                        break;
                case SUB_TOKEN:
                        if (opt == 2)
                        {
//                                SYNC_TOS;
//                                printf("\tLDA\tESTKL%+d,X\n", vsp+2);
//                                printf("\tSEC\n");
//                                printf("\tSBC\tESTKL%+d,X\n", vsp);
//                                printf("\tSTA\tESTKL%+d,X\n", vsp+2);
//                                printf("\tLDA\tESTKH%+d,X\n", vsp+2);
//                                printf("\tSBC\tESTKH%+d,X\n", vsp);
//                                printf("\tTAY\n");
//                                VALID_Y;
//                                INVALID_YTOS;
//                                vsp += 2;
                                POP_YA;
                                printf("\tEOR\t#$FF\n");
                                printf("\tSEC\n");
                                printf("\tADC\tESTKL%+d,X\n", vsp);
                                printf("\tSTA\tESTKL%+d,X\n", vsp);
                                printf("\tTYA\n");
                                printf("\tEOR\t#$FF\n");
                                printf("\tADC\tESTKH%+d,X\n", vsp);
                                printf("\tTAY\n");
                                VALID_Y;
                                INVALID_YTOS;
                        }
                        else if (opt == 1)
                        {
				                SYNC_TOS;
                                printf("\tJSR\tSUB\n");
                        }
                        else
                                printf("\tDB\t$04\t\t\t; SUB\n");
                        break;
                case SHL_TOKEN:
                        if (opt == 2)
                        {
                                POP_A;
                                printf("\tTAY\n");
                                printf("\tBEQ\t:++\n");
                                printf(":\tASL\tESTKL%+d,X\n", vsp);
                                printf("\tROL\tESTKH%+d,X\n", vsp);
                                printf("\tDEY\n");
                                printf("\tBNE\t:-\n");
                                printf(":\n");
                                INVALID_YA;
                        }
                        else if (opt == 1)
                        {
				                SYNC_TOS;
                                printf("\tJSR\tSHL\n");
                        }
                        else
                                printf("\tDB\t$1A\t\t\t; SHL\n");
                        break;
                case SHR_TOKEN:
                        if (opt == 2)
                        {
                                POP_A;
                                printf("\tTAY\n");
                                printf("\tBEQ\t:++\n");
                                printf("\tLDA\tESTKH%+d,X\n", vsp);
                                printf(":\tCMP\t#$80\n");
                                printf("\tROR\n");
                                printf("\tROR\tESTKL%+d,X\n", vsp);
                                printf("\tDEY\n");
                                printf("\tBNE\t:-\n");
                                printf("\tSTA\tESTKH%+d,X\n", vsp);
                                printf(":\n");
                                INVALID_YA;
                        }
                        else if (opt == 1)
                        {
				                SYNC_TOS;
                                printf("\tJSR\tSHR\n");
                        }
                        else
                                printf("\tDB\t$1C\t\t\t; SHR\n");
                        break;
                case AND_TOKEN:
                        if (opt == 2)
                        {
                                POP_YA;
                                printf("\tAND\tESTKL%+d,X\n", vsp);
                                printf("\tSTA\tESTKL%+d,X\n", vsp);
                                printf("\tTYA\n");
                                printf("\tAND\tESTKH%+d,X\n", vsp);
                                printf("\tTAY\n");
                                VALID_Y;
                                INVALID_YTOS;
                        }
                        else if (opt == 1)
                        {
				                SYNC_TOS;
                                printf("\tJSR\tBAND\n");
                        }
                        else
                                printf("\tDB\t$14\t\t\t; BAND\n");
                        break;
                case OR_TOKEN:
                        if (opt == 2)
                        {
                                POP_YA;
                                printf("\tORA\tESTKL%+d,X\n", vsp);
                                printf("\tSTA\tESTKL%+d,X\n", vsp);
                                printf("\tTYA\n");
                                printf("\tORA\tESTKH%+d,X\n", vsp);
                                printf("\tTAY\n");
                                VALID_Y;
                                INVALID_YTOS;
                        }
                        else if (opt == 1)
                        {
				                SYNC_TOS;
                                printf("\tJSR\tIOR\n");
                        }
                        else
                                printf("\tDB\t$16\t\t\t; IOR\n");
                        break;
                case EOR_TOKEN:
                        if (opt == 2)
                        {
                                POP_YA;
                                printf("\tEOR\tESTKL%+d,X\n", vsp);
                                printf("\tSTA\tESTKL%+d,X\n", vsp);
                                printf("\tTYA\n");
                                printf("\tEOR\tESTKH%+d,X\n", vsp);
                                printf("\tTAY\n");
                                VALID_Y;
                                INVALID_YTOS;
                        }
                        else if (opt == 1)
                        {
				                SYNC_TOS;
                                printf("\tJSR\tXOR\n");
                        }
                        else
                                printf("\tDB\t$18\t\t\t; XOR\n");
                        break;
                case EQ_TOKEN:
                        if (opt == 2)
                        {
                                POP_YA;
                                printf("\tCMP\tESTKL%+d,X\n", vsp);
                                printf("\tBNE\t:+\n");
                                printf("\tTYA\n");
                                printf("\tLDY\t#$FF\n");
                                printf("\tCMP\tESTKH%+d,X\n", vsp);
                                printf("\tBEQ\t:++\n");
                                printf(":\tLDY\t#$00\n");
                                printf(":\tTYA\n");
                                VALID_YA;
                                INVALID_TOS;
                        }
                        else if (opt == 1)
                        {
				                SYNC_TOS;
                                printf("\tJSR\tISEQ\n");
                        }
                        else
                                printf("\tDB\t$40\t\t\t; ISEQ\n");
                        break;
                case NE_TOKEN:
                        if (opt == 2)
                        {
                                POP_YA;
                                printf("\tCMP\tESTKL%+d,X\n", vsp);
                                printf("\tBNE\t:+\n");
                                printf("\tTYA\n");
                                printf("\tLDY\t#$00\n");
                                printf("\tCMP\tESTKH%+d,X\n", vsp);
                                printf("\tBEQ\t:++\n");
                                printf(":\tLDY\t#$FF\n");
                                printf(":\tTYA\n");
                                VALID_YA;
                                INVALID_TOS;
                        }
                        else if (opt == 1)
                        {
				                SYNC_TOS;
                                printf("\tJSR\tISNE\n");
                        }
                        else
                                printf("\tDB\t$42\t\t\t; ISNE\n");
                        break;
                case GE_TOKEN:
                        if (opt == 2)
                        {
                                SYNC_TOS;
                                printf("\tLDY\t#$FF\n");
                                printf("\tLDA\tESTKL%+d,X\n", vsp + 2);
                                printf("\tCMP\tESTKL%+d,X\n", vsp);
                                printf("\tLDA\tESTKH%+d,X\n", vsp + 2);
                                printf("\tSBC\tESTKH%+d,X\n", vsp);
                                printf("\tBPL\t:+\n");
                                printf("\tINY\n");
                                printf(":\tTYA\n");
                                VALID_YA;
                                INVALID_TOS;
                                vsp += 2;
                        }
                        else if (opt == 1)
                        {
				                SYNC_TOS;
                                printf("\tJSR\tISGE\n");
                        }
                        else
                                printf("\tDB\t$48\t\t\t; ISGE\n");
                        break;
                case LT_TOKEN:
                        if (opt == 2)
                        {
                                SYNC_TOS;
                                printf("\tLDY\t#$00\n");
                                printf("\tLDA\tESTKL%+d,X\n", vsp + 2);
                                printf("\tCMP\tESTKL%+d,X\n", vsp);
                                printf("\tLDA\tESTKH%+d,X\n", vsp + 2);
                                printf("\tSBC\tESTKH%+d,X\n", vsp);
                                printf("\tBPL\t:+\n");
                                printf("\tDEY\n");
                                printf(":\tTYA\n");
                                VALID_YA;
                                INVALID_TOS;
                                vsp += 2;
                        }
                        else if (opt == 1)
                        {
				                SYNC_TOS;
                                printf("\tJSR\tISLT\n");
                        }
                        else
                                printf("\tDB\t$46\t\t\t; ISLT\n");
                        break;
                case GT_TOKEN:
                        if (opt == 2)
                        {
                                POP_YA;
                                printf("\tCMP\tESTKL%+d,X\n", vsp);
                                printf("\tTYA\n");
                                printf("\tLDY\t#$00\n");
                                printf("\tSBC\tESTKH%+d,X\n", vsp);
                                printf("\tBPL\t:+\n");
                                printf("\tDEY\n");
                                printf(":\tTYA\n");
                                VALID_YA;
                                INVALID_TOS;
                        }
                        else if (opt == 1)
                        {
				                SYNC_TOS;
                                printf("\tJSR\tISGT\n");
                        }
                        else
                                printf("\tDB\t$44\t\t\t; ISGT\n");
                        break;
                case LE_TOKEN:
                        if (opt == 2)
                        {
                                POP_YA;
                                printf("\tCMP\tESTKL%+d,X\n", vsp);
                                printf("\tTYA\n");
                                printf("\tLDY\t#$FF\n");
                                printf("\tSBC\tESTKH%+d,X\n", vsp);
                                printf("\tBPL\t:+\n");
                                printf("\tINY\n");
                                printf(":\tTYA\n");
                                VALID_YA;
                                INVALID_TOS;
                        }
                        else if (opt == 1)
                        {
				                SYNC_TOS;
                                printf("\tJSR\tISLE\n");
                        }
                        else
                                printf("\tDB\t$4A\t\t\t; ISLE\n");
                        break;
                case LOGIC_OR_TOKEN:
                        if (opt == 2)
                        {
                                POP_YA;
                                printf("\tORA\tESTKL%+d,X\n", vsp);
                                printf("\tBNE\t:+\n");
                                printf("\tTYA\n");
                                printf("\tORA\tESTKH%+d,X\n", vsp);
                                printf("\tBEQ\t:++\n");
                                printf(":\tLDY\t#$FF\n");
                                printf("\tTYA\n");
                                printf(":\n");
                                VALID_YA;
                                INVALID_TOS;
                        }
                        else if (opt == 1)
                        {
				                SYNC_TOS;
                                printf("\tJSR\tLOR\n");
                        }
                        else
                                printf("\tDB\t$22\t\t\t; LOR\n");
                        break;
                case LOGIC_AND_TOKEN:
                        if (opt == 2)
                        {
                                POP_YA;
                                printf("\tCMP\t#$00\n");
                                printf("\tBNE\t:+\n");
                                printf("\tCPY\t#$00\n");
                                printf("\tBEQ\t:+++\n");
                                printf(":\tLDY\t#$FF\n");
                                printf("\tLDA\tESTKL%+d,X\n", vsp);
                                printf("\tBNE\t:+\n");
                                printf("\tLDA\tESTKH%+d,X\n", vsp);
                                printf("\tBNE\t:+\n");
                                printf("\tINY\n");
                                printf(":\tTYA\n");
                                printf(":\n");
                                VALID_YA;
                                INVALID_TOS;
                        }
                        else if (opt == 1)
                        {
				                SYNC_TOS;
                                printf("\tJSR\tLAND\n");
                        }
                        else
                                printf("\tDB\t$24\t\t\t; LAND\n");
                        break;
                default:
                        return (0);
        }
        return (1);
}
