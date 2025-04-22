module mux2x1 (
    input var logic [31:0] a_in,
    input var logic[31:0] b_in,
    input var logic sel,
    output var logic [31:0] z_out
);

    always @(*) begin
        if (sel) begin
            z_out = b_in;
        end else begin
            z_out = a_in;
        end
    end

endmodule
