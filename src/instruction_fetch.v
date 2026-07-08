module instruction_memory (
    input  wire [31:0] addr,
    output wire [31:0] instruction
);

    reg [31:0] mem [0:255];

    assign instruction = mem[addr[31:2]];

    initial begin
        mem[0]  = 32'h003100b3;
        mem[1]  = 32'h40628233;
        mem[2]  = 32'h009413b3;
        mem[3]  = 32'h00c5a533;
        mem[4]  = 32'h00f736b3;
        mem[5]  = 32'h0128c833;
        mem[6]  = 32'h015a59b3;
        mem[7]  = 32'h418bdb33;
        mem[8]  = 32'h01bd6cb3;
        mem[9]  = 32'h01eefe33;
        mem[10] = 32'h00500093;
        mem[11] = 32'h00a1a113;
        mem[12] = 32'h0062b213;
        mem[13] = 32'h0033c313;
        mem[14] = 32'h0074e413;
        mem[15] = 32'h00f5f513;
        mem[16] = 32'h00269613;
        mem[17] = 32'h0017d713;
        mem[18] = 32'h4038d813;
        mem[19] = 32'h00010083;
        mem[20] = 32'h00021183;
        mem[21] = 32'h00032283;
        mem[22] = 32'h00044383;
        mem[23] = 32'h00055483;
        mem[24] = 32'h00110023;
        mem[25] = 32'h00321023;
        mem[26] = 32'h00532023;
        mem[27] = 32'h00208c63;
        mem[28] = 32'h00419a63;
        mem[29] = 32'h0062c863;
        mem[30] = 32'h0083d663;
        mem[31] = 32'h00a4e463;
        mem[32] = 32'h00c5f263;
        mem[33] = 32'h123450b7;
        mem[34] = 32'h12345117;
        mem[35] = 32'h008000ef;
        mem[36] = 32'h00008167;
    end

endmodule
