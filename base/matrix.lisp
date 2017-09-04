(in-package :mx)

;; if you want to change from flaot to double, change followings
(defparameter *fnv-type* 'FNV-FLOAT)
(defmacro fnv (n &optional (iv 0)) `(make-fnv-float ,n :initial-value ,iv))
(defmacro vrf (v i) `(fnv-float-ref ,v ,i))
;; end of type change

(defparameter *print-maxn* 8)

;; column major order
(defclass MX ()
  ((fnv :initarg :fnv :accessor %nv :initform nil)
   (nr :initarg :nr :accessor %nr :initform 0)
   (nc :initarg :nc :accessor %nc :initform 0)
   (tr :accessor %tr :initform nil)))

(defgeneric $nrow (m))
(defgeneric $ncol (m))

(defmethod $nrow ((m MX)) (if (%tr m) (%nc m) (%nr m)))
(defmethod $ncol ((m MX)) (if (%tr m) (%nr m) (%nc m)))

(defmacro mx (vs nr nc) `(make-instance 'MX :fnv ,vs :nr ,nr :nc ,nc))

(defun fnv-from-seq (seq)
  (let ((v (fnv (length seq))))
    (loop :for i :from 0 :below (length seq)
          :do (setf (vrf v i) (float (elt seq i))))
    v))

(defun %mx (values &key nr nc)
  (cond ((typep values 'NUMBER) (mx (fnv (* nr nc) values) nr nc))
        ((typep values 'SEQUENCE) (mx (fnv-from-seq values) nr nc))
        ((typep values *fnv-type*) (mx values nr nc))))

(defun cpmx (mx)
  (let ((v (fnv (fnv-length (%nv mx)))))
    (loop :for i :from 0 :below (fnv-length v)
          :do (setf (vrf v i) (vrf (%nv mx) i)))
    (%mx v :nr (%nr mx) :nc (%nc mx))))

(defun bmx (seq)
  (let ((e (elt seq 0)))
    (cond ((typep e 'SEQUENCE) (let* ((nr (length seq))
                                      (nc (length e))
                                      (vs (fnv (* nr nc))))
                                 (dotimes (j nc)
                                   (dotimes (i nr)
                                     (setf (vrf vs (+ (* nr j) i)) (* 1.0 (elt (elt seq i) j)))))
                                 (%mx vs :nr nr :nc nc)))
          ((typep e *fnv-type*) (let* ((nr (length seq))
                                       (nc (fnv-length e))
                                       (vs (fnv (* nr nc))))
                                  (dotimes (j nc)
                                    (dotimes (i nr)
                                      (setf (vrf vs (+ (* nr j) i)) (vrf (elt seq i) j))))
                                  (%mx vs :nr nr :nc nc)))
          ((typep e 'NUMBER) (%mx seq :nr (length seq) :nc 1)))))

(defun $m (data &optional (d0 nil) (d1 nil))
  (cond ((typep data 'MX) (cpmx data))
        ((and (typep data 'NUMBER) d0 d1) (%mx (fnv (* d0 d1) (* 1.0 data)) :nr d0 :nc d1))
        ((typep data 'NUMBER) ($mx (fnv 1 data) :nr 1 :nc 1))
        ((and (typep data 'SEQUENCE) (eq d0 nil) (eq d1 nil)) (bmx data))
        ((and (typep data 'SEQUENCE) d0 d1) (%mx data :nr d0 :nc d1))
        ((and (typep data *fnv-type*) d0) (%mx data :nr d0 :nc (/ (fnv-length data) d0)))
        ((and (typep data 'SEQUENCE) d0) (%mx data :nr d0 :nc (/ (length data) d0)))))

(defun %get (m &optional (i T) (j T))
  (cond ((not (typep m 'mx)) nil)
        ((and (eq i T) (eq j T)) m)
        ((and (eq i T) (numberp j)) (let* ((nr (%nr m))
                                           (r ($m 0 nr 1))
                                           (mvs (%nv m))
                                           (rvs (%nv r)))
                                      (dotimes (ii nr)
                                        (setf (vrf rvs ii) (vrf mvs (+ (* nr j) ii))))
                                      r))
        ((and (numberp i) (eq j T)) (let* ((nc (%nc m))
                                           (nr (%nr m))
                                           (r ($m 0 1 nc))
                                           (mvs (%nv m))
                                           (rvs (%nv r)))
                                      (dotimes (jj nc)
                                        (setf (vrf rvs jj) (vrf mvs (+ i (* nr jj)))))
                                      r))
        ((and (numberp i) (numberp j)) (let* ((nr (%nr m))
                                              (mvs (%nv m)))
                                         (vrf mvs (+ i (* nr j)))))))

(defun $ (m &optional (i T) (j T))
  (if (%tr m) (%get m j i) (%get m i j)))

(defun %setv (m nv &optional (i T) (j T))
  (cond ((and (eq i T) (eq j T)) (cond ((numberp nv) (let ((sz (fnv-length (%nv m)))
                                                           (vs (%nv m)))
                                                       (dotimes (i sz) (setf (vrf vs i) (* 1.0 nv)))
                                                       m))
                                       ((and (typep nv 'MX)
                                             (= (%nr m) (%nr nv))
                                             (= (%nc m) (%nc nv)))
                                        (let ((vs (%nv m))
                                              (nvs (%nv nv)))
                                          (dotimes (i (fnv-length vs)) (setf (vrf vs i) (vrf nvs i)))
                                          m))))
        ((and (eq i T) (numberp j)) (cond ((numberp nv)
                                           (let ((mvs (%nv m))
                                                 (nrm (%nr m)))
                                             (dotimes (ii nrm)
                                               (setf (vrf mvs (+ (* nrm j) ii)) (* 1.0 nv)))))
                                          ((and (typep nv 'MX)
                                                (= (%nr m) (%nr nv))
                                                (= 1 (%nc nv)))
                                           (let ((mvs (%nv m))
                                                 (nrm (%nr m))
                                                 (nvs (%nv nv)))
                                             (dotimes (ii nrm)
                                               (setf (vrf mvs (+ (* nrm j) ii)) (vrf nvs ii)))))))
        ((and (numberp i) (eq j T)) (cond ((numberp nv)
                                           (let ((mvs (%nv m))
                                                 (nrm (%nr m))
                                                 (ncm (%nc m)))
                                             (dotimes (jj ncm)
                                               (setf (vrf mvs (+ (* nrm jj) i))
                                                     (* 1.0 nv)))))
                                          ((and (typep nv 'MX)
                                                (= (%nc m) (%nc nv))
                                                (= 1 (%nr nv)))
                                           (let ((mvs (%nv m))
                                                 (nrm (%nr m))
                                                 (ncm (%nc m))
                                                 (nvs (%nv nv)))
                                             (dotimes (jj ncm)
                                               (setf (vrf mvs (+ (* nrm jj) i)) (vrf nvs jj)))))))
        ((and (numberp i) (numberp j)) (let* ((nr (%nr m))
                                              (mvs (%nv m)))
                                         (setf (vrf mvs (+ i (* nr j))) (* 1.0 nv))))))

(defun %set (m nv &optional (i T) (j T)) (if (%tr m) (%setv m nv j i) (%setv m nv i j)))

(defsetf $ (m i j) (v) `(%set ,m ,v ,i ,j))

(defmethod print-object ((m MX) stream)
  (let ((nr0 ($nrow m))
        (nc0 ($ncol m))
        (nr ($nrow m))
        (nc ($ncol m))
        (coltr? nil)
        (rowtr? nil)
        (halfmx (/ *print-maxn* 2)))
    (when (> nr *print-maxn*)
      (setf rowtr? T)
      (setf nr *print-maxn*))
    (when (> nc *print-maxn*)
      (setf coltr? T)
      (setf nc *print-maxn*))
    (format stream "MX[~A x ~A] : ~%" nr0 nc0)
    (loop :for i :from 0 :below nr
          :do (let ((i (if (and rowtr? (>= i halfmx)) (- nr0 (- *print-maxn* i)) i)))
                (format stream "")
                (loop :for j :from 0 :below nc
                      :do (let ((j (if (and coltr? (>= j halfmx)) (- nc0 (- *print-maxn* j)) j)))
                            (if (< j (1- nc0))
                                (if (and coltr? (= j (- nc0 halfmx)))
                                    (format stream " ··· ~10,2E " ($ m i j))
                                    (format stream "~10,2E " ($ m i j)))
                                (format stream "~10,2E" ($ m i j)))))
                (if (and rowtr? (= i (1- halfmx)))
                    (format stream "~%~%   ···~%~%")
                    (format stream "~%"))))))

(defun $transpose! (m)
  (setf (%tr m) (not (%tr m)))
  m)

(defun $transpose (m)
  (let ((nm ($m m)))
    ($transpose! nm)))

(defun rn (n)
  (loop :for i :from 0 :below n :collect (random 1.0)))

(defun $ru (&optional d0 d1)
  (cond ((and (eq d0 nil) (eq d1 nil)) ($m (random 1.0) 1 1))
        ((and d0 (eq d1 nil)) ($m (rn d0) d0 1))
        ((and d0 d1) ($m (rn (* d0 d1)) d0 d1))))

(defun random-normal ()
  (coerce (* (sqrt (* -2.0 (log (- 1.0 (random 1.0)))))
             (cos (* 2.0 PI (random 1.0))))
          'float))

(defun rnn (n)
  (loop :for i :from 0 :below n :collect (random-normal)))

(defun $rn (&optional d0 d1)
  (cond ((and (eq d0 nil) (eq d1 nil)) ($m (random-normal) 1 1))
        ((and d0 (eq d1 nil)) ($m (rnn d0) d0 1))
        ((and d0 d1) ($m (rnn (* d0 d1)) d0 d1))))

(defun $ones (&optional d0 d1)
  (cond ((and (eq d0 nil) (eq d1 nil)) ($m 1 1 1))
        ((and d0 (eq d1 nil)) ($m (loop :for i :from 0 :below d0 :collect 1.0) d0 1))
        ((and d0 d1) ($m (loop :for i :from 0 :below (* d0 d1) :collect 1.0) d0 d1))))

(defun $zeros (&optional d0 d1)
  (cond ((and (eq d0 nil) (eq d1 nil)) ($m 0 1 1))
        ((and d0 (eq d1 nil)) ($m (loop :for i :from 0 :below d0 :collect 0.0) d0 1))
        ((and d0 d1) ($m (loop :for i :from 0 :below (* d0 d1) :collect 0.0) d0 d1))))
