
.data
A:.float 8.3, 4.5, 0.0,
.float  -1.2, 0.0, 40000.57

 B: .word 0, 0, 0
     .word 0, 0, 0
 N: .word 2
 M: .word 3
 X: .word 10

.text
  .globl main
  main:

  addu $sp $sp -4
  sw $ra ($sp)
  la $a0, A
  la $a1, B
  lw $a2, N
  lw $a3, M
  addu $sp $sp -4
  lw $t0, X
  sw $t0 ($sp)

  jal ExtractExponents

  li $t4, 0 #i
  li $t5, 0 #j
move $t2,  $a2
move $t3, $a3
move $t6, $a1

 #recorrer matriz B para imprimir
  bucle_iB:
    bge $t4, $t2 fin_1B #si i es mayor o igual que N se va a fin_1B
        bucle_jB:
        bge $t5, $t3 fin_2B #si j es mayor o igual que M se va a fin_2B

        # (i * M + j)x4
        mul $t1 $t4 $t3
        add $t1 $t1 $t5
        mul $t1 $t1 4 # t1 es [i][j]

        # * matriz + (i * M+j) * 4

        add $t7 $t6 $t1 #dir de A [i][j]

        lw $a0 ($t7) #carga en a0 el valor de la dir $t7

        li $v0 1 #imprime la matriz
        syscall
        li $a0 ','  # va poniendo comas detras de los numeros
        li $v0 11
        syscall
        li $a0 ' ' #va dejando espacios entre los numeros
        li $v0 11
        syscall

addi $t5 $t5 1 #j++
        b bucle_jB #vuelve a bucle_jB
    fin_2B:
    addi $t4 $t4 1 #i++
    li $t5, 0 #reiniciar j
    li $a0, '\n' #salto de linea para que tenga forma de matriz
    li $v0 ,11
    syscall
        b bucle_iB #vuelve al bucle_iB
fin_1B:
  li $v0 10 #sale del programa
  syscall

  lw $ra 8($sp)
   addu $sp $sp 8

  jr $ra

    ExtractExponents:
    addu $sp $sp -40
    sw $s0 ($sp)
    sw $s1 4($sp)
    sw $s2 8($sp)
    sw $s3 16($sp)
    sw $s4 20($sp)
    sw $s5 24($sp)
    sw $s6 32($sp)
    sw $s7 36($sp)
    sw $ra 28($sp)

      move $s0 $a0
      move $s1 $a1
      move $s2 $a2
      move $s3 $a3

      li $s4, 0 #i
      li $s5, 0 #j
      li $t5, -126
      li $t6, 99999
      li $s7, -127

    bucle_i:
      bge $s4, $s2 fin_1 #si i es mayor o igual que N se va a fin_1
          bucle_j:
          bge $s5, $s3 fin_2 #si j es mayor o igual que N se va a fin_2

            # (i * M + j)x4
            mul $t1 $s4 $s3
            add $t1 $t1 $s5
            mul $t1 $t1 4 # t1 es [i][j]

            # * matriz + (i * M+j) * 4
            la $t2 ($s0) #obtener dir de la matriz A
            add $t2 $t2 $t1 #dir de A [i][j]

            l.s $f4   ($t2) #coger el valor de esa dir

            mov.s $f12, $f4 #para pasar el parametro a la funcion
               jal sacar_exponente
               move $s6, $v0 #exponente

                bne $s6 $s7 fin_3 # si exponente es distinto de 0 fin, si es igual pone -126

                  la $t4 ($s1) #obtener dir de la matriz B
                  add $t4 $t4 $t1 #sumar a la direccion de la matriz B el valor de [i][j] y obtenemos dir de B [i][j]
                 sw $t5 ($t4) # poner en B[i][j] -126


                 fin_3:
                  bgeu $s6 $t0 fin_4 #si exponente es mayor o igual que X, va a fin_4
                  la $t4 ($s1) #obtener dir de la matriz B
                  add $t4 $t4 $t1 #sumar a la direccion de la matriz B el valor de [i][j] y obtenemos dir de B [i][j]
                  sw $s6 ($t4) # poner en B[i][j] exponente


                  fin_4:
                  blt $s6 $t0 follow #si exponente es menor que X va a follow
                    la $t7 ($s1) #obtener dir de la matriz B
                    add $t7 $t7 $t1 #sumar a la direccion de la matriz B el valor de [i][j] y obtenemos dir de B [i][j]
                    sw $t6 ($t7) # poner en B[i][j] 99999


            follow:
            addi $s5 $s5 1 #j++
               b bucle_j #volver a bucle_j
          fin_2:
             addi $s4 $s4 1 #i++
             li $s5 0 #reiniciar el valor j
              b bucle_i #volver a bucle_i
      fin_1: # ya tenemos la matriz B llena ahora hay que imprimirla en el main
        move $v0 $s1 #devolver el valor en $v0 según indica el convenio

lw $s0 ($sp)
lw $s1 4($sp)
lw $s2 8($sp)
lw $s3 16($sp)
lw $s4 20($sp)
lw $s5 24($sp)
lw $s6 32($sp)
lw $s7 36($sp)
lw $ra 28($sp)
addu $sp $sp 40
jr $ra

sacar_exponente:
mov.s $f5, $f12 # el valor de f12(es el primer valor de recorrer la matriz, es decir el argumento) se lo pasas a f5
mfc1 $t3, $f5 #pasar de float a binario
sll $t3 $t3 1 #desplaza una posicion a la izquierda y añade un 0 a la derecha
srl $t3 $t3 24 #desplaza 24 posiciones a la derecha para quitar la mantisa y queda el exponente
sub $t3 $t3 127 #restar 127 obtener el numero en decimal, no en IEEE
move $v0 $t3 #devolver el valor en $v0 según indica el convenio

jr $ra
