(define-module (technobabble plugin)
  #:use-module (ice-9 regex)
  #:export (clear-plugins
            add-plugin
            dispatch
            get-plugins))

(define *plugins* '())

(define (clear-plugins)
  (set! *plugins* '()))

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
  (delete 'guile-user
          (map (lambda (p)
                 (car p))
               *plugins*)))
