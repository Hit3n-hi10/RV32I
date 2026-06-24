module control_unit_tb;
    logic [6:0]opcode;
    logic RegWrite;
    logic MemRead; 
    logic MemWrite;
    logic MemToReg; 
    logic ALUSrc;
    logic Branch, Jump, Jalr;
    logic [1:0]ALUOp; 
    logic [2:0] imm_sel;
    
    control_unit dut(
        .opcode(opcode),
        .RegWrite(RegWrite), 
        .MemRead(MemRead), 
        .MemWrite(MemWrite),
        .MemToReg(MemToReg), 
        .ALUSrc(ALUSrc), 
        .Branch(Branch), 
        .Jump(Jump),
        .Jalr(Jalr),
        .ALUOp(ALUOp), 
        .imm_sel(imm_sel)
    );
    
    int pass_count = 0;
    int fail_count = 0;
    
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
        input logic [2:0] exp_imm_sel
    );
        begin
            
            opcode = opcode_in;
    
            #1;
        
            if (RegWrite !== exp_RegWrite ||
                MemRead !== exp_MemRead ||
                MemWrite !== exp_MemWrite ||
                MemToReg !== exp_MemToReg ||
                ALUSrc !== exp_ALUSrc ||
                Branch !== exp_Branch ||
                Jump !== exp_Jump ||
                Jalr !== exp_Jalr ||
                ALUOp !== exp_ALUOp ||
                imm_sel !== exp_imm_sel ) begin
                
                    $display("TESTCASE FAILED!");
                    $display("Opcode = %b", opcode_in);
            
                    $display("Expected:");
                    $display("RegWrite=%b MemRead=%b MemWrite=%b MemToReg=%b",
                             exp_RegWrite, exp_MemRead,
                             exp_MemWrite, exp_MemToReg);
            
                    $display("ALUSrc=%b Branch=%b Jump=%b Jalr=%b ALUOp=%b imm_sel=%b",
                             exp_ALUSrc, exp_Branch,
                             exp_Jump, exp_Jalr,
                             exp_ALUOp, exp_imm_sel);
            
                    $display("Actual:");
                    $display("RegWrite=%b MemRead=%b MemWrite=%b MemToReg=%b",
                             RegWrite, MemRead,
                             MemWrite, MemToReg);
            
                    $display("ALUSrc=%b Branch=%b Jump=%b Jalr=%b ALUOp=%b imm_sel=%b",
                             ALUSrc, Branch,
                             Jump, Jalr, ALUOp,
                             imm_sel);
            
                    fail_count++;
               end
               else begin 
                   $display("TESTCASE PASSED : Opcode = %b", opcode_in);
                    pass_count++;
                end 
        end
    endtask
    
    initial begin 
    
        // R TYPE
        check_control(
            7'b0110011,
            1'b1, // RegWrite
            1'b0, // MemRead
            1'b0, // MemWrite
            1'b0, // MemToReg
            1'b0, // ALUSrc
            1'b0, // Branch
            1'b0, // Jump
            1'b0, // Jalr
            2'b10, // ALUOp
            3'b000 // I_Type (default)
        );
        
        // I TYPE 
        check_control(
            7'b0010011,
            1'b1,
            1'b0,
            1'b0,
            1'b0,
            1'b1,
            1'b0,
            1'b0,
            1'b0,
            2'b10,
            3'b000
        );
        
        // LOAD
        check_control(
            7'b0000011,
            1'b1,
            1'b1,
            1'b0,
            1'b1,
            1'b1,
            1'b0,
            1'b0,  
            1'b0,
            2'b00,
            3'b000
        );
        
        // STORE
        check_control(
            7'b0100011,
            1'b0,
            1'b0,
            1'b1,
            1'b0,
            1'b1,
            1'b0,
            1'b0,
            1'b0,
            2'b00,
            3'b001
        );
        
        // BRANCH
        check_control(
            7'b1100011,
            1'b0,
            1'b0,
            1'b0,
            1'b0,
            1'b0,
            1'b1,
            1'b0,
            1'b0,
            2'b01,
            3'b010
        );
        
        // JAL 
        check_control(
            7'b1101111,
            1'b1,
            1'b0,
            1'b0,
            1'b0,
            1'b0,
            1'b0,
            1'b1,
            1'b0,
            2'b00,
            3'b100
        );
        
        // LUI 
        check_control(
            7'b0110111,
            1'b1,
            1'b0,
            1'b0,
            1'b0,
            1'b1,
            1'b0,
            1'b0,
            1'b0,
            2'b00,
            3'b011
        );
        
        // AUIPC 
        check_control(
            7'b0010111,
            1'b1,
            1'b0,
            1'b0,
            1'b0,
            1'b1,
            1'b0,
            1'b0,
            1'b0,
            2'b00,
            3'b011
        );
        
        // JALR
        check_control(
            7'b1100111,        
            1'b1,
            1'b0,
            1'b0,
            1'b0,
            1'b1,
            1'b0,
            1'b0,
            1'b1,
            2'b00,
            3'b000
        );
        
        // ILLEGAL
        check_control(
            7'b1111111,
            1'b0,
            1'b0,
            1'b0,
            1'b0,
            1'b0,
            1'b0,
            1'b0,  
            1'b0,
            2'b00,
            3'b000
        );
        
        $display("==================================");
        $display("TOTAL PASSED = %0d", pass_count);
        $display("TOTAL FAILED = %0d", fail_count);
        $display("==================================");

        $finish;
    
    end 
    
endmodule
