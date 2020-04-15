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
		      Path)

	      (let
		  ((_code_git_version
		    (string ,(let ((str (with-output-to-string (s)
					  (sb-ext:run-program "/usr/bin/git" (list "rev-parse" "HEAD") :output s))))
			       (subseq str 0 (1- (length str))))))
		   (_code_generation_time
		    (string ,(multiple-value-bind
				   (second minute hour date month year day-of-week dst-p tz)
				 (get-decoded-time)
			       (declare (ignorable dst-p))
			       (format nil "~2,'0d:~2,'0d:~2,'0d of ~a, ~d-~2,'0d-~2,'0d (GMT~@d)"
				       hour
				       minute
				       second
				       (nth day-of-week *day-names*)
				       year
				       month
				       date
				       (- tz)))))))

	      (space
	       "public extension String"
	       (curly
		(space @discardableResult
		       (defun shell ( "_ args: String...")
			 (declare (values String))
			 (let (((values task pipe) (values (Process)
							   (Pipe))))
			   (setf task.executableURL (URL :fileURLWithPath self)
				 (values task.arguments
					 task.standardOutput) (values args pipe))
			   (handler-case
			       (progn
				(space "try"
				       (task.run)))
			     (t (print (string "unexpected error: \\(error)."))))
			   (let ((data (pipe.fileHandleForReading.readDataToEndOfFile)))
			     (return (?? (String :data data
						 :encoding String.Encoding.utf8)
					 (string "")))))))))
	      (print (dot (string "/bin/ls")
			  (shell (string "-lh"))))
	      "// ")))) 
    (write-source (format nil "~a/source/~a" *path* *code-file*) code)))
 




