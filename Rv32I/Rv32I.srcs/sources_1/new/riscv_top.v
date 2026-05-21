`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/09/2026 05:34:56 PM
// Design Name: 
// Module Name: riscv_top
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module riscv_top(
    input wire clk,
    input wire rst
    );
    // --- IF stage ---
    wire [31:0] pc_current;
    wire [31:0] pc_plus4_if;
    wire [31:0] instr_if;
    wire        stall;
    wire        pc_src;
    wire [31:0] pc_target;

    // --- IF/ID register outputs ---
    wire [31:0] pc_if_id;
    wire [31:0] instr_if_id;

    // --- ID stage wires ---
    wire [6:0]  opcode_id;
    wire [4:0]  rs1_id, rs2_id, rd_id;
    wire [2:0]  funct3_id;
    wire [6:0]  funct7_id;
    wire [31:0] read_data1_id, read_data2_id;
    wire [31:0] imm_id;
    wire [31:0] pc_plus4_id;
    

    // Control signals from ID
    wire        reg_write_id;
    wire        mem_read_id;
    wire        mem_write_id;
    wire [1:0]  mem_to_reg_id;
    wire        alu_src_id;
    wire [1:0]  alu_op_id;
    wire        branch_id;
    wire        jump_id;

    // --- ID/EX register outputs ---
    wire [31:0] pc_id_ex;
    wire [31:0] read_data1_ex;
    wire [31:0] read_data2_ex;
    wire [31:0] imm_ex;
    wire [4:0]  rs1_ex, rs2_ex, rd_ex;
    wire [2:0]  funct3_ex;
    wire [6:0]  funct7_ex;
    wire        reg_write_ex, mem_read_ex, mem_write_ex;
    wire [1:0]  mem_to_reg_ex;
    wire        alu_src_ex, branch_ex, jump_ex;
    wire [1:0]  alu_op_ex;
    wire        opcode_b5_ex;

    // --- EX stage wires ---
    wire [3:0]  alu_ctrl_ex;
    wire [31:0] fwd_a, fwd_b;        // forwarded operands
    wire [31:0] alu_op_b;            // after alu_src mux
    wire [31:0] alu_result_ex;
    wire        alu_zero_ex;
    wire [31:0] branch_target_ex;
    wire        branch_taken;
    wire [31:0] pc_plus4_ex;

    // --- EX/MEM register outputs ---
    wire [31:0] alu_result_mem;
    wire [31:0] write_data_mem;
    wire [4:0]  rd_mem;
    wire [31:0] pc_plus4_mem;
    wire        reg_write_mem, mem_read_mem, mem_write_mem;
    wire [1:0]  mem_to_reg_mem;
    wire [2:0] funct3_mem;
    
    // --- MEM stage wires ---
    wire [31:0] mem_read_data;
    

    // --- MEM/WB register outputs ---
    wire [31:0] alu_result_wb;
    wire [31:0] mem_data_wb;
    wire [4:0]  rd_wb;
    wire [31:0] pc_plus4_wb;
    wire [31:0] imm_wb;
    wire        reg_write_wb;
    wire [1:0]  mem_to_reg_wb;
    wire [2:0] funct3_wb;

    // --- WB stage ---
    wire [31:0] wb_data;

    // --- Hazard/Forwarding ---
    wire        flush_if_id;
    wire        flush_id_ex;
    wire [1:0]  forward_a, forward_b;

    // =========================================================================
    // IF Stage
    // =========================================================================

    assign pc_plus4_if = pc_current + 32'd4;

    pc u_pc (
        .clk       (clk),
        .rst       (rst),
        .stall     (stall),
        .pc_src    (pc_src),
        .pc_target (pc_target),
        .pc_out    (pc_current)
    );

    instr_mem u_imem (
        .addr  (pc_current),
        .instr (instr_if)
    );

    if_id_reg u_if_id (
        .clk      (clk),
        .rst      (rst),
        .stall    (stall),
        .flush    (flush_if_id),
        .pc_in    (pc_plus4_if),   // store PC+4 for branch/link computations
        .instr_in (instr_if),
        .pc_out   (pc_if_id),
        .instr_out(instr_if_id)
    );

    // =========================================================================
    // ID Stage
    // =========================================================================

    // Instruction field extraction
    assign opcode_id = instr_if_id[6:0];
    assign rd_id     = instr_if_id[11:7];
    assign funct3_id = instr_if_id[14:12];
    assign rs1_id    = instr_if_id[19:15];
    assign rs2_id    = instr_if_id[24:20];
    assign funct7_id = instr_if_id[31:25];
    assign pc_plus4_id = pc_if_id; // pc_if_id already holds PC+4

    control_unit u_ctrl (
        .opcode     (opcode_id),
        .reg_write  (reg_write_id),
        .mem_read   (mem_read_id),
        .mem_write  (mem_write_id),
        .mem_to_reg (mem_to_reg_id),
        .alu_src    (alu_src_id),
        .alu_op     (alu_op_id),
        .branch     (branch_id),
        .jump       (jump_id)
    );

    reg_file u_regfile (
        .clk        (clk),
        .reg_write  (reg_write_wb),
        .rs1        (rs1_id),
        .rs2        (rs2_id),
        .rd         (rd_wb),
        .write_data (wb_data),
        .read_data1 (read_data1_id),
        .read_data2 (read_data2_id)
    );

    imm_gen u_immgen (
        .instr   (instr_if_id),
        .imm_out (imm_id)
    );

    id_ex_reg u_id_ex (
        .clk             (clk),
        .rst             (rst),
        .flush           (flush_id_ex),
        .pc_in           (pc_plus4_id),
        .read_data1_in   (read_data1_id),
        .read_data2_in   (read_data2_id),
        .imm_in          (imm_id),
        .rs1_in          (rs1_id),
        .rs2_in          (rs2_id),
        .rd_in           (rd_id),
        .funct3_in       (funct3_id),
        .funct7_in       (funct7_id),
        .reg_write_in    (reg_write_id),
        .mem_read_in     (mem_read_id),
        .mem_write_in    (mem_write_id),
        .mem_to_reg_in   (mem_to_reg_id),
        .alu_src_in      (alu_src_id),
        .alu_op_in       (alu_op_id),
        .branch_in       (branch_id),
        .jump_in         (jump_id),
        .opcode_b5_in    (opcode_id[5]),
        // outputs
        .pc_out          (pc_id_ex),
        .read_data1_out  (read_data1_ex),
        .read_data2_out  (read_data2_ex),
        .imm_out         (imm_ex),
        .rs1_out         (rs1_ex),
        .rs2_out         (rs2_ex),
        .rd_out          (rd_ex),
        .funct3_out      (funct3_ex),
        .funct7_out      (funct7_ex),
        .reg_write_out   (reg_write_ex),
        .mem_read_out    (mem_read_ex),
        .mem_write_out   (mem_write_ex),
        .mem_to_reg_out  (mem_to_reg_ex),
        .alu_src_out     (alu_src_ex),
        .alu_op_out      (alu_op_ex),
        .branch_out      (branch_ex),
        .jump_out        (jump_ex),
        .opcode_b5_out   (opcode_b5_ex)
    );

    // =========================================================================
    // EX Stage
    // =========================================================================

    // Forwarding muxes for ALU operand A
    assign fwd_a = (forward_a == 2'b10) ? alu_result_mem  :   // EX/MEM forward
                   (forward_a == 2'b01) ? wb_data          :   // MEM/WB forward
                                          read_data1_ex;       // register file

    // Forwarding mux for ALU operand B (pre-alu_src mux)
    wire [31:0] fwd_b_raw;
    assign fwd_b_raw = (forward_b == 2'b10) ? alu_result_mem :
                       (forward_b == 2'b01) ? wb_data         :
                                              read_data2_ex;

    // ALU source B mux: immediate or register
    assign alu_op_b = (alu_src_ex) ? imm_ex : fwd_b_raw;

    // fwd_b used for store data (SW needs forwarded rs2, not immediate)
    assign fwd_b = fwd_b_raw;

    alu_control u_alu_ctrl (
        .alu_op   (alu_op_ex),
        .opcode_b5(opcode_b5_ex),
        .funct3   (funct3_ex),
        .funct7   (funct7_ex),
        .alu_ctrl (alu_ctrl_ex)
    );

    alu u_alu (
        .a        (fwd_a),
        .b        (alu_op_b),
        .alu_ctrl (alu_ctrl_ex),
        .result   (alu_result_ex),
        .zero     (alu_zero_ex)
    );

    // Branch target: PC_id_ex already holds PC+4; branch imm is PC-relative
    // Actual branch target = (PC of branch instruction) + imm
    // Since pc_id_ex = PC+4, we subtract 4 to get branch base PC, then add imm.
    // Alternatively, keep PC (not PC+4) in the pipeline register. Here we store
    // PC+4 for the link, so: branch_target = (pc_id_ex - 4) + imm
    assign branch_target_ex = (pc_id_ex - 32'd4) + imm_ex;

    // Branch/jump taken logic
    // BEQ: funct3=000, taken if zero=1
    // BNE: funct3=001, taken if zero=0
   
    //only for BEQ and BNE
//    assign branch_condition = (funct3_ex == 3'b000) ?  alu_zero_ex :   // BEQ
//                              (funct3_ex == 3'b001) ? ~alu_zero_ex :   // BNE
//                              1'b0;
    
    //Full B-type :
    wire branch_condition;
    assign branch_condition = (funct3_ex == 3'b000) ?  (fwd_a == fwd_b) :   // BEQ
                              (funct3_ex == 3'b001) ? (fwd_a != fwd_b) :   // BNE
                              (funct3_ex == 3'b100) ? ($signed(fwd_a) < $signed(fwd_b)) :        // BLT  (Signed)
                              (funct3_ex == 3'b101) ? ($signed(fwd_a) >= $signed(fwd_b)) :       // BGE  (Signed)
                              (funct3_ex == 3'b110) ? (fwd_a < fwd_b) :                          // BLTU (Unsigned)
                              (funct3_ex == 3'b111) ? (fwd_a >= fwd_b) :                         // BGEU (Unsigned)
                               1'b0; // Default case

    assign branch_taken = (branch_ex && branch_condition) || jump_ex;

    // PC target: for JALR the target = rs1 + imm (alu_result), else branch formula
    assign pc_target  = (jump_ex && funct3_ex == 3'b000 && 
                         instr_if_id[6:0] == 7'b1100111) ? // JALR opcode
                        (alu_result_ex & ~32'd1) :          // JALR: clear bit0
                        branch_target_ex;
    assign pc_src     = branch_taken;

    assign pc_plus4_ex = pc_id_ex; // pc_id_ex already = PC+4

    ex_mem_reg u_ex_mem (
        .clk            (clk),
        .rst            (rst),
        .alu_result_in  (alu_result_ex),
        .write_data_in  (fwd_b),           // forwarded rs2 for SW
        .rd_in          (rd_ex),
        .pc_plus4_in    (pc_plus4_ex),
        .reg_write_in   (reg_write_ex),
        .mem_read_in    (mem_read_ex),
        .mem_write_in   (mem_write_ex),
        .mem_to_reg_in  (mem_to_reg_ex),
        .funct3_in      (funct3_ex),
        //output
        .alu_result_out (alu_result_mem),
        .write_data_out (write_data_mem),
        .rd_out         (rd_mem),
        .pc_plus4_out   (pc_plus4_mem),
        .reg_write_out  (reg_write_mem),
        .mem_read_out   (mem_read_mem),
        .mem_write_out  (mem_write_mem),
        .mem_to_reg_out (mem_to_reg_mem),
        .funct3_out     (funct3_mem)
    );

    // =========================================================================
    // MEM Stage
    // =========================================================================

    // Tín hiệu kết nối mới tới Data Memory
    reg [31:0] ram_wdata;
    reg [3:0]  ram_wmask;
    
    // Lấy 2 bit thấp của địa chỉ để xác định vị trí byte (0, 1, 2, 3)
    wire [1:0] byte_addr = alu_result_mem[1:0];

    always @(*) begin
        // Mặc định ban đầu
        ram_wdata = write_data_mem;
        ram_wmask = 4'b0000;

        if (mem_write_mem) begin
            case (funct3_mem)
                3'b000: begin // SB - Store Byte (8-bit)
                    case (byte_addr)
                        2'b00: begin ram_wdata = {24'b0, write_data_mem[7:0]};        ram_wmask = 4'b0001; end
                        2'b01: begin ram_wdata = {16'b0, write_data_mem[7:0], 8'b0};  ram_wmask = 4'b0010; end
                        2'b10: begin ram_wdata = {8'b0,  write_data_mem[7:0], 16'b0}; ram_wmask = 4'b0100; end
                        2'b11: begin ram_wdata = {write_data_mem[7:0], 24'b0};        ram_wmask = 4'b1000; end
                    endcase
                end
                
                3'b001: begin // SH - Store Halfword (16-bit)
                    case (byte_addr[1]) // Thường chỉ căn chỉnh theo địa chỉ chẵn (00 hoặc 10)
                        1'b0: begin ram_wdata = {16'b0, write_data_mem[15:0]};       ram_wmask = 4'b0011; end
                        1'b1: begin ram_wdata = {write_data_mem[15:0], 16'b0};       ram_wmask = 4'b1100; end
                    endcase
                end
                
                3'b010: begin // SW - Store Word (32-bit)
                    ram_wdata = write_data_mem;
                    ram_wmask = 4'b1111; // Ghi đè cả 4 byte
                end
                
                default: begin
                    ram_wdata = write_data_mem;
                    ram_wmask = 4'b0000;
                end
            endcase
        end
    end
    
    
    data_mem u_dmem (
        .clk        (clk),
        .mem_read   (mem_read_mem),
        .mem_write  (mem_write_mem),
        .wmask      (ram_wmask),
        .addr       (alu_result_mem),
        .write_data (ram_wdata),
        .read_data  (mem_read_data)
    );

    mem_wb_reg u_mem_wb (
        .clk            (clk),
        .rst            (rst),
        .alu_result_in  (alu_result_mem),
        .mem_data_in    (mem_read_data),
        .rd_in          (rd_mem),
        .pc_plus4_in    (pc_plus4_mem),
        .imm_in         (32'b0),            // LUI imm already in ALU result via PASS_B
        .reg_write_in   (reg_write_mem),
        .mem_to_reg_in  (mem_to_reg_mem),
        .funct3_in      (funct3_mem),
        //output
        .alu_result_out (alu_result_wb),
        .mem_data_out   (mem_data_wb),
        .rd_out         (rd_wb),
        .pc_plus4_out   (pc_plus4_wb),
        .imm_out        (imm_wb),
        .reg_write_out  (reg_write_wb),
        .mem_to_reg_out (mem_to_reg_wb),
        .funct3_out     (funct3_wb)
    );
    // =========================================================================
    // WB Stage - Data Extractor & Extender
    // =========================================================================
    reg [7:0]  extracted_byte;
    reg [15:0] extracted_half;
    reg [31:0] mem_data_formatted;

    wire [1:0] byte_offset = alu_result_wb[1:0]; // 2 bit cuối của địa chỉ

    //Trích xuất dữ liệu từ cục 32-bit của RAM
    always @(*) begin
        case (byte_offset)
            2'b00: extracted_byte = mem_data_wb[7:0];
            2'b01: extracted_byte = mem_data_wb[15:8];
            2'b10: extracted_byte = mem_data_wb[23:16];
            2'b11: extracted_byte = mem_data_wb[31:24];
        endcase
    end

    always @(*) begin
        case (byte_offset[1])
            1'b0: extracted_half = mem_data_wb[15:0];
            1'b1: extracted_half = mem_data_wb[31:16];
        endcase
    end

    //Mở rộng dấu (Sign-Extend hoặc Zero-Extend)
    always @(*) begin
        case (funct3_wb)
            3'b000: mem_data_formatted = {{24{extracted_byte[7]}}, extracted_byte};   // LB  (Kéo dài bit dấu)
            3'b001: mem_data_formatted = {{16{extracted_half[15]}}, extracted_half};  // LH  (Kéo dài bit dấu)
            3'b010: mem_data_formatted = mem_data_wb;                                 // LW  (Bê nguyên cục 32-bit)
            3'b100: mem_data_formatted = {24'b0, extracted_byte};                     // LBU (Chèn thêm số 0)
            3'b101: mem_data_formatted = {16'b0, extracted_half};                     // LHU (Chèn thêm số 0)
            default: mem_data_formatted = mem_data_wb;
        endcase
    end
    // =========================================================================
    // WB Stage - Write-back mux
    // =========================================================================
    // mem_to_reg: 00=ALU, 01=MemData, 10=PC+4 (link), 11=Imm (LUI)
    assign wb_data = (mem_to_reg_wb == 2'b01) ? mem_data_formatted  :
                     (mem_to_reg_wb == 2'b10) ? pc_plus4_wb         :
                     (mem_to_reg_wb == 2'b11) ? imm_wb              :
                                                alu_result_wb;

    // =========================================================================
    // Hazard Detection Unit
    // =========================================================================

    hazard_unit u_hazard (
        .id_ex_mem_read (mem_read_ex),
        .id_ex_rd       (rd_ex),
        .if_id_rs1      (rs1_id),
        .if_id_rs2      (rs2_id),
        .branch_taken   (branch_taken),
        .stall          (stall),
        .flush_if_id    (flush_if_id),
        .flush_id_ex    (flush_id_ex)
    );

    // =========================================================================
    // Forwarding Unit
    // =========================================================================

    forwarding_unit u_fwd (
        .id_ex_rs1       (rs1_ex),
        .id_ex_rs2       (rs2_ex),
        .ex_mem_rd       (rd_mem),
        .ex_mem_reg_write(reg_write_mem),
        .mem_wb_rd       (rd_wb),
        .mem_wb_reg_write(reg_write_wb),
        .forward_a       (forward_a),
        .forward_b       (forward_b)
    );
endmodule
