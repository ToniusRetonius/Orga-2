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
	
	xor rax, rax
	mov eax, r8d
	mul r9d
	mov r10, rax				; r10 contiene la cantidad de iteraciones
	shr r10, 2					; procesamos de a 4 pixeles
; ----- mepa que falla la # iteraciones porque no termina de imprimir -------- 
	ciclo:
	cmp r10, 0
	je fin
	pmovzxbd xmm0, [rsi]		; pasamos de 4 pixeles de 1 byte cada uno a 4 pixeles de 4 bytes cada uno en xmm0

	; xmm0 = |127| | pixel 4 | pixel 3 | pixel 2 | pixel 1 | |0|

	; extendemos con ceros porque a priori son positivos

	cvtdq2ps xmm0, xmm0			; pasamos a single precision

	pxor xmm1, xmm1
	pxor xmm2, xmm2

; ------------ chequear en gdb si se inserta bien scale y offset --------------
	movdqu xmm1, xmm0
	pinsrd xmm2, edx, 0			; insertamos en la primer dword del xmm2 scale

	pshufd xmm2, xmm2, 0		; tenemos 4 dwords con el valor de scalar
	mulps xmm1, xmm2			; xmm1 = |127| | pixel 4 * scalar | pixel 3 * scalar | pixel 2 * scalar | pixel 1 * scalar | |0|

	cvtps2dq xmm1, xmm1			; volvemos a dword int
	pinsrd xmm2, ecx, 0			; insertamos en la primer dword del xmm2 ofsset
	pshufd xmm2, xmm2, 0		; tenemos 4 dwords con el valor de offset

	paddd xmm1, xmm2			; sumamos con el offset
	; xmm1 = |127| | pixel 4 * scalar | pixel 3 * scalar | pixel 2 * scalar | pixel 1 * scalar | |0|
	
	movdqu [rdi], xmm1

	add rdi, 4					; nos movemos 4 bytes en dst (creo que falla por aca)
	dec r10						; restamos una iteracion
	jmp ciclo

	fin:
	pop r12
	pop r13
	pop rbp
	ret
