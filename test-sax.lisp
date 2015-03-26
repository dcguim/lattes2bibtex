(defparameter *hash* (make-hash-table))
(defparameter current-article "")

(defclass bibtex-handler (sax:default-handler)())
	     

(defmethod sax:start-element ((h bibtex-handler) (namespace t) (local-name t) (qname t) (attributes t))
  (cond ((equal local-name "ARTIGO-PUBLICADO")
	 (let ((seq (sax:attribute-value (sax:find-attribute "SEQUENCIA-PRODUCAO" attributes))))
	   (setf (gethash seq *hash*) (make-hash-table))
	   (setf current-article seq)
	   (setf (gethash 'key  (gethash current-article *hash*)) (concatenate 'string "article-" seq))))
	((equal local-name "DADOS-BASICOS-DO-ARTIGO")
	(let ((an (sax:attribute-value (sax:find-attribute "TITULO-DO-ARTIGO" attributes))))
	  (setf (gethash 'title (gethash current-article *hash*)) an)))))

;;(defmethod sax:characters ((handler tostring) data)
;;         (write-string data (acc handler)))


;;(defmethod sax:end-document ((handler tostring))     
;;  (get-output-stream-string (acc handler)))

;; use cases
;;; Parse the xml 
;;;;  (cxml:parse "<x>111<y>222</y>333</x>" (make-instance 'tostring))
;;;;  (cxml:parse #p"/Users/dcguim/common-lisp/bibtex-project/hermann-p1.xml" (make-instance 'bibtex-handler))
;;; Print the hash
;;;; (maphash #'(lambda (k v) (format t "~a: key:~a, title:~a ~%" k (gethash 'key v) (gethash 'title v))) *hash*)
