`timescale 1ns/1ps
module register_file (
    input wire clk, rst, write_en_3,
    input wire [4:0] addr_1, addr_2, addr_3,
    input wire [31:0] write_data_3,
    output wire [31:0] read_data_1, read_data_2
);
    // Shift the clock by 1ns to avoid race conditions with pipeline registers.
    wire clk_ram;
    assign #1 clk_ram = clk;

    wire [31:0] rf_out_1, rf_out_2;
    
    // Chip select signal for writing: Only write when write_en = 1 AND address is not 0 (x0 is hardwired to 0)
    wire csb0_signal = ~(write_en_3 && (addr_3 != 5'd0));

    // Macro 1: Dedicated for reading rs1
    ram32x32 rf_macro_1 (
        .clk0(clk_ram), .csb0(csb0_signal), .addr0(addr_3), .din0(write_data_3),
        .clk1(clk_ram), .csb1(1'b0),        .addr1(addr_1), .dout1(rf_out_1)
    );

    // Macro 2: Dedicated for reading rs2
    ram32x32 rf_macro_2 (
        .clk0(clk_ram), .csb0(csb0_signal), .addr0(addr_3), .din0(write_data_3),
        .clk1(clk_ram), .csb1(1'b0),        .addr1(addr_2), .dout1(rf_out_2)
    );

    // Hardwired Zero and Internal Bypassing
    // Return 0 if reading x0. If reading the exact register being written, forward the new value immediately.
    assign read_data_1 = (addr_1 == 5'd0) ? 32'd0 : 
                         ((write_en_3 && (addr_1 == addr_3)) ? write_data_3 : rf_out_1);

    assign read_data_2 = (addr_2 == 5'd0) ? 32'd0 : 
                         ((write_en_3 && (addr_2 == addr_3)) ? write_data_3 : rf_out_2);

endmodule