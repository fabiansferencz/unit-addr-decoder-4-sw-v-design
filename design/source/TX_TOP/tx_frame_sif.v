module tx_frame_sif #(
    parameter NUM_SW_INST = 5,
    parameter W_WIDTH = 8,
    parameter FRAME_WIDTH = 32
) (
    input clk, rst_n,
    input [NUM_SW_INST-1:0] load_in,
    input [FRAME_WIDTH-1:0] frame_in,

    output [NUM_SW_INST-1:0] sel_en,
    output [7:0] addr,
    output [W_WIDTH-1:0] wr_data,
    output wr_rd_s,
    output [7:0] op_id
);

    wire [W_WIDTH-1:0] wr_data_tx2sw_w;

    delay # (
        .WIDTH(W_WIDTH)
    ) WR_DATA_DELAY (
        .clk(clk),
        .rst_n(rst_n),
        .in(wr_data_tx2sw_w),
        .out(wr_data)
    ); 

    frame_sif # (
        .NUM_SW_INST(NUM_SW_INST),
        .W_WIDTH(W_WIDTH),
        .FRAME_WIDTH(FRAME_WIDTH)
    ) TX_FRAME_SIF (
        .clk(clk),
        .rst_n(rst_n),
        .load_in(load_in),
        .frame_in(frame_in),

        .sel_en(sel_en),
        .addr(addr),
        .wr_data(wr_data_tx2sw_w),
        .wr_rd_s(wr_rd_s),
        
        .op_id(op_id)
    );

    endmodule