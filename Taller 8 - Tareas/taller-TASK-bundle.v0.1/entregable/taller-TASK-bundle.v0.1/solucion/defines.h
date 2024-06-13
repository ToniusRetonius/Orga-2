
/* ** por compatibilidad se omiten tildes **
================================================================================
 TALLER System Programming - ORGANIZACION DE COMPUTADOR II - FCEN
================================================================================

  Definiciones globales del sistema.
*/

#ifndef __DEFINES_H__
#define __DEFINES_H__

/* Misc */
/* -------------------------------------------------------------------------- */
// Y Filas
#define SIZE_N 40
#define ROWS   SIZE_N

// X Columnas
#define SIZE_M 80
#define COLS   SIZE_M

/* Indices en la gdt */
/* -------------------------------------------------------------------------- */
#define GDT_COUNT         35

#define GDT_IDX_NULL_DESC 0
#define GDT_IDX_CODE_0 1
#define GDT_IDX_CODE_3 2
#define GDT_IDX_DATA_0 3
#define GDT_IDX_DATA_3 4
#define GDT_IDX_VIDEO  5


/* Offsets en la gdt */
/* -------------------------------------------------------------------------- */
#define GDT_OFF_NULL_DESC (GDT_IDX_NULL_DESC << 3)
#define GDT_OFF_VIDEO  (GDT_IDX_VIDEO << 3)

/* Valores para los selectores de segmento de la GDT
 * Definirlos a partir de los índices de la GDT, definidos más arriba
 * Hint: usar operadores "<<" y "|" (shift y or) */
#define GDT_CODE_0_SEL (GDT_IDX_CODE_0 << 3)
#define GDT_DATA_0_SEL (GDT_IDX_DATA_0 << 3)
/* | simboliza el OR en bits. Dado que es nivel 3 precisamos que los últimos 2 bits sea el privilegio 0x3*/
#define GDT_CODE_3_SEL ((GDT_IDX_CODE_3 << 3) | 0x3)
#define GDT_DATA_3_SEL ((GDT_IDX_DATA_3 << 3) | 0x3)

// Macros para trabajar con segmentos de la GDT.

// SEGM_LIMIT_4KIB es el limite de segmento visto como bloques de 4KIB
// principio del ultimo bloque direccionable.
#define GDT_LIMIT_4KIB(X)  (((X) / 4096) - 1)
#define GDT_LIMIT_BYTES(X) ((X)-1)

#define GDT_LIMIT_LOW(limit)  (uint16_t)(((uint32_t)(limit)) & 0x0000FFFF)
#define GDT_LIMIT_HIGH(limit) (uint8_t)((((uint32_t)(limit)) >> 16) & 0x0F)

#define GDT_BASE_LOW(base)  (uint16_t)(((uint32_t)(base)) & 0x0000FFFF)
#define GDT_BASE_MID(base)  (uint8_t)((((uint32_t)(base)) >> 16) & 0xFF)
#define GDT_BASE_HIGH(base) (uint8_t)((((uint32_t)(base)) >> 24) & 0xFF)

#define DESC_TYPE_EXECUTE_READ 0xA
#define DESC_TYPE_READ_WRITE   0x2
#define DESC_TYPE_32BIT_TSS    0x9

#define DESC_CODE_DATA 1
#define DESC_SYSTEM    0

#define FLAT_SEGM_SIZE  (817U * (1 << 20))
#define VIDEO_SEGM_SIZE (80U * 50 * 2)

/* Direcciones de memoria */
/* -------------------------------------------------------------------------- */

// direccion fisica de comienzo del bootsector (copiado)
#define BOOTSECTOR 0x00001000
// direccion fisica de comienzo del kernel
#define KERNEL 0x00001200
// direccion fisica del buffer de video
#define VIDEO 0x000B8000
// direccion fisica de la pagina de memoria compartida
#define SHARED 0x0001D000


/* MMU */
/* -------------------------------------------------------------------------- */
/* Definan:
Se tiene la direccion virtual, 32 bits. Esos se dividen en 3 partes :
    - [11:0] offset (para hallar la dire fisica dentro de la 4KB Page)
    - [21:12] indice en la tabla de paginas (Page Table)
    - [31:22] indice en el directorio de paginas (Page Directory)

VIRT_PAGE_OFFSET(X) devuelve el offset dentro de la página, donde X es una dirección virtual
VIRT_PAGE_TABLE(X)  devuelve la page table entry correspondiente, donde X es una dirección virtual
VIRT_PAGE_DIR(X)    devuelve el page directory entry, donde X es una dirección virtual
CR3_TO_PAGE_DIR(X)  devuelve el page directory, donde X es el contenido del registro CR3
MMU_ENTRY_PADDR(X)  devuelve la dirección física de la base de un page frame o de un page table, donde X es el campo de 20 bits en una PTE o PDE

*/
#define VIRT_PAGE_OFFSET(X) ((X) & 0xFFF)         // nos quedamos con los 12 bits de offset del inicio de la pagina para tener la dire fisica
#define VIRT_PAGE_TABLE(X)  (((X) >> 12) & 0x3FF) // nos quedamos con el offset de la Page Table que son los 10 bits del medio
#define VIRT_PAGE_DIR(X)    ((X) >> 22)           // nos quedamos con los 10 bits del offset del Page Directory
#define CR3_TO_PAGE_DIR(X)  ((X) & 0xFFFFF000)    // nos quedamos con 32 bits pero solo nos interesan los 20 valores altos (multiplo de 4kb)
#define MMU_ENTRY_PADDR(X)  ((X) << 12)           // extendemos a 32 bits el valor contenido en una entrada del Page Directory o Table


#define MMU_P (1 << 0)  // siempre es 1 (indica traduccion valida)
#define MMU_W (1 << 1)  // Read - Write
#define MMU_U (1 << 2)  // usuario 

#define PAGE_SIZE 4096

// direccion virtual del codigo
#define TASK_CODE_VIRTUAL 0x08000000
#define TASK_CODE_PAGES   2
#define TASK_STACK_BASE   0x08003000
#define TASK_SHARED_PAGE  0x08003000

// direccion virtual de memoria compartida on demand
#define ON_DEMAND_MEM_START_VIRTUAL    0x07000000
#define ON_DEMAND_MEM_END_VIRTUAL      0x07000FFF
#define ON_DEMAND_MEM_START_PHYSICAL   0x03000000

/* Direcciones fisicas de directorios y tablas de paginas del KERNEL */
/* -------------------------------------------------------------------------- */
#define KERNEL_PAGE_DIR     (0x00025000)
#define KERNEL_PAGE_TABLE_0 (0x00026000)
#define KERNEL_STACK        (0x00025000)

#endif //  __DEFINES_H__
