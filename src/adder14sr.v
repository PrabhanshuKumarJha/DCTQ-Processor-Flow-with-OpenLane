/*
 * 14-bit Signed Adder with Register
 * Author: Prabhanshu Kumar Jha
 * Description: Adds eight 18-bit signed inputs and registers the output.
 */

module adder14sr (
    input clk,
    input [13:0] n0, n1, n2, n3, n4, n5, n6, n7,
    output reg [11:0] dct // Output is registered
);

// Internal wires and signals
wire [13:0] sum;

// Adder logic
assign sum = n0 + n1 + n2 + n3 + n4 + n5 + n6 + n7;

// Register for output
always @(posedge clk) begin
    dct <= sum;
end

endmodule

