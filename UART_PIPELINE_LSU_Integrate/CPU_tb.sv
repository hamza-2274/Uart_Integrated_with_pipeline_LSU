`timescale 1ns / 1ps

module CPU_tb;
    // Testbench signals
    logic clock;
    logic reset;
    logic [31:0] instruction;
    logic [31:0] ALU_result;
    logic zero;

    // Instantiate the CPU
    CPU uut (
        .clock(clock),
        .reset(reset),
        .instruction(instruction),
        .ALU_result(ALU_result),
        .zero(zero)
    );
    
    // Clock generation
    always #5 clock = ~clock; // 10ns period clock
    
    initial begin
        // Initialize signals
        clock = 0;
        reset = 1;
        
        // Apply reset
        #5 reset = 0;
        
        // Allow some time for execution
        #100;
        
        // Observe results
        $display("Instruction: %h", instruction);
        $display("ALU Result: %h", ALU_result);
        $display("Zero Flag: %b", zero);
        
        // End simulation
        #50 $stop;
    end
endmodule
