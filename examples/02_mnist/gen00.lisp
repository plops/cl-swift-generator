(eval-when (:compile-toplevel :execute :load-toplevel)
  (ql:quickload "cl-swift-generator"))
  
(in-package :cl-swift-generator)

(progn
  (defparameter *path* "/home/martin/stage/cl-swift-generator/examples/02_mnist")
  (defparameter *code-file* "Sources/source/main.swift")
  (defparameter *source* (format nil "~a/~a" *path* *code-file*))
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
		      Path
		      TensorFlow)

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

	      (do0
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
			   (shell (string "-lh")))))
	      (do0
	       (space public
		      (defun downloadFile ("_ url: String"
					   "dest: String? = nil"
					   "force: Bool = false")
			(let ((dest_name (?? dest
					     (dot (/ Path.cwd
						     (dot (url.split :separator (string "/"))
							  last!))
						  string)))
			      (url_dest (URL :fileURLWithPath
					     (?? dest
						 (dot (/ Path.cwd
							 (dot (url.split :separator (string "/"))
							      last!))
						      string)))))
			  (when (and (not force)
				     (dot (! (Path dest_name))
					  exists))
			    return)
			  (print (string "Downloading \\(url)..."))
			  (do0 
			   (if (let ((cts (dot Just (get url) content))))
			       (handler-case
				   (progn
				     (space try
					    (cts.write :to (URL :fileURLWithPath dest_name))))
				 (t (print (string "Can't write to \\(url_dest).\\n \\(error)"))))
			       (print (string "Can't reach \\(url).")))))))
	       (downloadFile (string "https://storage.googleapis.com/cvdf-datasets/mnist/train-images-idx3-ubyte.gz")))

	      (do0
	       (space "protocol ConvertibleFromByte: TensorFlowScalar"
		      (progn
		       (init "_ d: UInt8")))
	       ,@(loop for e in `(Float Int32) collect
		      (format nil "extension ~a : ConvertibleFromByte {}" e))

	       (space "extension Data"
		      (progn
		       (defun "asTensor<T: ConvertibleFromByte>" ()
			 (declare (values Tensor<T>))
			 (return (Tensor (map T.init))))))
	       
	       (defun "loadMNIST<T: ConvertibleFromByte>" ("training: Bool"
				    "labels: Bool"
				    "path: Path"
				    "flat: Bool")
		    (declare (values ,(format nil "Tensor<T>")))
		    (let ((split (? training (string "train") (string "t10k")))
			  (kind (? labels (string "labels") (string "images")))
			  (batch (? training 60000 10000))
			  ("shape: TensorShape"
			   (? labels
			      (list batch)
			      (? flat
				 (list batch 784)
				 (list batch 28 28))))
			  (dropK (? labels 8 16))
			  (baseURL (string "https://storage.googleapis.com/cvdf-datasets/mnist/"))
			  (fname (+ split
				    (string "-")
				    kind
				    (string "-idx\\(labels ? 1 : 3)-ubyte")))
			  (file (/ path fname)))
		      (unless file.exists
			(let ((gz (dot (/ path (string "\\(fname).gz")) string)))
			  (downloadFile (string "\\(baseURL)\\(fname).gz")
					:dest gz
					)
			  (dot (string "/bin/gunzip")
			       (shell (string "-fq")
				      gz))))
		      (let ((data (space try!
					 (dot (Data :contentsOf (URL :fileURLWithPath file.string))
					      (dropFirst dropK)))))
			(if labels
			    (return (data.asTensor))
			    (return (dot data
					 (asTensor)
					 (reshaped :to shape))))))))
	      "// ")))) 
    (write-source (format nil "~a/source/~a" *path* *code-file*) code)))
 




