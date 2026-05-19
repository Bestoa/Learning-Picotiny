#include "lib.h"
#include "uart.h"

static int uart_echo = 1;

int putchar(int c)
{
   if (c == '\n')
       UART0->DATA = '\r';
   UART0->DATA = c;

   if (c == '\b')
   {
       UART0->DATA = ' ';
       UART0->DATA = '\b';
   }

   return c;
}

int getchar()
{
    int32_t c = -1;
    while (c == -1) {
        c = UART0->DATA;
    }
    if (uart_echo) {
        putchar(c);
    }
    return c;
}

char *gets(char *buf, int len)
{
    char *s = buf;
    while (len > 1) {
        *s = getchar();
        if (*s == '\r' || *s == '\n') {
            *s = '\0';
            break;
        } else if (*s == '\b') {
            *s = '\0';
            if (s > buf) {
                s--;
                len++;
            }
        } else {
            s++;
            len--;
        }
    }
    *s = '\0';
    return buf;
}

void print(const char *p)
{
    while (*p)
        putchar(*(p++));
}

void print_hex(uint32_t v, int digits)
{
    for (int i = 7; i >= 0; i--) {
        char c = "0123456789abcdef"[(v >> (4*i)) & 15];
        if (c == '0' && i >= digits) continue;
        putchar(c);
        digits = i;
    }
}

void print_dec(uint32_t v)
{
    char buf[10] = {0};
    int i = 0;
    if (v == 0) {
        putchar('0');
        return;
    }
    while (v) {
        buf[i++] = '0' + v % 10;
        v /= 10;
    }
    while(i--) {
        putchar(buf[i]);
    }
}

void dump_memory(uint32_t *p, int n)
{
    for (int i = 0; i < n; i++) {
        if (i % 4 == 0) {
            print_hex((uint32_t)p, 8);
            print(": ");
        }
        print_hex(*p++, 8);
        print(" ");
        if (i % 4 == 3) {
            print("\n");
        }
    }
}
