module branch(
    input [31:0] src_reg_1, 
    input [31:0] src_reg_2, 
    input [31:0] imm, 
    input [31:0] pc_in,
    input [2:0] func_b,

    output reg [31:0] pc_out,
    output reg brh_taken
);

    always @(*)
    begin
        case(func_b)

            // BEQ
            3'b000: begin
                if(src_reg_1 == src_reg_2) begin
                    brh_taken = 1'b1;
                    pc_out = pc_in + imm;
                end
                else begin
                    brh_taken = 1'b0;
                    pc_out = pc_in + 4;
                end
            end

            // BNE
            3'b001: begin
                if(src_reg_1 != src_reg_2) begin
                    brh_taken = 1'b1;
                    pc_out = pc_in + imm;
                end
                else begin
                    brh_taken = 1'b0;
                    pc_out = pc_in + 4;
                end
            end

            // BLT
            3'b010: begin
                if($signed(src_reg_1) < $signed(src_reg_2)) begin
                    brh_taken = 1'b1;
                    pc_out = pc_in + imm;
                end
                else begin
                    brh_taken = 1'b0;
                    pc_out = pc_in + 4;
                end
            end

            // BGE
            3'b011: begin
                if($signed(src_reg_1) >= $signed(src_reg_2)) begin
                    brh_taken = 1'b1;
                    pc_out = pc_in + imm;
                end
                else begin
                    brh_taken = 1'b0;
                    pc_out = pc_in + 4;
                end
            end

            // BLTU
            3'b100: begin
                if(src_reg_1 < src_reg_2) begin
                    brh_taken = 1'b1;
                    pc_out = pc_in + imm;
                end
                else begin
                    brh_taken = 1'b0;
                    pc_out = pc_in + 4;
                end
            end

        // BGEU
        3'b101: begin
                if(src_reg_1 >= src_reg_2) begin
                    brh_taken = 1'b1;
                    pc_out = pc_in + imm;
                end
                else begin
                    brh_taken = 1'b0;
                    pc_out = pc_in + 4;
                end
            end

        default: begin
                brh_taken = 1'b0;
                pc_out = pc_in + 4;
            end
        endcase
    end

endmodule
