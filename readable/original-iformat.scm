; From http://srfi.schemers.org/srfi-49/mail-archive/msg00008.html
; Naive pretty-printer from s-expressions to I-expressions.
; WARNING: it has a bug, doesn't present '(f (g)) correctly.
;    * To: Sven.Hartrumpf@fernuni-hagen.de
;    * Subject: Re: SRFI-49 formatter somewhere?
;    * From: redhog@redhog.org (RedHog (Egil Möller))
;    * Date: Tue, 02 Dec 2003 00:37:54 +0100
;    * Cc: srfi-49@srfi.schemers.org
;    * Delivered-to: srfi-49@srfi.schemers.org
;    * References: <20031201.224111.78731806.Sven.Hartrumpf@FernUni-Hagen.de>
;
;A naive formatter should be quite trivial to write. However, one that
;is smart when choosing what to format as S-expressions and what to
;format as I-expresions, is quite a bit trickier... Hm, now I just
;couldn't get to sleep, so I wrote one instaed (it i very naive, but
;works):


(define (iformat-head msg)
  (define (iformat-head sep msg)
    (if (and (pair? msg)
	     (not (pair? (car msg))))
	(let ((sl (iformat-head " " (cdr msg))))
	  (cons
	   (format
	    #f "~A~A~A"
	    sep (car msg) (car sl))
	   (cdr sl)))
	(cons "" msg)))
  (iformat-head "" msg))

(define (iformat-body ind msg)
  (cond
   ((null? msg)
    "")
   ((pair? msg)
    (string-append
     (iformat ind (car msg))
     (iformat-body ind (cdr msg))))
   (#t
    (format
     #f "~A.\n~A" ind
     (iformat ind msg)))))

(define (iformat ind msg)
  (if (not (pair? msg))
      (format #f "~A~A\n" ind msg)
      (let ((sl (iformat-head msg)))
	(format
	 #f "~A~A\n~A"
	 ind
	 (if (equal? (car sl) "")
	     "group"
	     (car sl))
	 (iformat-body (string-append ind " ") (cdr sl))))))

; "ind" is the indent, "msg" is the expression to be formatted, e.g.,
; (iformat " " '(f a b (c d)))


