class rv32i_mon_item extends uvm_sequence_item;
  `uvm_object_utils(rv32i_mon_item);
  
  logic [31:0] pc;
  logic [31:0] instruction;
  
  logic reg_write;
  logic [4:0] rd;
  logic [31:0] rd_data;
  
  logic mem_write;
  logic [31:0] mem_addr;
  logic [31:0] mem_data;
  logic branch_taken;
  
  logic jump_taken;
  logic [31:0] link_addr;
  logic illegal_instr;
  
  //constructor
  function new(string name ="rv32i_mon_item");
    super.new(name);
    `uvm_info("mon_item","constructor",UVM_MEDIUM)
    
  endfunction

endclass
