(define-module (technobabble plugins version)
  #:use-module (technobabble plugin)
  #:use-module (ix irc))

(add-plugin "^!version$"
            (lambda (irc from to text)
              (irc-msg irc to (string-append "Running on Guile Scheme " (version)))))
