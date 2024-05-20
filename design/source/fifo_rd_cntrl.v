module fifo_rd_cntrl #(
    parameter NUM_SW_INST = 5,
    parameter W_WIDTH = 8
) (
    input clk, rst_n,
    input [NUM_SW_INST-1:0] empty, full,
    input [NUM_SW_INST-1:0] last,
    input [NUM_SW_INST-1:0] sw_busy,

    output [NUM_SW_INST-1:0] rd_en
);
    localparam IDLE = 2'd0;
    localparam WAIT = 2'd1;
    localparam CHECK_BY_PRIORITY = 2'd2;

    integer i;
    integer idx_cnt_ff, idx_cnt_nxt;
    integer circ_buffer [NUM_SW_INST:0];//memory for keeping track of each fifo priority
    

    reg [NUM_SW_INST-1:0] rd_en_ff, rd_en_nxt;
    reg [1:0] state_m_nxt, state_m_ff;

    always @(*) begin
        rd_en_nxt = rd_en_ff;
        state_m_nxt = state_m_ff;
        idx_cnt_nxt = idx_cnt_ff;

        case(state_m_ff)
            IDLE:
                begin
                    //initialise the priority with {fifo_4, fifo_3, fifo_2, fifo_1, fifio_0, 0}, at each index representing FIFO priority
                    //element at index 6 is used for shifting the priority
                    for(i = 0; i < NUM_SW_INST; i = i + 1) begin
                        circ_buffer[NUM_SW_INST-1-i] = i;
                    end 

                    state_m_nxt = CHECK_BY_PRIORITY;
                    idx_cnt_nxt = NUM_SW_INST-1;
                end
            WAIT:
                begin
                    rd_en_nxt = 0;
                    state_m_nxt = CHECK_BY_PRIORITY;
                end
            CHECK_BY_PRIORITY:
                begin
                    rd_en_nxt = 0;
                    if((empty[circ_buffer[idx_cnt_ff]] == 0 && sw_busy[circ_buffer[idx_cnt_ff]] == 0)) begin
                        rd_en_nxt[circ_buffer[idx_cnt_ff]] = 1;
                        if(last[circ_buffer[idx_cnt_ff]] == 1'b1) begin
                            state_m_nxt = WAIT;
                        end
                    end
                    else begin
                        idx_cnt_nxt = idx_cnt_nxt - 1;
                    end 

                    if(idx_cnt_ff == 0) begin
                        //shift the priority after checking each fifo for data
                        for(i = NUM_SW_INST; i > 0; i = i - 1) begin
                            circ_buffer[i] = circ_buffer[i-1];
                            
                            if(i == 1) begin
                                circ_buffer[i-1] = circ_buffer[NUM_SW_INST];
                            end 
                        end 

                        idx_cnt_nxt = NUM_SW_INST-1;
                    end 
                end 
        endcase
    end

    always @(posedge clk or negedge rst_n) begin
      if(!rst_n) begin
            rd_en_ff <= '0;
            state_m_ff <= IDLE;
            idx_cnt_ff <= 0;
        end
        else begin
            rd_en_ff <= rd_en_nxt;
            state_m_ff <= state_m_nxt;
            idx_cnt_ff <= idx_cnt_nxt;
        end
    end

    assign rd_en = rd_en_ff;
endmodule : fifo_rd_cntrl