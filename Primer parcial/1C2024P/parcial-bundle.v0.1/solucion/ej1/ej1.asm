section .data
; OT
%define TABLE 8
%define TABLE_SIZE 0

; NODO_DISPLAY_LIST_T
%define CALCULAR_Z 0
%define X 8
%define Y 9
%define Z 10
%define SIGUIENTE 16

; NODO_OT
%define TAM_NODO_OT 16
%define DISPLAY_ELEMENT 0
%define SIGUIENTE_OT 8



section .text

global inicializar_OT_asm
global calcular_z_asm
global ordenar_display_list_asm

extern malloc
extern free
extern calloc

;########### SECCION DE TEXTO (PROGRAMA)

; ordering_table_t* inicializar_OT(uint8_t table_size);
inicializar_OT_asm:
    push rbp
    mov rbp, rsp

    push r12
    push r13

    xor r12, r12
    mov r12b, dil       ; capturamos table_size

    mov rdi, 16         ; tamano del struct
    call malloc         ; puntero a la ot
    mov r13, rax        ; guardamos en r13 res

    mov rdi, r12        ; pasamos table size
    mov rsi, 8          ; pasamos # elementos en el arreglo de punteros
    call calloc         ; puntero al array de punteros

    mov [r13 + TABLE], rax      ; asignamos el puntero al array de punteros
    mov [r13 + TABLE_SIZE], r12 ; asignamos el table size

    mov rax, r13
    pop r13
    pop r12
    pop rbp
    ret
; ------------------- pasa todos menos 1 ---------------------------
; void* calcular_z(nodo_display_list_t* nodo, uint8_t z_size) ;
calcular_z_asm:
    push rbp
    mov rbp, rsp

    push r12
    push r13

    mov r12, rdi                    ; *nodo 
    xor r13, r13    
    mov r13b, sil                   ; z_size

    mov rax, [r12 + CALCULAR_Z]     ; traemos el * funcion que calcula z
    xor rdi, rdi
    xor rsi, rsi
    xor rdx, rdx

    mov dil, [r12 + X]              ; pasamos x
    mov sil, [r12 + Y]              ; pasamo y
    mov rdx, r13                    ; pasamos z_size
    call rax                        ; llamamos a la fn

    mov [r12 + Z], al               ; asignamos el valor de z al nodo
    
    pop r13
    pop r12
    pop rbp
    ret
; ------------------- pasa bien los test -----------------------
; void* ordenar_display_list(ordering_table_t* ot, nodo_display_list_t* display_list) ;
ordenar_display_list_asm:
    push rbp
    mov rbp, rsp

    push r12
    push r13
    push r14
    push r15
    push rbx
    sub rsp, 8

    mov r12, rdi                        ; OT
    mov r13, rsi                        ; puntero al arreglo de nodos de la display list (en part el primero de ellos)
    mov r14, [rdi + TABLE_SIZE]         ; en otras palabras, z_size

    ciclo:
    xor rdi, rdi
    mov rdi, [r13]
    cmp rdi, 0
    je fin

    mov rdi, r13                        ; pasamos por ABI rdi = nodo display list
    xor rsi, rsi
    mov sil, r14b                       ; pasamos por ABI rsi = z_size
    call calcular_z_asm                 ; es void por cierto

    mov rdi, TAM_NODO_OT                ; pasamos a malloc el tam del nodo nuevo
    call malloc
    mov rbx, rax                        ; guardamos el * nuevo nodo en rbx
    xor rax, rax
    mov [rbx + DISPLAY_ELEMENT], r13    ; asignamos diplay element (actual)
    mov [rbx + SIGUIENTE_OT], rax       ; asignamos NULL al siguiente

    mov rax, 8                          ; tam cada puntero del arreglo
    xor rcx, rcx
    mov cl, [r13 + Z]                   ; capturamos z
    mul cx                              ; rax = offset adeuado

    xor r8, r8
    mov r8, [r12 + TABLE]               ; nos paramos en el primer puntero de la tabla
    add r8, rax                         ; offset adecuado

    xor r9, r9
    mov r9, [r8]
    cmp r9, 0
    je enlazar

    busqueda:
    xor r10, r10
    mov r10, [r8 + SIGUIENTE_OT]
    cmp r10, 0
    je enlazar
    
    mov r8, r10
    jmp busqueda

    enlazar:
    mov [r8], rbx
    add r13, 24
    jmp ciclo

    fin:
    add rsp, 8
    pop rbx
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbp
    ret
; -------------------- pasa 1 / 4 --------------------------
; chequear la busqueda 





