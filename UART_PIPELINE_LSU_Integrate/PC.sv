module PC(
    input var logic [31:0] pc_in,
    input var logic reset,
    input var logic clock,
    output var logic [31:0] pc_out
);
    
    always_ff @(posedge clock or posedge reset) begin
        if (reset)
            pc_out <= 32'h00000000;
        else
            pc_out <= pc_in;
    end
    
endmodule
