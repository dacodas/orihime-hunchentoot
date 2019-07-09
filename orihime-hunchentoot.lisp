;;;; orihime-hunchentoot.lisp

(in-package #:orihime-hunchentoot)


(hunchentoot:start (make-instance 'hunchentoot:easy-acceptor :port 80))
(hunchentoot:define-easy-handler (simple-lisp-rpc :uri "/simple-lisp-rpc") ()
  (setf (hunchentoot:content-type*) "application/json")
  (let ((json (cl-json:decode-json-from-source
               (sb-ext:octets-to-string
                (hunchentoot:raw-post-data :force-binary t)))))
    (destructuring-bind (function-name &rest rest) 
        json
      (format nil "~S~%"
              (let ((orihime::*current-backend* :larousse))
                (apply (intern (string-upcase function-name) (find-package :orihime)) rest))))))

(defun orihime::text-from-hash (text-hash)
  (second (dbi:fetch (orihime::grab-text (orihime::sql-text-id-from-hash text-hash)))))

(hunchentoot:define-easy-handler (show-text :uri "/show-text") (text-hash)
  (setf (hunchentoot:content-type*) "text/html")
  (multiple-value-bind (html number-of-words)
      (orihime::text-to-html text-hash)
    (if (string= (hunchentoot:header-in* :accept) "vnd+orihime.text")
        html
        (let ((context `((:|ANKI-Text| . ,html)
                         (:|orihime-colors| . ,orihime::*orihime-colors-style*)
                         (:|ANKI-field-number-start| . "")
                         (:|ANKI-field-number-end| . "")
                         (:|toggle-snippet| . ""))))
          (with-output-to-string (output)
            (orihime::mustache-render
             (merge-pathnames "html-template.html.mustache" orihime::*templates-directory*)
             context
             output))))))

(hunchentoot:define-easy-handler (add-text :uri "/add-text") ()
  (setf (hunchentoot:content-type*) "application/json")
  (multiple-value-bind (text-hash-hex text-hash)
      (orihime::sql-add-text
       (sb-ext:octets-to-string
        (hunchentoot:raw-post-data :request hunchentoot:*request*)))
    (cl-json:encode-json-alist-to-string `((:text-hash . ,text-hash-hex)))))
