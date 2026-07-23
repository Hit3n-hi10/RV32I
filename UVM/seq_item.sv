
class rv32i_seq_item extends uvm_sequence_item;

  `uvm_object_utils(rv32i_seq_item) 
 
  
  bit [31:0] instr[$];
  
  
  
  //standard constructor
  function new(string name = "rv32i_seq_item");
  
    super.new(name);
    `uvm_info("seq_item class","Constructor",UVM_MEDIUM)
    
  endfunction
  
endclass
