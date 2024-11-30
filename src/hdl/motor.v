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