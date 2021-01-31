%{

/* html2wikipedia by David A. Wheeler (http://www.dwheeler.com.com).
   This is a filter that converts HTML into Wikipedia's version of Wiki.
   As a filter, send HTML in as standard input; results are in stdout.

   This licensed under a _MODIFIED_ GPL; see the README.

   I've specifically written the code to try to avoid security problems,
   and I've also run the generated code through flawfinder
   (no problems noted).  I've also written this to be VERY FAST.

   This code is in flex, and MUST be processed as case-insensitive (-i).

   TODO: <img>, <dl>

   This handles the nasty incompatible curly single and double quotation
   marks from Windows (charset=windows-1252).
   For the contents of that charset:
   http://www.unicode.org/Public/MAPPINGS/VENDORS/MICSFT/WINDOWS/CP1252.TXT
   Right now it ALWAYS converts.  Can I rely on the charset value, and
   only do it then?  Should I convert others, esp. N dash and M dash?

   If you have really awful HTML,
   consider passing it first through the "Demoroniser" script:
     http://www.fourmilab.ch/webtools/demoroniser

*/

#include <stdio.h>
#include <ctype.h>
#include <string.h>

#define MIN(a,b) ( (a) < (b) ? (a) : (b) )
#define MAX(a,b) ( (a) > (b) ? (a) : (b) )

static int in_body = 0;  /* 1=we've seen a <body> */
static int in_pre = 0;   /* 1= in <pre>...</pre> section */
static int disable_newlines = 0; /* nonzero = don't output newline */
static int newlines_out = 0; /* Count of contentless newlines */

enum link_t {NOLINK, NORMAL_LINK, WIKI_LINK};

static enum link_t currentlink = NOLINK;

/* Print only if the body has been seen */
void out(char *text) {
	if (in_body) {
		fputs(text,stdout);
	}
}


/* Record list types at each level; because we use a max value
   and a single unsigned bitfield, we can't have buffer overflows. */
#define MAX_LIST_LEVEL 15
static int list_level = 0;
static unsigned list_type = 0; /* Bitfield, 1=ordered */

void set_list_type(int value) {
	if (value) {
		list_type |= (1 << list_level);
	} else {
		list_type &= (~(1 << list_level));
	}
}

void out_list_prefix() {
	int i;
	for (i = list_level; i > 0; i--) {
		if ( list_type & (1 << i))
			out("#");
		else
			out("*");
	}
}


%}


SPACE		[ \t\n\r\f]
ATTRIBUTES	{SPACE}([^">]|\"[^"]*\")*
BODY		\<body{ATTRIBUTES}?>
CENTER		\<center{ATTRIBUTES}?>
LISTITEM	\<li{ATTRIBUTES}?>{SPACE}*
CENTER_END	\<\/center{ATTRIBUTES}?>
PARAGRAPH	\<p{ATTRIBUTES}?>
ORDERED_LIST	\<ol{ATTRIBUTES}?>
ORDERED_LIST_END	\<\/ol{ATTRIBUTES}?>
UNORDERED_LIST	\<ul{ATTRIBUTES}?>
UNORDERED_LIST_END	\<\/ul{ATTRIBUTES}?>
PRE		\<pre{ATTRIBUTES}?\>
PRE_END		\<\/pre{ATTRIBUTES}?\>
EMPHASIZE	\<(b|i|em|strong){ATTRIBUTES}?\>
EMPHASIZE_END	\<\/(b|i|em|strong){ATTRIBUTES}?\>
COMMENT		\<\!--([^-]|-[^-]|--[^>])*\>
HYPERTEXT	\<a{ATTRIBUTES}?\>
HYPERTEXT_END	\<\/a{ATTRIBUTES}?\>
IMG		\<img{ATTRIBUTES}?\>
OUTPUT_AS_IS	\<\/?(br|table|tr|td|th|caption|tt|u|strike|sub|sup){ATTRIBUTES}?>
HR		\<hr{ATTRIBUTES}?>
WIKI_PREFIX	"http://www.wikipedia.com/wiki/"
MICROSOFT_JUNK	"<![if !supportEmptyParas]>&nbsp;<![endif]>"

%x hlink
%x wiki_url
%x link_url
%x link_consume

%%
{BODY}		{ in_body = 1; }
\<h1\>		{ out("\n== "); disable_newlines++; }
\<h2\>		{ out("\n=== "); disable_newlines++; }
\<h3\>		{ out("\n==== "); disable_newlines++; }
\<\/h1\>	{ out("  ==\n"); disable_newlines--;}
\<\/h2\>	{ out("  ===\n"); disable_newlines--;}
\<\/h3\>	{ out("  ====\n"); disable_newlines--;}
{CENTER}	{ out("<center>"); /* Remove any excess attributes */}
{CENTER_END}	{ out("</center>"); }
{PARAGRAPH}	{ out("\n"); out("\n"); }
{ORDERED_LIST}		{ list_level = MIN(list_level+1, MAX_LIST_LEVEL); set_list_type(1); }
{UNORDERED_LIST}	{ list_level = MIN(list_level+1, MAX_LIST_LEVEL); set_list_type(0);}
{ORDERED_LIST_END}	{ list_level = MAX(list_level-1, 0); }
{UNORDERED_LIST_END}	{ list_level = MAX(list_level-1, 0); }
{LISTITEM}	{ out("\n"); out_list_prefix(); }
{PRE}		{ in_pre = 1; out("\n "); }
{PRE_END}	{ in_pre = 0; out("\n"); }
{EMPHASIZE}	{out("''");}
{EMPHASIZE_END}	{out("''");}
{HR}		{out("\n----\n");}
\<a{SPACE}+	currentlink = NOLINK; BEGIN(hlink);
{HYPERTEXT_END}	{
		disable_newlines--;
		if (currentlink == NORMAL_LINK) {out("]");}
		else if (currentlink == WIKI_LINK) {out("]]");}
		}
{OUTPUT_AS_IS}	{out(yytext); }
{COMMENT}	{ /* Remove comment, even if tags embedded in it.
		     Note: This doesn't fully handle CDATA[. */ }
{MICROSOFT_JUNK}	{ /* Remove this generated empty paragraph. */ }
\<[^a>][^>]*\>	/* Remove unhandled HTML tags - coded this way so <a works. */
\<a[^> \t\n]*\>	/* Remove unhandled HTML tags */
\<\>		/* Weird special case: remove <> */
^[ \t]+		{if (in_pre) {out(yytext);} /* Remove bad leading spaces */}
[ \t]+		{if (in_pre) {out(yytext);} else {out(" ");}}
^\#		{out("&#35;"); /* Initial # is special to Wikipedia */ }
^\*		{out("&#42;"); /* Initial * is special to Wikipedia */ }
\[		{out("&#91;"); /* Character [ is special to Wikipedia */ }
''		{out("'&#39;"); /* Don't misinterpret doubled ' */}
\221		{out("&#8216;"); /* 0x91 - Windows left single quote */}
\222		{out("&#8217;"); /* 0x92 - Windows right single quote */}
\223		{out("&#8220;"); /* 0x93 - Windows left double quote */}
\224		{out("&#8221;"); /* 0x94 - Windows right double quote */}
\r		{ /* Do nothing */ }
\n		{
		if (disable_newlines) out(" ");
		else out("\n");
		if (in_pre) out(" ");
		}
[a-z0-9.,;]+	out(yytext); /* bulk match; this speeds processing */
.		out(yytext);


<hlink>href=\"?{WIKI_PREFIX}	BEGIN(wiki_url);
<hlink>href=\"?			BEGIN(link_url);
<hlink>[^>"= \t\n\f]+		/* skip */
<hlink>=			/* skip - handle separately so href triggers */
<hlink>\"[^"]*\"		/* skip ".." */
<hlink>{SPACE}+			/* skip spaces. */
<hlink>\>			BEGIN(INITIAL);	/* Done with <a...> */

<wiki_url>[^>" \t\n\r]*		{
	currentlink=WIKI_LINK;
	out("[[");
	/* TODO: _=>space */
	out(yytext);
	out("|");
	disable_newlines++;
	BEGIN(link_consume);
	}

<link_url>[^>" \t\n\r]*		{
	currentlink=NORMAL_LINK;
	out("[");
	out(yytext);
	out(" ");
	disable_newlines++;
	BEGIN(link_consume);
	}

<link_consume>[" \t\n\r]*	BEGIN(hlink);


%%

