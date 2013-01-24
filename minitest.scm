(define colour 31)
(define next-colour (lambda ()
		      (begin
			(if (equal? colour 36)
			    (set! colour 31)
			    (set! colour (+ 1 colour)))
			colour)))

(define test-count 0)
(define fails '())

(define pass-token (lambda () (string-append "\e[" (number->string (next-colour)) "m*\e[0m")))
(define fail-token "\e[41m\e[37mF\e[0m")

(define assert-equal (lambda (expected actual name)
		       (begin
			 (set! test-count (+ 1 test-count))
			 (if (equal? expected actual)
			     (display (pass-token))
			     (begin
			       (display fail-token)
			       (set! fails (append fails (list (cons test-count (cons name actual))))))))))

(define display-test-results (lambda ()
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
				      (display (string-append (cadr fail) "\n"))
				      (display (cddr fail))
				      (newline)))
				    fails))))
