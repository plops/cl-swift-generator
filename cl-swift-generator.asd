(asdf:defsystem cl-kotlin-generator
    :version "0"
    :description "Emit kotlin Language code"
    :maintainer " <kielhorn.martin@gmail.com>"
    :author " <kielhorn.martin@gmail.com>"
    :licence "GPL"
    :depends-on ("alexandria")
    :serial t
    :components ((:file "package")
		 (:file "kotlin")
		 (:file "xml")
		 ) )
