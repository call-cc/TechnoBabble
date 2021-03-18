(define-module (technobabble plugin)
  #:use-module (ice-9 regex)
  #:use-module (ice-9 ftw)
  #:use-module (srfi srfi-1)
  #:export (clear-plugins
            load-plugins
            add-plugin
            dispatch
            get-plugins))

(define *plugins* '())

(define (clear-plugins)
  (set! *plugins* '()))

(define (load-plugins)
  (let* ((dir "technobabble/plugins/")
         (files (scandir dir
                         (lambda (f) (string-suffix? ".scm" f)))))
    (for-each (lambda (f)
                (load (string-append "../" dir f)))
              files)))

(define (add-plugin cmd func)
  (let ((name (caddr (module-name (current-module)))))
    (set! *plugins* (append *plugins* (list (list name cmd func))))))

(define (dispatch irc from to text)
  (for-each (lambda (p)
              (if (string-match (cadr p)
                                text)
                  ((caddr p) irc from to text)))
            *plugins*))

(define (get-plugins)
  (string-join
   (map symbol->string
        (delete-duplicates
         (delete 'guile-user
                 (map (lambda (p)
                        (car p))
                      *plugins*))))))
