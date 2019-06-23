(define-module (technobabble plugins reload)
  #:use-module (technobabble plugin)
  #:use-module (ix irc)
  #:use-module (ice-9 ftw))

(define (load-plugins)
  (clear-plugins)
  (let ((files (scandir "technobabble/plugins/"
                        (lambda (f) (string-suffix? ".scm" f)))))
    (for-each (lambda (f)
                (load f))
              files)))

(add-plugin "^!reload$"
            (lambda (irc from to text)
              (load-plugins)
              (irc-msg irc to "Plugins reloaded")))
