(define-module (technobabble plugins uptime)
  #:use-module (technobabble plugin)
  #:use-module (ix irc)
  #:use-module (ice-9 popen)
  #:use-module (ice-9 rdelim))

(define (uptime)
  (let* ((port (open-input-pipe "uptime"))
         (str (read-line port)))
    (close-pipe port)
    str))

(add-plugin "^!uptime$"
            (lambda (irc from to text)
              (irc-msg irc to (uptime))))
