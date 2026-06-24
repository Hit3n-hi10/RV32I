module control_unit(
        input [6:0]opcode,
        input [2:0]funct3,
        input [6:0]funct7,
        output reg RegWrite, MemRead, MemWrite,
        MemToReg, ALUSrc, Branch, Jump, Jalr,
        output reg [1:0]ALUOp, 
        output reg [2:0] imm_sel
    );
    
    // Immediate Type Encoding
    parameter I_Type = 3'b000;
    parameter S_Type = 3'b001;
    parameter B_Type = 3'b010;
    parameter U_Type = 3'b011;
    parameter J_Type = 3'b100;
    
    always @(*) begin
    RegWrite = 0;
    MemRead = 0;
    MemWrite = 0;
    MemToReg = 0;
    ALUSrc = 0;
    Branch = 0;
    Jump = 0;
    Jalr = 0;
    ALUOp = 2'b00; 
    imm_sel = I_Type;
   
        case (opcode)
            // R - TYPE Instructions 
            7'b0110011: begin
                RegWrite = 1;
                ALUOp = 2'b10;
            end
            
            // I - TYPE Instructions 
            7'b0010011: begin
                RegWrite = 1;
                ALUSrc = 1;
                ALUOp = 2'b10;
                imm_sel = I_Type;
            end
            
            // LOAD Instructions 
            7'b0000011: begin
                 RegWrite = 1;
                 ALUSrc = 1;
                 MemRead = 1;
                 MemToReg = 1;
                 ALUOp = 2'b00;
                 imm_sel = I_Type;
            end 
            
            // STORE Instructions 
            7'b0100011: begin
                 ALUSrc = 1;
                 MemWrite = 1;
                 ALUOp = 2'b00;
                 imm_sel = S_Type;
            end
            
            // BRANCH Instructions 
            7'b1100011: begin
                Branch = 1;
                ALUOp = 2'b01;
                imm_sel = B_Type;
            end
            
            // JUMP Instructions 
            7'b1101111: begin 
                RegWrite = 1;
                Jump = 1;
                Jalr = 0;
                ALUOp = 2'b00;
                imm_sel = J_Type;
            end
            
        // LUI : Load Upper Immediate
            7'b0110111: begin
                RegWrite = 1;
                ALUSrc = 1;
                ALUOp = 2'b00;
                imm_sel = U_Type;
            end
    
            // AUIPC : Add Upper Immediate to PC
            7'b0010111: begin
                RegWrite = 1;
                ALUSrc = 1;
                ALUOp = 2'b00;
                imm_sel = U_Type;
            end
    
            // JALR
            7'b1100111: begin
                RegWrite = 1;
                Jump = 0;
                Jalr = 1;
                ALUSrc = 1;
                ALUOp = 2'b00;
                imm_sel = I_Type;
            end
            
            default: begin
                RegWrite = 0;
                MemRead  = 0;
                MemWrite = 0;
                MemToReg = 0;
                ALUSrc = 0;
                Branch = 0;
                Jump = 0;
                Jalr = 0;
                ALUOp = 2'b00;
                imm_sel = I_Type;
            end
        endcase 
    end         
endmodule
