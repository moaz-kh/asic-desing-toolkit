// __DESIGN_NAME___tb - self-checking testbench stub.
// Replace this with your own testbench. It prints PASS/FAIL lines and a
// final summary so you can see at a glance whether the design behaves.

`timescale 1ns/1ps

module __DESIGN_NAME___tb;

    localparam WIDTH = 8;

    reg              clk = 1'b0;
    reg              rst_n;
    reg              en;
    wire [WIDTH-1:0] count;

    integer errors = 0;

    __DESIGN_NAME__ #(.WIDTH(WIDTH)) dut (
        .clk   (clk),
        .rst_n (rst_n),
        .en    (en),
        .count (count)
    );

    // 100 MHz clock
    always #5 clk = ~clk;

    initial begin
        $dumpfile("sim/waves/__DESIGN_NAME__.vcd");
        $dumpvars(0, __DESIGN_NAME___tb);
    end

    task check(input [WIDTH-1:0] got, input [WIDTH-1:0] exp, input [8*64-1:0] msg);
        begin
            if (got !== exp) begin
                $display("FAIL: %0s - expected %0d, got %0d", msg, exp, got);
                errors = errors + 1;
            end else begin
                $display("PASS: %0s (= %0d)", msg, got);
            end
        end
    endtask

    // Inputs are driven one time-unit after the rising edge to keep the
    // testbench free of clock-edge races with the DUT.
    initial begin
        rst_n = 1'b0;
        en    = 1'b0;
        repeat (2) @(posedge clk); #1;
        check(count, 8'd0, "count is 0 while in reset");

        rst_n = 1'b1;
        @(posedge clk); #1;
        check(count, 8'd0, "count still 0 with en low");

        en = 1'b1;
        repeat (10) @(posedge clk); #1;
        check(count, 8'd10, "count reaches 10 after 10 enabled cycles");

        en = 1'b0;
        repeat (5) @(posedge clk); #1;
        check(count, 8'd10, "count holds while en low");

        if (errors == 0)
            $display("\n=== ALL TESTS PASSED ===");
        else
            $display("\n=== %0d TEST(S) FAILED ===", errors);

        $finish;
    end

endmodule
