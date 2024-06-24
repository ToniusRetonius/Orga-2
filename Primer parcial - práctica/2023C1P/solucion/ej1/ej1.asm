global templosClasicos

global cuantosTemplosClasicos

extern calloc
section .data
; TEMPLO
%define COLUM_LARGO 0
%define NOMBRE 8
%define COLUM_CORTO 16
%define TAM_TOTAL 24

; ARRAY 
%define SIGUIENTE 24



;########### SECCION DE TEXTO (PROGRAMA)
section .text


; templo*[rdi], temploArr_len[rsi]
cuantosTemplosClasicos:
    push rbp
    mov rbp, rsp
    
    xor rax, rax                    ; rax = (uint32_t) total = 0
    xor rcx, rcx
    xor rdx, rdx          

    ciclo:
    cmp rsi, 0
    je fin

    mov rcx, [rdi + COLUM_LARGO]    ; cl = #columnas en el lado largo
    mov rdx, [rdi + COLUM_CORTO]    ; dl + #columnas en el lado corto 
    add rdx, rdx
    inc rdx

    cmp rdx, rcx                    ; if (suma == #col en el lado largo)
    jne siguiente

    inc rax                         ; total++;
    siguiente:
    sub rsi, 1
    add rdi, SIGUIENTE
    jmp ciclo

    fin:
    pop rbp
    ret

;--------------------- pasa el test hasta aca ----------------

; templo*[rdi], temploArr_len[rsi] 
templosClasicos:
    push rbp
    mov rbp, rsp

    push rbx
    push r12
    push r13
    push r14

    mov rbx, rdi            ; guardamos el puntero a temple*
    mov r12, rsi            ; guardamos temple*.length

    call cuantosTemplosClasicos
    mov rdi, rax            ; le paso la # templos clasicos
    mov rsi, TAM_TOTAL      ; le paso el tam de cada templo
    call calloc

    mov r13, rax            ; me guardo el puntero a res

    ; tenemos que recorrer el array e ir guardando aquellos que son clasicos    
    xor rcx, rcx
    xor rdx, rdx   
    xor r8, r8   
    xor r9, r9   

    loop:
    cmp r12, 0
    je final

    mov r8, [rbx + NOMBRE]                          ; r8 = nombre
    mov rcx, [rbx + COLUM_LARGO]                ; rcx = #columnas en el lado largo
    mov r9, rcx
    mov rdx, [rbx + COLUM_CORTO]                    ; rdx =  #columnas en el lado corto 
    mov r10, rdx
    ; calculamos M 
    add rdx, rdx
    inc rdx

    cmp rdx, rcx                                    ; if (suma == #col en el lado largo)
    jne next

    mov [r13 + NOMBRE], r8                          ; agregamos al arreglo el nombre del templo
    mov [r13 + COLUM_LARGO], r9                     ; agregamos al arreglo la # columnas del lado largo
    mov [r13 + COLUM_CORTO], r10                    ; agregamos al arreglo la # columnas del lado corto
    add r13, SIGUIENTE                              ; actualizamos el indice
    
    next:
    sub r12, 1
    add rbx, SIGUIENTE
    jmp loop

    final:
    pop r14
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret
;--------------------- pasa el test hasta aca ----------------




