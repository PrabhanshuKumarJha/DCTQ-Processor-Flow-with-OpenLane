module ram_rc (
    input clk,
    input pci_clk,
    input rnw,
    input din_valid,
    input [7:0] be,
    input [2:0] ra,
    input [2:0] wa,
    input [63:0] di,
    output reg [63:0] data_out
);

    // Declare registered outputs and memory array.
    reg [63:0] column;
    reg [63:0] mem[7:0];
    wire [63:0] mem_data; // 8×64 bits memory array.
    wire [63:0] do_next;

    wire [2:0] addr = (rnw) ? wa : ra;

assign mem_data = mem[addr];

    // Intermediate wires for memory locations.
    wire [63:0] loc0 = mem[0];
    wire [63:0] loc1 = mem[1];
    wire [63:0] loc2 = mem[2];
    wire [63:0] loc3 = mem[3];
    wire [63:0] loc4 = mem[4];
    wire [63:0] loc5 = mem[5];
    wire [63:0] loc6 = mem[6];
    wire [63:0] loc7 = mem[7];

    // Address signal for selecting the correct memory location.

    // Read the RAM column-wise.
    always @(addr or loc0 or loc1 or loc2 or loc3 or loc4 or loc5 or loc6 or loc7) begin
        case (addr)
            3'b000: column = {loc0[63:56], loc1[63:56], loc2[63:56], loc3[63:56], loc4[63:56], loc5[63:56], loc6[63:56], loc7[63:56]};
            3'b001: column = {loc0[55:48], loc1[55:48], loc2[55:48], loc3[55:48], loc4[55:48], loc5[55:48], loc6[55:48], loc7[55:48]};
            3'b010: column = {loc0[47:40], loc1[47:40], loc2[47:40], loc3[47:40], loc4[47:40], loc5[47:40], loc6[47:40], loc7[47:40]};
            3'b011: column = {loc0[39:32], loc1[39:32], loc2[39:32], loc3[39:32], loc4[39:32], loc5[39:32], loc6[39:32], loc7[39:32]};
            3'b100: column = {loc0[31:24], loc1[31:24], loc2[31:24], loc3[31:24], loc4[31:24], loc5[31:24], loc6[31:24], loc7[31:24]};
            3'b101: column = {loc0[23:16], loc1[23:16], loc2[23:16], loc3[23:16], loc4[23:16], loc5[23:16], loc6[23:16], loc7[23:16]};
            3'b110: column = {loc0[15:8], loc1[15:8], loc2[15:8], loc3[15:8], loc4[15:8], loc5[15:8], loc6[15:8], loc7[15:8]};
            3'b111: column = {loc0[7:0], loc1[7:0], loc2[7:0], loc3[7:0], loc4[7:0], loc5[7:0], loc6[7:0], loc7[7:0]};
            default: column = {loc0[7:0], loc1[7:0], loc2[7:0], loc3[7:0], loc4[7:0], loc5[7:0], loc6[7:0], loc7[7:0]};
        endcase
    end

    // Enable write signals.
    wire be7 = (!be[7]) & rnw & din_valid;
    wire be6 = (!be[6]) & rnw & din_valid;
    wire be5 = (!be[5]) & rnw & din_valid;
    wire be4 = (!be[4]) & rnw & din_valid;
    wire be3 = (!be[3]) & rnw & din_valid;
    wire be2 = (!be[2]) & rnw & din_valid;
    wire be1 = (!be[1]) & rnw & din_valid;
    wire be0 = (!be[0]) & rnw & din_valid;

    // Write into RAM only if be signals are asserted.
    always @(posedge pci_clk) begin
        
            mem[addr] <= {
                (be7 ? di[63:56] : mem[addr][63:56]),
                (be6 ? di[55:48] : mem[addr][55:48]),
                (be5 ? di[47:40] : mem[addr][47:40]),
                (be4 ? di[39:32] : mem[addr][39:32]),
                (be3 ? di[31:24] : mem[addr][31:24]),
                (be2 ? di[23:16] : mem[addr][23:16]),
                (be1 ? di[15:8] : mem[addr][15:8]),
                (be0 ? di[7:0] : mem[addr][7:0])
            };
        
    end
    assign do_next = (rnw)? data_out :column;

    // Read column-wise from RAM only if rnw = 0.
    always @(posedge clk) begin
        
            data_out <= do_next; // Register the output.
        
    end

endmodule

