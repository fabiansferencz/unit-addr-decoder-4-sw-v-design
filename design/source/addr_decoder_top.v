module addr_decoder #(
    parameter READ_DELAY  = 1,
    parameter NUM_SW_INST = 5,
    parameter W_WIDTH = 8,
    parameter OP_WIDTH = 32
)(
    //IN-interface
    clk, rst_n,
    addr_in,
    wr_data_in, rd_data_out,
    wr_rd_op, valid_in, op_id_in,
    ready_out, ready_id,

    //OUT-interface
    sw_addr_in,
    sw_w_data_in, sw_rd_data_out,
    wr_rd_s_in,
    sel_en_in, ack_out
);

    //INPUT Interface
    input clk, rst_n;
    input reg[7:0] addr_in;
    input reg[W_WIDTH-1:0] wr_data_in, op_id_in;
    input wr_rd_op, valid_in;
    output ready_out;
    output reg[W_WIDTH-1:0] rd_data_out;
    output reg[7:0] ready_id;

    //OUTPUT Interface
    output reg[4:0] sw_addr_in;
    output reg[W_WIDTH-1:0] sw_w_data_in;
    input  reg[W_WIDTH-1:0] sw_rd_data_out;
    output wr_rd_s_in;
    input  ack_out[NUM_SW_INST];
    output sel_en_in[NUM_SW_INST];

    //{addr[4:0], wr_rd_op, wr_data[W_WIDTH-1:0], op_id[7:0]}
    wire [OP_WIDTH-1:0]         op_demux2fifo   [NUM_SW_INST];
    wire                        wr_demux2fifo   [NUM_SW_INST];
    wire [OP_WIDTH-1:0]         op_fifo2tx      [NUM_SW_INST];
    wire                        rd_fifo2tx      [NUM_SW_INST];
    wire                        empty_fifo2tx   [NUM_SW_INST];
    wire                        full_fifo2tx    [NUM_SW_INST];

    wire                        sw_busy_rx2tx   [NUM_SW_INST];
    wire [7:0]                  op_id_tx2rx     [NUM_SW_INST];

    in_demux DUT_DEMUX # (
        .NUM_SW_INST(NUM_SW_INST),
        .W_WIDTH(W_WIDTH),
        .OP_WIDTH(OP_WIDTH)
    )(
        .clk(clk),
        .rst_n(rst_n),
        .sw_sel(addr_in[7:5]),
        .addr(addr_in[4:0]),
        .wr_data(wr_data_in),
        .wr_rd_op(wr_rd_op),
        .valid(valid_in),
        .op_id(op_id_in),
        .op_out(op_demux2fifo),
        .wr_fifo(wr_demux2fifo)
    );

    tx_scheduler_top DUT_TX_SCHEDULER # (
        .NUM_SW_INST(NUM_SW_INST),
        .W_WIDTH(W_WIDTH),
        .OP_WIDTH(OP_WIDTH)
    )(
        .clk(clk),
        .rst_n(rst_n),
        .op_in(op_fifo2tx),
        .sw_busy(sw_busy_rx2tx),
        .op_id(op_id_tx2rx),
        .rd_fifo(rd_fifo2tx),
        .sel_en(sel_en_in),
        .addr(sw_addr_in),
        .wr_data(sw_w_data_in),
        .wr_rd_s(wr_rd_s_in),
        .empty_in(empty_fifo2tx),
        .full_in(full_fifo2tx)
    );

    rx_fsm DUT_RX_FSM # (
        .W_WIDTH(W_WIDTH)
    )(
        .clk(clk),
        .rst_n(rst_n),
        .sw_busy(sw_busy_rx2tx),
        .op_id_in(op_id_tx2rx),
        .rd_data_in(sw_rd_data_out),
        .ack(ack_out),
        .rd_data_out(rd_data_out),
        .ready(ready_out),
        .op_id_out(ready_id)
    );

    genvar i;
    generate
        for(i = 0; i < NUM_SW_INST - 1; i++) begin
            fifo DUT_AD_FIFO # (
                .FIFO_SIZE(2),
                .W_WIDTH(5+1+W_WIDTH+8)
            )(
                .clk(clk),
                .rst_n(rst),
                .wr_en(wr_demux2fifo[i]),
                .rd_en(rd_fifo2tx[i]),
                .data_in(op_demux2fifo[i]),
                .data_out(op_fifo2tx[i]),
                .empty(empty_fifo2tx[i]),
                .full(full_fifo2tx)
            );
        end 
    endgenerate
endmodule