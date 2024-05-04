
section .text

global dot_product_asm

; uint32_t dot_product_asm(uint16_t *p, uint16_t *q, uint32_t length);
; implementacion simd de producto punto
; se calcula componente a componente multiplicando 
; la length es multiplo de 8 

dot_product_asm:
	push rbp
	mov rbp, rsp

	shr rdx, 3 				; long de ciclo en rcx
	xor rax, rax

	ciclo: 
	cmp edx, 0
	je fin
	xor ecx, ecx
	
	movdqu xmm0, [rdi]		; los primeros 8 componentes vector p
	movdqu xmm1, [rsi]		; los primeros 8 componentes vector q
	movups xmm2, xmm0  		; tmp 

	pmullw xmm0, xmm1 		; parte baja de la mult :: xmm0 = | low(a7*b7) ... low(a0*b0) |
	pmulhw xmm2, xmm1  		; parte alta de la mult ::  xmm2 = | hi(a7*b7) ... hi(a0*b0) |
 
	; las partes altas ocupan dos bytes y las bajas tambien
	; dando como resultado un numero de 4 bytes o sea que en la reconstruccion 
	; tendremos un registro de 16 bytes con 4 valores de los 8 enteros iniciales

	movdqu xmm1, xmm0		; tmp
	punpcklwd xmm2, xmm0 	; xmm0 = |a0*b0 hasta a3*b3|
	punpckhwd xmm2, xmm1 	; xmm1 = |a4*b4 hasta a7*b7|

	phaddd xmm1, xmm0 		; horizontal add 32bit int xmm0 = | (a0*b0 + a1*b1) (a2*b2 + a3*b3) (a4*b4 + a5*b5) (a6*b6 + a7*b7) |
	phaddd xmm0,xmm0		;  xmm0 = | (a0*b0 + a1*b1 + a2*b2 + a3*b3) (a4*b4 + a5*b5 + a6*b6 + a7*b7) (a0*b0 + a1*b1 + a2*b2 + a3*b3) (a4*b4 + a5*b5 + a6*b6 + a7*b7) |
	phaddd xmm0,xmm0		;  xmm0 = | (a0*b0 + a1*b1 + a2*b2 + a3*b3 + a4*b4 + a5*b5 + a6*b6 + a7*b7) ...  (a0*b0 + a1*b1 + a2*b2 + a3*b3 + a4*b4 + a5*b5 + a6*b6 + a7*b7) |
	
	movd ecx, xmm0			; eax = (a0*b0 + a1*b1 + a2*b2 + a3*b3 + a4*b4 + a5*b5 + a6*b6 + a7*b7)
	add eax, ecx
	
	add rdi, 16 		
	add rsi, 16
	add rdx, -1
	jmp ciclo

	fin:
	pop rbp
	ret
