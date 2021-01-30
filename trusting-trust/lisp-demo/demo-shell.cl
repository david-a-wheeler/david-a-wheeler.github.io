; This script drives a test to show that DDC works in detecting
; malicious compilers, by correctly noting that a good compiler is a match,
; and that a malicious compiler is NOT a match... and that comparing
; the binaries of the malicious compiler to the DDC output can reveal
; the evil inside.

; It uses the good and malicious compiler code created by Wolfgang Goerigk
; in the ACL2 language.  I (David A. Wheeler) have quickly ported the ACL2
; code to simple Common Lisp, since there are a LOT more Common Lisp
; implementations than ACL2 implementations :-).
; I used GNU CLisp for my tests.

; The script and code are messy, because I only needed to do this once,
; and just show that it works. If this were to be done repeatedly, cleaner
; code would be nice.   But as a simple demo that it works at all,
; this is sufficient.

; Add ACL2 function definitions for Common Lisp:
; LEN: length function that can be applied to lists;
; Common Lisp's LEN will do the job.
(defun LEN (X) (length X))
; ZP returns true if X is not an integer, or if X is integer and X=0.
; otherwise (when X is a nonzero integer) it returns False. See:
; http://www.cs.utexas.edu/users/moore/acl2/v3-1/ZERO-TEST-IDIOMS.html
(defun ZP (X)
 (if (integerp X) (= X 0)
     t ;; If not an integer, always return True.
 ))
; TRUE-LISTP: returns True if its argument is a list that ends in,
;  or equals, nil... otherwise false.
(defun TRUE-LISTP (X)
  (if (NULL X) T
     (if (LISTP X) (TRUE-LISTP (CDR X))
          NIL)))
; ACL2-NUMBERP returns True if its argument is a list that ends in,
(defun ACL2-NUMBERP (X)
  (NUMBERP X))


; Local helper function.
; write-truth writes FALSE if false, true if true, else HUH.
(defun write-truth (B)
  (cond
    ((eq B t)   (write-line "True"))
    ((eq B nil) (write-line "False"))
    (t          (write-line "HUH?"))))

(write-line "Loading mymachine.cl")
(load "mymachine.cl")
(write-line "Loading mycompiler.cl")
(load "mycompiler.cl")
(write-line "Done loading files, now doing tests.")

(write-line "")
(write-line "Here's the source code for the good compiler:")
(pprint (compiler-source))

(write-line "")
(write-line "Here's the source code for the incorrect (evil) compiler:")
(pprint (incorrect-compiler-source))
(write-line "")

(write-line "")
(write-line "Here's the compiled code for the compiler:")
(pprint
  (compile-program (compiler-source)
                   '(defs vars main)
                   '(compile-program defs vars main))
)
(write-line "")

(write-line "")
(write-line "Here's the compiled code for the evil compiler:")
(pprint
  (compile-program (incorrect-compiler-source)
                   '(defs vars main)
                   '(compile-program defs vars main))
)
(write-line "")

(write-line "")
(write-line "Here's a compilation of a factorial function:")

(setq fact-machinecode
 (execute-am
  (compile-program (compiler-source)
                   '(defs vars main)
                   '(compile-program defs vars main))
  '((fac n)
    (n)
    ((defun fac (n) (if (equal n 0) 1 (* n (fac (1- n))))))
   )
  1000000)
)

(pprint fact-machinecode)
(write-line "")

(write-line "")
(write-line "Here's a compilation of a factorial function, by evil compiler:")

(setq fact-byevil-machinecode
 (execute-am
  (compile-program (incorrect-compiler-source)
                   '(defs vars main)
                   '(compile-program defs vars main))
  '((fac n)
    (n)
    ((defun fac (n) (if (equal n 0) 1 (* n (fac (1- n))))))
   )
  1000000)
)

(pprint fact-byevil-machinecode)
(write-line "")

(write-line "")
(write-line "They are the same machine code, as shown by seeing if equal:")
(write-truth (equal fact-machinecode fact-byevil-machinecode))

(write-line "")
(write-line "Let's run (fac 6), which returns 720:")
(pprint
 (execute-am
  (compile-program
    '((defun fac (n) (if (equal n 0) 1 (* n (fac (1- n))))))
    '(n)
    '(fac n))
  '(6)
  1000000)
)
(write-line "")

(write-line "")
(write-line "But login will be evil!")

(setq login-bygood-machinecode
 (execute-am
  (compile-program (compiler-source)
                   '(defs vars main)
                   '(compile-program defs vars main))
  '((login)
    ()
    ((defun login () '(This is the CORRECT login)))
   )
  1000000)
)

(setq login-byevil-machinecode
 (execute-am
  (compile-program (incorrect-compiler-source)
                   '(defs vars main)
                   '(compile-program defs vars main))
  '((login)
    ()
    ((defun login () '(This is the CORRECT login)))
   )
  1000000)
)

(write-truth (equal login-bygood-machinecode login-byevil-machinecode))
(write-line "Login from good compiler:")
(pprint login-bygood-machinecode)
(write-line "")
(write-line "")
(write-line "Login from evil compiler:")
(pprint login-byevil-machinecode)
(write-line "")
(write-line "")

(write-line "")
(write-line "Output of compile-program, without execute-am:")
(pprint
  (compile-program
    '((defun fac (n) (if (equal n 0) 1 (* n (fac (1- n))))))
    '(n)
    '(fac n))
)
(write-line "")
(write-line "")
(write-line "Okay, now show that the good compiler can self-regenerate:")
(write-line "")
(write-line "")

; First, we bootstrap the good compiler, in this case using the local
; Common Lisp implementation, onto the abstract machine:
(setq good-0
  (compile-program (compiler-source)
                   '(defs vars main)
                   '(compile-program defs vars main)))

; Now, we recompile the good compiler on itself:
(setq good-1
 (car (execute-am
    good-0
    (list '(compile-program defs vars main)
          '(defs vars main)
           (compiler-source))
    1000000)))

; Bootstrap test of good compiler: can we regen?
(setq good-2
 (car (execute-am
    good-1
    (list '(compile-program defs vars main)
          '(defs vars main)
           (compiler-source))
    1000000)))

(write-line "Here's the good self-regenerating machine code (self-regen):")
(write-truth (equal good-1 good-2))
(pprint good-1)

(write-line "")
(write-line "")
(write-line "But now show that the evil compiler can self-regenerate too:")
(write-line "")
(write-line "")

; First, we bootstrap the good compiler, in this case using CL,
; onto the abstract machine:
(setq evil-0
  (compile-program (incorrect-compiler-source)
                   '(defs vars main)
                   '(compile-program defs vars main)))

; Now, we recompile the evil compiler, but feeding it the GOOD source code.
; Notice the input - it is NOT "incorrect-compiler-source"!
(setq evil-1
 (car (execute-am
    evil-0
    (list '(compile-program defs vars main)
          '(defs vars main)
           (compiler-source)) ; Look at that - we fed it the CORRECT source.
    1000000)))

; Bootstrap test: can we regen?
; Notice the input - it is NOT "incorrect-compiler-source"!
(setq evil-2
 (car (execute-am
    evil-1
    (list '(compile-program defs vars main)
          '(defs vars main)
           (compiler-source)) ; Again, fed it CORRECT source and doesn't matter
    1000000)))

; Now compare to see if passes bootstrap test... and of course, it does.
(write-truth (equal evil-1 evil-2))
(write-line "Here's the evil, self-regenerating machine code:")
(pprint evil-2)
(write-line "")



(write-line "")
(write-line "Now for DDC. Use underlying Common Lisp implementation as T:")
; Due to Common Lisp punning, this is the same as the bootstrap in this
; scenario, though that is NOT always true in the general case:
(setq stage1
  (compile-program (compiler-source)
                   '(defs vars main)
                   '(compile-program defs vars main)))
; Now recompile from stage1.  Note that we never run the evil compiler,
; so the evil compiler can't hurt us.
(setq stage2
 (car (execute-am
    stage1
    (list '(compile-program defs vars main)
          '(defs vars main)
           (compiler-source))
    1000000)))
(write-line "")
(write-line "Okay.  Now, are stage2 and the good compiler-2 the same?")
(write-line "")

(write-truth (equal good-2 stage2))

(write-line "")
(write-line "Are stage2 and the evil compiler-2 the same?")
(write-line "")
(write-truth (equal evil-2 stage2))


(write-line "")
(write-line "How do stage2 and the evil compiler-2 differ?")
(write-line "Do a diff -u of ,stage2 and ,evil2.")
(setq stream-stage2 (open ",stage2" :direction :output :if-exists :supersede))
(setq stream-evil-2 (open ",evil2" :direction :output :if-exists :supersede))

(write stage2 :stream stream-stage2 :pretty t)
(write evil-2 :stream stream-evil-2 :pretty t)

(write-line "")
(write-line "Done.")

