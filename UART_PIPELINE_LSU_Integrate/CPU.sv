module CPU (
    input logic clock,
    input logic reset,
    input uart_rx,
    output uart_tx,
    output logic [31:0] instruction,
    output logic [31:0] ALU_result,
    output logic zero
);
    
    logic [31:0] pc_out;
    logic [31:0] pc_next;
    logic [31:0] pc_next_mux;
     logic [31:0]  mux_out;
    logic [31:0]  imm_to_bin;
    logic [31:0]  data_write_back_to_reg;
    logic [31:0] read_data_1, read_data_2;
    logic [31:0] read_data_to_bin;
    logic [3:0] ALU_control;
    logic register_write_enable,register_write_enable_memory;
    logic br_taken_mux_sel;
    logic [2:0] br_type_wire;
    logic [31:0]  mux_rs1_pc_to_operand1;
    logic [2:0] imm_sel;
    logic op_sel_rs1_pc;
    logic [31:0] J_adder_input_mux3x1,ALU_result_after_reg,read_data_2_write_after_reg;
    logic [1:0] mem_to_reg_wire,wb_sel_mw;
    logic [31:0]  reg_instruction_out,forward_to_alu_op2_mux,forward_to_alu_op1_mux,reg_pc_out,pc_out_after_reg;
    logic [4:0]  write_register_after_reg;
    logic FORWARD_A, FORWARD_B,mem_write,dm_mem_write_memory,flush;
    logic mem_read_wire,dm_mem_read_memory_wire;
 

    logic [14:0] uart_control;
    logic [3:0] uart_status;
    logic tx_fifo_wr, rx_fifo_rd, rx_in, tx_out;
    logic [7:0] tx_fifo_data_in;
    logic [7:0] rx_fifo_data_out;

    // Instantiate the PC module

    PC program_counter (
        .pc_in(pc_next_mux),
        .reset(reset),
        .clock(clock),
        .pc_out(pc_out)
    );
    

    PC_Adder pc_adder (
        .operand1(pc_out),
        .sum(pc_next)
    );
    
    // Instantiate the Instruction Memory module
    instruction_memory inst_mem (
        .address(pc_out),
        .instruction(instruction)
    );
    
    // Instantiate the Controller module
    controller ctrl (
        .instruction(reg_instruction_out),
        .ALU_control(ALU_control),
        .register_write_enable(register_write_enable),
        . opsel(opsel),
        . immsrc(imm_sel),
        .mem_to_reg(mem_to_reg_wire),
        .mem_write(mem_write),
        .mem_read(mem_read_wire),
        .br_type(br_type_wire),
        .opsel2(op_sel_rs1_pc)
    );
    
    // Instantiate the Register File module
    register_file reg_file (
        .read_register_1(reg_instruction_out[19:15]),
        .read_register_2(reg_instruction_out[24:20]),
        .clock(clock),
        .write_register(write_register_after_reg),
        .data_write( data_write_back_to_reg),
        .reset(reset),
        .write_en(register_write_enable_memory),
        .read_data_1(read_data_1),
        .read_data_2(read_data_2)
    );
      mux2x1 mux_rs2_imm (
        .a_in( forward_to_alu_op2_mux), 
        .b_in(imm_to_bin),    
        .sel(opsel),      
        .z_out(mux_out)    
    );
   ALU alu (
        .operand1( mux_rs1_pc_to_operand1),
        .operand2(mux_out),  
        .ALUoperation(ALU_control),
        .result(ALU_result),
        .zero(zero)
    );
    imm_generator imm_generator_inst(
        .instr(reg_instruction_out),
        . imm_src(imm_sel),
        .imm_out(imm_to_bin)
    );


    PC_Adder pc_adder_for_Jump (
        .operand1(pc_out_after_reg),
        .sum(J_adder_input_mux3x1)
    ); 


    mux3x1 mux_writeback(
        .in1(J_adder_input_mux3x1),
        .in2(ALU_result_after_reg),
        .in3(read_data_to_bin),
        .sel(wb_sel_mw),
        .out( data_write_back_to_reg)
    );
    mux2x1 mux_Programcounter(
        .a_in(pc_next),
        .b_in(ALU_result),
        .sel(br_taken_mux_sel),
        .z_out(pc_next_mux)
    );
    branch_condition branch_condition_inst(
        .rg1( forward_to_alu_op1_mux),
        .rg2(forward_to_alu_op2_mux),
        .br_type(br_type_wire),
        .op( reg_instruction_out[6:0]),
        .br_taken(br_taken_mux_sel)
    );
    mux2x1 mux_rs1_pc (
        .a_in(reg_pc_out), 
        .b_in( forward_to_alu_op1_mux),    
        .sel(op_sel_rs1_pc),      
        .z_out( mux_rs1_pc_to_operand1)    
    );
    register_file_fetch_to_decode register_file_fetch_to_decode_inst(
        .reg_instruction_in(instruction),
        .reg_pc_in(pc_out),
        .flush(flush),
        .reset(reset),
        .clock(clock),
        .reg_instruction_out(reg_instruction_out),
        .reg_pc_out(reg_pc_out)

    );
//forwarding muxes
    mux2x1 mux_rdata1_datawrite_forwA (
        .a_in( data_write_back_to_reg), 
        .b_in(read_data_1),    
        .sel(FORWARD_A),      
        .z_out( forward_to_alu_op1_mux)    
    );

     mux2x1 mux_rdata2_datawrite_forwB (
        .a_in( data_write_back_to_reg), 
        .b_in(read_data_2),    
        .sel(FORWARD_B),      
        .z_out( forward_to_alu_op2_mux)    
    );
    register_file_decode_to_memory register_file_decode_to_memory_inst(
        .pc_decode(reg_pc_out),
        .out_alu(ALU_result),
        .read_data_2_mux( forward_to_alu_op2_mux),
        .write_register(reg_instruction_out[11:7]),
        .reset(reset),
        .clock(clock),
        .pc_memory_write(pc_out_after_reg),
        .alu_memory_write(ALU_result_after_reg),
        .read_data_2_write(read_data_2_write_after_reg),
        .write_register_memory_write(write_register_after_reg)
    );
    forward_flush forward_flush_inst(
        .read_register_1(reg_instruction_out[19:15]),
        .read_register_2(reg_instruction_out[24:20]),       //WRONG ???????
        .write_register(write_register_after_reg),
        . reg_w(register_write_enable_memory),                                        // FROM Controller..........8*****
        . br_taken(br_taken_mux_sel),
        .sel_read_data_1(FORWARD_A),
        .sel_read_data_2(FORWARD_B),
        .flush(flush)
    );
    register_controller register_controller_inst(
        .register_write_enable(register_write_enable),
        . dm_mem_write(mem_write),  
        .dm_mem_read(mem_read_wire),                             //PROBLEM MAY OCCCURE AT MEM-ERITE !!!!!!
        .wb_sel(mem_to_reg_wire),
        .reset(reset),
        .clock(clock),
        .register_write_enable_memory(register_write_enable_memory),
        .dm_mem_write_memory(dm_mem_write_memory),
        . dm_mem_read_memory( dm_mem_read_memory_wire),
        .wb_sel_mw(wb_sel_mw)
    );

 uart UART_0(clock, reset, uart_control, tx_fifo_wr, rx_fifo_rd, tx_fifo_data_in, uart_rx, uart_tx, rx_fifo_data_out, uart_status);
 lsu lsu_0 (clock, wr_en_w, rd_en_w, alu_result_w, wdata_dm, rdata, uart_control, tx_fifo_wr, rx_fifo_rd, tx_fifo_data_in, rx_fifo_data_out, uart_status);
endmodule
