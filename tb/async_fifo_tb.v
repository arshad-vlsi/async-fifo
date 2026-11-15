
`timescale 1ns/1ps

module FIFO_tb;

    parameter DSIZE = 8;
    parameter ASIZE = 4;
    parameter DEPTH = 1 << ASIZE;

    reg wclk, rclk;
    reg wrst_n, rrst_n;
    reg winc, rinc;
    reg [DSIZE-1:0] wdata;

    wire [DSIZE-1:0] rdata;
    wire wfull, rempty;

    reg [DSIZE-1:0] expected_mem [0:DEPTH-1];

    integer i;
    integer write_ptr, read_ptr;

    // DUT
    FIFO DUT (
        .wdata(wdata),
        .winc(winc),
        .wclk(wclk),
        .wrst_n(wrst_n),
        .rdata(rdata),
        .wfull(wfull),
        .rinc(rinc),
        .rclk(rclk),
        .rrst_n(rrst_n),
        .rempty(rempty)
    );

    // Write clock: 100 MHz
    initial begin
        wclk = 0;
        forever #5 wclk = ~wclk;
    end

    // Read clock: 50 MHz
    initial begin
        rclk = 0;
        forever #10 rclk = ~rclk;
    end

    // Write task
    task write_data;
        input [DSIZE-1:0] data;
        begin
            @(negedge wclk);
            if (!wfull) begin
                wdata = data;
                winc = 1;
                @(posedge wclk);
                expected_mem[write_ptr] = data;
                write_ptr = (write_ptr + 1) % DEPTH;
                @(negedge wclk);
                winc = 0;
            end
            else
                $display("FIFO FULL: Write rejected");
        end
    endtask

    // Read and check task
    task read_data;
        reg [DSIZE-1:0] expected;
        begin
            @(negedge rclk);
            if (!rempty) begin
                expected = expected_mem[read_ptr];
                rinc = 1;
                @(posedge rclk);
                if (rdata !== expected)
                    $display("ERROR: Expected=%h, Got=%h",
                             expected, rdata);
                else
                    $display("PASS: Data=%h", rdata);

                read_ptr = (read_ptr + 1) % DEPTH;
                @(negedge rclk);
                rinc = 0;
            end
            else
                $display("FIFO EMPTY: Read rejected");
        end
    endtask

    // Test sequence
    initial begin
        wclk = 0;
        rclk = 0;
        wrst_n = 0;
        rrst_n = 0;
        winc = 0;
        rinc = 0;
        wdata = 0;
        write_ptr = 0;
        read_ptr = 0;

        // Reset
        #30;
        wrst_n = 1;
        rrst_n = 1;

        repeat (3) @(posedge wclk);
        repeat (3) @(posedge rclk);

        // Write data
        $display("\n--- WRITE OPERATION ---");
        for (i = 0; i < 8; i = i + 1)
            write_data(i + 8'h10);

        // Allow pointer synchronization
        repeat (3) @(posedge rclk);

        // Read data
        $display("\n--- READ OPERATION ---");
        for (i = 0; i < 8; i = i + 1)
            read_data();

        // Allow FIFO status to update
        repeat (3) @(posedge rclk);

        $display("\n--- TEST COMPLETED ---");
        $finish;
    end

endmodule
