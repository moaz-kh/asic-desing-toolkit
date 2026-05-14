// Reset synchronizer: asynchronous assert, synchronous de-assert.
// Drive `async_rst_n` from your raw reset source; use `sync_rst_n` as the
// reset for all flops in the `clk` domain. This removes the recovery/removal
// timing problem of releasing an async reset.

module reset_sync #(
    parameter STAGES = 2
) (
    input  wire clk,
    input  wire async_rst_n,
    output wire sync_rst_n
);

    reg [STAGES-1:0] sync_ff;

    always @(posedge clk or negedge async_rst_n) begin
        if (!async_rst_n)
            sync_ff <= {STAGES{1'b0}};
        else
            sync_ff <= {sync_ff[STAGES-2:0], 1'b1};
    end

    assign sync_rst_n = sync_ff[STAGES-1];

endmodule
