/*
 * DCTQ Controller Module
 * Author: Prabhanshu Kumar Jha
 * Description: Generates control and handshake signals for DCTQ coefficient computation.
 */

module dctq_controller (
    input clk,          // Clock input
    input reset_n,      // Active-low reset input
    input start,        // Start signal to initiate computation
    input hold,         // Hold signal to pause computation
    output reg ready,   // Ready signal indicating readiness for processing
    output reg rnw,     // Read/Write signal for memory access
    output reg dctq_valid, // Valid signal indicating valid DCTQ output
    output reg encnt2, // Counter enable signal for cnt2
    output reg [5:0] cnt1_reg, // Counter for stage 1
    output reg [2:0] cnt2_reg, // Counter for stage 2
    output reg [2:0] cnt3_reg, // Counter for stage 3
    output reg [5:0] cnt4_reg, // Counter for stage 4
    output reg [5:0] addr   // Memory address signal
);

// Internal signals and registers
reg dctq_valid_prev;
reg start_reg1;         // Internal register for start signal
reg cnt_0;        // Internal counter for initial stage
reg [5:0] cnt1_next, cnt4_next, cnt5_next; // Next stage counters
reg [2:0] cnt2_next, cnt3_next;
reg encnt1, encnt3, encnt4, encnt5; // Counter enable signals
reg encnt1_next, discnt1_next; // Next stage enable signals
wire swrnw1, swrnw2, swon_ready;
wire start_next1;


// Counter enable and next stage logic
assign cnt1_next = cnt1_reg + 1; // Increment counters in advance
assign cnt2_next = cnt2_reg + 1;
assign cnt3_next = cnt3_reg + 1;
assign cnt4_next = cnt4_reg + 1;
assign cnt5_next = addr + 1;
assign encnt1_next = ((start_reg1 == 1'b1) && (cnt1_reg == 0)) ? 1'b1 : 1'b0;
assign discnt1_next = ((start_reg1 == 1'b0) && (cnt1_reg == 6'd63)) ? 1'b1 : 1'b0;

// Counter enable generation
always @ (posedge clk or negedge reset_n) begin
    if (reset_n == 1'b0)
        encnt1 <= 1'b0;
    else if (hold == 1'b1)
        encnt1 <= encnt1;
    else if (encnt1_next == 1'b1)
        encnt1 <= 1'b1;
    else if (discnt1_next == 1'b1)
        encnt1 <= 1'b0;
    else
        encnt1 <= encnt1;
end

always @ (posedge clk or negedge reset_n) begin
    if (reset_n == 1'b0)
        encnt2 <= 1'b0;
    else if (hold == 1'b1)
        encnt2 <= encnt2;
    else if (discnt1_next == 1'b1)
        encnt2 <= 1'b0;
    else if (cnt1_reg == 6'd14)
        encnt2 <= 1'b1;
    else
        encnt2 <= encnt2;
end

always @ (posedge clk or negedge reset_n) begin
    if (reset_n == 1'b0)
        encnt3 <= 1'b0;
    else if (hold == 1'b1)
        encnt3 <= encnt3;
    else if (discnt1_next == 1'b1)
        encnt3 <= 1'b0;
    else if (cnt1_reg == 6'd20)
        encnt3 <= 1'b1;
    else
        encnt3 <= encnt3;
end

always @ (posedge clk or negedge reset_n) begin
    if (reset_n == 1'b0)
        encnt4 <= 1'b0;
    else if (hold == 1'b1)
        encnt4 <= encnt4;
    else if (discnt1_next == 1'b1)
        encnt4 <= 1'b0;
    else if (cnt1_reg == 6'd35)
        encnt4 <= 1'b1;
    else
        encnt4 <= encnt4;
end

always @ (posedge clk or negedge reset_n) begin
    if (reset_n == 1'b0)
        encnt5 <= 1'b0;
    else if (hold == 1'b1)
        encnt5 <= encnt5;
    else if (discnt1_next == 1'b1)
        encnt5 <= 1'b0;
    else if (cnt1_reg == 6'd44)
        encnt5 <= 1'b1;
    else
        encnt5 <= encnt5;
end

// Counter realization
always @ (posedge clk or negedge reset_n) begin
    if (reset_n == 1'b0)
        cnt1_reg <= 6'd00;
    else if (hold == 1'b1)
        cnt1_reg <= cnt1_reg;
    else if (encnt1 == 1'b1)
        cnt1_reg <= cnt1_next;
    else
        cnt1_reg <= cnt1_reg;
end

always @ (posedge clk or negedge reset_n) begin
    if (reset_n == 1'b0)
        cnt2_reg <= 6'd00;
    else if (hold == 1'b1)
        cnt2_reg <= cnt2_reg;
    else if (encnt2 == 1'b1)
        cnt2_reg <= cnt2_next;
    else
        cnt2_reg <= cnt2_reg;
end

always @ (posedge clk or negedge reset_n) begin
    if (reset_n == 1'b0)
        cnt3_reg <= 6'd00;
    else if (hold == 1'b1)
        cnt3_reg <= cnt3_reg;
    else if (encnt3 == 1'b1)
        cnt3_reg <= cnt3_next;
    else
        cnt3_reg <= cnt3_reg;
end

always @ (posedge clk or negedge reset_n) begin
    if (reset_n == 1'b0)
        cnt4_reg <= 6'd00;
    else if (hold == 1'b1)
        cnt4_reg <= cnt4_reg;
    else if (encnt4 == 1'b1)
        cnt4_reg <= cnt4_next;
    else
        cnt4_reg <= cnt4_reg;
end

always @ (posedge clk or negedge reset_n) begin
    if (reset_n == 1'b0)
        addr <= 6'd00;
    else if (hold == 1'b1)
        addr <= addr;
    else if (encnt5 == 1'b1)
        addr <= cnt5_next;
    else
        addr <= addr;
end

// Read/Write control logic
assign swrnw1 = ((start_reg1 == 1'b1) && (cnt1_reg == 0) && (cnt_0 == 1'b1)) ? 1'b1 : 1'b0; // Toggle after the first block of RAM is written
assign swrnw2 = ((start_reg1 == 1'b1) && (cnt1_reg == 6'd63)) ? 1'b1 : 1'b0; // Toggle after every DCTQ block is processed

always @ (posedge clk or negedge reset_n) begin
    if (reset_n == 1'b0) begin
        cnt_0 <= 1'b1;
        rnw <= 1'b1;
    end
    else if (hold == 1'b1)
        rnw <= rnw;
    else if (swrnw1) begin 
        cnt_0 <= 1'b0;
        rnw <= !rnw;
    end
    else if (swrnw2)
        rnw <= !rnw;
    else
        rnw <= rnw;
end

assign swon_ready = ((start_reg1 == 1'b1) && (cnt1_reg == 6'd01)) ? 1'b1 : 1'b0;

always @ (posedge clk or negedge reset_n) begin
    if (reset_n == 1'b0)
        ready <= 1'b1;
    else if (hold == 1'b1)
        ready <= ready;
    else if (swon_ready)
        ready <= 1'b1;
    else
        ready <= !start_reg1;
end

// DCTQ valid signal
always @ (posedge clk or negedge reset_n) begin
    if (reset_n == 1'b0) begin
        dctq_valid_prev <= 1'b0;
        dctq_valid <= 1'b0;
    end
    else if (hold == 1'b1) begin
        dctq_valid <= 1'b0;
    end
    else if (cnt1_reg == 6'd44) begin
        dctq_valid <= 1'b1;
        dctq_valid_prev <= 1'b1;
    end
    else if (hold == 1'b0) begin
        dctq_valid <= dctq_valid_prev;
    end
    else
        dctq_valid <= dctq_valid;
end

// Start signal control
assign start_next1 = (start == 1'b1) && (cnt1_reg == 0);

always @ (posedge clk or negedge reset_n) begin
    if (reset_n == 1'b0)
        start_reg1 <= 1'b0;
    else if (hold == 1'b1)
        start_reg1 <= start_reg1;
    else if (start_next1)
        start_reg1 <= 1'b1;
    else if ((!start == 1'b0) && (cnt1_reg == 6'd62))
        start_reg1 <= 1'b0;
    else
        start_reg1 <= start_reg1;
end

endmodule

