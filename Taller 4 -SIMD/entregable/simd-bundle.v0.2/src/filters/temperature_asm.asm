; ARGB
global temperature_asm

section .rodata
align 16
    treinta_y_uno: dd 31, 31, 31, 31
    treinta_y_dos: dd 32, 32, 32, 32
    noventa_y_cinco: dd 95, 95, 95, 95
    noventa_y_seis: dd 96, 96, 96, 96
    ciento_ciencuenta_y_nueve: dd 159, 159, 159, 159
    ciento_sesenta: dd 160, 160, 160, 160
    doscientos_veintitres: dd 223, 223, 223, 223
    doscientos_veinticuatro: dd 224, 224, 224, 224
    tres: dd 3.0, 3.0, 3.0, 3.0      
    ;  A R G B A R G B
    poner_A_en_0: dw 0xFF, 0xFF, 0xFF, 0, 0xFF, 0xFF, 0xFF, 0
    poner_solo_A: dw 0, 0, 0, 0xFF, 0, 0, 0, 0xFF
    ;                B  G   R  A

    ;base_caso1: dw 0,    0,    0,   128,   0,    0,    0,   128
    base_caso1: dw 128,    0,    0,   0,   128,    0,    0,   0
    ;                     +4*t1                 +4*t2
    ;sum_caso_1: dw 0,    0,    0,  0xFFFF,   0,    0,    0,  0xFFFF
    sum_caso_1: dw 0xFFFF,    0,    0,  0,   0xFFFF,    0,    0,  0
    ;----------------------------------------------------------------------------------------

    ;base_caso2: dw 0,    0,   -128,   255,   0,    0,   -128,   255
    base_caso2: dw 255, -128, 0, 0, 255, -128, 0, 0
    ;                +4*t1                 +4*t2          
    ;sum_caso_2: dw 0,    0,   0xFFFF,    0,   0,    0,   0xFFFF,    0
    sum_caso_2: dw 0,    0xFFFF,   0,    0,   0,    0xFFFF,   0,    0
    ;----------------------------------------------------------------------------------------

    ;base_caso3: dw 0,  -384,   255,   639,   0,   -384,   255,   639
    base_caso3: dw 639,  255,   -384,   0,   639,   255,   -384,   0
    ;           +4*t1        -4*t1       +4*t2        -4*t2
    ;sum_caso_3: dw 0,  0xFFFF,    0,    0,   0,   0xFFFF,    0,    0
    sum_caso_3: dw 0,  0,    0xFFFF,    0,   0,   0,    0xFFFF,    0
    ;res_caso_3: dw 0,    0,    0,  0xFFFF,   0,    0,    0,  0xFFFF
    res_caso_3: dw 0xFFFF,    0,    0,  0,   0xFFFF,    0,    0,  0
    ;----------------------------------------------------------------------------------------
    ;base_caso4: dw 0,   255,   895,    0,   0,   255,   895,    0
    base_caso4: dw 0,   895,   255,    0,   0,   895,   255,    0
    ;                -4*t1                 -4*t2
    ;res_caso_4: dw 0,    0,   0xFFFF,    0,   0,    0,   0xFFFF,    0
    res_caso_4: dw 0,    0xFFFF,   0,    0,   0,    0xFFFF,   0,    0
    ;----------------------------------------------------------------------------------------
    ;base_caso5: dw 0,  1151,    0,    0,   0,   1151,    0,    0
    base_caso5: dw 0,  0,    1151,    0,   0,   0,    1151,    0
    ;           -4*t1                 -4*t2
    ;res_caso_5: dw 0,  0xFFFF,    0,    0,   0,   0xFFFF,    0,    0
    res_caso_5: dw 0,  0,    0xFFFF,    0,   0,   0,    0xFFFF,    0
            

section .text

temperature_asm:
push rbp
mov rbp, rsp

mov rax, rdx    ; colocamos rdx (ancho) en rax
mul rcx         ; hacemos rax = rax*rcx(alto)
mov rcx, rax    ; rcx = ancho*alto

    ciclo:
    cmp rcx, 0  ; vamps a iterar cada pixel de a 2
    jle fin    ; cuando los hayamos visto todos, terminamos el ciclo

    ;levantamos 2 pixeles (solo vamos a usar 2, pixeles pasados a 64 bits cada uno)
    pmovzxbw xmm0, [rdi] 

    ;primero hacemos una copia de los A de los 2 pixeles
    movdqu xmm14, xmm0
    pand xmm14, [poner_solo_A]  ; dejamos solo vivos los A
    ; vamos a usar xmm14 al final para restaurar los A

    ; ponemos A en 0 en ambos pixeles
    pand xmm0, [poner_A_en_0]   

    ;hacemos suma horizontal
    phaddw xmm0,xmm0
    phaddw xmm0, xmm0   ; ahora, en xmm0 = | R1+G1+B1 | R2+G2+B2 | R1+G1+B1 | R2+G2+B2 | R1+G1+B1 | R2+G2+B2 | R1+G1+B1 | R2+G2+B2 |

    ; convertimos cada parte en un float, para poder asi dividir por 3
    pmovzxwd xmm0, xmm0             ; primero pasamos los valores a 32 bits, para poder pasarlos a float, xmm0 = | R1+G1+B1 | R2+G2+B2 | R1+G1+B1 | R2+G2+B2 |
    cvtdq2ps xmm0, xmm0      ; lo pasamos a float
    divps xmm0, [tres]       ; dividimos por 3
    cvtps2dq xmm0, xmm0      ; lo devolvemos a int
    ; nos quedo xmm0 = | t1 | t2 | t1 | t2 |   * 32 bits
    pshufd xmm0, xmm0, 0b11_01_10_00 ; lo ponemos asi,  xmm0 = | t1 | t1 | t2 | t2 |
    

    ; temporalmente uso xmm15 para no sobreescribir xmm0
    movdqu xmm15, [treinta_y_dos]  
    pcmpgtd xmm15, xmm0        ; 32 >? t
    movdqu xmm1, xmm15        ; guardo los bools en xmm1

    movdqu xmm15, [noventa_y_seis]  
    pcmpgtd xmm15, xmm0        ; 96 >? t
    movdqu xmm2, xmm15        ; guardo los bools en xmm2
    movdqu xmm15, xmm0
    pcmpgtd xmm15, [treinta_y_uno]   ; 31 < t  <-> 32 <= t
    pand xmm2, xmm15

    movdqu xmm15, [ciento_sesenta]  
    pcmpgtd xmm15, xmm0        ; 160 >? t
    movdqu xmm3, xmm15        ; guardo los bools en xmm3
    movdqu xmm15, xmm0
    pcmpgtd xmm15, [noventa_y_cinco]   ; 95 < t  <-> 96 <= t
    pand xmm3, xmm15

    movdqu xmm15, [doscientos_veinticuatro]  
    pcmpgtd xmm15, xmm0        ; 24 >? t
    movdqu xmm4, xmm15        ; guardo los bools en xmm4
    movdqu xmm15, xmm0
    pcmpgtd xmm15, [ciento_ciencuenta_y_nueve]   ; 159 < t  <-> 160 <= t
    pand xmm4, xmm15

    movdqu xmm15, xmm0  
    pcmpgtd xmm15, [doscientos_veintitres]        ; 223 < t  <-> 224 <= t
    movdqu xmm5, xmm15        ; guardo los bools en xmm5


    ; ya tengo las mascaras para el caso 1,2,3,4,5; ahora falta generar todos los casos
    movdqu xmm6, [base_caso1]
    movdqu xmm7, [base_caso2]
    movdqu xmm8, [base_caso3]
    movdqu xmm9, [base_caso4]
    movdqu xmm10, [base_caso5]

    ; ahora tomamos xmm0 y pasamos los 4 t´s de 32 bits a 8 de 16.
    packusdw xmm0, xmm0      ; xmm0 = | t1 | t1 | t2 | t2 | t1 | t1 | t2 | t2 |
    pshufd xmm0, xmm0, 0b11_01_10_00   ; xmm0 = | t1 | t1 | t1 | t1 | t2 | t2 | t2 | t2 |  lo acomodamos
    psllw xmm0, 2         ; xmm0 = | 4*t1 | 4*t1 | 4*t1 | 4*t1 | 4*t2 | 4*t2 | 4*t2 | 4*t2 |

    movdqu xmm15, xmm0      ; copio en xmm15 a xmm0. Pues le voy a aplicar varias mascaras

    ; caso 1
    pand xmm15, [sum_caso_1]  ; xmm15 = | 0 | 0 | 0 |   4*t1 | 0 | 0 | 0 |   4*t2 |
    paddw xmm6, xmm15     ; xmm6 = | 0 | 0 | 0 | 128 + 4*t1 | 0 | 0 | 0 | 128 + 4*t2 |
    ;----------------------------------------------------------------------------------------------------

    movdqu xmm15, xmm0  ; reseteo a xmm15

    ; caso 2
    pand xmm15, [sum_caso_2]  ; xmm15 = | 0 | 0 | 4*t1   | 0 | 0 | 0 | 4*t2   | 0 |
    paddw xmm7, xmm15     ; xmm6 = | 0 | 0 | 4*t1 - 128 | 255 | 0 | 0 | 4*t2 - 128 | 255 |
    ;----------------------------------------------------------------------------------------------------
    
    movdqu xmm15, xmm0  ; reseteo a xmm15

    ; caso 3
    pand xmm15, [sum_caso_3]
    paddw xmm8, xmm15
    movdqu xmm15, xmm0
    pand xmm15, [res_caso_3]
    psubw xmm8, xmm15
    ;----------------------------------------------------------------------------------------------------

    movdqu xmm15, xmm0  ; reseteo a xmm15
    
    ; caso 4
    pand xmm15, [res_caso_4] 
    psubw xmm9, xmm15  
    ;----------------------------------------------------------------------------------------------------

    movdqu xmm15, xmm0  ; reseteo a xmm15

    ; caso 5
    pand xmm15, [res_caso_5]
    psubw xmm10, xmm15


    ; ya tenemos armados todos los casos, ahora los unimos
    pand xmm6, xmm1             ; en cada uno, van a quedar los pixeles que hayan pasado su respectivo caso
    pand xmm7, xmm2
    pand xmm8, xmm3
    pand xmm9, xmm4
    pand xmm10, xmm5

    por xmm6, xmm7              ; ahora los unimos
    por xmm6, xmm8
    por xmm6, xmm9
    por xmm6, xmm10

    ; restauramos A en los 2 pixeles
    paddw xmm6, xmm14

    ; pasamos el resultado devueltas a 2 pixeles de 32 bits
    packuswb xmm6, xmm6

    movq [rsi], xmm6

    add rsi, 8 ; avanzo 2 pixeles
    add rdi, 8 ; avanzo 2 pixeles

    sub rcx, 2

    jmp ciclo

fin:

pop rbp
ret