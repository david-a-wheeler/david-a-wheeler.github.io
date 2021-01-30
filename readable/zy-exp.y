%{
#include <stdio.h>
/* Formal specification of ZY-Expressions syntax, in bison/yacc form.
 by David A. Wheeler.

 Released under the "MIT license":
 Copyright (c) 2005 David A. Wheeler

 Permission is hereby granted, free of charge, to any person obtaining a
 copy of this software and associated documentation files (the "Software"),
 to deal in the Software without restriction, including without limitation
 the rights to use, copy, modify, merge, publish, distribute, sublicense,
 and/or sell copies of the Software, and to permit persons to whom the
 Software is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
 THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR
 OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
 ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
 OTHER DEALINGS IN THE SOFTWARE.


 */
void process(char *s);
void yyerror(char *s);
int yydebug=1;
%}

%token NUMBER SYMBOL STRING NAME

/* Define precedence and assocation direction */
%left GE LE EQ NE '>' '<' '='
%left '+' '-' '&'
%left '*' '/'
/* You could argue to reverse the next two, or change to %left UMINUS */
%right '^'
%nonassoc UMINUS

%start formula

%%


expr : NAME '(' list ')'  /* Function call, creates (..) in s-expr */
       | NAME infixop NAME   /* Well-known Infix op in middle */
       | NAME NAME NAME   /* Infix op in middle - anything else. */
       | '(' NAME ')' maybe_call /* Parens control precedence, that's it. */
                                 /* If there's a call, then (..) in s-expr */
       | '{' list '}'     /* block, creates (..) in s-expr */
       | NAME             /* Eeek - how do we know we're done? */
       | NUMBER | SYMBOL | STRING
       | '-' expr %prec UMINUS  /* Support unary minus */
       ;

maybe_call : /* empty */ | '(' list ')' ; /* parameters of computed function */

list : /* empty */ | non_empty_list ;

nonempty_list: expr
	   | nonempty_list ',' expr ;

infixop: '+' | '-' | '*' | '/'
          | '<' | '>' | '=' |
          | GE | LE | NE | EQ ;


expr_list: /* empty - zero parameters okay. */
           | nonempty_expr_list ;


%%

void process(char *s) {
    fprintf(stdout, "%s\n", s);
}

void yyerror(char *s) {
    fprintf(stdout, "%s\n", s);
}

int main(void) {
    yyparse();
    return 0;
}
