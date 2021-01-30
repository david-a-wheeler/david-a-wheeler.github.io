#include <stdio.h>

#include "global.h"
#include "allocmem.h"

/* Accept a "starting" position and an amount desired, return the
   first available spot at "start" or higher with at least "nextamount"
   contiguous bytes */

#define zpage(x) ((x) <= 255)

PRIVATE unsigned non_zpage_offset;

unsigned allocate_memory(start,nextamount)
unsigned start;
unsigned nextamount;
{
if (zpage(start)) {
 if (!zpage(start+nextamount-1)) {
   return( (unsigned) 256); /* not enough space in zpage - get out of it */
   }
 /* zero page - skip used areas, etc */
 return(start);  /* Simplistic. */
}
return(start);  /* Simplistic. */
}

unsigned to_real_location(virtual_location)
unsigned virtual_location;
{
/* converts a "virtual" location in memory to a real one. */

if (zpage(virtual_location))
  return(virtual_location);
else
  return(virtual_location+non_zpage_offset);
}


void set_offset(highest_used, max_memory)
unsigned highest_used;
unsigned max_memory;
{
/* Given the highest memory location needed & the maximum memory 
   location allowed, set the offset for non-zero-page references */

if (zpage(highest_used)) /* non_zpage_offset won't be used */
   non_zpage_offset = 0x0800; /* set it to an innocuous value just in case */
else
   non_zpage_offset = max_memory - highest_used;
}
