
module rv32i_top(
    input clk,
    input rst
    );
    
    //wire connecting submodules
    wire [31:0] pc , next_pc;    // for PC
    wire [31:0] instruction;     // for fetch
    wire [6:0] opcode;           // for decoder
    wire [2:0] funct3;
    wire [6:0] funct7;
    wire illegal_instr;
    
    wire [31:0] immediate;       // for immediate generator
    wire [2:0] imm_sel;
    
    wire [31:0] alu_result;      // for ALU
    wire alu_zero;
    wire [31:0] alu_B,alu_A;
    wire [1:0] ALUOp;
    wire [3:0] alu_op;
    
    wire [31:0] mem_read_data;   // for data memory

    wire [31:0] rs1_data; // for register file
    wire [31:0] rs2_data;
    wire [31:0] write_back_data;
    
    //control signals
    wire RegWrite,MemRead,MemWrite,MemToReg,ALUSrc,Branch,Jump,Jalr;
    wire [4:0] rs1_addr,rs2_addr,rd_addr;
    wire [1:0] ALUSrcA;
    
    //branch signals
    wire brh_taken,jump_taken;
    wire [31:0] link_addr;
    
    //___Integration of submodules___
    //PC instantiation
    program_counter pc_block(.clk(clk),.rst_n(~rst),.next_pc(next_pc),.pc(pc));
    
    //Instruction Fetch
    instruction_memory imem_block(.addr(pc),.instruction(instruction));
    
    //Decoder instantiation
    instruction_decoder decoder_block(.instruction(instruction),.opcode(opcode),.rs1(rs1_addr)
                                      ,.rs2(rs2_addr),.rd(rd_addr),.funct3(funct3),.funct7(funct7),.illegal_instr(illegal_instr));

    //control unit instantiation
    control_unit control_unit_block(.opcode(opcode),.funct3(funct3),.funct7(funct7),.RegWrite(RegWrite),.MemRead(MemRead)
                        ,.MemWrite(MemWrite),.MemToReg(MemToReg),.ALUSrc(ALUSrc),.ALUSrcA(ALUSrcA) ,.Branch(Branch),.Jump(Jump),.Jalr(Jalr),.ALUOp(ALUOp),.imm_sel(imm_sel));

    //Immediate generator instantion
    imm_generator imm_gen_block(.instruction(instruction),.imm_sel(imm_sel),.immediate(immediate));

    //Register file instantiation
    register_file regfile_block(.clk(clk),.rst(rst),.regwrite(RegWrite),.rs1(rs1_addr),.rs2(rs2_addr),
                                .rd(rd_addr),.wd(write_back_data),.rd1(rs1_data),.rd2(rs2_data));
                               
    //ALU Control Instantiation
    ALU_Control alu_control_unit(.ALUOp(ALUOp),.funct3(funct3),.funct7(funct7),.alu_op(alu_op));
    
    //Mux logic for lui and auipc
     assign alu_A = (ALUSrcA == 2'b00) ? rs1_data :
                    (ALUSrcA == 2'b01) ? pc :
                    (ALUSrcA == 2'b10) ? 32'd0 : 32'd0;
    
    //ALUSrc MUX logic
    assign alu_B = (ALUSrc)? (immediate):(rs2_data) ;
    
    //ALU instantiation
    ALU alu_block(.A(alu_A),.B(alu_B),.alu_op(alu_op),.result(alu_result),.zero(alu_zero));
    
    //data memory instantiation
    data_memory dmem_block(.clk(clk),.memread(MemRead),.memwrite(MemWrite),.funct3(funct3),.address(alu_result),.write_data(rs2_data),.read_data(mem_read_data));
    
    //writeback logic
    assign write_back_data = (Jump || Jalr) ? link_addr : (MemToReg) ? mem_read_data : alu_result;
    
    //without branch logics
    //assign next_pc = pc + 4;
    
    //Branch/Jump unit
    Branch_Jump_Unit branch_block(.rst(rst),.jump(Jump),.jalr(Jalr),.brh(Branch),.func_b(funct3),.src_reg_1(rs1_data),.src_reg_2(rs2_data)
                                    ,.imm(immediate),.pc_in(pc),.pc_out(next_pc),.link_addr(link_addr),.brh_taken(brh_taken),.jump_taken(jump_taken));
    
endmodule
