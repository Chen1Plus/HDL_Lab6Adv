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
    output right_pwm
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

    // We have connected the motor and sonic_top modules in the template file for you.
    // TODO: control the motors with the information you get from ultrasonic sensor and 3-way track sensor.
    reg [1:0] mode;
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

    always @* begin
        if (distance < 15) begin
            mode = 2'b00;
            speed = 10'd800;
        end else begin
            if (!right_track) begin
                mode = 2'b10;
            end else if (!left_track) begin
                mode = 2'b01;
            end else if (!mid_track) begin
                mode = 2'b11;
            end else begin
                mode = 2'b10;
            end
            if (!right_track + !mid_track + !left_track != 1) begin
                speed = 10'd650;
            end else begin
                speed = 10'd800;
            end
        end
    end
endmodule