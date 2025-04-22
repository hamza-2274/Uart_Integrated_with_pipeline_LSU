module Tx_FIFO (
    input logic clk, reset,
    input logic [7:0] data_in,
    input logic wr_en, data_read,  
    output logic [7:0] data_out,
    output logic txff, txfe
);
    
    logic [7:0] fifo [7:0];
    logic [2:0] wr_ctr, rd_ctr;
    logic [3:0] stored_bytes;

    always @(posedge clk) begin
        if (reset) begin
            for (int i = 0; i < 8; i++)
                fifo[i] <= 8'b0;
            wr_ctr = 3'b0;
            rd_ctr = 3'b0;
            stored_bytes <= 4'b0;
        end
        else begin
            if (wr_en && ~txff) begin
                fifo[wr_ctr] <= data_in;
                stored_bytes <= stored_bytes + 1;
                if (wr_ctr == 3'd7) 
                    wr_ctr <= 3'b0;
                else
                    wr_ctr <= wr_ctr + 1;
            end 
            // When data has been read from FIFO (transmitted) successfully
            if (data_read) begin
                stored_bytes <= stored_bytes - 1;
                if (rd_ctr == 3'd7)
                    rd_ctr <= 3'b0;
                else
                    rd_ctr <= rd_ctr + 1;
            end
            // When data is being written and read in the same clock cycle
            if ((wr_en && ~txff) && (data_read))
                stored_bytes <= stored_bytes;
        end

    end

    assign txff = (stored_bytes == 4'd8) ? 1'b1 : 1'b0;
    assign txfe = (stored_bytes == 4'b0) ? 1'b1 : 1'b0;
    assign data_out = (~txfe) ? fifo[rd_ctr] : 8'b0;         // If FIFO is empty, output is 8'b0
//f not empty, output the current read pointer byte.
//If empty, default to 8'b0
endmodule