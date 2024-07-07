/*
Verilog Code for Signed Adder Design
// Adds eight numbers, n0 to n7, each of size 12 bits in 2’s complement.
// Has five pipeline stages registered at positive edge of clock.
// Result, sum, is in 15 bits, 2’s complement form (not registered).
*/

module adder12s (
    input clk,
    input [11:0] n0,
    input [11:0] n1,
    input [11:0] n2,
    input [11:0] n3,
    input [11:0] n4,
    input [11:0] n5,
    input [11:0] n6,
    input [11:0] n7,
    output [14:0] sum
);

// Declare nets in the design
wire [7:0] s00_lsb, s01_lsb, s02_lsb, s03_lsb;
wire [5:0] s00_msb, s01_msb, s02_msb, s03_msb;
wire [7:0] s10_lsb, s11_lsb, s20_lsb;
wire [6:0] s10_msb, s11_msb;

// Declare pipeline registers
reg [11:7] n0_reg1, n1_reg1, n2_reg1, n3_reg1, n4_reg1, n5_reg1, n6_reg1, n7_reg1;
reg [7:0] s00_lsbreg1, s01_lsbreg1, s02_lsbreg1, s03_lsbreg1;
reg [5:0] s00_msbreg2, s01_msbreg2, s02_msbreg2, s03_msbreg2;
reg [6:0] s00_lsbreg2, s01_lsbreg2, s02_lsbreg2, s03_lsbreg2;
reg [7:0] s10_lsbreg3, s11_lsbreg3;
reg [5:0] s00_msbreg3, s01_msbreg3, s02_msbreg3, s03_msbreg3;
reg [6:0] s10_msbreg4, s11_msbreg4;
reg [6:0] s10_lsbreg4, s11_lsbreg4;
reg [6:0] s10_msbreg5, s11_msbreg5;
reg s20_lsbreg5cy;
reg [6:0] s20_lsbreg5;

// First Stage Addition
assign s00_lsb[7:0] = n0[6:0] + n1[6:0];
assign s01_lsb[7:0] = n2[6:0] + n3[6:0];
assign s02_lsb[7:0] = n4[6:0] + n5[6:0];
assign s03_lsb[7:0] = n6[6:0] + n7[6:0];

always @(posedge clk) begin
    // Pipeline 1: clk (1)
    n0_reg1[11:7] <= n0[11:7];
    n1_reg1[11:7] <= n1[11:7];
    n2_reg1[11:7] <= n2[11:7];
    n3_reg1[11:7] <= n3[11:7];
    n4_reg1[11:7] <= n4[11:7];
    n5_reg1[11:7] <= n5[11:7];
    n6_reg1[11:7] <= n6[11:7];
    n7_reg1[11:7] <= n7[11:7];
    s00_lsbreg1[7:0] <= s00_lsb[7:0];
    s01_lsbreg1[7:0] <= s01_lsb[7:0];
    s02_lsbreg1[7:0] <= s02_lsb[7:0];
    s03_lsbreg1[7:0] <= s03_lsb[7:0];
end

// Sign extended & msb added with carry
assign s00_msb[5:0] = {n0_reg1[11], n0_reg1[11:7]} + {n1_reg1[11], n1_reg1[11:7]} + s00_lsbreg1[7];
assign s01_msb[5:0] = {n2_reg1[11], n2_reg1[11:7]} + {n3_reg1[11], n3_reg1[11:7]} + s01_lsbreg1[7];
assign s02_msb[5:0] = {n4_reg1[11], n4_reg1[11:7]} + {n5_reg1[11], n5_reg1[11:7]} + s02_lsbreg1[7];
assign s03_msb[5:0] = {n6_reg1[11], n6_reg1[11:7]} + {n7_reg1[11], n7_reg1[11:7]} + s03_lsbreg1[7];

always @(posedge clk) begin
    // Pipeline 2: clk (2)
    s00_msbreg2[5:0] <= s00_msb[5:0];
    s01_msbreg2[5:0] <= s01_msb[5:0];
    s02_msbreg2[5:0] <= s02_msb[5:0];
    s03_msbreg2[5:0] <= s03_msb[5:0];
    s00_lsbreg2[6:0] <= s00_lsbreg1[6:0];
    s01_lsbreg2[6:0] <= s01_lsbreg1[6:0];
    s02_lsbreg2[6:0] <= s02_lsbreg1[6:0];
    s03_lsbreg2[6:0] <= s03_lsbreg1[6:0];
end

// Second Stage Addition
assign s10_lsb[7:0] = s00_lsbreg2[6:0] + s01_lsbreg2[6:0];
assign s11_lsb[7:0] = s02_lsbreg2[6:0] + s03_lsbreg2[6:0];

always @(posedge clk) begin
    // Pipeline 3: clk (3)
    s10_lsbreg3[7:0] <= s10_lsb[7:0];
    s11_lsbreg3[7:0] <= s11_lsb[7:0];
    s00_msbreg3[5:0] <= s00_msbreg2[5:0];
    s01_msbreg3[5:0] <= s01_msbreg2[5:0];
    s02_msbreg3[5:0] <= s02_msbreg2[5:0];
    s03_msbreg3[5:0] <= s03_msbreg2[5:0];
end

assign s10_msb[6:0] = {s00_msbreg3[5], s00_msbreg3[5:0]} + {s01_msbreg3[5], s01_msbreg3[5:0]} + s10_lsbreg3[7];
assign s11_msb[6:0] = {s02_msbreg3[5], s02_msbreg3[5:0]} + {s03_msbreg3[5], s03_msbreg3[5:0]} + s11_lsbreg3[7];

always @(posedge clk) begin
    // Pipeline 4: clk (4)
    s10_lsbreg4[6:0] <= s10_lsbreg3[6:0];
    s11_lsbreg4[6:0] <= s11_lsbreg3[6:0];
    s10_msbreg4[6:0] <= s10_msb[6:0];
    s11_msbreg4[6:0] <= s11_msb[6:0];
end

// Third Stage Addition
assign s20_lsb[7:0] = s10_lsbreg4[6:0] + s11_lsbreg4[6:0];

always @(posedge clk) begin
    // Pipeline 5: clk (5)
    s10_msbreg5[6:0] <= s10_msbreg4[6:0];
    s11_msbreg5[6:0] <= s11_msbreg4[6:0];
    s20_lsbreg5cy <= s20_lsb[7];
    s20_lsbreg5[6:0] <= s20_lsb[6:0];
end

// Add third stage MSB results and concatenate with LSB result to get the final result
assign sum[14:0] = {({s10_msbreg5[6], s10_msbreg5[6:0]} + {s11_msbreg5[6], s11_msbreg5[6:0]} + s20_lsbreg5cy), s20_lsbreg5[6:0]};

endmodule

