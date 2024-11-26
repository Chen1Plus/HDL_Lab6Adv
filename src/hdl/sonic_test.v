module SonicTest (
    input rst,
    input clk,

    input  sonic_echo,
    output sonic_trig,

    output [9:0] led
);
    wire [19:0] distance;

    Sonic s0 (
        .rst     (rst),
        .clk     (clk),
        .echo    (sonic_echo),
        .trig    (sonic_trig),
        .distance(distance)
    );

    assign led = distance[11:2];
endmodule : SonicTest
