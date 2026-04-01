`timescale 1ns/1ps
module data_memory (
    input wire clk, rst, write_en,
    input wire [31:0] addr, write_data,
    output wire [31:0] read_data 
);
    // Shift the clock by 1ns to avoid race conditions with pipeline registers.
    wire clk_ram;
    assign #1 clk_ram = clk;

    // Convert Byte address (32-bit) to Word address (8-bit for 256-word RAM)
    wire [7:0] word_addr = addr[9:2];

    ram256x32 dmem_macro (
        .clk0(clk_ram), .csb0(~write_en), .addr0(word_addr), .din0(write_data),
        .clk1(clk_ram), .csb1(1'b0),      .addr1(word_addr), .dout1(read_data)
    );
endmodule