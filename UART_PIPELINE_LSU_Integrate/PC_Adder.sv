module PC_Adder(
    input var logic [31:0] operand1,
    output var logic [31:0] sum
);
    always @(*) begin 
           sum = operand1 + 'd4;  // input + 4
    end
endmodule

