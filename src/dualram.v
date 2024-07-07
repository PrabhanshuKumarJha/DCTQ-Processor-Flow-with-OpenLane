`include "ram_rc.v" // Include the individual RAM code file.

module dualram (
    input clk,           // System clock.
    input pci_clk,       // PCI clock for inputting data, di synchronously.
    input rnw,           // Sets one RAM in write only mode and the other RAM in read only mode.
    input din_valid,     // Data in (di) valid.
    input [7:0] be,      // Byte enable.
    input [2:0] ra,      // Read address.
    input [2:0] wa,      // Write address.
    input [63:0] di,     // Data input.
    output reg [63:0] data_out // Data output of dual RAM.
);

wire switch_bank;
wire [63:0] do1, do2;
reg [63:0] do_next;
reg rnw_delay;

assign switch_bank = ~rnw;
// Instantiate the first RAM.
ram_rc ram1 (
    .clk(clk),
    .pci_clk(pci_clk),
    .rnw(rnw),
    .be(be),
    .ra(ra),
    .wa(wa),
    .di(di),
    .din_valid(din_valid),
    .data_out(do1)
);

// Instantiate the second RAM.
ram_rc ram2 (
    .clk(clk),
    .pci_clk(pci_clk),
    .rnw(switch_bank),
    .be(be),
    .ra(ra),
    .wa(wa),
    .di(di),
    .din_valid(din_valid),
    .data_out(do2)
);

// Select the RAM output based on the rnw signal.
assign do_next = (rnw_delay) ? do2 : do1;

always @(posedge clk) begin
    rnw_delay <= rnw;      // Delay the rnw signal by one clock.
    data_out <= do_next;   // Register the selected RAM output.
end

endmodule

