global YUYV_to_RGBA

section .rodata
    constantes: dd 1.732446, 0.698001, 1.370705, 0.337633
    mask_128: dd 128, 128, 128, 128
    mask_127_error: db 127,127,0,0 ,127,127,0,0 ,127,127,0,0 ,127,127,0,0 
    mask_expand_px: db 0x0,0x1,0x3,0x80 ,0x2,0x1,0x3,0x80 , 0x8,0x9,0xb,0x80 , 0xa,0x9,0xb,0x80
    mask_errores: db 127,255,0,255 ,127,255,0,255 ,127,255,0,255 ,127,255,0,255  ; orden dudoso 

    ; notar que 127 es 0111 1111


;########### SECCION DE TEXTO (PROGRAMA)
section .text

; typedef struct yuyv_t {
;     int8_t y1, u, y2, v;
; } __attribute__((packed)) yuyv_t;

; typedef struct rgba_t {
;     unsigned char r, g, b, a;
; } __attribute__((packed)) rgba_t;   en un xmm = |a|b|g|r|


; cada struct tiene size 32 pixeles = 4 bytes = 1 dw
; en cada iteracion, vamos a agarrar 2 estructuras yuyv, osea 64 bytes y las vamos a
; separar en 4 yuv de 1 dw cada una... creo que el byte mas alto de la dw va a ser 0


;void YUYV_to_RGBA( int8_t *X, uint8_t *Y, uint32_t width, uint32_t height);
; rdi = X src  , rsi = Y dst , rdx = width del src  , rcx = height del src
YUYV_to_RGBA:
    push rbp
    mov rbp, rsp
    push r12
    push r13
    push r14
    push r15


    ; si queremos outputear de a 4 pixeles rgb, tenemos que tomar de a 2 pixles yuyv
    xor r9, r9              ; r9 = i = 0
    xor r10, r10            ; r10 = j = 0

    movdqu xmm15, [constantes]      ; xmm15 = | 0.337633 | 1.370705 | 0.698001 | 1.73244 |
    movdqu xmm14, [mask_expand_px]        
    movdqu xmm13, [mask_128]
    movdqu xmm12, [mask_127_error]
    movdqu xmm11, [mask_errores]

    .ciclo:
        cmp r9, rcx         
        je .fin             ; si i < n seguimos de largo

        pxor xmm0, xmm0                  ; aca vamos a guardar los pixeles RGBA que calculemos

        pmovzxdq xmm1, [rdi]            ; xmm1 = |0000|p2.v, p2.y2, p2.u, p2.y1|0000|p1.v, p1.y2, p1.u, p1.y1|
        movdqu xmm2, xmm1
        pshufb xmm2, xmm14 ; xmm2 = | 0, p2.v , p2.u , p2.y2 | 0, p2.v , p2.u , p2.y1 | 0, p1.v , p1.u , p1.y2 | 0, p1.v , p1.u , p1.y1|

        movdqu xmm3, xmm2  ; xmm3 = | 0, p2.v , p2.u , p2.y2 | 0, p2.v , p2.u , p2.y1 | 0, p1.v , p1.u , p1.y2 | 0, p1.v , p1.u , p1.y1|
        pslld xmm3, 24
        psrad xmm3, 24     ; xmm3 = | 0, 0, 0, p2.y2 | 0, 0, 0, p2.y1 | 0, 0, 0, p1.y2 | 0, 0, 0, p1.y1|   con sign extension!!

        movdqu xmm4, xmm2  ; xmm4 = | 0, p2.v , p2.u , p2.y2 | 0, p2.v , p2.u , p2.y1 | 0, p1.v , p1.u , p1.y2 | 0, p1.v , p1.u , p1.y1|
        pslld xmm4, 16
        psrad xmm4, 24     ; xmm4 = | 0, 0, 0, p2.u | 0, 0, 0, p2.u | 0, 0, 0, p1.u | 0, 0, 0, p1.u|       con sign extension

        movdqu xmm5, xmm2  ; xmm5 = | 0, p2.v , p2.u , p2.y2 | 0, p2.v , p2.u , p2.y1 | 0, p1.v , p1.u , p1.y2 | 0, p1.v , p1.u , p1.y1|
        pslld xmm5, 8
        psrad xmm5, 24     ; xmm5 = | 0, 0, 0, p2.v | 0, 0, 0, p2.v | 0, 0, 0, p1.v | 0, 0, 0, p1.v|        con sign extension

        ; ahora nos ocupamos de los pixeles que tienen errores y tienen valor 127
        movdqu xmm6, xmm2   
        psrld xmm6, 8      ; xmm6 = | 0, 0, p2.v , p2.u| 0, 0, p2.v , p2.u| 0, 0, p1.v , p1.u|0, 0, p1.v , p1.u|
        pcmpeqd xmm6, xmm12; ahora xmm6 tiene 1s en los pixeles con errores, y 0 en los que no


        psubd xmm4, xmm13  ; tiene u - 128 en cada dword, osea las U 
        psubd xmm5, xmm13  ; tiene v - 128 en cada dword, osea las V 
        
        ; ahora convertimos los registros con y, U y V a float
        .convertFloat:
        cvtdq2ps xmm3, xmm3
        cvtdq2ps xmm4, xmm4
        cvtdq2ps xmm5, xmm5     ;  hasta aca esta bien!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

        ; calculamos las R : R = Y + 1.370705 * V
        .red:
        movdqu xmm7, xmm5               ; xmm7 tiene las Vs
        pshufd xmm8, xmm15, 0b10101010  ; xmm8 = |1.370705|1.370705|1.370705|1.370705|
        mulps xmm7, xmm8                ; xmm7 tiene las V * 1.370705
        
        movdqu xmm9, xmm3               ; xmm9 tiene las Ys
        addps xmm9, xmm7                ; xmm9 tienen los valores de los R = Y + V.1.37...

        cvttps2dq xmm9, xmm9            ; xmm7 = |0,0,0,R|0,0,0,R|0,0,0,R|0,0,0,R|
        pslld xmm9, 24
        psrld xmm9, 24

        por xmm0, xmm9                  ; xmm0 = |0,0,0,R|0,0,0,R|0,0,0,R|0,0,0,R|  bien hasta aca

        .green:
        ; calculamos las G : G = Y - 0.698001 * V - 0.337633 * U
        movdqu xmm7, xmm5                  ; xmm7 tiene las Vs
        pshufd xmm8, xmm15, 0b01010101  ; xmm8 = |0.698001|0.698001|0.698001|0.698001|
        mulps xmm7, xmm8                ; xmm7 tiene las V * 0.698001
        
        movdqu xmm9, xmm3               ; xmm9 tiene las Ys
        subps xmm9, xmm7                ; xmm9 tienen los valores de Y - V * 0.698001  good

        movdqu xmm7, xmm4                  ; xmm7 tiene las Us
        pshufd xmm8, xmm15, 0b11111111  ; xmm8 = |0.337633|0.337633|0.337633|0.337633|
        mulps xmm7, xmm8                ; xmm7 tiene las U * 0.337633                       good

        subps xmm9, xmm7                ; xmm9 tienen los valores de G = Y - V * 0.698001 - U * 0.337633

        cvttps2dq xmm9, xmm9            ; xmm9 = |0,0,0,G|0,0,0,G|0,0,0,G|0,0,0,G|
        pslld xmm9, 24                  ; xmm9 = |G,0,0,0|G,0,0,0|G,0,0,0|G,0,0,0| 
        psrld xmm9, 16                  ; xmm9 = |0,0,G,0|0,0,G,0|0,0,G,0|0,0,G,0|  

        por xmm0, xmm9                  ; xmm0 = |0,0,G,R|0,0,G,R|0,0,G,R|0,0,G,R|  good

        .blue:
        ; calculamos las B : B = Y + 1.732446 * U
        movdqu xmm7, xmm4                  ; xmm7 tiene las Us
        pshufd xmm8, xmm15, 0b00000000  ; xmm8 = |1.732446|1.732446|1.732446|1.732446|
        mulps xmm7, xmm8                ; xmm7 tiene las U * 1.732446
        
        movdqu xmm9, xmm3               ; aca tenemos las Ys                        
        addps xmm9, xmm7                ; xmm9 tienen los valores de los R = Y - U * 1.7324... good

        cvttps2dq xmm9, xmm9            ; xmm9 = |0,0,0,B|0,0,0,B|0,0,0,B|0,0,0,B|
        pslld xmm9, 24                  ; xmm9 = |B,0,0,0|B,0,0,0|B,0,0,0|B,0,0,0| 
        psrld xmm9, 8                   ; xmm9 = |0,B,0,0|0,B,0,0|0,B,0,0|0,B,0,0|

        por xmm0, xmm9                  ; xmm0 = |0,R,G,B|0,R,G,B|0,R,G,B|0,R,G,B|

        ; limpiamos en la mascara de pixeles erroneos, los pixeles sanos
        movdqu xmm10, xmm11             ; xmm10 = |error_px|error_px|error_px|error_px|
        pand xmm10, xmm6                ; xmm10 = |error_px|0000|error_px|0000|

        pcmpeqd xmm2, xmm2              ; xmm2 = |ffff|ffff|ffff|ffff|
        pxor xmm6, xmm2                 ; xmm6 = ~xmm6

        ; ahora xmm6 tiene 0s en los pixeles defectuosos y 1s en los sanos

        pand xmm0, xmm6                 ; limpiamos los espacios de los pixeles defectuosos
        por xmm0, xmm10                 ; agregamos los resultados de los pixeles erroneos

        ; falta agregar los alphas en 255
        psrld xmm2, 24                  ; |0, 0, 0, 255|...|...|...|
        pslld xmm2, 24                  ; |255, 0, 0, 0|...|...|...|
        por xmm0, xmm2                  ; |255, R, G, B|...|...|...|

        .nextPixels:
            ; escribimos el res de 4 pixeles en el dst
            movdqu [rsi], xmm0        ; escribimos es resultado en el destino.

            add rdi, 8                  ; en src avanzamos de a 8 bytes, osea 2 estructuras de 4 bytes
            add rsi, 16                 ; en dst avanzamos de a 16 bytes, osea 4 estructuras de 4 bytes (rgba)

            add r10, 2                  ; j += 2 ya que agarramos de a 2 pixeles yuyv que son como 4 pixeles rgba
            cmp r10, rdx
            jl .ciclo       ; si j < n : seguimos en la misma row

        .nextRow:
            inc r9          ; i++
            xor r10, r10    ; j=0
            jmp .ciclo

    .fin:
        pop r15
        pop r14
        pop r13
        pop r12
        pop rbp
        ret






















