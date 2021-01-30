%{
/* scan.l -- scanner for Apple C compiler.
   This file is input to lex, which creates a scanner in C.

   This is based on the scanner in
   "Introduction to Compiler Construction in Unix".
*/

#include "y.tab.h"

#ifdef UNIT_TEST

extern int yywrap();

int yynerrs = 0;

main()
{
 int p;

 while ( p = yylex())
   printf("Token: %d yytext: %s\n",p, yytext);
}
#endif

%}

letter	[a-zA-Z_]
digit	[0-9]
letter_or_digit	[a-zA-Z_0-9]
white_space	[ \t\n]
blank	[ \t]
other	.

%%

asm				return ASSEMBLE;
char				return T_CHAR;
int				return T_INT;
\"[^\"]*\"			return STRING;
{letter}{letter_or_digit}*	return Identifier;
{digit}+			return Constant;
{white_space}+			;
{other}				return yytext[0];

%%

