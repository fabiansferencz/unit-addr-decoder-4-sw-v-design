module fifo_cnt # (
    parameter FIFO_SIZE = 64
)(
    input clk, rst_n,
    input fifo_en, wr_en, rd_en,
    output [$clog2(FIFO_SIZE):0] index,
    output last
);  

    reg [$clog2(FIFO_SIZE):0] index_s;

    always @ (posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            index_s <= 'b0;
        end 
        else begin
            if(fifo_en && wr_en && index_s < FIFO_SIZE) begin
                index_s = index_s + 1;
            end 
            if(rd_en && index_s > 'b0) begin
                index_s = index_s - 1;
            end
        end 
    end	

    assign index = index_s;
    assign last = index_s == 1'b1 ? 1'b1 : 1'b0;
   
endmodule : fifo_cnt

