/* null2pfb - a filter that converts null-byte-terminated lists to the
 * printf(1) "%b" format.  This can be useful with filenames; see
 * http://www.dwheeler.com/essays/filenames-in-shell.html
 *
 * Released under the "MIT/X11" license.
 * Copyright (c) 2010 David A. Wheeler
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

#include <stdio.h>
#include <stdbool.h>
#include <ctype.h>

/* Since we never use setlocale(), we will use the raw data of locale "C".
 * That's just what we want, since the locale settings need not match
 * the data we're processing.  */

/* This code should be correct even if char is signed.
 * It should work fine on any system, even those using EBCDIC. */


/* Returns true if the next character is a digit, without consuming it. */
bool isnextdigit(void)
{
  int c = getchar();
  (void) ungetc(c, stdin);
  return isdigit(c);
}

main()
{
  int c;
  while ( (c = getchar()) != EOF) {
    switch (c) {
      case   0 : putchar('\n'); break;
      case '\n': fputs("\\n", stdout); break; /* In EBCDIC, this is >32 */
      case '\t': fputs("\\t", stdout); break;
      case '\r': fputs("\\r", stdout); break;
      case '\\': fputs("\\\\", stdout); break; /* Escape the escape char */
      default:
        if (isalnum(c) || (c == '/') || (c == '.') || (c == '_')) {
          putchar(c);
        } else {
          // Escape whitespace, control chars, globbing chars, etc.
          // We'll even escape "-", since leading "-" can cause trouble.
          // We'll escape ":" so that it's not misunderstood as a URI.
          if (isnextdigit()) {
            // A digit follows, so use the unambiguous 3-digit format.
            printf("\\%0.3o", ((unsigned) c));
          } else {
            // We can use the "short form":
            printf("\\%o", ((unsigned) c));
          }
        }
        break;
    }
  }
}


