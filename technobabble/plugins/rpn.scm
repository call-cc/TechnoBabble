(define-module (technobabble plugins rpn)
  #:use-module (technobabble plugin)
  #:use-module (ix irc)
  #:use-module (ice-9 regex)
  #:use-module (ice-9 format))

(define *rpn-stack* '())

(define (get-rpn-exp text)
  (cdr (delete ""
               (string-split text #\space))))

(define (get-func op)
  (cond
   ((string=? op "+") +)
   ((string=? op "-") -)
   ((string=? op "*") *)
   ((string=? op "/") /)
   (else #f)))

(define (rpn-push number)
  (set! *rpn-stack* (cons number
                          *rpn-stack*)))

(define (rpn-pop)
  (if (> (length *rpn-stack*) 0)
      (let ((number (car *rpn-stack*)))
        (set! *rpn-stack* (cdr *rpn-stack*))
        number)
      #f))

(define (eval-exp-safely func arg1 arg2)
  (catch 'numerical-overflow
    (lambda ()
      (func arg1 arg2))
    (lambda (key . args)
      #f)))

(define (rpn-eval op)
  (let ((arg1 (rpn-pop))
        (arg2 (rpn-pop)))
    (if (and op
             arg1
             arg2)
        (rpn-push (eval-exp-safely op arg2 arg1))
        #f)))

;; 0 0 /
;; 1 2 0 0 0 +  /
;; 0 0 1 2 + 3 - /
(define (eval-rpn exp)
  (if (pair? exp)
      (begin
        (if (get-func (car exp))
            (rpn-eval (get-func (car exp)))
            (rpn-push (string->number (car exp))))
        (eval-rpn (cdr exp)))
      (rpn-pop)))

(define (rpn-calc irc from to text)
  (set! *rpn-stack* '())
  (let* ((exp (get-rpn-exp text))
         (result (eval-rpn exp))
         (text (format #f "~a" result)))
    (irc-msg irc to text)))

(add-plugin "!calc .+" rpn-calc)
