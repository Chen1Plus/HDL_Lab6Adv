// This module take "mode" input and control two motors accordingly.
// clk should be 100MHz for PWM_gen module to work correctly.
// You can modify / add more inputs and outputs by yourself.
module Motor (
    input rst,
    input c100MHz,
    input [1:0] mode,
    input [9:0] speed,
    output [1:0] pwm_lr,
    output reg [1:0] r_IN,
    output reg [1:0] l_IN
);
    wire pwm;

    MotorPWM m0 (
        .rst    (rst),
        .c100MHz(c100MHz),
        .duty   (speed),
        .out    (pwm)
    );
    assign pwm_lr = {2{pwm}};

    always @* begin
        case (mode)
            2'b00: begin
                l_IN = 2'b00;
                r_IN = 2'b00;
            end
            2'b01: begin
                l_IN = 2'b01;
                r_IN = 2'b00;
            end
            2'b10: begin
                l_IN = 2'b00;
                r_IN = 2'b10;
            end
            2'b11: begin
                l_IN = 2'b01;
                r_IN = 2'b10;
            end
        endcase
    end
endmodule : Motor

module MotorPWM (
    input       rst,
    input       c100MHz,
    input [9:0] duty,
    output reg  out
);
    localparam FREQ = 25_000;
    localparam [$clog2(100_000_000 / FREQ) - 1:0] CNT_MAX = 100_000_000 / FREQ;

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