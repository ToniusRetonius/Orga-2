
section .text

;section .rodata:
;primero: db 0
;segundo: db 1
;tercero: db 2
;cuarto: db 3
global dot_product_asm

; uint32_t dot_product_asm(uint16_t *p, uint16_t *q, uint32_t length);
; implementacion simd de producto punto

dot_product_asm:
	push rbp
	mov rbp, rsp

	shr rdx, 3
	mov eax, 0

loop1:
	cmp rdx, 0
	je fin
	movdqu xmm0, [rdi]
	movdqu xmm1, [rsi]
	movdqu xmm2, xmm0
	movdqu xmm3, xmm1

	pmulhuw xmm0, xmm1 
	pmullw xmm2, xmm3 ;multiplicalosx

	movdqu xmm4, xmm2
	punpckhwd xmm2, xmm0
	punpcklwd xmm4, xmm0

	phaddd xmm2, xmm4
	
	xor rcx, rcx

	extractps ecx, xmm2 , 0
	add eax, ecx 

	extractps ecx, xmm2 , 1
	add eax, ecx 

	extractps ecx, xmm2 , 2
	add eax, ecx 

	extractps ecx, xmm2 , 3
	add eax, ecx 
	
	sub rdx, 1 
	add rdi, 16
	add rsi, 16
	add r8, 32
	jmp loop1
	;guardalos respectivamente
fin:
	pop rbp
	ret