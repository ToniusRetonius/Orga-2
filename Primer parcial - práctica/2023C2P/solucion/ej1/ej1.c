#include "ej1.h"

list_t* listNew(){
  list_t* l = (list_t*) malloc(sizeof(list_t));
  l->first=NULL;
  l->last=NULL;
  return l;
}

void listAddLast(list_t* pList, pago_t* data){
    listElem_t* new_elem= (listElem_t*) malloc(sizeof(listElem_t));
    new_elem->data=data;
    new_elem->next=NULL;
    new_elem->prev=NULL;
    if(pList->first==NULL){
        pList->first=new_elem;
        pList->last=new_elem;
    } else {
        pList->last->next=new_elem;
        new_elem->prev=pList->last;
        pList->last=new_elem;
    }
}


void listDelete(list_t* pList){
    listElem_t* actual= (pList->first);
    listElem_t* next;
    while(actual != NULL){
        next=actual->next;
        free(actual);
        actual=next;
    }
    free(pList);
}

uint8_t contar_pagos_aprobados(list_t* pList, char* usuario){
    // no esta claro el tema de aprobado : voy a asumir que es NULL si no paga y 1 (uno) si esta aprobado el pago
    listElem_t* actual = pList->first;
    uint8_t total = 0;

    while (actual != NULL)
    {
        if (actual->data->pagador == usuario){
            if (actual->data->aprobado != 0)
            {
                total++;
            }
        }
        actual = actual->next;
    }
    return total;
}

uint8_t contar_pagos_rechazados(list_t* pList, char* usuario){
    listElem_t* actual = pList->first;
    uint8_t total = 0;
    
    while (actual != NULL)
    {
        if (actual->data->pagador == usuario){
            if (actual->data->aprobado == 0)
            {
                total++;
            }
        }
        actual = actual->next;
    }
    return total;
}

pagoSplitted_t* split_pagos_usuario(list_t* pList, char* usuario){
    pagoSplitted_t* res = malloc(sizeof(pagoSplitted_t));
    listElem_t* actual = pList->first;
    
    // con las fn anteriores llenamos los campos :
    res->cant_aprobados = contar_pagos_aprobados(pList, usuario);
    res->cant_rechazados = contar_pagos_rechazados(pList, usuario);

    // necesitamos crear el array de punteros :
    res->aprobados = calloc(res->cant_aprobados, sizeof(pago_t*));
    res->rechazados = calloc(res->cant_rechazados, sizeof(pago_t*));

    int8_t i_aprobados = 0;
    int8_t i_rechazados = 0;

    while (actual != NULL)
    {
        if (actual->data->pagador == usuario){
            if (actual->data->aprobado == 0)
            {
                res->rechazados[i_rechazados] = actual->data;
                i_rechazados++;
            }
            else
            {
                res->aprobados[i_aprobados] = actual->data;
                i_aprobados++;
            }
        }
        actual = actual->next;
    }
    return res;
}