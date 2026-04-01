`define USE_SIM_MODEL 1
// OpenRAM SRAM model
// Words: 256
// Word size: 32
`timescale 1ns / 1ps

module ram256x32(
`ifdef USE_POWER_PINS
    vccd1,
    vssd1,
`endif
// Port 0: W
    clk0,csb0,addr0,din0,
// Port 1: R
    clk1,csb1,addr1,dout1
  );

  parameter DATA_WIDTH = 32 ;
  parameter ADDR_WIDTH = 8 ;
  parameter RAM_DEPTH = 1 << ADDR_WIDTH;
  parameter DELAY = 3 ;
  parameter VERBOSE = 1 ;
  parameter T_HOLD = 1 ;

`ifdef USE_POWER_PINS
    inout vccd1;
    inout vssd1;
`endif
  input  clk0; // clock
  input   csb0; // active low chip select
  input [ADDR_WIDTH-1:0]  addr0;
  input [DATA_WIDTH-1:0]  din0;
  input  clk1; // clock
  input   csb1; // active low chip select
  input [ADDR_WIDTH-1:0]  addr1;
  output [DATA_WIDTH-1:0] dout1;

`ifdef USE_SIM_MODEL
  reg [DATA_WIDTH-1:0]    mem [0:RAM_DEPTH-1];

  reg  csb0_reg;
  reg [ADDR_WIDTH-1:0]  addr0_reg;
  reg [DATA_WIDTH-1:0]  din0_reg;

  integer i;
  initial begin
      for (i = 0; i < RAM_DEPTH; i = i + 1) begin
          mem[i] = 32'h0; // Khởi tạo tất cả bằng 0
      end
  end
  
  // All inputs are registers
  always @(posedge clk0)
  begin
    csb0_reg = csb0;
    addr0_reg = addr0;
    din0_reg = din0;
    if ( !csb0_reg && VERBOSE )
      $display($time," Writing %m addr0=%b din0=%b",addr0_reg,din0_reg);
  end

  reg  csb1_reg;
  reg [ADDR_WIDTH-1:0]  addr1_reg;
  reg [DATA_WIDTH-1:0]  dout1;

  // All inputs are registers
  always @(posedge clk1)
  begin
    csb1_reg = csb1;
    addr1_reg = addr1;
    if (!csb0 && !csb1 && (addr0 == addr1))
         $display($time," WARNING: Writing and reading addr0=%b and addr1=%b simultaneously!",addr0,addr1);
    
    
    if ( !csb1_reg && VERBOSE ) 
      $display($time," Reading %m addr1=%b dout1=%b",addr1_reg,mem[addr1_reg]);
  end

  // Memory Write Block Port 0
  always @ (negedge clk0)
  begin : MEM_WRITE0
    if (!csb0_reg) begin
        mem[addr0_reg][31:0] = din0_reg[31:0];
    end
  end

  // Memory Read Block Port 1
  always @ (negedge clk1)
  begin : MEM_READ1
    if (!csb1_reg)
       dout1 <= #(DELAY) mem[addr1_reg];
  end
`endif
endmodule