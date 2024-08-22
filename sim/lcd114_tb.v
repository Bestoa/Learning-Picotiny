`timescale 1ns / 1ps
module lcd114_tb;
reg clk;
reg resetn;
reg lcd_valid;
wire lcd_ready;
reg [31:0] lcd_addr;
reg [31:0] lcd_wdata;
reg [3:0] lcd_wstrb;
wire [31:0] lcd_rdata;

lcd114 lcd114_inst (
    .clk(clk),
    .resetn(resetn),
    .lcd_valid(lcd_valid),
    .lcd_ready(lcd_ready),
    .addr(lcd_addr),
    .wdata(lcd_wdata),
    .wstrb(lcd_wstrb),
    .rdata(lcd_rdata)
);
always begin
    #1 clk = ~clk;
end

initial begin
    $dumpfile("lcd114.vcd");
    $dumpvars(0, lcd114_inst);
    clk = 0;
    resetn = 0;
    lcd_valid = 0;
    #1
    resetn = 1;
    #10 
    lcd_wstrb = 4'b1111;
    lcd_addr = 32'h00000008;
    lcd_wdata = 32'hf;
    lcd_valid = 1;
    while (!lcd_ready) begin
        #1;
    end
    lcd_valid = 0;
    $display("boot done = ", lcd114_inst.boot_done);
    #10
    lcd_wstrb = 4'b1111;
    lcd_addr = 32'h00000008;
    lcd_wdata = 32'hffffffff;
    lcd_valid = 1;
    while (!lcd_ready) begin
        #1;
    end
    lcd_valid = 0;
    $display("boot done = ", lcd114_inst.boot_done);
    #10
    lcd_wstrb = 4'b0000;
    lcd_addr = 32'h00000000;
    lcd_valid = 1;
    while (!lcd_ready) begin
        #1;
    end
    $display("lcd_rdata = %h", lcd_rdata);
    lcd_valid = 0;
    #10
    lcd_wstrb = 4'b1111;
    lcd_addr = 32'h00000000;
    lcd_wdata = 16'h036;
    lcd_valid = 1;
    while (!lcd_ready) begin
        #1;
    end
    lcd_valid = 0;
    #10
    lcd_wstrb = 4'b1111;
    lcd_addr = 32'h00000000;
    lcd_wdata = 16'h170;
    lcd_valid = 1;
    while (!lcd_ready) begin
        #1;
    end
    lcd_valid = 0;
    #10
    lcd_wstrb = 4'b1111;
    lcd_addr = 32'h00000004;
    lcd_wdata = 16'h07e0;
    lcd_valid = 1;
    while (!lcd_ready) begin
        #1;
    end
    lcd_valid = 0;
    #10
    $finish;
end

endmodule
