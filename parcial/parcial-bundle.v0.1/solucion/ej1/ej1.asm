section .data
; NODO_DISPLAY_LIST  
%DEFINE FUNC_Z_NODO 0
%DEFINE X 8
%DEFINE Y 9
%DEFINE Z 10
%DEFINE SIG_PUNT 16
; NODO-OT-T 
%DEFINE DISPLAY_ELEMENT 0
%DEFINE SIGUIENTE 8
%DEFINE TAM_NODO_T 16 
;OT 
%DEFINE SIZE_ 0
%DEFINE TABLE_ 8
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
push rdi 

mov rdi, 16
call malloc

pop rdi
mov [rax + SIZE_], dil ;movemos el table_size a la ot en su respectivo offset 
push rax

xor rcx, rcx 
mov cl, dil 
mov rdi, rcx

mov rsi, 8
call calloc
pop r8
mov [r8 + TABLE_], rax
mov rax, r8
pop rbp
ret

;rdi tengo puntero display , sil z_size 
; void* calcular_z(nodo_display_list_t* display_list, uint8_t z_size) ;
calcular_z_asm:
    push rbp
    mov rbp, rsp

    xor rax, rax 

    push rdi 
    sub rsp, 8

    xor rdx, rdx 
    mov dl, sil ;z size

    mov rax, [rdi + FUNC_Z_NODO] ;preparo en rax la direccion a donde esta la funcion
    
    xor rsi, rsi
    mov sil, byte[rdi + Y]

    xor r8, r8
    mov r8b, byte[rdi + X]

    xor rdi, rdi
    mov rdi, r8
    
    call rax 

    add rsp, 8
    pop rdi 

    mov [rdi + Z], al

    pop rbp
    ret 
;rdi tenemos un puntero a la tabla
;rsi el puntero a la lista display    
; void* ordenar_display_list(ordering_table_t* ot, nodo_display_list_t* display_list) ;
ordenar_display_list_asm:
    push rbp
    mov rbp, rsp

    push r12 
    push r13
    push r14
    push r15


    xor r12, r12
    xor r13, r13
    xor r14, r14
    xor r15, r15

    mov r14b, byte [rdi + SIZE_]
    mov r12, [rdi + TABLE_] ; puntero de tipo ordering_table que contiene un punteor a tabla y a size
    mov r13, rsi ; punteor de tipo nodo_display_t apunta al primer nodo_display_list
    ciclo:
    cmp r13, 0 ;comparo para ver si mi nodo_display_list no tiene mas nodos
    je fin

    mov rdi, r13 
    mov rsi, r14

    call calcular_z_asm
    xor r8, r8
    mov r8, r12  ;estamos al principio de la table
    xor rdx, rdx 
    mov dl, byte[r13 + Z] ; capturo z del nodo display list
    shl rdx, 3
    add r8, rdx ;me paro en el puntero al nivel respectivo de z

    push r8
    ;pedimos memoria para nuestro nuevo nodo
    xor rdi, rdi
    mov rdi, TAM_NODO_T

    call malloc

    mov [rax + DISPLAY_ELEMENT], r13
    xor r8, r8 ;uso r8 para poner el 0 
    mov [rax + SIGUIENTE], r8 ;pongo null en sig ,osea ceros pero 
    ;ya tenemos nuestro nodo new

    pop r8 ;sigue teniendo el puntero offseteado en nuestra table.

    mov rdi, [r8] ;contenido
    cmp rdi, 0 ;chequeamos si el puntero del array es null
    je caso1

    caso2:
    mov r9, [r8]
    add r9, SIGUIENTE
    cmp r9, 0
    je enlazar
    mov r8, r9
    jmp caso2

    enlazar:
    mov r9, [r8]
    mov [r9 + SIGUIENTE], rax
    jmp sigDisplay 

    caso1:

    mov [r8], rax ;rax tiene la direccion de new. Y la guardamos en la direccion de r8 que es el elemento de la table
    sigDisplay:
    mov r13, [r13 + SIG_PUNT] ;vamos al sig nodo de la display list
    jmp ciclo

fin:
    pop r15
    pop r14
    pop r13
    pop r12

    pop rbp
    ret