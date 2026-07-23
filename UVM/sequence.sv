class rv32i_sequence extends uvm_sequence#(rv32i_seq_item);
  
  `uvm_object_utils(rv32i_sequence)
  
  rv32i_seq_item tx;
  
  //standard constructor
  function new(string name = "rv32i_sequence");
  
    super.new(name);
    `uvm_info("Sequence Class","Constructor",UVM_MEDIUM)
    
  endfunction
  
  task body();
     begin
     
      tx = rv32i_seq_item::type_id::create("tx");
      
      wait_for_grant();
      
       tx.instr.push_back(32'h00000113);   // ADDI x2,x0,0

       tx.instr.push_back(32'h00010283);   // LB  x5,0(x2)

       tx.instr.push_back(32'h00411303);   // LH  x6,4(x2)

       tx.instr.push_back(32'h00812383);   // LW  x7,8(x2)

       tx.instr.push_back(32'h00014403);   // LBU x8,0(x2)

       tx.instr.push_back(32'h00415483);   // LHU x9,4(x2)
       
//        tx.instr.push_back(32'hFFFFFFFF);
//        tx.instr.push_back(32'h00500093); // addi x1 x0 5   
//        tx.instr.push_back(32'h00A00113); // addi x2 x0 10
//        tx.instr.push_back(32'h002081B3); // add x3 x1 x2
//        tx.instr.push_back(32'h00302023); // sw x3 0(x0)
//        tx.instr.push_back(32'h00002103); // lw x2 0(x0)
       
       
//        tx.instr.push_back(32'h00500093); // ADDI x1,x0,5

// tx.instr.push_back(32'h00A00113); // ADDI x2,x0,10

// tx.instr.push_back(32'h0030E193); // ORI x3,x1,3

// tx.instr.push_back(32'h00717213); // ANDI x4,x2,7

// tx.instr.push_back(32'h002082B3); // ADD x5,x1,x2

// tx.instr.push_back(32'h40128333); // SUB x6,x5,x1

// tx.instr.push_back(32'h0062C3B3); // XOR x7,x5,x6

// tx.instr.push_back(32'h00502023); // SW x5,0(x0)

// tx.instr.push_back(32'h00002403); // LW x8,0(x0)

// tx.instr.push_back(32'h00828463); // BEQ x5,x8,+8

// tx.instr.push_back(32'h06400493); // ADDI x9,x0,100 (Skipped)

// tx.instr.push_back(32'h03200513); // ADDI x10,x0,50
     
       
//      tx.instr.push_back(32'h00800093); // ADDI x1,x0,8

// tx.instr.push_back(32'h00209113); // SLLI x2,x1,2

// tx.instr.push_back(32'h00115193); // SRLI x3,x2,1

// tx.instr.push_back(32'h40115213); // SRAI x4,x2,1

// tx.instr.push_back(32'h0020A2B3); // SLT x5,x1,x2

// tx.instr.push_back(32'h0020B333); // SLTU x6,x1,x2
       
       
//        tx.instr.push_back(32'h123450B7); // LUI x1,0x12345

// tx.instr.push_back(32'h00001117); // AUIPC x2,0x1

// tx.instr.push_back(32'h00510193); // ADDI x3,x2,5
       
       
//        tx.instr.push_back(32'h00500093); // ADDI x1,x0,5

// tx.instr.push_back(32'h008000EF); // JAL x1,+8

// tx.instr.push_back(32'h00A00113); // ADDI x2,x0,10 (Skipped)

// tx.instr.push_back(32'h01400193); // ADDI x3,x0,20
       
       
//        tx.instr.push_back(32'h01000093); // ADDI x1,x0,16

// tx.instr.push_back(32'h00008067); // JALR x0,0(x1)
       
      send_request(tx);
      wait_for_item_done();
      
    end
  
  endtask
  
endclass
