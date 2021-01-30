
# Create the Compiler

OBJECTS = main.o lex.yy.o y.tab.o yywrap.o yyerror.o

compile : $(OBJECTS)
	cc $(OBJECTS)
	mv a.out compile

tests:
	echo Executing test1:
	compile < test1
	echo Executing test2:
	-compile < test2
	echo Executing test3:
	compile < test3

y.tab.h  y.tab.c : acc.y
	yacc -d acc.y

lex.yy.c: scan.l y.tab.h
	lex scan.l

