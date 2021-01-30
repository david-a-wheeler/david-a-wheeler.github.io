<!DOCTYPE style-sheet PUBLIC "-//James Clark//DTD DSSSL Style Sheet//EN" [
<!ENTITY html-ss
PUBLIC "-//Norman Walsh//DOCUMENT DocBook HTML Stylesheet//EN" CDATA dsssl>
<!ENTITY print-ss
PUBLIC "-//Norman Walsh//DOCUMENT DocBook Print Stylesheet//EN" CDATA dsssl>
]>

<style-sheet>
<style-specification id="print" use="print-stylesheet">
<style-specification-body> 

;; customize the print stylesheet

;;Show URL links? If the text of the link and the URL are identical,
;;the parenthetical URL is suppressed.
;; We WON'T show the URL, because it causes bleeding into the edge so
;; awfully that you can't read the results.
(define %show-ulinks%
 #f)

;Make Ulinks footnotes to stop bleeding in the edges - this increases
;'jade --> print' time tremendously keep this in mind before
;complaining!
;It's also ugly.
; (define %footnote-ulinks%
; #t)

;; Are sections enumerated?
(define %section-autolabel% 
 #t)

;; Is two-sided output being produced?
(define %two-side% 
  #t)

;; Allow automatic hyphenation?
; (define %hyphenation%
;   #f)



</style-specification-body>
</style-specification>
<style-specification id="html" use="html-stylesheet">
<style-specification-body> 

;; customize the html stylesheet
;; I find that I have to say '../name-of-file', and even then things
;; don't seem to work.  Suggestions?

(define %section-autolabel% #t)

</style-specification-body>
</style-specification>
<external-specification id="print-stylesheet" document="print-ss">
<external-specification id="html-stylesheet" document="html-ss">
</style-sheet>
