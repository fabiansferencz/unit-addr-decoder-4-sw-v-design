module reorder # (
    parameter NUM_SW_INST = 5,
    parameter W_WIDTH = 32
)(
    input [W_WIDTH*NUM_SW_INST-1:0] data_in,
    output [W_WIDTH*NUM_SW_INST-1:0] data_out
);  

    integer i, j;
    reg [W_WIDTH*NUM_SW_INST-1:0] data_out_s;

    always @(*) begin
        for(i = 0; i < NUM_SW_INST; i = i + 1) begin
            for(j = 0; j < W_WIDTH; j = j + 1) begin
                data_out_s[NUM_SW_INST*j+i] = data_in[i*W_WIDTH+j];
            end
        end
    end

    assign data_out = data_out_s;

endmodule

