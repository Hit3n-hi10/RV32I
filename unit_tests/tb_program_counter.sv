//TEST BENCH
`timescale 1ns / 1ps
module tb_program_counter;
 logic        clk;
 logic        rst;
 logic [31:0] next_pc;
 logic [31:0] pc;

 program_counter uut (
 .clk     (clk),
 .rst     (rst),
 .next_pc (next_pc),
 .pc      (pc)
    );

  initial 
   begin
    clk = 0;
    forever #5 clk = ~clk;
   end

  initial 
   begin
   $dumpfile("dump.vcd");
   $dumpvars(0, tb_program_counter);
    rst     = 1'b0;
    next_pc = 32'h0000_0000;

   $monitor("Time = %0dt | rst = %b | next_pc = %h | pc = %h", $time, rst, next_pc, pc);

  #2;
  rst = 1'b1;        
  #10;
  rst = 1'b0;        

 @(posedge clk);
   next_pc = 32'h0000_0004;

  @(posedge clk);
   next_pc = 32'h0000_0008;

 @(posedge clk);
    next_pc = 32'h0000_000C;
 #3;              
  rst = 1'b1;        
   #2;
  rst = 1'b0;
 @(posedge clk);
    next_pc = 32'hAFFF_0000;
 @(posedge clk);
   #5;
 $finish;
    end
endmodule
