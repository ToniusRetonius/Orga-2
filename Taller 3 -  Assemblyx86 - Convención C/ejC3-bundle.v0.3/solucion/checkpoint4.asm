extern malloc
extern free
extern fprintf

section .data

section .text

global strCmp
global strClone
global strDelete
global strPrint
global strLen

; ** String **

; int32_t strCmp(char* a, char* b)
strCmp:
	; ret 0 si a = b
	; ret 1 si a < b
	; ret -1 si a > b
	
	; el orden lexicografico nos dice que para todo (a,b) pert a A y (a',b') pert B
	; se cumple que (a,b) < (a',b') sii a < a' o (a == a' y b < b')
	; podemos definir recursivamente la comparacion
	; traemos el caracter
	push rbp
	mov rbp, rsp
	xor rax, rax

	.comparacion:

	; el reg cl es de 8 bits
	; comparo char vs char
	mov cl, byte[rsi]
	cmp byte[rdi], cl
	jg .mayor
	jl .menor

	; si ambos son iguales y llegan hasta acá es porq son lo mismo
	cmp byte[rdi], 0x00
	je .fin

	; avanzar al sig char
	inc rdi
	inc rsi
	jmp .comparacion

	.menor:
	mov rax, 1
	jmp .fin

	.mayor:
	mov rax, -1
	jmp .fin

	.fin:
	pop rbp
	ret


; char* strClone(char* a)
strClone:
	push rbp
	mov rbp, rsp
	
	; guardamos el puntero en la pila
	push rdi
	; alineamos
	sub rsp, 0x8
	; necesitamos la len para saber cuánta data pedir
	call strLen
	; necesitamos guardarnos el char null
	inc rax
	; pusheamos esa data a la pila
	push rax
	; alineamos
	sub rsp, 0x8

	; pedimos memoria
	mov rdi, rax
	call malloc
	
	; guardamos el puntero q nos da malloc
	mov r8, rax
	mov rdi, rax

	; nos traemos la data de longitud y la guardamos en rcx
	add rsp, 0x8
	pop rcx
	; nos traemos la dire de a y la guardamos en rcx
	add rsp, 0x8
	pop rdx

	.ciclo:
	; voy guardando byte a byte
	mov al, byte[rdx]
	mov byte[rdi], al
	inc rdx
	inc rdi
	loop .ciclo

	; devolvemos el puntero
	mov rax, r8
	pop rbp
	ret

; void strDelete(char* a)
strDelete:
	push rbp
	mov rbp, rsp

	call free

	pop rbp
	ret

; void strPrint(char* a, FILE* pFile)
; int fprintf(FILE *stream, const char *format-string, argument-list);
strPrint:
	push rbp
	mov rbp, rsp

	; tenemos que pasarle al revés los parám a la función
	mov rcx, rdi
    mov rdi, rsi
    mov rsi, rcx

    call fprintf
	
	pop rbp
	ret

; uint32_t strLen(char* a)
strLen:
	; recibimos puntero a char RDI
	; mientras que la data de RDI sea != null, sumo
	push rbp
	mov rbp, rsp

	; en rax me guardo la suma acumulada (comienza en 0)
	xor rax, rax 

	; en rdi tengo la dire de memoria en la que comienza el str
	cmp byte [rdi], 0
	je .fin_ciclo
	
	.ciclo:
	; cargo data de memoria en r8
	movzx r8, byte [rdi]

	; condicion de ciclo (puntero distinto de null)
	; si la data cargada, es null (0)
	cmp r8, 0
	je .fin_ciclo 
	; rax ++ 
	inc rax
	; salto al prox char
	inc rdi 
	; loopea
	jmp .ciclo
	
	.fin_ciclo:
	; restauro la pila
	pop rbp	
	ret

