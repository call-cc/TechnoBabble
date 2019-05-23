(define-module (technobabble plugins slate)
  #:use-module (technobabble plugin)
  #:use-module (technobabble common)
  #:use-module (ix irc)
  #:use-module (ice-9 regex)
  #:use-module (srfi srfi-1))

(define *slate-file* "technobabble/plugins/slate.assoc")

(define (read-slate filename)
  (call-with-input-file filename
    (lambda (p)
      (read p))))

(define (parse-key text)
  (cadr (string-split* text " " 'prefix 1)))

(define (get-fact key)
  (let* ((slate (read-slate *slate-file*))
         (entry (assoc key slate string-ci=?)))
    (or entry
        (cons key "-404-"))))

(define (write-slate filename slate)
  (call-with-output-file filename
    (lambda (p)
      (flock p LOCK_EX)
      (write slate p)
      (flock p LOCK_UN))))

(define (set-fact key value)
  (let* ((slate (read-slate *slate-file*))
         (slate-aux (alist-delete key slate string-ci=?))
         (slate-final (acons key value slate-aux)))
    (write-slate *slate-file* slate-final)))

(define (delete-fact key)
  (let* ((slate (read-slate *slate-file*))
         (slate-final (alist-delete key slate string-ci=?)))
    (write-slate *slate-file* slate-final)))

(add-plugin "^!\\? .+"
            (lambda (irc from to text)
              (let* ((key (parse-key text))
                     (fact (get-fact key))
                     (answer (string-append (car fact) ": " (cdr fact)))
                     (target (if (is-target-channel? to)
                                 to
                                 from)))
                (irc-msg irc target answer))))

(add-plugin "^!- .+"
            (lambda (irc from to text)
              (let ((key (parse-key text))
                    (target (if (is-target-channel? to)
                                 to
                                 from)))
                (delete-fact key)
                (irc-msg irc target "Fact deleted."))))

(add-plugin "^!\\+ .+ .+"
            (lambda (irc from to text)
              (let* ((str (string-split* text " " 'prefix 2))
                     (key (cadr str))
                     (value (caddr str))
                     (target (if (is-target-channel? to)
                                 to
                                 from)))
                (set-fact key value)
                (irc-msg irc target "Fact added."))))
