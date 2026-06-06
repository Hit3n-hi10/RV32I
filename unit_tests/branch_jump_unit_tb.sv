module branch_jump_unit_tb;
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

    Branch_Jump_Unit DUT (
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
    packet pkt;

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end 

    initial begin
        rst = 1;
        jump      = 0;
        jalr      = 0;
        brh       = 0;
        func_b    = 0;
        src_reg_1 = 0;
        src_reg_2 = 0;
        imm       = 0;
        pc_in     = 0;
        #10
        repeat (1) @(posedge clk);
        rst = 0;

        repeat (100) begin

            pkt = new();
            assert(pkt.randomize())
            else
                $fatal(1, "Randomization Failed");

            @(posedge clk);

            jump      <= pkt.jump;
            jalr      <= pkt.jalr;
            brh       <= pkt.brh;
            func_b    <= pkt.func_b;

            src_reg_1 <= pkt.src_reg_1;
            src_reg_2 <= pkt.src_reg_2;

            imm       <= pkt.imm;
            pc_in     <= pkt.pc_in;
        end

        $finish;
    end
    
endmodule
