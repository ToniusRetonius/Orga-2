global miraQueCoincidencia

section .data
ROJO: dd 0,0.299,0,0
VERDE: dd 0,0,0.587,0
AZUL: dd 0,0,0,0.114

;########### SECCION DE TEXTO (PROGRAMA)
section .text

; imagenA [rdi], imageB [rsi], N(alto = ancho)[dl], imagenRes [rcx]
miraQueCoincidencia: 
    push rbp
    mov rbp, rsp

    xor r8, r8
    xor r9, r9
    xor r10, r10
    xor rax, rax
    mov al, dl
    mul dl                          ; N * N iteraciones
    mov r10, rax

    ciclo:
    cmp r10, 0
    je fin
    mov r8, [rdi]                   ; r8 = | A_a | B_a | G_a | R_a | cada componente es de 1 byte
    mov r9, [rsi]                   ; r9 = | A_b | B_b | G_b | R_b | cada componente es de 1 byte

    shl r8, 8                       ; r8 = | B_a | G_a | R_a | 0 |
    shl r9, 8                       ; r9 = | B_b | G_b | R_b | 0 |

    cmp r8, r9
    jne distinto

    ; si son iguales tenemos que hacerlos grandes y hacerle las op con floats
    ; como cada componente es de 1 byte, pasamos el byte a double 
    ; ( PMOVZXBD - Packed MOVe Zero eXtension Byte Dword)
    pxor xmm0, xmm0
    pxor xmm1, xmm1

    movq xmm0, r8
    movq xmm1, r9

    pmovzxbd xmm0, xmm0             ; xmm0 = | 0 | 0 | 0 | B_a | 0 | 0 | 0 | G_a | 0 | 0 | 0 | R_a | 0 | 0 | 0 | 0 |
    pmovzxbd xmm1, xmm1             ; xmm1 = | 0 | 0 | 0 | B_b | 0 | 0 | 0 | G_b | 0 | 0 | 0 | R_b | 0 | 0 | 0 | 0 |

    pxor xmm3, xmm3
    pxor xmm4, xmm4
    pxor xmm5, xmm5

    movdqu xmm3, [ROJO]             ; constante roja $3 = {[0] = 0, [1] = 1050220167, [2] = 0, [3] = 0}
    movdqu xmm4, [VERDE]            ; constante verde $4 = {[0] = 0, [1] = 0, [2] = 1058424226, [3] = 0}
    movdqu xmm5, [AZUL]             ; constante azul $5 = {[0] = 0, [1] = 0, [2] = 0, [3] = 1038710997}

    ; la idea es multiplicar coordenada a coordenada RGB a cualquiera de los dos pixeles (pues son iguales)
    ; para ello pasamos a float a las coordenadas RGB del pixel y luego multiplicamos
    ; tenemos que sumar todo con sumas horizontales, convertimos a int32 y chaucha, extraemos la parte que tiene res
    ; mov [rcx], (resultado)


    distinto:
    mov [rcx], byte 255             
    
    siguiente:
    inc rcx                         ; de a byte son los pixeles estos
    add rdi, 4                      ; proximo pixel imagen A
    add rsi, 4                      ; proximo pixel imagen B
    dec r10
    jmp ciclo

    fin:
    mov rax, rcx
    pop rbp
    ret


