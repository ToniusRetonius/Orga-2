; /** defines bool y puntero **/
%define NULL 0
%define TRUE 1
%define FALSE 0

section .data
%define LIST_SIZE 16
%define LIST_FIRST 0
%define LIST_LAST 8
%define NODE_T_SIZE 32
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
extern free
extern str_concat


string_proc_list_create_asm:
    push rbp
    mov rbp, rsp

    mov rdi, LIST_SIZE
    call malloc

    xor rsi,rsi
    mov [rax + LIST_FIRST], rsi
    mov [rax + LIST_LAST], rsi
    
    pop rbp
    ret

string_proc_node_create_asm:
    push rbp
    mov rbp, rsp

    push r12    
    push r13   
   
    mov r12, dil                    ; type en rdi pero el mini (8 bits)
    mov r13, rsi                    ; char* en rsi
    
    mov rdi, NODE_T_SIZE
    call malloc

    xor rdx, rdx

    mov [rax + NODE_NEXT], rdx
    mov [rax + NODE_PREV], rdx
    mov [rax + NODE_TYPE], r12b     ; r12b es el low 8-bit 
    mov [rax + NODE_HASH], r13

    pop r13
    pop r12
    pop rbp
    ret

; s_p_l* en rdi
string_proc_list_add_node_asm:
    push rbp
    mov rbp, rsp

    push r12
    sub rsp, 8                      ; alineamos la pila
    mov r12, rdi                    ; guardamos el puntero a list en un no volátil

    mov rdi, rsi                    ; type en rdi
    mov rsi, rdx                    ; hash en rsi
    call string_proc_node_create_asm 

    cmp [r12 + LIST_LAST], 0
    je first
    jne notfirst

    notfirst:
    mov rdi, [r12 + LIST_LAST]      ; ultimo = list->last;
    mov [rdi + NODE_NEXT], rax      ; ultimo->next = nuevo;
    mov [rax + NODE_PREV], rdi      ; nuevo->previous = ultimo;
    jmp fin

    first: 
    mov [r12 + LIST_FIRST], rax      ; list->first = nuevo;
    mov [r12 + LIST_LAST], rax      ; list->last = nuevo;
    jmp fin


    fin:
    add rsp, 8
    pop r12
    pop rbp
    ret 

string_proc_list_concat_asm:

    

