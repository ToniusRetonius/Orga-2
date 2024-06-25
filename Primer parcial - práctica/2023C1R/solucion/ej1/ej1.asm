global acumuladoPorCliente_asm
global en_blacklist_asm
global blacklistComercios_asm

extern calloc
extern strcmp
extern CantEnBlacklist

section .data

; PAGO
%define MONTO 0
%define COMERCIO 8
%define CLIENTE 16
%define APROBADO 17
%define TAM_PAGO 24

; ARREGLO_PUNTEROS
%define SIG_PUNTERO 8
;########### SECCION DE TEXTO (PROGRAMA)
section .text

; cantidadDePagos [dil], pago_t* [rsi]
acumuladoPorCliente_asm:
	push rbp
	mov rbp, rsp
	push r12
	push r13


	xor r12, r12
	xor r13, r13

	mov r12b, dil					; # pagos
	mov r13, rsi					; pago_t* puntero al array

	mov rdi, r12					; cantidadDePagos
	mov rsi, 32						; sizeof(uint32_t)
	call calloc						; ya tenemos en rax el puntero a res

	xor rcx, rcx					; i = 0
	xor r10, r10					
	mov r10, rax					; r10 = res

	ciclo:
	cmp rcx, r12
	je fin
	
	xor rdx, rdx
	xor r8, r8
	
	mov dl, [r13 + CLIENTE]	; capturamos el id_cliente

	mov r8b, [r13 + APROBADO]	; esta aprobado?
	cmp r8, 0						; 0 = desaprobado
	je siguiente

	; si esta aprobado
	
	xor rax, rax
	mov eax, 4
	mul edx							; HAY QUE MOVERSE 32BITS X NRO CLIENTE pues es el offset de res[i]

	xor r9, r9
	mov r9d, [r10d + eax]			; r9d = res[id_cliente] (32 bits)

	xor r11, r11
	mov r11b, [r13 + MONTO]			; r11 = monto del pago actual (monto int8)

	add r9, r11						; res[cliente] + arr_pagos[i].monto;

	mov [r10 + rax], r9d  			; res[cliente] =+ arr_pagos[i].monto; (es de 32 el dato)


	siguiente:
	add r13, TAM_PAGO
	inc rcx
	jmp ciclo

	fin:
	mov rax, r10
	pop r13
	pop r12
	pop rbp
	ret
; ------------------ pasa el test -------------

; comercio(char*)[rdi], lista_comercios (char**) [rsi], lista_c_len[dl]
en_blacklist_asm:
	push rbp
	mov rbp, rsp

	push r12
	push r13
	push r14
	push r15

	mov r12, rdi			; r12 = comercio
	mov r13, rsi			; r13 = lista de comercios
	xor r14, r14
	mov r14b, dl 			; r14b = int8 len de r13
	xor r15, r15			; r15 = i = 0

	loop:
	cmp r15, r14
	xor rax, rax			; mantenemos rax en 0 si no lo encuentra en la blist
	je final

	mov rdi, [r13]			; traemos el char* ( = el comercio de la lista)
	mov rsi, r12			; ponemos el comercio en cuestion
	call strcmp				; comparamos strings
	cmp rax, 0
	jne sig

	mov rax, 1
	jmp final


	sig:
	add r13, 8				; como el puntero es de 8 bytes, pasamos al siguiente	
	inc r15
	jmp loop


	final:
	pop r15
	pop r14
	pop r13
	pop r12
	pop rbp
	ret

; arr_pagos.size [dil], arr_pagos [rsi], arr_comercios [rdx], arr_comercios.size[cl]
blacklistComercios_asm:
	push rbp
	mov rbp, rsp
	push r12
	push r13
	push r14
	push r15
	push rbx
	sub rsp, 8
	; esta desalineada pero planeo alinearla en el ciclo 

	xor r12, r12
	mov r12b, dil				; r12b = arreglo_pagos.size
	mov r13, rsi				; r13 = arreglo_pagos
	mov r14, rdx				; r14 = arreglo_comercios
	xor r15, r15				
	mov r15b, cl				; r15b = arreglo_comercios.size


	call CantEnBlacklist		; usamos una aux en c llamada #en_blacklist para pedir # elementos
	xor rdi, rdi
	mov dil, al
	mov rsi, 8
	call calloc					; res = arreglo_de_*pagos

	xor rbx, rbx				
	mov rbx, rax				; rbx = rax

	; para el ciclo, usamos la fn en_blacklist_asm para determinar si esta
	; si esta => sumamos el pago a res, sino siguiente 	
	
	cicle:
	cmp r12, 0
	je fin_

	mov rdi, [r13 + COMERCIO]	; pasamos primero el comercio_pago
	mov rsi, r14				; pasamos luego arr_comercios
	xor rdx, rdx
	mov dl, r15b				; pasamos el size del arr_comercios
	call en_blacklist_asm
	cmp al, 0
	je next

	mov [rbx], r13
	add rbx, SIG_PUNTERO

	next:
	sub r12, 1					; i--
	add r13, TAM_PAGO			; siguiente pago
	jmp cicle

	fin_:
	mov rax, rbx
	add rsp, 8
	pop rbx
	pop r15
	pop r14
	pop r13
	pop r12
	pop rbp
	ret
