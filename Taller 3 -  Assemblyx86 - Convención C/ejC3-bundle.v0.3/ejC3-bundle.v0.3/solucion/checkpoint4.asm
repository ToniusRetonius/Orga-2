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

	xor rcx, rcx
	xor rax, rax
	cmp rcx, rdi
	je .fin

	.comparacion:
	; ambos null
	cmpvs rdi,rsi
	je .fin

	; a es null
	cmps rdi, 0
	jz .menor
	; b es null
	cmps rsi, 0
	jz .mayor

	mov r8, [rdi]
	mov r9, [rsi]
	CMPS r8,r9

	je .iguales
	jl .menor
	jg .mayor
	
	.iguales:
	; avanzar al sig char
	inc rdi
	inc rsi
	xor rax,rax
	jmp .comparacion

	.menor:
	mov rax, 1
	jmp .fin

	.mayor:
	mov rax, -1
	jmp .fin

	.fin:
	ret

; char* strClone(char* a)
strClone:
	; me guardo la compia del puntero
	mov rcx, rdi
	call strLen

	mov rdi, rax
	call malloc

	; rax ya tiene el puntero 
	mov rdx, rax
	.ciclo:
	movsb 
	

	ret

; void strDelete(char* a)
strDelete:
	CALL free
	ret

; void strPrint(char* a, FILE* pFile)
strPrint:

	ret

; uint32_t strLen(char* a)
strLen:
	; recibimos puntero a char RDI
	; mientras que la data de RDI sea != null, sumo
	push rbp
	sub rbp, rsp

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

