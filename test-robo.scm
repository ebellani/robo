#lang racket
(require "robo.scm"
         rackunit)

(check-equal? (constrói-tabuleiro 5 5)
              (make-tabuleiro 5 5))


(check-equal? (constrói-robo 5 5 'N)
              (make-robo 5 5 'N))

;(display (imprime-tabuleiro (constrói-tabuleiro 5 5)
;                            (constrói-robo 4 4 'N)))
;
;(display (imprime-tabuleiro (constrói-tabuleiro 10 10)
;                            (constrói-robo 9 9 'E)))



(test-case
 "Robot movement"
 (check-equal? (muda-direção (constrói-robo 9 9 'E)
                             'L)
               (constrói-robo 9 9 'N))
 (check-equal? (muda-direção (constrói-robo 1 9 'S)
                             'R)
               (constrói-robo 1 9 'W))
 
 (check-equal? (muda-posição (constrói-robo 1 9 'S)
                             6 3)
               (constrói-robo 6 3 'S))
 
 (check-equal? (passo-a-frente (constrói-robo 1 9 'S))
               (constrói-robo 1 8 'S))
 (check-equal? (passo-a-frente (constrói-robo 1 2 'N))
               (constrói-robo 1 3 'N))
 (check-equal? (passo-a-frente (constrói-robo 1 2 'E))
               (constrói-robo 2 2 'E))
 (check-equal? (passo-a-frente (constrói-robo 3 6 'W))
               (constrói-robo 2 6 'W)))