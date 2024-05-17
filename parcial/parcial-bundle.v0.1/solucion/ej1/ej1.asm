section .text
section .data
/* NODO_DISPLAY_LIST */ 
%DEFINE FUNC_Z_NODO 0
%DEFINE X 8
%DEFINE Y 9
%DEFINE Z 10
%DEFINE SIG_PUNT 16
/* NODO-OT-T */
%DEFINE DISPLAY_ELEMENT 0
%DEFINE SIGUIENTE 8
%DEFINE TAM_NODO_T 16 
/* OT */
%DEFINE SIZE_ 0
%DEFINE LISTA_ENLAZADA_Z 8


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

xor rcx, rcx
mov cl, sil
mov rdi, rcx
xor rsi , rsi 
mov rsi, 8 //tamano de puntero
call calloc 

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
push r12 ;
push r13
push r14
push r15


xor r12, r12
xor r13, r13
xor r14, r14
xor r15, r15

mov r12, rdi ; puntero de tipo ordering_table que contiene un punteor a tabla y a size
mov r13, rsi ; punteor de tipo nodo_display_t apunta al primer nodo_display_list
mov r14, [r12 + SIZE_]
ciclo:

mov rdi, r13 
mov rsi, r14

call calcular_z_asm
xor r8, r8
mov r8, [r12 + LISTA_ENLAZADA_Z] ;estamos al principio de la table
xor rdx, rdx 
mov dl, byte[r13 + Z] ; capturo z del nodo display list
mov r8, [r8 + rdx] ;me paro en el puntero al nivel respectivo de z

push r8
;pedimos memoria para nuestro nuevo nodo
xor rdi, rdi
mov rdi, TAM_NODO_T

call malloc
mov [rax + DISPLAY_ELEMENT], r13 ;
mov [rax + SIGUIENTE], dw 0 ;dw porque solo quiero ponerle al puntero que apunte a null

;ya tenemos nuestro nodo new

pop r8

cmp r8, 0 ;si es null salto al caso 1
je caso1
caso2:
xor r9, r9 ;inicializamos r9 que vamos a usar para guardar el sig
mov r9, [r8+ SIGUIENTE]
cmp r9, 0 ;vemos si es ultimo nodo de la lista enlazada
je enlazar ;si lo es enlazamos al new
mov r8, [r8 + SIGUIENTE] ;si no pasa al siguiente hasta encontrar el ultimo
jmp caso2

enlazar: ;caso en que el sig es null
mov [r8 + SIGUIENTE], rax ;que sig apunte al new
jmp sigDisplay 


caso1:

mov [r8], rax ;quiero poner new en memoria, la cual r8 contiene la direccion.
sigDisplay:
mov r12, [r12 + SIG_PUNT] ;vamos al sig nodo de la display list
jmp ciclo


pop r15
pop r14
pop r13
pop r12

pop rbp
ret

