global YUYV_to_RGBA

section .data
%define R 1.370705
%define G1 0.698001
%define G2 0.337633
%define B 1.732446


mask_shuffle_1 db 0,3,1,0xFF, 2, 3, 1,0xFF, 4,7,5, 0xFF, 6,7,5, 0xFF
mask_shuffle_2 db 8,11,9, 0xFF, 10,11,9 0xFF, 12,15,13, 0xFF, 14,15,13, 0xFF  

mask_u_v times 4 db 0,128,128,0
mask_filter times 4 db 0xFF,0xFF,0xFF,0

mask_A times 4 db 0,0,0,255

; pixel destino con valores de U y V son de 127 (0x7F) simultáneamente. RGBA(127,255,0,255)
;########### SECCION DE TEXTO (PROGRAMA)
section .text

;void YUYV_to_RGBA( int8_t *X, uint8_t *Y, uint32_t width, uint32_t height);
YUYV_to_RGBA:

    push rbp
    mov rbp, rsp

    ; rdi tiene el puntero a la imagen en YUYV
    ; rsi tiene el puntero a la imagen en RGBA que tenemos que devolver

    movdqu xmm0, [rdi]              ; me traigo la imagen en formato YUYV
    movdqu xmm4, xmm0               ; lo copio pues los datos altos los proceso en paralelo
    
    movdqu xmm1, [mask_shuffle_1]   ; me traigo la mask del mask_shuffle_1
    pshufb xmm0, xmm1               ; ordenados y1 v u y2 v u ... son 4 pixeles en total 
    
    movdqu xmm5, [mask_shuffle_2]   ; me traigo la mask del mask_shuffle_2
    pshufb xmm4, xmm5               ; queda ordenada la parte alta del xmm0 son los 4 pixeles restantes

    movdqu xmm2, [mask_filter]
    pand xmm0,xmm2                  ; los que estan en las pos xFF los hacemos 0
    pand xmm4, xmm2                 ; anàlogo

    movdqu xmm3, [mask_u_v]         ; operaciòn de resta U = U - 128 y V = V - 128 



    pop rbp
    ret

    ; mi idea en este ejercicio es en paralelo realizar la conversiòn a RGBA de todos los pìxeles que 
    ; me permite traer xmm0 al principio: 8 pìxeles. Por sugerencia se separa cada uno en Y1 V U Y2 V U 
    ; esta sepaciòn me lleva a ocupar màs espacio y por ello tomo xmm4 para la otra mitad
    ; esta divisiòn coherente la puedo realizar gracias a las màscaras de mask_shuffle_1 y mask_shuffle_2 
    ; se realiza y pand para poner el 4to byte del pixel en 0 por comodidad
    ; la idea es restarle los 128 a cada valor de U y V con otra màscara llamada mask_u_v
    ; luego tenemos limpios los valores, listos para procesar
    ; la idea es a cada pixel procesado (4 bytes) aplicarle una màscara de manera que 
    ; byte 0 = R  = 1.370705 x V
    ; byte 1 = G  = como es resta queda para el final, pero acumula la suma apropiada que desp se hace sub
    ; byte 2 = B  = 1.732446 x V
    ; byte 3 = A  = 255 
    ; còmo obtenemos V y U para las multiplicaciones? con EXTRACT en un reg /m8 
    