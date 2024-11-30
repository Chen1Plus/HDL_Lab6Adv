module lab6_advanced (
    input rst,
    input clk,

    input       sw_turn,
    input [1:0] sw_speed,

    input  sonic_echo,
    output sonic_trig,

    input track_l,
    input track_c,
    input track_r,

    output [4:1] motor_in,
    output [1:0] motor_pwm_ab,
    output [7:0] led
);
    wire c1MHz, c8MHz;

    Clk8MHz             c0 (.reset(rst), .clk(clk),   .c8MHz  (c8MHz));
    ClkDivider #(.n(3)) c1 (.rst  (rst), .clk(c8MHz), .clk_div(c1MHz));

    wire [7:0] distance;

    Sonic s0 (
        .rst     (rst),
        .c1MHz   (c1MHz),
        .echo    (sonic_echo),
        .trig    (sonic_trig),
        .distance(distance)
    );
    assign led = distance;

    reg [1:0] state;

    localparam BACKWARD = 2'd00;
    localparam LEFT     = 2'd01;
    localparam RIGHT    = 2'd10;
    localparam FORWARD  = 2'b11;

    always @(posedge clk, posedge rst)
    if (rst)
        state <= FORWARD;
    else begin
        state <= state;
        case (state)
            FORWARD: begin
                if      (!track_l) state <= LEFT;
                else if (!track_r) state <= RIGHT;
            end
            LEFT: begin
                if      (!track_c) state <= FORWARD;
                else if (!track_r) state <= RIGHT;
            end
            RIGHT: begin
                if      (!track_c) state <= FORWARD;
                else if (!track_l) state <= LEFT;
            end
            default: state <= FORWARD;
        endcase
    end

    reg [9:0] speed;

    always @*
    if      (sw_speed[1]) speed <= 10'd870;
    else if (sw_speed[0]) speed <= 10'd840;
    else                  speed <= 10'd780;

    Motor #(
        .BACKWORD(BACKWARD),
        .LEFT    (LEFT),
        .RIGHT   (RIGHT),
        .FORWARD (FORWARD)
    ) m0 (
        .rst        (rst),
        .c100MHz    (clk),
        .rotate_turn(sw_turn),
        .dir        (state),
        .speed      (distance > 8'd24 ? speed : 10'd0),
        .in         (motor_in),
        .pwm_ab     (motor_pwm_ab)
    );
endmodule : lab6_advanced