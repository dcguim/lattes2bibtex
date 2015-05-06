(defparameter *attr* (list (list (list "title" "TITULO-DO-ARTIGO")  (list "year" "ANO-DO-ARTIGO") (list "language" "IDIOMA")
				  (list "journal" "TITULO-DO-PERIODICO-OU-REVISTA") (list "volume" "VOLUME"))
			   (list (list "year" "ANO") (list "title" "TITULO-DO-LIVRO") (list "publisher" "NOME-DA-EDITORA")  
			         (list "language" "IDIOMA"))
			   (list (list "title" "TITULO-DO-CAPITULO-DO-LIVRO") (list "publisher" "NOME-DA-EDITORA")
				 (list "year" "ANO")(list "booktitle" "TITULO-DO-LIVRO"))
			   (list (list "title" "TITULO-DA-DISSERTACAO-TESE") (list "year" "ANO-DE-OBTENCAO-DO-TITULO")
				 (list "school" "NOME-INSTITUICAO"))
			   (list (list "title" "TITULO-DA-DISSERTACAO-TESE") (list "year" "ANO-DE-OBTENCAO-DO-TITULO")
				 (list "school" "NOME-INSTITUICAO"))))
  

(defparameter *entry-data* (list "DADOS-BASICOS-DO-ARTIGO" "DETALHAMENTO-DO-ARTIGO"
				 "DADOS-BASICOS-DO-LIVRO" "DETALHAMENTO-DO-LIVRO"
				 "DADOS-BASICOS-DO-CAPITULO" "DETALHAMENTO-DO-CAPITULO"
				 "MESTRADO" "DOUTORADO"))

(defparameter *entry-name* (list "ARTIGO-PUBLICADO"
				 "LIVRO-PUBLICADO-OU-ORGANIZADO"
				 "CAPITULO-DE-LIVRO-PUBLICADO"))

(defparameter *entry-code* '(("article" . 0) ("book" . 1) ("incollection" . 2)
			     ("masterthesis" . 3) ("phdthesis" . 4)))

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

(defmacro comp-lname (entries)
  (let ((ent (eval entries)))
    `(or 
      ,@(loop for e in ent collect `(equal local-name ,e)))))

 (defun insert-pair (key value obj)
	   (setf (gethash key (gethash (lh-entry-no obj) (lh-hash obj))) value))

(defun insert-entry (type obj)
  (let ((code (cdr (assoc type *entry-code* :test #'string=)))
	(-seq (concatenate 'string "-" (lh-entry-no obj))))
    (when code	
      (setf (lh-entry-code obj) code)
      (insert-pair "key" (concatenate 'string type -seq) obj)
      (insert-pair "entry-type" type obj))))

(defun print-hash (hash)
  (maphash #'(lambda (k v) 
	       (progn
		 (format t "CHAVE:~5t~a~%" (gethash "key" v))
		 (format t "AUTOR:~33t~a~%" (gethash "author" v))
		 (let ((type (gethash "entry-type" v)))
		   (format t "TIPO DE ENTRADA:~33t~a~%" type)
		   (if (equal type "incollection")
		       (format t "PAGINAS:~33t~a~%" (gethash "page" v)))
		   (dolist (at (nth (cdr (assoc type *entry-code* :test #'string=)) *attr*))
		     (format t "~a:~33t~a~%" (cadr at) (gethash (car at) v))))
		   (format t "~%"))) hash))



(defmethod sax:start-element ((lh lattes-handler) (namespace t) (local-name t) (qname t) (attributes t))
  (cond ((equal local-name "DADOS-GERAIS")
	 (let ((n (sax:find-attribute "NOME-COMPLETO" attributes)))
	   (if n
	       (setf (lh-auths lh) (sax:attribute-value n)))))

	((comp-lname (list "MESTRADO" "DOUTORADO"))
	 (let ((seq (sax:find-attribute "SEQUENCIA-FORMACAO" attributes)))
	   (when seq
	     (setf (lh-entry-no lh) (concatenate 'string "f-" (sax:attribute-value seq)))
	     (setf (gethash (lh-entry-no lh) (lh-hash lh)) (make-hash-table :test #'equalp))	     
	     (cond ((equal local-name "MESTRADO")
		    (insert-entry "masterthesis" lh))
		   ((equal local-name "DOUTORADO")
		    (insert-entry "phdthesis" lh)))))
	 (dolist (at (nth (lh-entry-code lh) *attr*))
	   (let ((e (sax:find-attribute (cadr at)  attributes)))
	     (when e
		 (print e)
		 (sax:attribute-value e)
		 (insert-pair (car at) (sax:attribute-value e) lh)))))

	((comp-lname *entry-name*)	      
	 (setf (lh-auths lh) '())
	 (let ((seq (sax:find-attribute "SEQUENCIA-PRODUCAO" attributes)))
	   (when seq
	       (setf (gethash (sax:attribute-value seq) (lh-hash lh)) (make-hash-table :test #'equalp))
	       (setf (lh-entry-no lh) (sax:attribute-value seq))
	       (cond ((equal local-name "ARTIGO-PUBLICADO")      
		      (insert-entry "article" lh))
		     ((equal local-name "LIVRO-PUBLICADO-OU-ORGANIZADO")	
		      (insert-entry "book" lh))
		     ((equal local-name "CAPITULO-DE-LIVRO-PUBLICADO")
		      (insert-entry "incollection" lh))))))

        ((and (comp-lname *entry-data*)
	      (or (equal (lh-entry-code lh) 0)
		  (equal (lh-entry-code lh) 1)
		  (equal (lh-entry-code lh) 2)
		  (equal (lh-entry-code lh) 3)
		  (equal (lh-entry-code lh) 4)))
	(if (and (equal (lh-entry-code lh) (cdr (assoc "incollection" *entry-code* :test #'string=)))
		  (equal local-name "DETALHAMENTO-DO-CAPITULO"))			 
	     (let ((i (sax:find-attribute "PAGINA-INICIAL" attributes)) (f (sax:find-attribute "PAGINA-FINAL" attributes)))
	       (if (and i f)
		   (insert-pair "page" (format nil "~a--~a"(sax:attribute-value i) (sax:attribute-value f)) lh))))
	 (dolist (at (nth (lh-entry-code lh) *attr*))
	   (let ((e (sax:find-attribute (cadr at)  attributes)))
	     (if e
		 (insert-pair (car at) (sax:attribute-value e) lh)))))

	((and (equal local-name "AUTORES")	 
	      (or (equal (lh-entry-code lh) 0)
		  (equal (lh-entry-code lh) 1)
		  (equal (lh-entry-code lh) 2)))
	 (let ((e (sax:find-attribute "NOME-COMPLETO-DO-AUTOR" attributes)))
	   (if e
	       (setf (lh-auths lh) (append (lh-auths lh) (list (sax:attribute-value e)))))))))


(defmethod sax:end-element ((lh lattes-handler) (namespace t) (local-name t) (qname t))
  (cond ((comp-lname *entry-name*)
	 (let ((auths (format nil "~{~a and ~}" (butlast (lh-auths lh)))))
	   (insert-pair "author" (concatenate 'string auths (car (last (lh-auths lh)))) lh)))
	((or (equal local-name "MESTRADO")
	     (equal local-name "DOUTORADO"))	 
	 (insert-pair "author" (lh-auths lh) lh)))
    (when (comp-lname (append  *entry-name* (list "MESTRADO" "DOUTORADO")))
      (setf (lh-entry-code lh) -1)
      (setf (lh-auths lh) '())
      (setf (lh-entry-no lh) -1)))
    
	 
	

	   
  
	
	


;; use case
;;; Make an instance of lattes-handler
;;; > (defparameter i1 (make-instance 'lattes-handler))


;;; Parse the xml 
;;; > (cxml:parse #p"/path/to/the/file.xml" i1) 

;;; Print the hash
;;; > (print-hash (lh-hash i1))
