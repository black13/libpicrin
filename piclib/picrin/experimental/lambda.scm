(define-library (picrin experimental lambda)
  (import (scheme base)
          (picrin macro))

  (define-syntax bind
    (ir-macro-transformer
     (lambda (form inject compare)
       (let ((formal (car (cdr form)))
             (value  (car (cdr (cdr form))))
             (body   (cdr (cdr (cdr form)))))
         (cond
          ((symbol? formal)
           `(let ((,formal ,value))
              ,@body))
          ((pair? formal)
           `(let ((value# ,value))
              (bind ,(car formal) (car value#)
                (bind ,(cdr formal) (cdr value#)
                  ,@body))))
          ((vector? formal)
           ;; TODO
           (error "fixme"))
          (else
           `(if (equal? ,value ',formal)
                (begin
                  ,@body)
                (error "match failure" ,value ',formal))))))))

  (define-syntax destructuring-lambda
    (ir-macro-transformer
     (lambda (form inject compare)
       (let ((args (car (cdr form)))
             (body (cdr (cdr form))))
         `(lambda formal# (bind ,args formal# ,@body))))))

  (define-syntax destructuring-define
    (ir-macro-transformer
     (lambda (form inject compare)
       (let ((maybe-formal (cadr form)))
         (if (symbol? maybe-formal)
             `(define ,@(cdr form))
             `(destructuring-define ,(car maybe-formal)
                (destructuring-lambda ,(cdr maybe-formal)
                  ,@(cddr form))))))))

  (export (rename destructuring-lambda lambda)
          (rename destructuring-define define)))
