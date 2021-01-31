/* encodef - encode/decode filenames or similar data.
 *
 * USAGE:
 *  encodef [options] [ -- [filenames] ]
 *
 * Encode/decode filenames or other data, with a variety of
 * encodings and options.  This makes it easier to handle filenames
 * with "unusual" bytes like newline or tab, while using ordinary
 * text-processing utilities.
 *
 * Without the "-d" option, it ENCODES data;
 * with the "-d" option, it DECODES data.
 * If "--" is an option, then any following arguments are
 * encoded/decoded in turn, and stdin is ignored.  If there is no "--", then
 * stdin is read, and the resulting encoding/decoding is sent to stdout.
 *
 * This generates a newline-terminated list of values in
 * printf(1) "%b" (pfb) format.  The pfb format uses "\" as the escape
 * character; \n = newline, \t = tab, \r = return, \0ddd = octal value
 * (where ddd is a 0-3 digit value; digits must be unambiguous).
 * This converts all characters except ".", "/", "_", and ASCII alphanumerics
 * into escaped pfb format; this produces "safe" filenames that are
 * easily processed, since control characters (inc. newline and tab),
 * space, dash, and many other troublesome characters are encoded.
 * Escaping uses octal codes except for newline, tab, and return.
 * We encode "\" using the octal escape, and *not* as \\, so that
 * the sequence \<newline> never occurs.
 * WARNING: There are many OTHER formats that use \ as the escape character,
 * and most are subtly incompatible with each other.  Note that in pfb
 * \0001 is control-A, and NOT \0 1.  Note that '\ ' and '\"' are
 * not supported by pfb.
 *
 * If called with 1 or more arguments, the first argument MUST be "--";
 * all arguments after that are printed in pfb format; each encoded
 * argument is terminated by newline.
 * This means you can do this in shell:
 *    for ef in `find . -exec encodef -- {} \+` ; do
 *      filename="$(printf "%bX" "$ef")" ; filename="${filename%X}" ...
 * If it is called with 0 arguments, it operates as a filter that
 * converts null-byte-terminated lists to pfb format. In this case,
 * an embedded newline is output as \0.  This means you can do this:
 *    for ef in `find . -print0 | encodef` ; do
 *      filename="$(printf "%bX" "$ef")" ; filename="${filename%X}" ...
 * This can be useful with filenames; see
 *    http://www.dwheeler.com/essays/filenames-in-shell.html
 *
 * Possible future extensions:
 *  - "-d" for "decode"?  or create a separate decodef program?
 *
 *  WHEN ENCODING - OUTPUT:
 *  - pfb -b
 *  - support %xx escaping (-p for "percent encoding"?)
 *  - support XML escaping, e.g., &lt; (-X for "XML encoding"?)
 *  - xargs escaping instead (ugh!) (-x for xargs?)
 *  - support C-string-style escaping instead. (-c), e.g., \5 and \".
 *  - null byte escaping (useful if given arguments) (-0)
 *  - Generate \0 when given null byte; only useful in filter mode (-z).
 *  - when encoding, encode escape char as duplicate (e.g., %% for %) (-2?)
 *
 *  WHEN DECODING - the previous ones describe the *input*.  Also:
 *  - Append 'Y' to end of output, to work with shell (shell strips trailing
 *    newlines; adding 'Y' to the end means you can get it, and then strip
 *    the ending 'Y', so you don't lose data). -Y?
 *  - Escape so it's suitable for xargs
 *  - If multiple filenames, by default separate with \0.
 *  - Control if last output terminates with \0 or not (default no).
 *  - Control if use \n instead of \0 output between/end of filenames.
 *
 *  WHEN ENCODING - WHAT IS ENCODED:
 *  - permit 128..255 to go through unescaped (-h for "high bit"?)
 *  - Don't escape characters in 33..126 range (-r for "reduced encoding?")
 *    It still has to encode the escape character.
 *  - The list is a list of filenames to read and go through a filter (-l)
 *  - The following is a filename containing files to be filtered (-f)
 *  - Could say "don't encode high-bit-chars if legal UTF-8", but that
 *    would require changing how the code works because multiple bytes
 *    must be analyzed to determine that. (-U?)
 * I expect to always *REQUIRE* a "--" before non-option arguments, because
 * the primary use is for filenames.  Since filenames can begin with "-",
 * and such filenames might be set by an attacker, requiring "--" makes
 * this program much safer to use.
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
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>
#include <ctype.h>
#include <assert.h>

/* Since we never use setlocale(), we will use the raw data of locale "C".
 * That's just what we want, since the locale settings need not match
 * the data we're processing.  */

/* This code should be correct even if char is signed.
 * It should work fine on any system, even those using EBCDIC. */

/* Option settings */
static int encoding;  /* Encoding system to use */
#define ENCODING_PFB 0         /* "Extra 0" */
#define ENCODING_BACKSLASH 1  /* Traditional backslash: \0400 is "space 0" */
#define ENCODING_PERCENT 10   /* %hh */

static int what_to_encode;
#define ENCODE_LOTS 0
#define ENCODE_CONTROL_SPACE 1
#define ENCODE_CONTROL 2

static bool decode; /* True if we're decoding instead of encoding */
static bool ymode;  /* True if "Ymode" - postfix filenames with Y, so that
                     * filenames ending in \n won't get their name
                     * consumed by sh(1)'s command substitution */


static int curr; /* Current byte to output */
static int prev; /* Previous byte that was already output */


/* Return "true" if current byte "curr" should be escaped */
bool should_escape()
{
  assert(curr != -1);
  if ((curr == '-') && ((prev == -1) || (prev == '/'))) {
    /* Always escape '-' if it's the leading char of a pathname component;
     * it often causes confusion with the option char "-" */
    return true;
  } else if (what_to_encode == ENCODE_CONTROL) {
    return iscntrl(curr);
  } else if (what_to_encode == ENCODE_CONTROL_SPACE) {
    return (curr == ' ') || iscntrl(curr);
  } else {
    /* Default: only leave alphanumerics, "/", ".", "_", "-" alone
     * ("-" is escaped if it's the leading char of a pathname component).
     * By default we escape whitespace, control chars, globbing chars, etc.
     * We'll escape ":" so that it's not misunderstood as a URI.
     * This escapes UTF-8 and other non-alphas, but that is a GOOD thing;
     * there is no way to be certain that a byte is of any particular
     * encoding */
    if (isalnum(curr) || (curr == '/') || (curr == '.') || (curr == '_')
        || (curr == '-'))
      return false;
    else
      return true;
  }
}

/* Send to stdout the encoding of byte "curr" which is being followed
 * by passed-in "next".  If "nullnewline" is true, output char 0 as newline.
 * You must call begin_encoding before using this. */
void encodeb(int next)
{
  bool escapeit;

  if (curr == -1) {  /* We haven't output anything yet; store this byte */
    curr = next;
    return;
  }

  if (encoding == ENCODING_PERCENT) {
    escapeit = should_escape();
    if (curr == '%') escapeit = true; /* MUST escape the escape char */
    /* Now output it, escaped if necessary */
    if (escapeit)
      if (curr == 0)
        putchar('\n');
      else
        printf("%%%.2x", ((unsigned int) curr));
    else
      putchar(curr);
  } else {
    switch (curr) {
      case   0 : putchar('\n'); break;  /* TODO */
      case '\\': fputs("\\\\", stdout); break;
      case '\a': fputs("\\a", stdout); break;
      case '\b': fputs("\\b", stdout); break;
      case '\f': fputs("\\f", stdout); break;
      case '\n': fputs("\\n", stdout); break; /* In EBCDIC, this is >32 */
      case '\r': fputs("\\r", stdout); break;
      case '\t': fputs("\\t", stdout); break;
      case '\v': fputs("\\v", stdout); break;
      default:
        escapeit = should_escape();
        if (curr == '\\') escapeit = true; /* MUST escape the escape char */
  
        /* Now output it, escaped if necessary */
        if (escapeit) {
          putchar('\\'); /* It's escaped, output the escape char */
          if (encoding == ENCODING_PFB) putchar('0'); /* Output "extra 0" */
          if (isdigit(next)) {
            /* A digit follows, so use the unambiguous 3-digit format. */
            printf("%.3o", ((unsigned int) curr));
          } else {
            /* We can use a "shorter form", so we'll do so.
             * Other than the null byte, we'll use at least 2 digits;
             * that way, it cannot be mistaken for a backreference.
             * Since \0 cannot be a backreference, and \0 is the usual
             * format for the null byte, we *will* output \0. Outputting
             * 2+ digits is not necessary, but it seems like a good idea
             * and emulates other tools that do this.
             * Note that localedef does this per
             * POSIX.1-2008 Vol. 1 section 7.3 (3).
             * The POSIX rationale for the Character Set Description File,
             * POSIX.1-2008 Rationale section A.6.4, says:
             * "The octal number notation with no leading zero required
             * was selected to match those of awk and tr and is
             * consistent with that used by localedef.
             * To avoid confusion between an octal constant and
             * the back-references used in localedef source, the octal,
             * hexadecimal, and decimal constants must
             * contain at least two digits." */
            if (curr == 0) { /* ENCODING_PFB already has \0, don't dup */
              if (encoding != ENCODING_PFB) putchar('0');
            } else {
              printf("%.2o", ((unsigned int) curr));
            }
          }
        } else {
          putchar(curr);
        }
        break;
    }
  }
  /* Finished processing curr; consume it and establish new state */
  prev = curr;
  curr = next;
}

void begin_encoding()
{
  curr = prev = -1;
}



int fromhex(int c) {
  switch (c) {
    case '0': return 0;
    case '1': return 1;
    case '2': return 2;
    case '3': return 3;
    case '4': return 4;
    case '5': return 5;
    case '6': return 6;
    case '7': return 7;
    case '8': return 8;
    case '9': return 9;
    case 'a': case 'A': return 10;
    case 'b': case 'B': return 11;
    case 'c': case 'C': return 12;
    case 'd': case 'D': return 13;
    case 'e': case 'E': return 14;
    case 'f': case 'F': return 15;
    default: return 0;
  }
}

/* Return true if octal digit, else return false */
bool isodigit(int c)
{
  switch (c) {
    case '0': case '1': case '2': case '3':
    case '4': case '5': case '6':
      return true;
    default:
      return false;
  }
}

static int store[7]; /* The "store" of submitted values to decode */
static int num_store;

/* Print state of store.  Not used directly; left here for debugging */
void print_store()
{
  int i;
  printf("Store (size=%d) is now:", num_store);
  for (i = 0; i < num_store; i++)
    printf(" %c", store[i]);
  printf("\n");
}

/* Shift (remove) bytes in storage by "amount" */
void shift(int amount)
{
  int i;
  for (i = amount; i < num_store ; i++) {
    store[i - amount] = store[i];
  }
  num_store -= amount;
}

/* Send in a byte c for decoding */
void decodeb(int c)
{
  int i;
  int numleft;
  int currentvalue;
  store[num_store++] = c;

  if (encoding == ENCODING_PERCENT) {
    if (c <= 0) {  /* Stop decoding */
      num_store--;
      if (num_store > 0) {
        /* %hh ended prematurely; output the undecoded characters. */
        putchar(store[0]);
        if (num_store > 1) putchar(store[1]);
      }
      num_store = 0;
    } else if (store[0] != '%') { /* Normal byte, just output it. */
      assert((num_store == 1) && (store[0] == c));
      putchar(c);
      num_store = 0;
    } else if ((num_store == 2) && (c == '%')) {
      /* Decode %% */
      assert((store[0] == '%') && (store[1] == '%'));
      putchar('%');
      num_store = 0;
    } else if (num_store >= 3) {
      assert(store[0] == '%');
      if (isxdigit(store[1]) && isxdigit(store[2])) {
        putchar(fromhex(store[1])*16+fromhex(store[2]));
      } else {
        /* Bad hh after %; just print the bytes. */
        putchar(store[0]);
        putchar(store[1]);
        putchar(store[2]);
      }
      num_store -= 3; /* Consume 3 characters */
    } /* Else, we're still reading in a %xx expression, so do nothing yet */
  } else { /* ENCODING_PFB or ENCODING_BACKSLASH */
    while ((num_store > 0) && (store[0] != '\\') && (store[0] != -1)) {
      /* Handle bytes not beginning with "\" */
      putchar(store[0]);
      shift(1);
    }
    if ((num_store == 1) && (c < 0)) {
      num_store--; /* We're at EOF, do nothing */
    } else if ((c < 0) || (num_store >= 6)) {
      /* A \, followed by enough characters to be unambiguous */
      if (store[0] != '\\') {
        printf("Uh oh, store[0] = %d\n", store[0]);
      }
      assert(store[0] == '\\');
      for (;;) {
        assert(num_store >= 0);
        if (num_store == 0) break;  /* Nothing left to process */
        if (store[0] != '\\') {
          putchar(store[0]);
          shift(1);
          break;
        }
        if (num_store == 1) {  /* One char with nothing following it. */
          putchar(store[0]);
          shift(1);
          break;
        }
        switch (store[1]) {
          case '\\': putchar('\\'); shift(2); break;
          case 'a': putchar('\a'); shift(2); break;
          case 'b': putchar('\b'); shift(2); break;
          case 'f': putchar('\f'); shift(2); break;
          case 'n': putchar('\n'); shift(2); break;
          case 'r': putchar('\r'); shift(2); break;
          case 't': putchar('\t'); shift(2); break;
          case 'v': putchar('\v'); shift(2); break;
          /* NOT HANDLED: \c in printf %b: "produce no further output" */
          /* NOT HANDLED: \hXX */
          case '0': case '1': case '2': case '3':
          case '4': case '5': case '6':
            /* Handle \octaldigits, including PFB's \0octaldigits */
            i = 1; /* i points to the current octal character */
            if ((encoding == ENCODING_PFB) && (store[1] == '0')) {
              /* PFB has a weird extra "0" after \; handle that */
              i++;
              if (!isodigit(store[2])) { /* Must handle specially */
                putchar('\0'); shift(2); break;
              }
            }
            numleft = 3;
            currentvalue = 0;
            /* Handle 1-3 digit octal value. */
            while ((numleft > 0) && (isodigit(store[i]))) {
              currentvalue = currentvalue * 8 + (store[i] - '0');
              i++;
              numleft--;
            }
            putchar(currentvalue);
            shift(i);
            break;
          default:
            putchar(store[1]); shift(2); break; /* Print following byte */
        }
        if (c >= 0) break; /* More characters to read, so don't do more. */
        if (num_store == 0) break; /* Nothing left to process. */
      }
    } /* Otherwise, let's just read the next character in */
  }
  if ((c <= 0) && ymode) putchar('Y');
  /* TODO: Output \0 separators/terminators */
}

void begin_decoding()
{
  num_store = 0;
}


void process_options(const char *options)
{
  const char *p;
  if (options[1] == '-') {
    fprintf(stderr, "No longname options available\n");
    exit(1);
  }
  for (p=options+1; *p; p++)
    switch (*p) {
      case 'd':  decode = true; break;
      case 'U':  encoding = ENCODING_PERCENT; break;
      case 'b':  encoding = ENCODING_PFB; break;
      case 'B':  encoding = ENCODING_BACKSLASH; break;
      case 'Y':  ymode = true; break;
      case 'C':  what_to_encode = ENCODE_CONTROL; break;
      case 'S':  what_to_encode = ENCODE_CONTROL_SPACE; break;
      default:
        fprintf(stderr, "Unknown option %c\n", *p);
        exit(1);
    }
}

int main(int argc, const char* argv[])
{
  int i, c;
  char *p;
  int num_parameters = argc - 1;

  /* Set up defaults */
  encoding = ENCODING_PERCENT; /* Should it be ENCODING_PFB? */
  what_to_encode = ENCODE_LOTS;
  decode = false;
  ymode = false;

  /* Process arguments */
  for (i = 1; i <= num_parameters; i++) {
    if (!strcmp(argv[i], "--")) break; /* Stop processing with -- */
    if (!strcmp(argv[i], "-")) {
      fprintf(stderr, "Single '-' not accepted\n");
      exit(1);
    } else if ((argv[i])[0] != '-') {
      fprintf(stderr, "Must separate filenames from options with '--'\n");
      exit(1);
    } else process_options(argv[i]);
  }

  if (decode) {
    if (i <= num_parameters) {
      if (strcmp(argv[i], "--")) {
        fprintf(stderr, "First non-option must be '--'.\n");
        exit(1);
      }
      /* Process remaining argument list as a set of unescaped filenames */
      for (i++; i <= num_parameters; i++) {
        begin_encoding();
        for (p = (char *) argv[i]; *p != 0; p++)
          decodeb(*p);
        /* Send the terminator */
        decodeb(-1);
      }
    } else {
      /* Process stdin as a set of filenames; filenames are
         terminated by newline or null byte.  */
      begin_encoding();
      while ( (c = getchar()) != EOF) {
        if (c == '\n')  decodeb(0);
        else            decodeb(c);
      }
      decodeb(-1); /* Output the last byte. */
    }
  } else {  /* Encode, not decode */
    if (i <= num_parameters) {
      if (strcmp(argv[i], "--")) {
        fprintf(stderr, "First non-option must be '--'.\n");
        exit(1);
      }
      /* Process remaining argument list as a set of unescaped filenames */
      for (i++; i <= num_parameters; i++) {
        begin_encoding();
        for (p = (char *) argv[i]; *p != 0; p++)
          encodeb(*p);
        /* Send the terminator */
        encodeb(0);
        encodeb(-1);
      }
    } else {
      /* Process stdin as a set of null-byte-terminated values.  Null byte
       * termination is a common for handling "bad" filenames, and this lets
       * people transition from null byte termination to another encoding. */
      begin_encoding();
      while ( (c = getchar()) != EOF)
        encodeb(c);
      encodeb(-1); /* Output the last byte. */
    }
  }
  return 0;
}

