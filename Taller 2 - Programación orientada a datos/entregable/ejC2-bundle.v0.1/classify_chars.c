#include "classify_chars.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

/* tenemos que clasificar un string en vocales y consonantes */
/* para eso tenemos que setear el campo 
    typedef struct classifier_s {
        char** vowels_and_consonants;
        char* string;
    } classifier_t;
 vowels_and_consonants de manera que : 
 vowels and consonants[0] queden todas las vocales del string
 vowels and consonants[1] queden las consonantes.
*/

int esVocal(char letra){
    switch (letra)
    {
    case 'a': 
        return 1;
    case 'e':
        return 1;
    case 'i':
        return 1;
    case 'o':
        return 1;
    case 'u':
        return 1;
    default:
        return 0;
    }
}

int longitud_de_string(char* string) {
	int i = 0;
	
	if (string == NULL){
		return 0;
	}
	while (string[i] != '\0'){
		i++;
	}
	
	return i;
}

void classify_chars_in_string(char* string, char** vowels_and_cons) {
    /* inicializamos el arreglo de vocales */
    /* le ponemos + 1 por si son todas vocales y necesitamos agregar al final el '\0' */
    char *vocales = calloc(65, sizeof(char));
    
    /* inicializamos el arreglo de consonantes */
    /* le ponemos + 1 por si son todas consonantes y necesitamos agregar al final el '\0' */
    char *consonantes = calloc(65, sizeof(char));
    
    /* llevamos contadores de las posiciones disponibles */
    int v = 0;
    int c = 0;

    /* clasificamos */
    for (int i = 0; string[i] != '\0'; i++)
    {
        if (esVocal(string[i]) == 1)
        {
            vocales[v] = string[i];
            v++;
        } else if (string[i] != ' ')
        {
            consonantes[c] = string[i];
            c++;
        }
    }
    /* tenemos que poner el ultimo caracter en '\0' */
    vocales[v] = '\0';
    consonantes[c] = '\0';

    /* asignamos los punteros al lugar que corresponde al inicio de los arreglos */
    vowels_and_cons[0] = vocales;
    vowels_and_cons[1] = consonantes;

}

void classify_chars(classifier_t* array, uint64_t size_of_array) {
    for (uint64_t i = 0; i < size_of_array; i++)
    {
        array[i].vowels_and_consonants = malloc(2 * sizeof(char*));
        classify_chars_in_string(array[i].string , array[i].vowels_and_consonants);
    }
    
}

/* 
memset
memset es una función en C que se utiliza para llenar un bloque de memoria con un valor específico. La función se define de la siguiente manera:

    void *memset(void *ptr, int value, size_t num);

ptr: Puntero al bloque de memoria que se va a llenar.
value: Valor a ser establecido. El argumento se convierte en un unsigned char y se establece en cada byte de la memoria.
num: Número de bytes a llenar.
La función memset copia el valor value al bloque de memoria apuntado por ptr, para los primeros num bytes. Es importante destacar que memset es una función de bajo nivel que opera en bytes, por lo que el valor value se copiará byte por byte.

calloc
calloc es una función en C que se utiliza para asignar y limpiar un bloque de memoria, similar a malloc, pero además inicializa todos los bytes en el bloque de memoria asignado a cero. La función se define de la siguiente manera:

    void *calloc(size_t num_elements, size_t element_size);

num_elements: Número de elementos que se asignarán.
element_size: Tamaño en bytes de cada elemento.
La función calloc devuelve un puntero al bloque de memoria recién asignado, que tiene espacio suficiente para contener num_elements elementos de tamaño element_size. Además, todos los bytes en el bloque de memoria se inicializan a cero.

Una diferencia importante entre calloc y malloc es que calloc garantiza que la memoria asignada esté inicializada en cero, mientras que con malloc, el contenido de la memoria asignada es indefinido, es decir, puede contener cualquier valor.
*/