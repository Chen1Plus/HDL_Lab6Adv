module Motor #(
    parameter BACKWORD = 2'b00,
    parameter LEFT     = 2'b01,
    parameter RIGHT    = 2'b10,
    parameter FORWARD  = 2'b11
)(
    input rst,
    input c100MHz,

    input [1:0] dir,
    input [9:0] speed,

    output reg [1:0] r_IN,
    output reg [1:0] l_IN,
    output [1:0]     pwm_lr
);
    wire pwm;

    MotorPWM m0 (
        .rst    (rst),
        .c100MHz(c100MHz),
        .duty   (speed),
        .out    (pwm)
    );
    assign pwm_lr = {2{pwm}};

    always @* case (dir)
        BACKWORD: begin
            l_IN = 2'b10;
            r_IN = 2'b01;
        end
        LEFT: begin
            l_IN = 2'b01;
            r_IN = 2'b00;
        end
        RIGHT: begin
            l_IN = 2'b00;
            r_IN = 2'b10;
        end
        FORWARD: begin
            l_IN = 2'b01;
            r_IN = 2'b10;
        end
    endcase
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