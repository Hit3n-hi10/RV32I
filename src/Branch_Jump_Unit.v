module Branch_Jump_Unit (
    input rst,
    input jump,
    input jalr,
    input brh,
    input [2:0] func_b,
    input [31:0] src_reg_1,
    input [31:0] src_reg_2,
    input [31:0] imm,
    input [31:0] pc_in,

    output reg [31:0] pc_out,
    output reg [31:0] link_addr,
    output reg brh_taken,
    output reg jump_taken
);

wire [31:0] brh_pc_out;
wire brh_flag;

branch b1(
    .src_reg_1(src_reg_1),
    .src_reg_2(src_reg_2),
    .imm(imm),
    .pc_in(pc_in),
    .func_b(func_b),
    .pc_out(brh_pc_out),
    .brh_taken(brh_flag)
);

always @(*) begin

    // Default values
    pc_out     = pc_in + 32'd4;
    link_addr  = 32'd0;
    brh_taken  = 1'b0;
    jump_taken = 1'b0;

    if (rst) begin
        pc_out     = 32'd0;
        link_addr  = 32'd0;
        brh_taken  = 1'b0;
        jump_taken = 1'b0;
    end

    else if (brh) begin
        pc_out     = brh_pc_out;
        brh_taken  = brh_flag;
    end

    else if (jump) begin
        pc_out     = pc_in + imm;
        link_addr  = pc_in + 32'd4;
        jump_taken = 1'b1;
    end

    else if (jalr) begin
        pc_out     = (src_reg_1 + imm) & 32'hFFFFFFFE;
        link_addr  = pc_in + 32'd4;
        jump_taken = 1'b1;
    end

end

endmodule
