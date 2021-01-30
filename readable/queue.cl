;  Sweet-Expressions - Common Lisp - Queue example

in-package("USER")

;; Define a default size for the queue.
defconstant(default-queue-size 100 "Default size of a queue")

;;; The following structure encapsulates a queue. It contains a
;;; simple vector to hold the elements and a pair of pointers to
;;; index into the vector. One is a "put pointer" that indicates
;;; where the next element is stored into the queue. The other is
;;; a "get pointer" that indicates the place from which the next
;;; element is retrieved.
;;; When put-ptr = get-ptr, the queue is empty.
;;; When put-ptr + 1 = get-ptr, the queue is full.
defstruct queue(:constructor(create-queue)
                :print-function(queue-print-function))
  elements(#() :type simple-vector) ; simple vector of elements
  put-ptr(0 :type fixnum) ; next place to put an element
  get-ptr(0 :type fixnum) ; next place to take an element

defun queue-next (queue ptr)
  "Increment a queue pointer by 1 and wrap around if needed."
  let
    group
      length length(queue-elements(queue))
      try the(fixnum (1+ ptr))
    if {try = length} 0 try

defun queue-get (queue &optional (default nil))
  check-type(queue queue)
  let
    group
      get queue-get-ptr(queue)
      put queue-put-ptr(queue)
    if {get = put} ;; Queue is empty.
        default
        prog1
          svref queue-elements(queue) get
          setf queue-get-ptr(queue) queue-next(queue get)

;; Define a function to put an element into the queue. If the
;; queue is already full, QUEUE-PUT returns NIL. If the queue
;; isn't full, QUEUE-PUT stores the element and returns T.
defun queue-put (queue element)
  "Store ELEMENT in the QUEUE and return T on success or NIL on failure."
  check-type(queue queue)
  let*
    group
      get queue-get-ptr(queue)
      put queue-put-ptr(queue)
      next queue-next(queue put)
    unless {get = next} ;; store element
      setf svref(queue-elements(queue) put) element
      setf queue-put-ptr(queue) next ; update put-ptr
      t ; indicate success 

