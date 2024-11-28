module lab6_advanced (
    input rst,
    input clk,

    input  sonic_echo,
    output sonic_trig,

    input left_track,
    input right_track,
    input mid_track,

    output IN1,
    output IN2,
    output IN3,
    output IN4,
    output left_pwm,
    output right_pwm,
    output [5:0] led
    // You may modify or add more input/ouput yourself.
);
    wire c1MHz, c8MHz;

    Clk8MHz             c0 (.reset(rst), .clk(clk),   .c8MHz  (c8MHz));
    ClkDivider #(.n(3)) c1 (.rst  (rst), .clk(c8MHz), .clk_div(c1MHz));

    wire [5:0] distance;

    Sonic s0 (
        .rst     (rst),
        .c1MHz   (c1MHz),
        .echo    (sonic_echo),
        .trig    (sonic_trig),
        .distance(distance)
    );
    assign led = distance;

    // We have connected the motor and sonic_top modules in the template file for you.
    // TODO: control the motors with the information you get from ultrasonic sensor and 3-way track sensor.
    reg [1:0] mode, next_mode;
    reg [9:0] speed;
    motor A(
        .clk(clk),
        .rst(rst),
        .mode(mode),
        .speed(speed),
        .pwm({left_pwm, right_pwm}),
        .l_IN({IN1, IN2}),
        .r_IN({IN3, IN4})
    );

    reg state, next_state;
    parameter FORWARD = 0;
    parameter TURN = 1;

    always @(posedge clk, posedge rst) begin
        if (rst) begin
            state <= FORWARD;
            mode <= 2'b11;
        end else begin
            state <= next_state;
            mode <= next_mode;
        end
    end

    always @* begin
        speed = distance > 8 ? 10'd800 : 10'd0;
        case (state)
            FORWARD: begin
                next_state = !left_track || !right_track ? TURN : FORWARD;
                if (!right_track) begin
                    next_mode = 2'b01;
                end else if (!left_track) begin
                    next_mode = 2'b10;
                end else begin
                    next_mode = 2'b11;
                end
            end
            TURN: begin
                next_state = !mid_track ? FORWARD : TURN;
                if (!right_track) begin
                    next_mode = 2'b10;
                end else if (!left_track) begin
                    next_mode = 2'b01;
                end else begin
                    next_mode = mode;
                end
            end
            default: begin
                next_state = FORWARD;
                next_mode = 2'b11;
            end
        endcase
    end
endmodule