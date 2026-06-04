module ALU_Control_tb();

logic [1:0] ALU_op;
logic [2:0] funct3;
logic [6:0] funct7;

logic [3:0] alu_op;

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

ALU_Control alu_control_block(.ALU_op(ALU_op),.funct3(funct3),.funct7(funct7),.alu_op(alu_op));

int pass_count;
int fail_count;
int test_count;

// for applying input 
task apply_inputs(
   input [1:0] ALU_op_in,
   input [2:0] funct3_in,
   input [6:0] funct7_in
    );
    
    begin
        ALU_op = ALU_op_in;
        funct3 = funct3_in;
        funct7 = funct7_in;
        #1;
    end
    
endtask

// for verifying results
task check_results(
    input string test_name,
    input [3:0] expected_alu_op
);
 begin 
    test_count++;
    
    if(alu_op == expected_alu_op) begin
        pass_count++;
        $display("[PASS] %s",test_name);
        end
    else begin 
        fail_count++;
        $display("[FAIL] %s",test_name);
        
        $display("Expected alu_op:%b",expected_alu_op);
        $display("Actual alu_op:%b",alu_op);
    end
 
end

endtask

//Giving test stimulus
initial begin 
    
    // Load/Store
    apply_inputs(2'b00,3'b000,7'b0000000);
    check_results("ADD_LD/SW",ALU_ADD);
    
    //BEQ
    apply_inputs(2'b01,3'b000,7'b0000000);
    check_results("Branch Compare",ALU_SUB);
    
    //ADD
    apply_inputs(2'b10,3'b000,7'b0000000);
    check_results("ADD",ALU_ADD);
    
    //SUB
    apply_inputs(2'b10,3'b000,7'b0100000);
    check_results("ADD",ALU_SUB);
    
    //SLL
    apply_inputs(2'b10,3'b001,7'b0000000);
    check_results("SLL",ALU_SLL);
    
    //SLT
    apply_inputs(2'b10,3'b010,7'b0000000);
    check_results("SLT",ALU_SLT);
    
    //SLTU
    apply_inputs(2'b10,3'b011,7'b0000000);
    check_results("SLTU",ALU_SLTU);
    
     //XOR
    apply_inputs(2'b10,3'b100,7'b0000000);
    check_results("XOR",ALU_XOR);
    
     //SRL
    apply_inputs(2'b10,3'b101,7'b0000000);
    check_results("SRL",ALU_SRL);
    
     //SRA
    apply_inputs(2'b10,3'b101,7'b0100000);
    check_results("SRA",ALU_SRA);
    
     //OR
    apply_inputs(2'b10,3'b110,7'b0000000);
    check_results("OR",ALU_OR);
    
     //AND
    apply_inputs(2'b10,3'b111,7'b0000000);
    check_results("AND",ALU_AND);
    
    // invalid alu_op (default case)
    apply_inputs(2'b11,3'b000,7'b0000000);
    check_results("INVALID_ALUOP",ALU_ADD); 
    
    // except 0100000 all will give SRL
    apply_inputs(2'b10,3'b101,7'b1111111);
    check_results("INVALID_FUNCT7_SHIFT",ALU_SRL);
    
    //invlid funct7 -> ADD as per default case 
    apply_inputs(2'b10,3'b000,7'b1111111);
    check_results("INVALID_FUNCT7_ADD",ALU_ADD);
    
    if (fail_count == 0) begin
      $display("All tests passed!");
    end else begin
      $display("Some tests failed!");
    end

    $finish;
    
end

endmodule
