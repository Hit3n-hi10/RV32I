
`timescale 1ns/1ns

`include "uvm_macros.svh" 
import uvm_pkg::*;

`include "interface.sv"
`include "rv32i_mon_item.sv"
`include "seq_item.sv"
`include "sequence.sv"
`include "sequencer.sv"
`include "driver.sv"
`include "monitor.sv"
`include "agent.sv"
`include "predictor.sv"
`include "scoreboard.sv"
`include "environment.sv"
`include "test.sv"

module top();
  
  logic clk;
  logic rst;
  
   rv32i_intf intf(.clk(clk));
  
  rv32i_top dut(.clk(intf.clk),.rst(intf.rst));
  
 initial begin
   uvm_config_db#(virtual rv32i_intf)::set(null,"*","vif",intf);
 end
  initial begin
  clk=0;
   // rst = 1;
   // #20;
   // rst=0;
  end
  always #10 clk = ~clk;
  
  initial begin
    $monitor("$time","Clk = %d",clk);
    //$dumpfile("dump.vcd"); 
    //$dumpvars;
    //#100 $finish;
  end
  
  initial begin
    run_test("rv32i_test");
  end
  
endmodule
