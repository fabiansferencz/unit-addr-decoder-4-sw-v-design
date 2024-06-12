module fifo # (
    parameter FIFO_SIZE = 64,
    parameter W_WIDTH = 32
)(
    input clk, rst_n,
    input fifo_en, wr_en, rd_en,
    input [W_WIDTH-1:0] data_in,
    output [W_WIDTH-1:0] data_out,
    output full, empty
);  

    reg [W_WIDTH-1:0] ram [FIFO_SIZE-1:0];//a memory with 64 locations depth and 8 bits word
    reg [$clog2(FIFO_SIZE)-1:0] wr_pos, rd_pos;

    reg full_s, empty_s; 
    reg [W_WIDTH-1:0] data_out_s;


    always @ (posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            rd_pos <= 'b0;
            wr_pos <= 'b0;
            full_s <= 'b0;
            empty_s <= 'b1;
            data_out_s <= 'b0;
        end 
        else begin
            if(fifo_en && wr_en && !full_s) begin
                ram[wr_pos] <= data_in;
                empty_s <= 1'b0;

                if(wr_pos == FIFO_SIZE - 1) begin
                    if(rd_pos == 1'b0) begin
                    full_s <= 1'b1;
                    end	
                    wr_pos <= 1'b0;
                end	
                else if(((wr_pos + 1'b1) == rd_pos)) begin
                    full_s <= 1'b1;
                    wr_pos <= wr_pos + 1;
                end	
                else begin
                    wr_pos <= wr_pos + 1;
                end	
            end 
            if(rd_en && !empty_s) begin
                data_out_s <= ram[rd_pos];
                ram[rd_pos] <= 'b0;
                full_s <= 1'b0;

                if(rd_pos == FIFO_SIZE-1) begin
                    if(wr_pos == 1'b0) begin
                        empty_s <= 1'b1;
                    end	
                    rd_pos <= 1'b0;
                end	
                else if((rd_pos + 1'b1) == wr_pos) begin
                    empty_s <= 1'b1;
                    rd_pos <= rd_pos + 1'b1;
                end	
                else begin
                    rd_pos <= rd_pos + 1;
                end	
            end
            else begin
                data_out_s <= 'b0;
            end
        end 
    end	

    assign data_out = data_out_s;
    assign empty = empty_s;
    assign full = full_s;
endmodule : fifo