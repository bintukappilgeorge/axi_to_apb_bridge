`timescale 1ns / 1ps

module axi_to_apb_bridge (
    input  wire         axi_clk,      // 100MHz AXI Clock
    input  wire         axi_resetn,   // Active-low reset
    input  wire [31:0]  axi_awaddr,   // 32-bit AXI write address
    input  wire [63:0]  axi_wdata,    // 64-bit AXI write data
    input  wire         axi_wvalid,   // AXI write valid
    output wire         axi_wready,   // AXI write ready
    
    input  wire         apb_clk,      // 50MHz APB Clock
    input  wire         apb_resetn,   // Active-low reset
    output reg  [31:0]  apb_paddr,    // 32-bit APB address (from 32-bit AXI address)
    output reg  [31:0]  apb_wdata,    // 32-bit APB write data
    output reg          apb_wvalid,   // APB write valid
    input  wire         apb_ready     // APB ready signal
);

// FIFO Parameters
parameter FIFO_DEPTH = 64; // FIFO depth
parameter ADDR_WIDTH = 6;  // log2(FIFO_DEPTH) = 6

// FIFO Storage for Data and Address
reg [31:0] fifo_data [FIFO_DEPTH-1:0]; // 32-bit data storage
reg [31:0] fifo_addr [FIFO_DEPTH-1:0]; // 32-bit address storage

reg [ADDR_WIDTH-1:0] w_ptr = 0;   // Write pointer
reg [ADDR_WIDTH-1:0] r_ptr = 0;   // Read pointer
reg [ADDR_WIDTH-1:0] w_ptr_sync = 0, r_ptr_sync = 0;
reg full  = 0;
reg empty = 1;

// Synchronize Write Pointer to APB Clock Domain
always @(posedge apb_clk or negedge apb_resetn) begin
    if (!apb_resetn) begin
        w_ptr_sync <= 0;
    end else begin
        w_ptr_sync <= w_ptr;
    end
end

// Synchronize Read Pointer to AXI Clock Domain
always @(posedge axi_clk or negedge axi_resetn) begin
    if (!axi_resetn) begin
        r_ptr_sync <= 0;
    end else begin
        r_ptr_sync <= r_ptr;
    end
end

// AXI Write to FIFO (split 64-bit data into two 32-bit parts)
always @(posedge axi_clk or negedge axi_resetn) begin
    if (!axi_resetn) begin
        w_ptr <= 0;
        full  <= 0;
    end else if (axi_wvalid && !full) begin
        // Store 32-bit address in FIFO (keeping the 32-bit AXI address)
        fifo_addr[w_ptr] = axi_awaddr;

        // Write lower 32 bits of 64-bit data to FIFO
        fifo_data[w_ptr] = axi_wdata[31:0];  
        w_ptr = w_ptr + 1;

        // Check full condition before writing upper 32 bits
        if (w_ptr == r_ptr_sync) begin
            full <= 1;
        end else begin
            // Write upper 32 bits to FIFO
            fifo_data[w_ptr] = axi_wdata[63:32];  
            w_ptr = w_ptr + 1;

            // Now check full condition again after both writes
            if (w_ptr == r_ptr_sync) full <= 1;
        end

        empty <= 0;
    end
end

assign axi_wready = !full;

// APB Read from FIFO (one 32-bit word at a time)
always @(posedge apb_clk or negedge apb_resetn) begin
    if (!apb_resetn) begin
        r_ptr <= 0;
        empty <= 1;
        apb_wvalid <= 0;
    end else if (!empty && apb_ready) begin
        // Read 32-bit address from FIFO for APB
        apb_paddr = fifo_addr[r_ptr];  // 32-bit AXI address passed to APB
        apb_wdata = fifo_data[r_ptr];  
        r_ptr = r_ptr + 1;

        apb_wvalid <= 1;

        // Update empty flag when FIFO is empty
        if (r_ptr == w_ptr_sync) empty <= 1;
        full <= 0;
    end else begin
        apb_wvalid <= 0;
    end
end

endmodule