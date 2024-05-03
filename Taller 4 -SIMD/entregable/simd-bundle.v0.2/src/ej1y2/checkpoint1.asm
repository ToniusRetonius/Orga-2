
section .text

global dot_product_asm

; uint32_t dot_product_asm(uint16_t *p, uint16_t *q, uint32_t length);
; implementacion simd de producto punto
; se calcula componente a componente multiplicando 

dot_product_asm:
	; epilogo 
	push rbp
	mov rbp, rsp
	; rdi = puntero p
	; rsi = puntero q
	; rdx = length mod (8) = 0 

	shr rdx, 3

	ciclo: 
	cmp rdx, 0
	je fin
	
	mov xmm0, qword[rdi]
	mov xmm1, qword[rsi]

	mov xmm2, xmm0

	; multiplica packed y hace el store low
	pmullw xmm0, xmm1
	; en xmm0 tenemos la multiplicacion de los low 
	pmullw xmm1, xmm2
	; en xmm1 tenemos la multiplicacion de los high 
	
	; unificamos 
	

	add rdx, -1 
	add rdi, 16
	add rsi, 16
	jmp ciclo
	
	fin:
	pop rbp
	ret
