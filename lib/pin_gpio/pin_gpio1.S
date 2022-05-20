// Cortex-M3 Devices Generic User Guide: https://developer.arm.com/documentation/dui0552/
// STM32f103xx Family Reference Manual: https://www.st.com/resource/en/reference_manual/cd00171190-stm32f101xx-stm32f102xx-stm32f103xx-stm32f105xx-and-stm32f107xx-advanced-arm-based-32-bit-mcus-stmicroelectronics.pdf
// STM32f103c8 Datasheet: https://www.st.com/resource/en/datasheet/stm32f103c8.pdf
// Procedure Call Standard for the Arm Architecture: https://github.com/ARM-software/abi-aa/blob/main/aapcs32/aapcs32.rst
.syntax unified
.cpu cortex-m3
.fpu softvfp
.thumb

.macro defun nombre
    .section .text.\nombre
    .global \nombre
    .type \nombre, %function
\nombre:
.endm
.macro endfun nombre
    .size \nombre, . - \nombre
.endm

.set Pin__puerto,0 //se elige el registro crl
.set Pin__numero,4

defun Pin_init
    // R0: self, R1: puerto, R2: numPin | R0 es el puntero, contiene la direccion base de memoria del puerto Y el numero de puerto
    str R1,[R0,#Pin__puerto] 
    str R2,[R0,#Pin__numero]
    bx lr
endfun Pin_init

//debo crear nuevo repositorio de este tp

.set CRL,0x00
.set CRH,0x04
.set IDR,0x08
.set ODR,0x0C
.set BSRR,0x10
.set BRR,0x14

defun Pin_configura
    // R0: self, R1: config 
    push {R4-R6, LR} 
    ldr R2, [R0, #Pin__puerto] //cargo la direccion del puerto
    ldr R3, [R0, #Pin__numero]

    cmp R3, #7
    bls 0f            //bhi : mayor que sin signo | si es menor saltara a 0 | bls : menor que
    mov R5, #8
    mov R0, #CRH
    b 1f
0:
    mov R5, #0
    mov R0, #CRL

1:
    ldr R0, [R2, R0]
    lsls R3, #2 //logical shift | es una potencia | equivalente al mov con deplazamiento multiplo de 4 | necesito de otro registo y se utiliza R4 => hago push{R4,LR} pop {R4, PC}
    movs R4, #0xF  //utilizo como mascara
    lsls R4, R3
    bics R6,R4 //uso bitclear para borrar
    lsls R1, R3
    orrs R6, R1
    str R6, [R2, R0]

    push {R4-R6, PC} 
    bx lr
endfun Pin_configura



defun Pin_escribe
    // R0: self, R1: valor
    push {LR}
    movs R3,#(1<<16)
    cbz R1,0f
    movs R3,#1
0:
    ldrd R1,R2,[R0]
    lsls R3,R2
    str R3,[R1,#BSRR]
    pop {PC}

    //bx lr         ????
endfun Pin_escribe

defun Pin_lee
    // R0: self
    ldrd R0,R1,[R0]
    movs R2,#1
    lsls R1,R2,R1
    ldr R2,[R0,#IDR]
    movs R0,#0
    tst R2,R1
    it ne
    movne R0,#1
    bx lr
    // R0: valor
endfun Pin_lee
defun Pin_leeSalida
    // R0: self
    ldrd R0,R1,[R0]
    movs R2,#1
    lsls R1,R2,R1
    ldr R2,[R0,#ODR]
    movs R0,#0
    tst R2,R1
    it ne
    movne R0,#1
    bx lr
    // R0: valor
endfun Pin_leeSalida
