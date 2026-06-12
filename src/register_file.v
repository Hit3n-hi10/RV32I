// Inputs:
//   clk              - Clock signal
//   rst              - Active-high reset
//   regwrite         - Register write enable (from Control Unit)
//   rs1[4:0]         - Source Register 1 address
//   rs2[4:0]         - Source Register 2 address
//   rd[4:0]          - Destination Register address
//   wd[31:0]         - Write data from ALU/Write-back stage
//
// Outputs:
//   rd1[31:0]        - Data read from source register rs1
//   rd2[31:0]        - Data read from source register rs2
//
// Internal Storage:
//   registers[0:31]  - 32 General Purpose Registers
//                       each 32 bits wide
//
// Specifications:
//   Number of Registers = 32
//   Register Width      = 32 bits
//   Address Width       = 5 bits
//   x0 Register         = Hardwired to 0
//   Read Ports          = 2 (Combinational)
//   Write Ports         = 1 (Synchronous)

module register_file(
input clk,
input rst,
input regwrite,                //control signal from control unit, 1=allow writing

input[4:0] rs1,                //5-bit address of first source register 
input[4:0]rs2,
input[4:0]rd,

input [31:0] wd,         //write data , input that will be written in destination  (from ALU or….. )
output [31:0]rd1,                             //data stored in rs1
output[31:0]rd2
);

reg[31:0] registers[0:31];               //32 registers each of 32 bit 

integer i;

always @(posedge clk or posedge rst)
begin
if (rst) begin
for(i = 0; i < 32; i = i + 1)
registers[i] <= 32'b0;                  //non blocking assignment (simultaneously)
end

else  begin
if(regwrite&& rd!=0)          // as x0 always remain 0 in risc v
registers[rd]<=wd;  
end 
end

//Read ports
assign rd1 = (rs1 == 0) ? 32'b0 : registers[rs1];   //reads data from rs1
assign rd2 = (rs2 == 0) ? 32'b0 : registers[rs2];


endmodule
