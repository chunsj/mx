(defpackage :mx
  (:use #:common-lisp
        #:fnv
        #:cl-blapack)
  (:export #:mx
           #:$m
           #:$nrow
           #:$ncol
           #:$
           #:$transpose
           #:$transpose!
           #:$mm))
