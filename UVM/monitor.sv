class rv32i_monitor extends uvm_monitor;
  
  `uvm_component_utils(rv32i_monitor)
  
  uvm_analysis_port #(rv32i_mon_item) item_collected_port;
  virtual rv32i_intf intf;
  rv32i_mon_item item;
  
  
  //standard constructor
  function new (string name = "rv32i_monitor",uvm_component parent);
  
    super.new(name,parent);
    `uvm_info("Monitor Class","Constructor",UVM_MEDIUM)
    
  endfunction
  
  //build phase
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    item_collected_port = new("item_collected_port",this);
    
    if(!uvm_config_db#(virtual rv32i_intf)::get(this,"","vif",intf))
       `uvm_fatal("no intf in driver","virtual interface get failed from config db");
  endfunction
  
  //run phase
  task run_phase(uvm_phase phase);
  	forever begin
      @(posedge intf.clk);
      
       `uvm_info("MON_PC",
      $sformatf("RST=%0b  PC=%08h  INST=%08h",
                intf.rst,
                top.dut.pc,
                top.dut.instruction),
      UVM_LOW)
      
      if(intf.rst)
        continue;
      item = rv32i_mon_item::type_id::create("item");
      
      item.pc = top.dut.pc;
      item.instruction = top.dut.instruction;
      
      item.reg_write = top.dut.RegWrite;
      item.rd = top.dut.rd_addr;
      item.rd_data = top.dut.write_back_data;
      
      item.mem_write = top.dut.MemWrite;
      item.mem_addr = top.dut.alu_result;
      item.mem_data = top.dut.rs2_data;
      item.branch_taken = top.dut.brh_taken;
      
      item.jump_taken = top.dut.jump_taken;
      item.link_addr = top.dut.link_addr;
      item.illegal_instr = top.dut.illegal_instr;
      
      `uvm_info(get_type_name(),
                $sformatf("PC=%08h INST=%08h DATA=%08h MDATA=%08h",
item.pc,
item.instruction,
item.rd_data,
item.mem_data),
UVM_MEDIUM)
      
    if(item.instruction[6:0] == 7'b1100011) begin
    $display("\n========== BRANCH DEBUG ==========");
    $display("PC           = %h", item.pc);
    $display("Instruction  = %h", item.instruction);
    $display("branch_taken = %b", item.branch_taken);

      $display("x5 = %h", top.dut.regfile_block.registers[5]);
      $display("x8 = %h", top.dut.regfile_block.registers[8]);

    $display("=================================\n");
end

      
      item_collected_port.write(item);
    end
  
  endtask
  
endclass
