class rv32i_predictor;

  bit [31:0] ref_reg[32];
  bit [31:0] ref_mem[256];
  
  function new();

        foreach(ref_reg[i])
            ref_reg[i]=0;

        foreach(ref_mem[i])
            ref_mem[i]=0;

  endfunction

  task predict(
  	input rv32i_mon_item item,
    output rv32i_mon_item exp
  );
    
    logic [6:0] opcode;
logic [2:0] funct3;
logic [6:0] funct7;

logic [4:0] rs1;
logic [4:0] rs2;
logic [4:0] rd;
    logic [31:0] imm;
    logic [7:0] address;

    logic [31:0] byte_addr;
logic [7:0]  mem_addr;
logic [1:0]  byte_off;


    
opcode = item.instruction[6:0];
rd     = item.instruction[11:7];
funct3 = item.instruction[14:12];
rs1    = item.instruction[19:15];
rs2    = item.instruction[24:20];
funct7 = item.instruction[31:25];
    
    exp = new();

exp.rd_data    = 0;
exp.mem_addr   = 0;
exp.mem_data   = 0;
exp.reg_write  = 0;
exp.mem_write  = 0;
    
exp.branch_taken=0;
exp.jump_taken =0;
exp.link_addr =0;
exp.illegal_instr=0;
    
   case(opcode)

    7'b0110011: begin
        // R-Type predictor
    	 case(funct3)

        3'b000:
          if(funct7==7'b0100000)
            exp.rd_data = ref_reg[rs1] - ref_reg[rs2];      // SUB
            else
              exp.rd_data = ref_reg[rs1] + ref_reg[rs2];      // ADD

        3'b001:
            exp.rd_data = ref_reg[rs1] << ref_reg[rs2][4:0];    // SLL

        3'b010:
            exp.rd_data = ($signed(ref_reg[rs1]) < $signed(ref_reg[rs2])) ? 1 : 0; // SLT

        3'b011:
            exp.rd_data = (ref_reg[rs1] < ref_reg[rs2]) ? 1 : 0; // SLTU

        3'b100:
            exp.rd_data = ref_reg[rs1] ^ ref_reg[rs2];          // XOR

        3'b101:
          if(funct7==7'b0100000)
            exp.rd_data = $signed(ref_reg[rs1]) >>> ref_reg[rs2][4:0]; // SRA
                
            else
              exp.rd_data = ref_reg[rs1] >> ref_reg[rs2][4:0];       // SRL
                

        3'b110:
            exp.rd_data = ref_reg[rs1] | ref_reg[rs2];          // OR

        3'b111:
            exp.rd_data = ref_reg[rs1] & ref_reg[rs2];          // AND
		default:
            exp.illegal_instr = 1;
           
    endcase

   // exp.reg_write = 1;
    exp.mem_write = 0;

    exp.reg_write = !exp.illegal_instr;

if(rd!=0 && !exp.illegal_instr)
    ref_reg[rd]=exp.rd_data;
      
    end

    7'b0010011: begin
        // I-Type ALU predictor
      imm = {{20{item.instruction[31]}},item.instruction[31:20]};

    case(funct3)

        3'b000:
            exp.rd_data = ref_reg[rs1] + imm;              // ADDI

        3'b010:
            exp.rd_data = ($signed(ref_reg[rs1]) < $signed(imm)); // SLTI

        3'b011:
            exp.rd_data = (ref_reg[rs1] < imm);            // SLTIU

        3'b100:
            exp.rd_data = ref_reg[rs1] ^ imm;              // XORI

        3'b110:
            exp.rd_data = ref_reg[rs1] | imm;              // ORI

        3'b111:
            exp.rd_data = ref_reg[rs1] & imm;              // ANDI

        3'b001:
            exp.rd_data = ref_reg[rs1] << imm[4:0];        // SLLI

        3'b101:
            if(funct7==7'b0000000)
                exp.rd_data = ref_reg[rs1] >> imm[4:0];    // SRLI
            else
                exp.rd_data = $signed(ref_reg[rs1]) >>> imm[4:0]; // SRAI

 			default:
            exp.illegal_instr = 1;
    endcase

  //  exp.reg_write=1;
    exp.mem_write=0;

 exp.reg_write = !exp.illegal_instr;

if(rd!=0 && !exp.illegal_instr)
    ref_reg[rd]=exp.rd_data;
    end

 7'b0000011: begin
   	

    imm = {{20{item.instruction[31]}}, item.instruction[31:20]};

    byte_addr = ref_reg[rs1] + imm;

    mem_addr = byte_addr[9:2];

    byte_off = byte_addr[1:0];
   exp.mem_addr = byte_addr;

    case(funct3)

        // LB
        3'b000:
            case(byte_off)
                2'd0: exp.rd_data = {{24{ref_mem[mem_addr][7]}},  ref_mem[mem_addr][7:0]};
                2'd1: exp.rd_data = {{24{ref_mem[mem_addr][15]}}, ref_mem[mem_addr][15:8]};
                2'd2: exp.rd_data = {{24{ref_mem[mem_addr][23]}}, ref_mem[mem_addr][23:16]};
                2'd3: exp.rd_data = {{24{ref_mem[mem_addr][31]}}, ref_mem[mem_addr][31:24]};
            endcase

        // LH
        3'b001:
            if(byte_off[1]==0)
                exp.rd_data = {{16{ref_mem[mem_addr][15]}},
                               ref_mem[mem_addr][15:0]};
            else
                exp.rd_data = {{16{ref_mem[mem_addr][31]}},
                               ref_mem[mem_addr][31:16]};

        // LW
        3'b010:
            exp.rd_data = ref_mem[mem_addr];

        // LBU
        3'b100:
            case(byte_off)
                2'd0: exp.rd_data = {24'd0,ref_mem[mem_addr][7:0]};
                2'd1: exp.rd_data = {24'd0,ref_mem[mem_addr][15:8]};
                2'd2: exp.rd_data = {24'd0,ref_mem[mem_addr][23:16]};
                2'd3: exp.rd_data = {24'd0,ref_mem[mem_addr][31:24]};
            endcase

        // LHU
        3'b101:
            if(byte_off[1]==0)
                exp.rd_data = {16'd0,
                               ref_mem[mem_addr][15:0]};
            else
                exp.rd_data = {16'd0,
                               ref_mem[mem_addr][31:16]};

        default:
            exp.illegal_instr = 1;

    endcase

    exp.reg_write = !exp.illegal_instr;

    if(rd != 0 && !exp.illegal_instr)
        ref_reg[rd] = exp.rd_data;

end

   7'b1100111: begin
    // JALR predictor

     if(funct3!=3'b000)
       exp.illegal_instr=1;
     else begin
     
    imm = {{20{item.instruction[31]}}, item.instruction[31:20]};

    // Link register value
    exp.rd_data = item.pc + 32'd4;
    exp.link_addr = item.pc + 32'd4;

    // Jump information
    exp.jump_taken = 1;

    // Predicted next PC
    //exp.next_pc = (ref_reg[rs1] + imm) & 32'hFFFFFFFE;

   // exp.reg_write = 1;
    exp.mem_write = 0;

   exp.reg_write = !exp.illegal_instr;

if(rd!=0 && !exp.illegal_instr)
    ref_reg[rd]=exp.rd_data;
     end

end

   7'b0100011: begin
    

    imm = {{20{item.instruction[31]}},
           item.instruction[31:25],
           item.instruction[11:7]};

    byte_addr = ref_reg[rs1] + imm;

    mem_addr = byte_addr[9:2];

    byte_off = byte_addr[1:0];
	exp.mem_addr = byte_addr;
     
    case(funct3)

        // SB
        3'b000: begin
            case(byte_off)
                2'd0: ref_mem[mem_addr][7:0]   = ref_reg[rs2][7:0];
                2'd1: ref_mem[mem_addr][15:8]  = ref_reg[rs2][7:0];
                2'd2: ref_mem[mem_addr][23:16] = ref_reg[rs2][7:0];
                2'd3: ref_mem[mem_addr][31:24] = ref_reg[rs2][7:0];
            endcase
        end

        // SH
        3'b001: begin
            if(byte_off[1] == 1'b0)
                ref_mem[mem_addr][15:0] = ref_reg[rs2][15:0];
            else
                ref_mem[mem_addr][31:16] = ref_reg[rs2][15:0];
        end

        // SW
        3'b010: begin
            ref_mem[mem_addr] = ref_reg[rs2];
        end

        default: begin
            exp.illegal_instr = 1;
        end

    endcase

    exp.mem_write = !exp.illegal_instr;
    exp.reg_write = 0;
    exp.mem_addr  = byte_addr;
    exp.mem_data  = ref_reg[rs2];

end
     
     
    7'b1100011: begin
        // BRANCH predictor
      case(funct3)

        3'b000: exp.branch_taken=(ref_reg[rs1]==ref_reg[rs2]); // BEQ

        3'b001: exp.branch_taken=(ref_reg[rs1]!=ref_reg[rs2]); // BNE

        3'b100: exp.branch_taken=($signed(ref_reg[rs1])<$signed(ref_reg[rs2])); // BLT

        3'b101: exp.branch_taken=($signed(ref_reg[rs1])>=$signed(ref_reg[rs2])); // BGE

        3'b110: exp.branch_taken=(ref_reg[rs1]<ref_reg[rs2]); // BLTU

        3'b111: exp.branch_taken=(ref_reg[rs1]>=ref_reg[rs2]); // BGEU

    	default:
            exp.illegal_instr = 1;
      endcase

    exp.reg_write=0;
    exp.mem_write=0;
      
    end

    7'b0110111: begin
        // LUI predictor
      imm={item.instruction[31:12],12'b0};

    exp.rd_data=imm;

   // exp.reg_write=1;
    exp.mem_write=0;

   exp.reg_write = !exp.illegal_instr;

if(rd!=0 && !exp.illegal_instr)
    ref_reg[rd]=exp.rd_data;

      
    end

    7'b0010111: begin
        // AUIPC predictor
      imm={item.instruction[31:12],12'b0};

    exp.rd_data=item.pc+imm;

    //exp.reg_write=1;
    exp.mem_write=0;

    exp.reg_write = !exp.illegal_instr;

if(rd!=0 && !exp.illegal_instr)
    ref_reg[rd]=exp.rd_data;
    end

  7'b1101111: begin
    // JAL predictor

    imm = {{12{item.instruction[31]}},
           item.instruction[19:12],
           item.instruction[20],
           item.instruction[30:21],
           1'b0};

    exp.rd_data = item.pc + 32'd4;
    exp.link_addr = item.pc + 32'd4;

    exp.jump_taken = 1;

   // exp.next_pc = item.pc + imm;

   // exp.reg_write = 1;
    exp.mem_write = 0;
exp.reg_write = !exp.illegal_instr;

if(rd!=0 && !exp.illegal_instr)
    ref_reg[rd]=exp.rd_data;

end
    default: begin
   		exp.illegal_instr=1;
      `uvm_error("PRED","Illegal Instruction");
    end

endcase
    
    ref_reg[0] = 0;
  endtask
  
endclass
