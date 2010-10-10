#lang racket
(require "robo.scm"
         rackunit)

(check-equal? (constrói-tabuleiro "10 10")
              (make-tabuleiro 10 10))

(check-equal? (constrói-robo "10 9 E")
              (make-robo 10 9 #\E))

;(display (imprime-tabuleiro (constrói-tabuleiro 5 5)
;                            (make-robo 4 4 #\N)))
;
;(display (imprime-tabuleiro (constrói-tabuleiro 10 10)
;                            (make-robo 9 9 #\E)))



(test-case
 "Robot movement"
 (check-equal? (muda-direção (make-robo 9 9 #\E)
                             #\L)
               (make-robo 9 9 #\N))
 (check-equal? (muda-direção (make-robo 1 9 #\S)
                             #\R)
               (make-robo 1 9 #\W))
 
 (check-equal? (muda-posição (make-robo 1 9 #\S)
                             6 3)
               (make-robo 6 3 #\S))
 
 (check-equal? (passo-a-frente (make-robo 1 9 #\S))
               (make-robo 1 8 #\S))
 (check-equal? (passo-a-frente (make-robo 1 2 #\N))
               (make-robo 1 3 #\N))
 (check-equal? (passo-a-frente (make-robo 1 2 #\E))
               (make-robo 2 2 #\E))
 (check-equal? (passo-a-frente (make-robo 3 6 #\W))
               (make-robo 2 6 #\W)))

(display (ler-movimentos-do-robo (open-input-file "./robo.txt")))