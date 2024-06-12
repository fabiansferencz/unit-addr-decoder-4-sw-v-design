`include "frame_sif.v"
`include "tx_mux.v"
`include "tx_frame_sif.v"
`include "fifo_rd_cntrl.v"

module tx_scheduler_top #(
    parameter NUM_SW_INST = 5,
    parameter W_WIDTH = 8,
    parameter FRAME_WIDTH = 32
) (
    input clk, rst_n,
    input [NUM_SW_INST-1:0] empty_in, full_in,
    input [NUM_SW_INST-1:0] sw_busy,
    input [NUM_SW_INST-1:0] last,
    input [FRAME_WIDTH*NUM_SW_INST-1:0] frame_in,

    output [NUM_SW_INST-1:0] fifo_rd_en,
    output [7:0] op_id,

    output [NUM_SW_INST-1:0] sel_en,
    output [W_WIDTH-1:0] addr, wr_data,
    output wr_rd_s

);  
    wire [NUM_SW_INST-1:0] rd_en2sif_frame;
    wire [FRAME_WIDTH-1:0] mux2frame_sif;
    
    tx_mux # (
        .NUM_SW_INST(NUM_SW_INST),
        .W_WIDTH(W_WIDTH),
        .FRAME_WIDTH(FRAME_WIDTH)
    ) DUT_TX_MUX_TOP (
        .clk(clk),
        .rst_n(rst_n),
        .sel(rd_en2sif_frame),
        .data_in(frame_in),
        .data_out(mux2frame_sif)
    );
    
    fifo_rd_cntrl # (
        .NUM_SW_INST(NUM_SW_INST),
        .W_WIDTH(W_WIDTH)
    ) DUT_FIFO_RD_CNTRL (
        .clk(clk),
        .rst_n(rst_n),
        .empty(empty_in),
        .full(full_in),
        .last(last),
        .sw_busy(sw_busy),
        .rd_en(rd_en2sif_frame)
    );

    tx_frame_sif # (
        .NUM_SW_INST(NUM_SW_INST),
        .W_WIDTH(W_WIDTH),
        .FRAME_WIDTH(FRAME_WIDTH)
    ) DUT_FRAME_SIF_TOP (
        .clk(clk),
        .rst_n(rst_n),
        .load_in(rd_en2sif_frame),
        .frame_in(mux2frame_sif),

        .sel_en(sel_en),
        .addr(addr),
        .wr_data(wr_data),
        .wr_rd_s(wr_rd_s),
        
        .op_id(op_id)
    );

    assign fifo_rd_en = rd_en2sif_frame;
endmodule : tx_scheduler_top