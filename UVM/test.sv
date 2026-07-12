class rv32i_test extends uvm_test;
  
  `uvm_component_utils(rv32i_test)
  
  rv32i_env env;
  
  //standard constructor
  function new(string name = "rv32i_test",uvm_component parent);
    super.new(name,parent);
    `uvm_info("Test Class","Constructor",UVM_MEDIUM)
    
  endfunction
  
  //build phase
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    
    env = rv32i_env::type_id::create("env",this);
  endfunction
  
  //connect phase
  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    `uvm_info("Test Class","connect phase",UVM_MEDIUM);
    
  endfunction
  
  //end of elob
  virtual function void end_of_elaboration();
    `uvm_info("Test Class","elab phase",UVM_MEDIUM);
    print();
    
  endfunction
  
endclass
