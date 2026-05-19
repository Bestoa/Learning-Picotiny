/*
 * Tang Primer 25K CoreMark port override
 * - Sets UART CLKDIV for 50MHz clock
 * - Skips QSPI benchmark (no SPI Flash on bare 25K)
 */
#include "coremark.h"
#include "core_portme.h"
#include "uart.h"
#include <stdint.h>

/* Use static memory instead of stack - avoids stack overflow with 2KB stack */
#undef MEM_METHOD
#define MEM_METHOD MEM_STATIC

#define CLK_FREQ  50000000
#define UART_BAUD 115200

#if VALIDATION_RUN
volatile ee_s32 seed1_volatile = 0x3415;
volatile ee_s32 seed2_volatile = 0x3415;
volatile ee_s32 seed3_volatile = 0x66;
#endif
#if PERFORMANCE_RUN
volatile ee_s32 seed1_volatile = 0x0;
volatile ee_s32 seed2_volatile = 0x0;
volatile ee_s32 seed3_volatile = 0x66;
#endif
#if PROFILE_RUN
volatile ee_s32 seed1_volatile = 0x8;
volatile ee_s32 seed2_volatile = 0x8;
volatile ee_s32 seed3_volatile = 0x8;
#endif
volatile ee_s32 seed4_volatile = ITERATIONS;
volatile ee_s32 seed5_volatile = 0;

CORETIMETYPE
barebones_clock()
{
    CORETIMETYPE cycles;
    __asm__ volatile ("rdcycle %0" : "=r"(cycles));
    return cycles;
}

#define GETMYTIME(_t)              (*_t = barebones_clock())
#define MYTIMEDIFF(fin, ini)       ((fin) - (ini))
#define TIMER_RES_DIVIDER          1
#define SAMPLE_TIME_IMPLEMENTATION 1
#define EE_TICKS_PER_SEC           (CLOCKS_PER_SEC / TIMER_RES_DIVIDER)

static CORETIMETYPE start_time_val, stop_time_val;

void
start_time(void)
{
    GETMYTIME(&start_time_val);
}

void
stop_time(void)
{
    GETMYTIME(&stop_time_val);
}

CORE_TICKS
get_time(void)
{
    CORE_TICKS elapsed
        = (CORE_TICKS)(MYTIMEDIFF(stop_time_val, start_time_val));
    return elapsed;
}

secs_ret
time_in_secs(CORE_TICKS ticks)
{
    secs_ret retval = ((secs_ret)ticks) / (secs_ret)EE_TICKS_PER_SEC;
    return retval;
}

ee_u32 default_num_contexts = 1;

void
portable_init(core_portable *p, int *argc, char *argv[])
{
    (void)argc;
    (void)argv;

    UART0->CLKDIV = CLK_FREQ / UART_BAUD - 2;

    /* SRAM integrity check - read back first 4 words and verify */
    volatile unsigned int *sram = (volatile unsigned int *)0x80000000;
    ee_printf("SRAM[0..3]: %08x %08x %08x %08x\n",
        sram[0], sram[1], sram[2], sram[3]);
    ee_printf("expect:     4040006f 00000013 00000013 00000013\n");

    ee_printf("CoreMark start...\n");

    if (sizeof(ee_ptr_int) != sizeof(ee_u8 *))
    {
        ee_printf(
            "ERROR! Please define ee_ptr_int to a type that holds a "
            "pointer!\n");
    }
    if (sizeof(ee_u32) != 4)
    {
        ee_printf("ERROR! Please define ee_u32 to a 32b unsigned type!\n");
    }
    p->portable_id = 1;
}

void
portable_fini(core_portable *p)
{
    ee_printf("BUILD: v0.8 fmt=%lu/%u/%d/%04x ok\n",
        (long unsigned)12345, (unsigned)67, 89, 0xdead);
    p->portable_id = 0;
}
