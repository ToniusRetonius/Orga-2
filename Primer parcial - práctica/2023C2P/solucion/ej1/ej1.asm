section .data

; PLIST
%define PLISTFIRST 0
%define PLISTLAST 8

; S_LIST
%define DATA 0
%define NEXT 8
%define PREV 16

; PAGO_T
%define MONTO 0
%define APROBADO 1
%define PAGADOR 8
%define COBRADOR 16

; PAGOSPLITTED_T
%define CANT_APROBADOS 0
%define CANT_RECHAZADOS 1
%define APROBADOS 8
%define RECHAZADOS 16

section .text

global contar_pagos_aprobados_asm
global contar_pagos_rechazados_asm

global split_pagos_usuario_asm

extern malloc
extern free
extern strcmp


;########### SECCION DE TEXTO (PROGRAMA)

; uint8_t contar_pagos_aprobados_asm(list_t* pList, char* usuario);
; pList[rdi], usuario[rsi]
contar_pagos_aprobados_asm:
    push rbp
    mov rbp, rsp

    push r12
    push r13
    push r14
    push r15

    mov r12, rdi                    ; plist
    mov r13, rsi                    ; usuario
    xor r14, r14                    ; total = 0

    mov r12, [rdi + PLISTFIRST]     ; actual = pList->first;
    
    ciclo:
    cmp r12, 0                      ; while (actual != NULL)
    je fin

    mov r15, [r12 + DATA]           ; actual->data
    mov rdi, [r15 + PAGADOR]        ; actual->data->pagador
    mov rsi, r13                    ; usuario
    
    call strcmp                     ; str = 0 => son iguales
    cmp rax, 0                      ; if (actual->data->pagador == usuario)
    jne siguiente        

    xor rcx, rcx                    ; como sabemo si es aprobado?
    mov cl, byte[r15 + APROBADO]    ; actual->data->aprobado
    cmp cl, 0                       ; if (actual->data->aprobado != NULL)
    je siguiente

    add r14b, 1                      ; total++

    siguiente:
    mov r12, [r12 + NEXT]
    jmp ciclo
    
    fin:
    xor rax, rax
    mov al, r14b                    ; al  = total (uint8_t)
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbp
    ret

; uint8_t contar_pagos_rechazados_asm(list_t* pList, char* usuario);
; pList[rdi], usuario[rsi]
contar_pagos_rechazados_asm:

; pagoSplitted_t* split_pagos_usuario_asm(list_t* pList, char* usuario);
split_pagos_usuario_asm:

