module fifo_rd_controler #(
    parameter NUM_SW_INST = 5,
    parameter W_WIDTH = 8,
    parameter OP_WIDTH = 32
) (
    clk, rst_n,
    sw_busy, empty_in, full_in,
    rd_fifo, valid_out, fifo_idx_out
);

    input clk, rst_n;
    input sw_busy[NUM_SW_INST];
    input empty_in[NUM_SW_INST];
    input full_in[NUM_SW_INST];

    output rd_fifo[NUM_SW_INST];
    output valid_out;
    output [NUM_SW_INST>>1:0] fifo_idx_out;

    reg rd_fifo_ff[NUM_SW_INST];
    reg rd_fifo_nxt[NUM_SW_INST];
    reg valid_out_ff, valid_out_nxt;
    reg [NUM_SW_INST>>1:0] fifo_idx_cnt_ff, fifo_idx_cnt_nxt;

    always @(*) begin
        rd_fifo_nxt = rd_fifo_ff;
        valid_out_nxt = valid_out_ff;
        fifo_idx_cnt_nxt = fifo_idx_cnt_ff;
        
        valid_out_nxt = 1'b0;
        for(int i = 0; i < NUM_SW_INST; i++) begin
            rd_fifo_nxt[i] = 1'b0;
        end

        if(!empty_in[fifo_idx_cnt_ff] && !sw_busy[fifo_idx_cnt_ff]) begin
            rd_fifo_nxt[fifo_idx_cnt_ff] = 1'b1;
            valid_out_nxt = 1'b1;
        end
       
        if(fifo_idx_cnt_ff == NUM_SW_INST - 1) begin
            fifo_idx_cnt_nxt = '0;
        end
        else begin
            fifo_idx_cnt_nxt = fifo_idx_cnt_nxt + 1;
        end
    end

    always @(posedge clk or negedge rst_n) begin
      if(!rst_n) begin
            fifo_idx_cnt_ff <= '0;
            valid_out_ff = '0;

            for(int i = 0; i < NUM_SW_INST; i++) begin
                rd_fifo_ff[i] <= 1'b0;
            end
        end
        else begin
            fifo_idx_cnt_ff <= fifo_idx_cnt_nxt;
            valid_out_ff <= valid_out_nxt;
            rd_fifo_ff <= rd_fifo_nxt;
        end
    end

    assign rd_fifo = rd_fifo_ff;
    assign fifo_idx_out = fifo_idx_cnt_ff;
    assign valid_out = valid_out_ff;
endmodule