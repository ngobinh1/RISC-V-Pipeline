module riscv_pipeline_top (
    input wire clk,
    input wire rst
);

    // Fetch stage signals
    wire [31:0] pc_f, pc_plus_4_f, instr_f, pc_target_e;
    wire pc_src_e, stall_f;

    // Decode stage signals
    wire [31:0] instr_d, pc_d, pc_plus_4_d;
    wire [31:0] read_data_1_d, read_data_2_d, imm_ext_d;
    wire [4:0] rs1_d, rs2_d, rd_d;
    wire reg_write_d, mem_write_d, jump_d, branch_d, alu_src_d, jalr_d;
    wire [2:0] funct3_d;
    wire [1:0] result_src_d;
    wire [3:0] alu_control_d;
    wire stall_d, flush_d;

    // Execute stage signals
    wire [31:0] read_data_1_e, read_data_2_e, imm_ext_e, pc_e, pc_plus_4_e;
    wire [31:0] alu_result_e, write_data_e;
    wire [4:0] rs1_e, rs2_e, rd_e;
    wire reg_write_e, mem_write_e, jump_e, branch_e, alu_src_e, jalr_e;
    wire [2:0] funct3_e;
    wire [1:0] result_src_e, forward_a_e, forward_b_e;
    wire [3:0] alu_control_e;
    wire flush_e;

    // Memory stage signals
    wire [31:0] alu_result_m, write_data_m, pc_plus_4_m, read_data_m;
    wire [4:0] rd_m;
    wire reg_write_m, mem_write_m;
    wire [1:0] result_src_m;

    // Writeback stage signals
    wire [31:0] alu_result_w, read_data_w, pc_plus_4_w, result_w;
    wire [4:0] rd_w;
    wire reg_write_w;
    wire [1:0] result_src_w;

    // Enable signal for fetch stage (inverse of stall)
    wire en_f;
    assign en_f = ~stall_f;

    // Fetch Cycle
    fetch_cycle fetch_stage (
        .clk(clk),
        .rst(rst),
        .en(en_f),
        .pc_src_e(pc_src_e),
        .pc_target_e(pc_target_e),
        .instr_f(instr_f),
        .pc_f(pc_f),
        .pc_plus_4_f(pc_plus_4_f)
    );

    // Enable signal for decode pipeline (inverse of stall)
    wire en_d;
    assign en_d = ~stall_d;

    // Pipeline Register: Fetch -> Decode
    pipeline_1_2 pipeline_fd (
        .clk(clk),
        .rst(rst),
        .clr(flush_d),
        .en(en_d),
        .instr_f(instr_f),
        .pc_f(pc_f),
        .pc_plus_4_f(pc_plus_4_f),
        .instr_d(instr_d),
        .pc_d(pc_d),
        .pc_plus_4_d(pc_plus_4_d)
    );

    // Decode Cycle
    decode_cycle decode_stage (
        .clk(clk),
        .rst(rst),
        .reg_write_w(reg_write_w),
        .rd_w(rd_w),
        .instr_d(instr_d),
        .result_w(result_w),
        .pc_in(pc_d),
        .pc_plus_4_in(pc_plus_4_d),
        .imm_ext_d(imm_ext_d),
        .read_data_1_d(read_data_1_d),
        .read_data_2_d(read_data_2_d),
        .rs1_d(rs1_d),
        .rs2_d(rs2_d),
        .rd_d(rd_d),
        .reg_write_d(reg_write_d),
        .mem_write_d(mem_write_d),
        .jump_d(jump_d),
        .branch_d(branch_d),
        .jalr_d(jalr_d),
        .funct3_d(funct3_d),
        .alu_src_d(alu_src_d),
        .result_src_d(result_src_d),
        .alu_control_d(alu_control_d)
    );

    // Pipeline Register: Decode -> Execute
    pipeline_2_3 pipeline_de (
        .clk(clk),
        .rst(rst),
        .clr(flush_e),
        .reg_write_d(reg_write_d),
        .mem_write_d(mem_write_d),
        .alu_src_d(alu_src_d),
        .jump_d(jump_d),
        .branch_d(branch_d),
        .jalr_d(jalr_d),
        .funct3_d(funct3_d),
        .result_src_d(result_src_d),
        .alu_control_d(alu_control_d),
        .read_data_1_d(read_data_1_d),
        .read_data_2_d(read_data_2_d),
        .pc_d(pc_d),
        .pc_plus_4_d(pc_plus_4_d),
        .imm_ext_d(imm_ext_d),
        .rs1_d(rs1_d),
        .rs2_d(rs2_d),
        .rd_d(rd_d),
        .reg_write_e(reg_write_e),
        .mem_write_e(mem_write_e),
        .alu_src_e(alu_src_e),
        .jump_e(jump_e),
        .branch_e(branch_e),
        .jalr_e(jalr_e),
        .funct3_e(funct3_e),
        .result_src_e(result_src_e),
        .alu_control_e(alu_control_e),
        .read_data_1_e(read_data_1_e),
        .read_data_2_e(read_data_2_e),
        .pc_e(pc_e),
        .pc_plus_4_e(pc_plus_4_e),
        .imm_ext_e(imm_ext_e),
        .rs1_e(rs1_e),
        .rs2_e(rs2_e),
        .rd_e(rd_e)
    );

    // Execute Cycle
    execute_cycle execute_stage (
        .forward_a_e(forward_a_e),
        .forward_b_e(forward_b_e),
        .jump_e(jump_e),
        .branch_e(branch_e),
        .jalr_e(jalr_e),
        .funct3_e(funct3_e),
        .alu_src_e(alu_src_e),
        .alu_control_e(alu_control_e),
        .alu_result_m(alu_result_m),
        .read_data_1_e(read_data_1_e),
        .read_data_2_e(read_data_2_e),
        .imm_ext_e(imm_ext_e),
        .pc_e(pc_e),
        .pc_plus_4_e(pc_plus_4_e),
        .result_w(result_w),
        .rd_e(rd_e),
        .pc_target_e(pc_target_e),
        .alu_result_e(alu_result_e),
        .write_data_e(write_data_e),
        .pc_src_e(pc_src_e)
    );

    // Pipeline Register: Execute -> Memory
    pipeline_3_4 pipeline_em (
        .clk(clk),
        .rst(rst),
        .reg_write_e(reg_write_e),
        .mem_write_e(mem_write_e),
        .result_src_e(result_src_e),
        .alu_result_e(alu_result_e),
        .write_data_e(write_data_e),
        .pc_plus_4_e(pc_plus_4_e),
        .rd_e(rd_e),
        .reg_write_m(reg_write_m),
        .mem_write_m(mem_write_m),
        .result_src_m(result_src_m),
        .alu_result_m(alu_result_m),
        .write_data_m(write_data_m),
        .pc_plus_4_m(pc_plus_4_m),
        .rd_m(rd_m)
    );

    // Memory Cycle
    memory_cycle memory_stage (
        .clk(clk),
        .rst(rst),
        .mem_write_m(mem_write_m),
        .alu_result_m(alu_result_m),
        .write_data_m(write_data_m),
        .read_data_m(read_data_m)
    );

    // Pipeline Register: Memory -> Writeback
    pipeline_4_5 pipeline_mw (
        .clk(clk),
        .rst(rst),
        .reg_write_m(reg_write_m),
        .result_src_m(result_src_m),
        .alu_result_m(alu_result_m),
        .read_data_m(read_data_m),
        .pc_plus_4_m(pc_plus_4_m),
        .rd_m(rd_m),
        .reg_write_w(reg_write_w),
        .result_src_w(result_src_w),
        .alu_result_w(alu_result_w),
        .read_data_w(read_data_w),
        .pc_plus_4_w(pc_plus_4_w),
        .rd_w(rd_w)
    );

    // Writeback Cycle
    writeback_cycle writeback_stage (
        .result_src_w(result_src_w),
        .alu_result_w(alu_result_w),
        .read_data_w(read_data_w),
        .pc_plus_4_w(pc_plus_4_w),
        .result_w(result_w)
    );

    // Hazard Unit
    hazard_unit hazard_detection (
        .rst(rst),
        .reg_write_w(reg_write_w),
        .reg_write_m(reg_write_m),
        .pc_src_e(pc_src_e),
        .rd_m(rd_m),
        .rd_w(rd_w),
        .rs1_e(rs1_e),
        .rs2_e(rs2_e),
        .rd_e(rd_e),
        .rs1_d(rs1_d),
        .rs2_d(rs2_d),
        .result_src_e(result_src_e),
        .forward_a_e(forward_a_e),
        .forward_b_e(forward_b_e),
        .stall_f(stall_f),
        .stall_d(stall_d),
        .flush_e(flush_e),
        .flush_d(flush_d)
    );

endmodule

`timescale 1ns/1ps

module tb_riscv_pipeline();
    reg clk;
    reg rst;

    // Kết nối với Top Module
    riscv_pipeline_top dut (
        .clk(clk),
        .rst(rst)
    );

    // Tạo xung clock 10ns (100MHz)
    always #5 clk = ~clk;

    // Đường dẫn ảo tới Register File (Bạn cần điều chỉnh tên instance cho đúng với thiết kế của bạn)
    // Giả sử trong decode_stage có một instance tên là 'reg_file'
    wire [31:0] reg_a0 = dut.decode_stage.register_file.register[10];
    wire [31:0] reg_a1 = dut.decode_stage.register_file.register[11];
    wire [31:0] reg_a2 = dut.decode_stage.register_file.register[12];

    initial begin
        // Khởi tạo
        clk = 0;
        rst = 0;
        
        // Reset hệ thống
        #100 rst = 1;

        // Chờ chuỗi lệnh thực thi
        // LUI a0 + ADDI a0 + LUI a1 + ADDI a1 + ADD a2 + NOP
        // Với pipeline 5 tầng, cần ít nhất 10-15 chu kỳ để quan sát hết kết quả ghi lại (Writeback)
        #200;

        // Kiểm tra kết quả cuối cùng tại a2 (x12)
        if (reg_a2 === 32'h17D78400) 
            $display("TEST PASSED: a2 = 0x%h", reg_a2);
        else 
            $display("TEST FAILED: a2 = 0x%h (Expected: 0x17D78400)", reg_a2);

        $stop;
    end

    // Ghi log để debug nếu cần
    initial begin
        $monitor("At time %t: PC_F = %h, Instr = %h, a0 = %h, a1 = %h, a2 = %h", 
                 $time, dut.pc_f, dut.instr_f, reg_a0, reg_a1, reg_a2);
    end

endmodule
