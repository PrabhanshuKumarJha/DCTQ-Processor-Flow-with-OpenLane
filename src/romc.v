/*
ROMC Design.
This code is put into a file named “romc.v”.
This is the code for a ROM that stores the cosine, 2 × C or 2 × C T matrix.
Design incorporates two pipelining stages in order to keep pace with Dual RAM
used in the DCTQ design. ROM size is 8 × 64 bits. Two locations can be accessed
and output to the data bus, ‘dout1’ and ‘dout2’ simultaneously using the two ad-
dresses, ‘addr1’ and ‘addr2’ respectively. Each location stores eight numbers of
cosine terms. Thus, in eight such locations, a total of 64 terms are stored.
*/

module romc (
    input clk,
    input [2:0] addr1,
    input [2:0] addr2,
    output reg [63:0] dout1,
    output reg [63:0] dout2
);

// First pipeline registers.
reg [63:0] dout1_next;
reg [63:0] dout2_next;
reg [63:0] dout1_reg1;
reg [63:0] dout2_reg1;

// ROM data declared as nets.
wire [63:0] loc0 = 64'h5B5B5B5B5B5B5B5B; // ROM data - eight numbers of 8 bits data per location.
wire [63:0] loc1 = 64'h7E6A4719E7B99682;
wire [63:0] loc2 = 64'h7631CF8A8ACF3176;
wire [63:0] loc3 = 64'h6AE782B9477E1996;
wire [63:0] loc4 = 64'h5BA5A55B5BA5A55B;
wire [63:0] loc5 = 64'h4782196A96E77EB9;
wire [63:0] loc6 = 64'h318A76CFCF768A31;
wire [63:0] loc7 = 64'h19B96A827E9647E7;

// Addressed data is accessed whenever there is a change in any of the inputs in the always statement.
always @(loc0 or loc1 or loc2 or loc3 or loc4 or loc5 or loc6 or loc7 or
addr1 or addr2) begin
    case (addr1)
        3'b000: dout1_next = loc0;
        3'b001: dout1_next = loc1;
        3'b010: dout1_next = loc2;
        3'b011: dout1_next = loc3;
        3'b100: dout1_next = loc4;
        3'b101: dout1_next = loc5;
        3'b110: dout1_next = loc6;
        3'b111: dout1_next = loc7;
        default: dout1_next = loc0;
    endcase

    case (addr2)
        3'b000: dout2_next = loc0;
        3'b001: dout2_next = loc1;
        3'b010: dout2_next = loc2;
        3'b011: dout2_next = loc3;
        3'b100: dout2_next = loc4;
        3'b101: dout2_next = loc5;
        3'b110: dout2_next = loc6;
        3'b111: dout2_next = loc7;
        default: dout2_next = loc0;
    endcase
end

// First pipeline stage.
always @(posedge clk) begin
    dout1_reg1 <= dout1_next;
    dout2_reg1 <= dout2_next;
end

// Second pipeline stage.
always @(posedge clk) begin
    dout1 <= dout1_reg1;
    dout2 <= dout2_reg1;
end

endmodule

