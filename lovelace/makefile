# This makefile automates generating Lovelace tutorial files
# from its source files (.les) files.

# NOTE: See the file "legal.htm" for more information about the
# legal status of Lovelace.

# This makefile is unabashedly Unix-dependent, though translating it to some
# other system (like MS-DOS) shouldn't be too hard if desired.
# It's intended for my (David A. Wheeler's) personal use,
# but I'm including it in the distribution since it might be useful.

# Definitions of generic lesson-generating rules.

# The "-s" option in mklesson generates short filename extensions
# (.htm instead of .html):

MKLESSON=./mklesson -s -a

.les.tim:
	$(MKLESSON) $<

SUFFIXES += .tim .les

.SUFFIXES : $(SUFFIXES)

# Makefile variable definitions for file generation.

OBJECT_FILES = lesson1.tim lesson2.tim lesson3.tim lesson4.tim \
               lesson5.tim lesson6.tim lesson7.tim lesson8.tim \
               lesson9.tim lesson10.tim lesson11.tim lesson12.tim \
               lesson13.tim lesson14.tim lesson15.tim lesson16.tim \
               lesson17.tim lesson18.tim

SMALL_ADAFILES = creature.ads \
           directio.adb directio.ads \
           items.adb items.ads monsters.ads \
           occupant.adb occupant.ads \
           parser.adb parser.ads players.ads \
           rooms.adb rooms.ads small.adb \
           things.adb things.ads \
           ustrings.adb ustrings.ads \
           world.adb world.ads

SMALL_DESCRIPTION_HTML = small.htm smaldemo.htm

SMALL_ADA_HTML = creaturs.htm \
        directib.htm directis.htm \
        itemsb.htm itemss.htm monsters.htm \
        occupanb.htm occupans.htm \
        parserb.htm parsers.htm playerss.htm \
        roomsb.htm roomss.htm smallb.htm \
        thingsb.htm thingss.htm \
        ustringb.htm ustrings.htm \
        worldb.htm worlds.htm \
        pkglist.htm

# The Small files are $(SMALL_DESCRIPTION_HTML)
# $(SMALL_ADA_HTML) s18s*18.htm lesson18.htm

MKLESSON_FILES = readme gpl lgpl userg.htm mklesson template default \
              formattm.htm formatmk.txt blank.les new_sect \
              previous.gif next.gif up.gif tinyhome.gif \
              skip1s1.htm txttemp makefile

# File name of the "last lesson" (i.e. the lesson/section that doesn't exist)
LAST_LESSON = s19s1.htm


# Rules for file generation; default is "all".

# Note all the checking systems;
# weblint looks for HTML errors, hspell for spelling errors, and
# gcc calls GNAT to check for Ada syntax errors.
# Perhaps later I'll add "-gnatg" and explicitly use GNAT style.

all: $(OBJECT_FILES) comments.htm
	echo "Make sure you've install the program Small files."
	cp fini.htm $(LAST_LESSON)
	chmod ugo+r [a-z]*
	# weblint -e bad-link,mailto-link,upper-case \
        #        -d heading-order,empty-container -x netscape *.htm
	# nolink -i dwheeler.htm *.htm
	# hspell -x comments.htm *.htm
	# gcc -c -gnatc -gnatk8 *.adb *.ads
	# replace '<BODY>' '<BODY BGCOLOR="#FFFFFF">' *.htm
	-grep ' < ' *.les > ,goofs
	-grep ' > ' *.les >> ,goofs
	-grep ' & ' *.les >> ,goofs
	-grep ' <= ' *.les >> ,goofs
	-grep ' >= ' *.les >> ,goofs
	-grep ' => ' *.les >> ,goofs
	-echo "List of goofs follows:"
	-cat ,goofs

comments.htm: comments.hd COMMENTS comments.tl
	./mkcomm

clean:
	echo > ,temp.BAK
	echo > ,temp.org
	echo > ,temp.o
	echo > ,temp.tmp
	rm *.BAK *.org *.o *.tmp

really_clean: clean
	-rm *.tim
	-rm s[1-9][-s][1-9f].htm
	-rm s[1-9][0-9][-s][1-9f].htm
	-rm s[1-9][-s][1-9f]r[1-9].htm
	-rm s[1-9][0-9][-s][1-9f]r[1-9].htm


# Here's how to create the "small" executable.

small:
	/bin/rm -f ,errs
	# gnatchop -k -r -w mush
	# Use "-gnatg" for GNAT style.
	gnatmake small -cargs -gnatk8 -largs -gnatk8 2>&1 | tee ,errs | more

# Here's how to create the hypertext links for the "Small" program.
# Note that this is not done automatically.

hypertxt: $(SMALL_ADAFILES)
	# removed -m 'mailto:email-address'
	PATH=${PATH}:../ada2html ; export PATH ; ada2html -k -s -f -c 'You may return to the <A HREF="small.htm">Program Small Home Page</A>.' $(SMALL_ADAFILES)
	echo "Hypertext files created using 'ada2html'" > hypertxt



# Eventually add a "make check" entry, to perform a
# weblint, spellcheck, and a clean-compilation check.

# There's an implied order here:
# 1. Edit version files (lversion.htm, lovelace.htm, and version).
# 2. "make ci_all" to check in all local files.
# 3. "make distribute" to create the .zip, .tar.gz, and the WWW version.
# The distribution files do not contain old versions of
# documents (i.e. my RCS and OLD directories are not sent on).


# Check in every file in the (local) RCS directory.

ci_all:
	echo "You should have already edited these files:"
	echo "Files: version, lovelace.htm, lversion.htm"
	echo "Checking in all RCS files."
	ci -l RCS/*
	echo "Version Number is:"
	cat < version
	echo "If all's okay, execute this and make distribute:"
	echo 'rcs -Nversion: RCS/*'
	echo "Where version is Lversion.number (without the period)"

# "ci_all" doesn't do the rcs command because it's easy to
# forget to upgrade all the version files.

# "make distribute" creates distributions in various formats,
# including various subsets for people who only want pieces.
# First, it generates files, then generates subsets, then generates the web
# version of it.

distribute: clean comments.htm
	# Create statistics
	./lcount > stats.htm
	# Create "llstart.htm", which is moved "up" a directory
	# to create an "uncluttered" directory
	perl -ple 's/<A HREF="([^\/"]*)"/<A HREF="files\/$1"/g;' \
                  < local.htm > llstart.htm
	chmod ugo+r [a-z]*
	# Set up files for "Small".
	cat $(SMALL_ADAFILES) > small.txt
	zip -9 -v small.zip $(SMALL_ADAFILES)
	zip -9 -v smallall.zip $(SMALL_DESCRIPTION_HTML) $(SMALL_ADA_HTML) \
              s18s*.htm lesson18.htm small.gif
	# Create zipped & tar.gz version of Lovelace.
	# It mkdir's LOVELACE, to be less risky if I ruin the makefile.
	-rm -f lovelace.zip lovelace.tar.gz
	-rm -fr LOVELACE
	mkdir LOVELACE
	mkdir LOVELACE/tutorial
	cp -p [a-z]* *.class LOVELACE/tutorial
	cd LOVELACE/tutorial; /bin/rm `cat ../../exclude` ; cd ../..
	/bin/rm -f LOVELACE/tutorial/about.ps LOVELACE/tutorial/*.zip
	/bin/rm -f LOVELACE/tutorial/*.tar.gz
	# Place a few files into the upper directory
	cp LOVELACE/tutorial/llstart.htm LOVELACE/index.html
	cp LOVELACE/tutorial/readme LOVELACE/readme
	# We're done setting up the LOVELACE subdirectory. Create tar and zip.
	mv LOVELACE lovelace
	zip -9 lovelace.zip lovelace/*
	# Was: zip -9 lovelace.zip [a-z]* *.class -x `cat exclude`
	tar cvf - lovelace/* > lovelace.tar
	# Was: tar cvfX - exclude [a-z]* *.class > lovelace.tar
	gzip --best lovelace.tar
	rm -fr lovelace
	# Create zipped and tar.gz version of mklesson 
	rm -f mklesson.tar.gz mklesson.zip
	zip -9 mklesson.zip $(MKLESSON_FILES) -x `cat exclude`
	tar cvf - $(MKLESSON_FILES) > mklesson.tar
	gzip mklesson.tar
	chmod ugo+r *.zip *.gz
	# Everyone has a web browser, don't need CELLO nowadays:
	# rm -fr CELLO
	# mkdir CELLO
	# cp -p JUST_CELLO/* CELLO
	# cp -p [a-z]* *.class CELLO
	# cd CELLO; /bin/rm `cat ../exclude` ; cd ..
	# mv CELLO cello
	# zip -9 LV-CELLO.zip cello/*
	# was: cd CELLO; zip -9 LV-CELLO.zip [a-z]* -x `cat exclude`
	# was: mv CELLO/LV-CELLO.zip .
	# rm -fr cello
	# mv LV-CELLO.zip lovecell.zip
	tar cvf - WWW_install [a-z]* *.class About.fm COMMENTS X.ref Talk1.fm > WWW_LOVELACE.tar
	# mv lovecell.zip LV-CELLO.zip
	chmod a+r WWW_LOVELACE.tar
	compress WWW_LOVELACE.tar
	echo "Size of zip file is (should be less than 1400 Kbytes):"
	ls -l lovelace.zip


