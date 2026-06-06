module Branch_Jump_Unit_tb();

logic clk;
logic rst;
logic jump;
logic jalr;
logic brh;

logic [2:0] func_b;
logic [31:0] src_reg_1;
logic [31:0] src_reg_2;
logic [31:0] imm;
logic [31:0] pc_in;

logic [31:0] pc_out;
logic [31:0] link_addr;
logic brh_taken;
logic jump_taken;

parameter BEQ  = 3'b000;
parameter BNE  = 3'b001;
parameter BLT  = 3'b010;
parameter BGE  = 3'b011;
parameter BLTU = 3'b100;
parameter BGEU = 3'b101;

Branch_Jump_Unit x(
    .clk(clk),
    .rst(rst),
    .jump(jump),
    .jalr(jalr),
    .brh(brh),
    .func_b(func_b),
    .src_reg_1(src_reg_1),
    .src_reg_2(src_reg_2),
    .imm(imm),
    .pc_in(pc_in),
    .pc_out(pc_out),
    .link_addr(link_addr),
    .brh_taken(brh_taken),
    .jump_taken(jump_taken)
);

int pass_count;
int fail_count;
int test_count;

always #5 clk = ~clk;

task apply_inputs(
    input rst_in,
    input jump_in,
    input jalr_in,
    input brh_in,
    input [2:0] func_b_in,
    input [31:0] rs1_in,
    input [31:0] rs2_in,
    input [31:0] imm_in,
    input [31:0] pc_in_val
);
begin
    rst       = rst_in;
    jump      = jump_in;
    jalr      = jalr_in;
    brh       = brh_in;
    func_b    = func_b_in;
    src_reg_1 = rs1_in;
    src_reg_2 = rs2_in;
    imm       = imm_in;
    pc_in     = pc_in_val;
    @(posedge clk);
    #1;
end
endtask

task check_results(
    input string test_name,
    input [31:0] expected_pc,
    input [31:0] expected_link,
    input expected_brh_taken,
    input expected_jump_taken
);
begin
    test_count++;

    if((pc_out == expected_pc) &&
       (link_addr == expected_link) &&
       (brh_taken == expected_brh_taken) &&
       (jump_taken == expected_jump_taken))
    begin
        pass_count++;
        $display("[PASS] %s", test_name);
    end
    else begin
        fail_count++;
        $display("[FAIL] %s", test_name);
        $display("Expected: pc_out=%h link_addr=%h brh_taken=%b jump_taken=%b",
                 expected_pc, expected_link,
                 expected_brh_taken, expected_jump_taken);
        $display("Actual  : pc_out=%h link_addr=%h brh_taken=%b jump_taken=%b",
                 pc_out, link_addr,
                 brh_taken, jump_taken);
    end
end
endtask

initial begin

    clk = 0;

    apply_inputs(1,0,0,0,3'b000,0,0,0,0);
    check_results("RESET",32'h00000000,32'h00000000,0,0);

    apply_inputs(0,0,0,0,3'b000,0,0,0,32'd100);
    check_results("PC_INCREMENT",32'd104,32'h00000000,0,0);

    apply_inputs(0,1,0,0,3'b000,0,0,32'd20,32'd100);
    check_results("JAL",32'd120,32'd104,0,1);

    apply_inputs(0,0,1,0,3'b000,32'd200,0,32'd12,32'd100);
    check_results("JALR",32'd212,32'd104,0,1);

    apply_inputs(0,0,0,1,BEQ,32'd10,32'd10,32'd16,32'd100);
    check_results("BEQ_TAKEN",32'd116,32'd104,1,0);

    apply_inputs(0,0,0,1,BEQ,32'd10,32'd20,32'd16,32'd100);
    check_results("BEQ_NOT_TAKEN",32'd104,32'd104,0,0);

    apply_inputs(0,0,0,1,BNE,32'd10,32'd20,32'd12,32'd100);
    check_results("BNE_TAKEN",32'd112,32'd104,1,0);

    apply_inputs(0,0,0,1,BLT,-32'd5,32'd10,32'd8,32'd100);
    check_results("BLT_TAKEN",32'd108,32'd104,1,0);

    apply_inputs(0,0,0,1,BGE,32'd20,32'd10,32'd8,32'd100);
    check_results("BGE_TAKEN",32'd108,32'd104,1,0);

    apply_inputs(0,0,0,1,BLTU,32'd5,32'd10,32'd24,32'd100);
    check_results("BLTU_TAKEN",32'd124,32'd104,1,0);

    apply_inputs(0,0,0,1,BGEU,32'd20,32'd10,32'd24,32'd100);
    check_results("BGEU_TAKEN",32'd124,32'd104,1,0);

    apply_inputs(0,0,0,1,3'b111,32'd1,32'd2,32'd16,32'd100);
    check_results("INVALID_BRANCH",32'd104,32'd104,0,0);

    apply_inputs(0,0,0,1,BEQ,32'd5,32'd5,32'h7FFFFFFC,32'd100);
    check_results("BEQ_MAX_POS_OFFSET",32'h80000060,32'd104,1,0);

    apply_inputs(0,0,0,1,BEQ,32'd10,32'd10,-32'd20,32'd100);
    check_results("BEQ_NEG_OFFSET",32'd80,32'd104,1,0);

    apply_inputs(0,1,0,0,3'b000,0,0,-32'd40,32'd100);
    check_results("JAL_BACKWARD",32'd60,32'd104,0,1);

    apply_inputs(0,0,1,0,3'b000,32'd101,0,32'd2,32'd100);
    check_results("JALR_ALIGNMENT",32'd102,32'd104,0,1);

    apply_inputs(0,0,0,1,BLT,32'h80000000,32'h7FFFFFFF,32'd8,32'd100);
    check_results("BLT_SIGNED_EXTREME",32'd108,32'd104,1,0);

    apply_inputs(0,0,0,1,BGE,32'h7FFFFFFF,32'h80000000,32'd8,32'd100);
    check_results("BGE_SIGNED_EXTREME",32'd108,32'd104,1,0);

    apply_inputs(0,0,0,1,BLTU,32'h00000000,32'hFFFFFFFF,32'd12,32'd100);
    check_results("BLTU_EXTREME",32'd112,32'd104,1,0);

    apply_inputs(0,0,0,1,BGEU,32'hFFFFFFFF,32'h00000000,32'd12,32'd100);
    check_results("BGEU_EXTREME",32'd112,32'd104,1,0);

    apply_inputs(0,0,0,0,3'b000,0,0,0,32'hFFFFFFFC);
    check_results("PC_OVERFLOW",32'h00000000,32'd104,0,0);

    apply_inputs(0,0,0,1,BEQ,32'd10,32'd10,32'd0,32'd100);
    check_results("BEQ_ZERO_OFFSET",32'd100,32'd104,1,0);

    apply_inputs(0,1,1,0,3'b000,32'd200,0,32'd20,32'd100);
    check_results("JUMP_JALR_PRIORITY",32'd120,32'd104,0,1);

    apply_inputs(0,0,0,0,3'b000,0,0,0,0);
    check_results("ALL_ZERO_INPUTS",32'd4,32'd104,0,0);

    $display("");    
    $display("Tests Run : %0d", test_count);
    $display("Passed    : %0d", pass_count);
    $display("Failed    : %0d", fail_count);


    if(fail_count == 0)
        $display("ALL TESTS PASSED!");
    else
        $display("SOME TESTS FAILED!");

    $finish;

end

endmodule
