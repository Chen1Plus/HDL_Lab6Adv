module Debounce (
    input  clk,
    input  in,
    output out
);
    reg [3:0] shift_reg;

    always @(posedge clk) begin
        shift_reg <= {shift_reg[2:0], in};
    end
    assign out = &shift_reg;
endmodule : Debounce
