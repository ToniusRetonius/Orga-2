section .data
    msg db "Hello world!", 0ah
    ; 0ah es un carácter de nueva línea

section .text
    global _start
    ; el punto de entrada principal del programa y se hace global, 
    ; lo que significa que puede ser referenciado desde fuera del archivo actual.

_start:
    ; Preparando para invocar sys_write para imprimir "Hello world!"
    
    mov rax, 1
    ; el registro rax generalmente se usa para almacenar el número de la syscall que se desea invocar. 
    ; En este caso, 1 corresponde al número de la syscall sys_write, 
    ; que se utiliza para escribir datos en un archivo o en una salida estándar.
    
    mov rdi, 1
    ; En el contexto de la syscall sys_write, 
    ; rdi generalmente se utiliza para especificar el descriptor de archivo. 
    ; Un descriptor de archivo de 1 generalmente corresponde a la salida estándar, la pantalla.
    
    mov rsi, msg
    ; rsi generalmente se utiliza para especificar la dirección de memoria del búfer que contiene los datos 
    ; que se van a escribir. En este caso, msg es una etiqueta que representa 
    ; el comienzo de una cadena de caracteres en memoria que contiene el mensaje que deseamos escribir.
    
    mov rdx, 13
    ; En sys_write, rdx se usa para especificar la cantidad de bytes que se desean escribir
    ; desde el búfer indicado por rsi
    
    syscall
    ; La CPU cambia al modo kernel, 
    ; y el sistema operativo identifica la syscall según el valor almacenado en rax. 
    ; En este caso, como rax contiene 1, el sistema operativo ejecutará la syscall sys_write, 
    ; que escribirá los datos del búfer msg en la salida estándar.

    ; Preparando para invocar sys_exit para terminar el programa
    
    mov rax, 60
    ; Cargar el número de la syscall para la función sys_exit en rax
    
    mov rdi, 0
    ; Establecer el código de salida en rdi (0 para indicar éxito)
    
    syscall