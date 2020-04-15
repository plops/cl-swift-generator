(eval-when (:compile-toplevel :execute :load-toplevel)
  (ql:quickload "cl-swift-generator"))
  
(in-package :cl-swift-generator)

(progn
  (defparameter *path* "/home/martin/stage/cl-swift-generator/examples/02_mnist")
  (defparameter *code-file* "run_00_mnist.swift")
  (defparameter *source* (format nil "~a/source/~a" *path* *code-file*))
  (defparameter *inspection-facts*
    `((10 "")))
  (defparameter *day-names*
    '("Monday" "Tuesday" "Wednesday"
      "Thursday" "Friday" "Saturday"
      "Sunday"))

  (defparameter *sections*
    `((:name dbrf :length .204 :jsat 23.54)
      (:name dbrb :length .495 :jsat 21.87)
      (:name phase :length .1 :jsat 23)))
  (defun lookup-sections (name &optional key)
    (loop for e in *sections* do
      (when (eq name (getf e :name))
	(unless key
	  (return e))
	(return (getf e key)))))
  
  (let* ((code
	  `(do0
	     (do0
              (import Foundation
		      Just
		      Path))
	     ))) 
    (write-source (format nil "~a/source/~a" *path* *code-file*) code)))
 




