#include "vector.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>


vector_t* nuevo_vector(void) {
    vector_t *ptrVector;
    ptrVector = malloc(sizeof(vector_t));

    if (ptrVector == NULL)
    {
        return NULL;
    }
    /* retorna un vector de capacidad 2 */
    ptrVector->capacity = 2;
    ptrVector->size = 0;
    ptrVector->array = malloc(ptrVector->capacity * sizeof(uint32_t));

    return ptrVector;
}

uint64_t get_size(vector_t* vector) {
    return vector->size;
}

void push_back(vector_t* vector, uint32_t elemento) {
    
    if (vector->size < vector->capacity)
    {
        vector->array[vector->size] = elemento;
    }
    else
    {
        vector->capacity++;
        /* hay q usar realloc corte cheto*/
        /* La función realloc en C se utiliza para cambiar el tamaño de un bloque de memoria previamente asignado dinámicamente */
        /* void* realloc(void* ptr, size_t size);  */
        uint32_t* nuevo_array = realloc(vector->array, vector->capacity * sizeof(uint32_t));
        /* cambiamos el puntero por el nuevo */
        vector->array = nuevo_array;
        vector->array[vector->size] = elemento;
    }
    vector->size++;
    
}

int son_iguales(vector_t* v1, vector_t* v2) {
    if (v1->size != v2->size)
    {
        return 0;
    }
    
    for (uint32_t i = 0; i < v1->size; i++)
    {
        if (v1->array[i] != v2->array[i])
        {
            return 0;
        }
    }
    return 1;
    
}

uint32_t iesimo(vector_t* vector, size_t index) {
    return vector->array[index];
}

void copiar_iesimo(vector_t* vector, size_t index, uint32_t* out){
    /* *out se refiere al valor al que apunta el puntero out */
    /* asignamos el valor retornado por la función iesimo(vector, index) al espacio de memoria apuntado por out */
    *out = iesimo(vector, index);
}


// Dado un array de vectores, devuelve un puntero a aquel con mayor longitud.
vector_t* vector_mas_grande(vector_t** array_de_vectores, size_t longitud_del_array) {
    /* tengo un puntero (pos de memoria) que apunta a   */
    /* otro puntero(pos de memoria) que apunta al inicio del vector  */
    vector_t* max = array_de_vectores[0];
    int i = 0;

    
    if (array_de_vectores[0] == NULL)
    {
        return NULL;
    }

    while (array_de_vectores[i] != NULL )
    {
        if (array_de_vectores[i]->size > max->size)
        {
            max = array_de_vectores[i];
        }
        i++;
        
    }
    return max;
}
