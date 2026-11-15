
`timescale 1ns / 1ps

module sync_r2w #(parameter WIDTH = 4)(
    input wclk,
    input wrst_n,
    input [WIDTH:0] rptr,
    output reg [WIDTH:0] wq2_rptr
);

    reg [WIDTH:0] q1;

    always @(posedge wclk) begin

        if (!wrst_n) begin

            q1 <= 0;
            wq2_rptr <= 0;

        end

        else begin

            q1 <= rptr;
            wq2_rptr <= q1;

        end

    end

endmodule
