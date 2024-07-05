section .rodata
cuatro_pixeles_negros: times 4 dd 0xFF000000
cuatro_pixeles_blancos: times 4 dd 0xFFFFFFFF
dieciseis: dq 16

global Pintar_asm

section .text

Pintar_asm:
    push rbp
    mov rbp, rsp

    mov r10, rcx 				; height -> r10

    mov rcx, rdx
    shr rcx, 1 					; #iteraciones: (pixeles/4)*2
    push rcx
    ; pintamos de negro las primeras dos filas:
    movdqu xmm0, [cuatro_pixeles_negros]

    mov r11, 0
pintar_arriba:
    movdqu [rsi+r11], xmm0 		; en cada iteracion pintamos 4 pixeles
    add r11, [dieciseis]
    dec rcx
    cmp rcx, 0
    jne pintar_arriba

    ; r10 = height

    movdqu xmm1, [cuatro_pixeles_blancos]

    ; rsi + r11 está donde comienza el blanco
    ; iteraciones de blanco = (ancho/4)(altura-4)
    mov rcx, rdx 				; rcx = width
    shr rcx, 2 					; rcx = width / 4
    mov rax, r10 				; rax = height
    sub rax, 4 					; rax = height - 4
    mul rcx
    mov rcx, rax
pintar_relleno:
    movdqu [rsi+r11], xmm1 		; en cada iteracion pintamos 4 pixeles (16 bytes)
    add r11, [dieciseis] 		; nos movemos a los proximos 16
    dec rcx
    cmp rcx, 0
    jne pintar_relleno

    pop rcx

pintar_abajo:
    movdqu [rsi+r11], xmm0 		; en cada iteracion pintamos 4 pixeles
    add r11, [dieciseis]
    dec rcx
    cmp rcx, 0
    jne pintar_abajo

    ; poner rsi + r11 al comienzo de los dos ultimos pixeles de la segunda fila
    mov r11, r8
    add r11, r8
    sub r11, 8
    mov rcx, r10
    sub rcx, 3 					; cantidad de iteraciones = filas - 4
pintar_bordes:
    movdqu [rsi+r11], xmm0
    add r11, r8 				; siguiente fila
    dec rcx
    cmp rcx, 0
    jne pintar_bordes

    pop rbp
	ret

; para ejecutar
; make en la carpeta donde estan todas las carpetas
; ./build/simd Pintar -i asm ./img/puente.bmp
