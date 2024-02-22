module tx_scheduler_top #(
    parameter NUM_SW_INST = 5,
    parameter W_WIDTH = 8,
    parameter OP_WIDTH = 32
) (
    clk, rst_n,
    op_in, sw_busy, op_id,
    rd_fifo, sel_en,
    addr, wr_data, wr_rd_s,
    empty_in, full_in
);

    input clk, rst_n;
    input [OP_WIDTH-1:0] op_in [NUM_SW_INST];
    input sw_busy [NUM_SW_INST];
    input empty_in [NUM_SW_INST];
    input full_in [NUM_SW_INST];

    output [7:0] op_id [NUM_SW_INST];
    output rd_fifo [NUM_SW_INST];
    output sel_en_in [NUM_SW_INST];
    output [4:0] addr;
    output [W_WIDTH-1:0] wr_data;
    output wr_rd_s;

    wire [NUM_SW_INST>>1:0] fifo_idx_cntrl2sif;
    wire valid_cntrl2sif;
    wire [7:0] op_id_tx2rx [NUM_SW_INST];
    wire [4:0] addr_tx2sw;
    wire [W_WIDTH-1:0] wr_data_tx2sw;
    wire sel_en_in_tx2sw[NUM_SW_INST];
    wire rd_fifo_tx2fifo[NUM_SW_INST];
    wire wr_rd_s_tx2sw;

    fifo_rd_controler DUT_FIFO_RD_CNTRL #(
        .NUM_SW_INST(NUM_SW_INST),
        .W_WIDTH(W_WIDTH),
        .OP_WIDTH(OP_WIDTH)
    )(
        .clk(clk),
        .rst_n(rst_n),
        .sw_busy(sw_busy),
        .empty_in(empty_in),
        .full_in(full_in),
        .rd_fifo(rd_fifo_tx2fifo),
        .valid_out(valid_cntrl2sif),
        .fifo_idx_out(fifo_idx_cntrl2sif)
    );

    op_sif DUT_OP_SIF #(
        .NUM_SW_INST(NUM_SW_INST),
        .W_WIDTH(W_WIDTH),
        .OP_WIDTH(OP_WIDTH)
    )(
        .clk(clk),
        .rst_n(rst_n),
        .op_in(op_in),
        .fifo_idx(fifo_idx_cntrl2sif),
        .addr(addr_tx2sw),
        .wr_data(wr_data_tx2sw),
        .wr_rd_s(wr_rd_s_tx2sw),
        .sel_en_in(sel_en_in_tx2sw),
        .op_id_out(op_id_tx2rx),
        .valid_in(valid_cntrl2sif)
    );

endmodule