/* mod1.c */

#include <stdio.h>
#include <unistd.h>

#ifndef VERSION
#define VERSION ""
#endif

void 
x1(void) { 
    printf("Called mod1-x1 " VERSION "\n"); 
} 

