// Code your design here
typedef enum {WAIT_OP_ID, WAIT_ACK} state_t;

module rx_fsm #(
    parameter NUM_SW_INST = 5,
    parameter W_WIDTH = 8
) (
    clk, rst_n,
    sw_busy, op_id_in,
    rd_data_in, rd_data_out,
    ack, ready, op_id_out
);

    input clk, rst_n;
    input [7:0] op_id_in [NUM_SW_INST];
    input [W_WIDTH-1:0] rd_data_in;
    input ack [NUM_SW_INST];

    output sw_busy[NUM_SW_INST];
    output [W_WIDTH-1:0] rd_data_out;
    output ready;
    output [7:0] op_id_out;

    reg sw_busy_ff [NUM_SW_INST];
    reg sw_busy_nxt [NUM_SW_INST];
    reg [W_WIDTH-1:0] rd_data_out_ff, rd_data_out_nxt;
    reg ready_out_ff, ready_out_nxt;
    reg [7:0] op_id_out_ff, op_id_out_nxt;

    reg [7:0] op_id_buffer [NUM_SW_INST];
    state_t state_m[NUM_SW_INST];

    always @(*) begin
        rd_data_out_nxt <= rd_data_out_ff;
        ready_out_nxt <= ready_out_ff;
        op_id_out_nxt <= op_id_out_ff;
        sw_busy_nxt <= sw_busy_ff;

        for(int i = 0; i < NUM_SW_INST; i++) begin
            case(state_m[i])
                WAIT_OP_ID : begin
                  if(op_id_in[i]) begin
                        op_id_buffer[i] = op_id_in[i];
                        state_m[i] = WAIT_ACK;
                    	sw_busy_nxt[i] = 1'b1;
                    end 
                    else begin
                        state_m[i] = WAIT_OP_ID;
                      	sw_busy_nxt[i] = 1'b0;
                    end 
                end
                WAIT_ACK : begin
                    if(ack[i]) begin
                        state_m[i] = WAIT_OP_ID;
                        rd_data_out_nxt = rd_data_in;
                        ready_out_nxt = ack[i];
                        op_id_out_nxt = op_id_buffer[i];
                      	sw_busy_nxt[i] = 1'b0;
                    end 
                    else begin
                        state_m[i] = WAIT_ACK;
                    end 
                end 
            endcase
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            rd_data_out_ff <= '0;
            ready_out_ff <= 1'b0;
            op_id_out_ff <= '0;

            for(int i = 0; i < NUM_SW_INST; i++) begin
                sw_busy_ff[i] <= 1'b0;
                op_id_buffer[i] <= '0;
                state_m[i] <= WAIT_OP_ID;
            end
        end 
        else begin
            rd_data_out_ff <= rd_data_out_nxt;
            ready_out_ff <= ready_out_nxt;
            op_id_out_ff <= op_id_out_nxt;
            sw_busy_ff <= sw_busy_nxt;
        end 
    end    
    
    assign sw_busy = sw_busy_ff;
    assign rd_data_out = rd_data_out_ff;
    assign ready = ready_out_ff;
    assign op_id_out = op_id_out_ff;
endmodule