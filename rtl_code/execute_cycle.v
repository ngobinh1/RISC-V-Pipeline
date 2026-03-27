module execute_cycle(
    input wire [1:0] forward_a_e, forward_b_e, 
    input wire jump_e, branch_e, alu_src_e,
    input wire [3:0] alu_control_e,
    input wire [31:0] alu_result_m, read_data_1_e, read_data_2_e, imm_ext_e, pc_e, pc_plus_4_e, result_w,
    input wire [4:0] rd_e, 
    output  [31:0] pc_target_e, alu_result_e, write_data_e, 
    output  pc_src_e
);
    wire [31:0] src_a_e, src_b_e, src_b_interim_e;
    wire [31:0] alu_input_a;
    wire zero_e;
    wire overflow_e, carry_e, neg_e;

    // Forwarding MUX for source A
    mux_3_1 src_a_emux (
        .a(read_data_1_e),
        .b(result_w),
        .c(alu_result_m),
        .s(forward_a_e),
        .d(src_a_e)
    );

    // Forwarding MUX for source B (before alu_src mux)
    mux_3_1 src_b_interim_e_mux (
        .a(read_data_2_e),
        .b(result_w),
        .c(alu_result_m),
        .s(forward_b_e),
        .d(src_b_interim_e)
    );

    // ALU source MUX (register or immediate)
    mux alu_src_mux (
        .a(src_b_interim_e),
        .b(imm_ext_e),
        .s(alu_src_e),
        .c(src_b_e)
    );

    // For AUIPC, we need to use PC instead of register value
    // AUIPC is identified by alu_control = 1000
    assign alu_input_a = (alu_control_e == 4'b1000) ? pc_e : src_a_e;

    // ALU
    alu alu_unit (
        .a(alu_input_a),
        .b(src_b_e),
        .alu_control(alu_control_e),
        .result(alu_result_e),
        .overflow(overflow_e),
        .carry(carry_e),
        .zero(zero_e),
        .neg(neg_e)
    );

    // Branch adder
    adder branch_adder (
        .a(pc_e),
        .b(imm_ext_e),
        .c(pc_target_e)
    );

    // PC source control
    assign pc_src_e = (zero_e & branch_e) | jump_e;
    
    // Write data for store instructions (use forwarded value)
    assign write_data_e = src_b_interim_e;

endmodule