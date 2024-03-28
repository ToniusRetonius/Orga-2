#include "lista_enlazada.h"
#include <stdlib.h>
#include <stdio.h>
#include <string.h>


lista_t* nueva_lista(void) {
    /* defino el puntero a un dato de tipo lista_t */
    lista_t *ptrListaEnlazada;
    /* con Malloc le pido memoria */
    /* con sizeOf mido ese tamaño */
    ptrListaEnlazada = malloc(sizeof(lista_t));

    if (ptrListaEnlazada == NULL)
    {
        return NULL; //salvamos el caso en el que malloc me devuelva un puntero a NULL.
    }
    
    /* en C la -> : define el atributo de donde el puntero apunta */
    /* como la creamo, le pongo */
    ptrListaEnlazada->head = NULL;

    /* me interesa devolver la posición */
    return ptrListaEnlazada;
}


uint32_t longitud(lista_t* lista) {
    // definimos la variable longitud la cual llevará cuenta de la cantidad de nodos por la que pasé
    uint32_t longitud = 0;
    /* actual es un puntero a un dato de tipo Nodo */
    nodo_t* actual = lista->head;

    while (actual != NULL)
    {   
        /* -> next es un atributo que apunta al siguiente nodo*/
        actual = actual->next;
        longitud++;        
    }

    return longitud;
}

void agregar_al_final(lista_t* lista, uint32_t* arreglo, uint64_t longitud) {
    
}

nodo_t* iesimo(lista_t* lista, uint32_t i) {
    /* qué pasa si está out-of-range i ? */
    if (i >= longitud(lista))
    {
        return NULL;
    }
    // definimos donde comenzamos a buscar el i-ésimo elemento (head de la lista)
    nodo_t* actual = lista->head;
    
    // definimos un contador el cual itera sobre la lista y comparamos con el i.
    uint32_t j = 0;

    while (j != i && actual != NULL)
    {
        actual = actual->next;
        j++;
    }
    // cuando llegamos al i-esimo nodo, salimos del while y devolvemos el nodo donde estamos parados
    return actual;
}

uint64_t cantidad_total_de_elementos(lista_t* lista) {    
    
}

void imprimir_lista(lista_t* lista) {
    nodo_t* actual = lista->head;
    uint64_t cantidad;
    // implemento cantidad total de elementos de forma recursiva.
    /*
         |  "NULL"    si actual = NULL
    f(n) | "| cantidad_total_de_elementos(actual) |" + imprimir_lista(actual.siguiente) si actual != NULL

    */
    if (actual == NULL)
    {
        
    }    

    /* mi idea es armarme una lista vacía, meterle los valores de las len de los nodos hasta q no haya más nodos*/
    nodo_t* actual = lista->head;
    
}

// Función auxiliar para lista_contiene_elemento
int array_contiene_elemento(uint32_t* array, uint64_t size_of_array, uint32_t elemento_a_buscar) {
}

int lista_contiene_elemento(lista_t* lista, uint32_t elemento_a_buscar) {

}


// Devuelve la memoria otorgada para construir la lista indicada por el primer argumento.
// Tener en cuenta que ademas, se debe liberar la memoria correspondiente a cada array de cada elemento de la lista.
void destruir_lista(lista_t* lista) {

}