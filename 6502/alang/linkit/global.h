#include <stdio.h>

char *malloc();
char *calloc();
char *strcpy();

#define TRUE 1
#define FALSE 0

#define NULL 0

#define PRIVATE static

typedef char bool;

#define NULL_IS_0 1

#define DEBUG_OUTPUT 1

#ifdef DEBUG_OUTPUT
#define dbg1(str) printf(str)
#define dbg2(str,x) printf(str,x)
#define dbg3(str,x,y) printf(str,x,y)
#else
#define dbg1(str) /**/
#define dbg2(str,x) /**/
#define dbg3(str,x,y) /**/
#endif

#ifdef VERBOSE_DEBUG
#define vdbg1(str) printf(str)
#define vdbg2(str,x) printf(str,x)
#define vdbg3(str,x,y) printf(str,x,y)
#else
#define vdbg1(str) /**/
#define vdbg2(str,x) /**/
#define vdbg3(str,x,y) /**/
#endif
