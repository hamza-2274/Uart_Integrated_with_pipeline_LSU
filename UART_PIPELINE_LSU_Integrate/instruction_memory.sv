module instruction_memory (
    input var logic [31:0] address,
    output var logic [31:0] instruction
);
    
    var logic [31:0] memory [0:255]; // 256-word memory
    

    always_comb begin
        instruction = memory[address[31:2]]; // Word-aligned access
    end
    
endmodule