
# html2wikipedia makefile
# (C) 2002 David A. Wheeler.

# Version number.
VERSION=1.01

# If you're using lex instead of flex,
# change this to "l" and change how flex is called.
# WARNING: If untrusted users can call, make sure your flex alternative
# isn't vulnerable to buffer overflows.
LEXLIB=fl

# Where to install the binary
BIN=/usr/local/bin

# Set this to ".exe" for Cygnus.
EXE=

# Note: This makefile turns on various options to increase
# execution speed; the trade-off is that it takes more time to compile
# and slightly more disk space.  A fair trade.

html2wikipedia: lex.yy.c
	gcc -O3 lex.yy.c -o html2wikipedia -l$(LEXLIB)

# NOTE: This uses -i, case-insensitive.
# -Cfe makes it faster, though larger.
# -B makes it faster, but act oddly interactively.
lex.yy.c: html2wikipedia.l
	flex -i -Cfe html2wikipedia.l

install:
	cp html2wikipedia $(BIN)/html2wikipedia$(EXE)

test: html2wikipedia test.html
	./html2wikipedia < test.html | less

clean:
	rm -f html2wikipedia

really_clean:
	rm -f lex.yy.c

distribute: clean
	chmod -R a+rX *
	mkdir ,111
	cp -p [a-zA-Z]* ,111
	rm -f ,111/*.tar.gz
	rm -f ,111/html2wikipedia
	mv ,111 html2wikipedia-$(VERSION)
	tar cvfz html2wikipedia-$(VERSION).tar.gz html2wikipedia-$(VERSION)
	chown --reference=. html2wikipedia-$(VERSION).tar.gz
	rm -fr html2wikipedia-$(VERSION)


