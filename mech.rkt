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

;; A new robot. I will use english names this time. 
;; Easier for someone outside of the luso world to understand the code.

;; Import the parser and lexer generators.
(require parser-tools/yacc
         parser-tools/lex
         (prefix-in : parser-tools/lex-sre))

(define-struct board (x y) #:transparent)
(define-struct mech (x y direction) #:transparent)

(define COMMAND-LOOKUP-TABLE
  `#hash((#\M . ,(λ (mech) (step-forward mech)))
         (#\R . ,(λ (mech) (turn mech #\R)))
         (#\L . ,(λ (mech) (turn mech #\L)))))

(define STEP-CONSEQUENCE
  `#hash((#\N . ,(list (λ (n) n) add1))
         (#\W . ,(list sub1 (λ (n) n)))
         (#\S . ,(list (λ (n) n) sub1))
         (#\E . ,(list add1 (λ (n) n)))))

(define TURN-CONSEQUENCE
  #hash((#\N . (#\W #\E))
        (#\W . (#\S #\N))
        (#\S . (#\E #\W))
        (#\E . (#\N #\S))))

;; get-consequences : hash char -> X
(define (get-consequences consequences key)
  (hash-ref consequences
            key))

;; turn : mech direction -> mech
(define (turn the-mech to-where)
  (let ([consequences (get-consequences TURN-CONSEQUENCE
                                        (mech-direction the-mech))])
    (struct-copy mech the-mech
                 (direction (if (equal? to-where #\L)
                                (first consequences)
                                (second consequences))))))

;; step-forward : mech -> mech
(define (step-forward the-mech)
  (let ([consequences (get-consequences STEP-CONSEQUENCE
                                        (mech-direction the-mech))])
    (struct-copy mech the-mech
                 (x ((first consequences) (mech-x the-mech)))
                 (y ((second consequences) (mech-y the-mech))))))

;; teleport : mech number number -> mech
(define (jump the-mech x y)
  (struct-copy mech the-mech
               (x x)
               (y y)))

(define-tokens value-tokens (NUMBER
                             DIRECTION
                             FUNCTION
                             COMMANDS))

(define-empty-tokens op-tokens (EOF NEWLINE))

(define-lex-abbrevs
  (teleport     #\T)
  (turn-left    #\L)
  (turn-right   #\R)
  (move-forward #\M)
  (directions (:or #\N
                   #\S
                   #\E
                   #\W))
  (digit        (:/ #\0 #\9)))

(define mech-lexer
  (lexer
   [(eof) 'EOF]
   [#\newline (token-NEWLINE)]
   ;; recursively call the lexer on the remaining input after a tab or space.    
   ;; Returning the result of that operation.  
   ;; This effectively skips all whitespace.
   [#\space (mech-lexer input-port)]
   [directions (token-DIRECTION (string-ref lexeme 0))]
   [(:+ (:or turn-right turn-left move-forward))
    (token-COMMANDS
     (map (λ (command)
            (get-consequences COMMAND-LOOKUP-TABLE command))
          (string->list lexeme)))]
   [teleport (token-FUNCTION (string-ref lexeme 0))]
   [(:+ digit) (token-NUMBER (string->number lexeme))]))

;; mech-parser : (X -> token) board mech -> mech
(define (mech-parser gen
                     (board #f)
                     (mech #f))
  ((parser
    (start start)
    (end EOF NEWLINE)
    (tokens value-tokens op-tokens)
    (error (lambda (tok-ok? tok-name tok-value)
             (error 'lexer
                    (format
                     (if (false? tok-ok?)
                         "the token ~a with value ~a was invalid."
                         "unknow error with token ~a with value ~a")
                     tok-name
                     tok-value))))
    
    (grammar
     (start [() mech] ;; end our parsing, return the mech structure
            [(exp) $1])
     
     (exp [(NUMBER NUMBER)
           (mech-parser gen
                        (make-board $1 $2)
                        mech)]
          
          [(NUMBER NUMBER DIRECTION)
           (mech-parser gen
                        board
                        (make-mech $1 $2 $3))]
          
          [(FUNCTION NUMBER NUMBER)
           (mech-parser gen
                        board
                        (jump mech $2 $3))]
          
          [(COMMANDS)
           (mech-parser gen
                        board
                        (foldl (λ (command old-mech)
                                 (command old-mech)) mech $1))])))
   gen))

(define (process-mech ip)
  (mech-parser (λ () (mech-lexer ip))))


(provide process-mech
         (struct-out mech)
         (struct-out board))