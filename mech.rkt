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
  (list (list #\M (λ (mech) (printf "move mech ~a forward~n" mech)))
        (list #\R (λ (mech) (printf "move mech ~a to the right~n" mech)))
        (list #\L (λ (mech) (printf "move mech ~a to the left~n" mech)))))

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
   [directions (token-DIRECTION (string->symbol lexeme))]
   [(:+ (:or turn-right turn-left move-forward))
    (token-COMMANDS
     (map (λ (command)
            (second (findf (λ (table-item)
                             (equal? command
                                     (first table-item)))
                           COMMAND-LOOKUP-TABLE)))
          (string->list lexeme)))]
   [teleport (token-FUNCTION (string->symbol lexeme))]
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
           (printf "teleport to ~a ~a ~n" $2 $3)]
          
          [(COMMANDS)
           (mech-parser gen
                        board
                        (foldl (λ (command old-mech)
                                 (command old-mech)
                                 old-mech)
                               mech $1))])))
   gen))

(define (process-mech ip)
  (mech-parser (λ () (mech-lexer ip))))


(process-mech (open-input-string "10 9\n 0 0 N\n RL\n LLLMMRRL"))
;(process-mech (open-input-string "10 10\n 0 0 N\n T 1 4\n LRMMM\n T 3 3"))

