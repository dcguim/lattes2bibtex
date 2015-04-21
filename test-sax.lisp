(defparameter *hash* (make-hash-table))
(defparameter *curr-article* "")
(defparameter *attr* (list (list 'state "NATUREZA") (list 'title "TITULO-DO-ARTIGO") (list 'year "ANO-DO-ARTIGO") 
			 (list 'country "PAIS-DE-PUBLICACAO") (list 'language "IDIOMA") (list  'media "MEIO-DE-DIVULGACAO")
			 (list 'homepage "HOME-PAGE-DO-TRABALHO") (list 'en-title "TITULO-DO-ARTIGO-INGLES")))


(defclass bibtex-handler (sax:default-handler)())

(defun print-hash ()
  (maphash #'(lambda (k v) 
	       (progn
		 (format t "CHAVE:~5t~a~%" (gethash 'key v))
		 (dolist (at *attr*)
		   (format t "~a:~25t~a~%" (cadr at) (gethash (car at) v)))
		 (format t "~%"))) *hash*))

 (defun insert-pair (key value)
	   (setf (gethash key (gethash *curr-article* *hash*)) value))	     

(defmethod sax:start-element ((h bibtex-handler) (namespace t) (local-name t) (qname t) (attributes t))
  (cond ((equal local-name "ARTIGO-PUBLICADO")
	 (let ((seq (sax:attribute-value (sax:find-attribute "SEQUENCIA-PRODUCAO" attributes))))
	   (setf (gethash seq *hash*) (make-hash-table))
	   (setf *curr-article* seq)
	   (insert-pair 'key (concatenate 'string "article-" seq))))
	((equal local-name "DADOS-BASICOS-DO-ARTIGO")
	 (dolist (elem *attr*)
	   (let ((e (sax:find-attribute (cadr elem)  attributes)))
	     (if e
	         (insert-pair (car elem) (sax:attribute-value e))))))))

	
	

;;(defmethod sax:characters ((handler tostring) data)
;;         (write-string data (acc handler)))


;;(defmethod sax:end-document ((handler tostring))     
;;  (get-output-stream-string (acc handler)))

;; use cases
;;; Parse the xml 
;;;;  (cxml:parse "<x>111<y>222</y>333</x>" (make-instance 'tostring))
;;;;  (cxml:parse #p"/Users/dcguim/common-lisp/xml2bibtex/hermann-p1.xml" (make-instance 'bibtex-handler))
;;; Print the hash
;;;(maphash #'(lambda (k v) (format t "~a: key:~a, title:~a ~% year:~a country:~a lang:~a ~% media:~a homepage:~a en-title:~a ~%" k (gethash 'key v) (gethash 'title v) (gethash 'year v) (gethash 'country v) (gethash 'language v) (gethash 'media v) (gethash 'homepage v) (gethash 'en-title v))) *hash*)
