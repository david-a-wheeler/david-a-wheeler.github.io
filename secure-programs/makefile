# Process Secure Programming HOWTO Docbook.
# Makefile (C) 1999-2015 David A. Wheeler
# Placed under GNU GPL version 2.

# Usual use: Edit, then "make".
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

# Need ulem.sty.  If not around, use:
#  wget http://ctan.mackichan.com/macros/plain/contrib/misc/ulem.sty

# Eventually may switch to the newer XML tools, but will the HTML single
# pages retain their URLs?!?
# Eventually support Epub and Kindle's mobi; see:
# http://skweez.net/compile-docbook-documents-for-kindle/
# The "ignore" entry forces the viewport to be contiguous, which is required
# for at least Firefox on Android

dollar = $$
FIXUP_HTML = sed -i -e 's/<IMG$(dollar)/<IMG style=\"max-width:90\%\"/' -e 's/<\/title$(dollar)/&><meta name="viewport" content="width=device-width, initial-scale=1.0><meta name="ignore" content="ignore"/i'

all: Secure-Programs-HOWTO.pdf \
     Secure-Programs-HOWTO.html \
     Secure-Programs-HOWTO/index.html
	chmod -R a+rX *

# print: Secure-Programs-HOWTO.ps
#	lpr Secure-Programs-HOWTO.ps

clean:
	rm -fr Secure-Programs-HOWTO.aux \
               Secure-Programs-HOWTO.junk Secure-Programs-HOWTO.log \
               Secure-Programs-HOWTO.dvi Secure-Programs-HOWTO.tex

really_clean: clean
	/bin/rm -fr Secure-Programs-HOWTO.ps Secure-Programs-HOWTO.txt \
		    Secure-Programs-HOWTO.pdf Secure-Programs-HOWTO.rtf
	/bin/rmdir Secure-Programs

gzip: Secure-Programs-HOWTO.tar.gz


# Auto-create an index.

HTML.index: Secure-Programs-HOWTO.sgml secure-programs-style.dsl
	@echo GENERATING: Document index
	jade -t sgml -i html -V nochunks -V html-index -d secure-programs-style.dsl\#html Secure-Programs-HOWTO.sgml > /dev/null

index.sgml: HTML.index
	collateindex.pl -f -o index.sgml.new HTML.index
	cmp index.sgml.new index.sgml || mv index.sgml.new index.sgml

html: Secure-Programs-HOWTO.html
Secure-Programs-HOWTO.html: Secure-Programs-HOWTO.sgml index.sgml \
                                       secure-programs-style.dsl
	@echo GENERATING: Single html file
	test -f index.sgml || touch index.sgml
	jade -t sgml -i html -V nochunks -d secure-programs-style.dsl\#html Secure-Programs-HOWTO.sgml > Secure-Programs-HOWTO.html
	$(FIXUP_HTML) Secure-Programs-HOWTO.html
	cp -p dwheeler2003b.jpg Secure-Programs-HOWTO
	cp -p program.jpg Secure-Programs-HOWTO

# I used to do this to generate the HTML:
# db2html Secure-Programs-HOWTO.sgml
# but I couldn't control its formatting sufficiently.

chunked_html: Secure-Programs-HOWTO/index.html
Secure-Programs-HOWTO/index.html: Secure-Programs-HOWTO.sgml \
                                  secure-programs-style.dsl \
                                  program.gif program.jpg
	@echo GENERATING: Chunked html file
	rm -fr Secure-Programs-HOWTO
	mkdir Secure-Programs-HOWTO
	cp -p *.gif Secure-Programs-HOWTO
	cp -p *.png Secure-Programs-HOWTO
	cp -p *.jpg Secure-Programs-HOWTO
	# This patches the generated index file to work around bug
	cd Secure-Programs-HOWTO && \
	  cp -p ../Secure-Programs-HOWTO.sgml . && \
	  touch index.sgml && \
	  jade -t sgml -i html -V html-index -d ../secure-programs-style.dsl\#html Secure-Programs-HOWTO.sgml && \
	  collateindex.pl -f -o index.sgml HTML.index && \
	  jade -t sgml -i html -d ../secure-programs-style.dsl\#html Secure-Programs-HOWTO.sgml && \
	  $(FIXUP_HTML) *.html

# perl -p -i -e 's/HREF="#(.*)"/href="\L\1\E.html"/' i3828.html
# db2html no longer available; it was around 2003
# cd Secure-Programs-HOWTO; db2html --dsl ../secure-programs-style.dsl\#html ../Secure-Programs-HOWTO.sgml
# cp -p book1-html.orig Secure-Programs-HOWTO/book1.html

pdf: Secure-Programs-HOWTO.pdf

Secure-Programs-HOWTO.pdf: Secure-Programs-HOWTO.sgml index.sgml \
              program.jpg program.png secure-programs-style.dsl
	@echo GENERATING: PDF
	# On Cygwin removing first quickly warns of eventual failure
	rm -f Secure-Programs-HOWTO.pdf
	docbook2pdf -d secure-programs-style.dsl\#print Secure-Programs-HOWTO.sgml


# Secure-Programs-HOWTO.txt: Secure-Programs-HOWTO.html
# 	# ./textify < Secure-Programs-HOWTO.sgml > Secure-Programs-HOWTO.txt
# 	lynx -dump Secure-Programs-HOWTO.html > Secure-Programs-HOWTO.txt


Secure-Programs-HOWTO-all-html.tar.gz: Secure-Programs-HOWTO/index.html \
  program.gif program.png program.jpg
	rm -f Secure-Programs-HOWTO-all-html.tar.gz
	tar cf Secure-Programs-HOWTO-all-html.tar \
                        Secure-Programs-HOWTO/*
	gzip -9 Secure-Programs-HOWTO-all-html.tar

# I've eliminated all GIFs - now we only have PNGs for the public.
# See http://www.burnallgifs.org

Secure-Programs-HOWTO.tar.gz: Secure-Programs-HOWTO.sgml program.dia makefile
	tar cvf Secure-Programs-HOWTO.tar Secure-Programs-HOWTO.sgml \
	        program.dia program.gif program.png program.eps program.jpg \
	        dwheeler2003b.jpg \
		secure-programs-style.dsl \
	        ChangeLog makefile 
	rm -f Secure-Programs-HOWTO.tar.gz
	gzip -9 Secure-Programs-HOWTO.tar
	# gzip -9 -c Secure-Programs-HOWTO.sgml > Secure-Programs-HOWTO.sgml.gz

# TODO: Fix curly quotes.
Secure-Programs-HOWTO.xml: Secure-Programs-HOWTO.sgml
	osx -xlower -xcomment -xcdata -xno-nl-in-tag -xempty Secure-Programs-HOWTO.sgml > Secure-Programs-HOWTO.xml

# osx -xlower -xcomment -xcdata -xno-nl-in-tag -xempty --warning=xml --warning=sgmldecl --warning=undefined --warning=net --warning=all Secure-Programs-HOWTO.sgml > Secure-Programs-HOWTO.xml

# Secure-Programs-HOWTO.ps: Secure-Programs-HOWTO.sgml dwheeler-book-style.dsl
# db2ps -d dwheeler-book-style.dsl Secure-Programs-HOWTO.sgml

# Command was: 
#   ps2pdf Secure-Programs-HOWTO.ps2 Secure-Programs-HOWTO.pdf

# was: ./ldp_print --postscript --pdf Secure-Programs-HOWTO.html 
# But this required a long chain of tools that I had trouble maintaining,
# including html2doc.
# Note: if you use ldp_print, then make it depend on the .html.

# was: db2pdf -d dwheeler-book-style.dsl Secure-Programs-HOWTO.sgml
# But this didn't support .eps files, and had trouble with mediaobject (!),
# so figure 1 had to be in JPEG (and thus ugly).

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

program.pnm: program.png
	pngtopnm program.png > program.pnm

program.jpg: program.pnm
	pnmtojpeg --quality=100 --optimize program.pnm > program.jpg

program.pdf: program.eps
	epstopdf program.eps > program.pdf

# For dwheeler2003b, jpg is the master; eps is a wrapping of it.
# I created the 'eps' because db2ps can't handle the jpg directly,
# and db2pdf can't handle eps directly.

dwheeler2003b.eps : dwheeler2003b.pnm
	pnmtops dwheeler2003b.pnm > dwheeler2003b.eps

dwheeler2003b.pnm : dwheeler2003b.jpg
	jpegtopnm dwheeler2003b.jpg > dwheeler2003b.pnm

# There are no makefile rules to convert the master file "program.dia"
# into "program.png" and "program.eps" - you need to use Dia's "Export"
# command to do that.

distribute: clean
	scp -pr * dwheeler@dwheeler.com:/home/dwheeler/WWW/secure-programs


