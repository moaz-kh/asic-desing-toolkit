// Edge detector: produces a one-cycle pulse on rising/falling edges of
// `signal_in`. `signal_in` must already be synchronous to `clk` - run it
// through synchronizer.v first if it comes from another clock domain.

module edge_detector (
    input  wire clk,
    input  wire rst_n,
    input  wire signal_in,
    output wire rising_edge,
    output wire falling_edge,
    output wire any_edge
);

    reg signal_d;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            signal_d <= 1'b0;
        else
            signal_d <= signal_in;
    end

    assign rising_edge  =  signal_in & ~signal_d;
    assign falling_edge = ~signal_in &  signal_d;
    assign any_edge     =  signal_in ^  signal_d;

endmodule
