#lang racket
(define atan-deg (compose radians->degrees atan))
(define (co-ord-add  org dst) (map + dst org))
(define (co-ord-diff org dst) (map - dst org))

(define (co-ord-mul co-ord fac)
  (match fac
    ;; assumes co-ord lists are of same size
    [(list facs ..2) (map * co-ord facs)]
    [(? number?) (map (λ (cv) (* cv fac)) co-ord)]
    [_ (error "co-ord-mul: fac must be co-ord or scalar value")]
    ))

(define (manhattan-distance org dst)
  (apply + (map abs (co-ord-diff org dst))))

(define (reduce-factors co-ord)
  (define cf (apply gcd co-ord))
  (map (λ (n) (/ n cf)) co-ord))

(define input-file "ip.txt")
(define input
    (call-with-input-file input-file port->lines))

;; assume we always have a square grid :)
(define-values (MAP-X MAP-Y)
  (values (string-length (first input)) (length input)))

(define asteroids
  (append-map
   (λ (str y)
     (for/list ([c str]
                [x MAP-X]
                #:when (eq? c #\#))
       (list y x)))
   input
   (range MAP-Y)))

  
(define (out-of-bounds? co-ord)
  (match co-ord
    [(list y x) (or (>= x MAP-X) (>= y MAP-Y)
                    (< x 0) (< y 0))]))
  

(define (generate-view asteroid move-by)
  (for/list ([n (in-naturals 1)]
             #:break (out-of-bounds?
                      (co-ord-add
                       asteroid
                       (co-ord-mul move-by n))))
    (co-ord-add
     asteroid
     (co-ord-mul move-by n))))

(define (asteroids-in-sight asteroid asteroids)
  (define other-asteroids
    (rest ;; ignore fst, it will always equal, asteroid under consideration.
     (sort asteroids <
           #:key (λ (other-asteroid) (manhattan-distance asteroid other-asteroid)))))

  (define in-sights
    (let loop ([others other-asteroids]
               [in-sights (list)])
      (match others
        [(list) in-sights]
        [(list in-sight others ...)
         (define blocked-cords
           (generate-view in-sight
                          (reduce-factors (co-ord-diff asteroid in-sight))))
         (loop (remove* blocked-cords others) (cons in-sight in-sights))]
        [_ 'never-gets-here-added-for-syntactic-beauty-jk]
        )))
  in-sights)


(define co-ords first)
(define observable-asteroids second)
(define monitor-station
  (foldl (λ (asteroid best-monitor-station)
          (define this-station (list asteroid (length (asteroids-in-sight asteroid asteroids))))
          (if (> (observable-asteroids this-station)
                 (observable-asteroids best-monitor-station))
              this-station
              best-monitor-station))
        (list (first asteroids) 0)
        asteroids))

(format "Part 1 = ~a" (observable-asteroids monitor-station))

(define (positive-angle angle)
  (if (negative? angle)
      (+ angle 360)
      angle))

(define asteroids-to-destroy
  (sort
   (map (λ (asteroid)
          (list asteroid
                (positive-angle
                 (+ 90 (apply atan-deg (co-ord-diff (co-ords monitor-station) asteroid))))))
        (asteroids-in-sight (co-ords monitor-station)
                            asteroids))
   <
   #:key second))


(match (list-ref asteroids-to-destroy 199)
    [(list (list y x) _deg)
     (format "Part 2 = ~a" (+ y (* x 100)))])