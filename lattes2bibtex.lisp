(defparameter *directory* "/Users/dcguim/common-lisp/bibtex-project/xml2bibtex")
(defparameter *xslt-file* "lattes2bibtexml")

(defclass lattes-handler (sax:default-handler)
 ((hash 
    :initform (make-hash-table)
    :accessor lh-hash)  
  (current-key
    :initform ""
    :accessor lh-entry-key)))
  
   
(defun print-hash (hash)
  (maphash #'(lambda (k v)
	       (format t "~a ~a~%" k v)) hash))

 (defun insert-pair (key value obj)
   (setf (gethash key (lh-hash obj)) value))

(defun lattes-to-bibtexml (filename)
  "Assume the xml is in the same *directory* as the XSLT"
  (if (stringp filename)
      (let ((out (make-string-output-stream)))	
	(xuriella:apply-stylesheet 
	 (make-pathname :directory *directory* :name *xslt-file* :type "xsl")
	 (make-pathname :directory *directory* :name filename :type "xml") :output out)
	 (get-output-stream-string out))))
	   
  
(defun lattes-to-bibtex (filename)
  (let ((xml (lattes-to-bibtexml filename))
	(i (make-instance 'lattes-handler)))  
    (cxml:parse xml i)
    (print-hash (lh-hash i))))

(defmethod sax:start-element ((lh lattes-handler) (namespace t) (local-name t) (qname t) (attributes t))
  (cond ((equal local-name "entry")
	 (setf (lh-entry-key lh) (sax:attribute-value (sax:find-attribute "id" attributes)))
	 (insert-pair (lh-entry-key lh) (make-hash-table) lh))))
	
	 
