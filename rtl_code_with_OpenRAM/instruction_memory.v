`timescale 1ns/1ps
module instruction_memory (
    input wire clk, 
    input wire rst,
    input wire [31:0] addr,
    output wire [31:0] read_data
);
    // Shift the clock by 1ns to avoid race conditions with pipeline registers.
    // This ensures inputs are stable before capturing and outputs are ready before the next posedge.
    wire clk_ram;
    assign #1 clk_ram = clk;

    // Convert Byte address (32-bit) to Word address (8-bit for 256-word RAM)
    wire [7:0] word_addr = addr[9:2];

    ram256x32 imem_macro (
        .clk0(clk_ram), .csb0(1'b1), .addr0(8'd0), .din0(32'd0),
        .clk1(clk_ram), .csb1(1'b0), .addr1(word_addr), .dout1(read_data)
    );
endmodule