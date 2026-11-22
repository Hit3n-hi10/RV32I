module rv32i_top_tb();

logic clk;
logic rst;

rv32i_top core_block(.clk(clk),.rst(rst));

//clock generation
initial begin 
    clk = 0;
    forever #5 clk = ~clk;
end

// Clock check 
task automatic check_clock();
    real t0, t1;
    begin
        $display("CLOCK CHECK");
        @(posedge clk); t0 = $realtime;
        @(posedge clk); t1 = $realtime;
        if ((t1 - t0) == 10.0)
            $display("PASS : Clock Period (%0f ns)", t1-t0);
        else
            $display("FAIL : Clock Period (got %0f ns, expected 10ns)", t1-t0);
    end
endtask

// Reset check
task automatic check_reset();
    begin
        $display("RESET CHECK");
        rst = 1;
        @(posedge clk);
        if (core_block.pc == 32'h0)
            $display("PASS : Reset PC");
        else
            $display("FAIL : Reset PC (got %h)", core_block.pc);

        if (core_block.regfile_block.registers[1] == 0 &&
            core_block.regfile_block.registers[5] == 0 &&
            core_block.regfile_block.registers[13] == 0)
            $display("PASS : Reset Register File");
        else
            $display("FAIL : Reset Register File");

        repeat(3) @(posedge clk);
        rst = 0;
        $display("reset released");
    end
endtask

task load_program();
begin

// addi x1,x0,5
core_block.imem_block.mem[0]  = 32'h00500093;

// addi x2,x0,10
core_block.imem_block.mem[1]  = 32'h00A00113;

// add x3,x1,x2
core_block.imem_block.mem[2]  = 32'h002081B3;

// sub x8,x2,x1
core_block.imem_block.mem[3]  = 32'h40110433;

// ori x10,x1,3
core_block.imem_block.mem[4]  = 32'h0030E513;

// sw x3,0(x0)
core_block.imem_block.mem[5]  = 32'h00302023;

// lw x4,0(x0)
core_block.imem_block.mem[6]  = 32'h00002203;

// beq x3,x4,+8
core_block.imem_block.mem[7]  = 32'h00418463;

// addi x5,x0,99 (should be skipped)
core_block.imem_block.mem[8]  = 32'h06300293;

// addi x5,x0,1
core_block.imem_block.mem[9]  = 32'h00100293;

// jal x6,+8
core_block.imem_block.mem[10] = 32'h0080036F;

// addi x7,x0,99 (should be skipped)
core_block.imem_block.mem[11] = 32'h06300393;

// addi x7,x0,7
core_block.imem_block.mem[12] = 32'h00700393;

// nop (0x34)
core_block.imem_block.mem[13] = 32'h00000013;

// nop (0x38)
core_block.imem_block.mem[14] = 32'h00000013;

// nop (0x3C)
core_block.imem_block.mem[15] = 32'h00000013;

// bne x8,x2,+8 (0x40)
core_block.imem_block.mem[16] = 32'h00241463;

// addi x9,x0,99 (0x44)
core_block.imem_block.mem[17] = 32'h06300493;

// addi x9,x0,9 (0x48)
core_block.imem_block.mem[18] = 32'h00900493;

// nop (0x4C)
core_block.imem_block.mem[19] = 32'h00000013;

// jalr x13,x0,0x58 (0x50)
core_block.imem_block.mem[20] = 32'h058006E7;

// addi x14,x0,99 (0x54)
core_block.imem_block.mem[21] = 32'h06300713;

// addi x14,x0,14 (0x58)
core_block.imem_block.mem[22] = 32'h00E00713;

for (int i = 23; i < 256; i = i + 1)
    core_block.imem_block.mem[i] = 32'h00000013; // nop

end
endtask

bit verbose = 1;

always @(posedge clk) if (verbose) begin
    $display("Time : %0t",$time);
    $display("Pc : %h",core_block.pc);
    $display("Next Pc : %h",core_block.next_pc);
    $display("Instruction: %h",core_block.instruction);
    $display("ALU Result: %h",core_block.alu_result);
end


task automatic check_results();
begin

if(core_block.regfile_block.registers[1]==5)
$display("PASS : x1");

else 
$display("FAIL : x1");

if(core_block.regfile_block.registers[2]==10)
$display("PASS : x2");

else
$display("FAIL : x2");

if(core_block.regfile_block.registers[3]==15)
$display("PASS : x3");

else
$display("FAIL : x3");

if(core_block.regfile_block.registers[8] == 5)
    $display("PASS : x8 (SUB)");
else
    $display("FAIL : x8 (SUB)");

if(core_block.regfile_block.registers[10] == 7)
    $display("PASS : x10 (ORI)");
else
    $display("FAIL : x10 (ORI)");

if(core_block.dmem_block.memory[0]==15)
$display("PASS : Memory");

else
$display("FAIL : Memory");

if(core_block.regfile_block.registers[4] == 15)
    $display("PASS : x4");
else
    $display("FAIL : x4");

if(core_block.regfile_block.registers[5] == 1)
    $display("PASS : Branch");
else
    $display("FAIL : Branch");

if(core_block.regfile_block.registers[6] == 32'h2C)
    $display("PASS : JAL Link Register");
else
    $display("FAIL : JAL Link Register");

if(core_block.regfile_block.registers[7] == 7)
    $display("PASS : Jump");
else
    $display("FAIL : Jump");

if(core_block.dmem_block.memory[0] == 15)
    $display("PASS : Memory");
else
    $display("FAIL : Memory");

if(core_block.regfile_block.registers[13] == 32'h54)
    $display("PASS : JALR Link Register");
else
    $display("FAIL : JALR Link Register");

if(core_block.regfile_block.registers[14] == 14)
    $display("PASS : JALR Jump Target (skip verified)");
else
    $display("FAIL : JALR Jump Target (skip verified)");
if (core_block.regfile_block.registers[9] == 32'd9)
    $display("PASS: BNE instruction");
else
    $display("FAIL: BNE instruction");
end
endtask
    
//connectivity check
 int conn_pass = 0;
int conn_fail = 0;

task automatic chk(input bit cond, input string name);
    if (cond) begin
        $display("PASS : %s", name);
        conn_pass++;
    end
    else begin
        $display("FAIL : %s", name);
        conn_fail++;
    end
endtask

task automatic connectivity_check();
begin

    conn_pass = 0;
    conn_fail = 0;

    $display("MODULE CONNECTIVITY CHECK");

    // ---------------------------------------------------------
    // Deterministic start: reset, release 1 ns after a clock edge,
    // then let combinational logic settle. PC is still 0 here.
    // ---------------------------------------------------------
    rst = 1;
    repeat (3) @(posedge clk);
    #1;
    rst = 0;
    #1;

    // =========================================================
    // INSTRUCTION 0 : addi x1,x0,5   (0x00500093), PC = 0
    // =========================================================
    $display("-- Instruction 0: addi x1,x0,5 --");

    // Program counter
    chk(core_block.pc === 32'h0,                  "PC = 0 after reset release");

    // Instruction memory
    chk(core_block.instruction === 32'h00500093,  "Instruction Memory");

    // Decoder
    chk(core_block.opcode   === 7'b0010011,       "Decoder: opcode");
    chk(core_block.rs1_addr === 5'd0,             "Decoder: rs1");
    // I-type has no rs2 field: a decoder may pass instruction[24:20] (= 5)
    // through or mask it to 0. Either is correct, X/Z is not.
    chk((core_block.rs2_addr === 5'd0) || (core_block.rs2_addr === 5'd5),
                                                  "Decoder: rs2 (0 or 5 for I-type)");
    chk(core_block.rd_addr  === 5'd1,             "Decoder: rd");
    chk(core_block.funct3   === 3'b000,           "Decoder: funct3");
    chk(core_block.funct7   === 7'b0000000,       "Decoder: funct7");
    chk(core_block.illegal_instr === 1'b0,        "Decoder: illegal_instr low");

    // Control unit
    chk(core_block.RegWrite === 1'b1,             "Control: RegWrite");
    chk(core_block.ALUSrc   === 1'b1,             "Control: ALUSrc (immediate)");
    chk(core_block.ALUSrcA  === 2'b00,            "Control: ALUSrcA (rs1)");
    chk(core_block.MemRead  === 1'b0,             "Control: MemRead");
    chk(core_block.MemWrite === 1'b0,             "Control: MemWrite");
    chk(core_block.MemToReg === 1'b0,             "Control: MemToReg");
    chk(core_block.Branch   === 1'b0,             "Control: Branch");
    chk(core_block.Jump     === 1'b0,             "Control: Jump");
    chk(core_block.Jalr     === 1'b0,             "Control: Jalr");
    chk(core_block.ALUOp    === 2'b10,            "Control: ALUOp");

    // Immediate generator
    chk(core_block.immediate === 32'd5,           "Immediate Generator");

    // ALU control
    chk(core_block.alu_op === 4'b0000,            "ALU Control");

    // Register file read, ALU inputs
    chk(core_block.rs1_data === 32'd0,            "Register File Read (rs1)");
    chk(core_block.alu_A    === 32'd0,            "ALU input A");
    chk(core_block.alu_B    === 32'd5,            "ALU input B (immediate mux)");

    // ALU
    chk(core_block.alu_result === 32'd5,          "ALU result");
    chk(core_block.alu_zero   === 1'b0,           "ALU zero flag");

    // Write-back mux and branch/jump unit
    chk(core_block.write_back_data === 32'd5,     "Write-back mux");
    chk(core_block.next_pc    === 32'd4,          "Branch/Jump unit: next PC = PC+4");
    chk(core_block.brh_taken  === 1'b0,           "Branch/Jump unit: brh_taken low");
    chk(core_block.jump_taken === 1'b0,           "Branch/Jump unit: jump_taken low");

    // Execute instruction 0, then check state 1 ns after the edge
    @(posedge clk); #1;
    chk(core_block.pc === 32'h4,                                    "PC updated to 4");
    chk(core_block.regfile_block.registers[1] === 32'd5,            "Register File Writeback (x1 = 5)");

    // Execute instruction 1 (addi x2,x0,10)
    @(posedge clk); #1;
    chk(core_block.pc === 32'h8,                                    "PC updated to 8");
    chk(core_block.regfile_block.registers[2] === 32'd10,           "Register File Writeback (x2 = 10)");

    // =========================================================
    // INSTRUCTION 2 : add x3,x1,x2   (0x002081B3), PC = 8
    // Exercises the rs2 read path and the register-operand ALU path
    // =========================================================
    $display("-- Instruction 2: add x3,x1,x2 --");

    chk(core_block.instruction === 32'h002081B3,  "Instruction Memory (add)");
    chk(core_block.opcode   === 7'b0110011,       "Decoder: R-type opcode");
    chk(core_block.rs1_addr === 5'd1,             "Decoder: rs1 = x1");
    chk(core_block.rs2_addr === 5'd2,             "Decoder: rs2 = x2");
    chk(core_block.rd_addr  === 5'd3,             "Decoder: rd = x3");
    chk(core_block.RegWrite === 1'b1,             "Control: RegWrite");
    chk(core_block.ALUSrc   === 1'b0,             "Control: ALUSrc (register)");
    chk(core_block.rs1_data === 32'd5,            "Register File Read (rs1 = 5)");
    chk(core_block.rs2_data === 32'd10,           "Register File Read (rs2 = 10)");
    chk(core_block.alu_B    === 32'd10,           "ALU input B (rs2 mux)");
    chk(core_block.alu_op   === 4'b0000,          "ALU Control (ADD)");
    chk(core_block.alu_result === 32'd15,         "ALU result (15)");
    chk(core_block.write_back_data === 32'd15,    "Write-back mux (15)");

    @(posedge clk); #1;
    chk(core_block.regfile_block.registers[3] === 32'd15,           "Register File Writeback (x3 = 15)");
    chk(core_block.pc === 32'hC,                                    "PC updated to C");

    // ---------------------------------------------------------
    // Summary: only claims success if nothing failed
    // ---------------------------------------------------------
    if (conn_fail == 0)
        $display("MODULE CONNECTIVITY VERIFIED (%0d/%0d checks passed)",
                 conn_pass, conn_pass + conn_fail);
    else
        $display("MODULE CONNECTIVITY FAILED (%0d failed, %0d passed)",
                 conn_fail, conn_pass);

end
endtask
    
// Bootflow check
    
task automatic boot_check();

begin

    $display("\n==================================");
    $display("BOOT FLOW VERIFICATION");
    $display("====================================");

    // Immediately after reset release
    if(core_block.pc == 32'h00000000)
        $display("PASS : Reset Vector");
    else
        $display("FAIL : Reset Vector");


    // Cycle 1
    @(posedge clk);

    $display("\nCycle 1");

    if(core_block.pc == 32'h00000000)
        $display("PASS : PC = 0");
    else
        $display("FAIL : PC");

    if(core_block.instruction == 32'h00500093)
        $display("PASS : First Instruction Fetch");
    else
        $display("FAIL : First Instruction");

    // Cycle 2

    @(posedge clk);

    $display("\nCycle 2");

    if(core_block.pc == 32'h00000004)
        $display("PASS : PC = 4");
    else
        $display("FAIL : PC");

    if(core_block.regfile_block.registers[1] == 32'd5)
        $display("PASS : x1 = 5");
    else
        $display("FAIL : x1");

    // Cycle 3

    @(posedge clk);

    $display("\nCycle 3");

    if(core_block.pc == 32'h00000008)
        $display("PASS : PC = 8");
    else
        $display("FAIL : PC");

    if(core_block.regfile_block.registers[2] == 32'd10)
        $display("PASS : x2 = 10");
    else
        $display("FAIL : x2");


    // Cycle 4

    @(posedge clk);

    $display("\nCycle 4");

    if(core_block.pc == 32'h0000000C)
        $display("PASS : PC = C");
    else
        $display("FAIL : PC");

    if(core_block.regfile_block.registers[3] == 32'd15)
        $display("PASS : x3 = 15");
    else
        $display("FAIL : x3");

    $display("\nBOOT FLOW VERIFICATION COMPLETED\n");

end

endtask

// ---------------------------------------------------------------
// Low-Power Wake Boot Check
// No dedicated power-gating/sleep signal exists - extended reset hold simulates wake-from-idle.
// ---------------------------------------------------------------
task automatic boot_check_lowpower_wake();

begin

    $display("\n==================================");
    $display("BOOT FLOW VERIFICATION (WAKE FROM LOW POWER)");
    $display("====================================");

    // Simulate extended idle/sleep by holding reset far longer
    // than the normal check_reset() hold (3 cycles).
    rst = 1;
    repeat(50) @(posedge clk);
    rst = 0;

    if(core_block.pc == 32'h00000000)
        $display("PASS : Reset Vector (wake)");
    else
        $display("FAIL : Reset Vector (wake)");

    // Cycle 1
    @(posedge clk);
    $display("\nCycle 1 (wake)");
    if(core_block.pc == 32'h00000000)
        $display("PASS : PC = 0 (wake)");
    else
        $display("FAIL : PC (wake)");
    if(core_block.instruction == 32'h00500093)
        $display("PASS : First Instruction Fetch (wake)");
    else
        $display("FAIL : First Instruction (wake)");

    // Cycle 2
    @(posedge clk);
    $display("\nCycle 2 (wake)");
    if(core_block.pc == 32'h00000004)
        $display("PASS : PC = 4 (wake)");
    else
        $display("FAIL : PC (wake)");
    if(core_block.regfile_block.registers[1] == 32'd5)
        $display("PASS : x1 = 5 (wake)");
    else
        $display("FAIL : x1 (wake)");

    // Cycle 3
    @(posedge clk);
    $display("\nCycle 3 (wake)");
    if(core_block.pc == 32'h00000008)
        $display("PASS : PC = 8 (wake)");
    else
        $display("FAIL : PC (wake)");
    if(core_block.regfile_block.registers[2] == 32'd10)
        $display("PASS : x2 = 10 (wake)");
    else
        $display("FAIL : x2 (wake)");

    // Cycle 4
    @(posedge clk);
    $display("\nCycle 4 (wake)");
    if(core_block.pc == 32'h0000000C)
        $display("PASS : PC = C (wake)");
    else
        $display("FAIL : PC (wake)");
    if(core_block.regfile_block.registers[3] == 32'd15)
        $display("PASS : x3 = 15 (wake)");
    else
        $display("FAIL : x3 (wake)");

    $display("\nBOOT FLOW VERIFICATION (WAKE FROM LOW POWER) COMPLETED\n");

end

endtask

// ---------------------------------------------------------------
// Debug Mode Boot Check
// No dedicated debug module exists - repeated reset pulses simulate debugger halt/resume.
// ---------------------------------------------------------------
task automatic boot_check_debug_mode();

begin

    $display("\n==================================");
    $display("BOOT FLOW VERIFICATION (DEBUG MODE - REPEATED HALT/RESUME)");
    $display("====================================");

    // Simulate 3 debugger halt/resume pulses before final release
    repeat (3) begin
        rst = 1;
        repeat(5) @(posedge clk);
        rst = 0;
        repeat(2) @(posedge clk);   // brief "resume" window, like a single-step
    end

    // Final release for real boot
    rst = 1;
    repeat(5) @(posedge clk);
    rst = 0;

    if(core_block.pc == 32'h00000000)
        $display("PASS : Reset Vector (debug)");
    else
        $display("FAIL : Reset Vector (debug)");

    // Cycle 1
    @(posedge clk);
    $display("\nCycle 1 (debug)");
    if(core_block.pc == 32'h00000000)
        $display("PASS : PC = 0 (debug)");
    else
        $display("FAIL : PC (debug)");
    if(core_block.instruction == 32'h00500093)
        $display("PASS : First Instruction Fetch (debug)");
    else
        $display("FAIL : First Instruction (debug)");

    // Cycle 2
    @(posedge clk);
    $display("\nCycle 2 (debug)");
    if(core_block.pc == 32'h00000004)
        $display("PASS : PC = 4 (debug)");
    else
        $display("FAIL : PC (debug)");
    if(core_block.regfile_block.registers[1] == 32'd5)
        $display("PASS : x1 = 5 (debug)");
    else
        $display("FAIL : x1 (debug)");

    // Cycle 3
    @(posedge clk);
    $display("\nCycle 3 (debug)");
    if(core_block.pc == 32'h00000008)
        $display("PASS : PC = 8 (debug)");
    else
        $display("FAIL : PC (debug)");
    if(core_block.regfile_block.registers[2] == 32'd10)
        $display("PASS : x2 = 10 (debug)");
    else
        $display("FAIL : x2 (debug)");

    // Cycle 4
    @(posedge clk);
    $display("\nCycle 4 (debug)");
    if(core_block.pc == 32'h0000000C)
        $display("PASS : PC = C (debug)");
    else
        $display("FAIL : PC (debug)");
    if(core_block.regfile_block.registers[3] == 32'd15)
        $display("PASS : x3 = 15 (debug)");
    else
        $display("FAIL : x3 (debug)");

    $display("\nBOOT FLOW VERIFICATION (DEBUG MODE) COMPLETED\n");

end

endtask

// ============================================================
// RV32I INSTRUCTION ENCODER
// ============================================================

function automatic [31:0] encode_rv32i(

    input [5:0] instr_type,
    input [4:0] rs1,
    input [4:0] rs2,
    input [4:0] rd,
    input signed [31:0] imm,
    input [19:0] u_imm

);

    reg [31:0] instruction;

    begin

        instruction = 32'h00000013;


        case (instr_type)

            // =================================================
            // R TYPE
            // =================================================

            0: begin
                // ADD
                instruction =
                    {7'b0000000, rs2, rs1,
                     3'b000, rd, 7'b0110011};
            end


            1: begin
                // SUB
                instruction =
                    {7'b0100000, rs2, rs1,
                     3'b000, rd, 7'b0110011};
            end


            2: begin
                // SLL
                instruction =
                    {7'b0000000, rs2, rs1,
                     3'b001, rd, 7'b0110011};
            end


            3: begin
                // SLT
                instruction =
                    {7'b0000000, rs2, rs1,
                     3'b010, rd, 7'b0110011};
            end


            4: begin
                // SLTU
                instruction =
                    {7'b0000000, rs2, rs1,
                     3'b011, rd, 7'b0110011};
            end


            5: begin
                // XOR
                instruction =
                    {7'b0000000, rs2, rs1,
                     3'b100, rd, 7'b0110011};
            end


            6: begin
                // SRL
                instruction =
                    {7'b0000000, rs2, rs1,
                     3'b101, rd, 7'b0110011};
            end


            7: begin
                // SRA
                instruction =
                    {7'b0100000, rs2, rs1,
                     3'b101, rd, 7'b0110011};
            end


            8: begin
                // OR
                instruction =
                    {7'b0000000, rs2, rs1,
                     3'b110, rd, 7'b0110011};
            end


            9: begin
                // AND
                instruction =
                    {7'b0000000, rs2, rs1,
                     3'b111, rd, 7'b0110011};
            end


            // =================================================
            // I TYPE ALU
            // =================================================

            10: begin
                // ADDI
                instruction =
                    {imm[11:0], rs1,
                     3'b000, rd, 7'b0010011};
            end


            11: begin
                // SLTI
                instruction =
                    {imm[11:0], rs1,
                     3'b010, rd, 7'b0010011};
            end


            12: begin
                // SLTIU
                instruction =
                    {imm[11:0], rs1,
                     3'b011, rd, 7'b0010011};
            end


            13: begin
                // XORI
                instruction =
                    {imm[11:0], rs1,
                     3'b100, rd, 7'b0010011};
            end


            14: begin
                // ORI
                instruction =
                    {imm[11:0], rs1,
                     3'b110, rd, 7'b0010011};
            end


            15: begin
                // ANDI
                instruction =
                    {imm[11:0], rs1,
                     3'b111, rd, 7'b0010011};
            end


            16: begin
                // SLLI
                instruction =
                    {7'b0000000, imm[4:0],
                     rs1, 3'b001, rd, 7'b0010011};
            end


            17: begin
                // SRLI
                instruction =
                    {7'b0000000, imm[4:0],
                     rs1, 3'b101, rd, 7'b0010011};
            end


            18: begin
                // SRAI
                instruction =
                    {7'b0100000, imm[4:0],
                     rs1, 3'b101, rd, 7'b0010011};
            end


            // =================================================
            // LOADS
            // =================================================

            19: begin
                // LB
                instruction =
                    {imm[11:0], rs1,
                     3'b000, rd, 7'b0000011};
            end


            20: begin
                // LH
                instruction =
                    {imm[11:0], rs1,
                     3'b001, rd, 7'b0000011};
            end


            21: begin
                // LW
                instruction =
                    {imm[11:0], rs1,
                     3'b010, rd, 7'b0000011};
            end


            22: begin
                // LBU
                instruction =
                    {imm[11:0], rs1,
                     3'b100, rd, 7'b0000011};
            end


            23: begin
                // LHU
                instruction =
                    {imm[11:0], rs1,
                     3'b101, rd, 7'b0000011};
            end


            // =================================================
            // STORES
            // =================================================

            24: begin
                // SB
                instruction = {
                    imm[11:5],
                    rs2,
                    rs1,
                    3'b000,
                    imm[4:0],
                    7'b0100011
                };
            end


            25: begin
                // SH
                instruction = {
                    imm[11:5],
                    rs2,
                    rs1,
                    3'b001,
                    imm[4:0],
                    7'b0100011
                };
            end


            26: begin
                // SW
                instruction = {
                    imm[11:5],
                    rs2,
                    rs1,
                    3'b010,
                    imm[4:0],
                    7'b0100011
                };
            end


            // =================================================
            // BRANCHES
            // =================================================

            27: begin
                // BEQ
                instruction = {
                    imm[12],
                    imm[10:5],
                    rs2,
                    rs1,
                    3'b000,
                    imm[4:1],
                    imm[11],
                    7'b1100011
                };
            end


            28: begin
                // BNE
                instruction = {
                    imm[12],
                    imm[10:5],
                    rs2,
                    rs1,
                    3'b001,
                    imm[4:1],
                    imm[11],
                    7'b1100011
                };
            end


            29: begin
                // BLT
                instruction = {
                    imm[12],
                    imm[10:5],
                    rs2,
                    rs1,
                    3'b100,
                    imm[4:1],
                    imm[11],
                    7'b1100011
                };
            end


            30: begin
                // BGE
                instruction = {
                    imm[12],
                    imm[10:5],
                    rs2,
                    rs1,
                    3'b101,
                    imm[4:1],
                    imm[11],
                    7'b1100011
                };
            end


            31: begin
                // BLTU
                instruction = {
                    imm[12],
                    imm[10:5],
                    rs2,
                    rs1,
                    3'b110,
                    imm[4:1],
                    imm[11],
                    7'b1100011
                };
            end


            32: begin
                // BGEU
                instruction = {
                    imm[12],
                    imm[10:5],
                    rs2,
                    rs1,
                    3'b111,
                    imm[4:1],
                    imm[11],
                    7'b1100011
                };
            end


            // =================================================
            // JAL
            // =================================================

            33: begin

                instruction = {
                    imm[20],
                    imm[10:1],
                    imm[11],
                    imm[19:12],
                    rd,
                    7'b1101111
                };

            end


            // =================================================
            // JALR
            // =================================================

            34: begin

                instruction = {
                    imm[11:0],
                    rs1,
                    3'b000,
                    rd,
                    7'b1100111
                };

            end


            // =================================================
            // LUI
            // =================================================

            35: begin

                instruction = {
                    u_imm,
                    rd,
                    7'b0110111
                };

            end


            // =================================================
            // AUIPC
            // =================================================

            36: begin

                instruction = {
                    u_imm,
                    rd,
                    7'b0010111
                };

            end


            default:
                instruction = 32'h00000013;

        endcase


        encode_rv32i = instruction;

    end

endfunction
    // ============================================================
// INSTRUCTION NAME
// ============================================================

function automatic string rv32i_name(input [5:0] t);

    case (t)

        0:  rv32i_name = "ADD";
        1:  rv32i_name = "SUB";
        2:  rv32i_name = "SLL";
        3:  rv32i_name = "SLT";
        4:  rv32i_name = "SLTU";
        5:  rv32i_name = "XOR";
        6:  rv32i_name = "SRL";
        7:  rv32i_name = "SRA";
        8:  rv32i_name = "OR";
        9:  rv32i_name = "AND";

        10: rv32i_name = "ADDI";
        11: rv32i_name = "SLTI";
        12: rv32i_name = "SLTIU";
        13: rv32i_name = "XORI";
        14: rv32i_name = "ORI";
        15: rv32i_name = "ANDI";
        16: rv32i_name = "SLLI";
        17: rv32i_name = "SRLI";
        18: rv32i_name = "SRAI";

        19: rv32i_name = "LB";
        20: rv32i_name = "LH";
        21: rv32i_name = "LW";
        22: rv32i_name = "LBU";
        23: rv32i_name = "LHU";

        24: rv32i_name = "SB";
        25: rv32i_name = "SH";
        26: rv32i_name = "SW";

        27: rv32i_name = "BEQ";
        28: rv32i_name = "BNE";
        29: rv32i_name = "BLT";
        30: rv32i_name = "BGE";
        31: rv32i_name = "BLTU";
        32: rv32i_name = "BGEU";

        33: rv32i_name = "JAL";
        34: rv32i_name = "JALR";

        35: rv32i_name = "LUI";
        36: rv32i_name = "AUIPC";

        default:
            rv32i_name = "UNKNOWN";

    endcase

endfunction
    // ============================================================
// ALU REFERENCE MODEL
// ============================================================

function automatic [31:0] expected_alu_result(

    input [5:0] t,
    input [31:0] a,
    input [31:0] b,
    input signed [31:0] imm

);

    begin

        case (t)

            // R-type

            0:
                expected_alu_result = a + b;

            1:
                expected_alu_result = a - b;

            2:
                expected_alu_result = a << b[4:0];

            3:
                expected_alu_result =
                    ($signed(a) < $signed(b)) ?
                    32'd1 : 32'd0;

            4:
                expected_alu_result =
                    (a < b) ?
                    32'd1 : 32'd0;

            5:
                expected_alu_result = a ^ b;

            6:
                expected_alu_result = a >> b[4:0];

            7:
                expected_alu_result =
                    $signed(a) >>> b[4:0];

            8:
                expected_alu_result = a | b;

            9:
                expected_alu_result = a & b;


            // I-type

            10:
                expected_alu_result = a + imm;

            11:
                expected_alu_result =
                    ($signed(a) < $signed(imm)) ?
                    32'd1 : 32'd0;

            12:
                expected_alu_result =
                    (a < $unsigned(imm)) ?
                    32'd1 : 32'd0;

            13:
                expected_alu_result = a ^ imm;

            14:
                expected_alu_result = a | imm;

            15:
                expected_alu_result = a & imm;

            16:
                expected_alu_result = a << imm[4:0];

            17:
                expected_alu_result = a >> imm[4:0];

            18:
                expected_alu_result =
                    $signed(a) >>> imm[4:0];

            default:
                expected_alu_result = 32'd0;

        endcase

    end

endfunction

class rv32i_transaction;

    // ---------------- randomized fields ----------------
    rand int unsigned        instr_type;
    rand logic [4:0]         rs1, rs2, rd;
    rand logic signed [11:0] imm;
    rand logic [19:0]        u_imm;
    rand logic [31:0]        rs1_val, rs2_val;
    rand bit                 force_equal;

    // ---------------- coverage sample vars ----------------
    bit taken;
    bit rs_equal;
    bit rd_zero;

    // 0-9 R | 10-18 I-ALU | 19-23 loads | 24-26 stores
    // 27-32 branches | 33 JAL | 34 JALR | 35 LUI | 36 AUIPC
    constraint c_type { instr_type inside {[0:36]}; }

    // rd = x0 about 5% of the time to test that writes to x0 are ignored
    constraint c_rd { rd dist {0 := 1, [1:31] :/ 19}; }

    // Loads, stores and JALR use x0 as base so the target address is known
    constraint c_base {
        if (instr_type inside {[19:26], 34}) rs1 == 0;
    }

    constraint c_imm {

    // Normal I-type ALU
    if (instr_type inside {[10:15]})
        imm inside {[-2048:2047]};

    // Shift immediate
    else if (instr_type inside {[16:18]})
        imm inside {[0:31]};

    // Loads
    else if (instr_type inside {[19:23]})
        imm == 0;

    // Stores
    else if (instr_type inside {[24:26]})
        imm == 0;

    // Branches
    else if (instr_type inside {[27:32]})
        imm inside {[4:252]};

    // JAL
    else if (instr_type == 33)
        imm inside {[4:252]};

    // JALR
    else if (instr_type == 34)
        imm inside {[0:252]};

    // LUI / AUIPC
    else
        imm inside {[-2048:2047]};
}

    constraint c_u { u_imm inside {[0:1048575]}; }

    // Corner values matter for SLT/SLTU/SRA/SUB
    constraint c_vals {
        rs1_val dist {32'h00000000 := 1, 32'hFFFFFFFF := 1,
                      32'h80000000 := 1, 32'h7FFFFFFF := 1,
                      [32'h0:32'hFFFFFFFF] :/ 6};
        rs2_val dist {32'h00000000 := 1, 32'hFFFFFFFF := 1,
                      32'h80000000 := 1, 32'h7FFFFFFF := 1,
                      [32'h0:32'hFFFFFFFF] :/ 6};

        // x0 is always zero
        if (rs1 == 0) rs1_val == 32'h0;
        if (rs2 == 0) rs2_val == 32'h0;

        // Same register index must hold the same value
        if (rs1 == rs2) rs1_val == rs2_val;

        // Make BEQ/BGE/BGEU taken often
        if (force_equal) rs1_val == rs2_val;
    }

    constraint c_eq { force_equal dist {0 := 1, 1 := 1}; }

            function void post_randomize();
        int r1, r2;

        // 4-byte alignment for loads, stores, branches, JAL and JALR
        if (instr_type inside {[19:34]})
            imm[1:0] = 2'b00;

        // Inject corner values (about 40% of the time each), because XSim
        // does not honor the dist weights on rs1_val / rs2_val
        r1 = $urandom_range(0, 9);
        r2 = $urandom_range(0, 9);
        case (r1)
            0: rs1_val = 32'h00000000;
            1: rs1_val = 32'hFFFFFFFF;
            2: rs1_val = 32'h80000000;
            3: rs1_val = 32'h7FFFFFFF;
            default: ;
        endcase
        case (r2)
            0: rs2_val = 32'h00000000;
            1: rs2_val = 32'hFFFFFFFF;
            2: rs2_val = 32'h80000000;
            3: rs2_val = 32'h7FFFFFFF;
            default: ;
        endcase

        // Make operands equal when requested
        if (force_equal) begin
            if      (rs1 == 0) rs2_val = 32'h0;
            else if (rs2 == 0) rs1_val = 32'h0;
            else               rs2_val = rs1_val;
        end

        // x0 always reads as zero
        if (rs1 == 0) rs1_val = 32'h0;
        if (rs2 == 0) rs2_val = 32'h0;

        // Same register index must hold the same value
        if (rs1 == rs2) rs2_val = rs1_val;

        rs_equal = (rs1_val == rs2_val);
        rd_zero  = (rd == 0);
    endfunction

    // ---------------- functional coverage ----------------
    covergroup cg;
        cp_type  : coverpoint instr_type { bins t[] = {[0:36]}; }
        cp_br    : coverpoint instr_type { bins br[] = {[27:32]}; }
        cp_taken : coverpoint taken;
        cp_eq    : coverpoint rs_equal;
        cp_rd0   : coverpoint rd_zero;
        cp_rs1   : coverpoint rs1_val {
            bins zero   = {32'h00000000};
            bins ones   = {32'hFFFFFFFF};
            bins minint = {32'h80000000};
            bins maxint = {32'h7FFFFFFF};
            bins other  = default;
        }
        x_br_taken : cross cp_br, cp_taken;
        x_br_eq    : cross cp_br, cp_eq;
    endgroup

    function new();
        cg = new();
    endfunction

endclass


// ============================================================
// CONSTRAINT-RANDOM RV32I TEST
//
// One check per test covering:
//   - PC after the instruction
//   - all 32 registers (rd gets the result, everything else unchanged,
//     x0 stays 0)
//   - dmem[0..15] (only the store target changes)
// ============================================================

task automatic constraint_random_rv32i_test();

    rv32i_transaction tr;

    logic        [31:0] instruction;
    logic        [31:0] actual_rs1, actual_rs2;
    logic        [31:0] expected, expected_pc, new_word;
    logic signed [31:0] imm32;

    logic [31:0] reg_snap [32];
    logic [31:0] exp_regs [32];
    logic [31:0] mem_snap [16];
    logic [31:0] exp_mem  [16];

    int  widx;
    bit  taken;
    bit  writes_rd;
    bit  test_ok;
    int  pass_count;
    int  fail_count;
    int  fail_by_type [37];

    tr         = new();
    pass_count = 0;
    fail_count = 0;
        foreach (fail_by_type[i]) fail_by_type[i] = 0;

    $display("");
    $display("======================================================");
    $display("       CONSTRAINT-RANDOM RV32I TEST (1000 tests)");
    $display("       Constraint-random testing started");
    $display("======================================================");

    for (int test = 0; test < 1000; test++) begin

        // ---------------------------------------------------
        // Randomize
        // ---------------------------------------------------
        if (!tr.randomize()) begin
            $display("[FAIL] Randomization failed at Test=%0d", test);
            fail_count++;
            continue;
        end

        actual_rs1 = tr.rs1_val;
        actual_rs2 = tr.rs2_val;
        imm32      = tr.imm;            // proper sign extension to 32 bits

        instruction = encode_rv32i(tr.instr_type, tr.rs1, tr.rs2,
                                   tr.rd, imm32, tr.u_imm);

        // ---------------------------------------------------
        // Reset, then release and initialize in the SAME timestep.
        // The next posedge executes exactly the instruction at PC=0.
        // ---------------------------------------------------
        rst = 1'b1;
        repeat (5) @(posedge clk);
        #1;
        rst = 1'b0;

        // Registers: random everywhere so stray writes are detectable
        core_block.regfile_block.registers[0] = 32'd0;
        for (int i = 1; i < 32; i++)
            core_block.regfile_block.registers[i] = $urandom;

        if (tr.rs1 != 0)
            core_block.regfile_block.registers[tr.rs1] = tr.rs1_val;
        if (tr.rs2 != 0)
            core_block.regfile_block.registers[tr.rs2] = tr.rs2_val;

        // Data memory: random words 0..15
        for (int i = 0; i < 16; i++)
            core_block.dmem_block.memory[i] = $urandom;

        // Program: random instruction at 0, NOPs everywhere a jump can land
        core_block.imem_block.mem[0] = instruction;
        for (int i = 1; i < 40; i++)
            core_block.imem_block.mem[i] = 32'h00000013;

        // Snapshots after initialization
        for (int i = 0; i < 32; i++) begin
            reg_snap[i] = core_block.regfile_block.registers[i];
            exp_regs[i] = reg_snap[i];
        end
        for (int i = 0; i < 16; i++) begin
            mem_snap[i] = core_block.dmem_block.memory[i];
            exp_mem[i]  = mem_snap[i];
        end

        // ---------------------------------------------------
        // Expected values
        // ---------------------------------------------------
        expected    = 32'd0;
        expected_pc = 32'd4;
        taken       = 1'b0;
        writes_rd   = 1'b0;
        widx        = 0;

        // R-type / I-type ALU
        if (tr.instr_type <= 18) begin
            expected  = expected_alu_result(tr.instr_type, actual_rs1,
                                            actual_rs2, imm32);
            writes_rd = 1'b1;
        end

        // Loads (rs1 = x0, imm word-aligned, so byte 0 of the word)
        else if (tr.instr_type <= 23) begin
            widx = imm32[5:2];
            case (tr.instr_type)
                19: expected = {{24{mem_snap[widx][7]}},  mem_snap[widx][7:0]};
                20: expected = {{16{mem_snap[widx][15]}}, mem_snap[widx][15:0]};
                21: expected = mem_snap[widx];
                22: expected = {24'b0, mem_snap[widx][7:0]};
                23: expected = {16'b0, mem_snap[widx][15:0]};
            endcase
            writes_rd = 1'b1;
        end

        // Stores: merge into the old word
        else if (tr.instr_type <= 26) begin
            widx = imm32[5:2];
            case (tr.instr_type)
                24: new_word = {mem_snap[widx][31:8],  actual_rs2[7:0]};
                25: new_word = {mem_snap[widx][31:16], actual_rs2[15:0]};
                26: new_word = actual_rs2;
            endcase
            exp_mem[widx] = new_word;
        end

        // Branches
        else if (tr.instr_type <= 32) begin
            case (tr.instr_type)
                27: taken = (actual_rs1 == actual_rs2);
                28: taken = (actual_rs1 != actual_rs2);
                29: taken = ($signed(actual_rs1) <  $signed(actual_rs2));
                30: taken = ($signed(actual_rs1) >= $signed(actual_rs2));
                31: taken = (actual_rs1 <  actual_rs2);
                32: taken = (actual_rs1 >= actual_rs2);
            endcase
            expected_pc = taken ? imm32 : 32'd4;
        end

        // JAL (PC = 0, so target = imm)
        else if (tr.instr_type == 33) begin
            expected    = 32'd4;
            expected_pc = imm32;
            writes_rd   = 1'b1;
        end

        // JALR (rs1 = x0)
        else if (tr.instr_type == 34) begin
            expected    = 32'd4;
            expected_pc = (actual_rs1 + imm32) & 32'hFFFFFFFE;
            writes_rd   = 1'b1;
        end

        // LUI
        else if (tr.instr_type == 35) begin
            expected  = {tr.u_imm, 12'b0};
            writes_rd = 1'b1;
        end

        // AUIPC (PC = 0)
        else if (tr.instr_type == 36) begin
            expected  = {tr.u_imm, 12'b0};
            writes_rd = 1'b1;
        end

        // Writes to x0 must be ignored
        if (writes_rd && tr.rd != 0)
            exp_regs[tr.rd] = expected;

        // ---------------------------------------------------
        // Execute one instruction
        // ---------------------------------------------------
        @(posedge clk);
        #1;

        // ---------------------------------------------------
        // Compare PC, all registers, and dmem
        // ---------------------------------------------------
        test_ok = 1'b1;

        if (core_block.pc !== expected_pc) begin
            $display("[FAIL] Test=%0d | %-5s | PC Expected=%h Actual=%h",
                     test, rv32i_name(tr.instr_type),
                     expected_pc, core_block.pc);
            test_ok = 1'b0;
        end

        for (int i = 0; i < 32; i++) begin
            if (core_block.regfile_block.registers[i] !== exp_regs[i]) begin
                $display("[FAIL] Test=%0d | %-5s | x%0d Expected=%h Actual=%h (rd=x%0d rs1=x%0d rs2=x%0d imm=%0d)",
                         test, rv32i_name(tr.instr_type), i,
                         exp_regs[i],
                         core_block.regfile_block.registers[i],
                         tr.rd, tr.rs1, tr.rs2, imm32);
                test_ok = 1'b0;
            end
        end

        for (int i = 0; i < 16; i++) begin
            if (core_block.dmem_block.memory[i] !== exp_mem[i]) begin
                $display("[FAIL] Test=%0d | %-5s | dmem[%0d] Expected=%h Actual=%h",
                         test, rv32i_name(tr.instr_type), i,
                         exp_mem[i], core_block.dmem_block.memory[i]);
                test_ok = 1'b0;
            end
        end

                if (test_ok) begin
            pass_count++;
        end
        else begin
            fail_count++;
            fail_by_type[tr.instr_type]++;
        end

        // ---------------------------------------------------
        // Coverage
        // ---------------------------------------------------
        tr.taken = taken;
        tr.cg.sample();

    end

    // =========================================================
    // Summary
    // =========================================================
    $display("");
    $display("======================================================");
    $display("       CONSTRAINT-RANDOM TEST COMPLETED");
    $display("======================================================");
        $display("---- Failures by instruction type ----");
    for (int i = 0; i < 37; i++)
        if (fail_by_type[i] != 0)
            $display("%-5s failed %0d times", rv32i_name(i), fail_by_type[i]);
    $display("--------------------------------------");
    $display("TOTAL TESTS  = 1000");
    $display("PASSED       = %0d", pass_count);
    $display("FAILED       = %0d", fail_count);
    $display("COVERAGE     = %0.2f%%", tr.cg.get_inst_coverage());
    $display("======================================================");

endtask

//main block
initial begin

load_program();
connectivity_check();
check_clock();
check_reset();
boot_check();
check_reset();
boot_check_lowpower_wake();
check_reset();
boot_check_debug_mode();




repeat(40)
@(posedge clk);

check_results(); 
verbose = 0;
constraint_random_rv32i_test();
$finish;
