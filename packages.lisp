(in-package :cl-user)

(defpackage :lattes2bibtex
  (:use :cl)
  (:export #:lattes-to-bibtex
	   #:lattes-to-bibtexml
	   #:print-hash))
