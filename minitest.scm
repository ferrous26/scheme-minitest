;; Some impure FP to get started

(define colour 31) ; internal
(define next-colour
  (lambda ()
    (begin
      (if (equal? colour 36)
	  (set! colour 31)
	  (set! colour (+ 1 colour)))
      colour)))

(define test-count 0)
(define fails '())

(define pass-token
  (lambda () (string-append "\e[" (number->string (next-colour)) "m*\e[0m")))
(define fail-token "\e[41m\e[37mF\e[0m")



;; ASSERTIONS

(define assert
  (lambda (name) (lambda (msg) (lambda (expr)
				 (begin
				   (set! test-count (+ 1 test-count))
				   (if (expr)
				       (display (pass-token))
				       (begin
					 (display fail-token)
					 (set! fails (append fails (list (cons test-count (cons name msg))))))))))))

(define refute (lambda (name) (lambda (msg) (lambda (expr)
  (((assert name) msg) (lambda () (not (expr))))))))


(define assert-equal
  (lambda (name) (lambda (expected) (lambda (actual)
    (((assert name)
      (list "Expected" actual "to be equal to" expected))
      (lambda () (equal? expected actual)))))))

(define refute-equal
  (lambda (name) (lambda (expected) (lambda (actual)
    (((assert name)
      (list "Expected" actual "to NOT be equal to" expected))
      (lambda () (not (equal? expected actual))))))))

(define assert-empty
  (lambda (name) (lambda (collection)
    (((assert name)
      (list "Expected" collection "to be empty"))
      (lambda ()
	(cond
	 ((string? collection) (= 0 (string-length collection)))
	 (else (null? collection))))))))

(define refute-empty
  (lambda (name) (lambda (collection)
    (((assert name)
       (list "Expected" collection "to NOT be empty"))
       (lambda ()
	 (not (cond
	       ((string? collection) (= 0 (string-length collection)))
	       (else (null? collection)))))))))


;; Default display mechanism

(define display-test-results
  (lambda ()
    (begin
      (newline)

      (if (= test-count 1)
	  (display `(,test-count test))
	  (display `(,test-count tests)))

      (if (= (length fails) 1)
	  (display `(,(length fails) failure))
	  (display `(,(length fails) failures)))

      (newline)
      (newline)

      (for-each
       (lambda (fail)
	 (begin
	   (newline)
	   (display (string-append (number->string (car fail)) ") "))
	   (display (cadr fail))
	   (newline)
	   (display (cddr fail))
	   (newline)))
       fails)

      (newline))))


(((assert "failed assertion")      "my first message")  (lambda () (= 0 1)))
(((assert "successful assertion")  "my second message") (lambda () (= 0 0)))
(((refute "successful refutation") "my third message")  (lambda () (= 0 1)))
(((refute "failed refutation")     "my fourth message") (lambda () (= 0 0)))

(((assert-equal "equal numbers")   42) 42)
(((assert-equal "unequal symbols") 'cake) 'pie)
(((refute-equal "equal symbols")   'cow) 'cow)
(((refute-equal "unequal numbers") 7) 13)

((assert-empty "empty list") '())
((assert-empty "empty string") "")
((assert-empty "non-empty list") '(a))
((assert-empty "non-empty string") "a")

((refute-empty "empty list")       '())
((refute-empty "empty string")     "")
((refute-empty "non-empty list")   '(b))
((refute-empty "non-empty string") "b")

(display-test-results)
