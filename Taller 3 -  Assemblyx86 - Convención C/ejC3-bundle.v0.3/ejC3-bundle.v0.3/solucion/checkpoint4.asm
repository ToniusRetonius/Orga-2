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
	sub rbp, rsp

	xor rax, rax

	.comparacion:

	; el reg cl es de 8 bits
	mov cl, byte[rsi]
	cmp byte[rdi], cl
	jg .mayor
	jl .menor

	cmp byte[rdi], 0
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
	sub rbp, rsp

	; el puntero es valido
	; la cadena puede ser vacia
	; me guardo la copia del puntero al str en rcx
	mov rcx, rdi

	; llamo a len para saber cuanto espacio pedir
	call strLen

	; si es la cadena vacia
	cmp rax,0 
	je .null
	; si no
	mov r8, rax
	; que pasa con la pila? 

	; le pedimos a malloc memoria para len de str
	; nos da el puntero de res
	; en r8 tengo la len por tanto, le paso a malloc eso
	mov rdi, r8
	call malloc
	
	mov r9, rax
	; en rax tengo el puntero al espacio libre
	; tengo que llenar ese espacio ahora
	; while r8 >= 0  ... guardo de a byte en memoria 
	; de donde saco el dato?  del puntero en rcx
	; rcx + r8 (pos vieja)
	; r9 + r8 (pos nueva)
	
	.ciclo: 
	cmp r8,0 
	je .fin

	mov cl, byte[rcx + r8]
	mov byte[r9 + r8], cl

	add r8,-1
	jmp .ciclo

	.null:
	xor rax,rax

	.fin:
	; rax ni lo tocamos
	
	pop rbp
	ret
; void strDelete(char* a)
strDelete:
	push rbp
	sub rbp, rsp
	
	CALL free
	
	pop rbp
	ret


; void strPrint(char* a, FILE* pFile)
strPrint:
	push rbp
	sub rbp, rsp
	
	; little endian
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

