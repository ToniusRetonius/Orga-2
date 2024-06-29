section .data

section .text

; Marca un ejercicio como aún no completado (esto hace que no corran sus tests)
FALSE EQU 0
; Marca un ejercicio como hecho
TRUE  EQU 1

; Marca el ejercicio 2A como hecho (`true`) o pendiente (`false`).
;
; Funciones a implementar:
;   - ej2a
global EJERCICIO_2A_HECHO
EJERCICIO_2A_HECHO: db FALSE ; Cambiar por `TRUE` para correr los tests.

; Dada una imagen origen escribe en el destino `scale * px + offset` por cada
; píxel en la imagen.
;
; Parámetros:
;   - dst_depth: La imagen destino (mapa de profundidad). Está en escala de
;                grises a 32 bits con signo por canal.
;   - src_depth: La imagen origen (mapa de profundidad). Está en escala de
;                grises a 8 bits sin signo por canal.
;   - scale:     El factor de escala. Es un entero con signo de 32 bits.
;                Multiplica a cada pixel de la entrada.
;   - offset:    El factor de corrimiento. Es un entero con signo de 32 bits.
;                Se suma a todos los píxeles luego de escalarlos.
;   - width:     El ancho en píxeles de `src_depth` y `dst_depth`.
;   - height:    El alto en píxeles de `src_depth` y `dst_depth`.
global ej2a
ej2a:
	; Te recomendamos llenar una tablita acá con cada parámetro y su
	; ubicación según la convención de llamada. Prestá atención a qué
	; valores son de 64 bits y qué valores son de 32 bits.
	;
	; rdi = int32_t* dst_depth
	; rsi = uint8_t* src_depth
	; edx = int32_t  scale
	; ecx = int32_t  offset
	; r8d = int32      width
	; r9d = int32      height

	push rbp
	mov rbp, rsp

	push r12
	push r13

	; ------- cambie el mul porque me usaba volatiles y quedaba todo roto --
	xor r12, r12							
	xor r13, r13							
	
	mov r12d, r8d							
	mov r13d, r9d							
	
	imul r12, r13
	shr r12, 2					; procesamos de a 4 
	; -------------------------------------------------------------
	ciclo:
	cmp r12, 0
	je fin
	pmovzxbd xmm0, [rsi]		; pasamos de 4 pixeles de 1 byte cada uno a 4 pixeles de 4 bytes cada uno en xmm0

	; xmm0 = |127| | pixel 4 | pixel 3 | pixel 2 | pixel 1 | |0|

	; extendemos con ceros porque a priori son positivos

	;cvtdq2ps xmm0, xmm0			; pasamos a single precision (nos rompe todo esto)

	pxor xmm1, xmm1
	pxor xmm2, xmm2

	movdqu xmm1, xmm0
	pinsrd xmm2, edx, 0			; insertamos en la primer dword del xmm2 scale

	pshufd xmm2, xmm2, 0		; tenemos 4 dwords con el valor de scalar

	; usamos pmulld
	pmulld xmm1, xmm2			; xmm1 = |127| | pixel 4 * scalar | pixel 3 * scalar | pixel 2 * scalar | pixel 1 * scalar | |0|

	; falla cvtps2dq, pone todo en 0 ==> 
	; cvtps2dq xmm1, xmm1			; volvemos a dword int 
	pinsrd xmm2, ecx, 0			; insertamos en la primer dword del xmm2 ofsset
	pshufd xmm2, xmm2, 0		; tenemos 4 dwords con el valor de offset

	paddd xmm1, xmm2			; sumamos con el offset
	; xmm1 = |127| | pixel 4 * scalar | pixel 3 * scalar | pixel 2 * scalar | pixel 1 * scalar | |0|
	
	movdqu [rdi], xmm1

	add rdi, 16					; nos movemos 4 bytes en dst (creo que falla por aca) de a 4 pixeles de 4 bytes
	add rsi, 4
	dec r12						; restamos una iteracion
	jmp ciclo

	fin:
	; mal el epilogo 
	pop r13
	pop r12
	pop rbp
	ret

; Marca el ejercicio 2B como hecho (`true`) o pendiente (`false`).
;
; Funciones a implementar:
;   - ej2b
global EJERCICIO_2B_HECHO
EJERCICIO_2B_HECHO: db TRUE ; Cambiar por `TRUE` para correr los tests.

; Dadas dos imágenes de origen (`a` y `b`) en conjunto con sus mapas de
; profundidad escribe en el destino el pixel de menor profundidad por cada
; píxel de la imagen. En caso de empate se escribe el píxel de `b`.
;
; Parámetros:
;   - dst:     La imagen destino. Está a color (RGBA) en 8 bits sin signo por
;              canal.
;   - a:       La imagen origen A. Está a color (RGBA) en 8 bits sin signo por
;              canal.
;   - depth_a: El mapa de profundidad de A. Está en escala de grises a 32 bits
;              con signo por canal.
;   - b:       La imagen origen B. Está a color (RGBA) en 8 bits sin signo por
;              canal.
;   - depth_b: El mapa de profundidad de B. Está en escala de grises a 32 bits
;              con signo por canal.
;   - width:  El ancho en píxeles de todas las imágenes parámetro.
;   - height: El alto en píxeles de todas las imágenes parámetro.
global ej2b
ej2b:
	; Te recomendamos llenar una tablita acá con cada parámetro y su
	; ubicación según la convención de llamada. Prestá atención a qué
	; valores son de 64 bits y qué valores son de 32 bits.
	;
	; rdi = rgba_t*  dst
	; rsi = rgba_t*  a
	; rdx = int32_t* depth_a
	; rcx = rgba_t*  b
	; r8 = int32_t* depth_b
	; r9d = int32      width
	; pila = int 32     height

	push rbp
	mov rbp, rsp

	push r12
	push r13

	; ------ cambio de nuevo el mul porq rompe todo ----- 
	xor r12, r12
	xor r13, r13

	mov r12d, [rbp + 16]		; me traigo heigth
	imul r12d, r9d				; height x width
	shr r12, 2					; de a 4 procesamos
	; ------------------------------------------------
	cicle:
	cmp r12,0
	je final

	movdqu xmm0, [rsi]			; traemos 4 pixeles de la imagen A 127 | pixel 4 | pixel 3 | pixel 2 | pixel 1| 0
	movdqu xmm1, [rcx]			; traemos 4 pixeles de la imagen B 127 | pixel 4 | pixel 3 | pixel 2 | pixel 1| 0

	movdqu xmm2, [rdx]			; traemos 4 profundidades de la imagen A 127 | depth 4 | depth 3 | depth 2 | depth 1 | 0
	movdqu xmm3, [r8]			; traemos 4 profundidades de la imagen B 127 | depth 4 | depth 3 | depth 2 | depth 1 | 0

	movdqu xmm4, xmm3			; copia de las profundidades de B

	pcmpgtd	xmm4, xmm2			; xmm4 = mascara : comparo depth_a[y , x] < depth_b[y , x] es decir que obtengo 1 si los de A son menores
	
	movdqu xmm5, xmm0			; copia pixeles A
	movdqu xmm6, xmm1			; copia pixeles B

	pand xmm5, xmm4				; xmm5 = los pixeles de A que van a DST
	; ----------------------------------------------------- 
	pcmpeqd xmm7, xmm7			; xmm7 = mascara todo en 1
	pxor xmm4, xmm7				; xmm4 = inversa
	; -----------------------------------------------------
	;pandn xmm4, xmm4			; invertimos la mascara 

	pand xmm6, xmm4				; xmm6 = capturamos los pixeles de B que van a DST

	por xmm5, xmm6				; xmm5 = pixeles apropiados para escribir en DST

	movdqu [rdi], xmm5			; escritura

	add rsi, 16					; pasamos a los proximos 16 bytes de imagen A 
	add rcx, 16					; pasamos a los proximos 16 bytes de imagen B
	add rdx, 16					; proximas 4 profundidades de A 
	add r8, 16					; proximas 4 profundidades de B
	dec r12						; i-- 
	jmp cicle

	final:
	pop r13
	pop r12
	pop rbp
	ret
