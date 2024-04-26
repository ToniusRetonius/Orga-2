;########### ESTOS SON LOS OFFSETS Y TAMAÑO DE LOS STRUCTS
; Completar:
NODO_LENGTH	EQU	32 
LONGITUD_OFFSET	EQU 24	

PACKED_NODO_LENGTH	EQU	21
PACKED_LONGITUD_OFFSET	EQU	17

;########### SECCION DE DATOS
section .data

;########### SECCION DE TEXTO (PROGRAMA)
section .text

;########### LISTA DE FUNCIONES EXPORTADAS
global cantidad_total_de_elementos
global cantidad_total_de_elementos_packed

;########### DEFINICION DE FUNCIONES
;extern uint32_t cantidad_total_de_elementos(lista_t* lista);
;registros: lista[?]
cantidad_total_de_elementos:
	push rbp
	mov rbp, rsp

	; en rax me guardo la suma acumulada (comienza en 0)
	xor rax, rax 

	; en rdi tengo la dire de memoria en la que comienza el array
	cmp [rdi], rax
	je .fin_ciclo
	
	.ciclo:
	; cargo data de memoria en r8
	mov r8, [rdi]

	; condicion de ciclo (puntero distinto de null)
	; si la data cargada, es null (0)
	cmp r8, 0
	je .fin_ciclo 

	mov r9, [r8 + LONGITUD_OFFSET]
	
	; rax ++ 
	add rax, r9

	; salto al prox nodo
	mov rdi, r8

	; loopea
	jmp .ciclo

	.fin_ciclo:
	; restauro la pila

	pop rbp	
	ret

;extern uint32_t cantidad_total_de_elementos_packed(packed_lista_t* lista);
;registros: lista[?]
cantidad_total_de_elementos_packed:
	push rbp
	mov rbp, rsp

	; en rax me guardo la suma acumulada (comienza en 0)
	xor rax, rax 

	; en rdi tengo la dire de memoria en la que comienza el array
	cmp [rdi], rax
	je .fin_ciclo
	
	.ciclo:
	; cargo data de memoria en r8
	mov r8, [rdi]

	; condicion de ciclo (puntero distinto de null)
	; si la data cargada, es null (0)
	cmp r8, 0
	je .fin_ciclo 

	mov r9, [r8 + PACKED_LONGITUD_OFFSET]
	
	; rax ++ 
	add rax, r9

	; salto al prox nodo
	mov rdi, r8

	; loopea
	jmp .ciclo

	.fin_ciclo:
	; restauro la pila

	pop rbp	
	ret
