/* ** por compatibilidad se omiten tildes **
================================================================================
 TALLER System Programming - ORGANIZACION DE COMPUTADOR II - FCEN
================================================================================

  Rutinas del controlador de interrupciones.
*/
#include "pic.h"

#define PIC1_PORT 0x20
#define PIC2_PORT 0xA0

static __inline __attribute__((always_inline)) void outb(uint32_t port,uint8_t data) {
  __asm __volatile("outb %0,%w1" : : "a"(data), "d"(port));
}
void pic_finish1(void) { 
  outb(PIC1_PORT, 0x20); 
}

void pic_finish2(void) {
  outb(PIC1_PORT, 0x20);
  outb(PIC2_PORT, 0x20);
}

// COMPLETAR: implementar pic_reset()
void pic_reset() {
  // ICW1: Inicia la secuencia de inicialización (bit de inicio).
  outb(PIC1_PORT, 0x11); 
  outb(PIC2_PORT, 0x11);
  
  // ICW2: Configura los vectores de interrupción base
  // cada PIC necesita saber en que parte de la IDT debe colocar sus interrupciones
  // PIC1 maneja interrupciones IRQ 0-7, comienza en el vector 0x20 (= 32)
  // PIC2 maneja interrupciones IRQ 8-15, comienza en el vector 0x28 (= 40)
  outb(PIC1_PORT + 1, 0x20); 
  outb(PIC2_PORT + 1, 0x28); 
  
  // ICW3: Configura la conexión maestro/esclavo
  // tenemos que defirnir el modo de conexion del PIC1 (el bit3 = 1) 
  // tenemos que definir a traves de que linea (IRQ) el PIC2 esta conectado al PIC1
  // PIC1 está conectado al IRQ2 (slave en el PIC1)
  // PIC2 esclavo conectado al IRQ2 del maestro PIC1
  outb(PIC1_PORT + 1, 0x04); 
  outb(PIC2_PORT + 1, 0x02); 
  
  // ICW4: Configura el modo de funcionamiento
  // Modo 8086/88 (Normal EOI), sin Auto EOI
  outb(PIC1_PORT + 1, 0x01); 
  outb(PIC2_PORT + 1, 0x01);
}

void pic_enable() {
  outb(PIC1_PORT + 1, 0x00);
  outb(PIC2_PORT + 1, 0x00);
}

void pic_disable() {
  outb(PIC1_PORT + 1, 0xFF);
  outb(PIC2_PORT + 1, 0xFF);
}
