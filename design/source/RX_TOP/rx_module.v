
module rx_module #(
    parameter NUM_SW_INST = 5,
    parameter W_WIDTH = 8
) (
    input clk, rst_n,
    input [NUM_SW_INST-1:0] sel_en,
    input [W_WIDTH-1:0] rd_data,
    input [NUM_SW_INST-1:0] ack,

    output [NUM_SW_INST-1:0] sw_busy,
    output [W_WIDTH-1:0] rd_data_out
);
    reg [NUM_SW_INST-1:0] sw_busy_ff, sw_busy_nxt;
    reg [W_WIDTH-1:0] rd_data_out_ff, rd_data_out_nxt;

    integer i;

    always @(*) begin
        sw_busy_nxt = sw_busy_ff;
        rd_data_out_nxt = rd_data_out_ff;

        for(i = 0; i < NUM_SW_INST; i = i + 1) begin
            if(sel_en[i] == 1) begin
                sw_busy_nxt[i] = 1;
                i = NUM_SW_INST;//break
            end 
        end 

        for(i = 0; i < NUM_SW_INST; i = i + 1) begin
            if(ack[i] == 1) begin
                sw_busy_nxt[i] = 0;
                rd_data_out_nxt = rd_data;
                i = NUM_SW_INST;
            end 
            else begin
                rd_data_out_nxt = '0;
            end
        end 
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            sw_busy_ff <= '0;
            rd_data_out_ff <= 1'b0;
        end 
        else begin
            sw_busy_ff <= sw_busy_nxt;
            rd_data_out_ff <= rd_data_out_nxt;
        end 
    end    
    
    assign sw_busy = sw_busy_ff;
    assign rd_data_out = rd_data_out_ff;
endmodule : rx_module