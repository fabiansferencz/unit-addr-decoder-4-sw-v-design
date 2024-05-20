module bit_mux # (
    parameter NUM_SW_INST = 5
)(
    input clk, rst_n,
    input [NUM_SW_INST-1:0] data,
    input [NUM_SW_INST-1:0] sel,
    output out
);  

    assign out = (sel == 1'b0) ? 1'b0 : data[$clog2(sel)];
   
endmodule

