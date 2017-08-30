(in-package :mx)

(defgeneric $sigmoid (x))
(defgeneric $tanh (x))
(defgeneric $relu (x))
(defgeneric $softmax (y yhat))
(defgeneric $mse (y yhat))

(defgeneric $plus (a b))
(defgeneric $minus (a b))
(defgeneric $multiply (a b))
(defgeneric $dot (a b))
(defgeneric $divide (a b))
