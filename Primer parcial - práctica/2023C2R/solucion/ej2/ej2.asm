global combinarImagenes_asm
section .data
TRANSPARENCIA: db 0,0,0,255,0,0,0,255,0,0,0,255,0,0,0,255
NO_CUMPLEN: db 0,1,0,0,0,1,0,0,0,1,0,0,0,1,0,0


;########### SECCION DE TEXTO (PROGRAMA)
section .text

; combinarImagenes(uint8_t *src_a, uint8_t *src_b, uint8_t *dst, uint32_t width, uint32_t height)
; imagen_A[rdi], imagen_B[rsi], imagen_DST[rdx], width[ecx], height[r8d]
combinarImagenes_asm:
    push rbp
    mov rbp, rsp

    ; calculamos # iteraciones = width * height / # de pixeles procesador por load de xmm
    xor rax,rax
    mov eax, r8d
    mul ecx                     ; eax = width * height

    mov ecx, eax
    shr ecx, 2                  ; ecx = # iteraciones 


    movdqu xmm0, [rdi]          ; primeros 4 pixeles imagen A  xmm0 = | A_a | R_a | G_a | B_a | ... | A_a | R_a | G_a | B_a |
    movdqu xmm1, [rsi]          ; primeros 4 pixeles imagen B  xmm1 = | A_b | R_b | G_b | B_b | ... | A_b | R_b | G_b | B_b |

    movdqu xmm2, xmm0
    movdqu xmm3, xmm1

    ; componente BLUE de la imagen destino = B_a + R_b
    ; posicionamos en la componente BLUE de destino
    pslld xmm2, 24              ; xmm2 = | B_a | 0 | 0 | 0 | ... | B_a | 0 | 0 | 0 |
    psrld xmm2, 24              ; xmm2 = | 0 | 0 | 0 | B_a | ... | 0 | 0 | 0 | B_a |
    
    pslld xmm3, 8               ; xmm3 = | R_b | G_b | B_b | 0 | ... | R_b | G_b | B_b | 0 |
    psrld xmm3, 24              ; xmm3 = | 0 | 0 | 0 | R_b | ... | 0 | 0 | 0 | R_b |   

    paddb xmm2, xmm3            ; xmm2 = | 0 | 0 | 0 | B_a + R_b | ... | 0 | 0 | 0 | B_a + R_b |

    movdqu xmm3, [TRANSPARENCIA]; xmm3 = | 255 | 0 | 0 | 0 | ... | 255 | 0 | 0 | 0 |
    por xmm2, xmm3              ; xmm2 = | 255 | 0 | 0 | B_a + R_b | ... | 255 | 0 | 0 | B_a + R_b |
          
    movdqu xmm10, xmm2          ; xmm10 = | 255 | 0 | 0 | B_a + R_b | ... | 255 | 0 | 0 | B_a + R_b | 

    ; componente RED de la imagen destino = B_b - R_a
    ; nos paramos en la componente RED de destino
    movdqu xmm2, xmm0           ; xmm2 = | A_a | R_a | G_a | B_a | ... | A_a | R_a | G_a | B_a |
    movdqu xmm3, xmm1           ; xmm3 = | A_b | R_b | G_b | B_b | ... | A_b | R_b | G_b | B_b |

    pslld xmm2, 8               ; xmm2 = | R_a | G_a | B_a | 0 | ... | R_a | G_a | B_a | 0 |
    psrld xmm2, 24              ; xmm2 = | 0 | 0 | 0 | R_a | ... | 0 | 0 | 0 | R_a |
    pslld xmm2, 16              ; xmm2 = | 0 | R_a | 0 | 0 | ... | 0 | R_a | 0 | 0 |

    pslld xmm3, 24              ; xmm3 = | B_b | 0 | 0 | 0 | ... | B_b | 0 | 0 | 0 |
    psrld xmm3, 8               ; xmm3 = | 0 | B_b | 0 | 0 | ... | 0 | B_b | 0 | 0 | 

    psubb xmm3, xmm2            ; xmm3 = | 0 | B_b - R_a | 0 | 0 | ... | 0 | B_b - R_a| 0 | 0 |

    movdqu xmm1, xmm3

    por xmm10, xmm11            ; xmm10 = | 255 | B_b - R_a  | 0 | B_a + R_b | ... | 255 | B_b - R_a | 0 | B_a + R_b | 

    ; componente GREEN de la imagen destino : dos casos 
    ; caso 1 : componente green_A > componente green_B 
    movdqu xmm2, xmm0           ; xmm2 = | A_a | R_a | G_a | B_a | ... | A_a | R_a | G_a | B_a |
    movdqu xmm3, xmm1           ; xmm3 = | A_b | R_b | G_b | B_b | ... | A_b | R_b | G_b | B_b |

    pslld xmm2, 16              ; xmm2 = | G_a | B_a | 0 | 0 | ... | G_a | B_a | 0 | 0 |
    psrld xmm2, 24              ; xmm2 = | 0 | 0 | 0 | G_a | ... | 0 | 0 | 0 | G_a |
    pslld xmm2, 8               ; xmm2 = | 0 | 0 | G_a | 0 | ... | 0 | 0 | G_a | 0 |

    pslld xmm3, 16              ; xmm3 = | G_b | B_b | 0 | 0 | ... | G_b | B_b | 0 | 0 |
    psrld xmm3, 24              ; xmm3 = | 0 | 0 | 0 | G_b | ... | 0 | 0 | 0 | G_b |
    pslld xmm3, 8               ; xmm3 = | 0 | 0 | G_b | 0 | ... | 0 | 0 | G_b | 0 |
    
    movdqu xmm4, xmm2           ; xmm4 = | 0 | 0 | G_a | 0 | ... | 0 | 0 | G_a | 0 |
    movdqu xmm5, xmm2           ; xmm5 = | 0 | 0 | G_a | 0 | ... | 0 | 0 | G_a | 0 |
    movdqu xmm6, xmm3           ; xmm6 = | 0 | 0 | G_b | 0 | ... | 0 | 0 | G_b | 0 |

    ; no tocamos xmm2 ni xmm3 de aca en adelante 
    
    pcmpgtb xmm4, xmm6          ; obtendremos en xmm4 una mascara para saber que valores de verde son mayores en A que en B
    pand xmm5, xmm4             ; xmm5 = componentes verdes de A que cumplen caso 1 
    pand xmm6, xmm4             ; xmm6 = componentes verdes de B que cumplen caso 1

    psubb xmm5, xmm6            ; xmm5 =  (componente green_A - componente green_B) que cumplen condicion 

    ; caso 2 :  componente green_A <= componente green_B 

    movdqu xmm7, [NO_CUMPLEN]   ; cargo la mascara para definir los valores que no cumplen la cond anterior
    pxor xmm7, xmm4             ; como la mascara de xmm4 me decia aquellos que si, con un pxor pasan a ser 0 y los que eran 0, 1

    movdqu xmm8, xmm2           ; xmm8 = | 0 | 0 | G_a | 0 | ... | 0 | 0 | G_a | 0 |
    movdqu xmm9, xmm3           ; xmm9 = | 0 | 0 | G_b | 0 | ... | 0 | 0 | G_b | 0 |

    pand xmm8, xmm7             ; xmm8 = componentes verdes de A que cumplen caso 2
    pand xmm9, xmm7             ; xmm9 = componentes verdes de B que cumplen caso 2

    pavgb xmm8, xmm9            ; xmm8 = promedio (componentes verdes de A, componentes verdes de B)

    por xmm5, xmm8              ; xmm5 = todas las componentes green de la imagen destino
    por xmm10, xmm5             ; xmm10 = | 255 | B_b - R_a  | G_destino | B_a + R_b | ... | 255 | B_b - R_a | G_destino | B_a + R_b | 

    movdqu [rdx], xmm10

    pop rbp
    ret