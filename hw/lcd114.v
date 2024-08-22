module lcd114(
    input clk,
    input resetn,

    input lcd_valid,
    output reg lcd_ready,
    input [31:0] addr,
    input [31:0] wdata,
    input [3:0] wstrb,
    output [31:0] rdata,

    output lcd_resetn,
    output lcd_clk,
    output lcd_cs,
    output lcd_rs,
    output lcd_data
);

localparam MAX_CMDS = 69;

wire [8:0] init_cmd[MAX_CMDS:0];

assign init_cmd[ 0] = 9'h036;
assign init_cmd[ 1] = 9'h170;
assign init_cmd[ 2] = 9'h03A;
assign init_cmd[ 3] = 9'h105;
assign init_cmd[ 4] = 9'h0B2;
assign init_cmd[ 5] = 9'h10C;
assign init_cmd[ 6] = 9'h10C;
assign init_cmd[ 7] = 9'h100;
assign init_cmd[ 8] = 9'h133;
assign init_cmd[ 9] = 9'h133;
assign init_cmd[10] = 9'h0B7;
assign init_cmd[11] = 9'h135;
assign init_cmd[12] = 9'h0BB;
assign init_cmd[13] = 9'h119;
assign init_cmd[14] = 9'h0C0;
assign init_cmd[15] = 9'h12C;
assign init_cmd[16] = 9'h0C2;
assign init_cmd[17] = 9'h101;
assign init_cmd[18] = 9'h0C3;
assign init_cmd[19] = 9'h112;
assign init_cmd[20] = 9'h0C4;
assign init_cmd[21] = 9'h120;
assign init_cmd[22] = 9'h0C6;
assign init_cmd[23] = 9'h10F;
assign init_cmd[24] = 9'h0D0;
assign init_cmd[25] = 9'h1A4;
assign init_cmd[26] = 9'h1A1;
assign init_cmd[27] = 9'h0E0;
assign init_cmd[28] = 9'h1D0;
assign init_cmd[29] = 9'h104;
assign init_cmd[30] = 9'h10D;
assign init_cmd[31] = 9'h111;
assign init_cmd[32] = 9'h113;
assign init_cmd[33] = 9'h12B;
assign init_cmd[34] = 9'h13F;
assign init_cmd[35] = 9'h154;
assign init_cmd[36] = 9'h14C;
assign init_cmd[37] = 9'h118;
assign init_cmd[38] = 9'h10D;
assign init_cmd[39] = 9'h10B;
assign init_cmd[40] = 9'h11F;
assign init_cmd[41] = 9'h123;
assign init_cmd[42] = 9'h0E1;
assign init_cmd[43] = 9'h1D0;
assign init_cmd[44] = 9'h104;
assign init_cmd[45] = 9'h10C;
assign init_cmd[46] = 9'h111;
assign init_cmd[47] = 9'h113;
assign init_cmd[48] = 9'h12C;
assign init_cmd[49] = 9'h13F;
assign init_cmd[50] = 9'h144;
assign init_cmd[51] = 9'h151;
assign init_cmd[52] = 9'h12F;
assign init_cmd[53] = 9'h11F;
assign init_cmd[54] = 9'h11F;
assign init_cmd[55] = 9'h120;
assign init_cmd[56] = 9'h123;
assign init_cmd[57] = 9'h021;
assign init_cmd[58] = 9'h029;

assign init_cmd[59] = 9'h02A; // column
assign init_cmd[60] = 9'h100;
assign init_cmd[61] = 9'h128;
assign init_cmd[62] = 9'h101;
assign init_cmd[63] = 9'h117;
assign init_cmd[64] = 9'h02B; // row
assign init_cmd[65] = 9'h100;
assign init_cmd[66] = 9'h135;
assign init_cmd[67] = 9'h100;
assign init_cmd[68] = 9'h1BB;
assign init_cmd[69] = 9'h02C; // start

localparam INIT_RESET   = 4'b0000; // delay 100ms while reset
localparam INIT_PREPARE = 4'b0001; // delay 200ms after reset
localparam INIT_WAKEUP  = 4'b0010; // write cmd 0x11 MIPI_DCS_EXIT_SLEEP_MODE
localparam INIT_SNOOZE  = 4'b0011; // delay 120ms after wakeup
localparam INIT_WORKING = 4'b0100; // write command & data
localparam INIT_DONE    = 4'b0101; // all done

localparam IDLE         = 4'b0111; // idle
localparam U_CMD        = 4'b1000; // user data
localparam U_PIXEL_DATA = 4'b1001; // user data

`ifndef __SIM__
// based on 51Mhz
localparam CNT_100MS = 32'd5100000;
localparam CNT_120MS = 32'd6120000;
localparam CNT_200MS = 32'd10200000;
`else
localparam CNT_100MS = 32'd2;
localparam CNT_120MS = 32'd3;
localparam CNT_200MS = 32'd4;
`endif

reg [ 3:0] state;
reg [ 6:0] cmd_index;
reg [31:0] clk_cnt;
reg [ 4:0] bit_loop;

reg [15:0] test_pixel_cnt;

reg lcd_cs_r;
reg lcd_rs_r;
reg lcd_reset_r;

reg [7:0] spi_data;

assign lcd_resetn = lcd_reset_r;
assign lcd_clk    = ~clk;
assign lcd_cs     = lcd_cs_r;
assign lcd_rs     = lcd_rs_r;
assign lcd_data   = spi_data[7]; // MSB
assign lcd_rdata  = 32'bz;

reg boot_done;
reg [8:0] cmds;
reg [15:0] pixel;

// gen color bar
`ifndef __SIM__
wire [15:0] test_pixel = (test_pixel_cnt >= 21600) ? 16'hF800 : (test_pixel_cnt >= 10800) ? 16'h07E0 : 16'h001F;
`else
wire [15:0] test_pixel = (test_pixel_cnt >= 2) ? 16'hF800 : (test_pixel_cnt >= 1) ? 16'h07E0 : 16'h001F;
`endif

always@(posedge clk or negedge resetn) begin
    if (~resetn) begin
        clk_cnt <= 0;
        cmd_index <= 0;
        state <= IDLE;

        lcd_cs_r <= 1;
        lcd_rs_r <= 1;
        lcd_reset_r <= 0;
        spi_data <= 8'hFF;
        bit_loop <= 0;

        test_pixel_cnt <= 0;

        lcd_ready <= 0;
        boot_done <= 0;

    end else if (lcd_ready) begin
        lcd_ready <= 0;
    end else begin
        case (state)
            INIT_RESET : begin
                if (clk_cnt == CNT_100MS) begin
                    clk_cnt <= 0;
                    state <= INIT_PREPARE;
                    lcd_reset_r <= 1;
                end else begin
                    clk_cnt <= clk_cnt + 1;
                end
            end

            INIT_PREPARE : begin
                if (clk_cnt == CNT_200MS) begin
                    clk_cnt <= 0;
                    state <= INIT_WAKEUP;
                end else begin
                    clk_cnt <= clk_cnt + 1;
                end
            end

            INIT_WAKEUP : begin
                if (bit_loop == 0) begin
                    // start
                    lcd_cs_r <= 0;
                    lcd_rs_r <= 0;
                    spi_data <= 8'h11; // exit sleep
                    bit_loop <= bit_loop + 1;
                end else if (bit_loop == 8) begin
                    // end
                    lcd_cs_r <= 1;
                    lcd_rs_r <= 1;
                    bit_loop <= 0;
                    state <= INIT_SNOOZE;
                end else begin
                    // loop
                    spi_data <= { spi_data[6:0], 1'b1 };
                    bit_loop <= bit_loop + 1;
                end
            end

            INIT_SNOOZE : begin
                if (clk_cnt == CNT_120MS) begin
                    clk_cnt <= 0;
                    state <= INIT_WORKING;
                end else begin
                    clk_cnt <= clk_cnt + 1;
                end
            end

            INIT_WORKING : begin
                if (cmd_index == MAX_CMDS + 1) begin
                    state <= INIT_DONE;
                end else begin
                    if (bit_loop == 0) begin
                        // start
                        lcd_cs_r <= 0;
                        lcd_rs_r <= init_cmd[cmd_index][8];
                        spi_data <= init_cmd[cmd_index][7:0];
                        bit_loop <= bit_loop + 1;
                    end else if (bit_loop == 8) begin
                        // end
                        lcd_cs_r <= 1;
                        lcd_rs_r <= 1;
                        bit_loop <= 0;
                        cmd_index <= cmd_index + 1; // next command
                    end else begin
                        // loop
                        spi_data <= { spi_data[6:0], 1'b1 };
                        bit_loop <= bit_loop + 1;
                    end
                end
            end

            INIT_DONE : begin
                `ifndef __SIM__
                if (test_pixel_cnt == 32400) begin
                `else
                if (test_pixel_cnt == 3) begin
                `endif
                    state <= IDLE;
                    lcd_ready <= 1;
                    if (~boot_done) begin
                        boot_done <= 1;
                    end
                end else begin
                    if (bit_loop == 0) begin
                        // start
                        lcd_cs_r <= 0;
                        lcd_rs_r <= 1;
                        spi_data <= test_pixel[15:8];
                        bit_loop <= bit_loop + 1;
                    end else if (bit_loop == 8) begin
                        // next byte
                        spi_data <= test_pixel[7:0];
                        bit_loop <= bit_loop + 1;
                    end else if (bit_loop == 16) begin
                        // end
                        lcd_cs_r <= 1;
                        lcd_rs_r <= 1;
                        bit_loop <= 0;
                        test_pixel_cnt <= test_pixel_cnt + 1; // next pixel
                    end else begin
                        // loop
                        spi_data <= { spi_data[6:0], 1'b1 };
                        bit_loop <= bit_loop + 1;
                    end
                end
            end

            IDLE : begin
                if (~lcd_valid) begin
                    state <= IDLE;
                end else if (~boot_done) begin
                    if (~(wstrb == 4'b1111) || ~(addr[7:0] == 8'h08) || ~(wdata == 32'hFFFFFFFF)) begin
                        lcd_ready <= 1;
                    end else begin
                        state <= INIT_RESET;
                    end
                end else if (wstrb == 4'b1111) begin
                    case (addr[7:0])
                        8'h00 : begin
                            cmds <= wdata[8:0];
                            state <= U_CMD;
                        end
                        8'h04 : begin
                            pixel <= wdata[15:0];
                            state <= U_PIXEL_DATA;
                        end
                        8'h08: begin
                            if (wdata == 32'hFFFFFFFF) begin
                                clk_cnt <= 0;
                                cmd_index <= 0;
                                state <= INIT_RESET;

                                lcd_cs_r <= 1;
                                lcd_rs_r <= 1;
                                lcd_reset_r <= 0;
                                spi_data <= 8'hFF;
                                bit_loop <= 0;

                                test_pixel_cnt <= 0;

                                lcd_ready <= 0;
                            end else begin
                                lcd_ready <= 1;
                            end
                        end
                        default: begin
                            lcd_ready <= 1;
                        end
                    endcase
                end else begin
                    lcd_ready <= 1;
                end
            end

            U_CMD : begin
                if (bit_loop == 0) begin
                    // start
                    lcd_cs_r <= 0;
                    lcd_rs_r <= cmds[8];
                    spi_data <= cmds[7:0];
                    bit_loop <= bit_loop + 1;
                end else if (bit_loop == 8) begin
                    // end
                    lcd_cs_r <= 1;
                    lcd_rs_r <= 1;
                    bit_loop <= 0;
                    lcd_ready <= 1;
                    state <= IDLE;
                end else begin
                    // loop
                    spi_data <= { spi_data[6:0], 1'b1 };
                    bit_loop <= bit_loop + 1;
                end
            end

            U_PIXEL_DATA : begin
                if (bit_loop == 0) begin
                    // start
                    lcd_cs_r <= 0;
                    lcd_rs_r <= 1;
                    spi_data <= pixel[15:8];
                    bit_loop <= bit_loop + 1;
                end else if (bit_loop == 8) begin
                    // next byte
                    spi_data <= pixel[7:0];
                    bit_loop <= bit_loop + 1;
                end else if (bit_loop == 16) begin
                    // end
                    lcd_cs_r <= 1;
                    lcd_rs_r <= 1;
                    bit_loop <= 0;
                    lcd_ready <= 1;
                    state <= IDLE;
                end else begin
                    // loop
                    spi_data <= { spi_data[6:0], 1'b1 };
                    bit_loop <= bit_loop + 1;
                end
            end

        endcase

    end
end

endmodule
