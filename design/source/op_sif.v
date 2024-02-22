module op_sif #(
    parameter NUM_SW_INST = 5,
    parameter W_WIDTH = 8,
    parameter OP_WIDTH = 32
) (
    clk, rst_n,
    op_in, fifo_idx,
    addr, wr_data, wr_rd_s, sel_en_in,
    op_id_out, valid_in
);

    input clk, rst_n;
    input [OP_WIDTH-1:0] op_in;
    input [NUM_SW_INST>>1:0] fifo_idx;
    input valid_in;

    output [7:0] addr;
    output [W_WIDTH-1:0] wr_data;
    output wr_rd_s;
    output sel_en_in [NUM_SW_INST];
    output [7:0] op_id_out [NUM_SW_INST];

    reg [7:0] addr_ff, addr_nxt;
    reg [W_WIDTH-1:0] wr_data_ff, wr_data_nxt;
    reg wr_rd_s_ff, wr_rd_s_nxt;
    reg sel_en_in_ff [NUM_SW_INST];
    reg sel_en_in_nxt [NUM_SW_INST];
    reg [7:0] op_id_out_ff  [NUM_SW_INST];
    reg [7:0] op_id_out_nxt [NUM_SW_INST];

    reg valid_in_ff, valid_in_nxt;
  reg [NUM_SW_INST>>1:0] fifo_idx_ff, fifo_idx_nxt;

    always @(*) begin
        addr_nxt = addr_ff;
        wr_data_nxt = wr_data_ff;
        wr_rd_s_nxt = wr_rd_s_ff;
        sel_en_in_nxt = sel_en_in_ff;
        op_id_out_nxt = op_id_out_ff;

        valid_in_nxt = valid_in_ff;
        fifo_idx_nxt = fifo_idx;
		
      	valid_in_nxt = valid_in;

        for (int i = 0; i<NUM_SW_INST; i++) begin
            sel_en_in_nxt[i] = 1'b0;
            op_id_out_nxt[i] = '0; 
        end

        if(valid_in_ff) begin
            addr_nxt = op_in[21:17];
            wr_rd_s_nxt = op_in[16];
            wr_data_nxt = op_in[15:8];
            sel_en_in_nxt[fifo_idx_ff] = 1'b1;
          op_id_out_nxt[fifo_idx_ff] = op_in[7:0];
        end 
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            addr_ff <= '0;
            wr_data_ff <= '0;
            wr_rd_s_ff <= 1'b0;
            valid_in_ff <= 1'b0;
            fifo_idx_ff <= '0;

            for (int i = 0; i<NUM_SW_INST; i++) begin
                sel_en_in_ff[i] <= 1'b0;
                op_id_out_ff[i] <= '0; 
            end
        end 
        else begin
            addr_ff <= addr_nxt;
            wr_data_ff <= wr_data_nxt;
            wr_rd_s_ff <= wr_rd_s_nxt;
            sel_en_in_ff <= sel_en_in_nxt;
            op_id_out_ff <= op_id_out_nxt;
            valid_in_ff <= valid_in_nxt;
            fifo_idx_ff <= fifo_idx_nxt;
        end
    end

    assign addr = addr_ff;
    assign wr_data = wr_data_ff;
    assign wr_rd_s = wr_rd_s_ff;
    assign sel_en_in = sel_en_in_ff;
    assign op_id_out = op_id_out_ff;
endmodule