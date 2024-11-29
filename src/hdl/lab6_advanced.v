module lab6_advanced (
    input rst,
    input clk,

    input  sonic_echo,
    output sonic_trig,

    input left_track,
    input right_track,
    input mid_track,

    output [4:1] motor_in,
    output [1:0] motor_pwm_lr,
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
    // reg [1:0] mode;


    reg [1:0] state;

    localparam FORWARD = 2'b11;
    localparam LEFT    = 2'd01;
    localparam RIGHT   = 2'd10;

    always @(posedge clk, posedge rst) begin
        if (rst) begin
            state <= FORWARD;
        end else begin
            state <= state;
            case (state)
                FORWARD: begin
                    if      (!left_track)  state <= LEFT;
                    else if (!right_track) state <= RIGHT;
                end
                LEFT: begin
                    if      (!mid_track)   state <= FORWARD;
                    else if (!right_track) state <= RIGHT;
                end
                RIGHT: begin
                    if      (!mid_track)   state <= FORWARD;
                    else if (!left_track)  state <= LEFT;
                end
                default: state <= FORWARD;
            endcase
        end
    end

    Motor m0 (
        .rst(rst),
        .c100MHz(clk),
        .dir(state),
        .speed(distance > 8 || distance < 4 ? 10'd840 : 10'd0),
        .pwm_lr(motor_pwm_lr),
        .l_IN({motor_in[1], motor_in[2]}),
        .r_IN({motor_in[3], motor_in[4]})
    );
endmodule