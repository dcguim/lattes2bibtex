;;;; -*- Mode: Lisp; Syntax: ANSI-Common-Lisp; Base: 10 -*-
(in-package :cl-user)

(defpackage :lattes2bibtex-asd
  (:use :cl :asdf))

(in-package :lattes2bibtex-asd)

(defsystem :lattes2bibtex
  :description "lattes2bibtex:Converts from a Lattes Curriculum XML to a BibTeX file"
  :version "0.0.1"
  :author "Dan C. Guim <dcguim@gmail.com>"
  :serial t
  :components ((:file "packages")	       
               (:file "lattes2bibtex"))
  :depends-on (:cxml
	       :xuriella
	       :bibtex))
  
               
              
