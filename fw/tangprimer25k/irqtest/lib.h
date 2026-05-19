#ifndef __LIB_H__
#include <stdint.h>

extern int getchar();
extern int putchar(int c);
extern char *gets(char *buf, int size);
extern void print(const char *str);
extern void print_hex(uint32_t v, int digits);
extern void print_dec(uint32_t v);
extern void dump_memory(uint32_t *p, int n);
#endif
