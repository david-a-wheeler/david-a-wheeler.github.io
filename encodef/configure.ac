#                                               -*- Autoconf -*-
# Process this file with autoconf to produce a configure script.

AC_INIT([encodef], [0.40], [dwheeler@dwheeler.com], [encodef],
        [https://sourceforge.net/projects/encodef/])
AC_PREREQ([2.68])
# Safety check - list a source file that wouldn't be in other directories:
AC_CONFIG_SRCDIR([encodef.c])
# Put configuration results here, so we can easily #include them:
AC_CONFIG_HEADERS([config.h])

# Put autotools auxiliary files in a subdir, so they don't clutter top dir:
AC_CONFIG_AUX_DIR([build-aux])
AC_CONFIG_MACRO_DIR([m4])

AM_INIT_AUTOMAKE([1.11 subdir-objects -Wall -Werror])
AC_CONFIG_FILES([Makefile])

# Checks for programs.
AC_PROG_CC
AM_PROG_CC_C_O
AC_PROG_INSTALL
AC_PROG_MKDIR_P

# Checks for libraries.

# Checks for header files.
AC_CHECK_HEADERS([stdlib.h string.h])

# Checks for typedefs, structures, and compiler characteristics.
AC_CHECK_HEADER_STDBOOL

# Use GNU Autoconf Archive
# https://www.gnu.org/software/autoconf-archive/
AX_CFLAGS_WARN_ALL
AX_APPEND_COMPILE_FLAGS([-Wextra])
AX_APPEND_COMPILE_FLAGS([-pedantic])


# Checks for library functions.

AC_OUTPUT

