
module rx_fsm #(
    parameter NUM_SW_INST = 5,
    parameter W_WIDTH = 8
) (
    input clk, rst_n,
    input [NUM_SW_INST-1:0] sel_en,
    input [7:0] op_id,
    input [W_WIDTH-1:0] rd_data,
    input [NUM_SW_INST-1:0] ack,

    output [NUM_SW_INST-1:0] sw_busy,
    output [W_WIDTH-1:0] rd_data_out,
    output [7:0] op_id_out
);
    reg [NUM_SW_INST-1:0] sw_busy_ff, sw_busy_nxt;
    reg [W_WIDTH-1:0] rd_data_out_ff, rd_data_out_nxt;
    reg [7:0] op_id_out_ff, op_id_out_nxt;

    // reg [7:0] op_id_buffer [NUM_SW_INST];
    // state_t state_m[NUM_SW_INST];

    // always @(*) begin
    //     rd_data_out_nxt <= rd_data_out_ff;
    //     ready_out_nxt <= ready_out_ff;
    //     op_id_out_nxt <= op_id_out_ff;
    //     sw_busy_nxt <= sw_busy_ff;

    //     for(int i = 0; i < NUM_SW_INST; i++) begin
    //         case(state_m[i])
    //             WAIT_OP_ID : begin
    //               if(op_id_in[i]) begin
    //                     op_id_buffer[i] = op_id_in[i];
    //                     state_m[i] = WAIT_ACK;
    //                 	sw_busy_nxt[i] = 1'b1;
    //                 end 
    //                 else begin
    //                     state_m[i] = WAIT_OP_ID;
    //                   	sw_busy_nxt[i] = 1'b0;
    //                 end 
    //             end
    //             WAIT_ACK : begin
    //                 if(ack[i]) begin
    //                     state_m[i] = WAIT_OP_ID;
    //                     rd_data_out_nxt = rd_data_in;
    //                     ready_out_nxt = ack[i];
    //                     op_id_out_nxt = op_id_buffer[i];
    //                   	sw_busy_nxt[i] = 1'b0;
    //                 end 
    //                 else begin
    //                     state_m[i] = WAIT_ACK;
    //                 end 
    //             end 
    //         endcase
    //     end
    // end

    // always @(posedge clk or negedge rst_n) begin
    //     if (!rst_n) begin
    //         rd_data_out_ff <= '0;
    //         ready_out_ff <= 1'b0;
    //         op_id_out_ff <= '0;

    //         for(int i = 0; i < NUM_SW_INST; i++) begin
    //             sw_busy_ff[i] <= 1'b0;
    //             op_id_buffer[i] <= '0;
    //             state_m[i] <= WAIT_OP_ID;
    //         end
    //     end 
    //     else begin
    //         rd_data_out_ff <= rd_data_out_nxt;
    //         ready_out_ff <= ready_out_nxt;
    //         op_id_out_ff <= op_id_out_nxt;
    //         sw_busy_ff <= sw_busy_nxt;
    //     end 
    // end    
    
    assign sw_busy = sw_busy_ff;
    assign rd_data_out = rd_data_out_ff;
    assign op_id_out = op_id_out_ff;
endmodule