// __DESIGN_NAME__ - example design stub.
// Replace this with your own design. The toolkit ships a working parametrized
// counter so `make sim` produces a waveform the moment the project is created.

module __DESIGN_NAME__ #(
    parameter WIDTH = 8
) (
    input  wire             clk,
    input  wire             rst_n,
    input  wire             en,
    output reg  [WIDTH-1:0] count
);

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            count <= {WIDTH{1'b0}};
        else if (en)
            count <= count + 1'b1;
    end

endmodule
