#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>
#include <string.h>
#include <assert.h>

#include "checkpoints.h"

int main (void){
	/* Acá pueden realizar sus propias pruebas */
	char* a = malloc(sizeof(char));
	char* b = malloc(sizeof(char));
	a = 'HOla';
	b = 'HOla';
	printf(strCmp(&a,&b));	
	return 0;    
}


