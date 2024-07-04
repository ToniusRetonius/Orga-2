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
  ordering_table_t* ot = malloc(16);
  ot->table_size = table_size;
  ot->table = calloc(table_size, 8);
  return ot;
}

void calcular_z(nodo_display_list_t* nodo, uint8_t z_size) {
  nodo->z = nodo->primitiva(nodo->x,nodo->y, z_size);
}

void ordenar_display_list(ordering_table_t* ot, nodo_display_list_t* display_list) {
  nodo_display_list_t* actual = display_list;

  while (actual != NULL)
  {
    // calculamos z
    calcular_z(actual, ot->table_size);
    uint8_t z = actual->z;

    // creamos el nuevo nodo_ot
    nodo_ot_t* nuevo = malloc(sizeof(nodo_ot_t));
    nuevo->display_element = actual;
    nuevo->siguiente = NULL;

    // recorremos la lista enlazada
    nodo_ot_t* nodo_actual = ot->table[z];

    if (nodo_actual == NULL)
    {
      ot->table[z] = nuevo;
    }
    else
    {
    
    while (nodo_actual->siguiente != NULL)
    {
      nodo_actual = nodo_actual->siguiente;
    }
    // agregamos a la enlazada
    nodo_actual->siguiente = nuevo;
    }
    
    // next
    actual = actual->siguiente;
  }
}
// en C van todas bien