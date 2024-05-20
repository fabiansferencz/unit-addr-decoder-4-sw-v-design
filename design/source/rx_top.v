`include "rx_module.v"

module rx_top #(
    parameter NUM_SW_INST = 5,
    parameter W_WIDTH = 8,
    parameter FIFO_SIZE = 2
) (
    input clk, rst_n,
    input [NUM_SW_INST-1:0] sel_en,
    input [7:0] op_id,
    input [W_WIDTH-1:0] rd_data,
    input [NUM_SW_INST-1:0] ack,

    output [NUM_SW_INST-1:0] sw_busy,
    output [W_WIDTH-1:0] rd_data_out,
    output [7:0] op_id_out
);

    wire [8*NUM_SW_INST-1:0] done_op_id2op_id_out;
    wire [NUM_SW_INST-1:0] ack2mux_w;

    rx_module # (
        .NUM_SW_INST(NUM_SW_INST),
        .W_WIDTH(W_WIDTH)
    ) DUT_RX_FSM (
        .clk(clk),
        .rst_n(rst_n),
        .sel_en(sel_en),//for determing which switch is busy
        .rd_data(rd_data),//coming from the switches
        .ack(ack),

        .sw_busy(sw_busy),//signal that a switch is busy
        .rd_data_out(rd_data_out)
        );

    genvar i;
    generate
        for(i = 0; i < NUM_SW_INST; i = i + 1) begin
            fifo  # (
                .FIFO_SIZE(FIFO_SIZE),
                .W_WIDTH(8)
            ) RX_FIFO(
                .clk(clk),
                .rst_n(rst_n),
                .fifo_en(1),
                .wr_en(sel_en[i]),
                .rd_en(ack[i]),
                .data_in(op_id),
                .data_out(done_op_id2op_id_out[(i+1)*8-1:i*8]),
                .empty(),
                .full()
            );
        end 
    endgenerate

    delay # (
        .WIDTH(NUM_SW_INST)
    ) MUX_DELAY (
        .clk(clk),
        .rst_n(rst_n),
        .in(ack),
        .out(ack2mux_w)
    ); 

    mux_top # (
        .NUM_SW_INST(NUM_SW_INST),
        .W_WIDTH(W_WIDTH)
    ) RX_MUX (
        .clk(clk),
        .rst_n(rst_n),
        .sel(ack2mux_w),
        .data_in(done_op_id2op_id_out),
        .data_out(op_id_out)
    );
endmodule