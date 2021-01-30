
#include <stdio.h>

extern int yychar;
extern int yylineno;

yyerror(s)
char *s;
{
fprintf(stderr,"%s on %d",s, yylineno);
if ((yychar <= 127) && (yychar > 31))
  fprintf(stderr, " near %c", yychar);

fprintf(stderr,"\n");
}
