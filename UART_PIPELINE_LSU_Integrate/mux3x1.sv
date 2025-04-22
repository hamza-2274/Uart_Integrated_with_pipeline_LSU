module mux3x1 (
    input var logic [31:0] in1,   // Input 1 (32-bit)
    input var logic [31:0] in2,   // Input 2 (32-bit)
    input var logic [31:0] in3,   // Input 3 (32-bit)
    input var logic [1:0] sel,    // 2-bit selector
    output var logic [31:0] out   // 32-bit output
);

always_comb begin
    case (sel)
        2'b00: out = in1; // Select input 1
        2'b01: out = in2; // Select input 2
        2'b10: out = in3; // Select input 3
        default: out = 32'b0; // Default case (output zero)
    endcase
end

endmodule
