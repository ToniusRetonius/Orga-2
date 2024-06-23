
section .data
; LISTA 
%define STRING_PROC_LIST 16
%define LIST_FIRST 0
%define LIST_LAST 8
; NODO
%define STRING_PROC_NODE 32
%define NODE_NEXT 0
%define NODE_PREV 8
%define NODE_TYPE 16
%define NODE_HASH 24

section .text

global string_proc_list_create_asm
global string_proc_node_create_asm
global string_proc_list_add_node_asm
global string_proc_list_concat_asm

; FUNCIONES auxiliares que pueden llegar a necesitar:
extern malloc
extern calloc
extern free
extern str_concat


string_proc_list_create_asm:
    push rbp
    mov rbp, rsp

    xor rdi, rdi
    mov rdi, STRING_PROC_LIST
    call malloc

    xor rsi, rsi
    mov [rax], rsi
    mov [rax + LIST_LAST], rsi

    ; en gdb veo que no hay cero en un byte : raro
    pop rbp
    ret

; type[dil], hash[rsi]
string_proc_node_create_asm:
    push rbp
    mov rbp, rsp

    push rbx
    push r12

    mov rbx, rdi                        ; type en dil
    mov r12, rsi                        ; hash

    xor rdi, rdi
    mov rdi, STRING_PROC_NODE
    call malloc

    xor rcx, rcx

    mov [rax], rcx
    mov [rax + NODE_PREV], rcx
    mov [rax + NODE_TYPE], rcx          ; por las dudas que haya basura en el resto
    mov byte[rax + NODE_TYPE], bl
    mov [rax + NODE_HASH], rsi

    pop r12
    pop rbx
    pop rbp
    ret

; list[rdi], type[sil], hash[rdx]
string_proc_list_add_node_asm:
    push rbp
    mov rbp, rsp

    push rbx
    push r12
    push r13
    sub rsp, 8                          ; alineamos la pila

    mov rbx, rdi                        ; puntero a la lista
    mov r12b, sil                       ; type
    mov r13, rdx                        ; hash

    mov dil, sil                        ; pasamos type
    mov rsi, rdx                        ; pasamos hash
    call string_proc_node_create_asm    ; creamos el nodo

    mov rdx, [rbx]                      ; cargamos list->first 
    mov rcx, [rbx + 8]                  ; cargamos list->last
    cmp rdx, 0                          ; si list->first = 0 sino ...
    jne lista_no_vacia

    lista_vacia:
    mov [rbx], rax                      ; list->first = nuevo;
    mov [rbx + 8], rax                  ; list->last = nuevo;
    jmp fin

    lista_no_vacia:
    mov [rcx + NODE_NEXT], rax          ; ultimo->next = nuevo;
    mov [rax + NODE_PREV], rcx          ; nuevo->previous = ultimo;
    mov [rbx + 8], rax                  ; list->last = nuevo;
    jmp fin

    fin:
    add rsp, 8
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret 

; ------------------- test bien -----------------
; list[rdi], type[sil], hash[rdx]
string_proc_list_concat_asm:
    push rbp
    mov rbp, rsp

    push rbx
    push r12
    push r13
    push r14
    push r15

    mov r12, rdi                    ; list*
    mov r13b, sil                   ; type
    mov r14, rdx                    ; hash
    mov r15, [rdi + LIST_FIRST]     ; list->first (actual)

    ciclo:
    cmp r15, 0                      ; while (actual != NULL)
    je final

    mov cl, byte[r15 + NODE_TYPE]   ; capturamos el type del actual
    cmp cl, r13b                    ; comparamos con el type pasado por param
    je concat

    siguiente:
    mov r15, [r15 + NODE_NEXT]      ; actual = actual->next;
    jmp ciclo
    
    concat:                         ; por convecion pasamos a str_concat
    mov rdi, r14                    ; rdi = hash
    mov rsi, [r15 + NODE_HASH]      ; rsi = actual->hash
    call str_concat
    mov r14, rax                    ; hash = str_concat(hash, actual->hash);
    mov r15, [r15 + NODE_NEXT]      ; actual = actual->next;
    jmp ciclo

    final:
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret
; ------------------- test bien -----------------
; detalle : para evitar el seg fault que sucede con el mal manejo de la pila : pusheamos un no volatil para mantenerla alineada

    

