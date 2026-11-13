
`timescale 1ns / 1ps

module FIFO #(parameter DSIZE = 8,
              parameter ASIZE = 4)(
    output [DSIZE-1:0] rdata,
    output wfull,
    output rempty,

    input [DSIZE-1:0] wdata,

    input winc, wclk, wrst_n,
    input rinc, rclk, rrst_n
);

    wire [ASIZE-1:0] waddr, raddr;
    wire [ASIZE:0] wptr, rptr, wq2_rptr, rq2_wptr;

    // Read pointer synchronization to write clock domain
    sync_r2w #(ASIZE) rd_sync (
        .wq2_rptr(wq2_rptr),
        .rptr(rptr),
        .wclk(wclk),
        .wrst_n(wrst_n)
    );

    // Write pointer synchronization to read clock domain
    sync_w2r #(ASIZE) wr_sync (
        .rq2_wptr(rq2_wptr),
        .wptr(wptr),
        .rclk(rclk),
        .rrst_n(rrst_n)
    );

    // FIFO memory
    FIFO_memory #(DSIZE, ASIZE) fifomem (
        .rdata(rdata),
        .wdata(wdata),
        .waddr(waddr),
        .raddr(raddr),
        .wclk_en(winc),
        .wfull(wfull),
        .wclk(wclk)
    );

    // Read pointer and empty flag
    rptr_empty #(ASIZE) rptr_empty (
        .rempty(rempty),
        .raddr(raddr),
        .rptr(rptr),
        .rq2_wptr(rq2_wptr),
        .rinc(rinc),
        .rclk(rclk),
        .rrst_n(rrst_n)
    );

    // Write pointer and full flag
    wptr_full #(ASIZE) wptr_full (
        .wfull(wfull),
        .waddr(waddr),
        .wptr(wptr),
        .wq2_rptr(wq2_rptr),
        .winc(winc),
        .wclk(wclk),
        .wrst_n(wrst_n)
    );

endmodule
