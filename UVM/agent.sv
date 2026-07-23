class rv32i_agent extends uvm_agent;

  `uvm_component_utils(rv32i_agent)
  
  rv32i_driver drv;
  rv32i_monitor mon;
  rv32i_sequencer sqr;
  
  //standard constructor
  function new(string name = "rv32i_agent",uvm_component parent);
  
    super.new(name,parent);
    `uvm_info("Agent Class","Constructor",UVM_MEDIUM)
    
  endfunction
  
  //build phase
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    
    drv = rv32i_driver::type_id::create("drv",this);
    mon = rv32i_monitor::type_id::create("mon",this);
    sqr = rv32i_sequencer::type_id::create("sqr",this);
  endfunction
  
  //connect phase
  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    `uvm_info("agent class","connect phase",UVM_MEDIUM)
    drv.seq_item_port.connect(sqr.seq_item_export);
    
  endfunction
  
  //elab phase
  virtual function void end_of_elaboration();
      `uvm_info("agent Class", "elob phase", UVM_MEDIUM)
    print();
  endfunction
  
endclass
