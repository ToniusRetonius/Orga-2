extern sumar_c
extern restar_c
;########### SECCION DE DATOS
section .data
 

;########### SECCION DE TEXTO (PROGRAMA)
section .text

;########### LISTA DE FUNCIONES EXPORTADAS

global alternate_sum_4
global alternate_sum_4_simplified
global alternate_sum_8
global product_2_f
global product_9_f
global alternate_sum_4_using_c

;########### DEFINICION DE FUNCIONES
; uint32_t alternate_sum_4(uint32_t x1, uint32_t x2, uint32_t x3, uint32_t x4);
; registros: x1[?], x2[?], x3[?], x4[?]
alternate_sum_4:
	; prologo
	push rbp 
	mov rbp, rsp

	mov rax, rdi
	sub rax, rsi
	add rax, rdx
	sub rax, rcx

	;epilogo
	pop rbp
	ret

; uint32_t alternate_sum_4_using_c(uint32_t x1, uint32_t x2, uint32_t x3, uint32_t x4);
; registros: x1[rdi], x2[rsi], x3[rdx], x4[rcx]
alternate_sum_4_using_c:
	;prologo
	push rbp 
	mov rbp, rsp
	; me guardo los valores de los no volatiles
	push rbx
	push r12
	push r13

	; nos guardamos antes del call en los registros no volatiles rbx r12
	; esto es para que al llamar al call, si la funcion modifica los volatiles, no me pise los valores 
	mov rbx, rdx
	mov r12, rcx

	; restamos x1 y x2 
	call restar_c 
	mov r13, rax

	mov rdi, rbx
	mov rsi, r12
	; restamos x3 y x4
	call restar_c

	mov rdi, rax
	mov rsi, r13
	; sumamos las restas
	call sumar_c

	;epilogo
	pop r13
	pop r12
	pop rbx
	pop rbp
	ret 

; uint32_t alternate_sum_4_simplified(uint32_t x1, uint32_t x2, uint32_t x3, uint32_t x4);
; registros: x1[?], x2[?], x3[?], x4[?]
alternate_sum_4_simplified:
	; devuelve el resultado la operación x1 - x2 + x3 - x4. Esta función no crea ni el epílogo ni el prólogo
	mov rax, rdi
    sub rax, rsi
    add rax, rdx
    sub rax, rcx
	ret


; uint32_t alternate_sum_8(uint32_t x1, uint32_t x2, uint32_t x3, uint32_t x4, uint32_t x5, uint32_t x6, uint32_t x7, uint32_t x8);
; registros y pila: x1[?], x2[?], x3[?], x4[?], x5[?], x6[?], x7[?], x8[?]
alternate_sum_8:
	;prologo
	push rbp 
	mov rbp, rsp

	; seteamos rax en 0
	xor rax, rax

	; restas
	sub rdi,rsi
	sub rdx,rcx
	sub r8,r9

	; me traigo de la pila x7 y x8
	; el offset es 0x10 y 0x18 porq en 0x08 tenemos el RIP
 	mov rcx, [rbp + 0x10 ]
	mov r9, [rbp + 0x18 ]

	; resta 
	sub rcx, r9

	add rdi, rdx
	add rdi, r8
	add rdi, rcx

	mov rax, rdi
	 

	;epilogo
	; tengo que restaurar el valor del rbp que pushee en primer lugar?
	pop rbp
	ret


; SUGERENCIA: investigar uso de instrucciones para convertir enteros a floats y viceversa
;void product_2_f(uint32_t * destination, uint32_t x1, float f1);
;registros: destination[?], x1[?], f1[?]
product_2_f:
	; lo convierto a float 
	cvtsi2sd xmm1, rsi
	cvtss2sd xmm0, xmm0

	; operacion multiplicar
	mulsd xmm0,xmm1	
	; guardo la op. en destinantion
	; convierto a int de nuevo porq se trata de un puntero a uint32_t
	; lo devuelve truncado
	cvttsd2si rax, xmm0

	; uso un move para enteros y guardo en memoria 
	mov [rdi], eax

	ret

;extern void product_9_f(uint32_t * destination
;, uint32_t x1, float f1, uint32_t x2, float f2, uint32_t x3, float f3, uint32_t x4, float f4
;, uint32_t x5, float f5, uint32_t x6, float f6, uint32_t x7, float f7, uint32_t x8, float f8
;, uint32_t x9, float f9);
;registros y pila: destination[rdi], x1[rsi], f1[xmm0], x2[rdx], f2[xmm1], x3[rcx], f3[xmm2], x4[r8], f4[xmm3]
;	, x5[r9], f5[xmm4], x6[pila], f6[xmm5], x7[pila], f7[xmm6], x8[pila], f8[xmm7],
;	, x9[pila], f9[pila]
product_9_f:
product_9_f:
	;prologo
	push rbp
	mov rbp, rsp

	;convertimos los flotantes de cada registro xmm en double
	cvtss2sd xmm0, xmm0
	cvtss2sd xmm1, xmm1
	cvtss2sd xmm2, xmm2
	cvtss2sd xmm3, xmm3
	cvtss2sd xmm4, xmm4
	cvtss2sd xmm5, xmm5
	cvtss2sd xmm6, xmm6
	cvtss2sd xmm7, xmm7

	;multiplicamos los doubles en xmm0 <- xmm0 * xmm1, xmmo * xmm2 , ...
	mulsd xmm0, xmm1
	mulsd xmm0, xmm2
	mulsd xmm0, xmm3
	mulsd xmm0, xmm4
	mulsd xmm0, xmm5
	mulsd xmm0, xmm6
	mulsd xmm0, xmm7

	;traer los de la pila
	movd xmm1, [rbp + 0x30]
    cvtss2sd xmm1, xmm1

	;multiplicar los que estan en la pila
	mulsd xmm0, xmm1

	; convertimos los enteros en doubles y los multiplicamos por xmm0.
	cvtsi2sd xmm1, rsi
	mulsd xmm0, xmm1

	cvtsi2sd xmm1, rdx
	mulsd xmm0, xmm1

	cvtsi2sd xmm1, rcx
    mulsd xmm0, xmm1

    cvtsi2sd xmm1, r8
    mulsd xmm0, xmm1

    cvtsi2sd xmm1, r9
    mulsd xmm0, xmm1

    mov rdx, [rbp + 0x10]
    cvtsi2sd xmm1, rdx
    mulsd xmm0, xmm1

    mov rdx, [rbp + 0x18]
    cvtsi2sd xmm1, rdx
    mulsd xmm0, xmm1

    mov rdx, [rbp + 0x20]
    cvtsi2sd xmm1, rdx
    mulsd xmm0, xmm1

    mov rdx, [rbp + 0x28]
    cvtsi2sd xmm1, rdx
    mulsd xmm0, xmm1

    ; guardar en destination
    movq [rdi], xmm0

	; epilogo
	pop rbp
	ret


