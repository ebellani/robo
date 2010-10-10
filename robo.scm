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

(require srfi/13)

;; tabuleiro é uma estrutura contendo um par de inteiros
(define-struct tabuleiro (x y) #:transparent)

;; robo é uma estrutura contendo um par de inteiros e uma direção
(define-struct robo (x y direção) #:transparent)

;; constrói-tabuleiro : string -> tabuleiro
(define (constrói-tabuleiro dados)
  (let ([dados-do-tabuleiro (string-tokenize dados)])
    (make-tabuleiro (string->number (first dados-do-tabuleiro))
                    (string->number (second dados-do-tabuleiro)))))

;; constrói-tabuleiro : string -> tabuleiro
(define (constrói-robo dados)
  (let ([dados-do-robo (string-tokenize dados)])
    (make-robo (string->number (first dados-do-robo))
               (string->number (second dados-do-robo))
               (string-ref (third dados-do-robo) 0))))


(define DIREÇÕES-POSSIVEIS
  (list '(#\N (#\W #\E))
        '(#\W (#\S #\N))
        '(#\S (#\E #\W))
        '(#\E (#\N #\S))))

(define RESULTADO-DO-PASSO-A-FRENTE
  (list (list #\N (list (λ (n) n) add1))
        (list #\W (list sub1 (λ (n) n)))
        (list #\S (list (λ (n) n) sub1))
        (list #\E (list add1 (λ (n) n)))))

;; muda-direção : robo char -> robo
(define (muda-direção o-robo virar-para)
  (let ([possíveis-direções
         (second (findf (λ (uma-possibilidade)
                          (equal? (first uma-possibilidade)
                                  (robo-direção o-robo)))
                        DIREÇÕES-POSSIVEIS))])
    (struct-copy robo
                 o-robo
                 (direção (if (equal? virar-para #\L)
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
  (let ([possíveis-funções
         (second (findf (λ (um-resultado-de-uma-posição)
                          (equal? (first um-resultado-de-uma-posição)
                                  (robo-direção o-robo)))
                        RESULTADO-DO-PASSO-A-FRENTE))])
    (muda-posição o-robo
                  ((first possíveis-funções) (robo-x o-robo))
                  ((second possíveis-funções) (robo-y o-robo)))))

;; imprime-tabuleiro : tabuleiro robo -> string
;; imprime uma versão textual do tabuleiro, com o robo
;; sendo representado pela letra indicando sua direção. 
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
                     (for/list ([numero-linha
                                 (in-range (tabuleiro-y o-tabuleiro))])
                       (if (and (= (robo-x o-robo) numero-coluna)
                                (= (robo-y o-robo) numero-linha))
                           (format "|~a" (robo-direção o-robo))
                           "| "))))))))

;; ler-movimentos-do-robo : input-port robo tabuleiro -> robo
;; le e modifica a posição do robo a partir de uma lista de movimentos
(define (ler-movimentos-do-robo arquivo
                                (o-robo #f)
                                (o-tabuleiro #f))
  (let* ([linha-de-comandos (read-line arquivo 'any)])
    (if (eof-object? linha-de-comandos)
        o-robo
        (let ([elementos-da-linha (string-tokenize linha-de-comandos)])
          (case (length elementos-da-linha)
            [(3)
             (if (equal? (first elementos-da-linha) "T")
                 (ler-movimentos-do-robo arquivo
                                         (muda-posição
                                          o-robo
                                          (string->number (second
                                                           elementos-da-linha))
                                          (string->number (third
                                                           elementos-da-linha)))
                                         o-tabuleiro)
                 (ler-movimentos-do-robo arquivo
                                         (constrói-robo linha-de-comandos)
                                         o-tabuleiro))]
            [(2) (ler-movimentos-do-robo arquivo
                                         o-robo
                                         (constrói-tabuleiro linha-de-comandos))]
            [else
             (ler-movimentos-do-robo arquivo
                                     ; cria um novo robo pra cada comando da linha
                                     (string-fold
                                      (lambda (comando velho-robo)
                                        (if (equal? comando #\M)
                                            (passo-a-frente velho-robo)
                                            (muda-direção velho-robo comando)))
                                      o-robo
                                      linha-de-comandos)
                                     o-tabuleiro)])))))
(provide constrói-tabuleiro
         constrói-robo
         imprime-tabuleiro
         muda-direção
         muda-posição
         passo-a-frente
         ler-movimentos-do-robo
         (struct-out tabuleiro)
         (struct-out robo))