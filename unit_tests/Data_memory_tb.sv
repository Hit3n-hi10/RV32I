// Signals Driven:
//   clk          - 10ns clock
//   memread      - Read enable
//   memwrite     - Write enable
//   address[31:0]- Byte address input
//   write_data[31:0] - 32-bit data input
//
// Signals Observed:
//   read_data[31:0]  - 32-bit data output
//
// Tests         : 20 test cases, all passing
module tb_data_memory();

localparam N = 32;
localparam M = 256;

logic clk;
logic memread;
logic memwrite;
logic [31:0] address;
logic [N-1:0] write_data;
logic [N-1:0] read_data;

data_memory #(.M(M), .N(N)) dut (
    .clk (clk),
    .memread (memread),
    .memwrite (memwrite),
    .address (address),
    .write_data (write_data),
    .read_data (read_data)
);

int pass_count;
int fail_count;
int test_count;

always #5 clk = ~clk;

task apply_write(input [31:0] addr, input [N-1:0] data);
begin
    address    = addr;
    write_data = data;
    memwrite   = 1;
    memread    = 0;
    @(posedge clk); #1;
    memwrite   = 0;
end
endtask

task apply_read(input [31:0] addr);
begin
    address  = addr;
    memread  = 1;
    memwrite = 0;
    #1;
end
endtask

task check_results(input string test_name, input [N-1:0] expected_data);
begin
    test_count++;
    if (read_data == expected_data) begin
        pass_count++;
        $display("[PASS] %s", test_name);
    end
    else begin
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
    pass_count = 0;
    fail_count = 0;
    test_count = 0;

    @(posedge clk); #1;

    // Basic SW/LW operations
    apply_write(32'h00000000, 32'hDEADBEEF);
    apply_read(32'h00000000);
    check_results("SW/LW addr 0x000", 32'hDEADBEEF);

    apply_write(32'h00000004, 32'hCAFEBABE);
    apply_read(32'h00000004);
    check_results("SW/LW addr 0x004", 32'hCAFEBABE);

    apply_write(32'h00000008, 32'h12345678);
    apply_read(32'h00000008);
    check_results("SW/LW addr 0x008", 32'h12345678);

    // memread disabled
    apply_write(32'h00000010, 32'h99999999);
    address = 32'h00000010;
    memread = 0;
    memwrite = 0;
    #1;
    check_results("LW disabled (memread=0) gives 0", 32'h00000000);

    // memwrite disabled
    apply_write(32'h00000014, 32'h11111111);
    apply_read(32'h00000014);
    check_results("SW before disable test", 32'h11111111);

    address = 32'h00000014;
    write_data = 32'hFFFFFFFF;
    memwrite = 0;
    memread = 0;
    @(posedge clk); #1;

    apply_read(32'h00000014);
    check_results("SW disabled (memwrite=0) memory unchanged", 32'h11111111);

    // Overwrite same address
    apply_write(32'h00000018, 32'hAAAAAAAA);
    apply_write(32'h00000018, 32'h55555555);
    apply_read(32'h00000018);
    check_results("SW overwrite same address", 32'h55555555);

    // Misaligned accesses
    apply_write(32'h00000020, 32'hAAAAAAAA);

    apply_read(32'h00000020);
    check_results("Aligned access 0x20", 32'hAAAAAAAA);

    apply_read(32'h00000021);
    check_results("Misaligned +1 byte (0x21)", 32'hAAAAAAAA);

    apply_read(32'h00000022);
    check_results("Misaligned +2 bytes (0x22)", 32'hAAAAAAAA);

    apply_read(32'h00000023);
    check_results("Misaligned +3 bytes (0x23)", 32'hAAAAAAAA);

    // Out-of-range addresses
    apply_write(32'hFFFFFFFF, 32'hFACEB00C);
    apply_read(32'h000003FC);
    check_results("Invalid addr 0xFFFFFFFF maps to last location",
                  32'hFACEB00C);

    apply_write(32'h000000A0, 32'h13579BDF);
    apply_read(32'h000004A0);
    check_results("Invalid addr 0x4A0 wraps to same as 0xA0",
                  32'h13579BDF);

    // Simultaneous read/write
    apply_write(32'h00000030, 32'hAAAA0000);
    apply_read(32'h00000030);
    check_results("Pre-load before RW conflict", 32'hAAAA0000);

    address    = 32'h00000030;
    write_data = 32'h5555FFFF;
    memread    = 1;
    memwrite   = 1;
    #1;

    check_results("RW conflict: LW sees OLD value before posedge",
                  32'hAAAA0000);

    @(posedge clk); #1;

    memwrite = 0;
    memread  = 1;
    #1;

    check_results("RW conflict: LW sees NEW value after posedge",
                  32'h5555FFFF);

    memread = 0;

    // Boundary addresses
    apply_write(32'h000003FC, 32'hBEEFBEEF);
    apply_read(32'h000003FC);
    check_results("SW/LW last addr 0x3FC", 32'hBEEFBEEF);

    apply_read(32'h00000000);
    check_results("LW first addr 0x000 still intact", 32'hDEADBEEF);

    // Data pattern tests
    apply_write(32'h00000040, 32'h00000000);
    apply_read(32'h00000040);
    check_results("SW/LW all zeros", 32'h00000000);

    apply_write(32'h00000044, 32'hFFFFFFFF);
    apply_read(32'h00000044);
    check_results("SW/LW all ones", 32'hFFFFFFFF);

    $display("");
    $display("N (data width) = %0d bits", N);
    $display("M (memory depth) = %0d locations", M);
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
