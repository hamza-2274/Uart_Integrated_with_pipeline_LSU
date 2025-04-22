module register_controller(
    input var logic  register_write_enable ,
    input var logic  dm_mem_write,
    input var logic  dm_mem_read,
    input logic [1:0] wb_sel,
    input var logic reset,
    input var logic clock,
    output var logic register_write_enable_memory,
    output var logic dm_mem_write_memory,
    output var logic  dm_mem_read_memory,
    output logic [1:0] wb_sel_mw
);
    always_ff @(negedge clock ) begin  //posedge clock?
        if (reset) begin
             register_write_enable_memory <= '0; 
            dm_mem_write_memory<= '0; 
            dm_mem_read <= '0;
            wb_sel_mw   <= '0;
        end
        else begin
             register_write_enable_memory <= register_write_enable ; 
            dm_mem_write_memory <= dm_mem_write; 
             dm_mem_read_memory <=dm_mem_read;
            wb_sel_mw   <= wb_sel   ; 
        end
    end
endmodule