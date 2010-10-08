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
(displayln (read-line (open-input-file (vector-ref (current-command-line-arguments) 0))))

