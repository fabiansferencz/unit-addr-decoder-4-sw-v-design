`include "frame_mux.v"
`include "frame_sif.v"
`include "fifo_rd_cntrl.v"

module tx_scheduler_top #(
    parameter NUM_SW_INST = 5,
    parameter W_WIDTH = 8,
    parameter FRAME_WIDTH = 32
) (
    input clk, rst_n,
    input [NUM_SW_INST-1:0] empty_in, full_in,
    input [NUM_SW_INST-1:0] sw_busy,
    input [FRAME_WIDTH-1:0] frame_in_0,
    input [FRAME_WIDTH-1:0] frame_in_1,
    input [FRAME_WIDTH-1:0] frame_in_2,
    input [FRAME_WIDTH-1:0] frame_in_3,
    input [FRAME_WIDTH-1:0] frame_in_4,

    output [NUM_SW_INST-1:0] fifo_rd_en,
    output [7:0] op_id,

    output [NUM_SW_INST-1:0] sel_en,
    output [W_WIDTH-1:0] addr, wr_data,
    output wr_rd_s

);  
    wire [NUM_SW_INST-1:0] rd_en_tx2fifo_w;
    wire [FRAME_WIDTH-1:0] frame_mux2sif_w;
    wire [7:0] op_id_tx2rx_w;

    //signals going to the mem interface(switches)
    wire [NUM_SW_INST-1:0] sel_en_tx2sw_w;
    wire [W_WIDTH-1:0] addr_tx2sw_w;
    wire [W_WIDTH-1:0] wr_data_tx2sw_w;
    wire wr_rd_s_tx2sw_w;

    fifo_rd_cntrl # (
        .NUM_SW_INST(NUM_SW_INST),
        .W_WIDTH(W_WIDTH)
    ) DUT_FIFO_RD_CNTRL (
        .clk(clk),
        .rst_n(rst_n),
        .empty(empty_in),
        .full(full_in),
        .sw_busy(sw_busy),
        .rd_en(rd_en_tx2fifo_w)
    );

    frame_mux # (
        .NUM_SW_INST(NUM_SW_INST),
        .FRAME_WIDTH(FRAME_WIDTH)
    ) DUT_FRAME_MUX (
        .clk(clk),
        .rst_n(rst_n),
        .rd_sel(rd_en_tx2fifo_w),
        .frame_in_0(frame_in_0),
        .frame_in_1(frame_in_1),
        .frame_in_2(frame_in_2),
        .frame_in_3(frame_in_3),
        .frame_in_4(frame_in_4),
        .frame_out(frame_mux2sif_w)
    );

    frame_sif # (
        .NUM_SW_INST(NUM_SW_INST),
        .W_WIDTH(W_WIDTH),
        .FRAME_WIDTH(FRAME_WIDTH)
    ) DUT_FRAME_SIF (
        .clk(clk),
        .rst_n(rst_n),
        .load_in(rd_en_tx2fifo_w),
        .frame_in(frame_mux2sif_w),

        .sel_en(sel_en_tx2sw_w),
        .addr(addr_tx2sw_w),
        .wr_data(wr_data_tx2sw_w),
        .wr_rd_s(wr_rd_s_tx2sw_w),
        
        .op_id(op_id_tx2rx_w)
    );

    assign fifo_rd_en = rd_en_tx2fifo_w;
    assign op_id = op_id_tx2rx_w;

    assign addr = addr_tx2sw_w;
    assign wr_data = wr_data_tx2sw_w;
    assign wr_rd_s = wr_rd_s_tx2sw_w;
    assign sel_en = sel_en_tx2sw_w;
endmodule : tx_scheduler_top