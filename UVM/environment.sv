class rv32i_env extends uvm_env;

  `uvm_component_utils(rv32i_env)
  
  rv32i_agent agent;
  rv32i_scoreboard scb;
  
  //standard constructor
  function new(string name = "rv32i_env",uvm_component parent);
    super.new(name,parent);
    `uvm_info("env Class","Constructor",UVM_MEDIUM)
    
  endfunction
  
  //build phase
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    
    agent = rv32i_agent::type_id::create("agent",this);
    scb = rv32i_scoreboard::type_id::create("scb",this);
  endfunction
  
  //connect phase
  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    `uvm_info("env class","connect_phase",UVM_MEDIUM)
    agent.mon.item_collected_port.connect(scb.item_collected_export);
    
  endfunction
  
endclass
