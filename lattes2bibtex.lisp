(defparameter *directory* "/Users/dcguim/common-lisp/bibtex-project/lattes2bibtex")
(defparameter *xslt-file* "lattes2bibtexml")
(defparameter *fields* '("title" "author" "school" "year" "journal" "volume" "publisher" "booktitle"))
(defparameter *entries* '("masterthesis" "phdthesis" "article" "incollection" "book" "inproceedings" ))

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
  "Setf the instance slots and build the second level of the structure"
  (cond ((equal local-name "entry")
	 (setf (lh-entry-key lh) (sax:attribute-value (sax:find-attribute "id" attributes)))
	 (setf (gethash (lh-entry-key lh) (lh-hash lh)) (make-hash-table))
	 (insert-pair (lh-entry-key lh) "key" (lh-entry-key lh) lh))
	((find local-name *entries* :test #'string=)
	 (insert-pair (lh-entry-key lh) "entry-type" local-name lh))
	(t setf (lh-elem lh) local-name)))

(defmacro compose-insertions (fields)
  "The term compose was used to uphold the artistic aspect of macros"
  (let ((f (eval fields)))
    `(cond 
       ,@(loop for i in f collect `((equal (lh-elem lh) ,i)
				    (insert-pair (lh-entry-key lh) ,i data lh))))))
	      	
(defmethod sax:characters ((lh lattes-handler) data)
  "Insert the element values to the hash"
  (setf data (string-trim '(#\Space #\Tab #\Newline) data))
  (when (string/= "" data)
    (compose-insertions *fields*)))
	  
	 
	 
