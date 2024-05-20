module delay #(
    parameter WIDTH = 8
)(
    input clk, rst_n,
    input [WIDTH-1:0] in,
    output reg [WIDTH-1:0] out
);

    always @(posedge clk or negedge rst_n) begin
        if (~rst_n) begin
            out <= 1'b0;
        end
        else begin
            out <= in;
        end
    end
endmodule
