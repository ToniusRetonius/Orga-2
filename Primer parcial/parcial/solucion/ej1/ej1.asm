section .data
%define OT_SIZE 16
%define OT_TABLE_SIZE 0
%define OT_TABLE 8

%define NODO_PRIMITIVA 0
%define NODO_X 8
%define NODO_Y 9
%define NODO_Z 10
%define NODO_SIG 16

%define PTR_SIZE 8

%define NODO_T_SIZE 16

%define NODO_T_DISPLAY 0
%define NODO_T_SIG 8  

%define DISPLAY_LIST_SIGUIENTE 16

section .text

global inicializar_OT_asm
global calcular_z_asm
global ordenar_display_list_asm

extern malloc
extern free
extern calloc
;void *calloc(size_t num, size_t size);


;########### SECCION DE TEXTO (PROGRAMA)

; ordering_table_t* inicializar_OT(uint8_t table_size)

inicializar_OT_asm:
    push rbp
    mov rbp, rsp

    push rbx
    mov rbx, rdi
    sub rsp, 8                      ; alineamos la pila 

    mov rdi, OT_SIZE                ; pedimos espacio para la OT
    call malloc

    mov byte [rax + OT_TABLE_SIZE], rbx       ; seteamos nuevo->table_size = table_size

    mov rdi, rbx                            ; le paso # elems en el array de ptr
    mov rsi, PTR_SIZE                       ; le paso el tamaño de cada ptr
    mov rbx, rax                            ; me guardo el ptr al ot
    call calloc

    mov [rbx + OT_TABLE], rax               ; le paso a ot->table = rax del calloc (todos null)

    pop rbx
    pop rbp
    ret

;void calcular_z_asm(nodo_display_list_t* nodo, uint8_t z_size);
calcular_z_asm:
    push rbp
    mov rbp, rsp
    
    push rbx                                ; uso no-volàtil para almacenar el puntero 
    mov rbx, rdi                            ; me guardo el puntero al nodo 
    sub rsp, 8                              ; alineamos la pila

    
    mov rax, [rbx + NODO_PRIMITIVA]         ; para llamar a (*primitiva)
    mov dil, byte [rbx + NODO_X]            ; x en rdi de 8bits
    mov dl, sil                             ; z_size en rdx de 8 bits

    // es necesario limpiar todo lo que haya en rdx ? xor rdx,rdx luego mov dl, sil 
    
    mov sil, byte [rbx + NODO_Y]            ; Y en rsi de 8 bits
    
    call rax

    mov byte [rbx + NODO_Z], rax            ; asignamos valor de z al nodo
    
    pop rbx
    pop rbp
    ret

; void* ordenar_display_list(ordering_table_t* ot, nodo_display_list_t* display_list) ;
ordenar_display_list_asm:
    push rbp
    mov rbp, rsp

    push rbx                                       
    push r12                                        
    push r13                                        
    push r14
    push r15
    sub rsp, 8

    // podría limpiar todos los registros antes de usarlos 
    // xor (...)

    mov rbx, rdi                                    ; rbx = puntero a ord table
    mov r12, rsi                                    ; r12 = puntero a display_list actual
    mov r13, byte[rbx]                              ; r13 = table size
    
    // r13b
    // tal vez sería más apropiado traerse el puntero al array de punteros mov rbx, [rdi + OT_TABLE]

    lectura:
    cmp [r12], 0                                    ; si apunta a NULL, se termina
    je fin

    mov rdi, r12                                    ; con el puntero a la display_list actual 
    
    // a calcular z le tengo q pasar puntero a display_list y z_size
    // faltó mov rsi, r13
    call calcular_z_asm                             ; me traigo el z para saber dònde indexar en OT
    
    // calcular z es void, necesito capturar el valor de z 
    
    ; en rax =  z de este elem actual
    mov r14, [rbx + rax]                            ; me traigo el ptr de la ord list tal que apunta a la lista enlazada para ese z
    mov r15, [r14]                                  ; traigo lo que apunta r14 que es el primer nodo de la lista enlazada
    cmp r15, 0                                      ; es NULL?
    ; si es NULL -> creamos el nodo
    je crearNodo
    
    // el error es que tengo que acceder al nodo en la display_list -> capturar su z -> offsetear en el array de punteros
    // para ello :
    xor r8, r8
    mov r8, rbx                     //estamos al principio de la table ( recordar que este rbx es el de la correción no el del parcial)
    xor rdx, rdx 
    mov dl, byte[r12 + NODO_Z]      //capturo z del nodo display list
    shl rdx, 3                      //multiplico por 8 para moverme adecuadamente en el array de punteros
    add r8, rdx                     //me quiero parar en el puntero al nivel respectivo de z
    // me guardo r8 en la pila push r8
    // esto nos garantiza estar en arr[z] correcta ( es decir mirar al inicio de la lista enlazada)
    // pedimos memoria
    xor rdi, rdi
    mov rdi, TAM_NODO_T

    call malloc

    // hacemos las asignaciones adecuadas
    mov [rax + NODO_T_DISPLAY], r12
    xor r8, r8                      // uso r8 para poner el 0 
    mov [rax + NODO_T_SIG], r8      //pongo null en sig 

    pop r8                          //sigue teniendo el puntero offseteado en nuestra table.

    mov rdi, [r8] 
    cmp rdi, 0                      //chequeamos si el puntero del array es null    
    // vemos a dónde saltar : caso en q la lista enlazada es vacía o caso en que haya al menos un elemento

    
    nodoSiguiente:
    mov r15, [r15 + NODO_T_SIG]                     ; el nodo al que apunta el ultimo nodo de la lista  
    cmp r15, 0                                      ; el sig es NULL?
    jne nodoSiguiente
    ; si es NULL -> creamos el nodo y todo lo q implica

    crearNodo:
    mov rdi, NODO_T_SIZE                            ; necesito espacio para el nuevo nodo
    call malloc

    mov [rax + NODO_T_DISPLAY], r12                 ; el nodo apunta al display list actual
    mov dword[rax + NODO_T_SIG], 0                  ; el sig del nuevo nodo es NULL
    mov [r15 + NODO_T_SIG], rax                     ; el nodo anterior apunta al nuevo

    mov r12, [r12 + DISPLAY_LIST_SIGUIENTE]         ; actualizamos r12 con el siguiente de la display_list 
    jmp lectura                                     ; vemos el siguiente de la display_list
    
    fin:
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret

ordenar_display_list_asm_2:
    push rbp
    mov rbp, rsp

    push rbx                                       
    push r12                                        
    push r13                                        
    push r14
    push r15
    sub rsp, 8

    // podría limpiar todos los registros antes de usarlos 
    xor rbx, rbx
    xor r12, r12
    xor r13, r13
    xor r14, r14
    xor r15, r15

    mov rbx, [rdi + OT_TABLE]                           ; rbx = puntero a ord table
    mov r12, rsi                                        ; r12 = puntero a display_list actual
    mov r13b, byte[rbx]                                 ; r13 = table size

    lectura:
    cmp [r12], 0                                        ; si apunta a NULL, se termina
    je fin

    // a calcular z le tengo q pasar puntero a display_list y z_size
    mov rdi, r12                                        ; con el puntero a la display_list actual 
    mov rsi, r13
    call calcular_z_asm                                 ; me traigo el z para saber dònde indexar en OT
    // calcular z es void, necesito capturar el valor de z 
    
    // el error es que tengo que acceder al nodo en la display_list -> capturar su z -> offsetear en el array de punteros
    // para ello :
    xor r8, r8
    mov r8, rbx                                         //estamos al principio de la table
    xor rdx, rdx 
    mov dl, byte[r12 + NODO_Z]                          //capturo z del nodo display list
    shl rdx, 3                                          //multiplico por 8 para moverme adecuadamente en el array de punteros
    add r8, rdx                                         //me quiero parar en el puntero al nivel respectivo de z
    // me guardo r8 en la pila push r8
    // esto nos garantiza estar en arr[z] correcta ( es decir mirar al inicio de la lista enlazada)
    // pedimos memoria
    xor rdi, rdi
    mov rdi, TAM_NODO_T

    call malloc

    // hacemos las asignaciones adecuadas
    mov [rax + NODO_T_DISPLAY], r12
    xor r8, r8                      // uso r8 para poner el 0 
    mov [rax + NODO_T_SIG], r8      //pongo null en sig 

    pop r8                          //sigue teniendo el puntero offseteado en nuestra table.

    mov rdi, [r8] 
    cmp rdi, 0                      //chequeamos si el puntero del array es null    
    // vemos a dónde saltar : caso en q la lista enlazada es vacía o caso en que haya al menos un elemento
    je null_ptr

    lista_no_vacia:
    mov r9, [r8]                    // como no es nulo el ptr, queremos ver si su siguiente lo es
    add r9, NODO_T_SIG              // offset
    cmp r9, 0                       
    je enlazar                      
    mov r8, r9                      // actualizamos r8 para que tome el valor del ptr -> siguiente
    jmp lista_no_vacia          

    enlazar:
    mov r9, [r8]                    // en el contenido de r8 tenemos el ultimo nodo
    mov [r9 + NODO_T_SIG], rax      // rax tiene la dire de new, asignamos al sig del ultimo nodo, el ptr al nuevo
    jmp sigDisplay      

    null_ptr:
    mov [r8], rax                                   ;rax tiene la direccion de new. Y la guardamos en la direccion de r8 que es el elemento de la table
    
    sigDisplay:
    mov r12, [r12 + DISPLAY_LIST_SIGUIENTE]         ;vamos al sig nodo de la display list
    jmp ciclo
    
    fin:
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret

