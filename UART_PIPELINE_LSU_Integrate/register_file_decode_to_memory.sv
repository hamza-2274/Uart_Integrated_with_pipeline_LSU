module register_file_decode_to_memory(
    input var logic [31:0]  pc_decode,
    input var logic [31:0] out_alu,
    input var logic [31:0] read_data_2_mux,
    input var logic [4:0]   write_register,
    input  var logic  reset,
    input  var logic  clock,
    output var logic [31:0] pc_memory_write,
    output var logic [31:0] alu_memory_write,
    output var logic [31:0] read_data_2_write,
    output var logic [4:0]  write_register_memory_write
);
    always_ff @(negedge clock) begin
        if(reset)begin 
            pc_memory_write   <= 'h0;
            alu_memory_write  <= 'h0;
            read_data_2_write  <= 'h0;
            write_register_memory_write   <= 'h0; 
        end
        else begin
             pc_memory_write     <= pc_decode   ; 
            alu_memory_write    <= out_alu ; 
            read_data_2_write <=  read_data_2_mux ; 
            write_register_memory_write       <= write_register      ; 
        end
    end
endmodule