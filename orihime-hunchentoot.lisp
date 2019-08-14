;;;; orihime-hunchentoot.lisp

(in-package #:orihime-hunchentoot)

(defparameter *source-directory* (asdf:system-source-directory :orihime-hunchentoot))
(defparameter *templates-directory* (merge-pathnames "templates/" *source-directory*))
(defparameter *static-directory* (merge-pathnames "static/" *source-directory*))

(hunchentoot:start (make-instance 'hunchentoot:easy-acceptor :port 80))

(push
 (hunchentoot:create-folder-dispatcher-and-handler "/static/" *static-directory*)
 hunchentoot:*dispatch-table*)

(hunchentoot:define-easy-handler (add-text :uri "/add-text") ()
  (setf (hunchentoot:content-type*) "application/json")
  (multiple-value-bind (text-hash-hex text-hash)
      (orihime::sql-add-text
       (sb-ext:octets-to-string
        (hunchentoot:raw-post-data :request hunchentoot:*request*)))
    (cl-json:encode-json-alist-to-string `((:text-hash . ,text-hash-hex)))))

(hunchentoot:define-easy-handler (show-text :uri "/show-text") (text-hash)
  (setf (hunchentoot:content-type*) "text/html")
  (multiple-value-bind (html number-of-words)
      (orihime::text-to-html text-hash)
    (if (string= (hunchentoot:header-in* :accept) "vnd+orihime.text")
        html
        (let ((context `((:|ANKI-Text| . ,html)
                         (:|toggle-snippet| . ""))))
          (with-output-to-string (output)
            ;; Move orihime::mustache-render to something like
            ;; orihime-utils:mustache-render
            (orihime::mustache-render
             (merge-pathnames "html-template.html.mustache" *templates-directory*)
             context
             output))))))

(hunchentoot:define-easy-handler (add-child-word-to-text :uri "/add-child-word-to-text")
    (text-hash reading ocurrence (backend :init-form nil :parameter-type 'keyword))
  (let ((orihime::*current-backend* (or backend orihime::*current-backend*)))
    (format nil "~A"
            (orihime::add-child-word-to-text text-hash reading ocurrence))))


(hunchentoot:define-easy-handler (add-child-word-to-text :uri "/login")
    (userid password)
  (authenticate-user userid password))

(hunchentoot:define-easy-handler (search :uri "/search")
    (reading (backend :parameter-type 'keyword))
    (let ((orihime::*current-backend* backend))
      (format nil "~A"
              (orihime::find-definition-from-backend reading))))
