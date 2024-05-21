global YUYV_to_RGBA

section .data
%define R 1.370705
%define G1 0.698001
%define G2 0.337633
%define B 1.732446

Shuffle_y1  db 15,15,15,0xff,13,13,13,0xff,11,11,11,0xff,9,9,9,0xff
Shuflle_y5 db 7,7,7,0xff,5,5,5,0xff,3,3,3,0xff,1,1,1,0xff

Shuflle_UxVx_1 db 12,0xff,14,0xff,12,0xff,14,0xff,10,0xff,8,0xff,10,0xff,8,0xff  
Shuflle_UxVx_2 db 6,0xff,4,0xff,6,0xff,4,0xff,2,0xff,0,0xff,2,0xff,0,0xff

Shuflle_UxVx_a db 0xff,14,0xff,0xff,0xff,14,0xff,0xff,0xff,12,0xff,0xff,0xff,12,0xff,0xff
Shuflle_UxVx_b db 0xff,14,0xff,0xff,0xff,14,0xff,0xff,0xff,12,0xff,0xff,0xff,12,0xff,0xff

Mask_UV times 4 db 0,0xff,0,0xff
Mask_128 times 4 db 128,0,128,0
Mask_255 times 4 db 0,0,0,255

Mask_RxV_BxU times 4 dw 1.732446,1.370705
Mask_G times 4 dw 0.337633,0.698001

;########### SECCION DE TEXTO (PROGRAMA)
section .text

;void YUYV_to_RGBA( int8_t *X, uint8_t *Y, uint32_t width, uint32_t height);
YUYV_to_RGBA:
    push rbp
    mov rbp, rsp

    mul edx,ecx                 ; cantidad pixeles en la imagen
    shr edx, 4                  ; como traigo de a 16 bytes, divido por 16

    ciclo:
    cmp edx, 0
    je fin

    xor xmm1, xmm1
    xor xmm2, xmm2
    xor xmm3, xmm3
    xor xmm4, xmm4
    xor xmm5, xmm5
    xor xmm6, xmm6
    xor xmm7, xmm7
    
    movdqu xmm0, [rdi]          ; traemos los bloques YUYV (4)
    movdqu xmm1, xmm0           ; copia
    movdqu xmm2, xmm0           ; copia
    
    movdqu xmm3, [Shuffle_y1]   ; mascara primer shuffle
    movdqu xmm4, [Shuffle_y5]   ; mascara segundo shuffle
    movdqu xmm5, [Mask_UV]      ; mascara 0 U 0 V ...
    movdqu xmm6, [Mask_128]     ; mascara para la resta 

    pand xmm0, xmm5             ; xmm0 = 0 U 0 V ... 0 U 0 V 
    psubb xmm0, xmm6            ; xmm0 = 0 (U-128) 0 (V-128) ... 0 (U-128) 0 (V-128)
    pshufb xmm1, xmm3           ; xmm1 = y1 y1 y1 0 ... y4 y4 y4 0
    pshufb xmm2, xmm4           ; xmm2 = y5 y5 y5 0 ... y8 y8 y8 0
    
    movdqu xmm3, [Mask_RxV_BxU] ; mascara para la multiplicacion de V por 1.370705 y U por 1.732446
    movdqu xmm4, [Mask_G]       ; mascara para multiplicar a U y a V para obtener parte de GREEN
    
    movdqu xmm7, xmm0           ; copia xmm0 para el caso GREEN

    pmullw xmm0, xmm3           ; obtenemos los valores de V por 1.370705 y U por 1.732446 en XMM0
    pmullw xmm7, xmm4           ; obtenemos los valores de V * 0.698001 y U * 0.337633 en XMM7

    ; xmm0 =  (U * 1.732446) (V * 1.370705)  ... (U * 1.732446) (V * 1.370705) son de 16 bits cada uno
    ; xmm7 =  (U * 0.337633) (V * 0.698001)  ... (U * 0.337633) (V * 0.698001) son de 16 bits cada uno
    xor xmm5, xmm5
    phaddw xmm7, xmm5           ; tenemos en la parte alta todas las sumas (U * 0.337633) + (V * 0.698001) que son 4 es decir estan en los ultimos 8 bytes

    ; la idea es poner los low en posiciones adecuadas para sumar y restar a los valores de Y de los registros xmm1, xmm2

    movdqu xmm3, [Shuflle_UxVx_a]   ; shuffle para calcular R y B parte 1 xmm1
    movdqu xmm4, [Shuflle_UxVx_b]   ; shuffle para calcular R y B parte 2 xmm2

    movdqu xmm5, xmm7               ; Green parte 1
    movdqu xmm6, xmm7               ; Green parte 2

    pshufb xmm5, xmm3               ; xmm5 = 0 ((U * 0.337633) + (V * 0.698001)) 0 0 0 ... parte 1
    pshufb xmm6, xmm4               ; xmm6 = 0 ((U * 0.337633) + (V * 0.698001)) 0 0 0 ... parte 2

    ; la idea es poner los valores de xmm0 que contiene los valores de V por 1.370705 y U por 1.732446 en lugares apropiados

    movdqu xmm3, [Shuflle_UxVx_1]   ; shuffle para calcular R y B parte 1 xmm1
    movdqu xmm4, [Shuflle_UxVx_2]   ; shuffle para calcular R y B parte 2 xmm2
    
    movdqu xmm7, xmm0

    pshufb xmm7, xmm3               ; xmm3 = (V * 1.370705) 0 (U * 1.732446) 0 .... parte 1 xmm1
    pshufb xmm0, xmm4               ; xmm0 = (V * 1.370705) 0 (U * 1.732446) 0 .... parte 2 xmm2

    ; tenemos que sumar ahora 
    paddb xmm1, xmm7                ; xmm1 = (y1 + (V * 1.370705)) (y1 + 0) (y1 + (U * 1.732446)) 0 ... parte 1
    paddb xmm2, xmm0                ; xmm2 = (y5 + (V * 1.370705)) (y5 + 0) (y5 + (U * 1.732446)) 0 ... parte 2

    movdqu xmm7, [Mask_255]

    paddb xmm1, xmm7                ; xmm1 =  (y1 + (V * 1.370705)) (y1 + 0) (y1 + (U * 1.732446)) 255 ... parte 1
    paddb xmm2, xmm7                ; xmm2 =  (y5 + (V * 1.370705)) (y5 + 0) (y5 + (U * 1.732446)) 255 ... parte 2

    psubb xmm1, xmm5                ; xmm1 = (y1 + (V * 1.370705)) (y1 - (U * 0.337633) + (V * 0.698001)) (y1 + (U * 1.732446)) 255 ... parte 1
    psubb xmm2, xmm6                ; xmm2 = (y5 + (V * 1.370705)) (y5 - (U * 0.337633) + (V * 0.698001)) (y5 + (U * 1.732446)) 255 ... parte 2

    movdqu [rsi], xmm1              ; cargamos en memoria parte 1
    movdqu [rsi], xmm2              ; cargamos en memoria parte 2

    add rdi, 16         
    jmp ciclo

    fin:
    pop rbp
    ret







