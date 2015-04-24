(defparameter *attr* (list (list "title" "TITULO-DO-ARTIGO") 
			   (list "year" "ANO-DO-ARTIGO") 
			   (list "language" "IDIOMA")  
			   (list "journal" "TITULO-DO-PERIODICO-OU-REVISTA")
			   (list "volume" "VOLUME")))


(defclass lattes-handler (sax:default-handler)
  ((hash 
    :initform (make-hash-table :test #'equalp)
    :accessor lh-hash)
   (current-article
    :initform ""
    :accessor lh-curr-art)
   (authors
    :initform '()
    :accessor lh-auths)))
    

(defun print-hash (hash)
  (maphash #'(lambda (k v) 
	       (progn
		 (format t "CHAVE:~5t~a~%" (gethash "key" v))
		 (format t "AUTOR:~33t~a~%" (gethash "author" v))
		 (dolist (at *attr*)
		   (format t "~a:~33t~a~%" (cadr at) (gethash (car at) v)))
		 (format t "~%"))) hash))

 (defun insert-pair (key value obj)
	   (setf (gethash key (gethash (lh-curr-art obj) (lh-hash obj))) value))

(defmethod sax:start-element ((lh lattes-handler) (namespace t) (local-name t) (qname t) (attributes t))
  (cond ((equal local-name "ARTIGO-PUBLICADO")
	 (setf (lh-auths lh) '())
	 (let ((seq (sax:attribute-value (sax:find-attribute "SEQUENCIA-PRODUCAO" attributes))))
	   (setf (gethash seq (lh-hash lh)) (make-hash-table))
	   (setf (lh-curr-art lh) seq)
	   (insert-pair "key" (concatenate 'string "article-" seq) lh)
	   (insert-pair "entry-type" "article" lh)))
	((or (equal local-name "DADOS-BASICOS-DO-ARTIGO") 
	     (equal local-name "DETALHAMENTO-DO-ARTIGO"))
	 (dolist (at *attr*)
	   (let ((e (sax:find-attribute (cadr at)  attributes)))
	     (if e
		 (insert-pair (car at) (sax:attribute-value e) lh)))))
	((equal local-name "AUTORES")
	 (let ((e (sax:find-attribute "NOME-COMPLETO-DO-AUTOR" attributes)))
	   (if e
	       (setf (lh-auths lh) (append (lh-auths lh) (list (sax:attribute-value e)))))))))
	       

(defmethod sax:end-element ((lh lattes-handler) (namespace t) (local-name t) (qname t))
  (cond ((equal local-name "ARTIGO-PUBLICADO")
	 (let ((auths (format nil "~{~a and ~}" (butlast (lh-auths lh)))))
	   (insert-pair "author" (concatenate 'string auths (car (last (lh-auths lh)))) lh)))))
	   
  
	
	


;; use case
;;; Make an instance of lattes-handler
;;; > (defparameter i1 (make-instance 'lattes-handler))

;;; Parse the xml 
;;; > (cxml:parse #p"/path/to/the/file.xml" i1) 

;;; Print the hash
;;; > (print-hash (lh-hash i1))
