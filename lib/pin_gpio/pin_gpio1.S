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
    push {R4, R5, R6, lr} 

    ands R2, R1, #0xF //aplico mascara a ultimos bits
    cmp R2, #8 
    bne 0f
    push {R0, R1} 

    lsrs R1, #4
    bl Pin_escribe

    pop {R0,R1}

 
0:
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
    ldr R6, [R2, R0]
    subs R3, R5 //logical shift | es una potencia | equivalente al mov con deplazamiento multiplo de 4 | necesito de otro registo y se utiliza R4 => hago push{R4,LR} pop {R4, PC}
    lsls R3, #2
    movs R4, #0xF  //utilizo como mascara
    lsls R4, R3
    bics R6, R4 //uso bitclear para borrar
    ands R1, #0xF
    lsls R1, R3
    orrs R6, R1
    str R6, [R2, R0]

    pop {R4, R5, R6, PC} 
    bx lr
endfun Pin_configura




defun Pin_escribe
    // R0: self, R1: valor
    ldr R2, [R0, #Pin__puerto]
    ldr R3, [R0, #Pin__numero]
    movs R0,#1
    lsls R0, R3
    cbz R1, 0f
    str R0 , [R2, #BSRR]
    b 1f
0:
    str R0 , [R2, #BRR]
1:

    bx lr
endfun Pin_escribe

defun Pin_lee
    // R0: self
    ldr R2, [R0, #Pin__puerto]
    ldr R3, [R0, #Pin__numero]
    ldr R0, [R2, #IDR]
    lsr R0, R3
    bx lr
    // R0: valor
endfun Pin_lee

defun Pin_leeSalida
    // R0: self
    ldr R2, [R0, #Pin__puerto]
    ldr R3, [R0, #Pin__numero]
    ldr R0, [R2, #ODR]
    lsr R0, R3
    bx lr
    // R0: valor
endfun Pin_leeSalida
