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
  // pd_entry_t* kpd = (pd_entry_t*)KERNEL_PAGE_DIR;
  // pt_entry_t* kpt = (pt_entry_t*)KERNEL_PAGE_TABLE_0;
  // zero_page(paddr_t addr)
  zero_page((paddr_t)kpd);
  zero_page((paddr_t)kpt);

  // queremos inicializar una entrada de directorio
  // como es Kernel el U / S es cero, esta present y es de lecto-escritura
  kpd[0].attrs = MMU_P | MMU_W ;     
  // 
  kpd[0].pt = VIRT_PAGE_TABLE((uint32_t)kpt);  

  // queremos incialiazar las entradas de la tabla de esa entrada de directorio
  for (int i = 0; i < 1024; i++)
  {
    kpt[i].attrs = MMU_P | MMU_W;
    // como es identity mapping coincide el numero de pagina ;)
    kpt[i].page =  i; 
    // recordar que es una dire de 32 que la movemos 12 a la derecha ( podemos tomar i y alcanza )
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
  pd_entry_t* base_directory = (pd_entry_t*)CR3_TO_PAGE_DIR(cr3);
  uint32_t dir = (uint32_t)VIRT_PAGE_DIR(virt);

  // paso 2 : chequear si existe la entrada (mirar el bit 0 de present)
  if ((base_directory[dir].attrs & MMU_P) != 0x1)
  {
    // paso 3 : asignarle el puntero a la tabla (pidiendo memoria del area libre kernel)
    // pasamos la dire fisica de 32 a 20 bits (recordar que esto se debe a que las paginas estan alineadas a su tama;o)
    // 4kb = 2 ^ 12 eso quiere decir que los primeros 12 son ceros y aprovechamos ese espacio para attrs
    // por eso el puntero son solo esos 20 mas significativos 
    base_directory[dir].pt = (mmu_next_free_kernel_page() >> 12); 
  }
  // si existe la entrada, le mantenemos los atributos y hacemos un or con los nuevos
  base_directory[dir].attrs = base_directory[dir].attrs | attrs;

  // paso 4 : pararnos en la entrada adecuada de la Page Table
  // esa pagina nueva capturada, la tenemos que pasar a un puntero de 32 bits para poder acceder en ese lugar
  pt_entry_t* pt_puntero =  (pt_entry_t*)((uint32_t)(base_directory[dir].pt  << 12)); 
  // offset en la page table capturado de la virtual (son los 10 bits del medio , shifteamos 12 y hacemos & 0x3FF)
  uint32_t pt_offset = VIRT_PAGE_TABLE(virt);
  
  // paso 5 : crear la entrada de la Page Table
  pt_entry_t nueva;
  // pasamos de 32 bits a 20 bits. Misma razon que antes, las paginas estan alineadas a posiciones multiplo de 4KB
  nueva.page = (phy >> 12);      
  // el resto lo guardamos para los attrs
  nueva.attrs = attrs;    
  
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
  // tlbflush para eliminar las traducciones de la tlb
  tlbflush();

  // directorio
  pd_entry_t* directorio = (pd_entry_t*)CR3_TO_PAGE_DIR(cr3);
  uint32_t offset_directorio = (uint32_t)VIRT_PAGE_DIR(virt);
  
  // tabla
  pt_entry_t* page_table = (pt_entry_t*)((uint32_t)(directorio[offset_directorio].pt << 12));
  uint32_t offset_page_table = VIRT_PAGE_TABLE(virt);

  // bit present en 0 en la entrada de tabla (con esto desmapeamos)
  page_table[offset_page_table].attrs = 0;

  // nos pide retornar la dirección física de la página desvinculada
  // recordar que la entrada de la tabla en su campo .page es de 20 bits y queremos la fisica << 12 y listo
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
  paddr_t dir = mmu_next_free_kernel_page();
  
  // identity mapping del kernel
  // esto se debe a que la tarea en su estructura tiene que tener mapeado el kernel para las rutinas de atencion, excepciones
  // y todos los procesos vinculados a servicios del sistema que requieran de privilegios
  
  for (int32_t i = 0; i < 1024; i++) {
    // los primeros 4MB de Kernel, la estructura de paginacion de la tarea es entonces 
    // de 0x000000 hasta 0x3FFFFF de fisica a 0x000000 hasta 0x3FFFFF de virtual 
    mmu_map_page((uint32_t) dir, (vaddr_t) (i * PAGE_SIZE), (paddr_t) (i * PAGE_SIZE), MMU_P | MMU_W);
  }

  // mapeamos las dos de codigo read-only user
  mmu_map_page((uint32_t) dir , (vaddr_t) TASK_CODE_VIRTUAL, phy_start, MMU_P | MMU_U);
  mmu_map_page((uint32_t) dir , (vaddr_t) (TASK_CODE_VIRTUAL + PAGE_SIZE), (phy_start + PAGE_SIZE), MMU_P | MMU_U);

  // mapeamos el stack con permisos de lecto-escritura 
  // la direccion fisica de la pagina debe obtenerse del area libre de tareas
  // la direccion virtual del stack es 0x08002000 dado que su base es 0x08003000 (4096 bytes mas abajo) 
  // ( esto es por la implementacion de stack que hacemos add para sacar y sub para agregar)
  mmu_map_page((uint32_t) dir, 0x08002000, mmu_next_free_user_page(), MMU_P | MMU_U | MMU_W);

  // mapeamos la pagina shared read-only nivel 3 
  // la direccion fisica de la pagina de memoria compartida 0x0001D000 
  // la direccion virtual de memoria compartida 0x08003000
  mmu_map_page((uint32_t) dir, (vaddr_t) TASK_SHARED_PAGE, (paddr_t) SHARED, MMU_P | MMU_U); 

  return (paddr_t) dir;  
}

// COMPLETAR: devuelve true si se atendió el page fault y puede continuar la ejecución 
// y false si no se pudo atender 
bool page_fault_handler(vaddr_t virt) {
  print("Atendiendo page fault...", 0, 0, C_FG_WHITE | C_BG_BLACK);
  // acceso dentro del area on-demand
  if (ON_DEMAND_MEM_START_VIRTUAL <= virt || virt <= ON_DEMAND_MEM_END_VIRTUAL) {
      // mapeamos la pagina
      mmu_map_page(rcr3(), virt, (paddr_t) ON_DEMAND_MEM_START_PHYSICAL, MMU_P | MMU_U | MMU_W);
      return true;
  }
  return false;
}