`timescale 1ns/1ps

module picotiny (
  input clk,
  input resetn,

  output  flash_clk,
  output  flash_csb,
  inout   flash_mosi,
  inout   flash_miso,

  output lcd_resetn,
  output lcd_clk,
  output lcd_cs,
  output lcd_rs,
  output lcd_data,

  input  ser_rx,
  output ser_tx,
  inout [6:0] gpio
);
 wire sys_resetn;

 wire mem_valid;
 wire mem_ready;
 wire [31:0] mem_addr;
 wire [31:0] mem_wdata;
 wire [3:0] mem_wstrb;
 wire [31:0] mem_rdata;

 wire spimemxip_valid;
 wire spimemxip_ready;
 wire [31:0] spimemxip_addr;
 wire [31:0] spimemxip_wdata;
 wire [3:0] spimemxip_wstrb;
 wire [31:0] spimemxip_rdata;

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

 wire picop1_valid;
 wire picop1_ready;
 wire [31:0] picop1_addr;
 wire [31:0] picop1_wdata;
 wire [3:0] picop1_wstrb;
 wire [31:0] picop1_rdata;

 wire wbp_valid;
 wire wbp_ready;
 wire [31:0] wbp_addr;
 wire [31:0] wbp_wdata;
 wire [3:0] wbp_wstrb;
 wire [31:0] wbp_rdata;

 wire spimemcfg_valid;
 wire spimemcfg_ready;
 wire [31:0] spimemcfg_addr;
 wire [31:0] spimemcfg_wdata;
 wire [3:0] spimemcfg_wstrb;
 wire [31:0] spimemcfg_rdata;

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

 wire lcd_valid;
 wire lcd_ready;
 wire [31:0] lcd_addr;
 wire [31:0] lcd_wdata;
 wire [3:0] lcd_wstrb;
 wire [31:0] lcd_rdata;

wire cpu_clk;
wire pll_lock;

`ifdef __NO_PLL__
assign cpu_clk = clk;
assign pll_lock = 1;
`else
Gowin_rPLL u_pll (
  .clkin(clk),
  .clkout(cpu_clk),
  .lock(pll_lock)
);
`endif

Reset_Sync u_Reset_Sync (
  .resetn(sys_resetn),
  .ext_reset(resetn & pll_lock),
  .clk(cpu_clk)
);

picorv32 #(
   .PROGADDR_RESET(32'h8000_0000)
) u_picorv32 (
   .clk(cpu_clk),
   .resetn(sys_resetn),
   .trap(),
   .mem_valid(mem_valid),
   .mem_instr(),
   .mem_ready(mem_ready),
   .mem_addr(mem_addr),
   .mem_wdata(mem_wdata),
   .mem_wstrb(mem_wstrb),
   .mem_rdata(mem_rdata),
   .irq(32'b0),
   .eoi()
 );

 PicoMem_SRAM_32KB u_PicoMem_SRAM_32KB_7 (
  .resetn(sys_resetn),
  .clk(cpu_clk),
  .mem_s_valid(sram_valid),
  .mem_s_ready(sram_ready),
  .mem_s_addr(sram_addr),
  .mem_s_wdata(sram_wdata),
  .mem_s_wstrb(sram_wstrb),
  .mem_s_rdata(sram_rdata)
 );

 // S0 0x0000_0000 -> SPI Flash XIP
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

  .picos0_valid(spimemxip_valid),
  .picos0_ready(spimemxip_ready),
  .picos0_addr(spimemxip_addr),
  .picos0_wdata(spimemxip_wdata),
  .picos0_wstrb(spimemxip_wstrb),
  .picos0_rdata(spimemxip_rdata),

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

  .picos1_valid(picop1_valid),
  .picos1_ready(picop1_ready),
  .picos1_addr(picop1_addr),
  .picos1_wdata(picop1_wdata),
  .picos1_wstrb(picop1_wstrb),
  .picos1_rdata(picop1_rdata)
  );

// S0 0x8000_0000 -> BOOTROM
// S1 0x8100_0000 -> SPI Flash
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

  .picos1_valid(spimemcfg_valid),
  .picos1_ready(spimemcfg_ready),
  .picos1_addr(spimemcfg_addr),
  .picos1_wdata(spimemcfg_wdata),
  .picos1_wstrb(spimemcfg_wstrb),
  .picos1_rdata(spimemcfg_rdata),

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

// S0 0x8400_0000 -> LCD 
  PicoMem_Mux_1_4_slow #(
    .PICOS0_ADDR_BASE(32'h8400_0000),
    .PICOS0_ADDR_END (32'h84FF_FFFF),
    .PICOS1_ADDR_BASE(32'h8500_0000),
    .PICOS1_ADDR_END (32'h85FF_FFFF),
    .PICOS2_ADDR_BASE(32'h8600_0000),
    .PICOS2_ADDR_END (32'h86FF_FFFF),
    .PICOS3_ADDR_BASE(32'h8700_0000),
    .PICOS3_ADDR_END (32'h87FF_FFFF)
  ) u_PicoMem_Mux_1_4_picop1 (
  .picom_valid(picop1_valid),
  .picom_ready(picop1_ready),
  .picom_addr(picop1_addr),
  .picom_wdata(picop1_wdata),
  .picom_wstrb(picop1_wstrb),
  .picom_rdata(picop1_rdata),

  .picos0_valid(lcd_valid),
  .picos0_ready(lcd_ready),
  .picos0_addr(lcd_addr),
  .picos0_wdata(lcd_wdata),
  .picos0_wstrb(lcd_wstrb),
  .picos0_rdata(lcd_rdata)
  );

 PicoMem_SPI_Flash u_PicoMem_SPI_Flash_18 (
  .clk    (cpu_clk),
  .resetn (sys_resetn),

  .flash_csb  (flash_csb),
  .flash_clk  (flash_clk),
  .flash_mosi (flash_mosi),
  .flash_miso (flash_miso),

  .flash_mem_valid  (spimemxip_valid),
  .flash_mem_ready  (spimemxip_ready),
  .flash_mem_addr   (spimemxip_addr),
  .flash_mem_wdata  (spimemxip_wdata),
  .flash_mem_wstrb  (spimemxip_wstrb),
  .flash_mem_rdata  (spimemxip_rdata),

  .flash_cfg_valid  (spimemcfg_valid),
  .flash_cfg_ready  (spimemcfg_ready),
  .flash_cfg_addr   (spimemcfg_addr),
  .flash_cfg_wdata  (spimemcfg_wdata),
  .flash_cfg_wstrb  (spimemcfg_wstrb),
  .flash_cfg_rdata  (spimemcfg_rdata)
 );

 PicoMem_BOOT_SRAM_8KB u_boot_sram (
  .resetn(sys_resetn),
  .clk(cpu_clk),
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
  .clk(cpu_clk),
  .busin_valid(gpio_valid),
  .busin_ready(gpio_ready),
  .busin_addr(gpio_addr),
  .busin_wdata(gpio_wdata),
  .busin_wstrb(gpio_wstrb),
  .busin_rdata(gpio_rdata)
 );

 PicoMem_UART u_PicoMem_UART (
  .resetn(sys_resetn),
  .clk(cpu_clk),
  .mem_s_valid(uart_valid),
  .mem_s_ready(uart_ready),
  .mem_s_addr(uart_addr),
  .mem_s_wdata(uart_wdata),
  .mem_s_wstrb(uart_wstrb),
  .mem_s_rdata(uart_rdata),
  .ser_rx(ser_rx),
  .ser_tx(ser_tx)
 );

 lcd114 u_Pico_LCD114(
     .clk(cpu_clk),
     .resetn(sys_resetn),

     .lcd_valid(lcd_valid),
     .lcd_ready(lcd_ready),
     .addr(lcd_addr),
     .wdata(lcd_wdata),
     .wstrb(lcd_wstrb),
     .rdata(),

     .lcd_resetn(lcd_resetn),
     .lcd_clk(lcd_clk),
     .lcd_cs(lcd_cs),
     .lcd_rs(lcd_rs),
     .lcd_data(lcd_data)
 );

assign wbp_ready = 1'b1;

endmodule
