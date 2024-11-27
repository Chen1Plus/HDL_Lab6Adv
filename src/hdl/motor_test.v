module motor_test (
    input clk,
    input rst,
    input [1:0] sw,
    output IN1,
    output IN2,
    output IN3,
    output IN4,
    output left_pwm,
    output right_pwm
);
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
    always @(*) begin
        mode = sw;
        speed = 10'd750;
    end
endmodule