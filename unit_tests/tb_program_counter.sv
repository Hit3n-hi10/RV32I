//TEST BENCH 
`timescale 1ns / 1ps
module tb_program_counter;
 logic        clk;
 logic        rst_n;    
 logic [31:0] next_pc;
 logic [31:0] pc;

 program_counter uut (
 .clk     (clk),
 .rst_n   (rst_n),  
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
    rst_n   = 1'b1;     
    next_pc = 32'h0000_0000;

    $monitor("Time = %0dt | rst_n = %b | next_pc = %h | pc = %h", $time, rst_n, next_pc, pc);
//CASE 1:Asynchronous active low reset
  #2;
  rst_n = 1'b0;        
  #10;
  rst_n = 1'b1;        
    //CASE 2:Sequential Increments (PC+4)
 @(posedge clk);
   next_pc = 32'h0000_0004;

  @(posedge clk);
   next_pc = 32'h0000_0008;

 @(posedge clk);
    next_pc = 32'h0000_000C;
    //Case 3:Mid cycle Reset override interrupt
 #3;              
  rst_n = 1'b0;        
   #2;
  rst_n = 1'b1;
    //Case 4:Branch Long jump target updates
 @(posedge clk);
    next_pc = 32'hAFFF_0000;
 @(posedge clk);
    #5;
 $finish;
    end
endmodule
