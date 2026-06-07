`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06.06.2026 08:59:36
// Design Name: 
// Module Name: immediate_gen_tb
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

module imm_generator_tb();

logic [31:0] instruction;
logic [2:0] imm_sel;
logic [31:0] immediate;

parameter I_Type = 3'b000; 
parameter S_Type = 3'b001;
parameter B_Type = 3'b010; 
parameter U_Type = 3'b011; 
parameter J_Type = 3'b100;

imm_generator dut(
    .instruction(instruction),.imm_sel(imm_sel),.immediate(immediate)
);

int test_count;
int pass_count;
int fail_count;
// applying instructions
task apply_instruction(
    input [31:0] instr,
    input [2:0] sel
);
begin
    instruction = instr;
    imm_sel = sel;
    #1;
end
endtask
// task for checking 
task check_result(
    input string test_name,
    input [31:0] expected_immediate
);
begin

    test_count++;

    if(immediate == expected_immediate) begin
        pass_count++;
        $display("[PASS] %s", test_name);
    end
    else begin
        fail_count++;

        $display("[FAIL] %s", test_name);
        $display("Expected Immediate = %h",
                  expected_immediate);
        $display("Actual Immediate = %h",
                  immediate);
    end
end
endtask
// applying test stimulus
initial begin
    test_count = 0;
    pass_count = 0;
    fail_count = 0;
//I type:
    // addi x5,x0,10
    apply_instruction({12'd10,5'd0,3'b000,5'd5,7'b0010011},I_Type);
    check_result("ADD_POS",32'd10);
    // addi x5,x0,-5
    apply_instruction({12'hFFB,5'd0,3'b000,5'd5,7'b0010011},I_Type);
    check_result("ADD_NEG",32'hFFFFFFFB);
    // addi x5,x0,0
        apply_instruction({12'd0,5'd0,3'b000,5'd5,7'b0010011},I_Type);
        check_result("I_TYPE_ZERO",32'd0);
        // addi x5,x0,+2047
        apply_instruction({12'h7FF,5'd0,3'b000,5'd5,7'b0010011},I_Type);
        check_result("I_TYPE_MAX_POS",32'd2047);
        // addi x5,x0,-2048
        apply_instruction({12'h800,5'd0,3'b000,5'd5,7'b0010011},I_Type);
        check_result("I_TYPE_MAX_NEG",32'hFFFFF800);
    // lw x10,20(x2)
    apply_instruction({12'd20,5'd2,3'b010,5'd10,7'b0000011},I_Type);
    check_result("LW_POSITIVE",32'd20);
    // lw x10,-8(x2)
    apply_instruction({12'hFF8,5'd2,3'b010,5'd10,7'b0000011},I_Type);
    check_result("LW_NEGATIVE",32'hFFFFFFF8);
    // jalr x1,16(x5)
    apply_instruction({12'd16,5'd5,3'b000,5'd1,7'b1100111},I_Type);
    check_result("JALR",32'd16);

//S type:
    // sw x5,16(x2)
    apply_instruction(
        {7'b0000000,5'd5,5'd2,3'b010,5'b10000,7'b0100011},S_Type);
    check_result("SW_POS",32'd16);
    // sw x5,-8(x2)
    apply_instruction(
        {7'b1111111,5'd5,5'd2,3'b010,5'b11000,7'b0100011},S_Type);
    check_result("SW_NEG",32'hFFFFFFF8);
    // sw x5,0(x2)
    apply_instruction({7'b0000000,5'd5,5'd2,3'b010,5'b00000,7'b0100011},S_Type);
    check_result("S_TYPE_ZERO",32'd0);
    // sw x5,2047(x2)
    apply_instruction(
        {7'b0111111,5'd5,5'd2,3'b010,5'b11111,7'b0100011},S_Type);
    check_result("S_TYPE_MAX_POS",32'd2047);
    // sw x5,-2048(x2)
    apply_instruction(
        {7'b1000000,5'd5,5'd2,3'b010,5'b00000,7'b0100011},S_Type);
    check_result("S_TYPE_MAX_NEG",32'hFFFFF800);
    
//U type:
    // lui x10,0xABCDE
    apply_instruction({20'hABCDE,5'd10,7'b0110111},U_Type);
    check_result("LUI",32'hABCDE000);
 // lui x1,0
       apply_instruction({20'h00000,5'd1,7'b0110111},U_Type);
       check_result("U_TYPE_ZERO",32'h00000000);
       // lui x1,0x00001
       apply_instruction({20'h00001,5'd1,7'b0110111},U_Type);
       check_result("U_TYPE_MIN_NONZERO",32'h00001000);
       // lui x1,0xFFFFF
       apply_instruction(
           {20'hFFFFF,5'd1,7'b0110111},U_Type);
       check_result("U_TYPE_MAX",32'hFFFFF000);
    // auipc x15,0x12345
    apply_instruction({20'h12345,5'd15,7'b0010111},U_Type);
    check_result("AUIPC",32'h12345000);
    
//B type:

    // beq x1,x2,0
       apply_instruction({1'b0,6'b000000,5'd2,5'd1,3'b000,4'b0000,1'b0,7'b1100011},B_Type); 
       check_result("BEQ_ZERO",32'd0);
     // beq x1,x2,+16
     apply_instruction({1'b0,6'b000000,5'd2,5'd1,3'b000,4'b1000,1'b0,7'b1100011},B_Type);
      check_result("BEQ_POS",32'd16);
     // beq x1,x2,-16
      apply_instruction({1'b1,6'b111111,5'd2,5'd1,3'b000,4'b1000,1'b1,7'b1100011},B_Type);
      check_result("BEQ_NEG",32'hFFFFFFF0);                            

//J type: 
     // jal x1,0
       apply_instruction({1'b0,8'b00000000,1'b0,10'b0000000000,5'd1,7'b1101111},J_Type);
       check_result("JAL_ZERO",32'd0);
    // jal x1,+32
       apply_instruction({1'b0,10'b0000010000,1'b0,8'b00000000,5'd1,7'b1101111},J_Type);
       check_result("JAL_POS",32'd32);
    // jal x1,-32
        apply_instruction({1'b1,10'b1111110000,1'b1,8'b11111111,5'd1,7'b1101111},J_Type);
        check_result("JAL_NEG",32'hFFFFFFE0);   
//all zeros
     apply_instruction(32'h00000000,I_Type);
     check_result("ALL_ZEROS",32'd0);
//invalid opcode
     apply_instruction(32'hFFFFFFFF,3'b111);
     check_result("INVALID_IMM_SEL",32'd0);

    if(fail_count == 0)
        $display("All tests passed");
    else
        $display("Some tests failed");

    $finish;
end
endmodule
