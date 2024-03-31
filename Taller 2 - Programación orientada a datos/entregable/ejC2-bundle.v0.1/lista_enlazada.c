#include "lista_enlazada.h"
#include <stdlib.h>
#include <stdio.h>
#include <string.h>


lista_t* nueva_lista(void) {
    lista_t *ptrListaEnlazada;
    ptrListaEnlazada = malloc(sizeof(lista_t));

    if (ptrListaEnlazada == NULL)
    {
        return NULL; //salvamos el caso en el que malloc me devuelva un puntero a NULL.
    }
    ptrListaEnlazada->head = NULL;
    return ptrListaEnlazada;
}


uint32_t longitud(lista_t* lista) {
    // definimos la variable longitud la cual llevará cuenta de la cantidad de nodos por la que pasé
    uint32_t longitud = 0;
    nodo_t* actual = lista->head;

    while (actual != NULL) 
    {
        actual = actual->next;
        longitud++;        
    }
    /* printf("La lista tiene longitud : %u\n", longitud) */

    return longitud;
}

void agregar_al_final(lista_t* lista, uint32_t* arreglo, uint64_t longitud) {
    /* la idea es al ultimo nodo con nodo.next == NULL , le asignamos el nuevo nodo */

    /* 1_ creo el nodo */
    // [
    nodo_t* nuevo = malloc(sizeof(nodo_t));
    nuevo->arreglo = arreglo;
    nuevo->longitud = longitud;
    nuevo->next = NULL; 
    // ]


    /* 2_ hallar al nodo que apunta a NULL */
    nodo_t* ultimo = lista->head;
    while (ultimo->next != NULL)
    {
        ultimo = ultimo->next;
    }
    
    /* 3_ asignar al anterior al nuevo */
    ultimo->next = nuevo;
}

nodo_t* iesimo(lista_t* lista, uint32_t i) {
    // definimos donde comenzamos a buscar el i-ésimo elemento (head de la lista)
    nodo_t* actual = lista->head;
    // definimos un contador el cual itera sobre la lista y comparamos con el i.
    uint32_t j = 0;

    // salvamos el caso en que nos pasen un i que no esté en rango
    if (i >= longitud(lista) || i < 0)
    {
        return NULL;
    }
    
    while (j != i && actual != NULL)
    {
        actual = actual->next;
        j++;
    }
    /* estamos retornando la posicion de memoria donde esta ese i */
    return actual;
}

uint64_t cantidad_total_de_elementos(lista_t* lista) {    
    uint64_t sumaTotal = 0;
    nodo_t* actual = lista->head;

    while(actual != NULL){
        sumaTotal += actual->longitud;
        actual = actual->next;
    } 
    /*printf("Cantidad total de elementos en la lista: %lu\n", sumaTotal); */
    return sumaTotal;    
}

void imprimir_lista(lista_t* lista) {
    nodo_t* actual = lista->head;

    while (actual != NULL)
    {   
        printf("| %d | -> ", actual->longitud);
        actual = actual->next;
    }
    printf("null\n");
}

// Función auxiliar para lista_contiene_elemento -> O(n) buscar elemento
int array_contiene_elemento(uint32_t* array, uint64_t size_of_array, uint32_t elemento_a_buscar) {    
    for (uint64_t i = 0; i < size_of_array; i++)
    {
        if (array[i] == elemento_a_buscar)
        {
            return 1;
        }   
    }
    return 0;
}

int lista_contiene_elemento(lista_t* lista, uint32_t elemento_a_buscar) {
    nodo_t* actual = lista->head;

    if (actual == NULL)
    {
        return 0;
    }
    
    while (actual != NULL)
    {
        if (array_contiene_elemento(actual->arreglo, actual->longitud, elemento_a_buscar) == 1)
        {
            return 1;
        }
        actual = actual->next;
    }

    return 0;
}


// Devuelve la memoria otorgada para construir la lista indicada por el primer argumento.
// Tener en cuenta que ademas, se debe liberar la memoria correspondiente a cada array de cada elemento de la lista.
void destruir_lista(lista_t* lista) {
    nodo_t* actual = lista->head;
    nodo_t* tmp;
    while (actual != NULL)
    {
        tmp = actual->next;
        free(actual->arreglo);
        free(actual);
        actual = tmp;
    }
    
    free(lista);
}