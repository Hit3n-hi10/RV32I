`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/29/2026 11:23:49 AM
// Design Name: 
// Module Name: instruction_decoder
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module instruction_decoder(
    input [31:0] instruction,
    output reg [6:0]opcode,
    output reg [4:0] rd,
    output reg [4:0] rs1,
    output reg [4:0] rs2,
    output reg [2:0] funct3,
    output reg [6:0] funct7
    );
    always @(*) begin 
        opcode = instruction[6:0];
        rd = 0;
        rs1 = 0;
        rs2 = 0;
        funct3 = 0;
        funct7 = 0;
        
        case (opcode) 
            
            // R TYPE Instructions: add, sub, and, or, sll, slt,
            //                      sltu,xor,srl, sra
            7'b0110011: begin
                rd = instruction[11:7];
                funct3 = instruction[14:12];
                rs1 = instruction[19:15];
                rs2 = instruction[24:20];
                funct7 = instruction[31:25];
            end
            
            // I TYPE Instructions: addi, slti, sltiu, xori, ori, andi,
            //                      slli, srli, srai, lb, lh, lw, lbu, 
            //                      lhu, jalr
            7'b0010011,
            7'b0000011,
            7'b1100111: begin
                rd = instruction[11:7];
                funct3 = instruction[14:12];
                rs1 = instruction[19:15];
            end 
                    
            // S TYPE Instructions: sb, sh, sw
            7'b0100011: begin
                funct3 = instruction[14:12];
                rs1 = instruction[19:15];
                rs2 = instruction[24:20];
            end 
            
            // B TYPE Instructions: beq, bne, blt, bge, bltu, bgeu
            7'b1100011: begin
                funct3 = instruction[14:12];
                rs1 = instruction[19:15];
                rs2 = instruction[24:20];
            end
            
            // U TYPE Instructions: lui, auipc
            7'b0110111,
            7'b0010111: begin
                rd = instruction[11:7];
            end
            
            // J TYPE Instructions: jal
            7'b1101111: begin
                rd = instruction[11:7];
            end
            
        endcase
   end
     
endmodule
