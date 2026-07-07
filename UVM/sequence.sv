class rv32i_sequence extends uvm_sequence;
  
  `uvm_object_utils(rv32i_sequence)
  
  //standard constructor
  function new(string name = "rv32i_sequence",uvm_component parent);
  
    super.new(name,parent);
    `uvm_info("Sequence Class","Constructor",UVM_MEDIUM)
    
  endfunction
  
endclass
