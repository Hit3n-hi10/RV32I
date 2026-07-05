//RTL CODE
module program_counter (
    input  wire        clk,
    input  wire        rst_n,    
    input  wire [31:0] next_pc,
    output reg  [31:0] pc
);

    always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin        
      pc <= 32'h0000_0000;
    end
     else
      begin
            pc <= next_pc;
     end
    end
endmodule

