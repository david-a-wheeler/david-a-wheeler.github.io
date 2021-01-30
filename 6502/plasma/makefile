.SUFFIXES	=
AFLAGS	= -o $@
LFLAGS	= -C default.cfg
PLASMA  = plasma
OBJS	= parse.o lex.o codegen.o
INTERP  = interp6502.s
HGRPLA	= hgr.pla
HGRSYS	= hgr.sys
RODPLA	= rod.pla
RODSYS	= rod.sys
CMPPLA	= cmp.pla
CMPSYS	= cmp.sys
CATPLA	= cat.pla
CATSYS	= cat.sys
EDITPLA	= edit.pla
EDITSYS	= edit.sys
DBFILLPLA	= dbfill.pla
DBFILLSYS	= dbfill.sys
RADARPLA	= radar.pla
RADARSYS	= radar.sys
COMBSYSPLA	= combsys.pla
COMBSYSSYS	= combsys.sys
LOADERPLA	= loader.pla
LOADERSYS	= loader.sys
PLASMAPLA	= plasma.pla
PLASMASYS	= plasma.sys
PLEAIDEPLA	= pleaides.pla
PLEAIDESYS	= pleaides.sys
#
# Image filetypes for Virtual ][
#
PLATYPE	= .\$$ED
BINTYPE	= .BIN
SYSTYPE	= .SYS
TXTTYPE	= .TXT
#
# Image filetypes for CiderPress
#
#PLATYPE	= \#ed0000
#BINTYPE	= \#060000
#SYSTYPE	= \#ff0000
#TXTTYPE	= \#040000

all: $(PLEAIDESYS) $(PLASMASYS) $(LOADERSYS) $(COMBSYSSYS) $(DBFILLSYS) $(RADARSYS) $(EDITSYS) $(CATSYS) $(CMPSYS) $(RODSYS) $(HGRSYS) $(PLASMA)

$(PLASMA): $(OBJS)
	cc $(OBJS) -o $(PLASMA)

$(HGRSYS): $(PLASMA) $(HGRPLA) $(INTERP)
	./$(PLASMA) < $(HGRPLA) > hgr.s
	ca65 hgr.s -o tmp.o
	ld65 $(LFLAGS) tmp.o -o $(HGRSYS)
	rm tmp.o
	cp $(HGRSYS) hgr\#ff0000

$(RODSYS): $(PLASMA) $(RODPLA) $(INTERP)
	./$(PLASMA) < $(RODPLA) > rod.s
	ca65 rod.s -o tmp.o
	ld65 $(LFLAGS) tmp.o -o $(RODSYS)
	rm tmp.o
	cp $(RODSYS) rod\#ff0000

$(CMPSYS): $(PLASMA) $(CMPPLA) $(INTERP)
	./$(PLASMA) < $(CMPPLA) > cmp.s
	ca65 cmp.s -o tmp.o
	ld65 $(LFLAGS) tmp.o -o $(CMPSYS)
	rm tmp.o

$(CATSYS): $(PLASMA) $(CATPLA) $(INTERP)
	./$(PLASMA) < $(CATPLA) > cat.s
	ca65 cat.s -o tmp.o
	ld65 $(LFLAGS) tmp.o -o $(CATSYS)
	rm tmp.o

$(EDITSYS): $(PLASMA) $(EDITPLA) $(INTERP)
	./$(PLASMA) < $(EDITPLA) > edit.s
	ca65 edit.s -o tmp.o
	ld65 $(LFLAGS) tmp.o -o $(EDITSYS)
	rm tmp.o
	cp $(EDITSYS) edit\#ff0000

$(DBFILLSYS): $(PLASMA) $(DBFILLPLA) $(INTERP)
	./$(PLASMA) < $(DBFILLPLA) > dbfill.s
	ca65 dbfill.s -o tmp.o
	ld65 $(LFLAGS) tmp.o -o $(DBFILLSYS)
	rm tmp.o
	cp $(DBFILLSYS) dbfill\#ff0000

$(COMBSYSSYS): $(PLASMA) $(COMBSYSPLA) $(INTERP)
	./$(PLASMA) < $(COMBSYSPLA) > combsys.s
	ca65 combsys.s -o tmp.o
	ld65 $(LFLAGS) tmp.o -o $(COMBSYSSYS)
	rm tmp.o
	cp $(COMBSYSSYS) combsys\#ff0000

$(LOADERSYS): $(PLASMA) $(LOADERPLA) $(INTERP)
	./$(PLASMA) < $(LOADERPLA) > loader.s
	ca65 loader.s -o tmp.o
	ld65 $(LFLAGS) tmp.o -o $(LOADERSYS)
	rm tmp.o
	cp $(LOADERSYS) loader\#ff0000
	./$(PLASMA) - < $(LOADERPLA) > LOADER.S.TXT

$(RADARSYS): $(PLASMA) $(RADARPLA) $(INTERP)
	./$(PLASMA) < $(RADARPLA) > radar.s
	ca65 radar.s -o tmp.o
	ld65 $(LFLAGS) tmp.o -o $(RADARSYS)
	rm tmp.o
	cp $(RADARSYS) radar\#ff0000

$(PLASMASYS): $(PLASMAPLA) $(PLASMA) $(INTERP)
	./$(PLASMA) < $(PLASMAPLA) > plasma.s
	ca65 plasma.s -o tmp.o
	ld65 -C plasma.cfg tmp.o -o $(PLASMASYS)
	rm tmp.o
	cp $(PLASMASYS) plasma\#ff0000

$(PLEAIDESYS): $(PLEAIDEPLA) $(PLASMA) $(INTERP)
	./$(PLASMA) < $(PLEAIDEPLA) > pleaides.s
	ca65 pleaides.s -o tmp.o
	ld65 -C pleaides.cfg tmp.o -o $(PLEAIDESYS)
	rm tmp.o
	cp $(PLEAIDESYS) pleaides\#ff0000
