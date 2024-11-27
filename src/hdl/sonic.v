module Sonic (
    input            rst,
    input            c1MHz,
    input            echo,
    output           trig,
    output reg [5:0] distance // unit: cm
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
    reg [11:0] pos_cnt;

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

    always @* begin
        if (rst)
            distance <= 0;
        else if (pos_state == POS_S2)
            distance <= pos_cnt * 16'd17 / 1000;
        else
            distance <= distance;
    end
endmodule : Sonic