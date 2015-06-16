(defparameter *directory* "~/common-lisp/bibtex-project/xml2bibtex/")
(defparameter *xslt-file* "lattes2bibtexml")

(defclass lattes-handler (sax:default-handler)
 ((hash 
    :initform (make-hash-table)
    :accessor lh-hash)
   (current-entry-number
    :initform ""
    :accessor lh-entry-no)
   (authors
    :initform '()
    :accessor lh-auths)
   (current-entry-code
    :initform ""
    :accessor lh-entry-code)))

 (defun insert-pair (key value obj)
   (setf (gethash key (gethash (lh-entry-no obj) (lh-hash obj))) value))

(defmethod lattes-to-bibtexml (filename)
  "Assume the input xml is in the same path as the XSLT"
  (if (stringp filename)
      (let ((out (make-string-output-stream)))	
	(xuriella:apply-stylesheet 
	 (make-pathname :directory *directory* :name *xslt-file* :type "xsl")
	 (make-pathname :directory *directory* :name filename :type "xml") :output out))))
	   
  

