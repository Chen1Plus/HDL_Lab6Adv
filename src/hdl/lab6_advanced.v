module lab6_advanced (
    input rst,
    input clk,

    input       sw_stop,
    input       enable_distance,
    input       sw_speed_max,
    input [7:0] sw_speed,

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

    wire track_l_db, track_c_db, track_r_db;

    Debounce d0 (.clk(clk), .in(track_l), .out(track_l_db));
    Debounce d1 (.clk(clk), .in(track_c), .out(track_c_db));
    Debounce d2 (.clk(clk), .in(track_r), .out(track_r_db));

    reg [1:0] state;

    localparam BACKWARD = 2'b00;
    localparam LEFT     = 2'b01;
    localparam RIGHT    = 2'b10;
    localparam FORWARD  = 2'b11;

    always @(posedge clk, posedge rst)
    if (rst)
        state <= FORWARD;
    else begin
        state <= state;
        case (state)
            FORWARD: begin
                if      (!track_l_db) state <= LEFT;
                else if (!track_r_db) state <= RIGHT;
            end
            LEFT: begin
                if      (!track_c_db) state <= FORWARD;
                else if (!track_r_db) state <= RIGHT;
            end
            RIGHT: begin
                if      (!track_c_db) state <= FORWARD;
                else if (!track_l_db) state <= LEFT;
            end
            default: state <= FORWARD;
        endcase
    end

    reg [9:0] speed;

    always @* begin
        if      (sw_speed_max) speed = 10'd1023;
        else if (sw_speed[7]) speed = 10'd950;
        else if (sw_speed[6]) speed = 10'd940;
        else if (sw_speed[5]) speed = 10'd930;
        else if (sw_speed[4]) speed = 10'd920;
        else if (sw_speed[3]) speed = 10'd910;
        else if (sw_speed[2]) speed = 10'd900;
        else if (sw_speed[1]) speed = 10'd870;
        else if (sw_speed[0]) speed = 10'd840;
        else                  speed = 10'd780;

        if (state == LEFT || state == RIGHT) speed = 10'd1023;
    end

    Motor #(
        .BACKWORD(BACKWARD),
        .LEFT    (LEFT),
        .RIGHT   (RIGHT),
        .FORWARD (FORWARD)
    ) m0 (
        .rst        (rst),
        .c100MHz    (clk),
        .dir        (state),
        .speed      (!sw_stop && (!enable_distance || distance > 8'd6) ? speed : 10'd0),
        .in         (motor_in),
        .pwm_ab     (motor_pwm_ab)
    );
endmodule : lab6_advanced