module ClkDivider #(
    parameter n = 1
)(
    input  rst,
    input  clk,
    output clk_div
);
    reg [n - 1:0] num;

    always @(posedge clk, posedge rst)
    if (rst)
        num <= {1'b0, {(n - 1){1'b1}}};
    else
        num <= num + 1'd1;

    assign clk_div = num[n - 1];
endmodule : ClkDivider