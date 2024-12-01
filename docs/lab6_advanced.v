module lab6_advanced (
    input rst,
    input clk,

    input       sw_stop,
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

    wire track_l_db, track_c_db, track_r_db;

    Debounce d0 (.clk(clk), .in(track_l), .out(track_l_db));
    Debounce d1 (.clk(clk), .in(track_c), .out(track_c_db));
    Debounce d2 (.clk(clk), .in(track_r), .out(track_r_db));

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
        .dir        (state),
        .speed      (!sw_stop && distance > 8'd24 ? speed : 10'd0),
        .in         (motor_in),
        .pwm_ab     (motor_pwm_ab)
    );
endmodule : lab6_advanced

module Motor #(
    parameter [1:0] BACKWORD = 2'b00,
    parameter [1:0] LEFT     = 2'b01,
    parameter [1:0] RIGHT    = 2'b10,
    parameter [1:0] FORWARD  = 2'b11
)(
    input rst,
    input c100MHz,

    input [1:0] dir,
    input [9:0] speed,

    output reg [3:0] in,
    output     [1:0] pwm_ab
);
    wire pwm;

    MotorPWM m0 (
        .rst    (rst),
        .c100MHz(c100MHz),
        .duty   (speed),
        .out    (pwm)
    );
    assign pwm_ab = {2{pwm}};

    always @* case (dir)
        BACKWORD: in <= 4'b1001;
        LEFT:     in <= 4'b0010;
        RIGHT:    in <= 4'b0100;
        FORWARD:  in <= 4'b0110;
    endcase
endmodule : Motor

module MotorPWM (
    input       rst,
    input       c100MHz,
    input [9:0] duty,
    output reg  out
);
    localparam FREQ = 15'd25_000;
    localparam [$clog2(100_000_000 / FREQ) - 1:0] CNT_MAX = 27'd100_000_000 / FREQ;

    wire [$clog2(CNT_MAX) - 1:0] cnt_duty = {10'b0, CNT_MAX} * duty / 1024;
    reg [31:0] cnt;

    always @(posedge c100MHz, posedge rst)
    if (rst || cnt >= CNT_MAX) begin
        cnt <= 0;
        out <= 0;
    end else begin
        cnt <= cnt + 1;
        out <= cnt < cnt_duty;
    end
endmodule : MotorPWM

module Sonic (
    input            rst,
    input            c1MHz,
    input            echo,
    output           trig,
    output reg [7:0] distance // unit: cm
);
    reg [16:0] trig_cnt;

    always @(posedge c1MHz, posedge rst) begin
        if (rst || trig_cnt >= 17'd100000)
            trig_cnt <= 0;
        else
            trig_cnt <= trig_cnt + 1;
    end
    assign trig = !rst && (trig_cnt < 17'd11);

    reg  [1:0] pos_state;
    reg [13:0] pos_cnt;

    localparam POS_S0 = 2'b00;
    localparam POS_S1 = 2'b01;
    localparam POS_S2 = 2'b10;

    reg echo_delay;
    always @(posedge c1MHz) echo_delay <= echo;

    always @(posedge c1MHz, posedge rst)
    if (rst) begin
        pos_state <= POS_S0;
        pos_cnt <= 12'd0;
    end else begin
        pos_state <= pos_state;
        case(pos_state)
            POS_S0: begin
                if (echo & ~echo_delay) pos_state <= POS_S1;
                pos_cnt <= 12'd0;
            end
            POS_S1: begin
                if (~echo & echo_delay) pos_state <= POS_S2;
                pos_cnt <= pos_cnt + 12'd1;
            end
            default: begin
                pos_state <= POS_S0;
                pos_cnt <= pos_cnt;
            end
        endcase
    end

    reg [7:0] distance_reg;

    always @(posedge c1MHz, posedge rst) begin
        if (rst)
            distance_reg <= 0;
        else if (pos_state == POS_S2)
            distance_reg <= pos_cnt * 16'd17 / 1000;
        else
            distance_reg <= distance_reg;
    end

    always @(posedge c1MHz, posedge rst) begin
        if (rst)
            distance <= 0;
        else if (trig_cnt >= 17'd100000)
            distance <= distance_reg;
        else
            distance <= distance;
    end
endmodule : Sonic