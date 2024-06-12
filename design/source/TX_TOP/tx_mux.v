module tx_mux # (
    parameter NUM_SW_INST = 5,
    parameter W_WIDTH = 8,
    parameter FRAME_WIDTH = 32
)(
    input clk, rst_n,
    input [FRAME_WIDTH*NUM_SW_INST-1:0] data_in,
    input [NUM_SW_INST-1:0] sel,

    output [FRAME_WIDTH-1:0] data_out
);  

    wire [NUM_SW_INST-1:0] sel_en_delayed_w;

    delay # (
        .WIDTH(NUM_SW_INST)
    ) SEL_EN_DELAY (
        .clk(clk),
        .rst_n(rst_n),
        .in(sel),
        .out(sel_en_delayed_w)
    ); 

    mux_top # (
        .NUM_SW_INST(NUM_SW_INST),
        .W_WIDTH(FRAME_WIDTH)
    ) TX_MUX (
        .clk(clk),
        .rst_n(rst_n),
        .sel(sel_en_delayed_w),
        .data_in(data_in),
        .data_out(data_out)
    );

endmodule