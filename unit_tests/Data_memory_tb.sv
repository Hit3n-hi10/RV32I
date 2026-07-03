// Signals Driven:
//   clk          - 10ns clock
//   memread      - Read enable
//   memwrite     - Write enable
//   funct3[2:0]  - Load/store type selector
//   address[31:0]- Byte address input
//   write_data[31:0] - 32-bit data input
//
// Signals Observed:
//   read_data[31:0]  - 32-bit data output
module tb_data_memory();

localparam N = 32;
localparam M = 256;

// funct3 encodings
localparam F3_B  = 3'b000; // LB / SB
localparam F3_H  = 3'b001; // LH / SH
localparam F3_W  = 3'b010; // LW / SW
localparam F3_BU = 3'b100; // LBU
localparam F3_HU = 3'b101; // LHU

logic        clk;
logic        memread;
logic        memwrite;
logic [2:0]  funct3;
logic [31:0] address;
logic [N-1:0] write_data;
logic [N-1:0] read_data;

data_memory #(.M(M), .N(N)) dut (
    .clk        (clk),
    .memread    (memread),
    .memwrite   (memwrite),
    .funct3     (funct3),
    .address    (address),
    .write_data (write_data),
    .read_data  (read_data)
);

int pass_count;
int fail_count;
int test_count;

always #5 clk = ~clk;

int           written_idx  [0:19];
logic [N-1:0] written_data [0:19];

// funct3 defaults to F3_W so all original call sites work without change
task apply_write(input [31:0] addr, input [N-1:0] data, input [2:0] f3 = F3_W);
begin
    address    = addr;
    write_data = data;
    funct3     = f3;
    memwrite   = 1;
    memread    = 0;
    @(posedge clk); #1;
    memwrite   = 0;
end
endtask

task apply_read(input [31:0] addr, input [2:0] f3 = F3_W);
begin
    address  = addr;
    funct3   = f3;
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
    end else begin
        fail_count++;
        $display("[FAIL] %s", test_name);
        $display("Expected: read_data=%h", expected_data);
        $display("Actual  : read_data=%h", read_data);
    end
end
endtask

int          rand_word_idx;
logic [31:0] rand_addr;
logic [31:0] rand_data;

initial begin

    clk        = 0;
    memread    = 0;
    memwrite   = 0;
    funct3     = F3_W;
    address    = 0;
    write_data = 0;
    pass_count = 0;
    fail_count = 0;
    test_count = 0;

    @(posedge clk); #1;

    // -- Uninitialized Read --
    // memory[] is not initialized; read before write returns 'x' in simulation
    $display("\n-- Uninitialized Read Test --");
    apply_read(32'h00000050);
    $display("[INFO] Uninitialized read at 0x50: %h (expected: x/undefined)", read_data);
    memread = 0;

    // -- Basic SW/LW --
    $display("\n-- Basic SW/LW Tests --");
    apply_write(32'h00000000, 32'hDEADBEEF);
    apply_read(32'h00000000);
    check_results("SW/LW addr 0x000", 32'hDEADBEEF);

    apply_write(32'h00000004, 32'hCAFEBABE);
    apply_read(32'h00000004);
    check_results("SW/LW addr 0x004", 32'hCAFEBABE);

    apply_write(32'h00000008, 32'h12345678);
    apply_read(32'h00000008);
    check_results("SW/LW addr 0x008", 32'h12345678);

    // -- Control Signal Tests --
    $display("\n-- Control Signal Tests --");

    // memread=0 -> output must be 0
    apply_write(32'h00000010, 32'h99999999);
    address = 32'h00000010; funct3 = F3_W; memread = 0; memwrite = 0; #1;
    check_results("LW disabled (memread=0) gives 0", 32'h00000000);

    // memwrite=0 -> memory must not change
    apply_write(32'h00000014, 32'h11111111);
    apply_read(32'h00000014);
    check_results("SW before disable test", 32'h11111111);
    address = 32'h00000014; write_data = 32'hFFFFFFFF; funct3 = F3_W;
    memwrite = 0; memread = 0;
    @(posedge clk); #1;
    apply_read(32'h00000014);
    check_results("SW disabled (memwrite=0) memory unchanged", 32'h11111111);

    // Overwrite same address -> latest write wins
    apply_write(32'h00000018, 32'hAAAAAAAA);
    apply_write(32'h00000018, 32'h55555555);
    apply_read(32'h00000018);
    check_results("SW overwrite same address", 32'h55555555);

    //  Back-to-Back Writes 
    $display("\n-- Back-to-Back Write Tests --");
    apply_write(32'h0000005C, 32'hAABBCCDD);
    apply_write(32'h00000060, 32'h11223344);
    apply_read(32'h0000005C);
    check_results("Back-to-back write: addr 0x5C", 32'hAABBCCDD);
    apply_read(32'h00000060);
    check_results("Back-to-back write: addr 0x60", 32'h11223344);

    //  Simultaneous Read+Write 
    // Write is sync (posedge), read is async.
    // Before posedge: read sees old value. After posedge: read sees new value.
    $display("\n-- Simultaneous Read+Write Tests --");
    apply_write(32'h00000064, 32'hDEAD1234);
    apply_read(32'h00000064);
    check_results("Pre-load before simultaneous RW", 32'hDEAD1234);
    address = 32'h00000064; write_data = 32'h5A5A5A5A; funct3 = F3_W;
    memread = 1; memwrite = 1; #1;
    check_results("Simultaneous RW: read sees OLD value before posedge", 32'hDEAD1234);
    @(posedge clk); #1;
    memwrite = 0; memread = 1; #1;
    check_results("Simultaneous RW: read sees NEW value after posedge", 32'h5A5A5A5A);
    memread = 0;

    //  Address Truncation (Misaligned Access) 
    // DUT ignores address[1:0]. 0x21/0x22/0x23 all map to same word as 0x20.
    // This documents truncation behavior - DUT does not flag misaligned access.
    $display("\n-- Address Truncation Tests --");
    apply_write(32'h00000020, 32'hAAAAAAAA);
    apply_read(32'h00000020);
    check_results("Aligned access 0x20",                 32'hAAAAAAAA);
    apply_read(32'h00000021);
    check_results("0x21 truncates to same word as 0x20", 32'hAAAAAAAA);
    apply_read(32'h00000022);
    check_results("0x22 truncates to same word as 0x20", 32'hAAAAAAAA);
    apply_read(32'h00000023);
    check_results("0x23 truncates to same word as 0x20", 32'hAAAAAAAA);

    //  Out-of-Range Address Wrap 
    // Only address[9:2] used for indexing (M=256, ADDR_WIDTH=8). Upper bits ignored.
    // 0xFFFFFFFF -> address[9:2] = 0xFF = index 255 = 0x3FC
    // 0x4A0 and 0xA0 -> address[9:2] = 0x28 = index 40 (same slot)
    $display("\n-- Out-of-Range Address Wrap Tests --");
    apply_write(32'hFFFFFFFF, 32'hFACEB00C);
    apply_read(32'h000003FC);
    check_results("0xFFFFFFFF maps to index 255 (same as 0x3FC)", 32'hFACEB00C);
    apply_write(32'h000000A0, 32'h13579BDF);
    apply_read(32'h000004A0);
    check_results("0x4A0 and 0xA0 map to same index",             32'h13579BDF);

    //  Read/Write Conflict 
    // Spec-undefined behavior. DUT result: read sees old value before posedge,
    // new value after posedge (sync write, async read).
    $display("\n-- Read/Write Conflict Tests --");
    apply_write(32'h00000030, 32'hAAAA0000);
    apply_read(32'h00000030);
    check_results("Pre-load before RW conflict", 32'hAAAA0000);
    address = 32'h00000030; write_data = 32'h5555FFFF; funct3 = F3_W;
    memread = 1; memwrite = 1; #1;
    check_results("RW conflict: read sees OLD value before posedge", 32'hAAAA0000);
    @(posedge clk); #1;
    memwrite = 0; memread = 1; #1;
    check_results("RW conflict: read sees NEW value after posedge",  32'h5555FFFF);
    memread = 0;

    // -- Boundary Addresses --
    $display("\n-- Boundary Address Tests --");
    apply_write(32'h000003FC, 32'hBEEFBEEF);
    apply_read(32'h000003FC);
    check_results("SW/LW last addr 0x3FC",           32'hBEEFBEEF);
    apply_read(32'h00000000);
    check_results("LW first addr 0x000 still intact", 32'hDEADBEEF);
    apply_write(32'h00000040, 32'h00000000);
    apply_read(32'h00000040);
    check_results("SW/LW all zeros",                  32'h00000000);
    apply_write(32'h00000044, 32'hFFFFFFFF);
    apply_read(32'h00000044);
    check_results("SW/LW all ones",                   32'hFFFFFFFF);

    // -- Randomized SW/LW (indices 18 to M-1) --
    $display("\n-- Randomized SW/LW Tests --");
    for (int i = 0; i < 20; i++) begin
        rand_word_idx    = $urandom_range(18, M-1);
        rand_addr        = rand_word_idx << 2;
        rand_data        = $urandom();
        written_idx[i]   = rand_word_idx;
        written_data[i]  = rand_data;
        apply_write(rand_addr, rand_data);
        apply_read(rand_addr);
        check_results($sformatf("Rand SW/LW word[%0d]", rand_word_idx), rand_data);
    end

    // -- Randomized Readback Integrity --
    // Re-read all 20 locations to confirm no unintended overwrites
    $display("\n-- Randomized Readback Integrity Check --");
    for (int i = 0; i < 20; i++) begin
        apply_read(written_idx[i] << 2);
        check_results($sformatf("Readback integrity word[%0d]", written_idx[i]),
                      written_data[i]);
    end

    //  SB / LB / LBU TESTS
    $display("\n-- SB/LB/LBU Tests --");

    // Write each byte one at a time, confirm the other 3 bytes stay untouched
    apply_write(32'h00000080, 32'h00000000);

    apply_write(32'h00000080, 32'h000000AB, F3_B);
    apply_read(32'h00000080);
    check_results("SB byte0: merges into word, other bytes untouched", 32'h000000AB);

    apply_write(32'h00000081, 32'h000000CD, F3_B);
    apply_read(32'h00000080);
    check_results("SB byte1: merges into word, byte0 preserved",       32'h0000CDAB);

    apply_write(32'h00000082, 32'h000000EF, F3_B);
    apply_read(32'h00000080);
    check_results("SB byte2: merges into word, bytes0-1 preserved",    32'h00EFCDAB);

    apply_write(32'h00000083, 32'h00000012, F3_B);
    apply_read(32'h00000080);
    check_results("SB byte3: merges into word, bytes0-2 preserved",    32'h12EFCDAB);

    // LB sign extension: 0xAB is negative -> must sign extend to 0xFFFFFFAB
    apply_read(32'h00000080, F3_B);
    check_results("LB sign-extends negative byte (0xAB)",              32'hFFFFFFAB);

    // LBU zero extension: same byte -> must NOT sign extend
    apply_read(32'h00000080, F3_BU);
    check_results("LBU zero-extends byte (0xAB)",                      32'h000000AB);

    // LB positive byte: 0x12 -> no sign extension
    apply_read(32'h00000083, F3_B);
    check_results("LB positive byte (0x12) reads as-is",               32'h00000012);

    // LB/LBU on zero byte
    apply_write(32'h00000084, 32'h00000000);
    apply_read(32'h00000084, F3_B);
    check_results("LB zero byte gives 0x00000000",                     32'h00000000);
    apply_read(32'h00000084, F3_BU);
    check_results("LBU zero byte gives 0x00000000",                    32'h00000000);

    // ===================== SH / LH / LHU TESTS =====================
    $display("\n-- SH/LH/LHU Tests --");

    apply_write(32'h00000090, 32'h00000000);

    // Write lower halfword, confirm upper half untouched
    apply_write(32'h00000090, 32'h0000BEEF, F3_H);
    apply_read(32'h00000090);
    check_results("SH lower half: merges into word, upper half untouched", 32'h0000BEEF);

    // Write upper halfword, confirm lower half untouched
    apply_write(32'h00000092, 32'h0000DEAD, F3_H);
    apply_read(32'h00000090);
    check_results("SH upper half: merges into word, lower half preserved", 32'hDEADBEEF);

    // LH sign extension lower half: 0xBEEF is negative -> 0xFFFFBEEF
    apply_read(32'h00000090, F3_H);
    check_results("LH sign-extends negative lower halfword (0xBEEF)",      32'hFFFFBEEF);

    // LHU zero extension lower half
    apply_read(32'h00000090, F3_HU);
    check_results("LHU zero-extends lower halfword (0xBEEF)",              32'h0000BEEF);

    // LH sign extension upper half: 0xDEAD is negative -> 0xFFFFDEAD
    apply_read(32'h00000092, F3_H);
    check_results("LH sign-extends negative upper halfword (0xDEAD)",      32'hFFFFDEAD);

    // LHU zero extension upper half
    apply_read(32'h00000092, F3_HU);
    check_results("LHU zero-extends upper halfword (0xDEAD)",              32'h0000DEAD);

    // LH positive halfword: 0x1234 -> no sign extension
    apply_write(32'h00000094, 32'h00001234, F3_H);
    apply_read(32'h00000094, F3_H);
    check_results("LH positive halfword (0x1234) reads as-is",             32'h00001234);

    // LH/LHU on zero halfword
    apply_write(32'h00000098, 32'h00000000);
    apply_read(32'h00000098, F3_H);
    check_results("LH zero halfword gives 0x00000000",                     32'h00000000);
    apply_read(32'h00000098, F3_HU);
    check_results("LHU zero halfword gives 0x00000000",                    32'h00000000);

    // -- Summary --
    $display("");
    $display("N (data width)   = %0d bits", N);
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
