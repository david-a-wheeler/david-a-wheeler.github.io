/* regex.c - Demonstrate regular expressions
   by David A. Wheeler
   Released under the "MIT" license (see below).

   When compiling with gcc, compile it using:
      gcc -Wall -Wextra -pedantic regex.c -o regex

This lets you experiment with POSIX "Extended Regular Expressions" as
implemented by the POSIX standard's regexec().  In this language:
.       Matches any single character (including newline)
[list]  Matches a single character contained in the brackets.
        Ranges using "-" are supported; "-" is a literal if first or last.
        Negate by beginning with ^ inside [ ].
^       Matches the starting position.  MUST USE if want to match whole string.
$       Matches the ending position.  MUST USE if want to match whole string.
\       Escape character; a following metacharacter loses its meaning.
        Use \\ for backslash itself.
(...)   Subexpression; treat the entire expression as one expression.
|       Alternative.  "cat|dog" matches either "cat" or "dog".

*       Matches the preceding element zero or more times.
+       Matches the preceding element one or more times.
?       Matches the preceding element zero or one times ("optional")
{m,n}   Matches the preceding element at least m and not more than n times.


Note that *Extended* not *Basic* is used.  Also, note that:
* REG_NEWLINE is NOT enabled, so NEWLINE is an ordinary character with ".".
  This means that "^" and "$" do not search for newlines in the middle
  of the text to evalute (to treat specially).
* REG_ICASE is NOT enabled, so upper and lower case are distinct.
* No locale setting is done, so this runs in "C" ("POSIX") locale.


   Some sample regular expressions you might try:
   Variable name for many programming languages:
     ^[_A-Za-z][_A-Za-z0-9]*$
   Decimal Numbers
     ^[0-9]+(\.[0-9]*)?([Ee][0-9]+)?$
   Lastname, Firstname[additional names]
     ^[A-Za-z'!]+,( [A-Za-z'!]+)+$
   Course Number:
     ^[A-Z]+ [0-9]+$
     ^[A-Z]{1,4} [1-9][0-9]{0,3}$

     

Copyright (c) 2010 David A. Wheeler

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
*/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <regex.h>


/* Strip away trailing newline, if any, of string s. */
void chomp(char *s)
{
  size_t last;
  if (!s || s[0]=='\0') return;
  last = strlen(s) - 1;
  if (s[last] == '\n') s[last] = '\0';
}


/* Repeatedly read text to match, report if it matches regex pattern p */
void try_matches(regex_t *compiled_pattern)
{
  int error;
  char test_pattern[1024];
  do {
    puts("");
    puts("Text to match:");
    fgets(test_pattern, sizeof(test_pattern), stdin);
    chomp(test_pattern);

    if (strlen(test_pattern) == 0) break; /* Loop-and-a-half */

    error = regexec(compiled_pattern, test_pattern, (size_t) 0, NULL, 0);
    if (error == 0) {
      puts("  MATCH");
    } else if (error == REG_NOMATCH) {
      puts("  NO MATCH");
    } else {
      puts("  REGEX FAILED!");
    }
  } while (1);
}



int main()
{
  int error;
  char pattern[1024];
  regex_t compiled_pattern;

  puts("regex - demonstrate regular expressions");
  do {
    puts("");
    puts("Enter regular expression (or empty string to stop):");
    fgets(pattern, sizeof(pattern), stdin); /* Guarantees \0 termination. */
    chomp(pattern);

    if (strlen(pattern) == 0) break; /* Loop-and-a-half */

    error = regcomp(&compiled_pattern, pattern, REG_EXTENDED | REG_NOSUB);
    if (error) {
      puts("Regex compilation failed");
      exit(error);
    }
    try_matches(&compiled_pattern);
    regfree(&compiled_pattern);
  } while (1);
  return 0;
}

