/*
 * 12-bit Signed by 8-bit Unsigned Multiplier
 * Author: Prabhanshu Kumar Jha
 * Description: Multiplies a 12-bit signed integer by an 8-bit unsigned integer.
 */

module mult12sx8u (
    input clk,
    input signed [11:0] n1,  // 12-bit signed input
    input [7:0] n2,          // 8-bit unsigned input
    output reg [8:0] dctq1   // 9-bit signed output
);

// Internal signals
reg signed [20:0] product;

// Multiplier logic
always @(posedge clk) begin
    product <= n1 * n2;
    dctq1 <= product[20:12]; // Assign the quantized product to the output
end

endmodule

