module instruction_decoder_tb;
    logic [31:0] instruction;
    logic [6:0]opcode;
    logic [4:0] rd;
    logic [4:0] rs1;
    logic [4:0] rs2;
    logic [2:0] funct3;
    logic [6:0] funct7;
    logic illegal_instr;
    
    instruction_decoder dut(
        .instruction(instruction),
        .opcode(opcode),
        .rd(rd),
        .rs1(rs1),
        .rs2(rs2),
        .funct3(funct3),
        .funct7(funct7),
        .illegal_instr(illegal_instr)
    );
    
    int pass_count = 0;
    int fail_count = 0;
    
    task automatic check_decoder(
        input logic [31:0] instr,
        input logic [6:0] exp_opcode,
        input logic [4:0] exp_rd,
        input logic [4:0] exp_rs1,
        input logic [4:0] exp_rs2,
        input logic [2:0] exp_funct3,
        input logic [6:0] exp_funct7,
        input logic exp_illegal
    );
    
        begin
    
            instruction = instr;
        
            #1;
        
            if (opcode !== exp_opcode || 
                rd !== exp_rd ||
                rs1 !== exp_rs1 || 
                rs2 !== exp_rs2 ||
                funct3 !== exp_funct3 ||
                funct7 !== exp_funct7 ||
                illegal_instr !== exp_illegal) begin
                    
                    $display("TESTCASE FAILED!");
                    $display("Instruction = %h",instr);
                    $display("Expected:");
                    $display("opcode=%h rd=%0d rs1=%0d rs2=%0d funct3=%h funct7=%h illegal=%b",
                         exp_opcode, exp_rd, exp_rs1, exp_rs2,
                         exp_funct3, exp_funct7, exp_illegal);

                    $display("Actual:");
                    $display("opcode=%h rd=%0d rs1=%0d rs2=%0d funct3=%h funct7=%h illegal=%b",
                             opcode, rd, rs1, rs2,
                             funct3, funct7, illegal_instr);
                    fail_count ++;
            end
            else begin
                $display("TESTCASE PASSED : %h", instr);
                pass_count++;
            end     
        end
    endtask
    
    initial begin

        // R TYPE: ADD x5,x6,x7
        check_decoder(
            32'h007302B3,
            7'b0110011,
            5'd5,
            5'd6,
            5'd7,
            3'b000,
            7'b0000000,
            1'b0
        );

        // R TYPE: SUB x5,x6,x7
        check_decoder(
            32'h407302B3,
            7'b0110011,
            5'd5,
            5'd6,
            5'd7,
            3'b000,
            7'b0100000,
            1'b0
        );
        
        // I TYPE: ADDI
        check_decoder(
            32'h00A30293,
            7'b0010011,
            5'd5,
            5'd6,
            5'd0,
            3'b000,
            7'd0,
            1'b0
        );
    
        // I TYPE: SLLI    
        check_decoder(
            32'h00331293,
            7'b0010011,
            5'd5,
            5'd6,
            5'd0,
            3'b001,
            7'b0000000,
            1'b0
        );
        
        // LOAD 
        check_decoder(
            32'h00032283,
            7'b0000011,
            5'd5,
            5'd6,
            5'd0,
            3'b010,
            7'd0,
            1'b0
        );
        
        // STORE
        check_decoder(
            32'h00532023,
            7'b0100011,
            5'd0,
            5'd6,
            5'd5,
            3'b010,
            7'd0,
            1'b0
        );
        
        // BRANCH: beq
        check_decoder(
            32'h00530063,
            7'b1100011,
            5'd0,
            5'd6,
            5'd5,
            3'b000,
            7'd0,
            1'b0
        );
        
        // JUMP: JALR
        check_decoder(
            32'h000302E7,
            7'b1100111,
            5'd5,
            5'd6,
            5'd0,
            3'b000,
            7'd0,
            1'b0
        );
        
        // U TYPE: LUI
        check_decoder(
            32'h123452B7,
            7'b0110111,
            5'd5,
            5'd0,
            5'd0,
            3'd0,
            7'd0,
            1'b0
        );
        
        // U TYPE: AUIPC 
        check_decoder(
            32'h12345297,
            7'b0010111,
            5'd5,
            5'd0,
            5'd0,
            3'd0,
            7'd0,
            1'b0
        );
        
        // JUMP: JAL
        check_decoder(
            32'h000002EF,
            7'b1101111,
            5'd5,
            5'd0,
            5'd0,
            3'd0,
            7'd0,
            1'b0
        );
        
        // Illegal instruction
        check_decoder(
            32'hFFFFFFFF,
            7'b1111111,
            5'd0,
            5'd0,
            5'd0,
            3'd0,
            7'd0,
            1'b1
        );

        $display("==================================");
        $display("TOTAL PASSED = %0d", pass_count);
        $display("TOTAL FAILED = %0d", fail_count);
        $display("==================================");

        $finish;

    end

endmodule
