; /** defines bool y puntero **/
%define NULL 0
%define TRUE 1
%define FALSE 0

section .data

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
    mov rdi, 0x10
    call malloc
    mov qword [rax + 0x0], 0
    mov qword [rax + 0x8], 0
    ret

string_proc_node_create_asm:
    ; type en rdi
    ; char* en rsi
    mov rcx, rdi
    mov rdx, [rsi]

    mov rdi, 0x12
    call malloc

    mov byte[rax + 0x10], rcx
    mov byte[rax + 0x11], rdx

    ret
string_proc_list_add_node_asm:
    ; s_p_l* en rdi
    ; type en rsi
    ; char* hash rcx

    mov rdx, dword[rdi]

    ciclo:
    cmp dword[rdx], 0
    je fin

    add rdx, 0xA
    jmp ciclo

    fin
    mov rdi, rsi
    mov rsi, rcx
    call string_proc_node_create_asm

    mov 
    ret 

string_proc_list_concat_asm:
