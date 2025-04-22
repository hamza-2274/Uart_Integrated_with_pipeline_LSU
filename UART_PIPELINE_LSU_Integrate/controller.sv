module controller (
    input var logic [31:0] instruction,
    output var logic [3:0] ALU_control,
    output var logic register_write_enable,
    output var logic opsel,
    output var logic [2:0] immsrc,
    output var logic [1:0] mem_to_reg,
     output var logic mem_write,
     output var logic mem_read,
     output var logic [2:0] br_type,
     output var logic opsel2
);

    var logic [6:0] op;
    var logic [6:0] func7;
    var logic [2:0] func3;

    // Extract instruction fields
    always_comb begin
        op    = instruction[6:0];      // opcode
        func7 = instruction[31:25];     // funct7 (R-type)
        func3 = instruction[14:12];     // funct3 (R-type)
    end

    // Determine write enable for opcodes
    always_comb begin
        if (op == 7'b0000011 || op == 7'b0110011 || op == 7'b0110111 ||
            op == 7'b0010111 || op == 7'b1101111 || op == 7'b0010011)
            register_write_enable = 1'b1;
        else
            register_write_enable = 1'b0;
    end

    always_comb begin
        case (op)
            7'b0110011: // R-type instructions
                case ({func7, func3})
                    10'b0000000_000: ALU_control = 4'b0000; // ADD
                    10'b0100000_000: ALU_control = 4'b0001; // SUB
                    10'b0000000_111: ALU_control = 4'b0010; // AND
                    10'b0000000_110: ALU_control = 4'b0011; // OR
                    10'b0000000_100: ALU_control = 4'b0100; // XOR
                    10'b0000000_001: ALU_control = 4'b0101; // SLL
                    10'b0000000_101: ALU_control = 4'b0110; // SRL
                    10'b0100000_101: ALU_control = 4'b0111; // SRA
                    10'b0000000_010: ALU_control = 4'b1000; // SLT
                    10'b0000000_011: ALU_control = 4'b1001; // SLTU
                    default:         ALU_control = 4'b0000; // Default
                endcase

            7'b0010011: // I-type arithmetic instructions
                case (func3)
                    3'b000: ALU_control = 4'b0000; // ADDI
                    3'b111: ALU_control = 4'b0010; // ANDI
                    3'b110: ALU_control = 4'b0011; // ORI
                    3'b100: ALU_control = 4'b0100; // XORI
                    3'b010: ALU_control = 4'b1000; // SLTI
                    3'b011: ALU_control = 4'b1001; // SLTIU
                    3'b001: ALU_control = 4'b0101; // SLLI
                    3'b101:
                        if (func7 == 7'b0000000)
                            ALU_control = 4'b0110; // SRLI
                        else if (func7 == 7'b0100000)
                            ALU_control = 4'b0111; // SRAI
                        else
                            ALU_control = 4'b0000; // Default
                    default: ALU_control = 4'b0000; // Default
                endcase

            7'b0000011, // I-type load instructions
            7'b0100011: // S-type store instructions
                ALU_control = 4'b0000; // Use ALU for address calculation (ADD)

            7'b1100011: // B-type branch instructions
                case (func3)
                    3'b000: ALU_control = 4'b1111; // BEQ
                    3'b001: ALU_control = 4'b1111; // BNE
                    3'b100: ALU_control = 4'b1111; // BLT
                    3'b101: ALU_control = 4'b1111; // BGE
                    3'b110: ALU_control = 4'b1111; // BLTU
                    3'b111: ALU_control = 4'b1111; // BGEU
                    default: ALU_control = 4'b0000; // Default
                endcase

            7'b0110111, // U-type LUI instruction
            7'b0010111: // U-type AUIPC instruction
                ALU_control = 4'b1111; // Pass through immediate

            7'b1101111, // J-type JAL instruction
            7'b1100111: // I-type JALR instruction
                ALU_control = 4'b0000; // Pass through immediate

            default: ALU_control = 4'b0000; // Default
        endcase
    end

    // Define opsel
    always_comb begin
        opsel = (op == 7'b0000011 || op == 7'b0100011 ||  // lw I, sw
                 op == 7'b0010011 || op == 7'b1100011 ||  // addi I, B
                 op == 7'b1101111 || op == 7'b0110111 ||  // JAL, LUI
                 op == 7'b0010111) ? 1'b1 : 1'b0;         // AUIPC
    end

    // Define immsrc
    always_comb begin
        immsrc = (op == 7'b0010011) ? 3'b000 :  // I ADDI
                 (op == 7'b0000011) ? 3'b000 :  // I LW
                 (op == 7'b0100011) ? 3'b001 :  // S SW
                 (op == 7'b1100011) ? 3'b010 :  // B BEQ, BNE
                 (op == 7'b1101111) ? 3'b011 :  // J JAL
                 (op == 7'b0110111) ? 3'b100 :  // U LUI
                 (op == 7'b0010111) ? 3'b100 :  // U AUIPC
                 3'b000;
    end



always_comb begin
    case (op)
        7'b1101111: // JAL (Jump and Link)
            mem_to_reg = 2'b00; // Selects PC + 4 as the value to write back
        
         7'b0010011, 7'b0110111, // LUI (Load Upper Immediate)
        7'b0010111, // AUIPC (Add Upper Immediate to PC)
        7'b0110011: // R-type arithmetic instructions (ADD, SUB, AND, OR, etc.)
            mem_to_reg = 2'b01; // Selects ALU result for write-back
        
       
        7'b0000011: // Load instructions (LB, LH, LW, LBU, LHU)
            mem_to_reg = 2'b10; // Selects memory output for write-back
        
        default:
            mem_to_reg = 2'b01; // Default case (ALU result)
    endcase
end




    always_comb begin
    mem_write = (op == 7'b0100011) ? 1'b1 : 1'b0;
    mem_read  = (op == 7'b0000011) ? 1'b1 : 1'b0;
end


always_comb begin
    if (op == 7'b1100011) 
        br_type = func3; 
    else 
        br_type = 3'b010;
end


always_comb begin
    if (op == 7'b1100011)         // Branch instructions (BEQ, BNE, etc.)
        opsel2 = 1'b0;             
    else if (op == 7'b0000011 ||   // Load instructions (LB, LH, LW, LBU, LHU)
             op == 7'b0100011 ||   // Store instructions (SB, SH, SW)
             op == 7'b0010011)     // Immediate arithmetic instructions (ADDI, ANDI, ORI, etc.)
        opsel2 = 1'b1;
    else if (op == 7'b0110011)     // R-type arithmetic instructions (ADD, SUB, AND, OR, etc.)
        opsel2 = 1'b1;
    else if (op == 7'b1101111)     // JAL instruction (Jump and Link)
        opsel2 = 1'b0;
    else if (op == 7'b0110111 ||   // LUI (Load Upper Immediate)
             op == 7'b0010111)     // AUIPC (Add Upper Immediate to PC)
        opsel2 = 1'b0;
    else
        opsel2 = 1'b0;             // Default case
end


endmodule
