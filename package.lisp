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
           #:$ru
           #:$rn
           #:$ones
           #:$zeros
           #:$mm))
