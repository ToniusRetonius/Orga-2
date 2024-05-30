section .data

Mask_blanco times 4 dd 0xffffffff ; en memoria es : b = ff g = ff r = ff a = ff
Mask_negro_fila times 4 dd 0xff000000 ; en memoria es : b = 00 g = 00 r = 00 a = ff
Mask_negro_columna1  dd  0xff000000,0xff000000,0xffffffff,0xffffffff ; los primeros 2 son negros, y los otros 2 blancos
Mask_negro_columna2  dd  0xffffffff,0xffffffff,0xff000000,0xff000000 ; los primeros 2 son blancos, y los otros 2 negros

; colores de prueba porq el negro no se ve una goma
Mask_negro_columna3  dd  0xffFFA500,0xffFFA500,0xffffffff,0xffffffff ; los primeros 2 son naranjas, y los otros 2 blancos
Mask_negro_columna4  dd  0xffffffff,0xffffffff,0xffFFA500,0xffFFA500 ; los primeros 2 son blancos, y los otros 2 naranjas
Mask_naranja_fila times 4 dd 0xffFFA500 ; en memoria es : b = 00 g = 00 r = 00 a = ff

section .text
global Pintar_asm

;void Pintar_asm(unsigned char *src, unsigned char *dst, int width, int height, int src_row_size, int dst_row_size);
; la estrategia es pintar primero todo blanco : 
; blanco en rgba = 255,255,255,255
; luego recorrer (como se trata de una matriz) dos filas superiores, dos inferiores y 4 columnas y poner negro
; negro en rgba = 0,0,0,255 

Pintar_asm:
	push rbp
	mov rbp,rsp

	; cuantas dd tengo que poner el src?
	xor r10, r10
	xor r11, r11
	mov r10d, edx		; r10d = alto
	mov r11d, ecx		; r11d = ancho
	imul r10d, r11d		; r10d = edx x ecx (tam en pixeles) 

	; guardamos la dire de rsi 
	xor r11, r11
	mov r11, rsi

	; cargamos mask
	pxor xmm0, xmm0
	pxor xmm1, xmm1
	movdqu xmm0, [Mask_blanco]

	; tenemos que poner r10d / 4 (porq pintamos de a 4 pixeles) -veces blanco
	blanco:	
	cmp r10d,0
	je negro

	movdqu [r11], xmm0 
	add r11, 16			; me muevo 16 bytes en memoria
	sub r10d, 4			; como pinto de a 4, resto de a 4
	jmp blanco
	
	negro:
	; pintamos las columnas
	mov r11, rsi
	mov r10d, edx		; r10d = alto
	movdqu xmm1, [Mask_negro_columna3]

	columna1:
	cmp r10d,0
	je columna2

	movdqu [r11], xmm1
	add r11d, r9d		; sumamos el dst_row_size
	sub r10d, 1
	jmp columna1

	columna2:
	mov r11, rsi
	mov r10d, edx
	movdqu xmm1, [Mask_negro_columna4]
	xor r8,	r8
	mov r8, 4
	imul r8d, ecx 		; cuantos bytes son el ancho de la imagen? pixeles de ancho x 4
	sub r8d, 16 		; entonces ahora restamos 16 para estar en la ultima columna de la imagen
	add r11d, r8d		; offset adecuado

	col2:
	cmp r10d,0
	je filas

	movdqu [r11], xmm1
	add r11d, r9d
	sub r10d, 1
	jmp col2

	filas:
	mov r11, rsi
	mov r10d, ecx	; ancho 
	movdqu xmm1, [Mask_naranja_fila]
	xor r8, r8
	mov r8, r9
	add r8, r11 	; offset fila de abajo

	fila1_2:
	cmp r10d, 0
	je fila3_4

	movdqu [r11], xmm1
	movdqu [r8], xmm1
	add r11, 16
	add r8, 16
	sub r10d, 4
	jmp fila1_2

	fila3_4:
	mov r11, rsi
	mov r10d, ecx 	; ancho
	xor r8, r8
	mov r8d, edx 	; alto
	imul r8d, ecx 	; total de pixeles
	sub r8d, ecx		
	sub r8d, ecx		; le resto las ultimas 2 filas de pixeles (me quiero parar en altura - 1 al inicio de la columna)
	xor rax, rax
	mov rax, 4 		; son 4 bytes x pixel
	imul r8, rax	; # bytes que tengo q offsetear a rsi
	add r11, r8
	xor r8, r8
	mov r8, 2
	imul r10d, r8d 	; quiero recorrer dos filas

	f3f4:
	cmp r10d, 0
	je fin

	movdqu [r11], xmm1
	add r11, 16
	sub r10d, 4
	jmp f3f4

	fin:
	pop rbp
	ret
	

