
section .text

global dot_product_asm

; uint32_t dot_product_asm(uint16_t *p, uint16_t *q, uint32_t length);
; implementacion simd de producto punto
; se calcula componente a componente multiplicando 

dot_product_asm:
	; epilogo 
	push rbp
	mov rbp, rsp

	; tenemos los dos punteros enteros de 2 bytes
	; la length es multiplo de 8 
	; por tanto traemos de a 8 enteros del vector
	; long de ciclo en rcx
	mov rcx, rdx
	shr rcx, 3
	
	xor xmm3,xmm3

	.ciclo: 
	; metemos los primeros 8 enteros  de los vectores en los registros xmm
	movdqa xmm0, [rdi]
	movdqa xmm1, [rsi]

	; usamos xmm2 de tmp para la mult 
	movdqa xmm2, xmm0

	; parte baja de la mult
	pmullw xmm0, xmm1
	; parte alta de la mult
	pmulhw xmm2, xmm1 
 
	; xmm2 = | hi(a7*b7) ... hi(a0*b0) |
	; xmm0 = | low(a7*b7) ... low(a0*b0) |
	; es decir que no tenemos el espacio de la mult baja y
	; necesitamos reconstruir todo
	; nos alcanza un solo registro? NO
	; porque las partes altas ocupan dos bytes y las bajas tambien
	; dando como resultado un numero de 4 bytes o sea que en la reconstruccion tendremos un registro de 16 bytes con 4 valores de los 8 enteros iniciales
	; desde a0*b0 hasta a3*b3 y desde a4*b4 hasta a7*b7 

	; instruccion punpcklwd  
	; desempaqueta los datos empaquetados de dos registros en uno solo, y solo toma los elementos de menor orden de cada uno.
	; tmp
	movdqa xmm1, xmm0

	; |a0*b0 hasta a3*b3|
	punpcklwd xmm0, xmm2
	; |a4*b4 hasta a7*b7|
	punpckhwd xmm1, xmm2

	; nos interesa sumar ahora 
	; The HADDPS instruction performs a single precision addition on contiguous data elements
	; HADDPS OperandA, OperandB
	;	— OperandA (128 bits, four data elements): 3a, 2a, 1a, 0a
	;	— OperandB (128 bits, four data elements): 3b, 2b, 1b, 0b
	;	— Result (Stored in OperandA): 3b+2b, 1b+0b, 3a+2a, 1a+0a 

	haddps xmm0,xmm2
	addps xmm3,xmm0

	add rdi, 16
	add rsi, 16
	sub rcx, 8
	cmp rcx, 0
	je .fin
	jmp .ciclo

	.fin:
	movdqa xmm0, xmm3
	pop rbp
	ret
