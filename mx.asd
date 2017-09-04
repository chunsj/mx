(asdf:defsystem mx
  :name "mx"
  :author "Sungjin Chun <chunsj@gmail.com>"
  :version "0.1"
  :maintainer "Sungjin Chun <chunsj@gmail.com>"
  :license "GPL3"
  :description "my own matrix library for deep learning"
  :long-description "trying to make a better library for me"
  :depends-on ("org.middleangle.foreign-numeric-vector"
               "org.middleangle.cl-blapack")
  :components ((:file "package")
               (:module base :components ((:file "matrix")
                                          (:file "opers")))))
