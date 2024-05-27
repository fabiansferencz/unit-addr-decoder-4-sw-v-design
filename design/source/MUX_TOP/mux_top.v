`include "bit_mux.v"
`include "reorder_module.v"

module mux_top # (
    parameter NUM_SW_INST = 5,
    parameter W_WIDTH = 32
)(
    input clk, rst_n,
    input [W_WIDTH*NUM_SW_INST-1:0] data_in,
    input [NUM_SW_INST-1:0] sel,
    output [W_WIDTH-1:0] data_out
);  

    wire [W_WIDTH*NUM_SW_INST-1:0] reoder2mux_w;

    reorder  # (
        .NUM_SW_INST(NUM_SW_INST),
        .W_WIDTH(W_WIDTH)
    ) REORDER (
        .data_in(data_in),
        .data_out(reoder2mux_w)
    );

    genvar i;
    generate
        for(i = 0; i < W_WIDTH; i = i + 1) begin
            bit_mux  # (
                .NUM_SW_INST(NUM_SW_INST)
            ) BIT_MUX (
                .clk(clk),
                .rst_n(rst_n),
                .data(reoder2mux_w[(i+1)*NUM_SW_INST-1:i*NUM_SW_INST]),
                .sel(sel),
                .out(data_out[i])
            );
        end 
    endgenerate

endmodule

