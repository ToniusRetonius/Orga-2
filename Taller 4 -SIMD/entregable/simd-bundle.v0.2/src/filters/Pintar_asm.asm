section .data
zeros times 3 db 0
blanco times 4 dd 0xFFFFFFFF
negro times 4 dd 0xFF000000
negroIzq dd 0xFF000000, 0xFF000000 , 0xFFFFFFFF, 0xFFFFFFFF
negroIzqBytes db 0x00, 0x00, 0x00, 0xFF, 0x00, 0x00, 0x00, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF

negroDer dd 0xFFFFFFFF, 0xFFFFFFFF, 0xFF000000, 0xFF000000 

section .text
global Pintar_asm

;void Pintar_asm(unsigned char *src,
;              unsigned char *dst,
;              int width,
;              int height,
;              int src_row_size,
;              int dst_row_size);


;rdi contiene un puntero char de 8 bytes a src
;rsi contiene un puntero char de 8 bytes a dst
;edx  contiene width osea el ancho
;ecx contiene el alto
;r8d  contiene cuanto hay que offsetear para pasar a la misma columna de la fila anterior o siguiente del src
;r9d  contiene cuanto hay que offsetear para pasar a la misma columna de la fila anterior o siguiente del dst
;disp: r13 
;nodisp: r12 contiene el contados
Pintar_asm:
	push rbp
	mov rbp, rsp

	push r12
	push r13
	push r14
	push r15

	xor r15, r15
	xor r14, r14
	xor r13, r13
	xor r12, r12

;convierto el r9d en un entero de 64 bit
	xor r8, r8
	mov r8d, r9d

	mov r9, r8
;
	mov r14, rsi ;muevo el inicio de dst a r14

	mov r12d, edx
	mov r13d, ecx 

	imul r12, r13 ;ahora en r12 tengo el alto x ancho
	shr r12, 2 ;divido por 4
;pinta todo de blanco
.loop:
	cmp r12, 0
	je .ponerPri2filasEnNegro
	
	movdqu xmm0, [blanco]
	movdqu [rsi], xmm0
	add rsi, 16 ;quiero pasar a los siguientes 4 pixeles. Osea a los sigueintes 16 bytes 
	sub r12, 1
	jmp .loop

.ponerPri2filasEnNegro:
	xor r8, r8
	mov r8d, edx
	shr r8, 1 ;quiero dividir por 4(por los pixeles) y quiero multiplicar por 2 (dosfilas)
	cmp r8, 0
	je .ponerBordesEnMedio

	movdqu xmm0, [negro]
	movdqu [r14], xmm0
	add r14, r9 
	movdqu [r14], xmm0

	sub r8, 1
	jmp .ponerPri2filasEnNegro
jmp finkk
.ponerBordesEnMedio:
	movdqu xmm1, [negroIzq]
	movdqu xmm2, [negroDer]
	sub r13, 4
.loopM:
	cmp r13, 0 ;necesito uno para iterar altura menos 4 veces
	je .ponerUl2filasEnNegro

	movdqu [r14], xmm1 ;pongo la primera fila

	xor r8, r8
	mov r8d, edx  ;movele el ancho que esta en pixeles. 
	sub r8, 1 ;restale uno para moverte a la ultima
	shr r8, 2 ;multiplico por 4 porque es ne bytes
	movdqu [r14 + r8], xmm2
	
	sub r13, 1
	add r14, r9;pasa al sig 
	jmp .loopM

.ponerUl2filasEnNegro:
	;se supone que r14 esta parado en la ultima
	movdqu [r14], xmm0
	movdqu [r14+ r9], xmm0

	finkk:
	pop r15
	pop r14
	pop r13
	pop r12

	pop rbp
	ret
	

