.data
WordSearch: .byte 'a', 'l', 'o', 'H', 'H', 'O', 'N', 'X',
            .byte 'l', 'g', 'h', 'k', 'k', 'm', 'e', 'E',
            .byte 'o', 'x', 'O', 'L', 'C', 'c', 'C', 'D',
            .byte 'H', 'O', 'i', 'X', 'A', 'l', 'p', 'H',
            .byte 'h', 'L', 'a', 's', 'I', 'O', 'u', 'h',
            .byte 'L', 'B', 'B', 'Y', 'U', 'J', 'X', 'O',
            .byte 'O', 'H', 'O', 'p', 'A', 'O', 'H', 'l',
            .byte 'H', 'J', 'K', 'h', 'h', 'O', 'L', 'a',
Word: .asciiz "hOla"
N: .word  8

.text

    .globl main

    main:
        la $a0 WordSearch #Cargar la matriz
        lw $a1 N #Cargar las dimensiones
        la $a2 Word #Cargar la palabra a encontrar
        sub $sp $sp 4 #Creamos espacio en pila para guardar $ra para que la funcion pueda regresar al main
        sw $ra ($sp)

        jal SearchWords
        move $a0 $v0#el resultado lo devolvemos a $a0
        li $v0 1#lo imprimimos
        syscall

        lw $ra ($sp)
        addu $sp $sp 4

        li $v0 10#exit del programa
        syscall
        jr $ra

    wordlength: #Para medir la longitud de la palabra
        addu $sp $sp -4
        sw $ra ($sp)

        move $t1 $a2 #pasamos la direccion para poder movernos sin modifciar el argumento inicial

        li $t6 0 #Contador de longitud de palabra
        midiendo_palabra:
            lb $t5 ($t1)
            beqz $t5 fin_long
            addi $t1 $t1 1 #nos movemos por la palabbra
            addi $t6 $t6 1
            b midiendo_palabra

        fin_long:
        move $v0 $t6

        lw $ra ($sp)
        addu $sp $sp 4
        jr $ra

    SearchWords: #Funcion que une a todas las SearchWords R+L+U+D
        addu $sp $sp -4
        sw $ra ($sp)
        #Las llamadas a los 4 distintos algoritmos, cada uno de los cuales se encanrga de buscar palabras en
        #una direccion determinada
        jal SearchWordsR #right
        jal SearchWordsL #left
        jal SearchWordsD #down
        jal SearchWordsU #up

        lw $ra ($sp)
        addu $sp $sp 4
        jr $ra

    SearchWordsR:
        addu $sp $sp -16
        sw $s0 ($sp)
        sw $s1 4($sp)
        sw $s4 8($sp)
        sw $ra 12($sp)

        li $s0 0 #Contador de letras cl
        li $s1 0 #Palabras Encontradas pe

        move $t7 $a1 #N

        jal wordlength
        move $s4 $v0 #longitud de palabra

        li $t4 0 #i bucle for
        bucle_iR:
            bge $t4 $t7 fin_1R
            li $t6 0 #j bucle for
            li $s0 0 #reiniciamos el contador de letras
            bucle_jR:
                bge $t6 $t7 fin_2R #bucle for de js
                # (i * N + j)x1
                mul $t0 $t4 $t7
                add $t0 $t0 $t6
                # * matriz + (i * N +j) * 1
                #cargamos la direccion de la matriz, para añadirle el contador, y coger esa letra
                la $t5 ($a0)
                add $t5 $t5 $t0
                lb $t5 ($t5)
                #cargamos la direccion de la palabra, para añadirle el contador, y coger esa letra
                la $t2 ($a2)
                add $t2 $t2 $s0
                lb $t2 ($t2)

                checking_same_letterR: #if de revisar cada caracter de la palabra con matriz
                    bne $t5 $t2 rechekingR #si son iguales (las dos minusculas)
                    addu $s0 $s0 1 #el cp se suma 1
                    j if_eurekapalabraR #nos vamos directamente a chequear si hemos encontrado la palabra entera
                rechekingR:
                    #ya que no tienen la misma condicion de mayuscula o minuscula vemos si sumando a una 20 en decimal
                    #son la misma letra, si lo son ahora iran a la condicion anterior, y sino seguir buscando
                    beq $t5 $t2 if_eurekapalabraR #si son iguales es la misma letra
                    bgt $t5 96 smallerR #si la letra de la matriz es mayuscula y matriz minuscula va a smallerR
                    addi $t5 $t5 32 #al ser la letra de la matriz minuscula le sumamamos 32
                    beq $t5 $t2 checking_same_letterR ##si coinciden nos movemos en la palabra
                smallerR:
                    addi $t5 $t5 -32 #le restamos 32 para convertirla a minuscula
                    beq $t5 $t2 checking_same_letterR #si coinciden nos movemos en la palabra
                letters_repeatedR:
                    beqz $s0 not_same_letterR #para el caso de que la letra inicial de la palabra se repita 2 veces
                    li $s0 0
                    b bucle_jR #para chequear otra vez
                not_same_letterR: #la letra no es la misma, teniendo en cuenta mayusculas y letras repetidas
                    li $s0 0 #contador de letra a 0
                    j followR
                if_eurekapalabraR: #if de encontrar la palabra, el indice de la palabra a 0 y +1pe
                    bne $s0 $s4 followR # cl == word.length
                    li $s0 0 #cl a 0
                    addi $s1 $s1 1 #palabras encontradas mas 1
                followR:
                addi $t6 $t6 1 #sumamos j++
                b bucle_jR
            fin_2R:
            addi $t4 $t4 1 #sumamos i++
            b bucle_iR
        fin_1R:
        move $a3 $s1
        move $v0 $a3 #no sería necesario ya que no devuelve aqui sino en el ultimo algoritmo

        lw $s0 ($sp) #creamos espacio en pila
        lw $s1 4($sp)
        lw $s4 8($sp)
        lw $ra 12($sp)
        addu $sp $sp 16

        jr $ra

    SearchWordsL:
        addu $sp $sp -16
        sw $s0 ($sp)
        sw $s1 4($sp)
        sw $s4 8($sp)
        sw $ra 12($sp)

        li $s0 0 #Contador de letras cl
        li $s1 0 #Palabras Encontradas pe

        move $t7 $a1 #N
        li $t3 0

        jal wordlength
        move $s4 $v0

        move $t4 $a1 #i bucle for
        addi $t4 $t4 -1 #dado que la casilla inicial es 0 y no 1, el i inicial es N-1
        bucle_iL:
            blt $t4 $t3 fin_1L #iguales a 0
            move $t6 $a1 #j bucle for
            addi $t6 $t6 -1 #dado que la casilla inicial es 0 y no 1, el j inicial es N-1
            li $s0 0 #reiniciamos el contador de letras
            bucle_jL:
                blt $t6 $t3 fin_2L #bucle for de js
                #CONDICIONES PARA EL NEXT IF
                # (i * N + j)x1
                mul $t0 $t4 $t7
                add $t0 $t0 $t6
                # * matriz + (i * N +j) * 1
                #cargamos la direccion de la matriz, para añadirle el contador, y coger esa letra
                la $t5 ($a0) #matriz
                add $t5 $t5 $t0
                lb $t5 ($t5)
                #cargamos la direccion de la palabra, para añadirle el contador, y coger esa letra
                la $t2 ($a2)
                add $t2 $t2 $s0
                lb $t2 ($t2)
                checking_same_letterL: #if de revisar cada caracter de la palabra con matriz
                    bne $t5 $t2 rechekingL #si son iguales (las dos minusculas)
                    addu $s0 $s0 1 #el cp se suma 1
                    j if_eurekapalabraL #nos vamos directamente a chequear si hemos encontrado la palabra entera
                rechekingL:
                    #ya que no tienen la misma condicion de mayuscula o minuscula vemos si sumando a una 20 en decimal
                    #son la misma letra, si lo son ahora iran a la condicion anterior, y sino seguir buscando
                    beq $t5 $t2 if_eurekapalabraL #si son iguales es la misma letra
                    bgt $t5 96 smallerL #si la letra de la matriz es mayuscula y matriz minuscula va a smallerL
                    addi $t5 $t5 32 #al ser la letra de la matriz minuscula le sumamamos 32
                    beq $t5 $t2 checking_same_letterL #si coinciden nos movemos en la palabra
                smallerL:
                    addi $t5 $t5 -32 #le restamos 32 para convertirla a minuscula
                    beq $t5 $t2 checking_same_letterL #si coinciden nos movemos en la palabra
                letters_repeatedL:
                    beqz $s0 not_same_letterL #para el caso de que la letra inicial de la palabra se repita 2 veces
                    li $s0 0
                    b bucle_jL #para chequear otra vez
                not_same_letterL: #la letra no es la misma, teniendo en cuenta mayusculas y letras repetidas
                    li $s0 0 #cl a 0
                    j followL
                if_eurekapalabraL: #if de encontrar la palabra, el indice de la palabra a 0 y +1pe
                    bne $s0 $s4 followL # cl == word.length
                    li $s0 0 #cl a 0
                    addi $s1 $s1 1 #palabras encontradas mas 1
                followL:
                addi $t6 $t6 -1 #restamos j--
                b bucle_jL
            fin_2L:
            addi $t4 $t4 -1 #restamos i--
            b bucle_iL
        fin_1L:
        move $t1 $a3 #cogemos el resultado anterior guardado en a3
        add $t1 $t1 $s1 #a ello le sumamos las palabras contadas hacia la izquierda
        move $a3 $t1 #lo pasamos a a3
        move $v0 $a3#no sería necesario ya que no devuelve aqui sino en el ultimo algoritmo

        lw $s0 ($sp) #creamos espacio en pila
        lw $s1 4($sp)
        lw $s4 8($sp)
        lw $ra 12($sp)
        addu $sp $sp 16

        jr $ra

    SearchWordsD:
        addu $sp $sp -16
        sw $s0 ($sp)
        sw $s1 4($sp)
        sw $s4 8($sp)
        sw $ra 12($sp)

        li $s0 0 #Contador de letras cl
        li $s1 0 #Palabras Encontradas pe

        move $t7 $a1 #N

        jal wordlength
        move $s4 $v0 #para saber cuando volver a la letra inicial, cogemos la longitud de palabra

        li $t4 0 #j bucle for
        bucle_jD:
            bge $t4 $t7 fin_1D # bucle for de js
            li $t6 0 #i bucle for
            li $s0 0 #reiniciamos el contador de letras
            bucle_iD:
                bge $t6 $t7 fin_2D #bucle for de is
                #CONDICIONES PARA EL NEXT IF
                # (i * N + j)x1
                mul $t0 $t6 $t7
                add $t0 $t0 $t4
                # * matriz + (i * N +j) * 1
                #cargamos la direccion de la matriz, para añadirle el contador, y coger esa letra
                la $t5 ($a0) #matriz
                add $t5 $t5 $t0
                lb $t5 ($t5)
                #cargamos la direccion de la palabra, para añadirle el contador, y coger esa letra
                la $t2 ($a2)
                add $t2 $t2 $s0
                lb $t2 ($t2)
                checking_same_letterD: #if de revisar cada caracter de la palabra con matriz
                    bne $t5 $t2 rechekingD #si son iguales (las dos minusculas)
                    addu $s0 $s0 1 #el cp se suma 1
                    j if_eurekapalabraD #nos vamos directamente a chequear si hemos encontrado la palabra entera
                rechekingD:
                    #ya que no tienen la misma condicion de mayuscula o minuscula vemos si sumando a una 20 en decimal
                    #son la misma letra, si lo son ahora iran a la condicion anterior, y sino seguir buscando
                    beq $t5 $t2 if_eurekapalabraD #si son iguales es la misma letra
                    bgt $t5 96 smallerD #si la letra de la matriz es mayuscula y matriz minuscula va a smallerD
                    addi $t5 $t5 32 #al ser la letra de la matriz minuscula le sumamamos 32
                    beq $t5 $t2 checking_same_letterD #si coinciden nos movemos en la palabra
                smallerD:
                    addi $t5 $t5 -32 #le restamos 32 para convertirla a minuscula
                    beq $t5 $t2 checking_same_letterD #si coinciden nos movemos en la palabra
                letters_repeatedD:
                    beqz $s0 not_same_letterD #para el caso de que la letra inicial de la palabra se repita 2 veces
                    li $s0 0
                    b bucle_iD #para chequear otra vez
                not_same_letterD:
                    li $s0 0 #cl a 0
                    j followD
                if_eurekapalabraD: #if de encontrar la palabra, el indice de la palabra a 0 y +1pe
                    bne $s0 $s4 followD # cl == word.length
                    li $s0 0 #cl a 0
                    addi $s1 $s1 1 #palabras encontradas mas 1
                followD:
                addi $t6 $t6 1 #sumamos i++
                b bucle_iD
            fin_2D:
            addi $t4 $t4 1 #sumamos j++
            b bucle_jD
        fin_1D:
        move $t1 $a3 #cogemos el resultado anterior guardado en a3
        add $t1 $t1 $s1 #a ello le sumamos las palabras contadas hacia abajo
        move $a3 $t1 #lo pasamos a a3
        move $v0 $a3 #no sería necesario ya que no devuelve aqui sino en el ultimo algoritmo

        lw $s0 ($sp) #reestablecemos la pila
        lw $s1 4($sp)
        lw $s4 8($sp)
        lw $ra 12($sp)
        addu $sp $sp 16

        jr $ra

    SearchWordsU:
        addu $sp $sp -16
        sw $s0 ($sp)
        sw $s1 4($sp)
        sw $s4 8($sp)
        sw $ra 12($sp)

        li $s0 0 #Contador de letras cl
        li $s1 0 #Palabras Encontradas pe

        move $t7 $a1 #N
        li $t3 0

        jal wordlength
        move $s4 $v0

        move $t4 $a1 #j bucle for
        addi $t4 $t4 -1 #dado que la casilla inicial es 0 y no 1, el j maximo es N-1
        bucle_jU:
            blt $t4 $t3 fin_1U #iguales a 0
            move $t6 $a1 #i bucle for
            addi $t6 $t6 -1 #dado que la casilla inicial es 0 y no 1, el j inicial es N-1
            li $s0 0 #reiniciamos el contador de letras
            bucle_iU:
                blt $t6 $t3 fin_2U #bucle for de js
                #CONDICIONES PARA EL NEXT IF
                # (i * N + j)x1
                mul $t0 $t6 $t7
                add $t0 $t0 $t4
                # * matriz + (i * N +j) * 1
                #cargamos la direccion de la matriz, para añadirle el contador, y coger esa letra
                la $t5 ($a0) #matriz
                add $t5 $t5 $t0
                lb $t5 ($t5)
                #cargamos la direccion de la palabra, para añadirle el contador, y coger esa letra
                la $t2 ($a2)
                add $t2 $t2 $s0
                lb $t2 ($t2)
                checking_same_letterU: #if de revisar cada caracter de la palabra con matriz
                    bne $t5 $t2 rechekingU #si son iguales (las dos minusculas)
                    addu $s0 $s0 1 #el cp se suma 1
                    j if_eurekapalabraU
                rechekingU:
                    #ya que no tienen la misma condicion de mayuscula o minuscula vemos si sumando a una 20 en decimal
                    #son la misma letra, si lo son ahora iran a la condicion anterior, y sino seguir buscando
                    beq $t5 $t2 if_eurekapalabraU #si son iguales es la misma letra
                    bgt $t5 96 smallerU #si la letra de la matriz es mayuscula y matriz minuscula va a smallerU
                    addi $t5 $t5 32  #al ser la letra de la matriz minuscula le sumamamos 32
                    beq $t5 $t2 checking_same_letterU #si coinciden nos movemos en la palabra
                smallerU:
                    addi $t5 $t5 -32 #le restamos 32 para convertirla a minuscula
                    beq $t5 $t2 checking_same_letterU #si coinciden nos movemos en la palabra
                letters_repeatedU:
                    beqz $s0 not_same_letterU #para el caso de que la letra inicial de la palabra se repita 2 veces
                    li $s0 0
                    b bucle_iU #para chequear otra vez
                not_same_letterU:
                    li $s0 0 #cl a 0
                    j followU
                if_eurekapalabraU: #if de encontrar la palabra, el indice de la palabra a 0 y +1pe
                    bne $s0 $s4 followU # cl == word.length
                    li $s0 0 #cl a 0
                    addi $s1 $s1 1 #palabras encontradas mas 1
                followU:
                addi $t6 $t6 -1 #restamos j--
                b bucle_iU
            fin_2U:
            addi $t4 $t4 -1 #restamos i--
            b bucle_jU
        fin_1U:
        move $t1 $a3 #cogemos el resultado anterior guardado en a3
        add $t1 $t1 $s1 #a ello le sumamos las palabras contadas hacia abajo
        move $a3 $t1 #lo pasamos a a3
        move $v0 $a3 #el resultado de una funcion se devuelve en v0 para ya salir al main
        #no es necesario en el resto de funciones ya que damos por hecho que en todo momento
        #a la hora de buscar palabras se chequearan todas las direcciones, siendo solo útil este
        #ultimo move que devuelva el parámetro en $v0

        lw $s0 ($sp) #creamos espacio en pila
        lw $s1 4($sp)
        lw $s4 8($sp)
        lw $ra 12($sp)
        addu $sp $sp 16

        jr $ra
