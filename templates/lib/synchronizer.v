// 2-flop (configurable) CDC synchronizer.
// Use this when bringing an asynchronous signal into the `clk` domain.
// Only safe for single-bit / Gray-coded signals - do NOT use on a multi-bit
// bus where bits can change together.

module synchronizer #(
    parameter WIDTH  = 1,
    parameter STAGES = 2
) (
    input  wire             clk,
    input  wire             rst_n,
    input  wire [WIDTH-1:0] async_in,
    output wire [WIDTH-1:0] sync_out
);

    reg [WIDTH-1:0] sync_ff [0:STAGES-1];
    integer i;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            for (i = 0; i < STAGES; i = i + 1)
                sync_ff[i] <= {WIDTH{1'b0}};
        end else begin
            sync_ff[0] <= async_in;
            for (i = 1; i < STAGES; i = i + 1)
                sync_ff[i] <= sync_ff[i-1];
        end
    end

    assign sync_out = sync_ff[STAGES-1];

endmodule
