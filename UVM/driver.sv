
class rv32i_driver extends uvm_driver#(rv32i_seq_item);
  
  `uvm_component_utils(rv32i_driver)
  
  virtual rv32i_intf intf;
  rv32i_seq_item tx;
  
  //standard constructor
  function new(string name = "rv32i_driver",uvm_component parent);
  
    super.new(name,parent);
    `uvm_info("Driver Class","Constructor",UVM_MEDIUM)
    
  endfunction
  
  //build phase
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    
    if(!uvm_config_db#(virtual rv32i_intf)::get(this,"","vif",intf))
       `uvm_fatal("no intf in driver","virtual interface get failed from config db");
  endfunction
  
       
       //run phase
       task run_phase(uvm_phase phase);
       		forever begin
              `uvm_info("driver class","run phase",UVM_MEDIUM)
              seq_item_port.get_next_item(tx);
             // clear_imem();
              load_program();
              reset_dut();
             
				@(posedge intf.clk);
              seq_item_port.item_done();
            end
         
       endtask
  
  task reset_dut();
  	intf.rst=1;
    repeat(5) @(posedge intf.clk);
    intf.rst=0;
  endtask
  
//   task clear_imem();

//     for(int i=0;i<256;i++)
//         top.dut.imem_block.mem[i]=32'h00000013;
//         // NOP (ADDI x0,x0,0)

// endtask
  
  task load_program();
  // Copy queue into instruction memory

    foreach(tx.instr[i])
      top.dut.imem_block.mem[i]=tx.instr[i];
         
       endtask
  
endclass
