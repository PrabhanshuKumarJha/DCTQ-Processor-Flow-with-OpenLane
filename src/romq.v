/*
ROMQ Design.
This code can be put in a file named ‘romq.v’.
This ROM stores the inverse of quantization values (8 bits, unsigned).
Although organized as 8 × 64 bits, it is byte-addressed (64 × 8 bits) while
reading.
*/

module romq (
    input clk,
    input [5:0] a,
    output reg [7:0] d
);

// Declare internal registers and wires.
reg [7:0] d_next;
reg [63:0] mem [7:0]; // ROM organized as 8x64 bits
reg [7:0] byte_data [7:0]; // Read byte-by-byte.

wire [63:0] mem_data; // Intermediate wire for memory data

// ROM content initialized with inverse quantization values
wire [63:0] loc0 = 64'hFF806C5D4F4C473C;
wire [63:0] loc1 = 64'h80805D554C473C37;
wire [63:0] loc2 = 64'h6C5D4F4C473C3C36;
wire [63:0] loc3 = 64'h5D5D4F4C473C3733;
wire [63:0] loc4 = 64'h5D4F4C47403B332B;
wire [63:0] loc5 = 64'h4F4C47403B332B23;
wire [63:0] loc6 = 64'h4F4C473C362D251E;
wire [63:0] loc7 = 64'h4C473B362D251E19;

// Load ROM content into memory
always @(loc0 or loc1 or loc2 or loc3 or loc4 or loc5 or loc6 or loc7) begin
    mem[0] = loc0;
    mem[1] = loc1;
    mem[2] = loc2;
    mem[3] = loc3;
    mem[4] = loc4;
    mem[5] = loc5;
    mem[6] = loc6;
    mem[7] = loc7;
end

// Split 64-bit memory data into bytes
always @(mem_data) begin
    byte_data[0] = mem_data[63:56]; // MSB is assigned as LSB
    byte_data[1] = mem_data[55:48];
    byte_data[2] = mem_data[47:40];
    byte_data[3] = mem_data[39:32];
    byte_data[4] = mem_data[31:24];
    byte_data[5] = mem_data[23:16];
    byte_data[6] = mem_data[15:8];
    byte_data[7] = mem_data[7:0]; // LSB is assigned as MSB
end

assign mem_data = mem[a[5:3]]; // Get 64 bits data
assign d_next = byte_data[a[2:0]]; // Get byte data

// Register byte data on clock edge
always @(posedge clk) begin
    d <= d_next;
end

endmodule

