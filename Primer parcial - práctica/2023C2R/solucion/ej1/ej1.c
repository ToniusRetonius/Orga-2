#include "ej1.h"

string_proc_list* string_proc_list_create(void){
	string_proc_list* lista = calloc(2, sizeof(string_proc_list));
	return lista;
}

string_proc_node* string_proc_node_create(uint8_t type, char* hash){
	string_proc_node* nuevo = malloc(sizeof(string_proc_node));
	nuevo->type = type;
	nuevo->hash = hash;
	// hace falta asignar previous y next ? 
	nuevo->previous = NULL;
	nuevo->next = NULL;
	return nuevo;
}

void string_proc_list_add_node(string_proc_list* list, uint8_t type, char* hash){
	string_proc_node* nuevo = string_proc_node_create(type, hash);
	if (list->first == NULL)
	{
		// si es vacia, primero y ultimo son el mismo?
		list->first = nuevo;
		list->last = nuevo;
		// con esto basta pues el anterior y el sig son NULL
	}
	else
	{
		// capturamos el ultimo
		string_proc_node* ultimo = list->last;
		ultimo->next = nuevo;
		// actualizamos el ultimo
		list->last = nuevo;
		nuevo->previous = ultimo;
	}
}

char* string_proc_list_concat(string_proc_list* list, uint8_t type , char* hash){
	// para todo nodo con mismo type tenemos que concatenar sus hashes con el hash dado
	string_proc_node* actual = list->first;

	while (actual != NULL)
	{	
		if (actual->type == type)
		{
			hash = str_concat(hash, actual->hash);
		}
		// bucle no-infinito
		actual = actual->next;
	}
	return hash;
}


/** AUX FUNCTIONS **/

void string_proc_list_destroy(string_proc_list* list){

	/* borro los nodos: */
	string_proc_node* current_node	= list->first;
	string_proc_node* next_node		= NULL;
	while(current_node != NULL){
		next_node = current_node->next;
		string_proc_node_destroy(current_node);
		current_node	= next_node;
	}
	/*borro la lista:*/
	list->first = NULL;
	list->last  = NULL;
	free(list);
}
void string_proc_node_destroy(string_proc_node* node){
	node->next      = NULL;
	node->previous	= NULL;
	node->hash		= NULL;
	node->type      = 0;			
	free(node);
}


char* str_concat(char* a, char* b) {
	int len1 = strlen(a);
    int len2 = strlen(b);
	int totalLength = len1 + len2;
    char *result = (char *)malloc(totalLength + 1); 
    strcpy(result, a);
    strcat(result, b);
    return result;  
}

void string_proc_list_print(string_proc_list* list, FILE* file){
        uint32_t length = 0;
        string_proc_node* current_node  = list->first;
        while(current_node != NULL){
                length++;
                current_node = current_node->next;
        }
        fprintf( file, "List length: %d\n", length );
		current_node    = list->first;
        while(current_node != NULL){
                fprintf(file, "\tnode hash: %s | type: %d\n", current_node->hash, current_node->type);
                current_node = current_node->next;
        }
}