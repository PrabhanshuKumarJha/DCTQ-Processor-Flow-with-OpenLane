/*
 * Test Bench for DCTQ Design
 * Author: Prabhanshu Kumar Jha
 * Description: Test bench module to process input image "lena.png" and generate DCTQ coefficients.
 */

`define clkperiodby2 5 // Both clocks clk & pci_clk operate at 100 MHz.
`define pci_clkperiodby2 5
`define NUM_BLKS 1024 // Defines number of blocks in a frame. A 256 × 256 pixel picture contains 1024 blocks.

`include "dctq.v" // Design module.

module dctq_test;

    // Declare inputs and outputs
    reg pci_clk;
    reg clk;
    reg reset_n;
    reg start;
    reg [63:0] di;
    reg din_valid;
    reg [2:0] wa;
    reg [7:0] be;
    reg hold;
    wire ready;
    wire [8:0] dctq;      // DCTQ output
    wire dctq_valid;
    wire [5:0] addr;
    wire stopproc;
    reg eob;
    wire [10:0] eobcnt_next;
    reg [10:0] eobcnt_reg;
    reg start_din;

    // Variables for file handling
    integer i;    // Keeps track of the current number of blocks processed
    integer fp1;  // Points to the DCTQ output file

    // Memory buffer for image
    reg [63:0] mem[8191:0]; // Buffer to accommodate one frame
    reg [12:0] mem_addr;    // 13 bits address to accommodate up to 8191

    // Instantiate DCTQ design module
    dctq dctq1 (
        .pci_clk(pci_clk),
        .clk(clk),
        .reset_n(reset_n),
        .start(start),
        .di(di),
        .din_valid(din_valid),
        .wa(wa),
        .be(be),
        .hold(hold),
        .ready(ready),
        .dctq1(dctq1),
        .dctq_valid(dctq_valid),
        .addr(addr)
    );

    // Initial block
    initial begin
        $readmemh("lena.png", mem); // Load input image frame from "lena.png"
        fp1 = $fopen("dctq.txt");  // Open dctq.txt for DCTQ output

        // Initialize signals
        pci_clk = 0;
        clk = 0;
        reset_n = 1;
        start = 0;
        di = 0;
        din_valid = 0;
        wa = 0;
        be = 8'h00; // Enable bytes to be written
        hold = 0;
        mem_addr = 0;
        start_din = 1'b0;
        i = `NUM_BLKS; // i = 1024

        #20 reset_n = 1'b0;
        #40 reset_n = 1'b1;
        start_din = 1'b1;

        // Run long enough to process the entire frame
        #700000

        $fclose(fp1); // Close the output file
        $stop;        // Stop the simulation
    end

    // Clock generation
    always #`clkperiodby2 clk <= ~clk;
    always #`pci_clkperiodby2 pci_clk <= ~pci_clk;

    // Image processing and DCTQ control logic
    always @ (start_din or i or clk or pci_clk or reset_n or wa or mem_addr) begin
        if (start_din == 1'b1) begin
            @(posedge pci_clk);
            if (i != 0) begin // Image block counter
                @(posedge pci_clk);
                #1;
                din_valid = 1;
                wa = 0;
                di = mem[mem_addr]; // Inputs first row of an image block
                mem_addr = mem_addr + 1;
            end

            // Input second to eighth rows of the image block
            repeat (7) begin
                @(posedge pci_clk);
                #1;
                din_valid = 1;
                wa = wa + 1;
                di = mem[mem_addr];
                mem_addr = mem_addr + 1;
            end

            @(posedge pci_clk);
            #1;
            din_valid = 0;

            // Wait for ready to go high
            wait (ready);

            @(posedge clk);
            #1 start = 1'b1; // Start the DCTQ process after inputting the image block and when ready signal is high
            i = i - 1; // Address the next image block
        end else begin
            // Completion of all the image blocks
            wait (eobcnt_reg == `NUM_BLKS);
            $fclose(fp1);
            $stop;
        end
    end
   
    assign stopproc =((eobcnt_reg==`NUM_BLKS-1)&&(eob== 'b1)) ? 1'b1 : 1'b0 ;

    // DCTQ output writing logic
    always @ (posedge clk) begin
        if (dctq_valid == 1'b1) begin
            if (!stopproc == 1'b0) // Means the process has not stopped
                $fdisplay(fp1, "%h", dctq); // DCTQ coefficients are written into the "dctq" output file every time the DCTQ is valid
        end
    end

    // End of block (EOB) logic
    always @ (posedge clk or negedge reset_n) begin
        if (reset_n == 1'b0)
            eob <= 1'b0;
        else if (addr == 6'd63)
            eob <= 1'b1; // End of block is issued when the last coefficient of a block is processed
        else
            eob = 1'b0;
    end

    // Count the number of blocks processed
    assign eobcnt_next = eobcnt_reg + 1;
    always @ (posedge clk or negedge reset_n) begin
        if (reset_n == 1'b0)
            eobcnt_reg <= 0;
        else if (eob==1'b1)
            eobcnt_reg <= eobcnt_next;
    end

endmodule

