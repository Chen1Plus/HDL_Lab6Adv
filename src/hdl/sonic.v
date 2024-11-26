// sonic_top is the module to interface with sonic sensors
// clk = 100MHz
// <Trig> and <Echo> should connect to the sensor
// <distance> is the output distance in cm
module Sonic (
    input         rst,
    input         clk,
    input         echo,
    output        trig,
    output [19:0] distance
);
    wire c1MHz, c8MHz;

    Clk8MHz c0 (
        .reset(rst),
        .clk  (clk),
        .c8MHz(c8MHz)
    );

    ClkDivider c1 (
        .rst    (rst),
        .clk    (clk),
        .clk_div(c1MHz)
    );

    SonicTrigger st0 (
        .rst(rst),
        .c1MHz(c1MHz),
        .trig(trig)
    );

    PosCounter pc0 (
        .rst(rst),
        .c1MHz(c1MHz),
        .echo(echo),
        .distance_count(distance)
    );
endmodule

module PosCounter (
    input rst,
    input c1MHz,
    input echo,
    output [19:0] distance_count
);
    localparam S0 = 2'b00;
    localparam S1 = 2'b01;
    localparam S2 = 2'b10;

    wire start, finish;
    reg [1:0] state;
    // it seems echo is not necessary
    reg echo_reg, echo_delay;
    // it seems like 19-bits is enough
    reg [19:0] count, distance_register;

    always @(posedge c1MHz, posedge rst) begin
        if (rst) begin
            echo_reg <= 0;
            echo_delay <= 0;
            count <= 0;
            distance_register  <= 0;
            state <= S0;
        end
        else begin
            echo_reg <= echo;
            echo_delay <= echo_reg;
            case(state)
                S0:begin
                    if (start) state <= S1; //S1
                    else count <= 0;
                end
                S1:begin
                    if (finish) state <= S2; //S2
                    else count <= count + 1;
                end
                S2:begin
                    distance_register <= count;
                    count <= 0;
                    state <= S0; //S0
                end
            endcase
        end
    end

    assign start = echo_reg & ~echo_delay;
    assign finish = ~echo_reg & echo_delay;

    // DONE: trace the code and calculate the distance, output it to <distance_count>
    assign distance_count = distance_register * 17 / 1000;
endmodule

module SonicTrigger (
    input  rst,
    input  c1MHz,
    output trig
);
    reg [16:0] cnt;

    always @(posedge c1MHz, posedge rst)
    if (rst)
        cnt <= 0;
    else if (cnt < 17'd100000)
        cnt <= cnt + 1;
    else
        cnt <= 0;

    assign trig = !rst && (cnt < 17'd11);
endmodule : SonicTrigger

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
