(define-module (technobabble plugins bofh)
  #:use-module (technobabble plugin)
  #:use-module (technobabble common)
  #:use-module (ix irc))

(define *bofh-file* "plugins/bofh-excuses.txt")

(set! *random-state* (random-state-from-platform))

(define (get-quote)
  (let* ((content (slurp-file *bofh-file*))
         (quotes (string-split content #\newline))
         (n (random (length quotes))))
    (list-ref quotes n)))

(add-plugin "^!bofh$"
            (lambda (irc from to text)
              (irc-msg irc to (string-append "BOFH excuse: " (get-quote)))))
