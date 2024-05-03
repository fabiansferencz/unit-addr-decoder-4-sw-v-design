module frame_mux #(
    parameter NUM_SW_INST = 5,
    parameter FRAME_WIDTH = 32
)(
    input clk, rst_n,
    input [NUM_SW_INST-1] rd_sel,
    input [FRAME_WIDTH-1:0] frame_in_0,
    input [FRAME_WIDTH-1:0] frame_in_1,
    input [FRAME_WIDTH-1:0] frame_in_2,
    input [FRAME_WIDTH-1:0] frame_in_3,
    input [FRAME_WIDTH-1:0] frame_in_4,
    output [FRAME_WIDTH-1:0] frame_out 
);

    localparam FIFO_SW_0 = 5'b00001;
    localparam FIFO_SW_1 = 5'b00010;
    localparam FIFO_SW_2 = 5'b00100;
    localparam FIFO_SW_3 = 5'b01000;
    localparam FIFO_SW_4 = 5'b10000;

    always @(posedge clk or negedge rst_n) begin
        if (~rst_n) begin
            frame_out <= 0; // Default output
        end
        else begin
            case (rd_sel)
            FIFO_SW_0 : frame_out <= frame_in_0;
            FIFO_SW_1 : frame_out <= frame_in_1;
            FIFO_SW_2 : frame_out <= frame_in_2;
            FIFO_SW_3 : frame_out <= frame_in_3;
            FIFO_SW_4 : frame_out <= frame_in_4;
            default: frame_out <= 0; // Default case
        endcase
        end
    end
endmodule
