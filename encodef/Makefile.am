ACLOCAL_AMFLAGS = -I m4 --install
EXTRA_DIST = m4/NOTES

bin_PROGRAMS = encodef

encodef_SOURCES = encodef.c

# Use these autoconf-archive macros to turn on lots of warning flags.
# We'll distribute a local unmodified copy as a convenience.
EXTRA_DIST += m4/ax_append_flag.m4
EXTRA_DIST += m4/ax_cflags_warn_all.m4
# Use these to add -pedantic if we can:
EXTRA_DIST += m4/ax_append_compile_flags.m4
EXTRA_DIST += m4/ax_check_compile_flag.m4

# Documentation:

dist_man_MANS = encodef.1

dist_doc_DATA = encodef.pdf

encodef.pdf: encodef.1
	man -t ./encodef.1 | ps2pdf - - > encodef.pdf

# Tests:

EXTRA_DIST += encodef-test
EXTRA_DIST += evil-filenames-test

test:
	$(srcdir)/encodef-test

check: test

test-evil-filenames:
	$(srcdir)/evil-filenames-test


# Developer conveniences; various synonyms, etc.

push:
	git push

pull:
	git pull

