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
    push rbp
    mov rbp, rsp

    mov rdi, 10
    call malloc
    mov qword [rax], 0
    
    pop rbp
    ret

string_proc_node_create_asm:
    ; type en rdi
    ; char* en rsi
    push rbp
    mov rbp, rsp

    push rdi
    push rsi

    mov rdi, 32
    call malloc

    pop rsi
    pop rdi

    mov dword [rax], 0 
    mov dword [rax + 8], 0 
    mov byte [rax + 16], rdi
    mov dword [rax + 24], rsi

    pop rbp
    ret
string_proc_list_add_node_asm:
    ; s_p_l* en rdi
    ; type en rsi
    ; char* hash rdx
    push rbp
    mov rbp, rsp

    ; uso los no volátiles
    push r10
    push r11
    mov r10, rsi ; r10 = type
    mov r11, rdx ; r11 = char* = hash


    mov 
    ret 

string_proc_list_concat_asm:

