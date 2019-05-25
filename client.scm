(use-modules (oop goops)
             (ix irc)
             (technobabble plugin)
             (8sync))

(define *config-file* "irc-config.scm")

(define *config* '())

(define (load-config! filename)
  (call-with-input-file filename
    (lambda (p)
      (set! *config* (read p)))))

(define (get-cfg key)
  (let ((item (assoc key *config*)))
    (if (pair? item)
        (cdr item)
        'none)))

(load-config! *config-file*)

(define-class <ii> (<irc>))

(define-method (event:privmsg (irc <irc>) message params)
  (let ((to (caadr params))
        (from (get-nick (car params)))
        (text (cadadr params)))
    (dispatch irc from to text)))

(define* (run-irc #:key (username (get-cfg 'nick))
                  (nick (get-cfg 'nick))
                  (server (get-cfg 'server))
                  (channels (get-cfg 'channels))
                  (realname (get-cfg 'realname))
                  (ident (get-cfg 'ident))
                  (nick-password (get-cfg 'nick-password)))
  (define hive (make-hive))
  (define irc-client
    (bootstrap-actor* hive <ii> "irc-client"
                      #:username username
                      #:nick nick
                      #:server server
                      #:channels channels
                      #:realname realname
                      #:ident ident
                      #:nick-password nick-password))
  (load-plugins)
  (run-hive hive '()))
