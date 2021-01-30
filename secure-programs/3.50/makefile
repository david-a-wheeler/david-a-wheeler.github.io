#
# Process SGML file.
# Makefile (C) 1999-2002 David A. Wheeler
# Placed under GNU GPL version 2.

# Usual use:
#  (edit away, "make print" to print)
#  make
#
# For distribution, "make; make clean"
# then copy to old/VERSIONNUMBER,
# then send the files on (including the HTML and "old" file).
# using "make distribute" to copy to dwheeler.com, and
# email to Secure-Programs-HOWTO.tar.gz to submit@en.tldp.org
# (was submit@linuxdoc.org, but is no longer.)


# This requires LOTS of tools.  Go to www.linuxdoc.org
# for info on some.  Needs HTMLDOC, lynx, plucker,
# LDP's scripts and such.

disable:
	echo "Do 'make all' to actually do something"

all: Secure-Programs-HOWTO.ps Secure-Programs-HOWTO.txt \
     Secure-Programs-HOWTO.pdf Secure-Programs-HOWTO.rtf \
     Secure-Programs-HOWTO.html \
     Secure-Programs-HOWTO.pdb \
     Secure-Programs-HOWTO/index.html Secure-Programs-HOWTO.tar.gz \
     program.gif \
     Secure-Programs-HOWTO-all-html.tar.gz
	chmod -R a+rX *

print: Secure-Programs-HOWTO.ps
	lpr Secure-Programs-HOWTO.ps

clean:
	rm -fr Secure-Programs-HOWTO.aux \
               Secure-Programs-HOWTO.junk Secure-Programs-HOWTO.log \
               Secure-Programs-HOWTO.dvi Secure-Programs-HOWTO.tex

really_clean: clean
	/bin/rm -fr Secure-Programs-HOWTO.ps Secure-Programs-HOWTO.txt \
		    Secure-Programs-HOWTO.pdf Secure-Programs-HOWTO.rtf
	/bin/rmdir Secure-Programs

gzip: Secure-Programs-HOWTO.tar.gz

pdf: Secure-Programs-HOWTO.pdf

postscript: Secure-Programs-HOWTO.ps

# The "html" target creates the chunked version.
html: Secure-Programs-HOWTO/index.html

Secure-Programs-HOWTO.html: Secure-Programs-HOWTO.sgml
	jade -t sgml -i html -V nochunks -d ldp.dsl\#html Secure-Programs-HOWTO.sgml 2>&1 > Secure-Programs-HOWTO.html | sed 's/^jade://'
	cp -p dwheeler2003b.jpg Secure-Programs-HOWTO


Secure-Programs-HOWTO.ps: Secure-Programs-HOWTO.pdf
	# No-op; PDF generates ps too.
	touch Secure-Programs-HOWTO.ps

# Secure-Programs-HOWTO.ps: Secure-Programs-HOWTO.sgml dwheeler-book-style.dsl
# 	db2ps -d dwheeler-book-style.dsl Secure-Programs-HOWTO.sgml

Secure-Programs-HOWTO.txt: Secure-Programs-HOWTO.html
	# ./textify < Secure-Programs-HOWTO.sgml > Secure-Programs-HOWTO.txt
	lynx -dump Secure-Programs-HOWTO.html > Secure-Programs-HOWTO.txt

# I used to do this to generate the HTML:
# db2html Secure-Programs-HOWTO.sgml
# but I couldn't control its formatting sufficiently.

Secure-Programs-HOWTO/index.html: Secure-Programs-HOWTO.sgml program.gif
	rm -fr Secure-Programs-HOWTO
	mkdir Secure-Programs-HOWTO
	cp -p *.gif Secure-Programs-HOWTO
	cp -p *.png Secure-Programs-HOWTO
	cd Secure-Programs-HOWTO; jade -t sgml -i html -d ../ldp.dsl\#html ../Secure-Programs-HOWTO.sgml
	cp -p book1-html.orig Secure-Programs-HOWTO/book1.html
	cp -p dwheeler2003b.jpg Secure-Programs-HOWTO

Secure-Programs-HOWTO-all-html.tar.gz: Secure-Programs-HOWTO/index.html \
  program.gif program.png
	rm -f Secure-Programs-HOWTO-all-html.tar.gz
	tar cf Secure-Programs-HOWTO-all-html.tar \
                        Secure-Programs-HOWTO/*
	gzip -9 Secure-Programs-HOWTO-all-html.tar

# I've eliminated all GIFs - now we only have PNGs for the public.
# See http://www.burnallgifs.org


Secure-Programs-HOWTO.tar.gz: Secure-Programs-HOWTO.sgml program.dia makefile
	tar cvf Secure-Programs-HOWTO.tar Secure-Programs-HOWTO.sgml \
	        program.dia program.gif program.png program.eps \
	        dwheeler2003b.jpg \
		dwheeler-book-style.dsl ldp.dsl \
	        ChangeLog makefile textify
	rm -f Secure-Programs-HOWTO.tar.gz
	gzip -9 Secure-Programs-HOWTO.tar
	# gzip -9 -c Secure-Programs-HOWTO.sgml > Secure-Programs-HOWTO.sgml.gz


Secure-Programs-HOWTO.pdf: Secure-Programs-HOWTO.html program.png
	 ./ldp_print --postscript --pdf Secure-Programs-HOWTO.html 

#Secure-Programs-HOWTO.pdf: Secure-Programs-HOWTO.ps program.eps
#	# ps2pdf Secure-Programs-HOWTO.ps Secure-Programs-HOWTO.pdf
#	# # I'd like to use db2pdf directly, but there doesn't seem to be
#	# # a reasonable way to include figures.  .eps isn't imported, and
#	# # DocBook doesn't permit .pdf format (a format I can create
#	# # using epstopdf).
#	# db2pdf -d dwheeler-book-style.dsl Secure-Programs-HOWTO.sgml
#	# docbook2pdf Secure-Programs-HOWTO.sgml
#	# docbook2pdf Secure-Programs-HOWTO.sgml

Secure-Programs-HOWTO.rtf: Secure-Programs-HOWTO.sgml
	# db2rtf Secure-Programs-HOWTO.sgml
	jade -t rtf -d ldp.dsl Secure-Programs-HOWTO.sgml

# Plucker:
Secure-Programs-HOWTO.pdb: Secure-Programs-HOWTO.sgml
	plucker-build -v --stayonhost -M99 --noimages --zlib-compression \
	  --launchable \
	  -H file:/home/dwheeler/dwheeler.com/secure-programs/Secure-Programs-HOWTO/index.html -N "Secure Programming HOWTO" -f Secure-Programs-HOWTO
	mv ${HOME}/.plucker/Secure-Programs-HOWTO.pdb .
	chmod a+r Secure-Programs-HOWTO.pdb


program.pdf: program.eps
	epstopdf program.eps > program.pdf

# There are no makefile rules to convert the master file "program.dia"
# into "program.png" and "program.eps" - you need to use Dia's "Export"
# command to do that.

distribute: clean
	scp -pr * dwheeler@dwheeler.com:/home/dwheeler/WWW/secure-programs


