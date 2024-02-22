// Code your design here
module in_demux #(
  parameter NUM_SW_INST = 5,
  parameter W_WIDTH = 8,
  parameter OP_WIDTH = 32
) (
  clk, rst_n,
  sw_sel,
  addr, wr_data, wr_rd_op,
  valid,
  op_id,
  op_out, wr_fifo
);

  input clk, rst_n;
  input [2:0] sw_sel;
  input [4:0] addr;
  input [W_WIDTH-1:0] wr_data;
  input wr_rd_op;
  input valid;
  input [7:0] op_id;

  output [OP_WIDTH-1:0] op_out  [NUM_SW_INST];
  output                wr_fifo [NUM_SW_INST];

  reg [OP_WIDTH-1:0]      op_ff   [NUM_SW_INST];
  reg [OP_WIDTH-1:0]      op_nxt  [NUM_SW_INST];
  reg                     wr_fifo_ff  [NUM_SW_INST];
  reg                     wr_fifo_nxt [NUM_SW_INST];

  always @(*) begin
    op_nxt = op_ff;
    wr_fifo_nxt = wr_fifo_ff;
    
    for(int i = 0; i < NUM_SW_INST; i++) begin
      op_nxt[i] = '0;
      wr_fifo_nxt[i] = 1'b0;
    end

    if(valid) begin
      //{addr[21:17], wr_rd_s[16], wr_data[15:8], op_id[7:0]}
      op_nxt[sw_sel] = {addr, wr_rd_op, wr_data, op_id};
      wr_fifo_nxt[sw_sel] = 1'b1;
    end
  end 

  always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
      for(int i = 0; i < NUM_SW_INST; i++) begin
        op_ff[i] <= '0;
        wr_fifo_ff[i] <= 1'b0;
      end
    end 
    else begin
      op_ff <= op_nxt;
      wr_fifo_ff <= wr_fifo_nxt;
    end 
  end 

  assign op_out = op_ff;
  assign wr_fifo = wr_fifo_ff; 
endmodule