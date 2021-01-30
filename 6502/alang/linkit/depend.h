
/* Depend.h -- dependency graph for linker */


/* Organization: this is the specification for other users.
   This begins with a bunch of type declarations, followed by
   structures (required by C), followed by function declarations of
   the functions that may be called by the outside world.
   THUS: To see the interesting stuff, look at the BOTTOM FIRST. */


/* Type declarations */

/* Each MemInfNode represents a parameter or a local variable */
struct s_MemInfo;
typedef struct s_MemInfo MemInfNode;
typedef struct s_MemInfo * MemInfo;

/* Each DepItmNode represents a dependency to some MemHead */
struct s_DepItem;
typedef struct s_DepItem DepItmNode;
typedef struct s_DepItem *DepItem;

/* MemHeads are sets of variables (MemInfNodes)
   that depend on other MemHeads.
   A single MemHead may represent a set of parameters for a particular
   function or a set of temporary variables for a function. */
struct s_MemHedNode;
typedef struct s_MemHedNode MemHedNode;
typedef struct s_MemHedNode * MemHead;


/* Each of these nodes represents a function definition */
/* A function definition has two MemHeads: one for params, one for vars. */
struct s_FuncDfNode;
typedef struct s_FuncDfNode FuncDfNode;
typedef struct s_FuncDfNode *FuncDef;

typedef unsigned char PARAMSIZE;  /* store parameter sizes in this */


/* Now define the data structures to keep C happy */

#define MEMHEADER_BACKPOINTER 1

struct s_MemInfo {
unsigned location_in_memory;  /* address it is assigned to */
MemInfo next_MemInfo;         /* next parameter/local variable */
PARAMSIZE number_of_bytes;    /* Number of bytes to represent this parameter */
};

struct s_DepItem {
MemHead dependent_on;
DepItem next_DepItem;
};


/* Each node represents a set of parameters or a set of local vars of
   a function */
struct s_MemHedNode {
MemInfo firstMemInfo;
DepItem firstDepItem;
MemHead topo_previous; /* Higher-level Memory usage.. traces to top of tree*/
#ifdef MEMHEADER_BACKPOINTER
FuncDef owned_by_FuncDef;
#endif
unsigned first_unused_location; /* this location & higher isn't used by this */
char fan_in; /* number of other MemHedNodes that depend on this one */
};

struct s_FuncDfNode {
char *func_name;       /* Name of function */
MemHead params;      /* parameters */
MemHead local_vars;  /* local variables */
FuncDef next_FDefinition; /* Inefficient - should become BTree */
char Func_is_defined;
};



/* Legal operations - we have abstract data types, these are the
   legal, visible operations. */

/* create a Func Def. node - must call find_FunctionDefinition first! */
FuncDef make_FunctionDefinition(/* char *func_name, bool defined */);

FuncDef find_FunctionDefinition(/* char *func_name */);
void add_depend_on(/* FuncDef location, reference */);
FuncDef find_undefined_function();

void read_space_definitions(/* FuncDef */);

MemHead make_master_memory(/* FuncDef top_level_Function */);

/* Sort topologically the MEMORY USE.  Pass the sort the "master memory
   block" created by the "make master memory". */
MemHead topographic_sort(/* MemHead master_memheader */);

/* Implement these operations inline */

/* bool is_defined(FuncDef); */
#define is_defined(x) ((x)->Func_is_defined)

/* void mark_as_defined(FuncDef); */
#define mark_as_defined(x) ((x)->Func_is_defined = 1);

void print_equ_list();

void assign_memory(/* MemHead bottom */);
unsigned last_used_location(/* MemHead mh */);
