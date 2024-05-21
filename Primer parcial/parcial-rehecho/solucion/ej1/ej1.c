#include "ej1.h"

nodo_display_list_t* inicializar_nodo(
  uint8_t (*primitiva)(uint8_t x, uint8_t y, uint8_t z_size),
  uint8_t x, uint8_t y, nodo_display_list_t* siguiente) {
    nodo_display_list_t* nodo = malloc(sizeof(nodo_display_list_t));
    nodo->primitiva = primitiva;
    nodo->x = x;
    nodo->y = y;
    nodo->z = 255;
    nodo->siguiente = siguiente;
    return nodo;
}

ordering_table_t* inicializar_OT(uint8_t table_size) {
  
  ordering_table_t* table = calloc(table_size, sizeof(nodo_ot_t*));
  return table;
}

void calcular_z(nodo_display_list_t* nodo, uint8_t z_size) {
  uint8_t z = nodo->primitiva(nodo->x, nodo->y, z_size);
  nodo->z = z;
}

void ordenar_display_list(ordering_table_t* ot, nodo_display_list_t* display_list) {
  nodo_display_list_t* actual = display_list;
  while(actual != NULL){
    //para c nodo de la display list calculamos z
    calcular_z(actual, ot->table_size);
    /* asignamos z al nodo actual */
    uint8_t z = actual->z;
    
    /* accedemos a la table en la posicion z */
    nodo_ot_t* ptr_enlazada = ot->table[z];
    /* pedimos memoria para el nuevo nodo en la lista enlazada*/
    nodo_ot_t* new = malloc(sizeof(nodo_ot_t));
    /* asignamos los valores a new */
    new->display_element = actual;
    new->siguiente = NULL;
    /* si el puntero en table es null */
    if (ptr_enlazada == NULL)
    {
      ptr_enlazada = new;
    }
    else
    {
    /* nodo actual de la lista enlazada */
    nodo_ot_t* actual_n = ptr_enlazada;
    while (actual_n->siguiente == NULL)
    {
      actual_n = actual_n->siguiente;
    }
      /* capturamos el ultimo nodo de la lista enlazada y le asignamos next como new */
      actual_n->siguiente = new;
    }

      actual = actual->siguiente;
    }
}
