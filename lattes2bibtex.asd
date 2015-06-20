;;;; -*- Mode: Lisp; Syntax: ANSI-Common-Lisp; Base: 10 -*-
(in-package :asdf)

(defsystem lattes2bibtex
  :description "lattes2bibtex:converts form a Lattes Curriculum XML to a BibTeX file"
  :version "0.0.1"
  :author "Dan C. Guim <dcguim@gmail.com>"
  :depends-on (#:cxml
	       #:xuriella
	       #:bibtex)
  :components ((:file "packages")	       
               (:file "lattes2bibtex" :depends-on ("packages"))))
               
              
