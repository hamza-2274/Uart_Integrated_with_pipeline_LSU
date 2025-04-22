module forward_flush(
    input var logic [4:0] read_register_1,
    input var logic [4:0] read_register_2,
    input var logic [4:0] write_register,  // The register to which data is written
    input var logic reg_w,  // Register write enable
    input var logic br_taken,  // Branch taken flag (for flush)
    output var logic sel_read_data_1,  // Forward signal for read_register_1
    output var logic sel_read_data_2,  // Forward signal for read_register_2
    output var logic flush  // Flush signal
);
   logic rs1_valid, rs2_valid;
    logic sel_read_data_1_1 , sel_read_data_2_2;
    always_comb begin
        // Valid if register is not zero (i.e., not x0)
        rs1_valid = |read_register_1;
        rs2_valid = |read_register_2;

        // Default values
        sel_read_data_1 = 1'b1;
        sel_read_data_2 = 1'b1;

        // Forwarding logic
        if (reg_w && (write_register != 5'd0)) begin
            sel_read_data_1_1 = (write_register == read_register_1) && rs1_valid;
            sel_read_data_2_2 = (write_register == read_register_2) && rs2_valid;
             sel_read_data_1 = ~(sel_read_data_1_1);
              sel_read_data_2=~(sel_read_data_2_2);
        end

        // Flush if branch taken
        flush = |br_taken;
    end

endmodule