; ** por compatibilidad se omiten tildes **
; ==============================================================================
; TALLER System Programming - ORGANIZACION DE COMPUTADOR II - FCEN
; ==============================================================================

%include "print.mac"
global start

; COMPLETAR - Agreguen declaraciones extern según vayan necesitando
; traemos de A20.asm la fn enable
extern A20_enable

; nos traemos el valor del archivo C : gdt_descriptor_t GDT_DESC = {sizeof(gdt) - 1, (uint32_t)&gdt};
extern GDT_DESC

; para hacer el print de la pantallita traemos de screen.c la fn screen_draw_layout 
extern screen_draw_layout
extern screen_draw_box

; tenemos que cargar la IDT, la traemos de idt.c : idt_descriptor_t IDT_DESC = {sizeof(idt) - 1, (uint32_t)&idt};
extern IDT_DESC
extern idt_init

; tenemos que inicializar los PICS 
extern pic_reset
extern pic_enable

; traemos de mmu.c el puntero al directorio de pagina del kernel
extern KERNEL_PAGE_DIR
extern mmu_init_kernel_dir
extern mmu_init_task_dir
extern copy_page

; COMPLETAR - Definan correctamente estas constantes cuando las necesiten
%define CS_RING_0_SEL 0x0008    ; dire code 0 en code segment de 16 bits
%define DS_RING_0_SEL 0x0018    ; dire data 0 para todo registro de segmento de 16 bits


BITS 16
;; Saltear seccion de datos
jmp start

;;
;; Seccion de datos.
;; -------------------------------------------------------------------------- ;;
start_rm_msg db     'Iniciando kernel en Modo Real'
start_rm_len equ    $ - start_rm_msg

start_pm_msg db     'Iniciando kernel en Modo Protegido'
start_pm_len equ    $ - start_pm_msg

;;
;; Seccion de código.
;; -------------------------------------------------------------------------- ;;

;; Punto de entrada del kernel.
BITS 16
start:
    ; COMPLETAR - Deshabilitar interrupciones
    cli

    ; Cambiar modo de video a 80 X 50
    mov ax, 0003h
    int 10h ; set mode 03h
    xor bx, bx
    mov ax, 1112h
    int 10h ; load 8x8 font

    ; COMPLETAR - Imprimir mensaje de bienvenida - MODO REAL
    ; (revisar las funciones definidas en print.mac y los mensajes se encuentran en la
    ; sección de datos)
    ; print_text_rm Puntero al mensaje, Longitud del mensaje, Color, Fila, Columna
    ; ver macro 'Iniciando Kernel en Modo Real'
    ; Solo funciona en MODO REAL.
    ; TODOS los parámetros son de 16 BITS.
    print_text_rm start_rm_msg, start_rm_len, 0x0F, 0 , 0

    ; COMPLETAR - Habilitar A20
    ; (revisar las funciones definidas en a20.asm)
    call A20_enable

    ; COMPLETAR - Cargar la GDT
    ; lgdt Load Global/Interrupt Descriptor Table Register (ver Felix C)
    lgdt [GDT_DESC]
    bpointGDT:
    ; COMPLETAR - Setear el bit PE del registro CR0 ( Protection Enable (PE) = 1) 
    ; detalle: solo tocamos ese bit, recordar que sino se ignora o #GP exception
    xor eax, eax
    mov eax, cr0
    or eax, 1
    mov cr0, eax

    ; COMPLETAR - Saltar a modo protegido (far jump)
    ; (recuerden que un far jmp se especifica como jmp CS_selector:address)
    ; Pueden usar la constante CS_RING_0_SEL definida en este archivo
    ; como llegamos al valor del GDT_CODE_0_SEL ? 
    ; tenemos que cargar CS con ese valor?
    ; : que direccion ponemos? modo_protegido?
    jmp CS_RING_0_SEL:modo_protegido

BITS 32
modo_protegido:
    ; COMPLETAR - A partir de aca, todo el codigo se va a ejectutar en modo protegido
    ; Establecer selectores de segmentos DS, ES, GS, FS y SS en el segmento de datos de nivel 0
    ; Pueden usar la constante DS_RING_0_SEL definida en este archivo
    xor eax,eax
    mov eax, DS_RING_0_SEL
    mov ds, eax
    mov es, eax
    mov gs, eax
    mov fs, eax
    mov ss, eax

    ; COMPLETAR - Establecer el tope y la base de la pila
    ; modificamos esp, ebp
    ; dire = 0x25000
    mov esp, 0x25000
    mov ebp, 0x25000

    ; COMPLETAR - Imprimir mensaje de bienvenida - MODO PROTEGIDO
    ; print_text_pm Puntero al mensaje, Longitud del mensaje, Color, Fila, Columna
    ; ver macro 'Iniciando Kernel en Modo Protegido'
    ; Solo funciona en MODO PROTEGIDO.
    ;;* TODOS los parámetros son de 32 BITS.
    print_text_pm start_pm_msg, start_pm_len, 0x01, 0 , 0

    ; COMPLETAR - Inicializar pantalla
    ; llamamos a la funcion  que hace el print desde screen.c
    call screen_draw_layout

    ; Inicializar IDT y cargarla con lidt
    call idt_init
    lidt [IDT_DESC]
    bpointIDT:

    ; Inicializamos los PICS
    call pic_reset                ; remapea
    call pic_enable               ; habilita los pics

    ; antes de habilitar las interrupciones vamos a inicializar la paginacion
    call mmu_init_kernel_dir

    ; cargamos la dire del Page Directory en cr3
    mov cr3, eax
    
    ; seteamos cr0 el bit 31 para habilitar paginacion (PG)
    mov eax, cr0
    or eax, 0x80000000          
    mov cr0, eax
    bpointpaging:

    ; prueba mmu_map_page
    ; push 0x3                   ; attrs
    ; push phy                   ; dire fisica
    ; push virt                  ; dire virtual
    ; mov eax, cr3               ; conservamos el del kernel
    ; push cr3                   ; cr3
    ; call mmu_map_page          ; void
    ; add esp, 16                ; pusheamos 4 valores de 4 bytes 
    bpointmappage:

    ; pusheamos de derecha a izq los param en la pila
    ; las direcciones estan dentro del area mapeada sino, page fault
    ; la otra manera es asignar dentro de copy_page en mmu.c una variable 
    ; src[0] = 8
    ; desp del loop pedir  dst[0] y chequear que sea 8  
    push 0x00108000             ; src 
    push 0x00103000             ; dst
    mov byte [0x00108000], 8    ; src
    mov byte [0x00103000], 0    ; dst
    call copy_page
    add esp, 8                  ; alineamos la pila
    bpointcopypage:
    
    ; prueba init_task_dir
    mov eax, cr3            
    push eax                    ; guardamos el cr3 del kernel
    push 0x18000                ; pusheamos la supuesta phy_addr
    call mmu_init_task_dir      ; retorna la dire del page directory (para cr3 de la tarea)
    add esp, 4
    pop eax
    mov cr3, eax                ; reasignamos el cr3 del kernel
    bpointinittask:

    mov byte [0x07001000], 0xff ; escritura en alguna parte de la memoria compartida (deberia aparecer 'Atendiendo page fault')
    mov byte [0x07002000], 0xff ; escritura 2 (sin page fault)
    
    sti                         ; habilita interruciones
    bpoint88:
    int 88
    bpoint98:
    int 98

    ; Ciclar infinitamente 
    mov eax, 0xFFFF
    mov ebx, 0xFFFF
    mov ecx, 0xFFFF
    mov edx, 0xFFFF
    jmp $

;; -------------------------------------------------------------------------- ;;

%include "a20.asm"
