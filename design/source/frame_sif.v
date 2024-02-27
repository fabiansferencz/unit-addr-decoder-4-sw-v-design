module frame_sif #(
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

    reg [NUM_SW_INST-1:0] sel_en_nxt, sel_en_ff;
    reg [7:0] addr_ff, addr_nxt;
    reg [W_WIDTH-1:0] wr_data_ff, wr_data_nxt;
    reg wr_rd_s_ff, wr_rd_s_nxt;
    
    reg [7:0] op_id_nxt, op_id_ff;

    always @(*) begin
        sel_en_nxt = sel_en_ff;
        addr_nxt = addr_ff;
        wr_data_nxt = wr_data_ff;
        wr_rd_s_nxt = wr_rd_s_ff;
        op_id_nxt = op_id_ff;

        //sending out transactions
        sel_en_nxt = load_in;
        addr_nxt = {3'b000, frame_in[21:17]};
        wr_rd_s_nxt = frame_in[16];
        wr_data_nxt = frame_in[15:8];
        op_id_nxt = frame_in[7:0];
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            sel_en_ff <= 0;
            addr_ff <= '0;
            wr_data_ff <= '0;
            wr_rd_s_ff <= 1'b0;
            op_id_ff <= 0;
        end 
        else begin
            sel_en_ff <= sel_en_nxt;
            addr_ff <= addr_nxt;
            wr_data_ff <= wr_data_nxt;
            wr_rd_s_ff <= wr_rd_s_nxt;
            op_id_ff <= op_id_nxt;
        end
    end

    assign sel_en = sel_en_ff;
    assign addr = addr_ff;
    assign wr_data = wr_data_ff;
    assign wr_rd_s = wr_rd_s_ff;
    assign op_id = op_id_ff;
endmodule : frame_sif