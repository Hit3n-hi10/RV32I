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

always@(posedge clk) begin
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
   task automatic connectivity_check();

begin

    $display("MODULE CONNECTIVITY CHECK");

    @(posedge clk);

    // Instruction Memory
    if(core_block.instruction == 32'h00500093)
        $display("PASS : Instruction Memory");
    else
        $display("FAIL : Instruction Memory");

    // Decoder
    if(core_block.opcode == 7'b0010011 &&
       core_block.rs1_addr == 5'd0 &&
       core_block.rd_addr  == 5'd1)
        $display("PASS : Decoder");
    else
        $display("FAIL : Decoder");

    // Control Unit
    if(core_block.RegWrite  == 1'b1 &&
       core_block.ALUSrc    == 1'b1 &&
       core_block.MemRead   == 1'b0 &&
       core_block.MemWrite  == 1'b0 &&
       core_block.Branch    == 1'b0 &&
       core_block.Jump      == 1'b0 &&
       core_block.ALUOp     == 2'b10)
        $display("PASS : Control Unit");
    else
        $display("FAIL : Control Unit");

    // Immediate Generator
    if(core_block.immediate == 32'd5)
        $display("PASS : Immediate Generator");
    else
        $display("FAIL : Immediate Generator");

    // ALU Control
    if(core_block.alu_op == 4'b0000)
        $display("PASS : ALU Control");
    else
        $display("FAIL : ALU Control");

    // Register File Read
    if(core_block.rs1_data == 32'd0)
        $display("PASS : Register File Read");
    else
        $display("FAIL : Register File Read");

    // ALU Input
    if(core_block.alu_B == 32'd5)
        $display("PASS : ALU Input");
    else
        $display("FAIL : ALU Input");

    // ALU
    if(core_block.alu_result == 32'd5)
        $display("PASS : ALU");
    else
        $display("FAIL : ALU");

    @(posedge clk);

    // Register File Writeback
    if(core_block.regfile_block.registers[1] == 32'd5)
        $display("PASS : Register File Writeback");
    else
        $display("FAIL : Register File Writeback");

    $display("MODULE CONNECTIVITY VERIFIED");

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
class rv32i_transaction;

    // =========================================================
    // Randomized fields
    // =========================================================

    rand int unsigned instr_type;

    rand logic [4:0] rs1;
    rand logic [4:0] rs2;
    rand logic [4:0] rd;

    rand logic signed [11:0] imm;
    rand logic [19:0] u_imm;


    // =========================================================
    // Instruction type
    //
    // 0-9   : R-type
    // 10-18 : I-type ALU
    // 19-23 : Loads
    // 24-26 : Stores
    // 27-32 : Branches
    // 33    : JAL
    // 34    : JALR
    // 35    : LUI
    // 36    : AUIPC
    // =========================================================

    constraint valid_instr_type {
        instr_type inside {[0:36]};
    }


    // =========================================================
    // Register constraints
    // =========================================================

    constraint valid_registers {

        rs1 inside {[0:31]};
        rs2 inside {[0:31]};

        // rd = 1 to 31
        // This avoids writing to x0.
        rd inside {[1:31]};
    }


    // =========================================================
    // Immediate constraints
    // =========================================================

    constraint valid_immediate {

        // -----------------------------------------
        // I-type ALU instructions
        // ADDI, SLTI, SLTIU, XORI, ORI, ANDI
        // -----------------------------------------
        if (instr_type inside {[10:15]})
            imm inside {[-2048:2047]};


        // -----------------------------------------
        // Shift immediate instructions
        // SLLI, SRLI, SRAI
        //
        // RV32I shift amount = 5 bits
        // -----------------------------------------
        else if (instr_type inside {[16:18]})
            imm inside {[0:31]};


        // -----------------------------------------
        // Loads
        // LB, LH, LW, LBU, LHU
        // -----------------------------------------
        else if (instr_type inside {[19:23]})
            imm inside {[-128:128]};


        // -----------------------------------------
        // Stores
        // SB, SH, SW
        // -----------------------------------------
        else if (instr_type inside {[24:26]})
            imm inside {[-128:128]};


        // -----------------------------------------
        // Branches
        // BEQ, BNE, BLT, BGE, BLTU, BGEU
        //
        // Branch offset must be aligned to 2 bytes.
        // -----------------------------------------
        else if (instr_type inside {[27:32]})
            imm inside {[-128:-2], [2:128]};


        // -----------------------------------------
        // JAL
        //
        // JAL immediate is 21-bit signed,
        // but we keep the random range small
        // for your current instruction-memory setup.
        // -----------------------------------------
        else if (instr_type == 33)
            imm inside {[-128:-2], [2:128]};


        // -----------------------------------------
        // JALR
        //
        // Immediate is a signed 12-bit value.
        // -----------------------------------------
        else if (instr_type == 34)
            imm inside {[-128:128]};


        // -----------------------------------------
        // LUI / AUIPC
        // -----------------------------------------
        else
            imm inside {[-2048:2047]};
    }


    // =========================================================
    // U-type immediate
    // =========================================================

    constraint valid_u_immediate {
        u_imm inside {[0:1048575]};
    }


endclass
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
// ============================================================
// CORRECTED CONSTRAINT-RANDOM RV32I TEST
// ============================================================

task automatic constraint_random_rv32i_test();

    rv32i_transaction tr;

    reg [31:0] instruction;

    reg [31:0] rs1_value;
    reg [31:0] rs2_value;

    // Actual values seen by the DUT
    reg [31:0] actual_rs1;
    reg [31:0] actual_rs2;

    reg [31:0] expected;
    reg [31:0] actual;

    reg [31:0] expected_pc;
    reg [31:0] old_memory;

    integer pass_count;
    integer fail_count;

    tr = new();

    pass_count = 0;
    fail_count = 0;

    $display("");
    $display("======================================================");
    $display("       CONSTRAINT-RANDOM RV32I TEST");
    $display("======================================================");
    $display("       TOTAL TESTS = 1000");
    $display("======================================================");


    // =========================================================
    // 1000 RANDOMIZED TESTS
    // =========================================================

    for (int test = 0; test < 1000; test++) begin

        // -----------------------------------------------------
        // RANDOMIZE TRANSACTION
        // -----------------------------------------------------

        if (!tr.randomize()) begin

            $display(
                "[FAIL] Randomization failed at Test=%0d",
                test
            );

            fail_count++;
            continue;

        end


        // -----------------------------------------------------
        // GENERATE RANDOM SOURCE VALUES
        // -----------------------------------------------------

        rs1_value = $urandom;
        rs2_value = $urandom;


        // -----------------------------------------------------
        // IMPORTANT:
        // x0 MUST ALWAYS BE ZERO
        // -----------------------------------------------------

        actual_rs1 =
            (tr.rs1 == 0) ? 32'd0 : rs1_value;

        actual_rs2 =
            (tr.rs2 == 0) ? 32'd0 : rs2_value;


        // -----------------------------------------------------
        // GENERATE INSTRUCTION
        // -----------------------------------------------------

        instruction =
            encode_rv32i(
                tr.instr_type,
                tr.rs1,
                tr.rs2,
                tr.rd,
                tr.imm,
                tr.u_imm
            );


        // =====================================================
        // RESET FIRST
        // =====================================================

        rst = 1'b1;

        repeat (5)
            @(posedge clk);

        rst = 1'b0;

        // Wait for reset release
        @(posedge clk);


        // =====================================================
        // NOW INITIALIZE RANDOM REGISTERS
        // =====================================================

        // x0 is permanently zero
        core_block.regfile_block.registers[0] = 32'd0;

        if (tr.rs1 != 0)
            core_block.regfile_block.registers[tr.rs1] =
                rs1_value;

        if (tr.rs2 != 0)
            core_block.regfile_block.registers[tr.rs2] =
                rs2_value;


        // =====================================================
        // INITIALIZE DATA MEMORY
        // =====================================================

        old_memory = $urandom;

        core_block.dmem_block.memory[0] =
            old_memory;


        // =====================================================
        // LOAD RANDOM INSTRUCTION AT PC = 0
        // =====================================================

        core_block.imem_block.mem[0] =
            instruction;


        // Put NOPs after the randomized instruction.
        // This prevents JAL/JALR from executing old program data.

        core_block.imem_block.mem[1] =
            32'h00000013;

        core_block.imem_block.mem[2] =
            32'h00000013;

        core_block.imem_block.mem[3] =
            32'h00000013;

        core_block.imem_block.mem[4] =
            32'h00000013;


        // =====================================================
        // EXPECTED VALUES
        // =====================================================

        expected    = 32'd0;
        expected_pc = 32'd4;


        // =====================================================
        // R-TYPE / I-TYPE ALU
        // =====================================================

        if (tr.instr_type <= 18) begin

            expected =
                expected_alu_result(
                    tr.instr_type,
                    actual_rs1,
                    actual_rs2,
                    tr.imm
                );

        end


        // =====================================================
        // LOADS
        // =====================================================

        else if ((tr.instr_type >= 19) &&
                 (tr.instr_type <= 23)) begin

            case (tr.instr_type)

                // LB
                19:
                    expected =
                        {{24{old_memory[7]}},
                         old_memory[7:0]};

                // LH
                20:
                    expected =
                        {{16{old_memory[15]}},
                         old_memory[15:0]};

                // LW
                21:
                    expected = old_memory;

                // LBU
                22:
                    expected =
                        {24'b0, old_memory[7:0]};

                // LHU
                23:
                    expected =
                        {16'b0, old_memory[15:0]};

                default:
                    expected = 32'd0;

            endcase

        end


        // =====================================================
        // STORES
        // =====================================================

        else if ((tr.instr_type >= 24) &&
                 (tr.instr_type <= 26)) begin

            // Expected memory contents are handled below.
            expected = actual_rs2;

        end


        // =====================================================
        // BRANCHES
        // =====================================================

        else if ((tr.instr_type >= 27) &&
                 (tr.instr_type <= 32)) begin

            case (tr.instr_type)

                // BEQ
                27:
                    expected_pc =
                        (actual_rs1 == actual_rs2) ?
                        tr.imm : 32'd4;

                // BNE
                28:
                    expected_pc =
                        (actual_rs1 != actual_rs2) ?
                        tr.imm : 32'd4;

                // BLT
                29:
                    expected_pc =
                        ($signed(actual_rs1) <
                         $signed(actual_rs2)) ?
                        tr.imm : 32'd4;

                // BGE
                30:
                    expected_pc =
                        ($signed(actual_rs1) >=
                         $signed(actual_rs2)) ?
                        tr.imm : 32'd4;

                // BLTU
                31:
                    expected_pc =
                        (actual_rs1 < actual_rs2) ?
                        tr.imm : 32'd4;

                // BGEU
                32:
                    expected_pc =
                        (actual_rs1 >= actual_rs2) ?
                        tr.imm : 32'd4;

                default:
                    expected_pc = 32'd4;

            endcase

        end


        // =====================================================
        // JAL
        // =====================================================

        else if (tr.instr_type == 33) begin

            expected = 32'd4;

            // PC = 0, therefore target = immediate
            expected_pc = tr.imm;

        end


        // =====================================================
        // JALR
        // =====================================================

        else if (tr.instr_type == 34) begin

            // Link address
            expected = 32'd4;

            // rs1 is constrained to x0
            expected_pc =
                tr.imm & 32'hFFFFFFFE;

        end


        // =====================================================
        // LUI
        // =====================================================

        else if (tr.instr_type == 35) begin

            expected =
                {tr.u_imm, 12'b0};

        end


        // =====================================================
        // AUIPC
        // =====================================================

        else if (tr.instr_type == 36) begin

            // PC = 0
            expected =
                {tr.u_imm, 12'b0};

        end


        // =====================================================
        // EXECUTE ONE INSTRUCTION
        // =====================================================

        @(posedge clk);

        #1;


        // =====================================================
        // CHECK REGISTER-WRITING INSTRUCTIONS
        // =====================================================

        if ((tr.instr_type <= 23) ||
            (tr.instr_type == 33) ||
            (tr.instr_type == 34) ||
            (tr.instr_type == 35) ||
            (tr.instr_type == 36)) begin

            actual =
                core_block.regfile_block.registers[tr.rd];


            if (actual === expected) begin

                $display(
                    "[PASS] Test=%0d | %-5s | rd=x%0d | Expected=%h | Actual=%h",
                    test,
                    rv32i_name(tr.instr_type),
                    tr.rd,
                    expected,
                    actual
                );

                pass_count++;

            end
            else begin

                $display(
                    "[FAIL] Test=%0d | %-5s | rd=x%0d | Expected=%h | Actual=%h",
                    test,
                    rv32i_name(tr.instr_type),
                    tr.rd,
                    expected,
                    actual
                );

                fail_count++;

            end

        end


        // =====================================================
        // CHECK STORE
        // =====================================================

        else if ((tr.instr_type >= 24) &&
                 (tr.instr_type <= 26)) begin

            actual =
                core_block.dmem_block.memory[0];


            case (tr.instr_type)

                // -------------------------------------------------
                // SB
                // -------------------------------------------------

                24: begin

                    if (actual[7:0] ==
                        actual_rs2[7:0]) begin

                        $display(
                            "[PASS] Test=%0d | SB | Expected Byte=%h | Actual Byte=%h",
                            test,
                            actual_rs2[7:0],
                            actual[7:0]
                        );

                        pass_count++;

                    end
                    else begin

                        $display(
                            "[FAIL] Test=%0d | SB | Expected Byte=%h | Actual Byte=%h",
                            test,
                            actual_rs2[7:0],
                            actual[7:0]
                        );

                        fail_count++;

                    end

                end


                // -------------------------------------------------
                // SH
                // -------------------------------------------------

                25: begin

                    if (actual[15:0] ==
                        actual_rs2[15:0]) begin

                        $display(
                            "[PASS] Test=%0d | SH | Expected Half=%h | Actual Half=%h",
                            test,
                            actual_rs2[15:0],
                            actual[15:0]
                        );

                        pass_count++;

                    end
                    else begin

                        $display(
                            "[FAIL] Test=%0d | SH | Expected Half=%h | Actual Half=%h",
                            test,
                            actual_rs2[15:0],
                            actual[15:0]
                        );

                        fail_count++;

                    end

                end


                // -------------------------------------------------
                // SW
                // -------------------------------------------------

                26: begin

                    if (actual ==
                        actual_rs2) begin

                        $display(
                            "[PASS] Test=%0d | SW | Expected=%h | Actual=%h",
                            test,
                            actual_rs2,
                            actual
                        );

                        pass_count++;

                    end
                    else begin

                        $display(
                            "[FAIL] Test=%0d | SW | Expected=%h | Actual=%h",
                            test,
                            actual_rs2,
                            actual
                        );

                        fail_count++;

                    end

                end

            endcase

        end


        // =====================================================
        // CHECK BRANCH / JUMP PC
        // =====================================================

        else if ((tr.instr_type >= 27) &&
                 (tr.instr_type <= 34)) begin

            if (core_block.pc === expected_pc) begin

                $display(
                    "[PASS] Test=%0d | %-5s | Expected PC=%h | Actual PC=%h",
                    test,
                    rv32i_name(tr.instr_type),
                    expected_pc,
                    core_block.pc
                );

                pass_count++;

            end
            else begin

                $display(
                    "[FAIL] Test=%0d | %-5s | Expected PC=%h | Actual PC=%h",
                    test,
                    rv32i_name(tr.instr_type),
                    expected_pc,
                    core_block.pc
                );

                fail_count++;

            end

        end

    end


    // =========================================================
    // FINAL SUMMARY
    // =========================================================

    $display("");
    $display("======================================================");
    $display("       CONSTRAINT-RANDOM TEST COMPLETED");
    $display("======================================================");

    $display(
        "TOTAL RANDOM TESTS = 1000"
    );

    $display(
        "PASS CHECKS        = %0d",
        pass_count
    );

    $display(
        "FAIL CHECKS        = %0d",
        fail_count
    );

    $display("======================================================");

endtask
//main block
initial begin

load_program();
check_clock();
check_reset();
boot_check();
check_reset();
boot_check_lowpower_wake();
check_reset();
boot_check_debug_mode();
check_reset();    // re-sync PC back to 0 before connectivity_check
connectivity_check();



repeat(40)
@(posedge clk);

check_results(); 
  constraint_random_rv32i_test();
$finish;

end

endmodule
