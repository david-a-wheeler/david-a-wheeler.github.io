# quoter makefile
# (C) 2002-2009 David A. Wheeler.

# Version number.
VERSION=1.11


# This makefile turns on various options to increase
# execution speed; the trade-off is that it takes more time to compile
# and slightly more disk space.  A fair trade.

CC=gcc -O3

# If you're using lex instead of flex,
# change this to "l" and change how flex is called.
# E.g., "make LEXLIB=l"
# WARNING: If untrusted users can call, make sure your flex alternative
# isn't vulnerable to buffer overflows.
LEXLIB=fl

# NOTE: This uses -i, case-insensitive.
# -Cfe makes it faster, though larger.
# -B makes it faster, but act oddly interactively, so DON'T use -B
LEX=flex -Cfe -i

prefix=/usr/local

# Where to install the binary
# was "BIN=/usr/local/bin"
bindir=$(prefix)/bin

# Set this to ".exe" for Cygnus.
EXE=

INSTALL=install
INSTALL_PROGRAM=$(INSTALL)
INSTALL_DATA=$(INSTALL)

quoter: lex.yy.c
	$(CC) lex.yy.c -o quoter -l$(LEXLIB)

lex.yy.c: quoter.l
	$(LEX) quoter.l

install:
	$(INSTALL_PROGRAM) quoter $(DESTDIR)$(bindir)/quoter$(EXE)

test: quoter test.html
	./quoter < test.html > test_results.html
	@echo "Differences from expected results:"
	@diff -u test_results.html test_expected_results.html
	@echo "Done."

check: test

accept:
	@echo "Accepting test results."
	@cp -p test_results.html test_expected_results.html

clean:
	rm -f quoter quoter.exe

really_clean: clean
	rm -f lex.yy.c

distribute:
	chmod -R a+rX *
	mkdir ,111
	cp -p [a-zA-Z]* ,111
	( cd ,111 ; rm -f *.tar.gz quoter quoter.exe index.html )
	mv ,111 quoter-$(VERSION)
	tar cvfz quoter-$(VERSION).tar.gz quoter-$(VERSION)
	chown --reference=. quoter-$(VERSION).tar.gz
	rm -fr quoter-$(VERSION)

dist: distribute

.PHONY: install test check clean really_clean distribute dist

