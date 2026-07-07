class rv32i_seq_item extends uvm_sequence_item;

  `uvm_object_utils(rv32i_seq_item)
  
  //standard constructor
  function new(string name = "rv32i_seq_item",uvm_component parent);
  
    super.new(name,parent);
    `uvm_info("seq_item class","Constructor",UVM_MEDIUM)
    
  endfunction
  
endclass
