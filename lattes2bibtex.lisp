(defparameter *directory* "/Users/dcguim/common-lisp/bibtex-project/lattes2bibtex")
(defparameter *xslt-file* "lattes2bibtexml")

(defclass lattes-handler (sax:default-handler)
 ((hash 
    :initform (make-hash-table)
    :accessor lh-hash)  
  (current-key
    :initform ""
    :accessor lh-entry-key)
  (current-elem
   :initform ""
   :accessor lh-elem)))
  
   
(defun print-hash (hash)
  "Print the hash structure"
  (maphash #'(lambda (q w)
	       (format t "[~a]: ~a~%" q w)
	       (maphash #'(lambda (k v)
			    (format t "[~a]: ~a~%" k v)) (gethash q hash))) hash))

 (defun insert-pair (entry-key field-key value obj)
   "Insert a field-key pair in the hash of hashes"
   (setf (gethash field-key 
		  (gethash entry-key (lh-hash obj))) value))

(defun lattes-to-bibtexml (filename)
  "Assume the xml is in the same *directory* as the XSLT"
  (if (stringp filename)
      (let ((out (make-string-output-stream)))	
	(xuriella:apply-stylesheet 
	 (make-pathname :directory *directory* :name *xslt-file* :type "xsl")
	 (make-pathname :directory *directory* :name filename :type "xml") :output out)
	 (get-output-stream-string out))))
	   
  
(defun lattes-to-bibtex (filename)
  "Transform the given filename to bibtexml and then parse it"
  (let ((xml (lattes-to-bibtexml filename))
	(i (make-instance 'lattes-handler)))  
    (cxml:parse xml i)
    (print-hash (lh-hash i))))

(defmethod sax:start-element ((lh lattes-handler) (namespace t) (local-name t) (qname t) (attributes t))
  (if (equal local-name "entry")
      (progn
	(setf (lh-entry-key lh) (sax:attribute-value (sax:find-attribute "id" attributes)))
	(setf (gethash (lh-entry-key lh) (lh-hash lh)) (make-hash-table))
	(insert-pair (lh-entry-key lh) "key" (lh-entry-key lh) lh))
      (setf (lh-elem lh) local-name)))
	
(defmethod sax:characters ((lh lattes-handler) data)
  (setf data (string-trim data))
  (cond ((equal (lh-elem lh) "title")
	 (insert-pair (lh-entry-key lh) "title" data lh))
	((equal (lh-elem lh) "school")
	 (insert-pair (lh-entry-key lh) "school" data lh))
	((and (equal (lh-elem lh) "author") (not (string= "\n" data)))
	 (print data)
	 ;;(print (lh-entry-key lh))
	 ;;(print (lh-elem lh))
	 (insert-pair (lh-entry-key lh) "author" data lh))))
	 
	 
