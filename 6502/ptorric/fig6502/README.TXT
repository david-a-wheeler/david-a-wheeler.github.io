figFORTH 1.1 for the Apple I
============================

This code has been compiled with ca65 V2.9.2. 

Executable is built with ld65 V2.9.2.

See makefile.bat for options.

On the Apple I, load fig6503.bin at $0300.

Tor run:

	300R<CR>

If all loads well, the Apple I will respond with:

	FIG-FORTH 1.1

Note: This is currently compiled using $1F to represent ascii <space>.
This is what the POM emulator uses. It appears to be non-standard.
You may need to change this to $20 and recompile for the real Apple I.
This is line 980 in the figforth.lst (definition for the FORTH word BL).

W. K. Rodiger
11/6/03