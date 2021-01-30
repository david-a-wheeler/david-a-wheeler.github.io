; curly-infix.cl (Common Lisp), 2007-12-31
; Implements an infix reader macro: {...} surrounds an infix expression.
; E.G., {2 + 3 + 4} is transformed at read time into (+ 2 3 4), and
; {2 + {3 * 4}} transforms into (+ 2 (* 3 4)).
; This is useful when you want simple yet flexible infix capabilities,
; without complications. It's also a VERY simple implementation, so there's
; less to "go wrong".  You can optionally use it in conjunction with an
; execution/compile-time macro to support precedence, if you want.
;
; Copyright (C) 2007 by David A. Wheeler.
;
; This reader macro is invoked on expressions surrounded by {...}, and
; presumes that all infix operators are surrounded by whitespace.
; If the expression has (1) an odd number of parameters,
; (2) at least 3 parameters, and (3) all the even parameters are equal symbols,
; then it's "simple infix" and maps to (even-parameter odd-parameters).
; Otherwise, it's not simple, and it maps to (nfx parameters).
; Thus:
;  {2 * n}       maps to (* 2 n)
;  {x eq y}      maps to (eq x y)
;  {2 + 3 + 4}   maps to (+ 2 3 4)   - chaining/fungibility works
;  {2 + {3 * 4}} maps to (+ 2 (* 3 4)) - Nesting works + keeps things simple
;  {2 + 3 * 4}   maps to (nfx 2 + 3 * 4) - non-simple.
;
; If you always use simple infix expressions, e.g., by never mixing
; operators in the same list, then every list (after reading)
; will have the traditional order of operator-first. This means that simple
; infix expressions can be used inside ANY execution/compile-time macro.
; In simple infix expressions you can use ANY function name as an
; infix operator, e.g., {"hi" equal "hi"} works quite well - and you do
; not need to register any function name before you use it.
; You can nest simple infix expressions to keep each one simple, e.g.,
; {2 + {3 * 4}}.  You can nest ordinary lists too, e.g., to use
; prefix functions.  Thus {(- x) / 2} maps to (/ (- x) 2).
;
; If you want automatic precedence, define a macro named "nfx"
; and have it implement the precedence. Note that if another macro recurses
; into the nfx expression BEFORE nfx has a chance to modify its parameters,
; the other macro will see the lists in a different order than it may expect.
; Precedence is intentionally NOT handled by this reader macro,
; because it's easy to get precedence quietly wrong when using a reader macro.
; Instead, this reader macro is designed to work WITH an execution-time
; macro if that's desired.
;
; If want to avoid using an "nfx" macro entirely, just define the
; "nfx" macro as an error.
;
; Warning: if you use an "nfx" macro, don't have nfx override the name
; an existing function, or it will be confusing to use.  E.G., if
; "nfx" renames "=" as "setf", then you could have this confusing case:
; {x = 3 * 4} maps to (nfx x = 3 * 4) maps to (setf x (* 3 4)), but
; {x = 3} maps to (= x 3) which is a comparison, not a value-setting operation.
; Instead, create normal functions/macros for each infix operator and just
; use them directly, e.g., use "<-" for assignment and define a macro
; to do what you want.
;
; Pros:
; * Easy to use: Can use ANY operator name as infix, WITHOUT any registration
; * Syntax makes obvious where new lists occur (no "hidden list creation")
; * Easily understood/verified implementation - less to "go wrong"
; * Works 100% trivially with execution macros, particularly if only
;   "simple" infix forms are used.
; * No precedence list that must be memorized (unless you use an "nfx" macro)
; * Can work with an nfx macro (which COULD implement precedence) if needed
; Cons:
; * Doesn't support traditional prefix notation, e.g., - x. Must use (- x).
; * Doesn't directly support precedence (if you want that) - nfx macro
;   must do that.
; * Doesn't rename functions, or give them new infix names.  You can define
;   functions/macros with traditional infix names separately, if desired.
;
; 
; Released under the "MIT license":
; Permission is hereby granted, free of charge, to any person obtaining a
; copy of this software and associated documentation files (the "Software"),
; to deal in the Software without restriction, including without limitation
; the rights to use, copy, modify, merge, publish, distribute, sublicense,
; and/or sell copies of the Software, and to permit persons to whom the
; Software is furnished to do so, subject to the following conditions:
; 
; The above copyright notice and this permission notice shall be included
; in all copies or substantial portions of the Software.
; 
; THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
; IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
; FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
; THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR
; OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
; ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
; OTHER DEALINGS IN THE SOFTWARE.

; Utility functions to implement the simple infix system:

; Return true if lyst has an even # of parameters, and the (alternating) first
; ones are "op".  Used to determine if a longer lyst is infix.
; Otherwise it returns NIL (False).
; If passed empty list, returns true (so recursion works correctly).
(defun even-and-op-prefix (op lyst)
   (cond
     ((null lyst) t)
     ((not (consp lyst)) nil) ; Not a list.
     ((not (eq op (car lyst))) nil) ; fail - operators not all equal.
     ((null (cdr lyst)) nil) ; fail - odd # of parameters in lyst.
     (t (even-and-op-prefix op (cddr lyst))))) ; recurse.

; Return True if the lyst is in simple infix format (and should be converted
; at read time).  Else returns NIL.
(defun simple-infix-listp (lyst)
  (and
    (consp lyst)           ; Must have list;  '() doesn't count.
    (consp (cdr lyst))     ; Must have a second argument.
    (consp (cddr lyst))    ; Must have a third argument (we check it
                           ; this way for performance)
    (symbolp (cadr lyst))  ; 2nd parameter must be a symbol.
    (even-and-op-prefix (cadr lyst) (cdr lyst)))) ; even parameters equal?

; Return alternating parameters in a lyst (1st, 3rd, 5th, etc.)
(defun alternating-parameters (lyst)
  (if (or (null lyst) (null (cdr lyst)))
    lyst
    (cons (car lyst) (alternating-parameters (cddr lyst)))))

; Transform a simple infix list - move the 2nd parameter into first position,
; followed by all the odd parameters.  Thus (3 + 4 + 5) => (+ 3 4 5).
(defun transform-simple-infix (lyst)
   (cons (cadr lyst) (alternating-parameters lyst)))


; The following install the {...} reader.
; See "Common Lisp: The Language" by Guy L. Steele, 2nd edition,
; pp. 542-548 and pp. 571-572.


; Read until }, then process list as infix list.
; If it's a simple infix list (odd # parameters, 3+ parameters, all even
; parameters are equal symbols) then transform to infix. E.G.,
;   {3 + 4 + 5} => (+ 3 4 5).
; Otherwise, transform to (nfx list), and presume that some macro named
; "nfx" will take care of things.
(defun curly-brace-infix-reader (stream char)
  (declare (ignore char))
  (let ((result (read-delimited-list #\} stream t)))
    (if (simple-infix-listp result)
       (transform-simple-infix result) ; Simple infix expression.
       (cons 'nfx result)))) ; Non-simple; prepend "nfx" to the list.

; Invoke curly-brace-infix-reader when "{" is read in:
(set-macro-character #\{ #'curly-brace-infix-reader)

; This is necessary, else a cuddled } will be part of an atom: 
(set-macro-character #\} (get-macro-character #\) nil))

