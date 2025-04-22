module register_file_fetch_to_decode(
    input var logic [31:0] reg_instruction_in,
    input var logic [31:0] reg_pc_in,
    input var logic flush,
    input var logic reset,
    input var logic clock,
    output var logic [31:0] reg_instruction_out,
     output var logic [31:0] reg_pc_out
);
    always_ff @(posedge clock) begin
        if ( reset ) begin 
            reg_instruction_out <= 32'b0;
            reg_pc_out          <= 32'h0;
        end

        else if (flush) begin
            reg_instruction_out <= 32'h00000013; //nop
           reg_pc_out          <= reg_pc_out;
        end

        else begin
            reg_instruction_out <= reg_instruction_in;
            reg_pc_out          <= reg_pc_in;
        end
    end
endmodule