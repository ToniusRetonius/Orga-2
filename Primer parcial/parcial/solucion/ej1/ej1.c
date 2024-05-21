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
  ordering_table_t* nuevo = malloc(sizeof(ordering_table_t));
  nuevo->table_size = table_size;
  nuevo->table = calloc(table_size, sizeof(uint64_t));
  return nuevo;
}

void calcular_z(nodo_display_list_t* nodo, uint8_t z_size) {
  uint8_t x = nodo->x;
  uint8_t y = nodo->y;
  uint8_t z = nodo->primitiva(x,y,z_size);
}

void ordenar_display_list(ordering_table_t* ot, nodo_display_list_t* display_list) {

  nodo_display_list_t* actual = display_list;
  uint8_t z_size = ot->table_size;

  while (actual->siguiente != NULL)
  {
    uint8_t z = actual->primitiva(actual->x, actual->y, z_size);
    nodo_ot_t*lista = ot->table[z]; 
    
    nodo_ot_t* nodo_lista_act = lista->siguiente;
    while (nodo_lista_act != NULL)
    {
      nodo_lista_act = nodo_lista_act->siguiente;
    }
    nodo_ot_t* nuevo_nodo = malloc(sizeof(nodo_ot_t));
    nodo_lista_act->siguiente = nuevo_nodo;
    nuevo_nodo->display_element = actual;
    nuevo_nodo->siguiente = NULL;

    actual = actual->siguiente;
  }
  
}

