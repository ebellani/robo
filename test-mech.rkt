#lang racket
(require "mech.rkt"
         rackunit)

(check-equal? (process-mech (open-input-string "20 40\n2 0 S\nT 0 2\nMMLMLM"))
              (make-mech 1 1 #\N))

(check-equal? (process-mech (open-input-string "3 3\n1 1 N\nRMLMLMMLMM"))
              (make-mech 0 0 #\S))
