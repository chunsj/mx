(in-package :mx)

;; with float. if you want double, change %sgemm to %dgemm
(defun $gemm (a b &key (alpha 1.0) (beta 0.0) (c nil) (transa nil) (transb nil))
  (let* ((nra (if transa ($ncol a) ($nrow a)))
         (nca (if transa ($nrow a) ($ncol a)))
         (ncb (if transb ($nrow b) ($ncol b)))
         (c (or c ($m (fnv (* nra ncb)) nra ncb)))
         (m nra)
         (n ncb)
         (k nca)
         (lda (if transa k m))
         (ldb (if transb n k))
         (ldc m)
         (transa (if transa "T" "N"))
         (transb (if transb "T" "N"))
         (ax (%nv a))
         (bx (%nv b))
         (cx (%nv c)))
    (%sgemm transa transb m n k
            alpha
            ax lda bx ldb
            beta
            cx ldc)
    c))

(defun $axpy (a b &key (alpha 1.0) (incx 1) (incy 1))
  (let ((n (fnv-length (%nv a))))
    (%saxpy n alpha (%nv a) incx (%nv b) incy)
    b))

(defun $scal (alpha x &key (incx 1))
  (let ((n (fnv-length (%nv x))))
    (%sscal n alpha (%nv x) incx)
    x))

(defun $wxpb (w x b)
  ;; XXX b should be broadcasted
  ;; XXX gemm should use predefined target location of c
  ($axpy ($gemm w x) b))

(defun $wtz (w z)
  ;; XXX should use predefined target location of c
  ($gemm w z :transa T))
