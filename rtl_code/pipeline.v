// pipeline cho fetch và decode
module pipeline_1_2 (
    input wire clk, rst, clr, en,
    input wire [31:0] instr_f, pc_f, pc_plus_4_f,
    output [31:0] instr_d, pc_d, pc_plus_4_d
);
    reg [31:0] instr_reg, pc_reg, pc_plus_4_reg;

    // Initialize registers to prevent 'x' values
    initial begin
        instr_reg = 32'h00000000;
        pc_reg = 32'h00000000;
        pc_plus_4_reg = 32'h00000000;
    end

    always @(posedge clk ) begin
        if((rst == 1'b0)||(clr == 1'b1)) begin
            instr_reg <= 32'h00000000;
            pc_reg <= 32'h00000000;
            pc_plus_4_reg <= 32'h00000000;
        end
        else begin
            if(en) begin
                instr_reg <= instr_f;
                pc_reg <= pc_f;
                pc_plus_4_reg <= pc_plus_4_f;
            end
            else begin
                instr_reg <= instr_reg;
                pc_reg <= pc_reg;
                pc_plus_4_reg <= pc_plus_4_reg;
            end
        end
    end

    assign instr_d = instr_reg;
    assign pc_d = pc_reg;
    assign pc_plus_4_d = pc_plus_4_reg;

endmodule 

//pipeline cho decode và execute
module pipeline_2_3 (
    input wire clk, rst, clr,
    input wire reg_write_d, mem_write_d, alu_src_d, jump_d, branch_d,
    input wire [1:0] result_src_d,
    input wire [3:0] alu_control_d,
    input wire [31:0] read_data_1_d, read_data_2_d, pc_d, pc_plus_4_d, imm_ext_d,
    input wire [4:0] rs1_d, rs2_d, rd_d, 
    output  reg_write_e, mem_write_e, alu_src_e, jump_e, branch_e,
    output  [1:0] result_src_e,
    output  [3:0] alu_control_e,
    output  [31:0] read_data_1_e, read_data_2_e, pc_e, pc_plus_4_e, imm_ext_e,
    output  [4:0] rs1_e, rs2_e, rd_e
);  
    reg reg_write_reg, mem_write_reg, alu_src_reg, jump_reg, branch_reg;
    reg [1:0] result_src_reg;
    reg [3:0] alu_control_reg;
    reg [31:0] read_data_1_reg, read_data_2_reg, pc_reg, pc_plus_4_reg, imm_ext_reg;
    reg [4:0] rs1_reg, rs2_reg, rd_reg;
    
    // Initialize all registers to prevent 'x' values
    initial begin
        reg_write_reg = 1'b0;
        mem_write_reg = 1'b0;
        alu_src_reg = 1'b0;
        jump_reg = 1'b0;
        branch_reg = 1'b0;
        result_src_reg = 2'b00;
        alu_control_reg = 4'b0000;
        read_data_1_reg = 32'h00000000;
        read_data_2_reg = 32'h00000000;
        pc_reg = 32'h00000000;
        pc_plus_4_reg = 32'h00000000;
        imm_ext_reg = 32'h00000000;
        rs1_reg = 5'h00;
        rs2_reg = 5'h00;
        rd_reg = 5'h00;
    end
    
    always @(posedge clk ) begin
        if((rst == 1'b0)||(clr == 1'b1)) begin
            reg_write_reg <= 1'b0;
            mem_write_reg <= 1'b0;
            alu_src_reg <= 1'b0;
            jump_reg <= 1'b0;
            branch_reg <= 1'b0;
            result_src_reg <= 2'b00;
            alu_control_reg <= 4'b0000;
            read_data_1_reg <= 32'h00000000;
            read_data_2_reg <= 32'h00000000;
            pc_reg <= 32'h00000000;
            pc_plus_4_reg <= 32'h00000000;
            imm_ext_reg <= 32'h00000000;
            rs1_reg <= 5'h00;
            rs2_reg <= 5'h00;
            rd_reg <= 5'h00;
        end
        else begin
            reg_write_reg <= reg_write_d;
            mem_write_reg <= mem_write_d;
            alu_src_reg <= alu_src_d;
            jump_reg <= jump_d;
            branch_reg <= branch_d;
            result_src_reg <= result_src_d;
            alu_control_reg <= alu_control_d;
            read_data_1_reg <= read_data_1_d;
            read_data_2_reg <= read_data_2_d;
            pc_reg <= pc_d;
            pc_plus_4_reg <= pc_plus_4_d;
            imm_ext_reg <= imm_ext_d;
            rs1_reg <= rs1_d;
            rs2_reg <= rs2_d;
            rd_reg <= rd_d;
        end
    end

    assign reg_write_e = reg_write_reg;
    assign mem_write_e = mem_write_reg;
    assign alu_src_e = alu_src_reg;
    assign jump_e = jump_reg;
    assign branch_e = branch_reg;
    assign result_src_e = result_src_reg;
    assign alu_control_e = alu_control_reg;
    assign read_data_1_e = read_data_1_reg;
    assign read_data_2_e = read_data_2_reg;
    assign pc_e = pc_reg;
    assign pc_plus_4_e = pc_plus_4_reg;
    assign imm_ext_e = imm_ext_reg;
    assign rs1_e = rs1_reg;
    assign rs2_e = rs2_reg;
    assign rd_e = rd_reg;  
endmodule

//pipeline cho execute và memory
module pipeline_3_4 (
    input wire clk, rst,
    input wire reg_write_e, mem_write_e,
    input wire [1:0] result_src_e, 
    input wire [31:0] alu_result_e, write_data_e, pc_plus_4_e,
    input wire [4:0] rd_e, 
    output  reg_write_m, mem_write_m,
    output  [1:0] result_src_m,
    output  [31:0] alu_result_m, write_data_m, pc_plus_4_m,
    output  [4:0] rd_m
);

    reg reg_write_reg, mem_write_reg;
    reg [1:0] result_src_reg;
    reg [31:0] alu_result_reg, write_data_reg, pc_plus_4_reg;
    reg [4:0] rd_reg;

    // Initialize all registers to prevent 'x' values
    initial begin
        reg_write_reg = 1'b0;
        mem_write_reg = 1'b0;
        result_src_reg = 2'b00;
        alu_result_reg = 32'h00000000;
        write_data_reg = 32'h00000000;
        pc_plus_4_reg = 32'h00000000;
        rd_reg = 5'h00;
    end

    always @(posedge clk ) begin
        if(rst == 1'b0) begin
            reg_write_reg <= 1'b0;
            mem_write_reg <= 1'b0;
            result_src_reg <= 2'b00;
            alu_result_reg <= 32'h00000000;
            write_data_reg <= 32'h00000000;
            pc_plus_4_reg <= 32'h00000000;
            rd_reg <= 5'h00;
        end
        else begin 
            reg_write_reg <= reg_write_e;
            mem_write_reg <= mem_write_e;
            result_src_reg <= result_src_e;
            alu_result_reg <= alu_result_e;
            write_data_reg <= write_data_e;
            pc_plus_4_reg <= pc_plus_4_e;
            rd_reg <= rd_e;
        end
    end

    assign reg_write_m = reg_write_reg;
    assign mem_write_m = mem_write_reg;
    assign result_src_m = result_src_reg;
    assign alu_result_m = alu_result_reg;
    assign write_data_m = write_data_reg;
    assign pc_plus_4_m = pc_plus_4_reg;
    assign rd_m = rd_reg;   
endmodule 


//pipeline cho memory và writeback
module pipeline_4_5 (
    input wire clk, rst,
    input wire reg_write_m, 
    input wire [1:0] result_src_m,
    input wire [31:0] alu_result_m, read_data_m, pc_plus_4_m,
    input wire [4:0] rd_m,
    output  reg_write_w, 
    output  [1:0] result_src_w,
    output  [31:0] alu_result_w, read_data_w, pc_plus_4_w,
    output  [4:0] rd_w
);

    reg reg_write_reg; 
    reg [1:0] result_src_reg;
    reg [31:0] alu_result_reg, read_data_reg, pc_plus_4_reg;
    reg [4:0] rd_reg;

    // Initialize all registers to prevent 'x' values
    initial begin
        reg_write_reg = 1'b0;
        result_src_reg = 2'b00;
        alu_result_reg = 32'h00000000;
        read_data_reg = 32'h00000000;
        pc_plus_4_reg = 32'h00000000;
        rd_reg = 5'h00;
    end

    always @(posedge clk ) begin
        if(rst == 1'b0) begin
            reg_write_reg <= 1'b0;
            result_src_reg <= 2'b00;
            alu_result_reg <= 32'h00000000;
            read_data_reg <= 32'h00000000;
            pc_plus_4_reg <= 32'h00000000;
            rd_reg <= 5'h00;
        end
        else begin 
            reg_write_reg <= reg_write_m;
            result_src_reg <= result_src_m;
            alu_result_reg <= alu_result_m;
            read_data_reg <= read_data_m;
            pc_plus_4_reg <= pc_plus_4_m;
            rd_reg <= rd_m;
        end
    end

    assign reg_write_w = reg_write_reg;
    assign result_src_w = result_src_reg;
    assign alu_result_w = alu_result_reg;
    assign read_data_w = read_data_reg;
    assign pc_plus_4_w = pc_plus_4_reg;
    assign rd_w = rd_reg;

endmodule