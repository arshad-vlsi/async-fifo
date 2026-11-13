
`timescale 1ns / 1ps

module sync_w2r #(parameter WIDTH = 4)(
    input rclk,
    input rrst_n,
    input [WIDTH:0] wptr,
    output reg [WIDTH:0] rq2_wptr
);

    reg [WIDTH:0] q1;

    always @(posedge rclk) begin

        if (!rrst_n) begin

            q1 <= 0;
            rq2_wptr <= 0;

        end

        else begin

            q1 <= wptr;
            rq2_wptr <= q1;

        end

    end

endmodule
