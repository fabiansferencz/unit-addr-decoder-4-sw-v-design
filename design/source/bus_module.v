module in_bus #(
  parameter NUM_SW_INST = 5,
  parameter W_WIDTH = 8,
  parameter FRAME_WIDTH = 32
)(
  input clk, rst_n,
  input en_in,
  input wr_rd_op,
  input valid,
  input [7:0] op_id, addr_in,//bits[7:5] represent the switch address, bits[4:0] represents the register address 
  input [W_WIDTH-1:0] wr_data_in,

  output [FRAME_WIDTH-1:0] frame_out,
  output [NUM_SW_INST-1:0] fifo_wr_en
);

  reg [FRAME_WIDTH-1:0] frame_out_ff, frame_out_nxt;
  reg [NUM_SW_INST-1:0] fifo_wr_en_ff, fifo_wr_en_nxt;

  always @(*) begin
    frame_out_nxt = frame_out_ff;
    fifo_wr_en_nxt = fifo_wr_en_ff;

    if(en_in && valid) begin
      //{addr[21:17], wr_rd_s[16], wr_data[15:8], op_id[7:0]}
      frame_out_nxt = {11'd0, addr_in[4:0], wr_rd_op, wr_data_in, op_id};
      fifo_wr_en_nxt = 0;//reset the wr_en for fifos
      fifo_wr_en_nxt[addr_in[7:5]] = 1;//set the wr_en for coresponding fifo
    end
    else begin
      frame_out_nxt = 0;
      fifo_wr_en_nxt = 0;
    end  
  end 

  always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
      frame_out_ff <= 0;
      fifo_wr_en_ff <= 0;
    end 
    else begin
      frame_out_ff <= frame_out_nxt;
      fifo_wr_en_ff <= fifo_wr_en_nxt;
    end 
  end 

  assign frame_out = frame_out_ff;
  assign fifo_wr_en = fifo_wr_en_ff; 
endmodule : in_bus