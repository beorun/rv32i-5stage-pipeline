`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/09/2026 06:55:25 PM
// Design Name: 
// Module Name: rv32i
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


module tb_riscv;
    // -------------------------------------------------------------------------
    // DUT signals
    // -------------------------------------------------------------------------
    reg clk, rst;

    riscv_top dut (
        .clk (clk),
        .rst (rst)
    );

    // 10ns clock period
    initial clk = 0;
    always #5 clk = ~clk;

    // -------------------------------------------------------------------------
    // Helper task: check a register value
    // -------------------------------------------------------------------------
    task check_reg;
        input [4:0]  reg_num;
        input [31:0] expected;
        input [127:0] test_name;
        begin
            if (dut.u_regfile.regs[reg_num] !== expected) begin
                $display("FAIL [%s] x%0d = 0x%08h, expected 0x%08h",
                         test_name, reg_num, dut.u_regfile.regs[reg_num], expected);
            end else begin
                $display("PASS [%s] x%0d = 0x%08h",
                         test_name, reg_num, expected);
            end
        end
    endtask

    // -------------------------------------------------------------------------
    // Reset sequence
    // -------------------------------------------------------------------------
    task do_reset;
        begin
            rst = 1;
            repeat(2) @(posedge clk);
            rst = 0;
        end
    endtask

    // =========================================================================
    // TEST 1: R-type instructions
    // Assembly:
    //   addi x1, x0, 10    # x1 = 10
    //   addi x2, x0, 20    # x2 = 20
    //   add  x3, x1, x2    # x3 = 30  (tests EX-EX forwarding x1, x2)
    //   sub  x4, x2, x1    # x4 = 10
    //   and  x5, x1, x3    # x5 = 10 & 30 = 10
    //   or   x6, x1, x2    # x6 = 10 | 20 = 30
    //   xor  x7, x1, x2    # x7 = 10 ^ 20 = 30
    //   slt  x8, x1, x2    # x8 = 1  (10 < 20)
    //   nop; nop; nop       # drain pipeline
    // =========================================================================
    initial begin


        // --- Test 1: R-type ---
        $readmemh("test_rtype.hex", dut.u_imem.mem);
        do_reset;
        repeat(20) @(posedge clk);

        $display("\n=== TEST 1: R-type ===");
        check_reg(1,  32'd10,  "ADDI x1");
        check_reg(2,  32'd20,  "ADDI x2");
        check_reg(3,  32'd30,  "ADD  x3");
        check_reg(4,  32'd10,  "SUB  x4");
        check_reg(5,  32'd10,  "AND  x5");
        check_reg(6,  32'd30,  "OR   x6");
        check_reg(7,  32'd30,  "XOR  x7");
        check_reg(8,  32'd1,   "SLT  x8");

        // --- Test 2: Load/Store ---
        // addi x1, x0, 100    # base addr = 100
        // addi x2, x0, 0xAB   # store value
        // sw   x2, 0(x1)      # mem[100] = 0xAB
        // lw   x3, 0(x1)      # x3 = mem[100] = 0xAB
        // nop; nop; nop
        $readmemh("test_loadstore.hex", dut.u_imem.mem);
        $readmemh("zeros.hex",          dut.u_dmem.mem);
        do_reset;
        repeat(20) @(posedge clk);

        $display("\n=== TEST 2: Load/Store ===");
        check_reg(3, 32'hAB, "LW x3");

        // --- Test 3: Data hazard forwarding ---
        // Tests EX-EX and MEM-EX forwarding chains
        // addi x1, x0, 5
        // addi x2, x1, 3    # MEM-EX: depends on x1 just written
        // add  x3, x1, x2   # EX-EX:  depends on x2 just written
        // nop; nop; nop
        $readmemh("test_forward.hex", dut.u_imem.mem);
        do_reset;
        repeat(15) @(posedge clk);

        $display("\n=== TEST 3: Forwarding ===");
        check_reg(1, 32'd5,  "ADDI x1=5");
        check_reg(2, 32'd8,  "ADDI x2=8 (fwd x1)");
        check_reg(3, 32'd13, "ADD  x3=13 (fwd x1+x2)");

        // --- Test 4: Load-use stall ---
        // addi x1, x0, 200    # address
        // addi x2, x0, 0x55
        // sw   x2, 0(x1)
        // lw   x3, 0(x1)
        // add  x4, x3, x3     # x3 not ready - pipeline MUST stall
        // nop; nop; nop
        $readmemh("test_loaduse.hex", dut.u_imem.mem);
        $readmemh("zeros.hex",        dut.u_dmem.mem);
        do_reset;
        repeat(25) @(posedge clk);

        $display("\n=== TEST 4: Load-use stall ===");
        check_reg(3, 32'h55,   "LW  x3=0x55");
        check_reg(4, 32'hAA,   "ADD x4=0xAA (2*0x55, after stall)");

        // --- Test 5: Branch flush ---
        // addi x1, x0, 1
        // addi x2, x0, 1
        // beq  x1, x2, label  # taken - 2 instructions after beq should flush
        // addi x3, x0, 0xFF   # should NOT execute (in flight when branch taken)
        // addi x4, x0, 0xFF   # should NOT execute
        // label:
        // addi x5, x0, 42     # SHOULD execute
        // nop; nop; nop
        $readmemh("test_branch.hex", dut.u_imem.mem);
        do_reset;
        repeat(20) @(posedge clk);

        $display("\n=== TEST 5: Branch flush ===");
        check_reg(3, 32'd0,   "x3=0 (flushed, not executed)");
        check_reg(4, 32'd0,   "x4=0 (flushed, not executed)");
        check_reg(5, 32'd42,  "x5=42 (branch target executed)");

        $display("\n=== All tests complete ===");
        $finish;
    end

    // Timeout watchdog
    initial begin
        #10000;
        $display("TIMEOUT");
        $finish;
    end
endmodule
