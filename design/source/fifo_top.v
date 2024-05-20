`include "fifo_module.v"
`include "fifo_cnt.v"

module fifo_top # (
    parameter FIFO_SIZE = 64,
    parameter W_WIDTH = 32
)(
    input clk, rst_n,
    input fifo_en, wr_en, rd_en,
    input [W_WIDTH-1:0] data_in,
    output [W_WIDTH-1:0] data_out,
    output full, empty,
    output last
);  

    fifo  # (
        .FIFO_SIZE(FIFO_SIZE),
        .W_WIDTH(W_WIDTH)
    ) DUT_AD_FIFO (
        .clk(clk),
        .rst_n(rst_n),
        .fifo_en(fifo_en),
        .wr_en(wr_en),
        .rd_en(rd_en),
        .data_in(data_in),
        .data_out(data_out),
        .empty(empty),
        .full(full)
    );

    fifo_cnt # (
        .FIFO_SIZE(FIFO_SIZE)
    ) DUT_AD_FIFO_CNT (
        .clk(clk),
        .rst_n(rst_n),
        .fifo_en(fifo_en),
        .wr_en(wr_en),
        .rd_en(rd_en),
        .index(),
        .last(last)
    );  
   
endmodule : fifo_top

