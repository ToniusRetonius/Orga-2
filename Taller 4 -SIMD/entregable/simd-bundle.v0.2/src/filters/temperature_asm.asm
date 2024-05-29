global temperature_asm

section .data
borrarA times 4 dd 0x00111111
borrarRyB times 4 dd 0x00110011
borrarAyG times 4 dd 0x00110011
ceros times 4 dd 0x00000000
mascara db 0xFF,0xff,0xff,14,0xff,0xff,0xFF,12,0xff,0xff,0xFF,10 ,0xff,0xFF,0xFF,8
tres times 4 dd 3

mask_128 db 0,0,0,128,0,0,0,128,0,0,0,128,0,0,0,128
mask_96 db 0,0,0,96,0,0,0,96,0,0,0,96,0,0,0,96
mask_255  db 0,0,0,-255,0,0,0,-255,0,0,0,-255,0,0,0,-255
tresdos times 4 dd 32
section .text
;rdi contiene un puntero a la imagen a src
;rsi contiene un puntero a la imagen dst
;te lo traes en formato abgr
;en edx tengo el ancho
;en ecx tengo el largo
;en r8d tengo el offset para pasr a la miisma columna pero en la siguiente fila de src
;en r9d lo mismo pero de dst
;void temperature_asm(unsigned char *src,
;              unsigned char *dst,
;              int width,
;              int height,
;              int src_row_size,
;              int dst_row_size);

temperature_asm:
    push rbp
    mov rbp, rsp

    movdqu xmm0, [rdi] ;me traigo de memoria 4 pixeles
    pand xmm0, [borrarA] ;borro A
    movdqu xmm1, xmm0 ;copio a xmm1 
    pslldq xmm1, 1 ;shifteo a izq
    pand xmm0, [borrarRyB] ;borra r y b de xmm0
    pand xmm1, [borrarAyG] ;borra a y g de xmm1
    paddb xmm0, xmm1 ;suma a byte
    movdqu xmm1, [ceros] ;copialo
    phaddw xmm0, xmm1 ;t lo tengo todo en la parte alta 
    ;muevo t con un shuffle
    
    pshufb xmm0, [mascara]
    CVTDQ2PS xmm0, xmm0
    DIVPS xmm0, [tres] 
    cvttps2dq xmm0, xmm0

    pxor xmm1, xmm1
    pxor xmm2, xmm2
    pxor xmm3, xmm3
    pxor xmm4, xmm4
    pxor xmm5, xmm5
    pxor xmm6, xmm6
    pxor xmm7, xmm7
    pxor xmm8, xmm8
    pxor xmm9, xmm9
    pxor xmm10, xmm10

    
    ; en xmm1 guardamos los valores para t < 32 
    movdqu xmm1, xmm0
    paddusb xmm1,xmm1
    paddusb xmm1,xmm1
    paddusb xmm1,xmm1
    paddusb xmm1,xmm1           ; t · 4
    movdqu xmm2, [mask_128]     ; 128 + t · 4
    paddb xmm1, xmm2
    psrld xmm1, 8               ; < 0, 0, 128 + t · 4, 0 >

    
    
    ;segundo caso 32<=t < 96
    ;en xmm3 me traigo el xmm0
    movdqu xmm3, xmm0
    PSUBSB xmm3, [tresdos] ;le
    PADDUSB xmm3, xmm3
    PADDUSB xmm3, xmm3
    PADDUSB xmm3, xmm3
    PADDUSB xmm3, xmm3 ;ya lo reste y 

    
    ; en xmm5 guardamos los valores de  96 <= t < 160
    ; < (t − 96) · 4 , 255 , 255 − (t − 96) · 4 >
    movdqu xmm2, xmm0
    movdqu xmm5, [mask_96]
    
    psubusb xmm2, xmm5          ; < 0, 0, 0, (t − 96) >
    
    paddusb xmm2,xmm2
    paddusb xmm2,xmm2
    paddusb xmm2,xmm2
    paddusb xmm2,xmm2           ; < 0, 0, 0, (t − 96) · 4 >
    
    movdqu xmm6, xmm2
    psrld xmm6, 16              ; < 0, (t − 96) · 4 , 0 , 0 >
    
    paddusb xmm2,xmm6           ; < 0, (t − 96) · 4 , 0 , (t − 96) · 4 >
    
    movdqu xmm5, [mask_255]
    paddusb xmm2, xmm5          ;   

    


    pop rbp
    ret
