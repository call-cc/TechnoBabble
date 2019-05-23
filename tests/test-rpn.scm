(add-to-load-path "../technobabble/plugins")

(define-module (tests test-rpn)
  #:use-module (srfi srfi-64))

(test-begin "ix-irc-plugins-rpn")

(define-syntax-rule (%import var)
  (define var
    (@@ (technobabble plugins rpn) var)))

(%import *rpn-stack*)

(define (get-stack)
  (@@ (technobabble plugins rpn) *rpn-stack*))

(define (set-stack items)
  (set! (@@ (technobabble plugins rpn) *rpn-stack*)
        items))

(test-begin "Test get-rpn-exp")

(%import get-rpn-exp)

(test-equal "Test with '!calc 0'"
  '("0")
  (get-rpn-exp "!calc 0"))

(test-equal "Test with '!calc -1 -1'"
  '("-1" "-1")
  (get-rpn-exp "!calc -1 -1"))

(test-equal "Test with '!calc 0 20 *"
  '("0" "20" "*")
  (get-rpn-exp "!calc 0 20 *"))

(test-equal "Test with '!calc 10 20 -5 * *'"
  '("10" "20" "-5" "*" "*")
  (get-rpn-exp "!calc 10 20 -5 * *"))

(test-equal "Test with superfluous spaces"
  '("10" "20" "-5" "*" "*")
  (get-rpn-exp "!calc   10  20     -5     *   *    "))

(test-end)

(test-begin "Test get-func")

(%import get-func)

(test-equal "Test with '+' op" + (get-func "+"))

(test-equal "Test with '-' op" - (get-func "-"))

(test-equal "Test with '*' op" * (get-func "*"))

(test-equal "Test with '/' op" / (get-func "/"))

(test-begin "Test with non-ops")

(for-each (lambda (str)
            (test-equal #f (get-func str)))
          '("!" "#" "0" "99999" "a" "foo" " " "    " ";"))

(test-end)

(test-end)

(test-begin "Test rpn-push")

(%import rpn-push)

(set-stack '())

(rpn-push 42)

(test-equal
    "Test pusing to an empty stack"
  '(42)
  (get-stack))

(set-stack '(42))

(rpn-push 33)

(test-equal
    "Test pushing to a non empty stack"
  '(33 42)
  (get-stack))

(test-end)

(test-begin "Test rpn-pop")

(%import rpn-pop)

(test-begin "Test popping from an empty stack")

(set-stack '())

(test-equal #f (rpn-pop))

(test-equal '() (get-stack))

(test-end)

(test-begin "Test popping from a stack of 1 item")

(set-stack '(11))

(test-equal 11 (rpn-pop))

(test-equal '() (get-stack))

(test-end)

(test-begin "Test popping from a stack of 2 items")

(set-stack '(99 33))

(test-equal 99 (rpn-pop))

(test-equal '(33) (get-stack))

(test-end)

(test-begin "Test popping from a stack of several items")

(set-stack '(923016 44 14 376112 99 0 6 25 1 20000 8))

(test-equal 923016 (rpn-pop))

(test-equal '(44 14 376112 99 0 6 25 1 20000 8) (get-stack))

(test-end)

(test-begin "Test double pop")

(set-stack '(0 101 5 42 99999 1234))

(test-equal 0 (rpn-pop))

(test-equal 101 (rpn-pop))

(test-equal '(5 42 99999 1234) (get-stack))

(test-end)

(test-end)

(test-begin "Test eval-exp-safely")

(%import eval-exp-safely)

(test-equal "Test division by 0" #f (eval-exp-safely / 0 0))

(test-equal "Test with '0 / 1" 0 (eval-exp-safely / 0 1))

(test-end)

(test-begin "Test rpn-eval")

(%import rpn-eval)

(test-begin "Test with expression '+'")

(set-stack '())

(test-equal #f (rpn-eval +))

(test-end)

(test-begin "Test with expression '3 *'")

(set-stack '(3))

(test-equal #f (rpn-eval *))

(test-end)

(test-begin "Test with expression '100 10 /'")

(set-stack '(10 100))

(rpn-eval /)

(test-equal '(10) (get-stack))

(test-end)

(test-end)

(test-begin "Test eval-rpn")

(%import eval-rpn)

(test-begin "Test with empty expression")

(set-stack '())

(test-equal #f (eval-rpn '()))

(test-end)

(test-begin "Test with (-)")

(set-stack '())

(test-equal #f (eval-rpn '("-")))

(test-end)

(test-begin "Test with (1 /)")

(set-stack '())

(test-equal #f (eval-rpn '("1" "/")))

(test-end)

(test-begin "Test with (5 10 -)")

(set-stack '())

(test-equal -5 (eval-rpn '("5" "10" "-")))

(test-end)

(test-begin "Test with (5 10 - +)")

(set-stack '())

(test-equal #f (eval-rpn '("5" "10" "-" "+")))

(test-end)

(test-begin "Test with (25 50 - 25 +)")

(set-stack '())

(test-equal 0 (eval-rpn '("25" "50" "-" "25" "+")))

(test-end)

(test-begin "Test with (5 10 20 + -)")

(set-stack '())

(test-equal -25 (eval-rpn '("5" "10" "20" "+" "-")))

(test-end)

(test-end)

(test-end)
