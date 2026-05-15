module bootram_2kx8_3 (
    input clk,
    input reset,
    input ce,
    input oce,
    input wre,
    input [10:0] ad,
    input [7:0] din,
    output [7:0] dout
);

    reg [7:0] mem [2047:0];
    reg [7:0] mem_out;

    always @(posedge clk) begin
        if (ce) begin
            if (wre)
                mem[ad] <= din;
            else
                mem_out <= mem[ad];
        end
    end

    assign dout = mem_out;

    initial $readmemh("fw-tangprimer25k.vx3", mem);

endmodule
