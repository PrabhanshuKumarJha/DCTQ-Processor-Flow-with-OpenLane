/*
 * 8x8 Signed Multiplier
 * Author: Prabhanshu Kumar Jha
 * Description: Multiplies two 8-bit signed inputs and produces a 16-bit signed output.
 */

module mult8ux8s (
    input clk,
    input signed [7:0] n1, n2,
    output reg signed [15:0] result // 16-bit signed output
);

// Internal signals
reg signed [15:0] product;

// Multiplier logic
always @(posedge clk) begin
    product <= n1 * n2;
end

// Output assignment
assign result = product;

endmodule

