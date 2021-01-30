# Flawfinder.
# Released under the General Public License (GPL) version 2 or later.
# (C) 2001-2017 David A. Wheeler.

# To change version number, edit this here, the beginning of the
# "flawfinder" script, flawfinder.spec, setup.py, and index.html.
# Then "make test-is-correct" to get the updated version number.
# To distribute, "make distribute && su && make rpm".
# Then use make my_install to install to website image.
# Eventually switch to using DistUtils to autogenerate.

NAME=flawfinder
VERSION=2.0.0
RPM_VERSION=1
VERSIONEDNAME=$(NAME)-$(VERSION)
ARCH=noarch

SAMPLE_DIR=/usr/src/linux-2.2.16

# Flawfinder has traditionally used INSTALL_DIR, INSTALL_DIR_BIN, and
# INSTALL_DIR_MAN.  Here we add support for GNU variables like prefix, etc.;
# users who override the older flawfinder-specific variable names will
# not notice any changes.  We define exec_prefix oddly so we can
# quietly merge these 2 systems:

prefix=/usr/local
INSTALL_DIR=$(prefix)
exec_prefix=$(INSTALL_DIR)
bindir=$(exec_prefix)/bin
INSTALL_DIR_BIN=$(bindir)

datarootdir=$(INSTALL_DIR)/share
mandir=$(datarootdir)/man
man1dir=$(mandir)/man1
INSTALL_DIR_MAN=$(man1dir)

FLEX=flex

# For Cygwin on Windows, set PYTHONEXT=.py
# (EXE=.exe would be needed on some systems, but not for flawfinder)
EXE=
PYTHONEXT=
# EXE=.exe
# PYTHONEXT=.py

# The rpm build command.  "rpmbuild" for rpm version 4.1+
# (e.g., in Red Hat Linux 8), "rpm" for older versions.

RPMBUILD=rpmbuild

DESTDIR=

all: flawfinder.pdf flawfinder.1.gz
	chmod -R a+rX *

# We use the "-p" option of mkdir; some very old Unixes
# might not support this option, but it's a really common option
# and required by SUSv3 (and probably earlier, I haven't checked).
MKDIR_P=mkdir -p

INSTALL_PROGRAM=cp -p
INSTALL_DATA=cp -p

# This installer doesn't install the compiled Python bytecode.
# It doesn't take long to compile the short Python code, so
# it doesn't save much time, and having the source code available
# makes it easier to see what it does.  It also avoids the
# (admittedly rare) problem of bad date/timestamps causing the
# compiled code to override later uncompiled Python code.
install:
	-$(MKDIR_P) $(DESTDIR)$(INSTALL_DIR_BIN)
	$(INSTALL_PROGRAM) flawfinder$(PYTHONEXT) $(DESTDIR)$(INSTALL_DIR_BIN)/flawfinder$(PYTHONEXT)
	-$(MKDIR_P) $(DESTDIR)$(INSTALL_DIR_MAN)
	$(INSTALL_DATA) flawfinder.1 $(DESTDIR)$(INSTALL_DIR_MAN)/flawfinder.1

uninstall:
	rm -f $(DESTDIR)$(INSTALL_DIR_BIN)/flawfinder$(PYTHONEXT)
	rm -f $(DESTDIR)$(INSTALL_DIR_MAN)/flawfinder.1

flawfinder.1.gz: flawfinder.1
	gzip -c9 < flawfinder.1 > flawfinder.1.gz

flawfinder.ps: flawfinder.1
	man -t ./flawfinder.1 > flawfinder.ps

flawfinder.pdf: flawfinder.ps
	ps2pdf flawfinder.ps flawfinder.pdf

# Not built by default, since man2html is not widely available
# and the PDF is prettier.
flawfinder.html: flawfinder.1
	man2html flawfinder.1 | tail -n +3 > flawfinder.html

clean:
	rm -f *.pyc
	rm -f flawfinder-$(VERSION).tar.gz
	rm -f cwe.c cwe
	rm -f *.tar *.exe ./cwe

distribute: clean flawfinder.pdf flawfinder.ps
	chmod -R a+rX *
	mkdir ,tempdir
	cp -p [a-zA-Z]* ,tempdir
	rm -f ,tempdir/*.tar.gz
	rm -f ,tempdir/*.rpm
	# We don't need both "flawfinder" and "flawfinder.py":
	rm -f ,tempdir/flawfinder.py
	mv ,tempdir flawfinder-$(VERSION)
	# Nobody else needs "update" either.
	rm -f ,tempdir/update
	# Don't need compressed version of document.
	rm -f ,tempdir/flawfinder.1.gz
	# Don't include (out of date) index.html
	rm -f ,tempdir/index.html
	tar cvfz flawfinder-$(VERSION).tar.gz flawfinder-$(VERSION)
	chown --reference=. flawfinder-$(VERSION).tar.gz
	rm -fr flawfinder-$(VERSION)

dist: distribute

time:
	echo "Timing the program. First, time taken:"
	time ./flawfinder $(SAMPLE_DIR)/*/*.[ch] > /dev/null
	echo "Lines examined:"
	wc -l $(SAMPLE_DIR)/*/*.[ch] | tail -2

test: flawfinder test.c test2.c
	# Omit time report so that results are always the same textually.
	./flawfinder --omittime test.c test2.c > test-results.txt
	./flawfinder --csv test.c test2.c > test-results.csv
	echo >> test-results.txt
	echo "Testing for no ending newline:" >> test-results.txt
	./flawfinder --omittime no-ending-newline.c | \
	  grep 'Lines analyzed' >> test-results.txt
	./flawfinder --omittime --html --context test.c test2.c > test-results.html
	@echo "Differences from expected results:"
	@diff -u correct-results.txt test-results.txt
	@diff -u correct-results.html test-results.html
	@diff -u correct-results.csv test-results.csv

check: test

# Run "make test-is-correct" if the results are as expected.
test-is-correct: test-results.txt
	mv test-results.txt correct-results.txt
	mv test-results.html correct-results.html

profile:
	/usr/lib/python1.5/profile.py ./flawfinder > profile-results $(SAMPLE_DIR)/*/*.[ch] > profile-results 


rpm: distribute
	chmod -R a+rX *
	cp $(VERSIONEDNAME).tar.gz /usr/src/redhat/SOURCES
	cp flawfinder.spec /usr/src/redhat/SPECS
	cd /usr/src/redhat/SPECS
	$(RPMBUILD) -ba flawfinder.spec
	chmod a+r /usr/src/redhat/RPMS/$(ARCH)/$(VERSIONEDNAME)-$(RPM_VERSION)*.rpm
	chmod a+r /usr/src/redhat/SRPMS/$(VERSIONEDNAME)-$(RPM_VERSION)*.src.rpm
	# cp -p /usr/src/redhat/RPMS/$(ARCH)/$(VERSIONEDNAME)-$(RPM_VERSION)*.rpm .
	# cp -p /usr/src/redhat/RPMS/$(ARCH)/$(VERSIONEDNAME)-$(RPM_VERSION)*.rpm  $(VERSIONEDNAME)-$(RPM_VERSION).noarch.rpm
	cp -p /usr/src/redhat/RPMS/$(ARCH)/$(VERSIONEDNAME)-$(RPM_VERSION)*.rpm  .
	cp -p /usr/src/redhat/SRPMS/$(VERSIONEDNAME)-$(RPM_VERSION)*.src.rpm .
	chown --reference=README *.rpm
	# Install, for testing.  Ignore the "not installed" message here,
	# unless you already installed it; we're just removing any old copies:
	-rpm -e flawfinder
	rpm -ivh /usr/src/redhat/RPMS/$(ARCH)/$(VERSIONEDNAME)-$(RPM_VERSION)*.rpm
	echo "Use rpm -e $(NAME) to remove the package"
	chown --reference=. *.rpm

# This is a developer convenience target, not intended for general use.
my-install: flawfinder.pdf flawfinder.ps test
	cp -p $(VERSIONEDNAME).tar.gz \
	      flawfinder flawfinder.1 makefile \
	      flawfinder.pdf flawfinder.ps ChangeLog \
	      test.c test2.c test-results.txt test-results.html \
	           /home/dwheeler/dwheeler.com/flawfinder/

# This is intended to be a local capability to list CWEs
cwe.c: cwe.l
	$(FLEX) -o cwe.c cwe.l

cwe: cwe.c
	$(CC) -o cwe cwe.c -lfl

show-cwes: cwe
	./cwe < flawfinder | sort -u -V

pylint:
	pylint flawfinder

.PHONY: install clean test check profile test-is-correct rpm \
  uninstall distribute my-install show-cwes pylint

# When I switch to using "DistUtils", I may need to move the MANIFEST.in
# file into a subdirectory (named flawfinder-versionnumber).
# I can then create all the distribution files by just typing:
#  python setup.py bdist_rpm

