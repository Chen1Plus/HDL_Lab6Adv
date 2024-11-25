// sonic_top is the module to interface with sonic sensors
// clk = 100MHz
// <Trig> and <Echo> should connect to the sensor
// <distance> is the output distance in cm
module sonic_top (
    input clk,
    input rst,
    input Echo,
    output Trig,
    output [19:0] distance
);
    wire [19:0] dis;

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

    wire clk_2_17;

    assign distance = dis;

    SonicTrigger u1(.c1MHz(c1MHz), .rst(rst), .trig(Trig));
    PosCounter u2(.clk(c1MHz), .rst(rst), .echo(Echo), .distance_count(dis));

endmodule

module PosCounter (
    input clk,
    input rst,
    input echo,
    output [19:0] distance_count
);
    localparam S0 = 2'b00;
    localparam S1 = 2'b01;
    localparam S2 = 2'b10;

    wire start, finish;
    reg [1:0] curr_state, next_state;
    reg echo_reg1, echo_reg2;
    reg [19:0] count, distance_register;

    always @(posedge clk) begin
        if(rst) begin
            echo_reg1 <= 0;
            echo_reg2 <= 0;
            count <= 0;
            distance_register  <= 0;
            curr_state <= S0;
        end
        else begin
            echo_reg1 <= echo;
            echo_reg2 <= echo_reg1;
            case(curr_state)
                S0:begin
                    if (start) curr_state <= next_state; //S1
                    else count <= 0;
                end
                S1:begin
                    if (finish) curr_state <= next_state; //S2
                    else count <= count + 1;
                end
                S2:begin
                    distance_register <= count;
                    count <= 0;
                    curr_state <= next_state; //S0
                end
            endcase
        end
    end

    always @* begin
        case(curr_state)
            S0:next_state = S1;
            S1:next_state = S2;
            S2:next_state = S0;
            default:next_state = S0;
        endcase
    end

    assign start = echo_reg1 & ~echo_reg2;
    assign finish = ~echo_reg1 & echo_reg2;

    // TODO: trace the code and calculate the distance, output it to <distance_count>

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
        num <= {n{1'b0}};
    else
        num <= num + 1'd1;

    assign clk_div = num[n - 1];
endmodule : ClkDivider
