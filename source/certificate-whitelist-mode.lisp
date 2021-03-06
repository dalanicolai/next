(uiop:define-package :next/certificate-whitelist-mode
  (:use :common-lisp :trivia :next)
  (:documentation "Certificate whitelist mode"))
(in-package :next/certificate-whitelist-mode)
(eval-when (:compile-toplevel :load-toplevel :execute)
  (trivial-package-local-nicknames:add-package-local-nickname :alex :alexandria)
  (trivial-package-local-nicknames:add-package-local-nickname :sera :serapeum))

(sera:export-always '*default-certificate-whitelist*)
(defparameter *default-certificate-whitelist* '())

(define-mode certificate-whitelist-mode ()
  "Enable ignoring of certificate errors.
This can apply to specific buffers."
  ((certificate-whitelist :initarg :certificate-whitelist
                          :accessor certificate-whitelist
                          :type list-of-strings
                          :initform *default-certificate-whitelist*)
   (destructor
    :initform
    (lambda (mode)
      (setf (certificate-whitelist (buffer mode)) nil)))
   (constructor
    :initform
    (lambda (mode)
      (setf (certificate-whitelist (buffer mode)) (certificate-whitelist mode))
      (echo "Certificate host whitelist set to ~a."
            (certificate-whitelist mode))))))

(define-command add-domain-to-certificate-whitelist (&optional (buffer (current-buffer)))
  "Add the current domain to the buffer's certificate whitelist."
  (if (find-submode buffer 'certificate-whitelist-mode)
      (if (url buffer)
          (let ((domain (quri:uri-host (quri:uri (url buffer)))))
            (log:info domain)
            (pushnew domain (certificate-whitelist buffer) :test #'string=))
          (echo "Buffer has no URL."))
      (echo "Enable certificate-whitelist-mode first.")))

;; TODO: Implement command remove-domain-from-certificate-whitelist.
;;       Currently it is not possible due to WebKit limitations.
