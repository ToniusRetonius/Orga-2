%define OT_STRUCT_SIZE 16
%define TABLE_SIZE_OFFSET 0
%define TABLE_OFFSET 8

%define NODO_OT_STRUCT_SIZE 16
%define DSP_ELEM_OFFSET 0
%define SIGUIENTE_OT_OFFSET 8

%define NODO_DSP_STRUCT_SIZE 24

%define PRIMITIVA_OFFSET 0
%define X_OFFSET 8
%define Y_OFFSET 9
%define Z_OFFSET 10
%define SIGUIENTE_DSP_OFFSET 16


section .rodata

section .text

global inicializar_OT_asm
global calcular_z_asm
global ordenar_display_list_asm

extern malloc
extern free
extern calloc


;########### SECCION DE TEXTO (PROGRAMA)


; typedef struct {
; uint8_t table_size;
; nodo_ot_t** table;
; } ordering_table_t;

; ordering_table_t* inicializar_OT(uint8_t table_size);
; rdi = tableSize
inicializar_OT_asm:
    push rbp 
    mov rbp, rsp
    push r12
    push r13


    mov r12, rdi            ; r12 = tableSize
    mov rsi, 8              ; sizeof ptr

    xor r13, r13           
    cmp rdi, 0
    je .createOT            ; si el size es 0, entonces no crea el array, inicializa el ptr en 0 con el calloc

    call calloc             ; rax = nodo_ot** arr = calloc(table_size, 8)   
    mov r13, rax            ; r13 = nodo_ot** arr

    .createOT:
    mov rdi, OT_STRUCT_SIZE
    call malloc             ; rax = ordering_table* res

    mov [rax + TABLE_SIZE_OFFSET], r12      ; res->table_size = table_size
    mov [rax + TABLE_OFFSET], r13           ; res->table = arr
    
    ; res queda en rax
    .fin:
    pop r13
    pop r12
    pop rbp
    ret

; void* calcular_z(nodo_display_list_t* display_list, uint8_t z_size) ;
; rdi = display_listNodo* , rsi = z_size
calcular_z_asm:
    push rbp 
    mov rbp, rsp
    push r12
    push r13

    ; iteramos por cada nodo de la display list y completamos su coordenada z llamando a su funcion primitiva

    mov r12, rdi                ; r12 = nodoActualPtr
    xor r13, r13
    mov r13b, sil               ; r13b = z_size  (sil es el byte mas bajo de rsi)

    .ciclo:
        cmp r12, 0
        je .fin
        
        ; por las dudas (borrar al final)
        xor rdi, rdi
        xor rsi, rsi

        mov dil, byte [r12 + X_OFFSET]       ; rdi = nodo->x
        mov sil, byte [r12 + Y_OFFSET]       ; rsi = nodo->y
        mov rdx, r13                         ; rdx = z_size   , los bytes mas altos de r13 estan en 0

        mov r9, [r12 + PRIMITIVA_OFFSET]     ; r9 = puntero a la funcion a llamar
        call r9                              ; rax = nodo.primitiva(x, y, z_size)

        mov byte [r12 + Z_OFFSET], al        ; nodo.z = nodo.primitiva(x, y, z_size)   al el byte mas bajo de rax

        mov r12, [r12 + SIGUIENTE_DSP_OFFSET]    ; nodoActualPtr = nodoActualPtr->siguiente
        jmp .ciclo

    .fin:   
    pop r13
    pop r12
    pop rbp
    ret

; void* ordenar_display_list(ordering_table_t* ot, nodo_display_list_t* display_list) ;
; rdi = ot* , rsi = display_list*
ordenar_display_list_asm:
    push rbp 
    mov rbp, rsp
    push r12
    push r13
    push r14
    push r15

    mov r15, rdi                ; r15 = otPtr
    mov r14, rsi                ; r14 = display_listPtr

    mov rdi, r14                    ; rdi = display_listPtr
    mov sil, byte [r15 + TABLE_SIZE_OFFSET]    ; rsi = z_size = table_size

    call calcular_z_asm             ; ahora todos los nodos de las display_list tienen su z calculado

    .ciclo:
        cmp r14, 0
        je .fin

        xor r13, r13                    ; por las dudas (borrar al final)
        mov r13b, [r14 + Z_OFFSET]      ; r13 = nodoActual.z 

        ; vamos a usar r13 = nodoActual.z , como index para saber al final de que lista_ot agregar el display_node en r14

        ; buscamos la posicion de memoria apartir de ot->table, con el offset z

        mov r12, qword [r15 + TABLE_OFFSET]    ; r12 = ot->table , sacar del loop
        shl r13, 3                            ; z = z*8 (sizeof ptr)
        add r12, r13                           ; r12 = tablaPtr + z*8 = puntero al index z de la tabla

        ; [r12] tiene el nodo head de la lista_ot en la que hay que agregar al final el nodo display de r14
        
        cmp qword [r12], 0               ; invalid read aca creo
        jne .agregarNodo                ; si la lista es null, tenemos que inicializar el nodo_ot vacio antes de hacer el call

        mov rdi, NODO_OT_STRUCT_SIZE
        mov rsi, 1
        call calloc                     ; seteamos los 2 campos del nodo en 0

        mov [r12], rax                   ; guardamos en el array, el nodo vacio que acabamos de construir
        mov [rax + DSP_ELEM_OFFSET], r14 ; nuevoNodo->display_element = nodoActual;   
        jmp .nextIteration               ; no hay que agregar nada mas por ahora

        .agregarNodo:
        mov rdi, [r12] 
        mov rsi, r14

        call addLast                    ; addLast(tabla[z], displayNodoActual)

        ; avanzamos a la proxima iteracion
        .nextIteration:
        mov r14, [r14 + SIGUIENTE_DSP_OFFSET]       ; nodoActualPtr = nodoActualPtr->siguiente
        jmp .ciclo


    .fin:   
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbp
    ret

; necesito una funcion para agregar un nodo al final de una lista enlazada de nodo_ot
; addLast(nodo_ot_t* listHead, nodo_ot_t* node)

addLast:
    push rbp
    mov rbp, rsp
    push r12
    push r13

    cmp qword [rdi + DSP_ELEM_OFFSET], 0
    jne .ciclo                             ; si el head de la lista era null, seguimos de largo

    mov qword [rdi + DSP_ELEM_OFFSET], rsi       ; node se convierte en el primer elemento de la lista
    jmp .fin

    .ciclo:                                  ; si el head de la lista no era null
        cmp qword [rdi + SIGUIENTE_OT_OFFSET], 0
        jmp .fin

        mov rdi, qword [rdi + SIGUIENTE_OT_OFFSET]
        jmp .ciclo
    
    ; al salir del ciclo, rdi, es el ultimo nodo de la lista ot, y tiene su siguiente en null
    .fin:
    ; seteamos el siguiente del ultimo nodo al

    ; creamos un nodo ot, y lo seteamos con el nodo display
    mov r12, rdi
    mov r13, rsi

    mov rdi, NODO_OT_STRUCT_SIZE
    mov rsi, 1

    call calloc                             ; seteamos los 2 campos del nodo en 0, error aca
    mov [rax + DSP_ELEM_OFFSET], r13

    mov [r12 + SIGUIENTE_OT_OFFSET], rax

    pop r13
    pop r12
    pop rbp
    ret




































