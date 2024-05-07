section .data
mascara_value: times 16 db 0xF0						; máscara para filtar valor de palo
mascara_iguales: times 4 dd 0xFFFF  				; 16 bits en 1 para comparar igualdad de valores
shuffle: db 15,15,15,15,8,8,8,8,4,4,4,4,0,0,0,0  	; máscara shuffle 

%define NEXT_4_HANDS 16

section .text

global four_of_a_kind_asm
; uint32_t four_of_a_kind_c(card_t *hands, uint32_t n)
four_of_a_kind_asm:
	push rbp
	mov rbp, rsp

	xor eax, eax
	shr esi, 2										; # manos es mult de 4

	lectura:
	cmp esi, 0
	je fin
	xor ecx, ecx

	movdqu xmm0, [rdi]								; traigo a xmm0 las 4 manos
	movdqu xmm1, [mascara_value]					; cargo la máscara de valores
	pand xmm0, xmm1									; filtro los values de los palos
	movdqu xmm3, xmm0
	
	movdqu xmm2, [shuffle]							; cargo la máscara de shuffle en xmm2
	pshufb xmm3, xmm2								; modifico el orden de xmm0 y lo capturo en xmm3

	pcmpeqb xmm3, xmm0 								; comparo byte a byte

	movdqu xmm4, [mascara_value]					; cargo la máscara para saber si son iguales
	pcmpeqd xmm3, xmm4								; comparo de a 16 bits si son todos 1

	pextrd ecx, xmm3, 0	
	add eax, ecx
	pextrd ecx, xmm3, 1	
	add eax,ecx				
	pextrd ecx, xmm3, 2	
	add eax, ecx
	pextrd ecx, xmm3, 3	
	add eax,ecx	

	sub esi, 1
	add rdi, NEXT_4_HANDS
	jmp lectura

	fin:
	pop rbp
	ret

