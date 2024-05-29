
section .text

global four_of_a_kind_asm

.rodata:
quince: times 16 db 15
unos: times 4 dd 1
un: times 4 dd 1
; uint32_t four_of_a_kind_asm(card_t *hands, uint32_t n);

four_of_a_kind_asm:
	push rbp
	mov rbp, rsp ;OJO ,NO SE ME PISA EAX ?
	mov eax, 0 ;cant de manos que tienen 4 cartas de diferente palo pero mismo numero.

	;puedo suponer que n es multiplo de 4, osea que voy a poder tomar de a 4 manos
	shr esi, 2 ;divido la cantidad de manos por 4 ya que me voy a traer de a 4 manos
loop:
	cmp esi, 0
	je fin
	movdqu xmm0, [rdi] ;me traigo 16 cartas , osea 4 manos 
	movdqu xmm1, [quince]

	pand xmm0, xmm1   ;borra suit y quedate solo con value o shiftea a derecha cada byte 4 bits
	movdqu xmm1, xmm0 ;reutilizo a xmm1 para poner el xmm con los valores soolo
	movdqu xmm2, xmm0 ;uso a xmm2  y xmm3 para el xmm0 con solo value
	movdqu xmm3, xmm0
	;
	psrldq xmm1, 1
	pcmpeqb xmm0, xmm1 ;shifteo y comparo uno con uno. Tomando de comparacion al ultimo
	movdqu xmm5, [un]
	pand xmm0, xmm5
	;quiero aplicar una mascar a los valores que no me importan 
	
	psrldq xmm1, 1 
	pcmpeqb xmm2, xmm1
	pand xmm2, xmm5

	psrldq xmm1, 1
	pcmpeqb xmm3, xmm1
	pand xmm2, xmm5

	pand xmm0, xmm2  ;aplico el and entre los resultados de las comparaciones
	pand xmm0, xmm3 ;si todas dan entonces va a quedar 1 

	movdqu xmm5, [unos]
	
	pand xmm0, xmm5;antes de sumar tengo que aplicar una mascara para que todos los valores excepto el byte menos significativos queden como estaban osea un and 1

	pextrd edx, xmm0, 0
	add eax, edx

	pextrd edx, xmm0, 1
	add eax, edx 

	pextrd edx, xmm0, 2
	add eax, edx 

	pextrd edx, xmm0, 3
	add eax, edx	
	
	sub esi, 1 
	add rdi, 16
	jmp loop
fin:
	pop rbp
	ret
