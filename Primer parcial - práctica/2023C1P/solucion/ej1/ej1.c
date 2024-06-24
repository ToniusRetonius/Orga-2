#include "ej1.h"

uint32_t cuantosTemplosClasicos_c(templo *temploArr, size_t temploArr_len){
    uint32_t total = 0;
    size_t i = 0;
    while (i < temploArr_len)
    {
        uint32_t col_lado_largo =(uint32_t) temploArr[i].colum_largo; 
        uint32_t col_lado_corto =(uint32_t) temploArr[i].colum_corto;
        uint32_t m = (col_lado_corto * 2) + 1;
        if (m == col_lado_largo)
        {
            total++;
        }
        
        i++;
    }
    return total;
}
  
templo* templosClasicos_c(templo *temploArr, size_t temploArr_len){
    templo* res = calloc(temploArr_len, sizeof(templo));
    uint32_t j = 0;
    uint32_t i = 0;

    while (i < temploArr_len)
    {
        uint32_t col_lado_largo =(uint32_t) temploArr[i].colum_largo; 
        uint32_t col_lado_corto =(uint32_t) temploArr[i].colum_corto;
        uint32_t m = (col_lado_corto * 2) + 1;
        if (m == col_lado_largo)
        {
            res[j] = temploArr[i];
            j++;
        }
        i++;
    }
    return res;
}
