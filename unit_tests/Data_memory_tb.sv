module tb_data_memory();

localparam N = 32;
localparam M = 256;

logic  clk;
logic  memread;
logic  memwrite;
logic [31:0] address;
logic [N-1:0] write_data;
logic [N-1:0] read_data;

data_memory #(.M(M), .N(N)) dut (
    .clk(clk),
    .memread(memread),
    .memwrite(memwrite),
    .address(address),
    .write_data(write_data),
    .read_data(read_data)
);

int pass_count;
int fail_count;
int test_count;

always #5 clk = ~clk;

localparam [31:0] MASK = (N==32) ? 32'hFFFFFFFF : ((1 << N) - 1);

task apply_write(
    input [31:0] addr,
    input [N-1:0] data
);
begin
    address = addr;
    write_data = data;
    memwrite = 1;
    memread = 0;
    @(posedge clk);
    #1;
    memwrite = 0;
end
endtask

task apply_read(
    input [31:0] addr
);
begin
    address= addr;
    memread =1;
    memwrite= 0;
    #1;
end
endtask

task check_results(
    input string test_name,
    input [N-1:0] expected_data
);
begin
    test_count++;
    if (read_data == expected_data) begin
        pass_count++;
        $display("[PASS] %s", test_name);
    end else begin
        fail_count++;
        $display("[FAIL] %s", test_name);
        $display("Expected: read_data=%h", expected_data);
        $display("Actual  : read_data=%h", read_data);
    end
end
endtask

initial begin

    clk = 0;
    memread = 0;
    memwrite = 0;
    address = 0;
    write_data = 0;
    @(posedge clk); #1;

    apply_write(32'h00000000, N'(32'hDEADBEEF & MASK));
    apply_read(32'h00000000);
    check_results("Write/Read 0x000", N'(32'hDEADBEEF & MASK));

    apply_write(32'h00000004, N'(32'hCAFEBABE & MASK));
    apply_read(32'h00000004);
    check_results("Write/Read 0x004", N'(32'hCAFEBABE & MASK));

    apply_write(32'h00000008, N'(32'h12345678 & MASK));
    apply_read(32'h00000008);
    check_results("Write/Read 0x008", N'(32'h12345678 & MASK));

    apply_write(32'h0000000C, N'(32'hABCDABCD & MASK));
    apply_read(32'h0000000C);
    check_results("Write/Read 0x00C", N'(32'hABCDABCD & MASK));

    apply_write(32'h00000010, N'(32'hAAAAAAAA & MASK));
    apply_read(32'h00000010);
    check_results("Word Align 0x10", N'(32'hAAAAAAAA & MASK));

    apply_read(32'h00000011);
    check_results("Word Align 0x11 same as 0x10", N'(32'hAAAAAAAA & MASK));

    apply_read(32'h00000012);
    check_results("Word Align 0x12 same as 0x10", N'(32'hAAAAAAAA & MASK));

    apply_read(32'h00000013);
    check_results("Word Align 0x13 same as 0x10", N'(32'hAAAAAAAA & MASK));

    apply_write(32'h00000020, N'(32'h99999999 & MASK));
    address = 32'h00000020; memread = 0; memwrite = 0; #1;
    check_results("memread=0 gives 0", {N{1'b0}});

    apply_write(32'h00000024, N'(32'h11111111 & MASK));
    apply_read(32'h00000024);
    check_results("Before memwrite=0 test", N'(32'h11111111 & MASK));

    address = 32'h00000024; write_data = N'(32'hFFFFFFFF & MASK);
    memwrite = 0; memread = 0;
    @(posedge clk); #1;
    apply_read(32'h00000024);
    check_results("memwrite=0 memory unchanged", N'(32'h11111111 & MASK));

    apply_write(32'h00000028, N'(32'hAAAAAAAA & MASK));
    apply_read(32'h00000028);
    check_results("First write 0xAAAAAAAA", N'(32'hAAAAAAAA & MASK));

    apply_write(32'h00000028, N'(32'h55555555 & MASK));
    apply_read(32'h00000028);
    check_results("Overwrite 0x55555555", N'(32'h55555555 & MASK));

    apply_write(32'h00000030, N'(32'h00000001 & MASK));
    apply_write(32'h00000034, N'(32'h00000002 & MASK));
    apply_write(32'h00000038, N'(32'h00000003 & MASK));

    apply_read(32'h00000030);
    check_results("Location 0x30 = 1", N'(32'h00000001 & MASK));

    apply_read(32'h00000034);
    check_results("Location 0x34 = 2", N'(32'h00000002 & MASK));

    apply_read(32'h00000038);
    check_results("Location 0x38 = 3", N'(32'h00000003 & MASK));

    apply_write(32'h000003FC, N'(32'hBEEFBEEF & MASK));
    apply_read(32'h000003FC);
    check_results("Last addr 0x3FC", N'(32'hBEEFBEEF & MASK));

    apply_read(32'h00000000);
    check_results("First addr 0x000 intact", N'(32'hDEADBEEF & MASK));

    apply_write(32'h00000040, N'(32'h00000000 & MASK));
    apply_read(32'h00000040);
    check_results("Write all zeros", {N{1'b0}});

    apply_write(32'h00000044, N'(32'hFFFFFFFF & MASK));
    apply_read(32'h00000044);
    check_results("Write all ones", N'(32'hFFFFFFFF & MASK));

    apply_write(32'h00000050, N'(32'hAAAA0000 & MASK));
    apply_read(32'h00000050);
    check_results("Pre-load 0x50", N'(32'hAAAA0000 & MASK));

    address = 32'h00000050; write_data = N'(32'h5555FFFF & MASK);
    memread = 1; memwrite = 1; #1;
    check_results("Simultaneous OLD value before posedge", N'(32'hAAAA0000 & MASK));

    @(posedge clk); #1;
    memwrite = 0; memread = 1; #1;
    check_results("Simultaneous NEW value after posedge", N'(32'h5555FFFF & MASK));
    memread = 0;

    apply_write(32'h00000060, N'(32'h00000001 & MASK));
    apply_write(32'h00000060, N'(32'h00000002 & MASK));
    apply_write(32'h00000060, N'(32'h00000003 & MASK));
    apply_write(32'h00000060, N'(32'hDEAD1234 & MASK));
    apply_read(32'h00000060);
    check_results("Sequential writes last wins", N'(32'hDEAD1234 & MASK));

    apply_write(32'h00000070, N'(32'hFACEFACE & MASK));
    apply_write(32'h00000070, N'(32'h00000000 & MASK));
    apply_read(32'h00000070);
    check_results("Zero clears location", {N{1'b0}});

    apply_write(32'h00000070, N'(32'hBEEFCAFE & MASK));
    apply_read(32'h00000070);
    check_results("Write after zero", N'(32'hBEEFCAFE & MASK));

    apply_write(32'h00000080, N'(32'hAABBCCDD & MASK));
    apply_write(32'h00000084, N'(32'h11223344 & MASK));
    apply_write(32'h00000088, N'(32'h55667788 & MASK));

    memread = 1; memwrite = 0;
    address = 32'h00000080; #1;
    check_results("Sweep 0x80", N'(32'hAABBCCDD & MASK));

    address = 32'h00000084; #1;
    check_results("Sweep 0x84", N'(32'h11223344 & MASK));

    address = 32'h00000088; #1;
    check_results("Sweep 0x88", N'(32'h55667788 & MASK));

    address = 32'h00000084; #1;
    check_results("Sweep back 0x84", N'(32'h11223344 & MASK));

    address = 32'h00000080; #1;
    check_results("Sweep back 0x80", N'(32'hAABBCCDD & MASK));
    memread = 0;

    $display("");
    $display("========================================");
    $display("N (data width) = %0d bits", N);
    $display("M (memory depth) = %0d locations", M);
    $display("========================================");
    $display("Tests Run : %0d", test_count);
    $display("Passed    : %0d", pass_count);
    $display("Failed    : %0d", fail_count);

    if (fail_count == 0)
        $display("ALL TESTS PASSED!");
    else
        $display("SOME TESTS FAILED!");

    $finish;

end
endmodule
