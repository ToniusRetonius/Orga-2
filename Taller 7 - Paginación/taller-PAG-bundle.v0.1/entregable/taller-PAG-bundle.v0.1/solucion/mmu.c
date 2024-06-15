/* ** por compatibilidad se omiten tildes **
================================================================================
 TRABAJO PRACTICO 3 - System Programming - ORGANIZACION DE COMPUTADOR II - FCEN
================================================================================

  Definicion de funciones del manejador de memoria
*/

#include "mmu.h"
#include "i386.h"

#include "kassert.h"

static pd_entry_t* kpd = (pd_entry_t*)KERNEL_PAGE_DIR;
static pt_entry_t* kpt = (pt_entry_t*)KERNEL_PAGE_TABLE_0;

static const uint32_t identity_mapping_end = 0x003FFFFF;
static const uint32_t user_memory_pool_end = 0x02FFFFFF;

static paddr_t next_free_kernel_page = 0x100000;
static paddr_t next_free_user_page = 0x400000;

/**
 * kmemset asigna el valor c a un rango de memoria interpretado
 * como un rango de bytes de largo n que comienza en s
 * @param s es el puntero al comienzo del rango de memoria
 * @param c es el valor a asignar en cada byte de s[0..n-1]
 * @param n es el tamaño en bytes a asignar
 * @return devuelve el puntero al rango modificado (alias de s)
*/
static inline void* kmemset(void* s, int c, size_t n) {
  uint8_t* dst = (uint8_t*)s;
  for (size_t i = 0; i < n; i++) {
    dst[i] = c;
  }
  return dst;
}

/**
 * zero_page limpia el contenido de una página que comienza en addr
 * @param addr es la dirección del comienzo de la página a limpiar
*/
static inline void zero_page(paddr_t addr) {
  kmemset((void*)addr, 0x00, PAGE_SIZE);
}


void mmu_init(void) {}


/**
 * mmu_next_free_kernel_page devuelve la dirección física de la próxima página de kernel disponible. 
 * Las páginas se obtienen en forma incremental, siendo la primera: next_free_kernel_page
 * @return devuelve la dirección de memoria de comienzo de la próxima página libre de kernel
 */
paddr_t mmu_next_free_kernel_page(void) {
  // capturamos la actual
  paddr_t next = next_free_kernel_page;
  // actualizamos la siguiente libre
  next_free_kernel_page += PAGE_SIZE;
  // devolvemos la actual
  return next;
}

/**
 * mmu_next_free_user_page devuelve la dirección de la próxima página de usuarix disponible
 * @return devuelve la dirección de memoria de comienzo de la próxima página libre de usuarix
 */
paddr_t mmu_next_free_user_page(void) {
  // capturamos la actual
  paddr_t next = next_free_user_page;
  // actualizamos la siguiente libre
  next_free_user_page += PAGE_SIZE;
  // devolvemos la actual
  return next;
}

/**
 * mmu_init_kernel_dir inicializa las estructuras de paginación vinculadas al kernel y
 * realiza el identity mapping
 * @return devuelve la dirección de memoria de la página donde se encuentra el directorio
 * de páginas usado por el kernel
 */
paddr_t mmu_init_kernel_dir(void) {
  // es buena practica limpiar la pagina y no reutilizar
  zero_page(kpd);
  zero_page(kpt);

  // queremos inicializar una entrada de directorio
  pd_entry_t inicial;
  inicial.attrs = MMU_P | MMU_W ;     // como es Kernel el U / S es cero, esta present y es de lecto-escritura
  inicial.pt = ((uint32_t) kpt) >> 12;  // importante el uso del shift
  kpd[0] = inicial;
  // queremos incialiazar las entradas de la tabla de esa entrada de directorio
  for (int i = 0; i < 1024; i++)
  {
    pt_entry_t nueva;
    nueva.attrs = MMU_P | MMU_W;
    nueva.page =  i; 
    kpt[i] = nueva;
  }

  return (paddr_t) KERNEL_PAGE_DIR;
}

/**
 * mmu_map_page agrega las entradas necesarias a las estructuras de paginación de modo de que
 * la dirección virtual virt se traduzca en la dirección física phy con los atributos definidos en attrs
 * @param cr3 el contenido que se ha de cargar en un registro CR3 al realizar la traducción
 * @param virt la dirección virtual que se ha de traducir en phy
 * @param phy la dirección física que debe ser accedida (dirección de destino)
 * @param attrs los atributos a asignar en la entrada de la tabla de páginas
 */
void mmu_map_page(uint32_t cr3, vaddr_t virt, paddr_t phy, uint32_t attrs) {
  // paso 1 : hallar la entrada en el Page Directory
  pd_entry_t* base_directory = CR3_TO_PAGE_DIR(cr3);
  uint32_t dir = VIRT_PAGE_DIR(virt);

  // paso 2 : chequear si existe la entrada (mirar el bit 0 de present)
  if ((base_directory[dir].attrs & 0x1) != 0x1)
  {
    // paso 3 : si no existe hay que crear la entrada
    pd_entry_t nueva;
    nueva.attrs = attrs | MMU_P ; // ahora esta presente por cuestiones restriccion 
    nueva.pt = (mmu_next_free_kernel_page() >> 12); // le pasamos los 20 bits  que se ponen en el address de la tabla
    base_directory[dir] = nueva;
    // limpiamos la tabla ?
    zero_page((paddr_t)(nueva.pt) << 12); // extendemos a 32 bits para que limpie una pagina a partir de este puntero de 32 y crear la tabla
  }

  // paso 4 : pararnos en la entrada adecuada de la Page Table
  pt_entry_t* pt_puntero =  (pt_entry_t*)(base_directory[dir].pt  << 12);   // puntero a la tabla
  uint32_t pt_offset = VIRT_PAGE_TABLE(virt);
  
  // paso 5 : crear la entrada de la Page Table
  pt_entry_t nueva;
  nueva.attrs = attrs | MMU_P;    // atributos mas restrictivos
  nueva.page = (phy >> 12);      // pasamos de 32 bit a 20 bits
  
  pt_puntero[pt_offset] = nueva;

  // paso 6 : tlbflush() para no guardar una traduccion invalida
  tlbflush();
}

/**
 * mmu_unmap_page elimina la entrada vinculada a la dirección virt en la tabla de páginas correspondiente
 * @param virt la dirección virtual que se ha de desvincular
 * @return la dirección física de la página desvinculada
 */
paddr_t mmu_unmap_page(uint32_t cr3, vaddr_t virt) {
  // puntero al directorio
  pd_entry_t* directorio = CR3_TO_PAGE_DIR(cr3);
  uint32_t offset_directorio = VIRT_PAGE_DIR(virt);
  // puntero a la tabla
  pt_entry_t* page_table = (directorio[offset_directorio].pt << 12);
  uint32_t offset_page_table = VIRT_PAGE_TABLE(virt);
  // bit present en 0 en la entrada de tabla
  page_table[offset_page_table].attrs = 0x2;
  // tlbflush
  tlbflush();
  // nos pide retornar la dirección física de la página desvinculada
  return (paddr_t)(page_table[offset_page_table].page << 12);
}

#define DST_VIRT_PAGE 0xA00000
#define SRC_VIRT_PAGE 0xB00000

/**
 * copy_page copia el contenido de la página física localizada en la dirección src_addr a la página física ubicada en dst_addr
 * @param dst_addr la dirección a cuya página queremos copiar el contenido
 * @param src_addr la dirección de la página cuyo contenido queremos copiar
 *
 * Esta función mapea ambas páginas a las direcciones SRC_VIRT_PAGE y DST_VIRT_PAGE, respectivamente, realiza
 * la copia y luego desmapea las páginas. Usar la función rcr3 definida en i386.h para obtener el cr3 actual
 */
void copy_page(paddr_t dst_addr, paddr_t src_addr) {
  // mapeamos dst a DST_VIRT_PAGE
  mmu_map_page(rcr3(), DST_VIRT_PAGE, dst_addr, MMU_P | MMU_W); // la queremos escribir
  // mapeamos src a SRC_VIRT_PAGE
  mmu_map_page(rcr3(), SRC_VIRT_PAGE, src_addr, MMU_P );

  // copiamos byte a byte
  for (int i = 0; i < PAGE_SIZE; i++)
  {
    // casteamos DST_VIRT_PAGE a un puntero a 1 byte, le sumamos el offset y desreferenciamos al puntero 
    *((uint8_t*) DST_VIRT_PAGE + i) = *((uint8_t*) SRC_VIRT_PAGE + i); 
  }
  
  // unmapping
  mmu_unmap_page(rcr3(), DST_VIRT_PAGE);
  mmu_unmap_page(rcr3(), SRC_VIRT_PAGE);
}

 /**
 * mmu_init_task_dir inicializa las estructuras de paginación vinculadas a una tarea cuyo código se encuentra en la dirección phy_start
 * @pararm phy_start es la dirección donde comienzan las dos páginas de código de la tarea asociada a esta llamada
 * @return el contenido que se ha de cargar en un registro CR3 para la tarea asociada a esta llamada
 */

paddr_t mmu_init_task_dir(paddr_t phy_start) {
  // necesitamos dos paginas para directorio y tabla
  pd_entry_t* dir = mmu_next_free_kernel_page();
  pt_entry_t* table = mmu_next_free_kernel_page();
  
  // limpiamos la del directorio
  zero_page((paddr_t)dir);

  // mapeamos las dos de codigo read-only user
  mmu_map_page(dir , TASK_CODE_VIRTUAL, phy_start, MMU_U);
  mmu_map_page(dir , TASK_CODE_VIRTUAL + PAGE_SIZE, phy_start + PAGE_SIZE, MMU_U);

  // mapeamos el stack con permisos de lecto-escritura 
  // la pagina fisica debe obtenerse del area libre de tareas
  mmu_map_page(dir, 0x08002000, mmu_next_free_user_page(), MMU_U | MMU_W);

  // mapeamos la pagina shared read-only nivel 3 
  // las direcciones de memoria compartida fisica van desde 0x30000000 en adelante
  // las direcciones de memoria compartida virtual van desde 0x07000000 a 0x07000FFF
  mmu_map_page(dir, TASK_SHARED_PAGE, mmu_next_free_user_page(), MMU_U);

  return (paddr_t) dir;  
}

// COMPLETAR: devuelve true si se atendió el page fault y puede continuar la ejecución 
// y false si no se pudo atender
bool page_fault_handler(vaddr_t virt) {
  print("Atendiendo page fault...", 0, 0, C_FG_WHITE | C_BG_BLACK);

  if (ON_DEMAND_MEM_START_VIRTUAL <= virt && virt <= ON_DEMAND_MEM_END_VIRTUAL) 
  {
    // mapeamos
    mmu_map_page(rcr3(), virt, mmu_next_free_user_page(), MMU_U | MMU_W);
    return true;
  }
  return false;
}
