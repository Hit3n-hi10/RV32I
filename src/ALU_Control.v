module ALU_Control(
    input [1:0] ALUOp,
    input [2:0] funct3,
    input [6:0] funct7,
    output reg [3:0] alu_op 
    );
    
        //ALU operation code
    parameter ALU_ADD = 4'b0000;
    parameter ALU_SUB = 4'b0001;
    parameter ALU_AND = 4'b0010;
    parameter ALU_OR  = 4'b0011;
    parameter ALU_XOR = 4'b0100;
    parameter ALU_SLT = 4'b0101;
    parameter ALU_SLTU = 4'b0110;
    parameter ALU_SLL = 4'b0111;
    parameter ALU_SRL = 4'b1000;
    parameter ALU_SRA = 4'b1001;
    
    always@(*) begin
        alu_op = ALU_ADD;
    case(ALUOp)
        2'b00: alu_op = ALU_ADD;
        2'b01: alu_op = ALU_SUB;
        
        2'b10: begin
          case(funct3)
          
            3'b000: begin 
                if(funct7 == 7'b0100000)
                    alu_op = ALU_SUB;
                else
                    alu_op = ALU_ADD;
                end
                
            3'b001: alu_op = ALU_SLL;
            3'b010: alu_op = ALU_SLT;
            3'b011: alu_op = ALU_SLTU;
            3'b100: alu_op = ALU_XOR;
            3'b101: begin
                if(funct7 == 7'b0100000)
                    alu_op = ALU_SRA;
                else
                    alu_op = ALU_SRL;
                    end
            3'b110: alu_op = ALU_OR;
            3'b111: alu_op = ALU_AND;
            default: alu_op = ALU_ADD;
            
        endcase
        end
        default: alu_op = ALU_ADD;
        
    endcase
