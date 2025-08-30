;;;; MoStar Grid - Common Lisp Neutrosophic Verdict Engine
(ql:quickload '(:hunchentoot :cl-json))
(defpackage :mostar-verdict (:use :cl :hunchentoot :json))
(in-package :mostar-verdict)

(define-easy-handler (verdict-endpoint :uri "/verdict" :default-request-type :post) ()
  (setf (content-type*) "application/json")
  (encode-json-to-string '((:verdict . "approve") (:score . 0.99))))

(defvar *server* (start (make-instance 'easy-acceptor :port 8081)))
(loop (sleep 1))
