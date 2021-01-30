
/* Depend.c -- dependency graph for linker */

#include "global.h"
#include "depend.h"
#include "allocmem.h"

static FuncDef FDefbeginning = (FuncDef) NULL; /* beginning of list of */
                                               /* Func definitions */

/* inlined iterators */
#define first_FuncDef() FDefbeginning
#define next_FuncDef(v) ((v)->next_FDefinition)
#define first_dependent(memheader) ((memheader)->firstDepItem)
#define next_dependent(dependitem) ((dependitem)->next_DepItem)

PRIVATE MemHead make_memory_header()
{
MemHead mh;

#ifdef NULL_IS_0
/* We may assume that setting all 0's will make NULL, etc, okay.
   Use calloc() instead of malloc */
mh = (MemHead) calloc( (unsigned)1,sizeof(MemHedNode));
#else
mh = (MemHead) malloc(sizeof(MemHedNode));
mh->firstMemInfo    = (MemInfo) NULL;
mh->firstDepItem = (DepItem) NULL;
mh->fan_in = 0;
#endif

return mh;
}

#ifdef MEMHEADER_BACKPOINTER
PRIVATE void print_memheader_name(m)
MemHead m;
{
FuncDef f = m->owned_by_FuncDef;

if (!f) {
 printf("<Noname %d>", (unsigned) m); return;
 }

if (m == f->params) {
 printf("%s[P]", f->func_name);
 }
else if (m == f->local_vars) {
 printf("%s[L]", f->func_name);
 }
else {
 fatal("Incorrectly owned memheader\n");
 }
}


PRIVATE void print_depend_list(m)
MemHead m;
{
DepItem walker = m->firstDepItem;

while(walker) {
 print_memheader_name(walker->dependent_on);
 putchar(' ');
 walker = walker->next_DepItem;
 }
}
#endif

/* Make dependor depend on dependee */
PRIVATE add_memory_dependency(dependor, dependee)
MemHead dependor, dependee;
{
DepItem newItem;

newItem = (DepItem) malloc(sizeof(DepItmNode));
newItem->next_DepItem = dependor->firstDepItem;
newItem->dependent_on = dependee;
dependor->firstDepItem = newItem;
/* increment the fan-in counter of the dependee */
(dependee->fan_in)++;
}

FuncDef make_FunctionDefinition(fname,defined)
char *fname;
bool defined;
{
FuncDef newnode;
MemHead localvarlist, paramlist;
char *new_name_location;

/* First, create main node. */
newnode = (FuncDef) malloc(sizeof(FuncDfNode));
/* COPY the function name. */
new_name_location = (char *) malloc((unsigned) strlen(fname)+1);
(void) strcpy(new_name_location,fname);
newnode->func_name = new_name_location;
newnode->Func_is_defined = defined;


localvarlist = make_memory_header();
paramlist    = make_memory_header();

newnode->params     = paramlist;
newnode->local_vars = localvarlist;

/* Variable list & paramlist must depend on each other (clearly they
   can't use the same space!).  Either direction is fine, and this
   determines who has the priority on the zpage, the temp vars or
   the parameters.  paramlist, localvarlist means localvars get zpage first */

add_memory_dependency(paramlist, localvarlist);

#ifdef MEMHEADER_BACKPOINTER
paramlist->owned_by_FuncDef =
 localvarlist->owned_by_FuncDef = newnode;
#endif

/* Now add to (beginning of) system list of FDefinitions.  INEFFICIENT */
newnode->next_FDefinition = FDefbeginning;
FDefbeginning = newnode;

return newnode;
}


FuncDef find_FunctionDefinition(fname)
char *fname;
{
 register FuncDef walker = FDefbeginning;

 dbg2("Looking for %s\n", fname);
 while (walker) {
   if (!strcmp(fname, walker->func_name)) /* they're equal - return */
          {
          dbg3("Found Answer- %d %s\n", walker, walker->func_name);
          return walker;
          }
   walker = walker->next_FDefinition;  /* Nope, look at the next one. */
 }
 dbg2("Did not find %s\n", fname);
 return ((FuncDef) NULL);
}


PRIVATE MemInfo read_meminfo()
{
MemInfo newnode;
unsigned itemsize;

scanf("%d", &itemsize);
newnode = (MemInfo) malloc(sizeof(MemInfNode));
newnode->number_of_bytes = (PARAMSIZE) itemsize;

return newnode;
}


/* Read in a list of Memory requirements (ie param or local var list). */
/* Return the FIRST one */
PRIVATE MemInfo read_Memlist()
{
unsigned no_of_items;
MemInfo first;
MemInfo previous;
MemInfo current;

scanf("%d", &no_of_items);
if (!no_of_items) return (MemInfo) NULL;

first = previous = read_meminfo();
while (--no_of_items) {
 current = read_meminfo();
 previous->next_MemInfo = current;
 previous = current;
 }
previous->next_MemInfo = (MemInfo) NULL;

scanf("\n");

return first;
}

void read_space_definitions(func)
FuncDef func;
{
/* Read in space definitions for parameters & for local variables
   (in that order) */

(func->params)->firstMemInfo     = read_Memlist();
(func->local_vars)->firstMemInfo = read_Memlist();
}

PRIVATE print_space_definition(mh)
MemHead mh;
{
MemInfo walker;

printf("[");
for( walker = mh->firstMemInfo ; walker ; walker = walker->next_MemInfo ) {
  printf(" %d", walker->number_of_bytes);
  }
printf("]");
}

void add_depend_on(dependor, dependee)
FuncDef dependor, dependee;
{

/* Make params depend on params & locals */
add_memory_dependency(dependor->params, dependee->params);
add_memory_dependency(dependor->params, dependee->local_vars);

/* Make local variables depend on params & locals */
add_memory_dependency(dependor->local_vars, dependee->params);
add_memory_dependency(dependor->local_vars, dependee->local_vars);

}

FuncDef find_undefined_function()
{
register FuncDef victim;
/* Linear search - slooow. */

for (victim = first_FuncDef() ; victim ; victim = next_FuncDef(victim) ) {
  if (!is_defined(victim)) return(victim);
    }

/* Didn't find any undefined function */
return((FuncDef) NULL);
}


/* Make a MemHead Node that references both the vars & args of the
   top level Function. */
MemHead make_master_memory(toplevel_function)
FuncDef toplevel_function;
{
MemHead mh;

mh = make_memory_header();
add_memory_dependency(mh, toplevel_function->params);
add_memory_dependency(mh, toplevel_function->local_vars);

return mh;
}


/* Queue routines for topographic sort -- queue of MemHead's. */

struct s_queue_element;
typedef struct s_queue_element queue_node;
typedef struct s_queue_element * queue_element;

struct s_queue_element {
 queue_element next_queue_element;
 MemHead data_of_queue;
};

/*
   Queue - Add to back, remove from front.
*/

static queue_element queue_front = (queue_element) NULL;
static queue_element queue_back =  (queue_element) NULL;

#ifdef MEMHEADER_BACKPOINTER
void print_queue();
#endif

PRIVATE void add_to_queue(a)
MemHead a;
{
register queue_element newnode;

newnode = (queue_element) malloc(sizeof(queue_node));
newnode->data_of_queue = a;
newnode->next_queue_element = (queue_element) NULL;

if (!queue_front) { /* Empty queue */
  queue_front = queue_back = newnode;
  }
else {
  queue_back->next_queue_element = newnode;
  queue_back = newnode;
  }
#ifdef MEMHEADER_BACKPOINTER
 dbg1("Added ");  print_memheader_name(a);
 dbg2("%d ", a);
 dbg1("\n");
 print_queue();
#else
 dbg1("a");
#endif
}


PRIVATE MemHead remove_from_queue()
{
register queue_element oldnode;
MemHead value;

/* This is called "pop" by some books - see S/W Comp w/Ada, Grady Booch,p150 */
oldnode = queue_front;
if (!oldnode) return( (MemHead) NULL); /* return NULL if empty */

value = oldnode->data_of_queue;
queue_front = oldnode->next_queue_element;
if (!queue_front) { queue_back = (queue_element) NULL; }

free((char *) oldnode);

return value;
}

#ifdef MEMHEADER_BACKPOINTER
PRIVATE void print_queue()
{
register queue_element walker;
register queue_element lastwalker;

walker = queue_front;
lastwalker = walker;

puts("Queue:\n");
while (walker) {
 printf("%d ", walker);
 print_memheader_name(walker->data_of_queue);
 if (walker == queue_back) puts(".");
 else puts(" ");
 lastwalker = walker;
 walker = walker->next_queue_element;
 }

if (lastwalker != queue_back)
 puts(" <Queue inconsistent>\n");
else
 puts("<End of Queue.>\n");
}
#endif


MemHead topographic_sort(required)
MemHead required;  /* the top that is required */
{
/* Topological sort of function dependencies */
MemHead victim;
MemHead last_header_seen;
MemHead toq; /* "top of queue" */
DepItem walker;

dbg2("topographic_sort starting with %d\n", required);
dbg1("Using queue-\n");

#ifdef NOT_IMPLEMENTED
/* Look for undefined Functions.  This code isn't correct because
   it's the MemHedNodes that have fan-in, not the Functions. */
/* Look for things with fan_in == 0 (nothing depends on it).. there
   should be exactly one of them.  This one thing must be == required. */
for (victim = first_FuncDef() ; victim ; victim = next_FuncDef(victim) ) {
  if ((victim's fan_in == 0) && (victim != required)) {
    error("Function linked in but not used: victim");
    }
  }
#endif

/* Setup for major loop.  Put the root of the tree into the queue */
last_header_seen = NULL;
add_to_queue(required);

while (toq = remove_from_queue() ) {
 toq->topo_previous = last_header_seen;
#ifdef MEMHEADER_BACKPOINTER
 dbg2("Working on %d ", toq);  print_memheader_name(toq); dbg1("\n");
 print_queue();
#endif
 /* Conceptually "remove" the item - now go through every dependent */
 for (walker = first_dependent(toq); walker; walker = next_dependent(walker)) {
   victim = walker->dependent_on;
   (victim->fan_in)--;
   if (!(victim->fan_in)) add_to_queue(victim);
 }
 last_header_seen = toq;
}

#ifdef NOT_IMPLEMENTED
/* Same problem as above. */
/* Look for things with fan_in == 0 -- now everything should be this way.
   If not, we have cycles (recursive calling). */
for (victim = first_FuncDef() ; victim ; victim = next_FuncDef(victim) ) {
  if ((victim's fan_in != 0) {
    error("Function recursive: victim");
    }
  }
#endif

#ifdef MEMHEADER_BACKPOINTER
{
 register MemHead h = last_header_seen;
 puts("->");
 while (h) {
   print_memheader_name(h);
   print_space_definition(h);
   printf(" (");
   print_depend_list(h);
   printf(")\n->");
   h = h->topo_previous;
 }
}
#endif
return(last_header_seen);
}
 
 
/* Main entry.  This goes up from the leaf-level Memory units,
   requesting each one to be allocated (preferably in high-speed memory) */ 
/* Returns the highest location of memory used. */

void assign_memory(bottom)
MemHead bottom;
{
 register MemInfo mi; 
 MemHead mh = bottom;
 unsigned lowest_memory, mem_location, dependent_lowest;
 DepItem depend;
 

 puts("Allocating Memory");
 while (mh) {
#ifdef MEMHEADER_BACKPOINTER
   print_memheader_name(mh);
   print_space_definition(mh);
   printf(" (");
   print_depend_list(mh);
   printf(")\n->");
#endif

   /* Find out the lowest possible memory location (lowest_memory)
      by looking at all the dependents & taking their lowest */
   lowest_memory = 0;
   for (depend = first_dependent(mh); depend; depend = next_dependent(depend)) {
     dependent_lowest = (depend->dependent_on)->first_unused_location;
     if (lowest_memory < dependent_lowest) lowest_memory = dependent_lowest;
    }
    /* lowest_memory is now set to the smallest memory location that we can use */

   /* Allocate each memory item */
   mi = mh->firstMemInfo;
   while(mi) {
    mem_location = allocate_memory(lowest_memory,
                                   (unsigned) mi->number_of_bytes);
    mi->location_in_memory = mem_location;
    lowest_memory = mem_location + mi->number_of_bytes;
    dbg2("Lowest memory now %d\n", lowest_memory);
    mi = mi->next_MemInfo;
   }
   /* Set this header to the mem_location  */
   mh->first_unused_location = lowest_memory;
   mh = mh->topo_previous;
 }
#ifdef MEMHEADER_BACKPOINTER
{
 mh = bottom;
 puts("Allocations:");
 while (mh) {
   print_memheader_name(mh);
   print_space_definition(mh);
   printf(" (");
   print_depend_list(mh);
   printf(") ");
   mi = mh->firstMemInfo;
   while(mi) {
    printf(" %d",mi->location_in_memory);
    mi = mi->next_MemInfo;
   }
   printf("\n->");
   mh = mh->topo_previous;
 }
}
#endif
}

unsigned last_used_location(mh)
MemHead mh;
{
 return( (mh->first_unused_location) - 1);
}

PRIVATE void print_mh_equ(func_name,prefix,mh)
char *func_name;
char *prefix;
MemHead mh;
{
MemInfo mi;
unsigned count = 0;

for (mi = mh->firstMemInfo ; mi ; count++, mi = mi->next_MemInfo) {
 printf("%s%d%s EQU %u\n",prefix,count,func_name,
           to_real_location(mi->location_in_memory));
 }

}

void print_equ_list()
{
FuncDef f;

printf("\n");

for ( f = first_FuncDef() ; f ; f = next_FuncDef(f) ) {
 print_mh_equ(f->func_name,"P",f->params);
 print_mh_equ(f->func_name,"V",f->local_vars);
 }
}
