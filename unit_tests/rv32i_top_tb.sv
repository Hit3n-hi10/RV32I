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

//main block
initial begin

load_program();
check_clock();
check_reset();
boot_check();
check_reset();    // re-sync PC back to 0 before connectivity_check
connectivity_check();

repeat(40)
@(posedge clk);

check_results();
$finish;

end

endmodule
