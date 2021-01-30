;;;
;;; pp.scm
;;; pretty-printer
;;;
;;; Copyright (C) 1998-2000, Ivan Demakov.
;;; All rights reserved.
;;;
;;; Permission to use, copy, modify, and distribute this software and its
;;; documentation for any purpose, without fee, and without a written
;;; agreement is hereby granted, provided that the above copyright notice
;;; and this paragraph and the following two paragraphs appear in all copies.
;;; Modifications to this software may be copyrighted by their authors
;;; and need not follow the licensing terms described here, provided that
;;; the new terms are clearly indicated on the first page of each file where
;;; they apply.
;;;
;;; IN NO EVENT SHALL THE AUTHORS OR DISTRIBUTORS BE LIABLE TO ANY PARTY
;;; FOR DIRECT, INDIRECT, SPECIAL, INCIDENTAL, OR CONSEQUENTIAL DAMAGES,
;;; INCLUDING LOST PROFITS, ARISING OUT OF THE USE OF THIS SOFTWARE AND ITS
;;; DOCUMENTATION, EVEN IF THE AUTHORS HAS BEEN ADVISED OF THE
;;; POSSIBILITY OF SUCH DAMAGE.
;;;
;;; THE AUTHORS AND DISTRIBUTORS SPECIFICALLY DISCLAIMS ANY WARRANTIES,
;;; INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY
;;; AND FITNESS FOR A PARTICULAR PURPOSE.  THE SOFTWARE PROVIDED HEREUNDER IS
;;; ON AN "AS IS" BASIS, AND THE AUTHORS AND DISTRIBUTORS HAS NO OBLIGATIONS
;;; TO PROVIDE MAINTENANCE, SUPPORT, UPDATES, ENHANCEMENTS, OR MODIFICATIONS.
;;;
;;;
;;; Author:        Ivan Demakov <demakov@users.sourceforge.net>
;;; Creation date: Tue Apr 14 19:00:58 1998
;;; Last Update:   Tue Mar 21 02:38:43 2000
;;;
;;;
;;; $Id: pp.scm,v 1.1 2001/02/16 22:09:46 demakov Exp $
;;;
;;;
;;; Comments:
;;;


(define pp:tab "\t")
(define pp:nl  "\n")

(define pp:tab-size 8)
(define pp:width 70)


;;;
;;;

(define (pretty-print x . args)
  (let ((port (if (pair? args) (car args) #t)))
    (cond ((eq? port #t)
	   (pp:write x 0 pp:width display))

	  ((eq? port #f)
	   (let* ((str (make-string 0))
		  (port (open-output-string str)))
	     (pp:write x 0 pp:width (lambda (x) (display x port)))
	     (close-port port)
	     str))

	  ((output-port? port)
	   (pp:write x 0 pp:width (lambda (x) (display x port))))

	  ((procedure? port)
	   (pp:write x 0 pp:width (lambda (x) (apply port x (cdr args)))))

	  (else
	   (error 'pretty-print "invalid port in arg2: ~s" port)))))


(define pp pretty-print)

(define (set-pretty-print-width! . args)
  (let ((width (if (pair? args) (car args) 70)))
    (if (and (integer? width) (positive? width))
	(set! pp:width width)
	(error 'set-pretty-print-width! "invalid integer in arg1:" width))))

(define (set-pretty-print-tab-size! . args)
  (let ((size (if (pair? args) (car args) 8)))
    (if (and (integer? size) (positive? size))
	(set! pp:tab-size size)
	(error 'set-pretty-print-tab-size! "invalid integer in arg1:" size))))


;;;
;;;

(define (pp:spaces num output)
  (cond ((< pp:tab-size num)
	 (output pp:tab)
	 (pp:spaces (- num pp:tab-size) output))
	((< 0 num)
	 (output " ")
	 (pp:spaces (- num 1) output))))


(define (pp:write x pos width output)
  (pp:spaces pos output)
  (pp:wr-object x pos width output)
  (output pp:nl))

(define (pp:wr-object x pos width output)
  (cond ((null? x)
	 (output "()")
	 (+ pos 2))

	((pair? x)
	 (or (pp:read-macro x pos width output)
	     (pp:expr x pos width output)
	     (pp:wr-pair x pos width output)))

	((and (vector? x) (zero? (vector-length x)))
	 (output "#()")
	 (+ pos 3))

	((vector? x)
	 (pp:wr-vector x pos width output))

	(else
	 (let ((str (object->string x)))
	   (output str)
	   (+ pos (string-length str))))))


(define (pp:wr-pair x pos width output)
  (let ((simple-elems? #t)
	(single-line? #t)
	(nosublists? #t))

    (define (ck-out str)
      (if (string=? str pp:nl)
	  (set! simple-elems? #f)))

    (define (ck cur-pos x)
      (if (<= width (+ cur-pos 1))
	  (set! single-line? #f))

      (cond ((or (null? x) (not simple-elems?)) #f)
	    ((pair? x)
	     (if (or (pair? (car x)) (vector? (car x)))
		 (set! nosublists? #f))
	     (if (<= width (+ cur-pos 1))
		 (ck (pp:wr-object (car x) (+ pos 1) width ck-out) (cdr x))
		 (let ((cur (pp:wr-object (car x) (+ cur-pos 1) width ck-out)))
		   (cond (simple-elems?
			  (ck cur (cdr x)))
			 (else
			  (set! simple-elems? #t)
			  (set! single-line? #f)
			  (ck (pp:wr-object (car x) (+ pos 1) width ck-out)
			      (cdr x)))))))
	    (single-line?
	     (let ((cur (pp:wr-object x (+ cur-pos 3) width ck-out)))
	       (if (<= width (+ cur 1))
		   (set! simple-elems? #f))))
	    (else
	     (set! simple-elems? #f))))

    (define (pr cur-pos x)
      (cond ((null? x)
	     cur-pos)

	    ((and simple-elems? single-line?)
	     (cond ((pair? x)
		    (output " ")
		    (pr (pp:wr-object (car x) (+ cur-pos 1) width output)
			(cdr x)))
		   (else
		    (output " . ")
		    (pp:wr-object x (+ cur-pos 3) width output))))

	    ((and simple-elems? nosublists?)
	     (let ((num (pp:wr-object (car x) 0 width void)))
	       (if (<= width (+ cur-pos num 1))
		   (begin (output pp:nl)
			  (pp:spaces (+ pos 1) output)
			  (pr (pp:wr-object (car x) (+ pos 1) width output)
			      (cdr x)))
		   (begin (output " ")
			  (pr (pp:wr-object (car x) (+ cur-pos 1) width output)
			      (cdr x))))))

	    (else
	     (output pp:nl)
	     (pp:spaces (+ pos 1) output)
	     (cond ((pair? x)
		    (pr (pp:wr-object (car x) (+ pos 1) width output) (cdr x)))
		   (else
		    (output ".")
		    (output pp:nl)
		    (pp:spaces (+ pos 1) output)
		    (pp:wr-object x (+ pos 1) width output))))))

    (if (or (pair? (car x)) (vector? (car x)))
	(set! nosublists? #f))
    (output "(")
    (ck (pp:wr-object (car x) (+ pos 1) width ck-out) (cdr x))
    (set! pos (pr (pp:wr-object (car x) (+ pos 1) width output) (cdr x)))
    (output ")")
    (+ pos 1)))


(define (pp:wr-vector x pos width output)
  (let ((simple-elems? #t)
	(single-line? #t)
	(nosublist? #t))

    (define (ck-out str)
      (if (string=? str pp:nl)
	  (set! simple-elems? #f)))

    (define (ck cur-pos i)
      (if (<= width (+ cur-pos 1))
	  (set! single-line? #f))
      (if (and simple-elems? (< i (vector-length x)))
	  (let ((z (vector-ref x i)))
	    (if (or (pair? z) (vector? z))
		(set! nosublist? #f))
	    (cond ((<= width (+ cur-pos 1))
		   (if nosublist?
		       (ck (pp:wr-object z (+ pos 2) width ck-out)
			   (+ i 1))
		       (set! simple-elems? #f)))
		  (else
		   (let ((cur (pp:wr-object z (+ cur-pos 1) width ck-out)))
		     (cond (simple-elems?
			    (ck cur (+ i 1)))
			   (nosublist?
			    (set! simple-elems? #t)
			    (set! single-line? #f)
			    (ck (pp:wr-object z (+ pos 2) width ck-out)
				(+ i 1)))
			   (else
			    (set! simple-elems? #f)))))))))


    (define (pr cur-pos i)
      (cond ((= i (vector-length x))
	     (output ")")
	     (+ cur-pos 1))

	    ((and simple-elems? single-line?)
	     (output " ")
	     (pr (pp:wr-object (vector-ref x i) (+ cur-pos 1) width output)
		 (+ i 1)))

	    ((and simple-elems? nosublist?)
	     (let ((num (pp:wr-object (vector-ref x i) 0 width void)))
	       (if (<= width (+ cur-pos num 1))
		   (begin (output pp:nl)
			  (pp:spaces (+ pos 2) output)
			  (pr (pp:wr-object (vector-ref x i)
					    (+ pos 2) width output)
			      (+ i 1)))
		   (begin (output " ")
			  (pr (pp:wr-object (vector-ref x i)
					    (+ cur-pos 1) width output)
			      (+ i 1))))))

	    (else
	     (output pp:nl)
	     (pp:spaces (+ pos 2) output)
	     (pr (pp:wr-object (vector-ref x i) (+ pos 2) width output)
		 (+ i 1)))))

    (output "#(")
    (ck (pp:wr-object (vector-ref x 0) (+ pos 2) width ck-out) 1)
    (pr (pp:wr-object (vector-ref x 0) (+ pos 2) width output) 1)))


(define (pp:read-macro x pos width output)
  (and (pair? x) (pair? (cdr x)) (null? (cddr x))
       (memq (car x) '(quote quasiquote unquote unquote-splicing))
       (begin
	 (case (car x)
	   ((quote)		(output "'")  (set! pos (+ pos 1)))
	   ((quasiquote)	(output "`")  (set! pos (+ pos 1)))
	   ((unquote)		(output ",")  (set! pos (+ pos 1)))
	   ((unquote-splicing)	(output ",@") (set! pos (+ pos 2))))
	 (pp:wr-object (cadr x) pos width output))))
       

(define (pp:expr x pos width output)
  (and (list? x) (symbol? (car x)) (pair? (cdr x))
       (case (car x)
	 ((lambda let* letrec define fluid-let
		  define-macro define-syntax
		  let-syntax letrec-syntax
		  with-syntax syntax-rules)
	  (pp:wr-style x pos width output 1 #f #f))

	 ((and or if)
	  (pp:wr-style x pos width output 1 #t #f))

	 ((cond begin begin0)
	  (pp:wr-style x pos width output #f #f #f))

	 ((set! case dotimes)
	  (pp:wr-style x pos width output 1 #f #f))

	 ((let syntax-case)
	  (if (and (pair? (cdr x)) (symbol? (cadr x)))
	      (pp:wr-style x pos width output 2 #f #f)
	      (pp:wr-style x pos width output 1 #f #f)))

	 ((do)
	  (pp:wr-style x pos width output 1 #f 2))

	 ((define-generic define-method define-class)
	  (if (and (pair? (cddr x))
		   (or (keyword? (caddr x))
		       (and (pair? (caddr x)) (keyword? (caaddr x)))))
	      (pp:wr-style x pos width output 1 #f 3)
	      (pp:wr-style x pos width output 1 #f 2)))

	 (else
	  (pp:wr-call x pos width output)))))


(define (pp:wr-style x pos width output num-0 num-1 num-2)
  (let ((single-line? #t)
	(pos-1 pos))

    (define (ck-out str)
      (if (string=? str pp:nl)
	  (set! single-line? #f)))

    (define (ck cur-pos x)
      (if (and single-line? (pair? x))
	  (if (<= width cur-pos)
	      (set! single-line? #f)
	      (ck (+ (pp:wr-object (car x) cur-pos width ck-out) 1)
		  (cdr x)))))

    (define (pr cur-pos x i)
      (cond ((null? x) cur-pos)

	    ((zero? i)
	     (set! pos-1 (pp:wr-object (car x) cur-pos width output))
	     (pr pos-1 (cdr x) (+ i 1)))

	    ((or single-line?
		 (and (boolean? num-0) num-0)
		 (and (number? num-0) (<= i num-0)))
	     (output " ")
	     (pr (pp:wr-object (car x) (+ cur-pos 1) width output)
		 (cdr x)
		 (+ i 1)))

	    ((or (and (boolean? num-1) num-1)
		 (and (number? num-1) (<= i num-1)))
	     (output pp:nl)
	     (pp:spaces (+ pos-1 1) output)
	     (pr (pp:wr-object (car x) (+ pos-1 1) width output)
		 (cdr x)
		 (+ i 1)))

	    ((or (and (boolean? num-2) num-2)
		 (and (number? num-2) (<= i num-2)))
	     (output pp:nl)
	     (pp:spaces (+ pos 4) output)
	     (pr (pp:wr-object (car x) (+ pos 4) width output)
		 (cdr x)
		 (+ i 1)))

	    (else
	     (output pp:nl)
	     (pp:spaces (+ pos 2) output)
	     (pr (pp:wr-object (car x) (+ pos 2) width output)
		 (cdr x)
		 (+ i 1)))))

    (ck (+ pos 1) x)
    (output "(")
    (set! pos (pr (+ pos 1) x 0))
    (output ")")
    (+ pos 1)))


(define (pp:wr-call x pos width output)
  (let ((single-line? #t)
	(pos-1 pos)
	(already-keyargs? #f))

    (define (ck-out str)
      (if (string=? str pp:nl)
	  (set! single-line? #f)))

    (define (ck cur-pos x)
      (if (and single-line? (pair? x))
	  (if (<= width cur-pos)
	      (set! single-line? #f)
	      (ck (+ (pp:wr-object (car x) cur-pos width ck-out) 1)
		  (cdr x)))))

    (define (keyargs? x)
      (and (or (keyword? (car x))
	       (and (pair? (car x)) (pair? (cdar x)) (null? (cddar x))
		    (eq? (caar x) 'quote) (keyword? (cadar x))))
	   (pair? (cdr x))
	   (or (null? (cddr x)) (keyargs? (cddr x)))))

    (define (pr cur-pos x i)
      (cond ((null? x) cur-pos)

	    ((zero? i)
	     (set! pos-1 (pp:wr-object (car x) cur-pos width output))
	     (pr pos-1 (cdr x) (+ i 1)))

	    ((or single-line? (<= i 1))
	     (output " ")
	     (pr (pp:wr-object (car x) (+ cur-pos 1) width output)
		 (cdr x)
		 (+ i 1)))

	    ((or already-keyargs? (keyargs? x))
	     (set! already-keyargs? #t)
	     (output pp:nl)
	     (pp:spaces (+ pos-1 1) output)
	     (set! cur-pos (pp:wr-object (car x) (+ pos-1 1) width output))
	     (output " ")
	     (pr (pp:wr-object (cadr x) (+ cur-pos 1) width output)
		 (cddr x)
		 (+ i 2)))

	    (else
	     (output pp:nl)
	     (pp:spaces (+ pos-1 1) output)
	     (pr (pp:wr-object (car x) (+ pos-1 1) width output)
		 (cdr x)
		 (+ i 1)))))

    (ck (+ pos 1) x)
    (output "(")
    (set! pos (pr (+ pos 1) x 0))
    (output ")")
    (+ pos 1)))


;;; End of code
