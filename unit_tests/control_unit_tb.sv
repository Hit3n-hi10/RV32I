`timescale 1ns / 1ps

module control_unit_tb;

    logic [6:0] opcode;
    logic [2:0] funct3;
    logic [6:0] funct7;

    logic RegWrite;
    logic MemRead;
    logic MemWrite;
    logic MemToReg;
    logic ALUSrc;
    logic Branch;
    logic Jump;
    logic Jalr;

    logic [1:0] ALUOp;
    logic [1:0] ALUSrcA;
    logic [2:0] imm_sel;

    // DUT Instantiation
    control_unit dut(
        .opcode(opcode),
        .funct3(funct3),
        .funct7(funct7),
        .RegWrite(RegWrite),
        .MemRead(MemRead),
        .MemWrite(MemWrite),
        .MemToReg(MemToReg),
        .ALUSrc(ALUSrc),
        .Branch(Branch),
        .Jump(Jump),
        .Jalr(Jalr),
        .ALUOp(ALUOp),
        .ALUSrcA(ALUSrcA),
        .imm_sel(imm_sel)
    );

    int pass_count = 0;
    int fail_count = 0;

    
    // Generic task to verify all control signals
    
    task automatic check_control(
        input logic [6:0] opcode_in,

        input logic exp_RegWrite,
        input logic exp_MemRead,
        input logic exp_MemWrite,
        input logic exp_MemToReg,
        input logic exp_ALUSrc,
        input logic exp_Branch,
        input logic exp_Jump,
        input logic exp_Jalr,

        input logic [1:0] exp_ALUOp,
        input logic [1:0] exp_ALUSrcA,
        input logic [2:0] exp_imm_sel
    );

    begin

        opcode = opcode_in;
        funct3 = 3'b000;
        funct7 = 7'b0000000;

        #1;

        if ( RegWrite !== exp_RegWrite ||
             MemRead  !== exp_MemRead  ||
             MemWrite !== exp_MemWrite ||
             MemToReg !== exp_MemToReg ||
             ALUSrc   !== exp_ALUSrc   ||
             Branch   !== exp_Branch   ||
             Jump     !== exp_Jump     ||
             Jalr     !== exp_Jalr     ||
             ALUOp    !== exp_ALUOp    ||
             ALUSrcA  !== exp_ALUSrcA  ||
             imm_sel  !== exp_imm_sel )

        begin

            
            $display("TESTCASE FAILED");
            $display("Opcode = %b", opcode_in);

            $display("\nExpected:");
            $display("RegWrite=%b MemRead=%b MemWrite=%b MemToReg=%b",
                     exp_RegWrite,
                     exp_MemRead,
                     exp_MemWrite,
                     exp_MemToReg);

            $display("ALUSrc=%b Branch=%b Jump=%b Jalr=%b",
                     exp_ALUSrc,
                     exp_Branch,
                     exp_Jump,
                     exp_Jalr);

            $display("ALUOp=%b ALUSrcA=%b imm_sel=%b",
                     exp_ALUOp,
                     exp_ALUSrcA,
                     exp_imm_sel);

            $display("\nActual:");
            $display("RegWrite=%b MemRead=%b MemWrite=%b MemToReg=%b",
                     RegWrite,
                     MemRead,
                     MemWrite,
                     MemToReg);

            $display("ALUSrc=%b Branch=%b Jump=%b Jalr=%b",
                     ALUSrc,
                     Branch,
                     Jump,
                     Jalr);

            $display("ALUOp=%b ALUSrcA=%b imm_sel=%b",
                     ALUOp,
                     ALUSrcA,
                     imm_sel);

          
            fail_count++;

        end

        else begin

            $display("TESTCASE PASSED : Opcode = %b", opcode_in);
            pass_count++;

        end

    end
    endtask

    
    // Test Cases
    

    initial begin

        
        // R-Type
   
        check_control(
            7'b0110011,
            1,0,0,0,
            0,0,0,0,
            2'b10,
            2'b00,
            3'b000
        );

    
        // I-Type
       
        check_control(
            7'b0010011,
            1,0,0,0,
            1,0,0,0,
            2'b10,
            2'b00,
            3'b000
        );

        
        // LOAD
        
        check_control(
            7'b0000011,
            1,1,0,1,
            1,0,0,0,
            2'b00,
            2'b00,
            3'b000
        );

        
        // STORE
        
        check_control(
            7'b0100011,
            0,0,1,0,
            1,0,0,0,
            2'b00,
            2'b00,
            3'b001
        );

    
        // BRANCH
       
        check_control(
            7'b1100011,
            0,0,0,0,
            0,1,0,0,
            2'b01,
            2'b00,
            3'b010
        );

        
        // JAL
    
        check_control(
            7'b1101111,
            1,0,0,0,
            0,0,1,0,
            2'b00,
            2'b00,
            3'b100
        );

        
        // LUI
       
        check_control(
            7'b0110111,
            1,0,0,0,
            1,0,0,0,
            2'b00,
            2'b10,
            3'b011
        );

     
        // AUIPC
       
        check_control(
            7'b0010111,
            1,0,0,0,
            1,0,0,0,
            2'b00,
            2'b01,
            3'b011
        );

        
        // JALR
        
        check_control(
            7'b1100111,
            1,0,0,0,
            1,0,0,1,
            2'b00,
            2'b00,
            3'b000
        );

        
        // Illegal Opcode
        check_control(
            7'b1111111,
            0,0,0,0,
            0,0,0,0,
            2'b00,
            2'b00,
            3'b000
        );

        // Summary
       
       
        $display("        CONTROL UNIT TEST SUMMARY");
        
        $display("TOTAL PASSED = %0d", pass_count);
        $display("TOTAL FAILED = %0d", fail_count);
        $display("=====================================\n");

        $finish;

    end

endmodule
