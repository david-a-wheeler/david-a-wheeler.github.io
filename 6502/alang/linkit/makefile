all: test
 
test: test1 linker
	./linker < test1

ALL_OBJECTS= linker.o depend.o misc.o allocmem.o

depend.o: depend.c depend.h global.h

linker.o: linker.c depend.h misc.h global.h

misc.o: misc.c misc.h global.h

linker: $(ALL_OBJECTS)
	cc $(ALL_OBJECTS) -o linker

tar-file:
	tar cvfb tar-file 20 InputFormat README makefile *.[ch] test? test?.doc
