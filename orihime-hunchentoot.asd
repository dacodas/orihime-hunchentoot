;;;; orihime-hunchentoot.asd

(asdf:defsystem #:orihime-hunchentoot
  :description "Describe orihime-hunchentoot here"
  :author "Your Name <your.name@example.com>"
  :license  "Specify license here"
  :version "0.0.1"
  :serial t
  :components ((:file "package")
               (:file "orihime-hunchentoot"))
  :depends-on (:hunchentoot :orihime))
