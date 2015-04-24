(defparameter *attr* (list (list (list "title" "TITULO-DO-ARTIGO")  (list "year" "ANO-DO-ARTIGO") (list "language" "IDIOMA")
				  (list "journal" "TITULO-DO-PERIODICO-OU-REVISTA") (list "volume" "VOLUME"))
			   (list (list "year" "ANO") (list "title" "TITULO-DO-LIVRO") (list "publisher" "NOME-DA-EDITORA")  
			         (list "language" "IDIOMA"))
			   (list (list "title" "TITULO-DO-CAPITULO-DO-LIVRO") (list "publisher" "NOME-DA-EDITORA")
				 (list "year" "ANO"))))

(defparameter *entry* '(("article" . 0) ("book" . 1) ("inbook" . 2)))

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
   (current-entry-type
    :initform ""
    :accessor lh-entry-type)))
    

(defun print-hash (hash)
  (maphash #'(lambda (k v) 
	       (progn
		 (format t "CHAVE:~5t~a~%" (gethash "key" v))
		 (format t "AUTOR:~33t~a~%" (gethash "author" v))
		 (let ((type (gethash "entry-type" v)))
		   (format t "TIPO DE ENTRADA:~33t~a~%" type)
		   (if (equal type "inbook")
		       (format t "PAGINAS:~33t~a~%" (gethash "page" v)))
		   (dolist (at (nth (cdr (assoc type *entry* :test #'string=)) *attr*))
		     (format t "~a:~33t~a~%" (cadr at) (gethash (car at) v))))
		   (format t "~%"))) hash))

 (defun insert-pair (key value obj)
	   (setf (gethash key (gethash (lh-entry-no obj) (lh-hash obj))) value))

(defmethod sax:start-element ((lh lattes-handler) (namespace t) (local-name t) (qname t) (attributes t))
  (cond ((or (equal local-name "ARTIGO-PUBLICADO") 
	     (equal local-name "LIVRO-PUBLICADO-OU-ORGANIZADO")
	     (equal local-name "CAPITULO-DE-LIVRO-PUBLICADO"))
	 (setf (lh-auths lh) '())
	 (let ((seq (sax:attribute-value (sax:find-attribute "SEQUENCIA-PRODUCAO" attributes))))
	   (setf (gethash seq (lh-hash lh)) (make-hash-table :test #'equalp))
	   (setf (lh-entry-no lh) seq)
	   (cond ((equal local-name "ARTIGO-PUBLICADO")	       
		 (setf (lh-entry-type lh) 0)
		 (insert-pair "key" (concatenate 'string "article-" seq) lh)
		 (insert-pair "entry-type" "article" lh))
	       ((equal local-name "LIVRO-PUBLICADO-OU-ORGANIZADO")	
		 (setf (lh-entry-type lh) 1)
		 (insert-pair "key" (concatenate 'string "book-" seq) lh)
		 (insert-pair "entry-type" "book" lh))
	       ((equal local-name "CAPITULO-DE-LIVRO-PUBLICADO")
		(setf (lh-entry-type lh) 2)
		(insert-pair "key" (concatenate 'string "inbook-" seq) lh)
		(insert-pair "entry-type" "inbook" lh)))))
	((or (equal local-name "DADOS-BASICOS-DO-ARTIGO") (equal local-name "DETALHAMENTO-DO-ARTIGO")
	     (equal local-name "DADOS-BASICOS-DO-LIVRO")  (equal local-name "DETALHAMENTO-DO-LIVRO")
	     (equal local-name "DADOS-BASICOS-DO-CAPITULO") (equal local-name "DETALHAMENTO-DO-CAPITULO"))
	 (if (and (equal (lh-entry-type lh) (cdr (assoc "inbook" *entry* :test #'string=)))
		  (equal local-name "DETALHAMENTO-DO-CAPITULO"))			 
	     (let ((i (sax:find-attribute "PAGINA-INICIAL" attributes)) (f (sax:find-attribute "PAGINA-FINAL" attributes)))
	       (if (and i f)
		   (insert-pair "page" (format nil "~a--~a"(sax:attribute-value i) (sax:attribute-value f)) lh))))
	 (dolist (at (nth (lh-entry-type lh) *attr*))
	   (let ((e (sax:find-attribute (cadr at)  attributes)))
	     (if e
		 (insert-pair (car at) (sax:attribute-value e) lh)))))
	((equal local-name "AUTORES")
	 (let ((e (sax:find-attribute "NOME-COMPLETO-DO-AUTOR" attributes)))
	   (if e
	       (setf (lh-auths lh) (append (lh-auths lh) (list (sax:attribute-value e)))))))))
	       

(defmethod sax:end-element ((lh lattes-handler) (namespace t) (local-name t) (qname t))
  (cond ((or (equal local-name "ARTIGO-PUBLICADO") 
	     (equal local-name "LIVRO-PUBLICADO-OU-ORGANIZADO")
	     (equal local-name "CAPITULO-DE-LIVRO-PUBLICADO"))
	 (let ((auths (format nil "~{~a and ~}" (butlast (lh-auths lh)))))
	   (insert-pair "author" (concatenate 'string auths (car (last (lh-auths lh)))) lh)))))
	   
  
	
	


;; use case
;;; Make an instance of lattes-handler
;;; > (defparameter i1 (make-instance 'lattes-handler))

;;; Parse the xml 
;;; > (cxml:parse #p"/path/to/the/file.xml" i1) 

;;; Print the hash
;;; > (print-hash (lh-hash i1))
