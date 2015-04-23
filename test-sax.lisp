(defparameter *attr* (list (list 'state "NATUREZA") (list 'title "TITULO-DO-ARTIGO") (list 'year "ANO-DO-ARTIGO") 
			 (list 'country "PAIS-DE-PUBLICACAO") (list 'language "IDIOMA") (list  'media "MEIO-DE-DIVULGACAO")
			 (list 'homepage "HOME-PAGE-DO-TRABALHO") (list 'en-title "TITULO-DO-ARTIGO-INGLES")))


(defclass lattes-handler (sax:default-handler)
  ((hash 
    :initform (make-hash-table)
    :accessor lh-hash)
   (current-article
    :initform ""
    :accessor lh-curr-art)))
    

(defun print-hash (hash)
  (maphash #'(lambda (k v) 
	       (progn
		 (format t "CHAVE:~5t~a~%" (gethash 'key v))
		 (dolist (at *attr*)
		   (format t "~a:~25t~a~%" (cadr at) (gethash (car at) v)))
		 (format t "~%"))) hash))

 (defun insert-pair (key value obj)
	   (setf (gethash key (gethash (lh-curr-art obj) (lh-hash obj))) value))

(defmethod sax:start-element ((lh lattes-handler) (namespace t) (local-name t) (qname t) (attributes t))
  (cond ((equal local-name "ARTIGO-PUBLICADO")
	 (let ((seq (sax:attribute-value (sax:find-attribute "SEQUENCIA-PRODUCAO" attributes))))
	   (setf (gethash seq (lh-hash lh)) (make-hash-table))
	   (setf (lh-curr-art lh) seq)
	   (insert-pair 'key (concatenate 'string "article-" seq) lh)))
	((equal local-name "DADOS-BASICOS-DO-ARTIGO")
	 (dolist (at *attr*)
	   (let ((e (sax:find-attribute (cadr at)  attributes)))
	     (if e
		 (insert-pair (car at) (sax:attribute-value e) lh)))))))
	
	


;; use case
;;; Make an instance of lattes-handler
;;; > (defparameter i1 (make-instance 'lattes-handler))

;;; Parse the xml 
;;; > (cxml:parse #p"/path/to/the/file.xml" i1) 

;;; Print the hash
;;; > (print-hash (lh-hash i1))
