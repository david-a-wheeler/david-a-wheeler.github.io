# This makefile generates GIF files of Chess boards.

# FEN2GIF program converts "fen" into "gif".

FEN2GIF=../fen2gif

# Automatic rule for transforming "fen" to "gif":

.fen.gif:
	$(FEN2GIF) $<

SUFFIXES += .gif .fen

.SUFFIXES : $(SUFFIXES)

# sicilian.gif: sicilian.fen
# 	../fen2gif sicilian.fen

#####


BOARDS=carokann.gif centerc.gif dragon.gif dutch.gif english.gif evans.gif french.gif giuoco.gif indian.gif kingind.gif kingsg.gif modern.gif queeng.gif ruy.gif sicilian.gif najdorf.gif template.gif

all: $(BOARDS)


distribute:
	/bin/rm -f garden.zip *.BAK
	zip -9 garden.zip * -x garden.zip
	uuencode garden.zip garden.zip > garden.uu
