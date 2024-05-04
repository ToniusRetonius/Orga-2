#include "ej1.h"

string_proc_list* string_proc_list_create(void){
	string_proc_list* res = malloc(2 * sizeof(uint64_t));
	res->first = NULL;
	res->last = NULL;
	return res;
}

string_proc_node* string_proc_node_create(uint8_t type, char* hash){
	string_proc_node* nuevo = malloc(sizeof(string_proc_node));
	nuevo->next = NULL;
	nuevo->previous = NULL;
	nuevo->type = type;
	nuevo->hash = hash;
	return nuevo;
}

void string_proc_list_add_node(string_proc_list* list, uint8_t type, char* hash){
	string_proc_node* nuevo = string_proc_node_create(type, hash);
	string_proc_node ultimo = list->last;
	
	ultimo->next = nuevo;
	nuevo->previous = ultimo;

	list->last = nuevo;
}

char* string_proc_list_concat(string_proc_list* list, uint8_t type , char* hash){
	char* res;
	res = hash;

	string_proc_node actual = list->first;
	
	while (actual->next != NULL)
	{
		if (actual->type == type)
		{
			res = str_concat(res,actual->hash);
		}
		actual = actual->next;
	}
	return res;
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