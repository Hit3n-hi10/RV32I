module ALU(
    input [31:0] A,
    input [31:0] B,
    input [3:0] alu_op,
    output reg [31:0] result,
    output zero
    );
    
    //ALU operation code
    parameter ALU_ADD = 4'b0000;
    parameter ALU_SUB = 4'b0001;
    parameter ALU_AND = 4'b0010;
    parameter ALU_OR  = 4'b0011;
    parameter ALU_XOR = 4'b0100;
    parameter ALU_SLT = 4'b0101;
    parameter ALU_SLTU = 4'b0110;
    parameter ALU_SLL = 4'b0111;
    parameter ALU_SRL = 4'b1000;
    parameter ALU_SRA = 4'b1001;
    
    always@(*) begin
    	result = 32'd0;
    case(alu_op)
        ALU_ADD: result = A+B;
        ALU_SUB: result = A-B;
        ALU_AND: result = A&B;
        ALU_OR: result = A|B;
        ALU_XOR: result = A^B;
        ALU_SLT: result = ($signed(A) < $signed(B))?32'd1:32'd0 ;
        ALU_SLTU: result = (A<B)?32'd1:32'd0;
        ALU_SLL: result = A << B[4:0]; // since 32bit instruction so max shift 32 i.e 2^5 = 32
        ALU_SRL: result = A >> B[4:0];
        ALU_SRA: result = $signed(A) >>> B[4:0];
        default: result = 32'd0;
    endcase
    
    end
    assign zero = (result==32'd0)?1:0;
    
endmodule
