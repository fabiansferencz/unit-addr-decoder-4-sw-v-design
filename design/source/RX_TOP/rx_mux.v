module rx_mux #(
    parameter NUM_SW_INST = 5,
    parameter W_WIDTH = 8
) (
    input clk, rst_n,
    input [8*NUM_SW_INST-1:0] op_id,
    input [NUM_SW_INST-1:0] ack,

    output [7:0] op_id_out
);

    wire [NUM_SW_INST-1:0] ack2mux_w;

    delay # (
        .WIDTH(NUM_SW_INST)
    ) ACK_DELAY (
        .clk(clk),
        .rst_n(rst_n),
        .in(ack),
        .out(ack2mux_w)
    ); 

    mux_top # (
        .NUM_SW_INST(NUM_SW_INST),
        .W_WIDTH(8)
    ) RX_MUX (
        .clk(clk),
        .rst_n(rst_n),
        .sel(ack2mux_w),
        .data_in(op_id),
        .data_out(op_id_out)
    );

    endmodule