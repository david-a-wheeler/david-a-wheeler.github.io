<!DOCTYPE style-sheet PUBLIC "-//James Clark//DTD DSSSL Style Sheet//EN"

<!-- http://developers.cogentrts.com/cogent/prepdoc/pd-customizingthedssslstylesheets.html -->

[<!ENTITY % html "IGNORE">
	 
<![%html;[
<!ENTITY % print "IGNORE">
<!ENTITY docbook.dsl SYSTEM "/usr/share/sgml/docbook/dsssl-stylesheets-1.76/html/docbook.dsl" CDATA dsssl>
]]>

<!ENTITY % print "INCLUDE">
<![%print;[
<!--ENTITY docbook.dsl SYSTEM "/usr/share/sgml/docbook/stylesheet/dsssl/modular/print/docbook.dsl" CDATA dsssl-->
<!ENTITY docbook.dsl SYSTEM "/usr/share/sgml/docbook/dsssl-stylesheets-1.76/print/docbook.dsl" CDATA dsssl>
]]>

<!ENTITY longprintcustomizations.dsl SYSTEM "longprintcustomizations.dsl">
<!ENTITY % en.words SYSTEM "/usr/share/sgml/docbook/dsssl-stylesheets-1.76/common/dbl1en.ent"> %en.words
]>


<!-- New directory:/usr/share/sgml/docbook/stylesheet/dsssl/modular/ --> 
<!-- Old directory:/usr/share/sgml/docbook/dsssl-stylesheets-1.76/ --> 
<!-- Very old directory:/usr/share/sgml/docbook/docbook-dsssl-1.72/ --> 

<!-- Cygnus customizations by Mark Galassi -->
<!-- Cogent customizations by Sam Roberts and Bob McIlvride -->

<style-sheet>

<!--
;; ====================
;; customize all stylesheets
;; ====================
-->

<style-specification id="print" use="docbook">
<style-specification-body> 

;; ====================
;; customize the print stylesheet
;; ====================

;; These elements appear in this order on the title page
;; of the book. The "mediaobject" is the Cogent graphic.
(define (book-titlepage-recto-elements)
  (list	(normalize "mediaobject")
	(normalize "title") 
	(normalize "subtitle") 
	(normalize "corpname") 
	(normalize "corpauthor") 
	(normalize "pubdate")
	(normalize "authorgroup") 
	(normalize "author") 
	(normalize "editor")
	))

;; Place elements on title page in document order?
;; No, we put them in the order above.
(define %titlepage-in-info-order% 
  #f)

;; These elements appear in this order inside the title
;; page and for the next few pages, as necessary.
(define (book-titlepage-verso-elements)
  (list (normalize "title") 
	(normalize "subtitle") 
;	(normalize "corpauthor") 
	(normalize "abstract") 
;	(normalize "authorgroup") 
;	(normalize "author") 
;	(normalize "authorblurb") 
	(normalize "editor")
;	(normalize "edition") 
	(normalize "pubdate")
	(normalize "publisher")
	(normalize "copyright")
	(normalize "revhistory")
	(normalize "releaseinfo")
	(normalize "legalnotice") 
	))

;; --- Explanation for the "longprintcustomization" entity. ---

;; The following entity refers to a separate dsssl customization
;; file of dbttlpg.dsl that reduces the font size to 80% of the children
;; of an ordered list that appears inside a legalnotice.  This is done to
;; match the font size in the existing paras, which is also reduced to 80%.
;; It also starts the legalnotice role="license" on a new page.
;; (The code was moved to a separate file because it is over 850 lines.)

;; This code also contains a small adjustment to the revhistory table
;; that puts the revremarks into column 2, making it easier to read the
;; table.

;; It also contains a small modification to "define process-cell"
;; which allows us to reduce the font size of table headers.  This was
;; necessary because we have increased the default size of section and
;; chapter titles, from which table headers derive their font size
;; information.

;; Also an experimental improvement of rendering of revhistory.

&longprintcustomizations.dsl;

;; Omit from print output any para with the attribute role="html".
;; This lets us add paragraphs to the document that only
;; appear in HTML output.  Note: right now this doesn't
;; work in formalpara, but to get formalpara to work
;; correctly, we have to redefine it.
(element para
  (if (equal? (attribute-string "role") "html")
      (empty-sosofo)
      ($paragraph$)))
;; Since we have redefined para, we have to put that newly-defined
;; para back into formalpara.
(element (formalpara para) (process-children))

;; Taken from David Mason posting on DB list Mar 2, 2000
;; This puts figure titles below the figure. The default
;; is to put them above.
(define ($object-titles-after$)
  (list (normalize "figure")))

;; This centers figure titles.
(mode formal-object-title-mode
  (element title
    (let* ((object (parent (current-node)))
           (nsep   (gentext-label-title-sep (gi object))))
      (make paragraph
        font-weight: 'bold
	quadding: 'center
        space-before: (if (object-title-after (parent (current-node)))
                          (* %para-sep% .3)
                          0pt)
        space-after: (if (object-title-after (parent (current-node)))
                         0pt
                         %para-sep%)
        start-indent: (+ %block-start-indent% (inherited-start-indent))
        keep-with-next?: (not (object-title-after (parent (current-node))))
        (if (member (gi object) (named-formal-objects))
            (make sequence
              (literal (gentext-element-name object))
              (if (string=? (element-label object) "")
                  (literal nsep)
                  (literal " " (element-label object) nsep)))
            (empty-sosofo))
        (process-children))))
)

;; This scales vebatim environments so that the longest line fits,
;; or so it seems.
  (define %verbatim-size-factor%
    #f)

  ;; If no WIDTH attribute is specified on verbatim environments, 
  ;; '%verbatim-default-width%' is the default.  Note: this width only
  ;; comes into play if '%verbatim-size-factor%' is '#f'.
(define %verbatim-default-width%
  80)

; This supports the customization of paramdef (below).
(element funcprototype 
  (make sequence
    (make paragraph
      font-family-name: %mono-font-family%
      (process-children))))

; This puts all parameters in a funcprototype into a column indented 5
; picas from the left.  I would like to indent them exactly under the
; first parameter, but haven't figured out how to do it yet.  Here is
; some code that I was trying, but doesn't work:
;(testvar ((child-number (current-node)) 1))
;(param-length (* 1pi (string-length (testvar))))
(element paramdef
  (let ((param (select-elements (children (current-node)) (normalize "parameter"))))
    (make sequence
      (if (equal? (child-number (current-node)) 1)
	  (make sequence
	    (literal "(")
	    (process-children)
	    (make sequence
	      (if (equal? (gi (ifollow (current-node))) (normalize "paramdef"))
		  (literal ",")
		  (literal ");"))))
	  (if (equal? (gi (ifollow (current-node))) (normalize "paramdef"))
	      (make sequence
		(make paragraph
		  font-family-name: %mono-font-family%
		  start-indent: 7pi
		  (process-children)
		  (make sequence
		    (literal ", "))))
	      (make sequence
		(make paragraph
		  font-family-name: %mono-font-family%
		  start-indent: 7pi
		  (process-children)
		  (make sequence
		    (literal ");")))))
	  ))))




;; This starts each RefEntry on a new page.
(define %refentry-new-page%
  #t)

;; Keep RefEntrys together?
;; This specifies whether and how to keep reference entries together.
;; #t - smallest possible area
;; 'page - same page
;; #f - ignore this characteristic
(define %refentry-keep%
  #t)

;; Output NAME header before 'RefName'(s)?
;; This puts a section title: NAME before a reference entry name. 
(define %refentry-generate-name% 
  #f)

;; Should a Table of Contents be produced for References?
(define %generate-reference-toc%
  #t)

;; Should a Table of Contents be produced for Parts?
(define %generate-part-toc%
  #t)

;; Should the Reference TOC appear on the Reference title page?
(define %generate-reference-toc-on-titlepage%
  #t)

;; TOC bug fix removed from here.

;; Is two-sided output being produced?
(define %two-side% 
  #f)

;; Enumerate lines in a 'ProgramListing'? (Doesn't appear to work now.)
;; If true, lines in each 'ProgramListing' will be enumerated.
;; See also '%linenumber-mod%', '%linenumber-length%',
;; '%linenumber-padchar%', and '($linenumber-space$)'.
(define %number-programlisting-lines%
  #f)

;; Indent lines in a programlisting? by how many spaces?
;; Note: we set this to an empty string because when using with
;; inlinemediaobject as we do, it only indents the first line.
(define %indent-programlisting-lines%
  "")

;; Indent lines in a 'Screen'?
;; This is a string of characters used to indent every line of
;; a screen. 
(define %indent-screen-lines%
  "    ")

;; Use the admonition graphics?
(define %admon-graphics% #t)

;; This is an experiment to handle admonition graphics using a table,
;; which allows for more precise placement of the graphic on the page.
(define ($graphical-admonition$)
   (let* ((adm       (current-node))
          (title     (select-elements (children adm)
                                      (normalize "title")))
          (title?    (not (node-list-empty? title)))
          (adm-title (if title?
                        (with-mode title-sosofo-mode
                           (process-node-list (node-list-first title)))
                        (literal (gentext-element-name adm))))
          (graphic   (make external-graphic
                       display?: #f
                       position-point-y: (+ %bf-size% 2pt)
                       entity-system-id: ($admon-graphic$)))
          (f-child   (node-list-first (children (current-node))))
          (r-child   (node-list-rest (children (current-node)))))

     (make table
       space-before: %block-sep%
       space-after: %block-sep%
       table-width: (- %text-width% (inherited-start-indent))
       (make table-column
        width: ($admon-graphic-width$))
       (make table-column
        width: 10pt)
       (make table-column
        width: (- %text-width%
                   (+ (inherited-start-indent)
                      ($admon-graphic-width$)
                      10pt)))
       (make table-row
        (make table-cell
           graphic)
        (make table-cell
           (make line-field
             field-width: 5pt
             field-align: 'center
             (empty-sosofo)))
         (make table-cell
          (process-children))))))

;; This overrides the default .gif extension for print admontions.
(define ($admon-graphic$ #!optional (nd (current-node)))
  (cond ((equal? (gi nd) (normalize "tip"))
	 (string-append %admon-graphics-path% "tip.png"))
	((equal? (gi nd) (normalize "note"))
	 (string-append %admon-graphics-path% "note.png"))
	((equal? (gi nd) (normalize "important"))
	 (string-append %admon-graphics-path% "important.png"))
	((equal? (gi nd) (normalize "caution"))
	 (string-append %admon-graphics-path% "caution.png"))
	((equal? (gi nd) (normalize "warning"))
	 (string-append %admon-graphics-path% "warning.png"))
	(else (error (string-append (gi nd) " is not an admonition.")))))

;; Identify the default extension for admonition graphics. This allows
;; backends to select different images (e.g., EPS for print, PNG for
;; PDF, etc.)  It doesn' seem to be working, so we used the override above.
(define admon-graphic-default-extension ".png")

;; This sets the width for indent after graphic.
(define ($admon-graphic-width$ #!optional (nd (current-node)))
  0.3in)

;; Use graphics in admonitions, and have their path be defined.
;; These are the graphics for Note, Caution, Warning, etc.
(define %admon-graphics-path% "../../../i/common/")

(define %admon-font-family% 
  ;; The font family used in admonitions
  "Times New Roman")

;; List of mediaobject filename extensions.
(define preferred-mediaobject-extensions
  (list "jpeg" "jpg" "png" "avi" "mpg" "mpeg" "qt" "pdf" "g" "kdef" "sgml" "pl" "mak" "dsl" "txt" "cfg" "dat" "mod" ""))

;; List of inlinemediaobject filename extensions.
(define preferred-inlinemediaobject-extensions
  (list "jpeg" "jpg" "png" "avi" "mpg" "mpeg" "qt" "pdf" "g" "kdef" "sgml" "pl" "mak" "dsl" "txt" "cfg" "dat" "mod" ""))

;; The acceptable mediaobject extensions.
(define acceptable-mediaobject-extensions
  (list "gif" "bmp" "g" "kdef" "sgml" "pl" "mak" "dsl" "txt" "cfg" "dat" "mod" ""))

;; Display URLs after ULinks?
;; We hide URLs because they make the text difficult to read,
;; and they don't wrap, causing strange line breaks and/or
;; the text gets truncated at the page margin.
(define %show-ulinks%
  #f)

;; This is necessary because right now jadetex does not understand
;; symbolic entities, whereas things work well with numeric entities.
(declare-characteristic preserve-sdata?
          "UNREGISTERED::James Clark//Characteristic::preserve-sdata?"
          #f)

;; Are sections enumerated?
;; The number appears in their title, both in the table
;; of contents, and in the text.
(define %section-autolabel% 
  #t)

;; The font family used in titles
(define %title-font-family% 
   "Helvetica")

(define title-style
  (style
   font-family-name: %title-font-family%
   font-weight: 'medium
   quadding: 'start))

;; The font family used in verbatim environments
(define %mono-font-family% 
  "Courier New")

;; The general measure of document text size.  Options are:
;; "tiny"
;; "normal"
;; "presbyopic"
;; "large-type"
(define %visual-acuity%
  "normal")

;; Make structure names and fields appear in monospaced font.
(element structname ($mono-seq$))
(element structfield ($mono-seq$))

;; This lets you indent paragraphs, etc. Not in use now.
;; (define %block-start-indent%
;;    10pt)

;; These set title spacing.
(define %head-before-factor% .75) ;; default: 0.75
(define %head-after-factor% 0.2)  ;; default: 0.5

;; This sets the horizontal ratio between different
;; sizes of text font.
(define %hsize-bump-factor% 1.2) ;; default: 1.2

;; This sets the space between block elements to
;; one-half the amount of space between paragraphs.
(define %block-sep% (* %para-sep% 0.5)) ;; default: 2.0

;; These set the document margins, measured in picas.
(define %top-margin% 6pi) ; 6pi
(define %bottom-margin% 4pi) ; 8pi
(define %left-margin% 6pi) ; 6pi
(define %right-margin% 6pi) ; 6pi
(define %footer-margin% 2pi) ; 4pi
(define %header-margin% 
  (if (equal? %visual-acuity% "large-type") 
      5.5pi 2pi)) ; 4pi

;; Default punctuation at the end of a run-in head.
;; This appears between the title and the text in a formalpara.
(define %default-title-end-punct% 
  " ")

;; Make "bottom-of-page" footnotes instead of at the end of a chapter?
;; Unfortunately, this doesn't work on our system.  The docs say that it
;; is only supported by TeX, so I'm guessing that means not JadeTeX.
(define %bop-footnotes%
  #t)

(define (make-endnote-header)
  (let ((headsize (if (equal? (gi) (normalize "refentry"))
		      (HSIZE 2)
		      (HSIZE 1)))
	(indent   (lambda () (if (equal? (gi) (normalize "refentry"))
				 %body-start-indent%
				 0pt))))
    (make paragraph
      break-before: %footnote-endnote-break%
      font-family-name: %title-font-family%
      font-weight: 'bold
      font-size: headsize
      line-spacing: (* headsize %line-spacing-factor%)
      space-before: (* headsize %head-before-factor%)
      space-after: (* headsize %head-after-factor%)
      start-indent: (indent)
      quadding: 'start
      keep-with-next?: #t
      (literal (gentext-endnotes)))))

;; May format VariableLists as tables?
;; This would be nice, but it seems to be buggy
;; in some way.  Some variable names that are too
;; long wrap inside the table cell instead of extending
;; across the page.  Anyway, even when it works, it looks
;; pretty disorganized.
;;(define %may-format-variablelist-as-table%
;;  #t)

;; Default term length on variablelists
;; Same problem as above.
;;(define %default-variablelist-termlength%
;;  10)

;; An experiment to solve variablelist term indents.
(element (varlistentry term)
    (make paragraph
          space-before: (if (first-sibling?)
                            %block-sep%
                            0pt)
          keep-with-next?: #t
          first-line-start-indent: 0pt
;          start-indent: 0pt
          (process-children)))


;; This sets the width of the gutter between columns
;(define %page-column-sep%
;  0in)

;; The following are specifically for articles:
;;

;(define %qnx-html% #f) ;; can be overridden on command line
;(define %header-navigation%
;  (if %qnx-html% #f #t))
;(define %footer-navigation%
;  (if %qnx-html% #f #t))



;; Should an article title page be produced?
(define %generate-article-titlepage% 
  #t)

;; Should the article title page be on a separate page?
(define %generate-article-titlepage-on-separate-page%
  #f)

;; The elements, in order, that appear on an article title page.
(define (article-titlepage-recto-elements)
  (list	(normalize "title") 
	(normalize "subtitle") 
	(normalize "corpauthor") 
	(normalize "author") 
	))

;; These elements appear in this order inside an article title
;; page and for the next few pages, as necessary.
(define (article-titlepage-verso-elements)
  (list (normalize "editor")
	(normalize "edition") 
	(normalize "pubdate")
	(normalize "publisher")
	(normalize "copyright")
	(normalize "legalnotice") 
	(normalize "revhistory")
	(normalize "releaseinfo")
	))

;; Should the Article TOC appear on the Article title page?
(define %generate-article-toc-on-titlepage%
  #f)

;; Restart page numbers in each article?
(define %article-page-number-restart% 
  #t)


;; The two following entries tell jadetex to make PDF bookmarks.

(declare-characteristic heading-level 
   "UNREGISTERED::James Clark//Characteristic::heading-level" 2)

(define %generate-heading-level% #t)


;;(define %cals-cell-before-column-margin% 10pt)
;;(define %cals-cell-after-column-margin% 10pt)

;; This overrides bug for aligning images.
(element imagedata
  (if (have-ancestor? (normalize "mediaobject"))
      ($img$ (current-node) #t)
      ($img$ (current-node) #f)))

;; This puts titles into xrefs.
(define (en-xref-strings)
  (list (list (normalize "appendix")    (if %chapter-autolabel%
                                            "&Appendix; %n, %t"
                                            "the &appendix; called %t"))
        (list (normalize "article")     (string-append %gentext-en-start-quote%
                                                       "%t"
                                                       %gentext-en-end-quote%))
        (list (normalize "bibliography") "%t")
        (list (normalize "book")        "%t")
        (list (normalize "chapter")     (if %chapter-autolabel%
                                            "&Chapter; %n, %t"
                                            "the &chapter; called %t"))
        (list (normalize "equation")    "&Equation; %n, %t")
        (list (normalize "example")     "&Example; %n, %t")
        (list (normalize "figure")      "&Figure; %n, %t")
        (list (normalize "glossary")    "%t")
        (list (normalize "index")       "%t")
        (list (normalize "listitem")    "%n")
        (list (normalize "part")        "&Part; %n, %t")
        (list (normalize "preface")     "%t")
        (list (normalize "procedure")   "&Procedure; %n, %t")
        (list (normalize "reference")   "&Reference; %n, %t")
        (list (normalize "section")     (if %section-autolabel%
                                            "&Section; %n, %t"
                                            "the &section; called %t"))
        (list (normalize "sect1")       (if %section-autolabel%
                                            "&Section; %n, %t"
                                            "the &section; called %t"))
        (list (normalize "sect2")       (if %section-autolabel%
                                            "&Section; %n, %t"
                                            "the &section; called %t"))
        (list (normalize "sect3")       (if %section-autolabel%
                                            "&Section; %n, %t"
                                            "the &section; called %t"))
        (list (normalize "sect4")       (if %section-autolabel%
                                            "&Section; %n, %t"
                                            "the &section; called %t"))
        (list (normalize "sect5")       (if %section-autolabel%
                                            "&Section; %n, %t"
                                            "the &section; called %t"))
        (list (normalize "simplesect")  (if %section-autolabel%
                                            "&Section; %n, %t"
                                            "the &section; called %t"))
        (list (normalize "sidebar")     "the &sidebar; %t")
        (list (normalize "step")        "&step; %n, %t")
        (list (normalize "table")       "&Table; %n, %t")))


;; This makes the whole question of a qanda set bold, not just the
;; "Q:" part.
(element question
  (let* ((chlist   (children (current-node)))
         (firstch  (node-list-first chlist))
         (restch   (node-list-rest chlist)))
    (make sequence
      (make paragraph
        space-after: (/ %para-sep% 2)
        keep-with-next?: #t
        (make sequence
          font-weight: 'bold
          (literal (question-answer-label (current-node)) " ")
	  (process-node-list (children firstch))))
      (process-node-list restch))))

;; BRIDGEHEAD isn't a proper section, but appears to be a section title
(element bridgehead
  (let* ((renderas (attribute-string "renderas"))
	 ;; the apparent section level
	 (hlevel
	  ;; if not real section level, then get the apparent level
	  ;; from "renderas"
	  (if renderas
	      (section-level-by-gi #t (normalize renderas))
	      ;; Set to #t to give better control of bridgeheads
	      ;; for renderas=sect4.
	      ;; else use the real level
	      (SECTLEVEL)))
	 (hs (HSIZE (- 4 hlevel))))	
    (make paragraph
      font-family-name: %title-font-family%
      font-weight:  (if (< hlevel 4) 'bold 'medium)
      font-posture: (if (< hlevel 4) 'upright 'italic)
      font-size: hs
      line-spacing: (* hs %line-spacing-factor%)
      space-before: (* hs %head-before-factor%)
      space-after: (* hs %head-after-factor%)
      start-indent: (if (< hlevel 3)
			0pt
			%body-start-indent%)
      first-line-start-indent: (if (< hlevel 4)
			0pt
			%body-start-indent%)
      ;; Above changed from 0 pt to indent sect4 
      quadding: %section-title-quadding%
      keep-with-next?: #t
      (process-children))))


</style-specification-body>
</style-specification>

<!--
;; ====================
;; customize the html stylesheet
;; ====================
-->
<style-specification id="html" use="docbook">
<style-specification-body> 

;;(define %chapter-autolabel% 
  ;; Are chapters enumerated?
;;  #f)

(define nochunks
  ;; Suppress chunking of output pages
  #f)

;; These elements appear in this order on the title page
;; of the Cogent Documentation bookset. The "mediaobject"
;; is the Cogent graphic.
(define (set-titlepage-recto-elements)
  (list (normalize "mediaobject")
	(normalize "title")
        (normalize "subtitle")
;;        (normalize "authorgroup")
;;        (normalize "author")
        (normalize "editor")
	(normalize "pubdate")
        (normalize "abstract")
        (normalize "copyright")
	(normalize "releaseinfo")
        (normalize "legalnotice")))

;; These elements appear in this order on the title page
;; of individual books. The "mediaobject" is the Cogent
;; graphic.
(define (book-titlepage-recto-elements)
  (list
        (normalize "mediaobject")
	(normalize "title")
        (normalize "subtitle")
;;	(normalize "titleabbrev") 
;;        (normalize "authorgroup")
;;        (normalize "author")
;;	(normalize "authorblurb") 
;	(normalize "othercredit") 
;;        (normalize "editor")
	(normalize "pubdate")
        (normalize "abstract")
        (normalize "copyright")
;;	(normalize "releaseinfo")
        (normalize "legalnotice")))


;; This group customizes some title-page elements
(mode book-titlepage-recto-mode

  ;; This reduces the size of the subtitle.
  (element subtitle 
    (make element gi: "H3"
          attributes: (list (list "CLASS" (gi)))
          (process-children-trim)))

  ;; Adds a "by " string to beginning of authorgroup.
  (element authorgroup
    (make element gi: "DIV"
	  attributes: (list (list "CLASS" (gi)))
	  (make sequence
	    (make empty-element gi: "A"
		attributes: (list (list "NAME" (element-id))))
	    (literal "by ")
	    (process-children))))

  ;; Controls the formatting of formalpara in legalnotice.
  (element (formalpara)
    (make element gi: "DIV"
	  (make element gi: "P"
		(process-children))))

  (element (formalpara title) ($runinhead$))

  (element (formalpara para)
    (process-children))

  
  ;; Put in an authorblurb, which we abuse to include other credits.
  (element authorblurb
    (make element gi: "DIV"
	  attributes: (list (list "CLASS" (gi)))
	  (process-children)))

    
  ;; This reduces the size of the authors' names, and puts in commas,
  ;; spaces, and the 'and' before the final name.  Taken from the verso
  ;; mode code.
  (element author
    ;; Print the author name.  Handle the case where there's no AUTHORGROUP
    (let ((in-group (have-ancestor? (normalize "authorgroup") (current-node))))
      (if (not in-group)
	  (make element gi: "P"
		attributes: (list (list "CLASS" (gi)))
		(literal (gentext-by))
		(make entity-ref name: "nbsp")
		(make sequence
		  (make empty-element gi: "A"
			attributes: (list (list "NAME" (element-id))))
		  (literal (author-list-string))))
	  (make sequence
	    (make empty-element gi: "A"
		  attributes: (list (list "NAME" (element-id))))
	    (literal (author-list-string)))))))

;                       (literal (question-answer-label (current-node)) " ")

;; This increases the size and makes bold the font of
;; book titles in the book set.

(define (build-toc nd depth #!optional (chapter-toc? #f) (first? #t))
  (let ((toclist (toc-list-filter 
                  (node-list-filter-by-gi (children nd)
                                          (append (division-element-list)
                                                  (component-element-list)
                                                  (section-element-list)))))
        (wrappergi (if first? "DIV" "DD"))
        (wrapperattr (if first? '(("CLASS" "TOC")) '())))
    (if (or (<= depth 0) 
            (node-list-empty? toclist)
            (and chapter-toc?
                 (not %force-chapter-toc%)
                 (<= (node-list-length toclist) 1)))
        (empty-sosofo)
        (make element gi: wrappergi
              attributes: wrapperattr
              (make element gi: "DL"
                    (if first?
                        (make element gi: "DT"
			      (make element gi: "B"
				    (literal (gentext-element-name (normalize "toc")))))
				    (empty-sosofo))
		    
;; Extra code starts here...
		    
		    (if (string=? (gi nd) (normalize "set"))
			(make element gi: "BIG"
			      (make element gi: "B"
				    (let loop ((nl toclist))
				      (if (node-list-empty? nl)
					  (empty-sosofo)
					  (sosofo-append
					   (toc-entry (node-list-first nl))
					   (build-toc (node-list-first nl) 
						      (- depth 1) chapter-toc? #f)
					   (loop (node-list-rest nl)))))))

;; Extra code ends here.
			
			(let loop ((nl toclist))
			  (if (node-list-empty? nl)
			      (empty-sosofo)
			      (sosofo-append
			       (toc-entry (node-list-first nl))
			       (build-toc (node-list-first nl) 
					  (- depth 1) chapter-toc? #f)
			       (loop (node-list-rest nl)))))))))))



;; Omit from html output any para with the attribute role="print".
;; This lets us add paragraphs to the document that only
;; appear in print output.  Note: right now this doesn't
;; work in formalpara, but to get formalpara to work
;; correctly, we have to redefine it.
(element para
  (if (equal? (attribute-string "role") "print")
      (empty-sosofo)
      ($paragraph$)))
;; Since we have redefined para, we have to put that newly-defined
;; para back into formalpara.
(element (formalpara para) (process-children))


;; Enumerate lines in a 'ProgramListing'? 
(define %number-programlisting-lines%
  #f)

;; Indent lines in a programlisting? by how many spaces?
;; Note: we set this to an empty string because when using with
;; inlinemediaobject as we do, it only indents the first line.
(define %indent-programlisting-lines%
  "")

  ;; Enumerate lines in a 'Screen'?
(define %number-screen-lines%
  #f)

;; A hack to improve spacing around tables.  Default is #t.
(define %spacing-paras%
  #f)

;; This is necessary because right now jadetex does not understand
;; symbolic entities, whereas things work well with numeric entities.
(declare-characteristic preserve-sdata?
          "UNREGISTERED::James Clark//Characteristic::preserve-sdata?"
          #f)

;; Put the legal notice in a separate file?
;; This puts our legal notice etc. on a separate HTML page that
;; does not appear in the table of contents.  It is only accessible
;; by clicking the Copyright link on the first page.
(define %generate-legalnotice-link%
  #t)

;; Name of output file for legal notices.
;; We set this up to make other links, (like trademark) go to the
;; legal notice page.  We aren't using that feature right now.
(define ($legalnotice-link-file$ legalnotice)
  (string-append "ln" 
       (number->string (all-element-number legalnotice))
         %html-ext%))

;; This puts a section title: NAME before a reference entry name. 
(define %refentry-generate-name% 
  #f)

;; Fix a bug in the stylesheet to put the refnamediv into a paragraph.

;;(element refnamediv 
;;  (make element gi: "DIV"
;;        attributes: (list
;;                     (list "CLASS" (gi)))
;;	(make element gi: "A"
;;	      attributes: (list (list "NAME" (element-id)))
;;	      (empty-sosofo))
;;	(make element gi: "P"
;;	      (process-children))))

(define ($block-container$)
  (make element gi: "DIV"
        attributes: (list
                     (list "CLASS" (gi)))
        (make element gi: "A"
              attributes: (list (list "NAME" (element-id)))
              (empty-sosofo))
	(make element gi: "P"
	      (process-children))))

(define %page-number-restart% #f)

;; Use graphics in callouts?
(define %callout-graphics%
  #f)

;; Use graphics in admonitions, and have their path be "stylesheet-images".
;; These are the graphics for Note, Caution, Warning, etc.
(define %admon-graphics-path%
  "./stylesheet-images/")

;; Use the admonition graphics?
(define %admon-graphics%
  #t)

;; Identifies the default extension for admonition graphics. This allows
;; backends to select different images (e.g., EPS for print, PNG for
;; PDF, etc.)
(define admon-graphic-default-extension
  ".png")

;; The preferred mediaobject extension.
(define preferred-mediaobject-extensions
  (list "gif" "png" "sgml" "pl" "mak" "dsl" "txt" "cfg" "dat" "mod" ""))

;; List of mediaobject filename extensions.
(define acceptable-mediaobject-extensions
  (list "jpeg" "jpg" "png" "avi" "mpg" "mpeg" "qt" "pdf" "g" "kdef" "sgml" "pl" "mak" "dsl" "txt" "cfg" "dat" "mod" ""))

;; List of inlinemediaobject filename extensions.
(define acceptable-inlinemediaobject-extensions
  (list "gif" "jpeg" "jpg" "png" "avi" "mpg" "mpeg" "qt" "pdf" "g" "kdef" "sgml" "pl" "mak" "dsl" "txt" "cfg" "dat" "mod" ""))


;; This is to fix a bug that prevents image alignment in HTML
;; We had to move the make element gi: "P" part of the mediaobject
;; element to the imagedata element. The original code is in
;; nwalsh-modular/html/db31.dsl.

(element mediaobject
  (make element gi: "DIV"
        attributes: (list (list "CLASS" (gi)))
	($mediaobject$)))
  
(element imagedata
  (if (have-ancestor? (normalize "inlinemediaobject"))
      ($img$ (current-node) #t)
      (let* ((filename (data-filename (current-node)))
         (mediaobj (parent (parent (current-node))))
         (textobjs (select-elements (children mediaobj) 
                                    (normalize "textobject")))
         (alttext  (let loop ((nl textobjs) (alttext #f))
                     (if (or alttext (node-list-empty? nl))
                         alttext
                         (let ((phrase (select-elements 
                                        (children 
                                         (node-list-first nl))
                                        (normalize "phrase"))))
                           (if (node-list-empty? phrase)
                               (loop (node-list-rest nl) #f)
                               (loop (node-list-rest nl)
                                     (data (node-list-first phrase))))))))
         (fileref   (attribute-string (normalize "fileref")))
         (entityref (attribute-string (normalize "entityref")))
         (align     (attribute-string (normalize "align")))
         (format    (if (attribute-string (normalize "format"))
                        (attribute-string (normalize "format"))
                        (if entityref
                            (entity-notation entityref)
                            #f))))
    (if (equal? format (normalize "linespecific"))
        (if fileref
            (include-file fileref)
            (include-file (entity-generated-system-id entityref)))
        (make element gi: "P"
              attributes: (if align (list (list "ALIGN" align)) '())
	      (make element gi: "IMG"
		    attributes: (append
				 (list (list "SRC" filename))
				 (if alttext
				     (list (list "ALT" alttext))
				     '()))))))))

;; End of bug fix.

;; This is supposed to fix the above bug.
;; From Norm Walsh 26 April 2001 on DocBook-Apps newsgroup.
;; It works for print stylesheet.
;(element imagedata
;  (if (have-ancestor? (normalize "mediaobject"))
;      ($img$ (current-node) #t)
;      ($img$ (current-node) #f)))


;; Decorate elements of a FuncSynopsis?
;; This makes a function name bold, and adds other things like
;; parentheses and commas, etc.
(define %funcsynopsis-decoration%
  #t)

;; This specifies the HTML extension to put on output files.
(define %html-ext% ".html")

;; What attributes should be hung off of BODY?
;; This is a list of HTML BODY attributes that will get generated.
(define %body-attr%
  '())
;;  (list
;;   (list "BGCOLOR" "#FFFFFF")
;;   (list "TEXT" "#000000")))

;; Should a Table of Contents be produced for Articles?
;; If true, a Table of Contents will be generated for each 'Article'.
(define %generate-article-toc% 
  #f)

;; Should a Table of Contents be produced for Parts?
(define %generate-part-toc% #t)

;; Should verbatim environments be shaded?
(define %shade-verbatim%
  #t)

;; These are attributes used to create a shaded verbatim environment.
(define ($shade-verbatim-attr$)
  (list
   (list "BORDER" "0")
   (list "BGCOLOR" "#f0f0f0")
   (list "WIDTH" ($table-width$))))

;; Indent lines in a 'Screen'?
;; This is a string of characters used to indent every line of
;; a screen. 
(define %indent-screen-lines%
  "    ")

;; Use ID attributes as name for component HTML files?
;; If a chapter or a section has an ID attribute, that ID is used
;; to generate the HTML file name.
(define %use-id-as-filename%
  #t)

;; Taken from David Mason posting on DB list Mar 2, 2000.
;; This puts figure titles below the figure.
(define ($object-titles-after$)
  (list (normalize "figure")))

;; If we're generating QNX helpviewer html, don't build the navigation
;; headers and footers.
(define %qnx-html% #f) ;; can be overridden on command line
(define %header-navigation%
  (if %qnx-html% #f #t))
(define %footer-navigation%
  (if %qnx-html% #f #t))

;; Have HTML indexing?
(define html-index
  #t)

;; This sets the name of HTML index file.
(define html-index-filename
  "HTML.index")

;; In DSSSL 1.76 the (make empty-element gi: "A" line causes a problem
;; for QNX4 Helpviewer.  It doesn't wrap the following line in literal
;; environments.  Changed to (make element gi: "A".
(element indexterm 
  (if html-index
      (let* ((id (if (attribute-string (normalize "id"))
                     (attribute-string (normalize "id"))
                     (generate-anchor))))
	;; Changed here:
        (make element gi: "A"
              attributes: (list (list "NAME" id))))
      (empty-sosofo)))

;; Default punctuation at the end of a run-in head.
;; This appears at the end of titles in formalpara's.
(define %default-title-end-punct%   
  " ")

;; Are sections enumerated?
;; The number appears in their title, both in the table
;; of contents, and in the text.
(define %section-autolabel%
  #t)

;; This is a fix for returnvalue problems in QNX helpviewer.
;; The HTML tag generated by returnvalue wasn't recognized by
;; the QNX helpviewer. This fix assigns it a recognizable HTML tag.
(element returnvalue
  ($mono-seq$))


;; Name for the root HTML document
;; If we want to change "book1" to "index" as the
;; root filename, we can use this:
;;        (define %root-filename%
;;          "index")

;; Use tables to build the navigation headers and footers?
;; This lets us put book titles in the header, and our copyright
;; in the footer. (See below.)
(define  %gentext-nav-use-tables%
  #t)

;; This puts a footer at bottom of every page, with our copyright
;; in it.
(define ($html-body-end$)
   (make element gi: "p"
     (make element gi: "center"
        (literal "Copyright 1995-2004 by
         Cogent Real-Time Systems, Inc."))))

;; Have the book title of a set appear in the header,
;; instead of the set title.  Code modifications by
;; Bob McIlvride.
(define (nav-banner elemnode)
  (let* ((rootelem       (ancestor-member (current-node)
					  (list (normalize "book"))))
         (info           (info-element rootelem))
         (subtitle-child (select-elements (children rootelem)
                                          (normalize "subtitle")))
         (subtitle-info  (select-elements (children info)
                                          (normalize "subtitle")))
         (subtitle       (if (node-list-empty? subtitle-info)
                             subtitle-child
                             subtitle-info))
         (banner-text    (inherited-dbhtml-value elemnode "banner-text"))
         (banner-href    (inherited-dbhtml-value elemnode "banner-href"))
         (banner         (if (and banner-text (not (string=? banner-text "")))
                             (literal banner-text)
                             (make sequence
                               (element-title-sosofo rootelem)
                               (if (node-list-empty? subtitle)
                                   (empty-sosofo)
                                   (make sequence
                                     (literal ": ")
                                     (with-mode subtitle-mode
                                       (process-node-list subtitle))))))))
    (make sequence
      (if banner-href
          (make element gi: "A"
                attributes: (list (list "HREF" banner-href))
                banner)
          banner))))

(mode htmlindex
  ;; this mode is really just a hack to get at the root element
  (root (process-children))

  (default 
    (if (node-list=? (current-node) (sgml-root-element))
        (make entity
          system-id: (html-entity-file html-index-filename)
          (process-node-list (select-elements 
                              (descendants (current-node))
                              (normalize "indexterm"))))
        (empty-sosofo)))

  (element indexterm
    (let* ((target (ancestor-member (current-node)
                                    (append (book-element-list)
                                            (division-element-list)
                                            (component-element-list)
                                            (section-element-list))))
           (title  (string-replace (element-title-string target) "&#13;" " ")))
      (make sequence
        (make formatting-instruction data: "INDEXTERM ")
        (make formatting-instruction data: (href-to target))
        (htmlnewline)

        (make formatting-instruction data: "INDEXPOINT ")
        (make formatting-instruction data: (href-to (current-node)))
        (htmlnewline)

;; Give formatting instructions for BOOK, created with Cogent's
;; customized collateindex.pl and collate-all.  Code modifications
;; by Bob McIlvride.
        (make formatting-instruction data: "BOOK ")
        (make formatting-instruction data: (element-title-string
					    (ancestor-member (current-node)
							     (list (normalize "book")))))
        (htmlnewline)

        (make formatting-instruction data: "TITLE ")
        (make formatting-instruction data: title)
        (htmlnewline)

        (htmlindexattr "scope")
        (htmlindexattr "significance")
        (htmlindexattr "class")
        (htmlindexattr "id")
        (htmlindexattr "startref")
        
        (if (attribute-string (normalize "zone"))
            (htmlindexzone (attribute-string (normalize "zone")))
            (empty-sosofo))

        (process-children)

        (make formatting-instruction data: "/INDEXTERM")
        (htmlnewline))))
                    
  (element primary
    (htmlindexterm))

  (element secondary
    (htmlindexterm))

  (element tertiary
    (htmlindexterm))

  (element see
    (htmlindexterm))

  (element seealso
    (htmlindexterm))
)

;; This puts titles into xrefs.
(define (en-xref-strings)
  (list (list (normalize "appendix")    (if %chapter-autolabel%
                                            "&Appendix; %n, %t"
                                            "the &appendix; called %t"))
        (list (normalize "article")     (string-append %gentext-en-start-quote%
                                                       "%t"
                                                       %gentext-en-end-quote%))
        (list (normalize "bibliography") "%t")
        (list (normalize "book")        "%t")
        (list (normalize "chapter")     (if %chapter-autolabel%
                                            "&Chapter; %n, %t"
                                            "the &chapter; called %t"))
        (list (normalize "equation")    "&Equation; %n, %t")
        (list (normalize "example")     "&Example; %n, %t")
        (list (normalize "figure")      "&Figure; %n, %t")
        (list (normalize "glossary")    "%t")
        (list (normalize "index")       "%t")
        (list (normalize "listitem")    "%n")
        (list (normalize "part")        "&Part; %n, %t")
        (list (normalize "preface")     "%t")
        (list (normalize "procedure")   "&Procedure; %n, %t")
        (list (normalize "reference")   "&Reference; %n, %t")
        (list (normalize "section")     (if %section-autolabel%
                                            "&Section; %n, %t"
                                            "the &section; called %t"))
        (list (normalize "sect1")       (if %section-autolabel%
                                            "&Section; %n, %t"
                                            "the &section; called %t"))
        (list (normalize "sect2")       (if %section-autolabel%
                                            "&Section; %n, %t"
                                            "the &section; called %t"))
        (list (normalize "sect3")       (if %section-autolabel%
                                            "&Section; %n, %t"
                                            "the &section; called %t"))
        (list (normalize "sect4")       (if %section-autolabel%
                                            "&Section; %n, %t"
                                            "the &section; called %t"))
        (list (normalize "sect5")       (if %section-autolabel%
                                            "&Section; %n, %t"
                                            "the &section; called %t"))
        (list (normalize "simplesect")  (if %section-autolabel%
                                            "&Section; %n, %t"
                                            "the &section; called %t"))
        (list (normalize "sidebar")     "the &sidebar; %t")
        (list (normalize "step")        "&step; %n, %t")
        (list (normalize "table")       "&Table; %n, %t")))

;; Make structure names and fields appear in monospaced font.
(element structname ($mono-seq$))
(element structfield ($mono-seq$))

;; Make GUI-related names appear in bold font.
(element guibutton ($bold-seq$))
(element guiicon ($bold-seq$))
(element guilabel ($bold-seq$))
(element guimenu ($bold-seq$))
(element guimenuitem ($bold-seq$))
(element guisubmenu ($bold-seq$))

;; Make the whole question of a qanda set bold, not just the
;; "Q:" part.
(element question
  (let* ((chlist   (children (current-node)))
         (firstch  (node-list-first chlist))
         (restch   (node-list-rest chlist)))
    (make element gi: "DIV"
          attributes: (list (list "CLASS" (gi)))
          (make element gi: "P"
                (make element gi: "A"
                      attributes: (list (list "NAME" (element-id)))
                      (empty-sosofo))
                (make element gi: "B"
                      (literal (question-answer-label (current-node)) " ")
		      (process-node-list (children firstch))))
          (process-node-list restch))))


;; Override a change in docbook-dsssl-1.76 by using code from
;; docbook-dsssl-1.71.  The change was made to generate a list of tables
;; for articles, but a side-effect is that it put an empty-element "A" instead
;; of an element "A" for chapter titles, which in Mozilla, at least, causes
;; a carriage return in the first TOC title.  The basic problem is most
;; likely a Mozilla bug that doesn't handle empty 'A' tags correctly, but
;; for the time being, we can use the 1.71 version because we don't need the
;; list of tables in articles feature.

(define ($component-title$ #!optional (titlegi "H1") (subtitlegi "H2"))
  (let* ((info (cond
                ((equal? (gi) (normalize "appendix"))
                 (select-elements (children (current-node)) (normalize "docinfo")))
                ((equal? (gi) (normalize "article"))
                 (node-list-filter-by-gi (children (current-node))
                                         (list (normalize "artheader")
                                               (normalize "articleinfo"))))
                ((equal? (gi) (normalize "bibliography"))
                 (select-elements (children (current-node)) (normalize "docinfo")))
                ((equal? (gi) (normalize "chapter"))
                 (select-elements (children (current-node)) (normalize "docinfo")))
                ((equal? (gi) (normalize "dedication"))
                 (empty-node-list))
                ((equal? (gi) (normalize "glossary"))
                 (select-elements (children (current-node)) (normalize "docinfo")))
                ((equal? (gi) (normalize "index"))
                 (select-elements (children (current-node)) (normalize "docinfo")))
                ((equal? (gi) (normalize "preface"))
                 (select-elements (children (current-node)) (normalize "docinfo")))
                ((equal? (gi) (normalize "reference"))
                 (select-elements (children (current-node)) (normalize "docinfo")))
                ((equal? (gi) (normalize "setindex"))
                 (select-elements (children (current-node)) (normalize "docinfo")))
                (else
                 (empty-node-list))))
         (exp-children (if (node-list-empty? info)
                           (empty-node-list)
                           (expand-children (children info) 
                                            (list (normalize "bookbiblio") 
                                                  (normalize "bibliomisc")
                                                  (normalize "biblioset")))))
         (parent-titles (select-elements (children (current-node)) (normalize "title")))
         (info-titles   (select-elements exp-children (normalize "title")))
         (titles        (if (node-list-empty? parent-titles)
                            info-titles
                            parent-titles))
         (subtitles     (select-elements exp-children (normalize "subtitle"))))
    (make sequence
      (make element gi: titlegi
            (make element gi: "A"
                  attributes: (list (list "NAME" (element-id)))
                  (if (and %chapter-autolabel%
                           (or (equal? (gi) (normalize "chapter"))
                               (equal? (gi) (normalize "appendix"))))
                      (literal (gentext-element-name-space (gi))
                               (element-label (current-node))
                               (gentext-label-title-sep (gi)))
                      (empty-sosofo))
                  (if (node-list-empty? titles)
                      (element-title-sosofo) ;; get a default!
                      (with-mode title-mode
                        (process-node-list titles)))))
      (if (node-list-empty? subtitles) 
          (empty-sosofo)
          (with-mode subtitle-mode
            (make element gi: subtitlegi
                  (process-node-list subtitles)))))))



</style-specification-body>
</style-specification>

<external-specification id="docbook" document="docbook.dsl">

</style-sheet>
