module register_file (
    input var logic [4:0] read_register_1,
    input var logic [4:0] read_register_2,
    input var logic clock,
    input var logic [4:0] write_register,
    input var logic [31:0] data_write,
    input var logic reset,
    input var logic write_en,
    output var logic [31:0] read_data_1,
    output var logic [31:0] read_data_2
);
    
     logic [31:0] registers [31:0]; 
always_ff @(negedge clock or negedge reset) begin
    if (reset) begin
        for (int i = 0; i < 32; i++) begin
            registers[i] <= i;  // Initialize each register with its index
        end
    end else begin
        if (write_en && (|write_register)) begin
            registers[write_register] <= data_write;
        end
    end
end



    // Read Operations in always_comb
     always_comb begin
      //  read_data_1 = (|read_register_1) ? registers[read_register_1] : 32'h00000000;
     //   read_data_2 = (|read_register_2) ? registers[read_register_2] : 32'h00000000;
        read_data_1 = (read_register_1 == 5'd0) ? 32'h00000000 : registers[read_register_1];
        read_data_2 = (read_register_2 == 5'd0) ? 32'h00000000 : registers[read_register_2];

    end


endmodule
