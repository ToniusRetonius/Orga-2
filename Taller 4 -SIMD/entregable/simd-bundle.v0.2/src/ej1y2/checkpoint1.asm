section .data
%define OFFSET 16

section .text

global dot_product_asm


dot_product_asm:
	push rbp
	mov rbp, rsp

	xor eax,eax
	shr edx, 3				; dividimos por 8 a length

	lectura:
	cmp edx, 0				; condición de ciclo
	je fin

	xor ecx,ecx

	movdqu xmm0, [rsi]		; lectura de 128 bits unaligned del puntero a p
	movdqu xmm1, [rdi]		; lectura de 128 bits unaligned del puntero a q
	movdqu xmm2, xmm0		; tmp p 
	
	pmulhuw xmm0, xmm1 		; mult xmm0, xmm2 guardo en xmm0 las partes high 
	pmullw xmm1, xmm2   	; mult xmm2 (= old(xmm0)) guardo en xmm1 partes low

	movdqu xmm2, xmm1   	; tmp (= xmm0) partes low

	; el problema que tuve : cuando hacemos el unpack los valores del reg dst tienen que ser LOW (pues quedan y addicionan el high a izq) 

	punpcklwd xmm2, xmm0	; en xmm0 [a7xb7 : a4xb4] 
	punpckhwd xmm1, xmm0	; en xmm1 [a3xb3 : a0xb0] 

	phaddd xmm2,xmm1 		; suma xmm0, xmm1 los packed double words horizontalmente xmm0 =  (a7xb7 + a6xb6) (a5xb5 + a4xb4) (a3xb3 + a2xb2) (a1xb1 + a0xb0)
	
	extractps ecx, xmm2, 0	; me traigo la suma de (a1xb1 + a0xb0)
	add eax, ecx
	extractps ecx, xmm2, 1	; me traigo la suma de (a3xb3 + a2xb2)
	add eax,ecx				
	extractps ecx, xmm2, 2	; me traigo la suma de (a5xb5 + a4xb4)
	add eax, ecx
	extractps ecx, xmm2, 3	; me traigo la suma de (a7xb7 + a6xb6)
	add eax,ecx				

	sub edx, 1				; length - 1
	add rsi, OFFSET
	add rdi, OFFSET

	jmp lectura

	fin:
	pop rbp
	ret
