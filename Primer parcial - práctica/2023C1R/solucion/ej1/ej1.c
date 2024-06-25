#include "ej1.h"

uint32_t* acumuladoPorCliente(uint8_t cantidadDePagos, pago_t* arr_pagos){
    // tomamos cada cliente como su id en el array 
    uint32_t i = 0;
    uint32_t* res = calloc(cantidadDePagos, sizeof(uint32_t));

    while (i < cantidadDePagos)
    {   
        uint8_t cliente = arr_pagos[i].cliente;
        if (arr_pagos[i].aprobado != 0)
        {
            // si el pago esta aprobado ... 
            res[cliente] += arr_pagos[i].monto;
        }
        i++;
    }
    return res;
}
// hasta aca la fn en c funciona barbaro

uint8_t en_blacklist(char* comercio, char** lista_comercios, uint8_t n){
    uint8_t i = 0;
    while (i < n)
    {
        if (strcmp(lista_comercios[i], comercio) == 0)
        {
            return (uint8_t)1;
        }
        i++;   
    }
    return (uint8_t)0;
}

pago_t** blacklistComercios(uint8_t cantidad_pagos, pago_t* arr_pagos, char** arr_comercios, uint8_t size_comercios){
    uint8_t i = 0;
    uint8_t j = 0;
    pago_t** res = calloc(cantidad_pagos, sizeof(pago_t*));

    while (i < cantidad_pagos)
    {
        char* comercio_pago = arr_pagos[i].comercio;

        if (en_blacklist(comercio_pago, arr_comercios, size_comercios) == 1)
        {
            res[j] = &arr_pagos[i];
            j++; 
        }
        i++;   
    }
    return res;
}

//hago una funcion que devuelva cant_en_blacklist
uint8_t CantEnBlacklist(uint8_t cantidad_pagos, pago_t* arr_pagos, char** arr_comercios, uint8_t size_comercios){
    uint8_t cant_en_blacklist = 0;
    for (int i = 0; i < cantidad_pagos; i++){
        if (en_blacklist(arr_pagos[i].comercio, arr_comercios, size_comercios)){
            cant_en_blacklist++;
        }
    }
    return cant_en_blacklist;
}


