#include <stdint.h>

#define CLK_FREQ        50000000
#define UART_BAUD       115200

static volatile uint32_t * const UART_DATA   = (volatile uint32_t *)0x83000000;
static volatile uint32_t * const UART_CLKDIV = (volatile uint32_t *)0x83000004;

static void uart_putc(char c)
{
    *UART_DATA = c;
}

static void uart_puts(const char *s)
{
    while (*s)
        uart_putc(*s++);
}

int main(void)
{
    *UART_CLKDIV = CLK_FREQ / UART_BAUD - 2;

    uart_puts("\r\n");
    uart_puts("================================\r\n");
    uart_puts("  PicoTiny on Tang Primer 25K  \r\n");
    uart_puts("================================\r\n");
    uart_puts("Hello World from BROM!\r\n");
    uart_puts("CPU running at 27MHz\r\n");
    uart_puts("SRAM: 64KB @ 0x4000_0000\r\n");
    uart_puts("\r\n");

    while (1) {
        uart_puts(".");
        for (volatile int i = 0; i < 5000000; i++);
    }

    return 0;
}
