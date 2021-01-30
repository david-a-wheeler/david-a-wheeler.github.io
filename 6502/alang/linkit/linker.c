/* linker.h -- linker for .ac (Apple C) compiled (.oo) files */

#include "global.h"
#include "depend.h"
#include "misc.h"
#include "allocmem.h"

#define read_in_line(x)  (void) gets(x);

/* Highest usable position in memory - data/params for __main, etc,
   will go flush against this */

#define MAX_MEMORY 0xbfff

char inputbuf[80]; /* input buffer - use read_in_line to read in strings. */

void gen_code()
{
/** ??: NOT_IMPLEMENTED */
}


read_function_definition()
{
FuncDef location, reference;
unsigned no_of_refs;

read_in_line(inputbuf);
dbg2("Beginning read_function_definition, am defining %s\n", inputbuf);
location = find_FunctionDefinition(inputbuf);
if (location) {
 /* There's already a node for this function - was it defined? */
 if (!is_defined(location)) {
   dbg1("Marking as defined\n");
   mark_as_defined(location); 
   }
 else {
   dbg2("location=%d\n", location);
   dbg2("defined=%d\n", is_defined(location));
   fatal("Function multiply defined.");
 }
}
else { /* no location - make a new node */
  location = make_FunctionDefinition(inputbuf, TRUE);
  dbg2("Defined as %d\n", location);
}

/* Read in parameter & local variable definitions */
read_space_definitions(location);

/* Read in references to other functions */
scanf("%d\n", &no_of_refs);
dbg2("Number of refs=%d\n", no_of_refs);
while (no_of_refs--) {
  read_in_line(inputbuf);
  reference = find_FunctionDefinition(inputbuf);
  if (!reference) {
    /* Didn't find it.  Create a placeholder (& add to list of undefined) */
    reference = make_FunctionDefinition(inputbuf, FALSE);
  }
  add_depend_on(location,reference);
  
}
}



void act_on_file()
{
  while (1) { /* ??? !eof */
    read_in_line(inputbuf);  /* begin with "F" for func def, "V" for var */
    dbg2("Read in %s\n", inputbuf);
    if ( inputbuf[0] == 'F' ) {
       read_function_definition();
    }
    else { if ( inputbuf[0] == 'E') {
       break;
       }
       else {
          /* static variable definition */
          error("Static variables not available yet");
          }
      } /* if/else.. */
   } /* while */
}




main()
{
FuncDef location;
MemHead master_memory;     /* Points to top of memory use tree */
MemHead bottom;            /* Points to the "bottom" (last part of) tree */
unsigned highest_used;       /* Highest used pos in memory */

/* Read in each file given by user first */

dbg1("Beginning main\n");

#ifdef NOT_IMPLEMENTED
for(; is there a file; next file) {
  open up file;
  set input to it;
  act_on_file();
  };
#else
  act_on_file();
#endif
 


/* Try to get external definitions of functions not explicitly listed */

#ifdef NOT_IMPLEMENTED
/** ??: NOT_IMPLEMENTED */
while (u = find_undefined_function()) {
  try to open a file for u
  if success {
     act_on_file();
     if (!is_defined(u)) {
       error("Found a file but u wasn't defined there");
     }
  }
  else  {
     error("Can't open a file for u");
     mark_as_defined(u); /* For error recovery, carry on as though defined */
  }
} /* end trying to find external definitions */
#else
dbg1("About to act_on_file (stdin)\n");
act_on_file();
#endif

/* Make sure that _main (User's main() function) is around */
dbg1("Looking for User's _main\n");
location = find_FunctionDefinition("_main");
if (!location) fatal("No main program found");

/* Make sure that __main (runtime system) is around */
/* Function __main must init things, call _main, and then clean up. */
dbg1("Looking for Runtime __main\n");
location = find_FunctionDefinition("__main");
if (!location) fatal("No runtime system found");
master_memory = make_master_memory(location);

/* We now have all the functions defined.  Create a dependency graph &
   do a topographical sort so that the leaf-level functions will get as
   many page zero locations as we can give them.  The result of the topo
   sort is a list that goes BACKWARDS (ie leaf-level functions will be
   first, all the way to __main which is last) */

bottom = topographic_sort(master_memory);  /* return a leaf-level function */

/* After all that work we now know what depends on what.  Let's allocate
   memory! */

assign_memory(bottom);

/* Memory map is as follows:
   zero page -- variables, parameters, etc
   <--> stack, unused,etc
   code
   <--> heap & malloc space
   data/param space up to MAX_MEMORY
*/

highest_used = last_used_location(master_memory);

printf("Highest used= %u, MAX=%u\n", highest_used,
        MAX_MEMORY);

set_offset(highest_used, MAX_MEMORY);

print_equ_list();

/* Now output code. */

gen_code();

}
