; map then append
(define (mappend f . lss)
  (apply append (apply map (cons f lss))))

; test if a list is unique
(define (unique ls)
  (fold-right
    (lambda (x ls) (if (member x ls) ls (cons x ls)))
    '()
    ls))

; get the first index of an item in a vector, error if not found
(define (index-of x v)
  (let loop ([i 0])
    (cond
     [(= i (vector-length v))
      (error "index-of" "~s not found in ~s" x v)]
     [(eq? x (vector-ref v i))
      i]
     [else
      (loop (add1 i))])))

; get unique letters in any number of words
; if less than ten, pad with #\_
; if more than ten, error
(define (get-letters words)
  (let ([ls (unique (mappend string->list words))])
    (if (> (length ls) 10)
        (error "get-letters" "no solution, too many letters")
        (list->vector
          (append (map (lambda (_) #\_) (iota (- 10 (length ls)))) ls)))))

; get the value of a word using a given key
; return #f for words that start with 0
(define (score-word key word)
  (and (not (zero? (index-of (string-ref word 0) key)))
       (car
         (fold-right
           (lambda (c n/i)
             (cons (+ (car n/i) (* (index-of c key) (cdr n/i)))
                   (* (cdr n/i) 10)))
           (cons 0 1)
           (string->list word)))))

; score a solution by summing all words except subtracting the last
; return #f for invalid scores
(define (score-words key words)
  (let ([scores (map (lambda (word) (score-word key word)) words)])
    (and (andmap number? scores)
         (abs
           (let loop ([ls scores])
             (if (null? (cdr ls))
                 (- (car ls))
                 (+ (car ls) (loop (cdr ls)))))))))

; scramble a solution by swapping two elements (might be the same one)
(define (swap-two v)
  (let* ([n (vector-copy v)]
         [i (random (vector-length v))]
         [j (random (vector-length v))])
    (vector-set! n i (vector-ref v j))
    (vector-set! n j (vector-ref v i))
    n))

; print out a solution nicely
(define (display-solution key words)
  (newline)
  (printf "~a " (car words))
  (let loop ([words (cdr words)])
    (if (null? (cdr words))
        (printf " = ~a" (car words))
        (begin
          (printf " + ~a" (car words))
          (loop (cdr words)))))
  (newline)
  (printf "~a " (score-word key (car words)))
  (let loop ([words (cdr words)])
    (if (null? (cdr words))
        (printf " = ~a" (score-word key (car words)))
        (begin
          (printf " + ~a" (score-word key (car words)))
          (loop (cdr words)))))
  (newline))

; solve a puzzle using a hill-climbing algorithm with some random jitter
(define (solve . words)
  (let loop ([soln (get-letters words)]
             [best (score-words (get-letters words) words)])
    (let* ([new-soln (swap-two soln)]
           [new-best (score-words new-soln words)])
      (cond
        [(and new-best (= 0 new-best))
         (display-solution new-soln words)]
        [(or (not best)
             (and new-best (< new-best best))
             (zero? (random 100)))
         (loop new-soln new-best)]
        [else
         (loop soln best)]))))