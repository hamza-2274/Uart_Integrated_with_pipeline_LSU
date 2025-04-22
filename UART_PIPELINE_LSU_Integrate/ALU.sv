module ALU(
    input var logic [31:0] operand1,
    input var logic [31:0] operand2,
    input var logic [3:0] ALUoperation,
    output var logic [31:0] result,
    output var logic zero
);
    always @(*) begin
        zero = 0;
        
        case (ALUoperation)
            4'b0000: result = operand1 + operand2;                       // ADD
            4'b0001: result = operand1 - operand2;                       // SUB
            4'b0010: result = operand1 & operand2;                       // AND
            4'b0011: result = operand1 | operand2;                       // OR
            4'b0100: result = operand1 ^ operand2;                       // XOR
            4'b0101: result = operand1 << operand2[4:0];                 // SLL
            4'b0110: result = operand1 >> operand2[4:0];                 // SRL
            4'b0111: result = $signed(operand1) >>> operand2[4:0];         // SRA
            4'b1000: result = ($signed(operand1) < $signed(operand2)) ? 32'b1 : 32'b0; // SLT
            4'b1001: result = (operand1 < operand2) ? 32'b1 : 32'b0;       // SLTU
            4'b1111: result = operand2; 
            default: result = 32'b0;
        endcase
        
        //  result is zero
        if (result == 32'b0) begin
            zero = 1;
        end
    end
endmodule

