module branch_condition(
    input [31:0] rg1,
    input [31:0] rg2,
    input [2:0] br_type,
    input [6:0] op,
    output reg br_taken
);

always_comb begin
    if (op == 7'b1101111) // JAL: always taken
        br_taken = 1'b1;
    else begin
        case (br_type)
            3'b000: br_taken = (rg1 == rg2);  // BEQ
            3'b001: br_taken = (rg1 != rg2);  // BNE
            3'b101: br_taken = (rg1 < rg2);   // BLT
            3'b100: br_taken = (rg1 >= rg2);  // BGE
            3'b110: br_taken = (rg1 < rg2);   // BLTU
            3'b111: br_taken = (rg1 >= rg2);  // BGEU
            3'b010: br_taken = 1'b0;
            default: br_taken = 1'b0;         // Default case
        endcase
    end
end

endmodule
