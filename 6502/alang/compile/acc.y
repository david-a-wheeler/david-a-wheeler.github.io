/* Acc.y -- parser for Apple II C Compiler */

/* terminal symbols */

%union {
       char *y_str;
       int y_num;
       }

%token <y_str> Identifier
%token <y_int> Constant
%token T_INT
%token T_CHAR
%token STRING
%token ASSEMBLE
%token '{'
%token '}'


%%

program : definitions

definitions
        : definition
        | definitions definition

type
        : T_INT
        | T_CHAR
        | type '*'

definition
        : function_definition
        | type function_definition


function_definition
        : Identifier { printf("%d\n", $1); }
          '(' optional_parameter_list ')'
          parameter_declarations compound_statement

optional_parameter_list
        : /* empty */
        | parameter_list

parameter_list
        : Identifier
        | parameter_list ',' Identifier

parameter_declarations
        : /* empty */
        | parameter_declarations parameter_declaration

parameter_declaration
        : type parameter_declaration_list ';'

parameter_declaration_list
        : Identifier
        | parameter_declaration_list ',' Identifier

compound_statement
        : '{' declarations statements '}'

declarations
        : /* empty */
        | declarations declaration

declaration
        : type declarator_list ';'

declarator_list
        : Identifier
        | declarator_list ',' Identifier

statements
        : /* empty */
        | statements statement

statement
        : ';' /* null statement */
        | assembly_statement ';'
        | Identifier '(' optional_argument_list ')' ';'  /* function call */

assembly_statement
        : ASSEMBLE '(' STRING ')'

optional_argument_list
        : /* empty */
        | argument_list

argument_list
        : Identifier
        | argument_list ',' Identifier


