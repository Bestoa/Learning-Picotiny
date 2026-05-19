#include "lib.h"
#include "libs.h"

uint32_t gIRQTimer = 0;
uint32_t gIRQEbreak = 0;
uint32_t gIRQUnknow = 0;

int main()
{
    print("IRQ test\n");

    set_timer(1000);
    //overriding the timer
    set_timer(1000);
    for (int i = 0; i < 1000; i++);
    print("IRQ timer: ");
    print_dec(gIRQTimer);
    if (gIRQTimer != 1)
        print(" [FAIL]\n");
    else
        print(" [PASS]\n");

    set_timer(1000);
    for (int i = 0; i < 1000; i++);
    print("IRQ Timer: ");
    print_dec(gIRQTimer);
    if (gIRQTimer != 2)
        print(" [FAIL]\n");
    else
        print(" [PASS]\n");

    __asm__ __volatile__("ebreak");
    print("IRQ ebreak: ");
    print_dec(gIRQEbreak);
    if (gIRQEbreak != 1)
        print(" [FAIL]\n");
    else
        print(" [PASS]\n");

    print("Disable IRQ\n");
    disable_irq();
    set_timer(1000);
    for (int i = 0; i < 10000; i++);
    print("IRQ Timer: ");
    print_dec(gIRQTimer);
    if (gIRQTimer != 2)
        print(" [FAIL]\n");
    else
        print(" [PASS]\n");

    print("Enable IRQ\n");
    enable_irq();
    __asm__ __volatile__("ebreak");
    print("IRQ ebreak: ");
    print_dec(gIRQEbreak);
    if (gIRQEbreak != 2)
        print(" [FAIL]\n");
    else
        print(" [PASS]\n");

    set_timer(1000);
    for (int i = 0; i < 1000; i++);
    print("IRQ Timer: ");
    print_dec(gIRQTimer);
    // one pending timer interrupt
    if (gIRQTimer != 4)
        print(" [FAIL]\n");
    else
        print(" [PASS]\n");

    print("Test Done\n");

    return 0;
}

void irqCallback(uint32_t irq)
{
    if (irq & 0x1)
    {
        gIRQTimer++;
    }
    if (irq & 0x2)
    {
        gIRQEbreak++;
    }
    if (irq & ~0x3)
    {
        gIRQUnknow++;
    }
}
