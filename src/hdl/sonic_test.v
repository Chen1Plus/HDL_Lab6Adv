module SonicTest (
    input        rst,
    input        clk,
    input        sonic_echo,
    output       sonic_trig,
    output [5:0] led
);
    Sonic s0 (
        .rst     (rst),
        .clk     (clk),
        .echo    (sonic_echo),
        .trig    (sonic_trig),
        .distance(led)
    );
endmodule : SonicTest
