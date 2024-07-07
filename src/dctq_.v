`include "dualram.v"
`include "adder12s.v"
`include "adder14sr.v"
`include "dctreg2x8xn.v"
`include "mult8ux8s.v"
`include "mult11sx8s.v"
`include "mult12sx8u.v"
`include "romc.v"
`include "romq.v"
`include "dctq_controller.v"

module dctq_ (
    input  pci_clk,
    input  clk,
    input  reset_n,
    input  start,
    input  din_valid,
    input  hold,
    input  [63:0] di,
    input  [2:0] wa,
    input  [7:0] be,
    output reg ready,
    output reg [8:0] dctq1,
    output reg dctq_valid,
    output reg [5:0] addr
);

// Declare internal wires and registers
wire [15:0] result1, result2, result3, result4, result5, result6, result7, result8;
wire [14:0] sum1;
wire [11:0] dct;
wire [63:0] d1, d2;
wire [10:0] qr0, qr1, qr2, qr3, qr4, qr5, qr6, qr7;
wire [18:0] res1, res2, res3, res4, res5, res6, res7, res8;
wire [5:0] cnt1_reg;
wire [2:0] cnt2_reg, cnt3_reg;
wire [5:0] cnt4_reg;
wire [7:0] qout;
wire rnw;
wire encnt2;
wire [63:0] data_out; // Declare data_out as a 64-bit wide wire

// Stage 1: Dual RAM instantiation for reading image block
dualram dualram1 (
    .clk(clk),
    .pci_clk(pci_clk),
    .rnw(rnw),
    .be(be),
    .ra(cnt1_reg[2:0]),
    .wa(wa),
    .di(di),
    .din_valid(din_valid),
    .data_out(data_out) // Ensure data_out is correctly connected
);

// Stage 1 to 2 Pipeline Registers
reg [63:0] data_out_reg;
always @(posedge clk or negedge reset_n) begin
    if (!reset_n)
        data_out_reg <= 0;
    else
        data_out_reg <= data_out;
end

// Stage 2: ROMC instantiation for accessing C and CT matrices
romc romc1 (
    .clk(clk),
    .addr1(cnt1_reg[5:3]),
    .addr2(cnt3_reg[2:0]),
    .dout1(d1),
    .dout2(d2)
);

// Stage 2 to 3 Pipeline Registers
reg [63:0] d1_reg, d2_reg;
always @(posedge clk or negedge reset_n) begin
    if (!reset_n) begin
        d1_reg <= 0;
        d2_reg <= 0;
    end else begin
        d1_reg <= d1;
        d2_reg <= d2;
    end
end

// Stage 3: Multipliers for CX computation
mult8ux8s u11 (
    .clk(clk),
    .n1(data_out_reg[63:56]), // Updated from do to data_out_reg
    .n2(d1_reg[63:56]),
    .result(result1)
);
mult8ux8s u12 (
    .clk(clk),
    .n1(data_out_reg[55:48]), // Updated from do to data_out_reg
    .n2(d1_reg[55:48]),
    .result(result2)
);
mult8ux8s u13 (
    .clk(clk),
    .n1(data_out_reg[47:40]), // Updated from do to data_out_reg
    .n2(d1_reg[47:40]),
    .result(result3)
);
mult8ux8s u14 (
    .clk(clk),
    .n1(data_out_reg[39:32]), // Updated from do to data_out_reg
    .n2(d1_reg[39:32]),
    .result(result4)
);
mult8ux8s u15 (
    .clk(clk),
    .n1(data_out_reg[31:24]), // Updated from do to data_out_reg
    .n2(d1_reg[31:24]),
    .result(result5)
);
mult8ux8s u16 (
    .clk(clk),
    .n1(data_out_reg[23:16]), // Updated from do to data_out_reg
    .n2(d1_reg[23:16]),
    .result(result6)
);
mult8ux8s u17 (
    .clk(clk),
    .n1(data_out_reg[15:8]), // Updated from do to data_out_reg
    .n2(d1_reg[15:8]),
    .result(result7)
);
mult8ux8s u18 (
    .clk(clk),
    .n1(data_out_reg[7:0]), // Updated from do to data_out_reg
    .n2(d1_reg[7:0]),
    .result(result8)
);

// Stage 3 to 4 Pipeline Registers
reg [15:0] result1_reg, result2_reg, result3_reg, result4_reg, result5_reg, result6_reg, result7_reg, result8_reg;
always @(posedge clk or negedge reset_n) begin
    if (!reset_n) begin
        result1_reg <= 0;
        result2_reg <= 0;
        result3_reg <= 0;
        result4_reg <= 0;
        result5_reg <= 0;
        result6_reg <= 0;
        result7_reg <= 0;
        result8_reg <= 0;
    end else begin
        result1_reg <= result1;
        result2_reg <= result2;
        result3_reg <= result3;
        result4_reg <= result4;
        result5_reg <= result5;
        result6_reg <= result6;
        result7_reg <= result7;
        result8_reg <= result8;
    end
end

// Stage 4: Adder for summing partial products
adder12s adder12s1 (
    .clk(clk),
    .n0(result1_reg[15:4]),
    .n1(result2_reg[15:4]),
    .n2(result3_reg[15:4]),
    .n3(result4_reg[15:4]),
    .n4(result5_reg[15:4]),
    .n5(result6_reg[15:4]),
    .n6(result7_reg[15:4]),
    .n7(result8_reg[15:4]),
    .sum(sum1)
);

// Stage 4 to 5 Pipeline Registers
reg [14:0] sum1_reg;
always @(posedge clk or negedge reset_n) begin
    if (!reset_n)
        sum1_reg <= 0;
    else
        sum1_reg <= sum1;
end

// Stage 5: Register for storing partial products
dctreg2x8xn #(11) dctreg1 (
    .clk(clk),
    .din(sum1_reg[14:4]),
    .wa(cnt2_reg[2:0]),
    .enreg(encnt2),
    .qr0(qr0),
    .qr1(qr1),
    .qr2(qr2),
    .qr3(qr3),
    .qr4(qr4),
    .qr5(qr5),
    .qr6(qr6),
    .qr7(qr7)
);

// Stage 5 to 6 Pipeline Registers
reg [10:0] qr0_reg, qr1_reg, qr2_reg, qr3_reg, qr4_reg, qr5_reg, qr6_reg, qr7_reg;
always @(posedge clk or negedge reset_n) begin
    if (!reset_n) begin
        qr0_reg <= 0;
        qr1_reg <= 0;
        qr2_reg <= 0;
        qr3_reg <= 0;
        qr4_reg <= 0;
        qr5_reg <= 0;
        qr6_reg <= 0;
        qr7_reg <= 0;
    end else begin
        qr0_reg <= qr0;
        qr1_reg <= qr1;
        qr2_reg <= qr2;
        qr3_reg <= qr3;
        qr4_reg <= qr4;
        qr5_reg <= qr5;
        qr6_reg <= qr6;
        qr7_reg <= qr7;
    end
end

// Stage 6: Multipliers for second stage multiplication
mult11sx8s u21 (
    .clk(clk),
    .n1(qr0_reg),
    .n2(d2_reg[63:56]),
    .result(res1)
);
mult11sx8s u22 (
    .clk(clk),
    .n1(qr1_reg),
    .n2(d2_reg[55:48]),
    .result(res2)
);
mult11sx8s u23 (
    .clk(clk),
    .n1(qr2_reg),
    .n2(d2_reg[47:40]),
    .result(res3)
);
mult11sx8s u24 (
    .clk(clk),
    .n1(qr3_reg),
    .n2(d2_reg[39:32]),
    .result(res4)
);
mult11sx8s u25 (
    .clk(clk),
    .n1(qr4_reg),
    .n2(d2_reg[31:24]),
    .result(res5)
);
mult11sx8s u26 (
    .clk(clk),
    .n1(qr5_reg),
    .n2(d2_reg[23:16]),
    .result(res6)
);
mult11sx8s u27 (
    .clk(clk),
    .n1(qr6_reg),
    .n2(d2_reg[15:8]),
    .result(res7)
);
mult11sx8s u28 (
    .clk(clk),
    .n1(qr7_reg),
    .n2(d2_reg[7:0]),
    .result(res8)
);

// Stage 6 to 7 Pipeline Registers
reg [18:0] res1_reg, res2_reg, res3_reg, res4_reg, res5_reg, res6_reg, res7_reg, res8_reg;
always @(posedge clk or negedge reset_n) begin
    if (!reset_n) begin
        res1_reg <= 0;
        res2_reg <= 0;
        res3_reg <= 0;
        res4_reg <= 0;
        res5_reg <= 0;
        res6_reg <= 0;
        res7_reg <= 0;
        res8_reg <= 0;
    end else begin
        res1_reg <= res1;
        res2_reg <= res2;
        res3_reg <= res3;
        res4_reg <= res4;
        res5_reg <= res5;
        res6_reg <= res6;
        res7_reg <= res7;
        res8_reg <= res8;
    end
end

// Stage 7: Adder for summing second stage products
adder14sr adder14sr1 (
    .clk(clk),
    .n0(res1_reg[18:5]),
    .n1(res2_reg[18:5]),
    .n2(res3_reg[18:5]),
    .n3(res4_reg[18:5]),
    .n4(res5_reg[18:5]),
    .n5(res6_reg[18:5]),
    .n6(res7_reg[18:5]),
    .n7(res8_reg[18:5]),
    .dct(dct)
);

// Stage 7 to 8 Pipeline Registers
reg [11:0] dct_reg;
always @(posedge clk or negedge reset_n) begin
    if (!reset_n)
        dct_reg <= 0;
    else
        dct_reg <= dct;
end

// Stage 8: ROMQ for quantization values
romq romq1 (
    .clk(clk),
    .a(cnt4_reg),
    .d(qout)
);

// Stage 8 to 9 Pipeline Registers
reg [7:0] qout_reg;
always @(posedge clk or negedge reset_n) begin
    if (!reset_n)
        qout_reg <= 0;
    else
        qout_reg <= qout;
end

// Stage 9: Multiplier for quantization stage
mult12sx8u u31 (
    .clk(clk),
    .n1(dct_reg[11:0]),
    .n2(qout_reg),
    .dctq1(dctq1)
);

// DCTQ Controller instantiation
dctq_controller dctq_control1 (
    .clk(clk),
    .reset_n(reset_n),
    .start(start),
    .hold(hold),
    .ready(ready),
    .rnw(rnw),
    .dctq_valid(dctq_valid),
    .encnt2(encnt2),
    .cnt1_reg(cnt1_reg),
    .cnt2_reg(cnt2_reg),
    .cnt3_reg(cnt3_reg),
    .cnt4_reg(cnt4_reg),
    .addr(addr)
);

endmodule

