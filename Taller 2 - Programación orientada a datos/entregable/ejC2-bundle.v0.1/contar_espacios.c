#include <stdint.h>
#include <stdio.h>
#include "contar_espacios.h"

uint32_t longitud_de_string(char* string) {
	uint32_t i = 0;
	
	if (string == NULL){
		return 0;
	}
	while (string[i] != '\0'){
		i++;
	}
	
	return i;
}

uint32_t contar_espacios(char* string) {
	uint32_t i = 0;
	uint32_t res = 0;
	uint32_t len = longitud_de_string(string); 
	
	if (string == NULL){
		return 0;
	}
	while(i < len){
		if (string[i] == ' '){
			res ++;
		}
		i++;
	}
	return res;
}