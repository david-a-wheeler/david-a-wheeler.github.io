; sweet-expr.scm
; by AmkG
; An implementation of sweet-expressions 0.2, plus
; some modifications:
;   Use some single character for GROUP, instead of the
;     lengthy keyword "group"
;   Follow the SPLICE rules, EXCEPT for "SPLICE at the
;      end of the line" rule.
;   Whitespace at top-level DISABLES I-expressions.

; Copyright (c) 2012 Alan Manuel K. Gloria
;
; Permission is hereby granted, free of charge,
; to any person obtaining a copy of this software
; and associated documentation files (the
; "Software"), to deal in the Software without
; restriction, including without limitation the
; rights to use, copy, modify, merge, publish,
; distribute, sublicense, and/or sell copies of
; the Software, and to permit persons to whom the
; Software is furnished to do so, subject to the
; following conditions:
;
; The above copyright notice and this permission
; notice shall be included in all copies or
; substantial portions of the Software.
;
; THE SOFTWARE IS PROVIDED "AS IS", WITHOUT
; WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
; INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
; MERCHANTABILITY, FITNESS FOR A PARTICULAR
; PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
; THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR
; ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
; IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
; ARISING FROM, OUT OF OR IN CONNECTION WITH THE
; SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
; SOFTWARE.

; scheme-specific code
(cond-expand
  (guile
    ; define the guile module
    (define-module (sweet-expr)
      :export (sweet-reader))
    (cond-expand
      (guile-2
        '())
      (else
        ; use syncase
        (use-modules (ice-9 syncase))))
    ; give the method for how to get
    ; srcinfo from ports and put
    ; srcinfo into expressions
    (define (get-srcinfo port) (list (port-filename port)
                                     (port-line port)
                                     (port-column port)))
    (define (put-srcinfo srcinfo expr)
      ; Guile can only put srcinfo into
      ; cons cells
      (cond
        ((pair? expr)
          (set-source-property! expr 'filename (list-ref srcinfo 0))
          (set-source-property! expr 'line     (list-ref srcinfo 1))
          (set-source-property! expr 'column   (list-ref srcinfo 2))))
      expr)
    ; give an error-reporting method
    (define (report-read-error s1 s2 msg)
      ; s1 is required, s2 is the end-of-range
      ; srcinfo and is optional (can be #f)
      (let ((ss1 (srcinfo->string s1))
            (ss2 (cond
                   (s2 (string-append "-" (srcinfo->string s2)))
                   (#t ""))))
        (error (string-append "read:" ss1 ss2 ": " msg))))
    (define (srcinfo->string s)
      (string-append (list-ref s 0)
                     ":"
                     (number->string (list-ref s 1))
                     ":"
                     (number->string (list-ref s 2))))
    ; we can probably reasonably assume Guile to
    ; use ASCII.
    (define cTAB       (integer->char 9))
    (define cCR        (integer->char 13))
    (define cVTAB      (integer->char 11))
    (define cFORMFEED  (integer->char 12))
    ; give a method for getting input ports
    ; from strings
    (define portable-open-input-string open-input-string)
    ; we already define the guile module
    ; above.  However some other scheme's
    ; need module contents inside an
    ; overarching s-expression; for
    ; compatibility with those scheme's
    ; we use module-contents to wrap them.
    ; On Guile we convert to (begin...)
    (define-syntax module-contents
      (syntax-rules ()
        ((module-contents expr ...)
          (begin expr ...)))))
  ; TODO: r6rs library wrapper around
  ; the module contents
  ; unknown Scheme implementations
  (else
    ; give dummy defaults
    (define (get-srcinfo port) '())
    (define (put-srcinfo srcinfo expr) expr)
    (define (report-read-error s1 s2 msg)
      (error (string-append "read: " msg)))
    ; assume ASCII, which is probably reasonable
    (define cTAB       (integer->char 9))
    (define cCR        (integer->char 13))
    (define cVTAB      (integer->char 11))
    (define cFORMFEED  (integer->char 12))
    ; assume SRFI-6 is implemented.
    (define portable-open-input-string open-input-string)
    ; give dummy module definition
    (define-syntax module-contents
      (syntax-rules ()
        ((module-contents expr ...)
          (begin expr ...))))))

(module-contents

; NB: we assume that the built-in read
; automatically attaches source info.
(define built-in-read read)

; stuff still under discussion as of 2012-07-01
(define (GROUP? c)  (eqv? c #\.))
(define (SPLICE? c) (eqv? c #\\)) ; disable SPLICE rules by returning #f
(define (postable-base-expr? x)
  (and (not (nothing? x))
       (or (pair? x) (symbol? x)))) ; change to _any expr_ by returning #t

; a special "nothing" return value that
; acts as a sentinel for all parsers.
(define nothing (cons '() '()))
(define (nothing? obj) (eq? obj nothing))

; wrapper to automatically use current-input-port
(define (sweet-reader . port)
  (cond
    ((null? port) (swt-rd (current-input-port)))
    (#t           (swt-rd (car port)))))

; wrapper to convert nothing return values to
; errors.
(define (swt-rd port)
  (let ((rv (swt-expr port)))
    (cond
      ((nothing? rv)
        (let* ((s (get-srcinfo port))
               (c (read-char port)))
        (report-read-error s #f (string-append "Unexpected character '" (string c) "'"))))
      (#t
        rv))))

(define any-space-char
  (list #\space cTAB cVTAB cFORMFEED cCR #\newline))
(define (any-space port)
  (let ((c (peek-char port)))
    (cond
      ((member c any-space-char)
        (read-char port)
        #t)
      ((eqv? c #\;)
        (consume-comment-loop port)
        #t)
      (#t
        nothing))))
(define (consume-comment-loop port)
  (let ((c (peek-char port)))
    (cond
      ((member c (list #\newline cCR))
        #t)
      (#t
        (read-char port)
        (consume-comment-loop port)))))
(define (any-space* port)
  (let (($1 (any-space port)))
    (cond
      ((nothing? $1)
        #t)
      (#t
        (any-space* port)))))

(define (mdn-expr port)
  (let* ((s (get-srcinfo port))
         (c (peek-char port)))
    (cond
      ; check for quote marks
      ((eqv? c #\')
        (read-char port)
        ; factored out common handling of quoted forms.
        (mdn-expr-qq 'quote s port))
      ((eqv? c #\`)
        (read-char port)
        (mdn-expr-qq 'quasiquote s port))
      ((eqv? c #\,)
        (read-char port)
        ; differentiate between , and ,@
        (let ((c (peek-char port)))
          (cond
            ((eqv? c #\@)
              (read-char port)
              (mdn-expr-qq 'unquote-splicing s port))
            (#t
              (mdn-expr-qq 'unquote s port)))))
      ; farm out to another parser
      (#t
        (mdn-expr-post-quote port)))))
(define (mdn-expr-qq $1 s port)
  (any-space* port)
  (let (($3 (mdn-expr port)))
    (cond
      ((nothing? $3)
        nothing)
      (#t
        (put-srcinfo s (list $1 $3))))))

(define (mdn-expr-post-quote port)
  ; NB: it is difficult to differentiate
  ; between postable and nonpostable if
  ; we operate at the level of characters
  ; and are restricted to one-character
  ; lookahead.  Instead of implementing
  ; base-expr-postable and base-expr,
  ; in this implementation we just
  ; implement base-expr and consider a
  ; base expression postable if it's a
  ; symbol or pair.
  (let (($1 (base-expr port)))
    (cond
      ((nothing? $1)
        ; failed
        nothing)
      ((postable-base-expr? $1)
        (let (($2 (post-mdn-expr port)))
          (cond
            ((nothing? $2)
              $1)
            (#t
              ($2 $1)))))
      (#t
        $1))))

; use explicit continuations.  In Guile < 2.0
; this is needed since otherwise C stack is
; used, and C stack is a much more limited
; resource than heap.
; For other schemes, we assume that the
; scheme stack is likely to be implemented
; as heap objects anyway, so the overhead
; is assumed to be low.
(define (post-mdn-expr port)
  (post-mdn-expr-loop port (lambda (e) e)))
(define (post-mdn-expr-loop port k)
  (let (($1 (post-mdn-expr-1 port)))
    (cond
      ((nothing? $1)
        k)
      (#t
        (post-mdn-expr-loop port
          (lambda (e)
            ($1 (k e))))))))
(define (post-mdn-expr-1 port)
  (let* ((s  (get-srcinfo port))
         ($1 (list-notation port)))
    (cond
      ((not (nothing? $1))
        (lambda (e) (put-srcinfo s (cons e $1))))
      (#t
        (let ((c (peek-char port)))
          (cond
            ((eqv? c #\[)
              (read-char port)
              (let (($2 (list-content port)))
                (cond
                  ((not (nothing? $2))
                    (let* ((s2 (get-srcinfo port))
                           (c  (peek-char port)))
                      (cond
                        ((eqv? c #\])
                          (read-char port)
                          (lambda (e) (put-srcinfo s (cons 'bracketaccess (cons e $2)))))
                        (#t
                          (report-read-error s s2 "Improperly terminated bracketaccess form")))))
                  (#t
                    (report-read-error s #f "Failed to parse inner expressions of bracketaccess form")))))
            (#t
              (let (($1 (curly-infix port)))
                (cond
                  ((not (nothing? $1))
                    (lambda (e) (put-srcinfo s (list e $1))))
                  (#t
                    nothing))))))))))

(define (list-notation port)
  (let* ((s (get-srcinfo port))
         (c (peek-char port)))
    (cond
      ((eqv? c #\()
        (read-char port)
        (let (($2 (list-content port)))
          (cond
            ((not (nothing? $2))
              (let* ((s2 (get-srcinfo port))
                     (c  (peek-char port)))
                (cond
                  ((eqv? c #\))
                    (read-char port)
                    $2)
                  (#t
                    (report-read-error s s2 "Improperly terminated list form")))))
            (#t
              (report-read-error s #f "Failed to parse inner expressions of list form")))))
      (#t
        nothing))))

(define (list-content port)
  (let ((s (get-srcinfo port)))
    (put-srcinfo s (list-content-loop port '()))))
(define (list-content-loop port pre-built)
  (any-space* port)
  ; check CONS
  (let* ((s (get-srcinfo port))
         (c (peek-char port)))
    (cond
      ((eqv? c #\.)
        (read-char port)
        (any-space* port)
        (let* ((s2 (get-srcinfo port))
               ($4 (mdn-expr port)))
          (cond
            ((not (nothing? $4))
              (any-space* port)
              (reverse-and-cons pre-built $4))
            (#t
              (report-read-error s s2 "Expecting an expression in cdr postion of improper cons pair")))))
      (#t
        ; check mdn-expr
        (let (($2 (mdn-expr port)))
          (cond
            ((not (nothing? $2))
              (list-content-loop port (cons $2 pre-built)))
            (#t
              (reverse pre-built))))))))

; reverse the value and cons something
(define (reverse-and-cons l target)
  (cond
    ((pair? l)
      (reverse-and-cons (cdr l) (cons (car l) target)))
    (#t
      target)))

(define (base-expr port)
  ; try list, bracket, and curly-infix notations first
  (let (($1 (list-notation port)))
    (cond
      ((not (nothing? $1)) $1)
      (#t
        (let (($1 (bracket-notation port)))
          (cond
            ((not (nothing? $1)) $1)
            (#t
              (let (($1 (curly-infix port)))
                (cond
                  ((not (nothing? $1)) $1)
                  (#t
                    ; an atom
                    (let ((c (peek-char port)))
                      (cond
                        ; fall back to using built-in reader
                        ; for OTHER (i.e. starting with #)
                        ; and STRING
                        ; NOTE!
                        ; For some schemes, #||# or #!!#
                        ; is used to denote multiline
                        ; comments.  Unfortunately that
                        ; *cannot* be handled here.
                        ; One-character-lookahead is a
                        ; PITA.
                        ((or (eqv? c #\#) (eqv? c #\"))
                          (built-in-read port))
                        (#t
                          ; otherwise, read in the atom as
                          ; a string.
                          (let* ((s       (get-srcinfo port))
                                 (to-read (read-atom-string port)))
                            (cond
                              ((equal? to-read "")
                                nothing)
                              (#t
                                (let ((nport (portable-open-input-string to-read)))
                                  (dynamic-wind
                                    (lambda () '())
                                    (lambda ()
                                      (cond
                                        (nport
                                          (put-srcinfo s (built-in-read nport)))
                                        ; shouldn't happen
                                        (#t
                                          nothing)))
                                    (lambda ()
                                      (cond
                                        (nport
                                          (close-input-port nport)
                                          (set! nport #f))
                                        (#t '())))))))))))))))))))))
(define (read-atom-string port)
  (read-atom-string-loop port '()))
(define (read-atom-string-loop port rv)
  (let ((c (peek-char port)))
    (cond
      ; termination of atoms
      ((or
         (SPLICE? c) ; ?
         (GROUP? c) ; ?
         (member c `(#\space #\newline ,cTAB ,cCR ,cVTAB ,cFORMFEED
                     #\{ #\} #\[ #\] #\( #\)
                     #\' #\` #\,
                     #\" #\#)))
        (apply string (reverse rv)))
      (#t
        (read-char port)
        (read-atom-string-loop port (cons c rv))))))

; hook for language-specific bracket meanings
(define (bracket-notation port) (bracket-notation-scheme port))
; bracket in scheme.
(define (bracket-notation-scheme port)
  (let* ((s (get-srcinfo port))
         (c (peek-char port)))
    (cond
      ((eqv? c #\[)
        (read-char port)
        (let (($2 (list-content port)))
          (cond
            ((not (nothing? $2))
              (let* ((s2 (get-srcinfo port))
                     (c  (peek-char port)))
                (cond
                  ((eqv? c #\])
                    (read-char port)
                    $2)
                  (#t
                    (report-read-error s s2 "Improperly terminated bracket form")))))
            (#t
              (report-read-error s #f "Failed to parse inner expressions of bracket form")))))
      (#t nothing))))

; curly infix
(define (curly-infix port)
  (let* ((s (get-srcinfo port))
         (c (peek-char port)))
    (cond
      ((eqv? c #\{)
        (read-char port)
        (let (($2 (list-content port)))
          (cond
            ((not (nothing? $2))
              (let* ((s2 (get-srcinfo port))
                     (c  (peek-char port)))
                (cond
                  ((eqv? c #\})
                    (read-char port)
                    ; inspect $2
                    (cond
                      ; if not a proper list, map to nfx
                      ((not (list? $2))
                        (map-to-nfx s $2))
                      ; must have an odd number of parameters
                      ((even? (length $2))
                        (map-to-nfx s $2))
                      ; must have at least 3 parameters
                      ((< (length $2) 3)
                        (map-to-nfx s $2))
                      ; all even parameters are the same _symbol_
                      ((not (same-symbol? (even-elems $2)))
                        (map-to-nfx s $2))
                      (#t
                        (put-srcinfo s
                          (cons (cadr $2) (odd-elems $2))))))
                  (#t
                    (report-read-error s s2 "Improperly terminated curly-infix form")))))
            (#t
              (report-read-error s #f "Failed to parse inner expressions of curly-infix form")))))
      (#t nothing))))
(define (map-to-nfx s inner)
  (put-srcinfo s (cons 'nfx inner)))
(define (same-symbol? l)
  (cond
    ; trivially true
    ((null? l)
      #t)
    (pair? l
      (let ((fst (car l)))
        (cond
          ((not (symbol? fst))
            #f)
          (#t
            (same-symbol?-loop fst (cdr l))))))
    ; not a list
    (#t
      #f)))
(define (same-symbol?-loop x l)
  (cond
    ((null? l)
      #t)
    ((pair? l)
      (cond
        ((eq? x (car l))
          (same-symbol?-loop x (cdr l)))
        (#t #f)))
    (#t #f)))
(define (even-elems l)
  (even-elems-loop l '()))
(define (odd-elems l)
  (odd-elems-loop l '()))
(define (even-elems-loop l rv)
  (cond
    ((null? l)
      (reverse rv))
    ((pair? l)
      (odd-elems-loop (cdr l) rv))
    (#t
      (error "even/odd-elems: Expecting a list"))))
(define (odd-elems-loop l rv)
  (cond
    ((null? l)
      (reverse rv))
    ((pair? l)
      (even-elems-loop (cdr l) (cons (car l) rv)))
    (#t
      (error "even/odd-elems: Expecting a list"))))

; TODO
(define (swt-expr port)
  (any-space* port)
  (mdn-expr port))
)
