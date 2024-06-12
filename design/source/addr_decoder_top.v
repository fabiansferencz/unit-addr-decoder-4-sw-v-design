`include "addr_decoder_top_filelist.v"

module addr_decoder_top #(
    parameter READ_DELAY  = 1,
    parameter FIFO_SIZE = 2,
    parameter NUM_SW_INST = 5,
    parameter W_WIDTH = 8,
    parameter FRAME_WIDTH = 32
)(
    input clk, rst_n,
    input enable_in,
    input wr_rd_op, valid_in,
    input [7:0] addr_in, op_id_in,
    input [W_WIDTH-1:0] wr_data_in,

    input  [W_WIDTH-1:0] rd_data_in,//from switches
    input  [NUM_SW_INST-1:0] ack_in,//from switches

    output ready_out,
    output [W_WIDTH-1:0] rd_data_out,
    output [7:0] done_op_id,

    output [NUM_SW_INST-1:0] sel_en_out,//going to switches
    output wr_rd_s_out,//going to switches
    output [W_WIDTH-1:0] addr_out,//going to switches
    output [W_WIDTH-1:0] wr_data_out//going to switches
);

    wire [FRAME_WIDTH-1:0] frame_bus2fifo_w;
    wire [NUM_SW_INST-1:0] wr_en_bus2fifo_w;
    wire [FRAME_WIDTH*NUM_SW_INST-1:0] frame_fifo2tx_w;
    wire [NUM_SW_INST-1:0] rd_en_tx2fifo_w;
    wire [NUM_SW_INST-1:0] empty_fifo2tx_w;
    wire [NUM_SW_INST-1:0] full_fifo2tx_w;
    wire [NUM_SW_INST-1:0] last_fifo2tx_w;

    wire [NUM_SW_INST-1:0] sw_busy_rx2tx_w;
    wire [7:0]             op_id_tx2rx_w;

    //to switches
    wire [NUM_SW_INST-1:0] sel_en_out_w;
    wire [W_WIDTH-1:0] addr_out_w;
    wire [W_WIDTH-1:0] wr_data_out_w;
    wire wr_rd_s_out_w;

    //from switches
    wire [W_WIDTH-1:0]     rd_data_rx2out_w;
    wire [7:0]             done_op_id_w;

    bus_module # (
        .NUM_SW_INST(NUM_SW_INST),
        .W_WIDTH(W_WIDTH),
        .FRAME_WIDTH(FRAME_WIDTH)
    ) DUT_BUS (
        .clk(clk),
        .rst_n(rst_n),
        .full((|full_fifo2tx_w)),
        .en_in(enable_in),
        .wr_rd_op(wr_rd_op),
        .valid(valid_in),
        .op_id(op_id_in),
        .addr_in(addr_in),
        .wr_data_in(wr_data_in),
        .frame_out(frame_bus2fifo_w),
        .fifo_wr_en(wr_en_bus2fifo_w)
    );

    genvar i;
    generate
        for(i = 0; i < NUM_SW_INST; i = i + 1) begin
            fifo_top  # (
                .FIFO_SIZE(FIFO_SIZE),
                .W_WIDTH(FRAME_WIDTH)
            ) DUT_AD_fifo_TOP (
                .clk(clk),
                .rst_n(rst_n),
                .fifo_en(~(|full_fifo2tx_w)),
                .wr_en(wr_en_bus2fifo_w[i]),
                .rd_en(rd_en_tx2fifo_w[i]),
                .data_in(frame_bus2fifo_w),
                .data_out(frame_fifo2tx_w[(i+1)*FRAME_WIDTH-1:i*FRAME_WIDTH]),
                .empty(empty_fifo2tx_w[i]),
                .full(full_fifo2tx_w[i]),
                .last(last_fifo2tx_w[i])
            );
        end 
    endgenerate

    tx_scheduler_top # (
        .NUM_SW_INST(NUM_SW_INST),
        .W_WIDTH(W_WIDTH),
        .FRAME_WIDTH(FRAME_WIDTH)
    ) DUT_TX_SCHEDULER (
        .clk(clk),
        .rst_n(rst_n),
        .empty_in(empty_fifo2tx_w),
        .full_in(full_fifo2tx_w),
        .sw_busy(sw_busy_rx2tx_w),//this maybe connected to the ack incoming from sw
        .last(last_fifo2tx_w),
        .frame_in(frame_fifo2tx_w),

        .op_id(op_id_tx2rx_w),
        .fifo_rd_en(rd_en_tx2fifo_w),
        .sel_en(sel_en_out_w),
        .addr(addr_out_w),
        .wr_data(wr_data_out_w),
        .wr_rd_s(wr_rd_s_out_w)
    );

    rx_top # (
        .NUM_SW_INST(NUM_SW_INST),
        .W_WIDTH(W_WIDTH),
        .FIFO_SIZE(FIFO_SIZE)
    ) DUT_RX_TOP (
        .clk(clk),
        .rst_n(rst_n),
        .sel_en(sel_en_out_w),//for determing which switch is busy
        .op_id(op_id_tx2rx_w),//this needs to be saved when a select is present
        .rd_data(rd_data_in),//coming from the switches
        .ack(ack_in),

        .sw_busy(sw_busy_rx2tx_w),//signal that a switch is busy
        .rd_data_out(rd_data_rx2out_w),
        .op_id_out(done_op_id_w)
    );

    assign sel_en_out = sel_en_out_w;
    assign addr_out = addr_out_w;
    assign wr_data_out = wr_data_out_w;
    assign wr_rd_s_out = wr_rd_s_out_w;

    assign rd_data_out = rd_data_rx2out_w;
    assign ready_out = ~(|full_fifo2tx_w);//signals that at least one fifo is full, if not, the AD is ready to receaive transactions
    assign done_op_id = done_op_id_w;
endmodule : addr_decoder_top