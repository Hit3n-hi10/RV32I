module rv32i_top_tb();

logic clk;
logic rst;

rv32i_top core_block(.clk(clk),.rst(rst));

//clock generation
initial begin 
    clk = 0;
    forever #5 clk = ~clk;
end

task reset();
begin 
    rst = 1;
    repeat(5) @(posedge clk);
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

// sw x3,0(x0)
core_block.imem_block.mem[3]  = 32'h00302023;

// lw x4,0(x0)
core_block.imem_block.mem[4]  = 32'h00002203;

// beq x3,x4,+8
core_block.imem_block.mem[5]  = 32'h00418463;

// addi x5,x0,99   (should be skipped)
core_block.imem_block.mem[6]  = 32'h06300293;

// addi x5,x0,1
core_block.imem_block.mem[7]  = 32'h00100293;

// jal x6,+8
core_block.imem_block.mem[8]  = 32'h0080036F;

// addi x7,x0,99   (should be skipped)
core_block.imem_block.mem[9]  = 32'h06300393;

// addi x7,x0,7
core_block.imem_block.mem[10] = 32'h00700393;
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

if(core_block.regfile_block.registers[6] == 32'h24)
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

end
endtask

//main block
initial begin

load_program();
reset();

repeat(40)
@(posedge clk);

check_results();
$finish;

end

endmodule
