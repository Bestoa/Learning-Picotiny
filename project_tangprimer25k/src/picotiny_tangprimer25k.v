`timescale 1ns/1ps

module picotiny_tangprimer25k (
    input clk,
    input rst,

    input  ser_rx,
    output ser_tx,
    inout [1:0] gpio
);

wire sysclk;
wire sys_resetn;
wire pll_lock;

assign pll_lock = 1'b1;
assign sysclk = clk;

Reset_Sync u_Reset_Sync (
    .resetn(sys_resetn),
    .ext_reset(~rst & pll_lock),
    .clk(sysclk)
);

wire mem_valid;
wire mem_ready;
wire [31:0] mem_addr;
wire [31:0] mem_wdata;
wire [3:0] mem_wstrb;
wire [31:0] mem_rdata;

wire sram_valid;
wire sram_ready;
wire [31:0] sram_addr;
wire [31:0] sram_wdata;
wire [3:0] sram_wstrb;
wire [31:0] sram_rdata;

wire picop_valid;
wire picop_ready;
wire [31:0] picop_addr;
wire [31:0] picop_wdata;
wire [3:0] picop_wstrb;
wire [31:0] picop_rdata;

wire picop0_valid;
wire picop0_ready;
wire [31:0] picop0_addr;
wire [31:0] picop0_wdata;
wire [3:0] picop0_wstrb;
wire [31:0] picop0_rdata;

wire wbp_valid;
wire wbp_ready;
wire [31:0] wbp_addr;
wire [31:0] wbp_wdata;
wire [3:0] wbp_wstrb;
wire [31:0] wbp_rdata;

wire brom_valid;
wire brom_ready;
wire [31:0] brom_addr;
wire [31:0] brom_wdata;
wire [3:0] brom_wstrb;
wire [31:0] brom_rdata;

wire gpio_valid;
wire gpio_ready;
wire [31:0] gpio_addr;
wire [31:0] gpio_wdata;
wire [3:0] gpio_wstrb;
wire [31:0] gpio_rdata;

wire uart_valid;
wire uart_ready;
wire [31:0] uart_addr;
wire [31:0] uart_wdata;
wire [3:0] uart_wstrb;
wire [31:0] uart_rdata;

reg [31:0] irq = 0;

wire unused_main_s0_valid;
wire unused_picop_s1_valid;
wire unused_picop_s2_valid;
wire unused_picop_s3_valid;
wire unused_picop0_s1_valid;

picorv32 #(
    .PROGADDR_RESET(32'h8000_0000),
    .PROGADDR_IRQ(32'h0000_0400),
    .ENABLE_FAST_MUL(1),
    .ENABLE_DIV(1),
    .ENABLE_TRACE(1),
    .ENABLE_IRQ(1)
) u_picorv32 (
    .clk(sysclk),
    .resetn(sys_resetn),
    .trap(),
    .trace_valid(),
    .trace_data(),
    .mem_valid(mem_valid),
    .mem_instr(),
    .mem_ready(mem_ready),
    .mem_addr(mem_addr),
    .mem_wdata(mem_wdata),
    .mem_wstrb(mem_wstrb),
    .mem_rdata(mem_rdata),
    .irq(irq),
    .eoi()
);

PicoMem_SRAM_64KB u_PicoMem_SRAM_64KB (
    .resetn(sys_resetn),
    .clk(sysclk),
    .mem_s_valid(sram_valid),
    .mem_s_ready(sram_ready),
    .mem_s_addr(sram_addr),
    .mem_s_wdata(sram_wdata),
    .mem_s_wstrb(sram_wstrb),
    .mem_s_rdata(sram_rdata)
);

// S0 0x0000_0000 -> unused (no SPI Flash XIP on bare 25K)
// S1 0x4000_0000 -> SRAM
// S2 0x8000_0000 -> PicoPeriph
// S3 0xC000_0000 -> Wishbone
PicoMem_Mux_1_4 u_PicoMem_Mux_1_4_8 (
    .picom_valid(mem_valid),
    .picom_ready(mem_ready),
    .picom_addr(mem_addr),
    .picom_wdata(mem_wdata),
    .picom_wstrb(mem_wstrb),
    .picom_rdata(mem_rdata),

    .picos0_valid(unused_main_s0_valid),
    .picos0_ready(1'b1),
    .picos0_addr(),
    .picos0_wdata(),
    .picos0_wstrb(),
    .picos0_rdata(32'h0000_0000),

    .picos1_valid(sram_valid),
    .picos1_ready(sram_ready),
    .picos1_addr(sram_addr),
    .picos1_wdata(sram_wdata),
    .picos1_wstrb(sram_wstrb),
    .picos1_rdata(sram_rdata),

    .picos2_valid(picop_valid),
    .picos2_ready(picop_ready),
    .picos2_addr(picop_addr),
    .picos2_wdata(picop_wdata),
    .picos2_wstrb(picop_wstrb),
    .picos2_rdata(picop_rdata),

    .picos3_valid(wbp_valid),
    .picos3_ready(wbp_ready),
    .picos3_addr(wbp_addr),
    .picos3_wdata(wbp_wdata),
    .picos3_wstrb(wbp_wstrb),
    .picos3_rdata(wbp_rdata)
);

PicoMem_Mux_1_4_slow #(
    .PICOS0_ADDR_BASE(32'h8000_0000),
    .PICOS0_ADDR_END (32'h83FF_FFFF),
    .PICOS1_ADDR_BASE(32'h8400_0000),
    .PICOS1_ADDR_END (32'h87FF_FFFF),
    .PICOS2_ADDR_BASE(32'h8800_0000),
    .PICOS2_ADDR_END (32'h8BFF_FFFF),
    .PICOS3_ADDR_BASE(32'h8C00_0000),
    .PICOS3_ADDR_END (32'h8FFF_FFFF)
) u_PicoMem_Mux_1_4_picop (
    .picom_valid(picop_valid),
    .picom_ready(picop_ready),
    .picom_addr(picop_addr),
    .picom_wdata(picop_wdata),
    .picom_wstrb(picop_wstrb),
    .picom_rdata(picop_rdata),

    .picos0_valid(picop0_valid),
    .picos0_ready(picop0_ready),
    .picos0_addr(picop0_addr),
    .picos0_wdata(picop0_wdata),
    .picos0_wstrb(picop0_wstrb),
    .picos0_rdata(picop0_rdata),

    .picos1_valid(unused_picop_s1_valid),
    .picos1_ready(1'b1),
    .picos1_addr(),
    .picos1_wdata(),
    .picos1_wstrb(),
    .picos1_rdata(32'h0000_0000),

    .picos2_valid(unused_picop_s2_valid),
    .picos2_ready(1'b1),
    .picos2_addr(),
    .picos2_wdata(),
    .picos2_wstrb(),
    .picos2_rdata(32'h0000_0000),

    .picos3_valid(unused_picop_s3_valid),
    .picos3_ready(1'b1),
    .picos3_addr(),
    .picos3_wdata(),
    .picos3_wstrb(),
    .picos3_rdata(32'h0000_0000)
);

// S0 0x8000_0000 -> BOOTROM
// S1 0x8100_0000 -> unused (no SPI Flash config)
// S2 0x8200_0000 -> GPIO
// S3 0x8300_0000 -> UART
PicoMem_Mux_1_4_slow #(
    .PICOS0_ADDR_BASE(32'h8000_0000),
    .PICOS0_ADDR_END (32'h80FF_FFFF),
    .PICOS1_ADDR_BASE(32'h8100_0000),
    .PICOS1_ADDR_END (32'h81FF_FFFF),
    .PICOS2_ADDR_BASE(32'h8200_0000),
    .PICOS2_ADDR_END (32'h82FF_FFFF),
    .PICOS3_ADDR_BASE(32'h8300_0000),
    .PICOS3_ADDR_END (32'h83FF_FFFF)
) u_PicoMem_Mux_1_4_picop0 (
    .picom_valid(picop0_valid),
    .picom_ready(picop0_ready),
    .picom_addr(picop0_addr),
    .picom_wdata(picop0_wdata),
    .picom_wstrb(picop0_wstrb),
    .picom_rdata(picop0_rdata),

    .picos0_valid(brom_valid),
    .picos0_ready(brom_ready),
    .picos0_addr(brom_addr),
    .picos0_wdata(brom_wdata),
    .picos0_wstrb(brom_wstrb),
    .picos0_rdata(brom_rdata),

    .picos1_valid(unused_picop0_s1_valid),
    .picos1_ready(1'b1),
    .picos1_addr(),
    .picos1_wdata(),
    .picos1_wstrb(),
    .picos1_rdata(32'h0000_0000),

    .picos2_valid(gpio_valid),
    .picos2_ready(gpio_ready),
    .picos2_addr(gpio_addr),
    .picos2_wdata(gpio_wdata),
    .picos2_wstrb(gpio_wstrb),
    .picos2_rdata(gpio_rdata),

    .picos3_valid(uart_valid),
    .picos3_ready(uart_ready),
    .picos3_addr(uart_addr),
    .picos3_wdata(uart_wdata),
    .picos3_wstrb(uart_wstrb),
    .picos3_rdata(uart_rdata)
);

PicoMem_BOOT_SRAM_8KB u_boot_sram (
    .resetn(sys_resetn),
    .clk(sysclk),
    .mem_s_valid(brom_valid),
    .mem_s_ready(brom_ready),
    .mem_s_addr(brom_addr),
    .mem_s_wdata(brom_wdata),
    .mem_s_wstrb(brom_wstrb),
    .mem_s_rdata(brom_rdata)
);

PicoMem_GPIO u_PicoMem_GPIO (
    .resetn(sys_resetn),
    .io(gpio),
    .clk(sysclk),
    .busin_valid(gpio_valid),
    .busin_ready(gpio_ready),
    .busin_addr(gpio_addr),
    .busin_wdata(gpio_wdata),
    .busin_wstrb(gpio_wstrb),
    .busin_rdata(gpio_rdata)
);

PicoMem_UART u_PicoMem_UART (
    .resetn(sys_resetn),
    .clk(sysclk),
    .mem_s_valid(uart_valid),
    .mem_s_ready(uart_ready),
    .mem_s_addr(uart_addr),
    .mem_s_wdata(uart_wdata),
    .mem_s_wstrb(uart_wstrb),
    .mem_s_rdata(uart_rdata),
    .ser_rx(ser_rx),
    .ser_tx(ser_tx)
);

assign wbp_ready = 1'b1;

endmodule
