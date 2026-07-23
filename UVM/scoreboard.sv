class rv32i_scoreboard extends uvm_scoreboard;

  `uvm_component_utils(rv32i_scoreboard)
  uvm_analysis_imp #(rv32i_mon_item, rv32i_scoreboard) item_collected_export;
  
  rv32i_mon_item mon_q[$];
  rv32i_predictor predictor; 
  
  //standard constructor
  function new(string name = "rv32i_scoreboard",uvm_component parent);
  
    super.new(name,parent);
    `uvm_info("Scoreboard Class","Constructor",UVM_MEDIUM)
    
  endfunction
  
  //build phase
  function void build_phase(uvm_phase phase);
    super.build_phase(phase); 
    item_collected_export = new("item_collected_export",this);
    predictor = new();
  endfunction
  
  function void write(rv32i_mon_item item);
    `uvm_info("SCOREBOARD",
              "Received transaction from monitor",
              UVM_LOW)
    mon_q.push_back(item);
  endfunction
  
  //run phase
  task run_phase(uvm_phase phase);
  	rv32i_mon_item actual;
    rv32i_mon_item expected;
    
    forever begin
      wait(mon_q.size()>0);
      actual = mon_q.pop_front();
      
      predictor.predict(actual,expected);
      compare(expected,actual);
      
//       //compare
//       if(item.rd_data == 32'd5)
//         `uvm_info("SB","ADDI PASS",UVM_LOW)
//       else
//             `uvm_error("SB","ADD FAIL")
      
    end
    
  endtask
  
  task compare(rv32i_mon_item exp, rv32i_mon_item act);

case(act.instruction[6:0])

// R-TYPE

7'b0110011:
begin
    string inst;
	  string err="";
    case(act.instruction[14:12])
        3'b000:
            if(act.instruction[31:25]==7'b0100000)
                inst="SUB";
            else
                inst="ADD";

        3'b001: inst="SLL";
        3'b010: inst="SLT";
        3'b011: inst="SLTU";
        3'b100: inst="XOR";

        3'b101:
            if(act.instruction[31:25]==7'b0100000)
                inst="SRA";
            else
                inst="SRL";

        3'b110: inst="OR";
        3'b111: inst="AND";
        default: inst="UNKNOWN";
    endcase

 

if(exp.reg_write != act.reg_write)
    err = {err, $sformatf("\nRegWrite    Exp=%0b Act=%0b", exp.reg_write, act.reg_write)};

if(exp.rd != act.rd)
    err = {err, $sformatf("\nRD          Exp=x%0d Act=x%0d", exp.rd, act.rd)};

if(exp.rd_data != act.rd_data)
    err = {err, $sformatf("\nRD_DATA     Exp=%08h Act=%08h", exp.rd_data, act.rd_data)};

if(exp.mem_write != act.mem_write)
    err = {err, $sformatf("\nMemWrite    Exp=%0b Act=%0b", exp.mem_write, act.mem_write)};

// if(exp.mem_addr != act.mem_addr)
//     err = {err, $sformatf("\nMemAddr     Exp=%08h Act=%08h", exp.mem_addr, act.mem_addr)};

// if(exp.mem_data != act.mem_data)
//     err = {err, $sformatf("\nMemData     Exp=%08h Act=%08h", exp.mem_data, act.mem_data)};

if(exp.branch_taken != act.branch_taken)
    err = {err, $sformatf("\nBranchTaken Exp=%0b Act=%0b", exp.branch_taken, act.branch_taken)};

if(exp.jump_taken != act.jump_taken)
    err = {err, $sformatf("\nJumpTaken   Exp=%0b Act=%0b", exp.jump_taken, act.jump_taken)};

if(exp.link_addr != act.link_addr)
    err = {err, $sformatf("\nLinkAddr    Exp=%08h Act=%08h", exp.link_addr, act.link_addr)};

if(exp.illegal_instr != act.illegal_instr)
    err = {err, $sformatf("\nIllegalInst Exp=%0b Act=%0b", exp.illegal_instr, act.illegal_instr)};

if(err != "")
    `uvm_error("SB",
        $sformatf("\n[%s] SCOREBOARD FAILED @ PC=%08h%s",
                  inst, act.pc, err))
else
    `uvm_info("SB",
        $sformatf("[%s] PASS @ PC=%08h", inst, act.pc),
        UVM_LOW);
end



// I-TYPE ALU

7'b0010011:
begin
    string inst;
  	string err="";

    case(act.instruction[14:12])

        3'b000: inst="ADDI";
        3'b010: inst="SLTI";
        3'b011: inst="SLTIU";
        3'b100: inst="XORI";
        3'b110: inst="ORI";
        3'b111: inst="ANDI";

        3'b001: inst="SLLI";

        3'b101:
            if(act.instruction[31:25]==7'b0100000)
                inst="SRAI";
            else
                inst="SRLI";

        default: inst="UNKNOWN";
    endcase

   

if(exp.reg_write != act.reg_write)
    err = {err, $sformatf("\nRegWrite    Exp=%0b Act=%0b", exp.reg_write, act.reg_write)};

if(exp.rd != act.rd)
    err = {err, $sformatf("\nRD          Exp=x%0d Act=x%0d", exp.rd, act.rd)};

if(exp.rd_data != act.rd_data)
    err = {err, $sformatf("\nRD_DATA     Exp=%08h Act=%08h", exp.rd_data, act.rd_data)};

if(exp.mem_write != act.mem_write)
    err = {err, $sformatf("\nMemWrite    Exp=%0b Act=%0b", exp.mem_write, act.mem_write)};

// if(exp.mem_addr != act.mem_addr)
//     err = {err, $sformatf("\nMemAddr     Exp=%08h Act=%08h", exp.mem_addr, act.mem_addr)};

// if(exp.mem_data != act.mem_data)
//     err = {err, $sformatf("\nMemData     Exp=%08h Act=%08h", exp.mem_data, act.mem_data)};
  

if(exp.branch_taken != act.branch_taken)
    err = {err, $sformatf("\nBranchTaken Exp=%0b Act=%0b", exp.branch_taken, act.branch_taken)};

if(exp.jump_taken != act.jump_taken)
    err = {err, $sformatf("\nJumpTaken   Exp=%0b Act=%0b", exp.jump_taken, act.jump_taken)};

if(exp.link_addr != act.link_addr)
    err = {err, $sformatf("\nLinkAddr    Exp=%08h Act=%08h", exp.link_addr, act.link_addr)};

if(exp.illegal_instr != act.illegal_instr)
    err = {err, $sformatf("\nIllegalInst Exp=%0b Act=%0b", exp.illegal_instr, act.illegal_instr)};

if(err != "")
    `uvm_error("SB",
        $sformatf("\n[%s] SCOREBOARD FAILED @ PC=%08h%s",
                  inst, act.pc, err))
else
    `uvm_info("SB",
        $sformatf("[%s] PASS @ PC=%08h", inst, act.pc),
        UVM_LOW);
end



// LOAD

7'b0000011:
begin
    string inst;
	 string err = "";
  	
    case(act.instruction[14:12])
        3'b000: inst="LB";
        3'b001: inst="LH";
        3'b010: inst="LW";
        3'b100: inst="LBU";
        3'b101: inst="LHU";
        default: inst="LOAD";
    endcase

  
if(exp.reg_write != act.reg_write)
    err = {err, $sformatf("\nRegWrite    Exp=%0b Act=%0b", exp.reg_write, act.reg_write)};

if(exp.rd != act.rd)
    err = {err, $sformatf("\nRD          Exp=x%0d Act=x%0d", exp.rd, act.rd)};

if(exp.rd_data != act.rd_data)
    err = {err, $sformatf("\nRD_DATA     Exp=%08h Act=%08h", exp.rd_data, act.rd_data)};

if(exp.mem_write != act.mem_write)
    err = {err, $sformatf("\nMemWrite    Exp=%0b Act=%0b", exp.mem_write, act.mem_write)};

if(exp.mem_addr != act.mem_addr)
    err = {err, $sformatf("\nMemAddr     Exp=%08h Act=%08h", exp.mem_addr, act.mem_addr)};

if(exp.mem_data != act.mem_data)
    err = {err, $sformatf("\nMemData     Exp=%08h Act=%08h", exp.mem_data, act.mem_data)};

if(exp.branch_taken != act.branch_taken)
    err = {err, $sformatf("\nBranchTaken Exp=%0b Act=%0b", exp.branch_taken, act.branch_taken)};

if(exp.jump_taken != act.jump_taken)
    err = {err, $sformatf("\nJumpTaken   Exp=%0b Act=%0b", exp.jump_taken, act.jump_taken)};

if(exp.link_addr != act.link_addr)
    err = {err, $sformatf("\nLinkAddr    Exp=%08h Act=%08h", exp.link_addr, act.link_addr)};

if(exp.illegal_instr != act.illegal_instr)
    err = {err, $sformatf("\nIllegalInst Exp=%0b Act=%0b", exp.illegal_instr, act.illegal_instr)};

if(err != "")
    `uvm_error("SB",
        $sformatf("\n[%s] SCOREBOARD FAILED @ PC=%08h%s",
                  inst, act.pc, err))
else
    `uvm_info("SB",
        $sformatf("[%s] PASS @ PC=%08h", inst, act.pc),
        UVM_LOW);
end



// STORE

7'b0100011:
begin
    string inst;
	 string err = "";	
  
    case(act.instruction[14:12])
        3'b000: inst="SB";
        3'b001: inst="SH";
        3'b010: inst="SW";
        default: inst="STORE";
    endcase

    

if(exp.reg_write != act.reg_write)
    err = {err, $sformatf("\nRegWrite    Exp=%0b Act=%0b", exp.reg_write, act.reg_write)};

if(exp.rd != act.rd)
    err = {err, $sformatf("\nRD          Exp=x%0d Act=x%0d", exp.rd, act.rd)};

if(exp.rd_data != act.rd_data)
    err = {err, $sformatf("\nRD_DATA     Exp=%08h Act=%08h", exp.rd_data, act.rd_data)};

if(exp.mem_write != act.mem_write)
    err = {err, $sformatf("\nMemWrite    Exp=%0b Act=%0b", exp.mem_write, act.mem_write)};

if(exp.mem_addr != act.mem_addr)
    err = {err, $sformatf("\nMemAddr     Exp=%08h Act=%08h", exp.mem_addr, act.mem_addr)};

if(exp.mem_data != act.mem_data)
    err = {err, $sformatf("\nMemData     Exp=%08h Act=%08h", exp.mem_data, act.mem_data)};

if(exp.branch_taken != act.branch_taken)
    err = {err, $sformatf("\nBranchTaken Exp=%0b Act=%0b", exp.branch_taken, act.branch_taken)};

if(exp.jump_taken != act.jump_taken)
    err = {err, $sformatf("\nJumpTaken   Exp=%0b Act=%0b", exp.jump_taken, act.jump_taken)};

if(exp.link_addr != act.link_addr)
    err = {err, $sformatf("\nLinkAddr    Exp=%08h Act=%08h", exp.link_addr, act.link_addr)};

if(exp.illegal_instr != act.illegal_instr)
    err = {err, $sformatf("\nIllegalInst Exp=%0b Act=%0b", exp.illegal_instr, act.illegal_instr)};

if(err != "")
    `uvm_error("SB",
        $sformatf("\n[%s] SCOREBOARD FAILED @ PC=%08h%s",
                  inst, act.pc, err))
else
    `uvm_info("SB",
        $sformatf("[%s] PASS @ PC=%08h", inst, act.pc),
        UVM_LOW);
end


// BRANCH

7'b1100011:
begin
    string inst;
	string err = "";
  
    case(act.instruction[14:12])
        3'b000: inst="BEQ";
        3'b001: inst="BNE";
        3'b100: inst="BLT";
        3'b101: inst="BGE";
        3'b110: inst="BLTU";
        3'b111: inst="BGEU";
        default: inst="BRANCH";
    endcase

if(exp.reg_write != act.reg_write)
    err = {err, $sformatf("\nRegWrite    Exp=%0b Act=%0b", exp.reg_write, act.reg_write)};

if(exp.rd != act.rd)
    err = {err, $sformatf("\nRD          Exp=x%0d Act=x%0d", exp.rd, act.rd)};

if(exp.rd_data != act.rd_data)
    err = {err, $sformatf("\nRD_DATA     Exp=%08h Act=%08h", exp.rd_data, act.rd_data)};

if(exp.mem_write != act.mem_write)
    err = {err, $sformatf("\nMemWrite    Exp=%0b Act=%0b", exp.mem_write, act.mem_write)};

if(exp.mem_addr != act.mem_addr)
    err = {err, $sformatf("\nMemAddr     Exp=%08h Act=%08h", exp.mem_addr, act.mem_addr)};

if(exp.mem_data != act.mem_data)
    err = {err, $sformatf("\nMemData     Exp=%08h Act=%08h", exp.mem_data, act.mem_data)};

if(exp.branch_taken != act.branch_taken)
    err = {err, $sformatf("\nBranchTaken Exp=%0b Act=%0b", exp.branch_taken, act.branch_taken)};

if(exp.jump_taken != act.jump_taken)
    err = {err, $sformatf("\nJumpTaken   Exp=%0b Act=%0b", exp.jump_taken, act.jump_taken)};

if(exp.link_addr != act.link_addr)
    err = {err, $sformatf("\nLinkAddr    Exp=%08h Act=%08h", exp.link_addr, act.link_addr)};

if(exp.illegal_instr != act.illegal_instr)
    err = {err, $sformatf("\nIllegalInst Exp=%0b Act=%0b", exp.illegal_instr, act.illegal_instr)};

if(err != "")
    `uvm_error("SB",
        $sformatf("\n[%s] SCOREBOARD FAILED @ PC=%08h%s",
                  inst, act.pc, err))
else
    `uvm_info("SB",
        $sformatf("[%s] PASS @ PC=%08h", inst, act.pc),
        UVM_LOW);
end



// LUI

7'b0110111:
begin
  	string inst ="LUI";
    string err = "";

if(exp.reg_write != act.reg_write)
    err = {err, $sformatf("\nRegWrite    Exp=%0b Act=%0b", exp.reg_write, act.reg_write)};

if(exp.rd != act.rd)
    err = {err, $sformatf("\nRD          Exp=x%0d Act=x%0d", exp.rd, act.rd)};

if(exp.rd_data != act.rd_data)
    err = {err, $sformatf("\nRD_DATA     Exp=%08h Act=%08h", exp.rd_data, act.rd_data)};

if(exp.mem_write != act.mem_write)
    err = {err, $sformatf("\nMemWrite    Exp=%0b Act=%0b", exp.mem_write, act.mem_write)};

if(exp.mem_addr != act.mem_addr)
    err = {err, $sformatf("\nMemAddr     Exp=%08h Act=%08h", exp.mem_addr, act.mem_addr)};

if(exp.mem_data != act.mem_data)
    err = {err, $sformatf("\nMemData     Exp=%08h Act=%08h", exp.mem_data, act.mem_data)};

if(exp.branch_taken != act.branch_taken)
    err = {err, $sformatf("\nBranchTaken Exp=%0b Act=%0b", exp.branch_taken, act.branch_taken)};

if(exp.jump_taken != act.jump_taken)
    err = {err, $sformatf("\nJumpTaken   Exp=%0b Act=%0b", exp.jump_taken, act.jump_taken)};

if(exp.link_addr != act.link_addr)
    err = {err, $sformatf("\nLinkAddr    Exp=%08h Act=%08h", exp.link_addr, act.link_addr)};

if(exp.illegal_instr != act.illegal_instr)
    err = {err, $sformatf("\nIllegalInst Exp=%0b Act=%0b", exp.illegal_instr, act.illegal_instr)};

if(err != "")
    `uvm_error("SB",
        $sformatf("\n[%s] SCOREBOARD FAILED @ PC=%08h%s",
                  inst, act.pc, err))
else
    `uvm_info("SB",
        $sformatf("[%s] PASS @ PC=%08h", inst, act.pc),
        UVM_LOW);
end


// AUIPC

7'b0010111:
begin
  	string inst ="AUIPC";
   string err = "";

if(exp.reg_write != act.reg_write)
    err = {err, $sformatf("\nRegWrite    Exp=%0b Act=%0b", exp.reg_write, act.reg_write)};

if(exp.rd != act.rd)
    err = {err, $sformatf("\nRD          Exp=x%0d Act=x%0d", exp.rd, act.rd)};

if(exp.rd_data != act.rd_data)
    err = {err, $sformatf("\nRD_DATA     Exp=%08h Act=%08h", exp.rd_data, act.rd_data)};

if(exp.mem_write != act.mem_write)
    err = {err, $sformatf("\nMemWrite    Exp=%0b Act=%0b", exp.mem_write, act.mem_write)};

if(exp.mem_addr != act.mem_addr)
    err = {err, $sformatf("\nMemAddr     Exp=%08h Act=%08h", exp.mem_addr, act.mem_addr)};

if(exp.mem_data != act.mem_data)
    err = {err, $sformatf("\nMemData     Exp=%08h Act=%08h", exp.mem_data, act.mem_data)};

if(exp.branch_taken != act.branch_taken)
    err = {err, $sformatf("\nBranchTaken Exp=%0b Act=%0b", exp.branch_taken, act.branch_taken)};

if(exp.jump_taken != act.jump_taken)
    err = {err, $sformatf("\nJumpTaken   Exp=%0b Act=%0b", exp.jump_taken, act.jump_taken)};

if(exp.link_addr != act.link_addr)
    err = {err, $sformatf("\nLinkAddr    Exp=%08h Act=%08h", exp.link_addr, act.link_addr)};

if(exp.illegal_instr != act.illegal_instr)
    err = {err, $sformatf("\nIllegalInst Exp=%0b Act=%0b", exp.illegal_instr, act.illegal_instr)};

if(err != "")
    `uvm_error("SB",
        $sformatf("\n[%s] SCOREBOARD FAILED @ PC=%08h%s",
                  inst, act.pc, err))
else
    `uvm_info("SB",
        $sformatf("[%s] PASS @ PC=%08h", inst, act.pc),
        UVM_LOW);
end



// JAL

7'b1101111:
begin
  	string inst = "JAL";
   string err = "";

if(exp.reg_write != act.reg_write)
    err = {err, $sformatf("\nRegWrite    Exp=%0b Act=%0b", exp.reg_write, act.reg_write)};

if(exp.rd != act.rd)
    err = {err, $sformatf("\nRD          Exp=x%0d Act=x%0d", exp.rd, act.rd)};

if(exp.rd_data != act.rd_data)
    err = {err, $sformatf("\nRD_DATA     Exp=%08h Act=%08h", exp.rd_data, act.rd_data)};

if(exp.mem_write != act.mem_write)
    err = {err, $sformatf("\nMemWrite    Exp=%0b Act=%0b", exp.mem_write, act.mem_write)};

if(exp.mem_addr != act.mem_addr)
    err = {err, $sformatf("\nMemAddr     Exp=%08h Act=%08h", exp.mem_addr, act.mem_addr)};

if(exp.mem_data != act.mem_data)
    err = {err, $sformatf("\nMemData     Exp=%08h Act=%08h", exp.mem_data, act.mem_data)};

if(exp.branch_taken != act.branch_taken)
    err = {err, $sformatf("\nBranchTaken Exp=%0b Act=%0b", exp.branch_taken, act.branch_taken)};

if(exp.jump_taken != act.jump_taken)
    err = {err, $sformatf("\nJumpTaken   Exp=%0b Act=%0b", exp.jump_taken, act.jump_taken)};

if(exp.link_addr != act.link_addr)
    err = {err, $sformatf("\nLinkAddr    Exp=%08h Act=%08h", exp.link_addr, act.link_addr)};

if(exp.illegal_instr != act.illegal_instr)
    err = {err, $sformatf("\nIllegalInst Exp=%0b Act=%0b", exp.illegal_instr, act.illegal_instr)};

if(err != "")
    `uvm_error("SB",
        $sformatf("\n[%s] SCOREBOARD FAILED @ PC=%08h%s",
                  inst, act.pc, err))
else
    `uvm_info("SB",
        $sformatf("[%s] PASS @ PC=%08h", inst, act.pc),
        UVM_LOW);
end



// JALR

7'b1100111:
begin
  	string inst = "JALR";
   string err = "";

if(exp.reg_write != act.reg_write)
    err = {err, $sformatf("\nRegWrite    Exp=%0b Act=%0b", exp.reg_write, act.reg_write)};

if(exp.rd != act.rd)
    err = {err, $sformatf("\nRD          Exp=x%0d Act=x%0d", exp.rd, act.rd)};

if(exp.rd_data != act.rd_data)
    err = {err, $sformatf("\nRD_DATA     Exp=%08h Act=%08h", exp.rd_data, act.rd_data)};

if(exp.mem_write != act.mem_write)
    err = {err, $sformatf("\nMemWrite    Exp=%0b Act=%0b", exp.mem_write, act.mem_write)};

if(exp.mem_addr != act.mem_addr)
    err = {err, $sformatf("\nMemAddr     Exp=%08h Act=%08h", exp.mem_addr, act.mem_addr)};

if(exp.mem_data != act.mem_data)
    err = {err, $sformatf("\nMemData     Exp=%08h Act=%08h", exp.mem_data, act.mem_data)};

if(exp.branch_taken != act.branch_taken)
    err = {err, $sformatf("\nBranchTaken Exp=%0b Act=%0b", exp.branch_taken, act.branch_taken)};

if(exp.jump_taken != act.jump_taken)
    err = {err, $sformatf("\nJumpTaken   Exp=%0b Act=%0b", exp.jump_taken, act.jump_taken)};

if(exp.link_addr != act.link_addr)
    err = {err, $sformatf("\nLinkAddr    Exp=%08h Act=%08h", exp.link_addr, act.link_addr)};

if(exp.illegal_instr != act.illegal_instr)
    err = {err, $sformatf("\nIllegalInst Exp=%0b Act=%0b", exp.illegal_instr, act.illegal_instr)};

if(err != "")
    `uvm_error("SB",
        $sformatf("\n[%s] SCOREBOARD FAILED @ PC=%08h%s",
                  inst, act.pc, err))
else
    `uvm_info("SB",
        $sformatf("[%s] PASS @ PC=%08h", inst, act.pc),
        UVM_LOW);
end


// ILLEGAL

default:
begin
    `uvm_warning("SB",
    $sformatf("Unknown Opcode = %b",
    act.instruction[6:0]));
end

endcase

endtask
endclass
