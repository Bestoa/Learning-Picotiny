#ifndef __UART_H__
#include <stdint.h>

typedef struct {
    volatile uint32_t DATA;
    volatile uint32_t CLKDIV;
} PICOUART;

#define UART0 ((PICOUART*)0x83000000)

#endif // __UART_H__
