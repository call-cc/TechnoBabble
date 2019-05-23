(define-module (technobabble plugins list-plugins)
  #:use-module (technobabble plugin)
  #:use-module (ix irc))

(add-plugin "^!plugins$"
            (lambda (irc from to text)
              (irc-msg irc to (get-plugins))))
