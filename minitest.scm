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
  (lambda (expr name msg)
    (begin
      (set! test-count (+ 1 test-count))
      (if (expr)
	  (display (pass-token))
	  (begin
	    (display fail-token)
	    (set! fails (append fails (list (cons test-count (cons name msg))))))))))

(define refute (lambda (expr name msg) (assert (not (expr)) name msg)))


(define assert-equal
  (lambda (expected actual name)
    (assert (lambda () (equal? expected actual))
	    name
	    (list "Expected" actual "to be equal to" expected))))

(define refute-equal
  (lambda (expected actual name)
    (assert (lambda () (not (equal? expected actual)))
	    name
	    (list "Expected" actual "to NOT be equal to" expected))))


(define assert-empty
  (lambda (collection name)
    (lambda ()
      (cond
       ((string? collection) (= 0 (string-length collection)))
       (else (null? collection))))
    name
    (list "Expected" collection "to be empty")))

(define refute-empty
  (lambda (collection name)
    (lambda ()
      (not (cond
	    ((string? collection) (= 0 (string-length collection)))
	    (else (null? collection)))))
    name
    (list "Expected" collection "to NOT be empty")))


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
