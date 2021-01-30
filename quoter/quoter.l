%{

/* quoter by David A. Wheeler (http://www.dwheeler.com).
   This is a filter that fixes quotation marks, etc., in HTML files.
   As a filter, send HTML in as standard input; results are in stdout.

   This handles the nasty incompatible curly single and double quotation
   marks from Windows (charset=windows-1252).
   For the contents of that charset:
   http://www.unicode.org/Public/MAPPINGS/VENDORS/MICSFT/WINDOWS/CP1252.TXT
   Right now it ALWAYS converts.  Can I rely on the charset value, and
   only do it then?  Should I convert others, esp. N dash and M dash?

   If you have really awful HTML,
   consider passing it first through the "Demoroniser" script:
     http://www.fourmilab.ch/webtools/demoroniser

   Must use -i ignore case.

*/

#include <stdio.h>
#include <ctype.h>
#include <string.h>

#define MIN(a,b) ( (a) < (b) ? (a) : (b) )
#define MAX(a,b) ( (a) > (b) ? (a) : (b) )


void out(char *text) {
	fputs(text,stdout);
}

void outchar(char c) {
	fputc(c, stdout);
}

/*
 Provide main().
 By doing this, we don't need a linker option later
 (which would be -lfl on Linux, -ll on MacOS). Providing main() also
 eliminates the need to install additional run-time packages on some systems.
 See: https://stackoverflow.com/questions/26064096/
 using-flex-the-lexical-analizer-on-os-x
*/
extern int yylex(void);

int main() {
	while (yylex());
	return 0;
}

%}
%option noyywrap


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
HR		\<hr{ATTRIBUTES}?>

%x pre
%x tt
%x comment
%x script

%%
\'\'\'+		{ out(yytext); }
\"\"\"+		{ out(yytext); }
```+		{ out(yytext); }

``		{ out("&#8220;"); }
^(''|\")	{ out("&#8220;"); }
(''|\")$	{ out("&#8221;"); }
[ \t](\"|'')	{ outchar(yytext[0]);  out("&#8220;"); }
(\(|\[|\{)(\"|'') { outchar(yytext[0]); out("&#8220;"); }
(\"|'')		{ out("&#8221;"); }

`		{ out("&#8216;"); }
^'		{ out("&#8216;"); }
[ \t]'		{ outchar(yytext[0]); out("&#8216;"); }
(\(|\[|\{)\'	{ outchar(yytext[0]); out("&#8216;"); }
'		{ out("&#8217;"); }

\221		{out("&#8216;"); /* 0x91 - Windows left single quote */}
\222		{out("&#8217;"); /* 0x92 - Windows right single quote */}
\223		{out("&#8220;"); /* 0x93 - Windows left double quote */}
\224		{out("&#8221;"); /* 0x94 - Windows right double quote */}

\342\200\231    {out("&#8217;"); /* Seamonkey botch */}
\342\200\230    {out("&#8216;"); /* Seamonkey botch */}
\342\200\234    {out("&#8220;");}
\342\200\235    {out("&#8221;");}
\342\200\&\#8221\; {out("&mdash;");}

\<pre{ATTRIBUTES}?\>	{out(yytext); BEGIN(pre); }
\<tt{ATTRIBUTES}?\>	{out(yytext); BEGIN(tt); }
\<script{ATTRIBUTES}?\>	{out(yytext); BEGIN(script); }
\<\!\-\-	{out(yytext); BEGIN(comment); }

\<li{ATTRIBUTES}?\>\"	{out(yytext); out("&#8220;"); }
\<i{ATTRIBUTES}?\>\"	{out(yytext); out("&#8220;"); }
\<b{ATTRIBUTES}?\>\"	{out(yytext); out("&#8220;"); }
\<p{ATTRIBUTES}?\>\"	{out(yytext); out("&#8220;"); }
\<td{ATTRIBUTES}?\>\"	{out(yytext); out("&#8220;"); }

\<li{ATTRIBUTES}?\>\'	{out(yytext); out("&#8216;"); }
\<i{ATTRIBUTES}?\>\'	{out(yytext); out("&#8216;"); }
\<b{ATTRIBUTES}?\>\'	{out(yytext); out("&#8216;"); }
\<p{ATTRIBUTES}?\>\'	{out(yytext); out("&#8216;"); }
\<td{ATTRIBUTES}?\>\'	{out(yytext); out("&#8216;"); }

\<[A-Za-z0-9_-]+{ATTRIBUTES}?\>	{out(yytext);  /* Ignore other tags */}
\<![A-Za-z0-9]+{ATTRIBUTES}?\>	{out(yytext);  /* <!DOCTYPE etc. 
	        Handle "!" specially so comment processing is correct. */}

[a-z0-9.,;]+	{ out(yytext); /* bulk match; this speeds processing */ }
.		{ out(yytext); }


<pre>\<\/pre{ATTRIBUTES}?\>	{ out(yytext); BEGIN(INITIAL); }
<pre>.		{ out(yytext); }

<tt>\<\/tt{ATTRIBUTES}?\>	{ out(yytext); BEGIN(INITIAL); }
<tt>.		{ out(yytext); }

<script>\<\/script{ATTRIBUTES}?\>	{ out(yytext); BEGIN(INITIAL); }
<script>.		{ out(yytext); }

<comment>\-\-\>	{ out(yytext); BEGIN(INITIAL); }
<comment>[^->\n\r]+	{ out(yytext); }
<comment>.		{ out(yytext); }


%%

