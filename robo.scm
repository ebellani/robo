#lang racket
#|
Suponha que você precisa implementar um robo controlado pelos seguintes
comandos:

L - Virar 90 graus para a esquerda
R - Virar 90 graus para a direita
M - Mover um ponto para frente
T - Se tele transportar para um determinado ponto

O robo anda em um plano cartesiano, em um espaço de tamanho especifico. Ele
não pode se mover ou tele transportar para fora desse espaço. O input do
problema vem de um arquivo no seguinte formato (sem os comentários):

10 10                # o tamanho do espaço que o robo pode usar
2 5 N                # sua localização atual e para qual direção ele está virado
LLRRMMMRLRMMM        # um conjunto de inputs
T 1 3                # para se tele transportar para um ponto especifico dentro do espaço definido 
LLRRMMRMMRM          # um outro conjunto de entradas

O resultado final deve ser dado pelo robo para indicar sua posição e para
onde ele está apontando, por exemplo:

2 4 E                              # na posição 2 4, virado para East

Assuma que, o quadrado, imediatamente ao norte de (x, y) é (x, y + 1)
|#

;; tabuleiro é uma estrutura contendo um par de inteiros
(define-struct tabuleiro (x y) #:transparent)

;; robo é uma estrutura contendo um par de inteiros e uma direção
(define-struct robo (x y direção) #:transparent)

;; constrói-tabuleiro : number number -> tabuleiro
(define (constrói-tabuleiro x y)
  (make-tabuleiro x y))

;; constrói-tabuleiro : number number symbol -> tabuleiro
(define (constrói-robo x y direção)
  (make-robo x y direção))

(define DIREÇÕES-POSSIVEIS
  (list '(N (W E))
        '(W (S N))
        '(S (E W))
        '(E (N S))))

(define RESULTADO-DO-PASSO-A-FRENTE
  (list (list 'N (list #f add1))
        (list 'W (list sub1 #f))
        (list 'S (list #f sub1))
        (list 'E (list add1 #f))))

;; muda-direção : robo symbol -> robo
(define (muda-direção o-robo virar-para)
  (let ([possíveis-direções
         (second (findf (λ (uma-possibilidade)
                          (equal? (first uma-possibilidade)
                                  (robo-direção o-robo)))
                        DIREÇÕES-POSSIVEIS))])
    (struct-copy robo
                 o-robo
                 (direção (if (equal? virar-para 'L)
                              (first possíveis-direções)
                              (second possíveis-direções))))))


;; muda-posição : robo number number -> robo
(define (muda-posição o-robo x y)
  (struct-copy robo
               o-robo
               (x x)
               (y y)))

;; passo-a-frente : robo -> robo
(define (passo-a-frente o-robo)
  (local [(define (quantidade-do-movimento função numero)
            (if (not (false? função))
                (função numero)
                numero))]
    (let ([possíveis-funções
           (second (findf (λ (um-resultado-de-uma-posição)
                            (equal? (first um-resultado-de-uma-posição)
                                    (robo-direção o-robo)))
                          RESULTADO-DO-PASSO-A-FRENTE))])
      (muda-posição o-robo
                    (quantidade-do-movimento (first possíveis-funções)
                                             (robo-x o-robo))
                    (quantidade-do-movimento (second possíveis-funções)
                                             (robo-y o-robo))))))

;; imprime-tabuleiro : tabuleiro robo -> string
;; imprime uma versão textual do tabuleiro, com o robo
;; sendo representado por uma seta. 
(define (imprime-tabuleiro o-tabuleiro o-robo)
  (let ([uma-linha (apply string-append
                          (for/list ([i (in-range (tabuleiro-x o-tabuleiro))])
                            "__"))])
    (apply string-append
           (for/list ([numero-coluna (in-range (tabuleiro-x o-tabuleiro))])
             (format
              "~a,~n~a|~n"
              uma-linha
              (apply string-append
                     (for/list ([numero-linha (in-range (tabuleiro-y o-tabuleiro))])
                       (if (and (= (robo-x o-robo) numero-coluna)
                                (= (robo-y o-robo) numero-linha))
                           (format "|~a" (robo-direção o-robo))
                           "| "))))))))


(provide constrói-tabuleiro
         constrói-robo
         imprime-tabuleiro
         muda-direção
         muda-posição
         passo-a-frente
         (struct-out tabuleiro)
         (struct-out robo))

;(displayln (read-line (open-input-file (vector-ref (current-command-line-arguments) 0))))

