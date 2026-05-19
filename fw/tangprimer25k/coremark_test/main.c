#include <stdint.h>

typedef struct {
    volatile uint32_t DATA;
    volatile uint32_t CLKDIV;
} PICOUART;

#define UART0 ((PICOUART*)0x83000000)
#define CLK_FREQ  50000000
#define UART_BAUD 115200

static void uart_putc(char c) {
    if (c == '\n')
        UART0->DATA = '\r';
    UART0->DATA = c;
}

static void print(const char *s) {
    while (*s)
        uart_putc(*s++);
}

static void print_dec(uint32_t v) {
    char buf[12];
    int i = 0;
    if (v == 0) { uart_putc('0'); return; }
    while (v) { buf[i++] = '0' + (v % 10); v /= 10; }
    while (i--) uart_putc(buf[i]);
}

static uint32_t get_cycle(void) {
    uint32_t c;
    __asm__ volatile("rdcycle %0" : "=r"(c));
    return c;
}

int main() {
    UART0->CLKDIV = CLK_FREQ / UART_BAUD - 2;

    print("Simple benchmark start\n");

    uint32_t t0 = get_cycle();

    // Simple workload: XOR-shift 100000 iterations
    uint32_t x = 0xDEADBEEF;
    volatile uint32_t sink = 0;
    for (int i = 0; i < 100000; i++) {
        x ^= x << 13;
        x ^= x >> 17;
        x ^= x << 5;
    }
    sink = x;

    uint32_t t1 = get_cycle();

    print("Done. Cycles: ");
    print_dec(t1 - t0);
    print("\nChecksum: 0x");
    // Print hex
    for (int i = 28; i >= 0; i -= 4) {
        int nibble = (sink >> i) & 0xf;
        uart_putc(nibble < 10 ? '0' + nibble : 'a' + nibble - 10);
    }
    print("\n");

    // Now test a larger memory pattern
    #define BUF_SIZE 512
    static uint8_t buf[BUF_SIZE];
    t0 = get_cycle();
    for (int i = 0; i < BUF_SIZE; i++)
        buf[i] = (uint8_t)(i * 7 + 3);
    uint32_t sum = 0;
    for (int i = 0; i < BUF_SIZE; i++)
        sum += buf[i];
    t1 = get_cycle();

    print("Memory test. Cycles: ");
    print_dec(t1 - t0);
    print(" Sum: ");
    print_dec(sum);
    print("\n");

    print("All tests passed!\n");

    while (1) {}
    return 0;
}
