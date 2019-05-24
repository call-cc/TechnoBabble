(define-module (technobabble plugins naggum)
  #:use-module (technobabble plugin)
  #:use-module (technobabble common)
  #:use-module (ix irc))

(define *quote-file* "technobabble/plugins/naggum.txt")

(set! *random-state* (random-state-from-platform))

(define (get-quote)
  (let* ((content (slurp-file *quote-file*))
         (quotes (string-split content #\newline))
         (n (random (length quotes))))
    (list-ref quotes n)))

(add-plugin "^!naggum$"
            (lambda (irc from to text)
              (irc-msg irc to (get-quote))))
