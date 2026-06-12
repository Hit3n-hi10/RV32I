// Signals Driven:
//   clk            - 10 ns clock
//   rst            - Active-high reset
//   regwrite       - Register write enable
//   rs1[4:0]       - Source register 1 address
//   rs2[4:0]       - Source register 2 address
//   rd[4:0]        - Destination register address
//   wd[31:0]       - Write data
//
// Signals Observed:
//   rd1[31:0]      - Data read from source register 1
//   rd2[31:0]      - Data read from source register 2
//
// Verification Coverage:
//   - Reset functionality verification
//   - x0 hardwired-to-zero validation
//   - Single register write/read operations
//   - Multiple register write/read operations
//   - Register overwrite verification
//   - Dual read port functionality
//   - Write enable control verification
//   - Register independence checks
//   - Various data pattern testing
//   - Boundary register testing (x1, x31)
//   - Same-cycle read/write behavior verification
//   - Randomized register access testing
//
// Test Results:
//   215 test cases executed
//   All tests passed successfully




`timescale 1ns/1ps

module tb_register_file;

//Testbench Signals 
 
  logic         clk;
  logic         rst;
  logic  [4:0]  rs1;
  logic  [4:0]  rs2;
  logic  [4:0]  rd;
  logic  [31:0] wd;
  logic         regwrite;
  logic  [31:0] rd1;
  logic  [31:0] rd2;

  // DUT Instantiation
  register_file dut (
    .clk      (clk),
    .rst      (rst),
    .regwrite (regwrite),
    .rs1      (rs1),
    .rs2      (rs2),
    .rd       (rd),
    .wd       (wd),
    .rd1      (rd1),
    .rd2      (rd2)
  );

  // Test Counters

   int test_count = 0;
  int pass_count = 0;
  int fail_count = 0;

// Clock Generation  - 10 ns period

 initial begin
    clk = 1'b0;
    forever #5 clk = ~clk;
  end

  // Helper Tasks
  // Generic pass/fail checker
  task check(string test_name, logic condition);
    test_count++;
    if (condition) begin
      pass_count++;
      $display("[PASS] Test %0d: %s", test_count, test_name);
    end else begin
      fail_count++;
      $display("[FAIL] Test %0d: %s", test_count, test_name);
      $display(" rs1=%02d, rs2=%02d, rd=%02d", rs1, rs2, rd); //02d means pad with zero min                     //2 width decimal number

      $display(" rd1=0x%08x, rd2=0x%08x, wd=0x%08x",  rd1, rd2, wd);
    end
  endtask

  // Check both read ports simultaneously
  task check_read(string test_name,
                  logic [31:0] exp_rd1,
                  logic [31:0] exp_rd2);
    check($sformatf("%s - rd1 (exp:0x%08x got:0x%08x)", test_name, exp_rd1, rd1),
          rd1 == exp_rd1);
    check($sformatf("%s - rd2 (exp:0x%08x got:0x%08x)", test_name, exp_rd2, rd2),
          rd2 == exp_rd2);
  endtask

  // Write to a register and wait two edges so the value settles
 task write_reg(logic [4:0] addr, logic [31:0] data);
begin
    @(negedge clk);     // set up inputs mid-cycle, away from clock edge
    rd       = addr;
    wd       = data;
    regwrite = 1'b1;
    @(posedge clk);     // write latches here (NBA region)
    #1;                 // let non-blocking assignment settle
    regwrite = 1'b0;
    @(negedge clk);     // wait until safely past the write edge before returning
end
endtask



  // Drive read-address lines and let combinational logic settle
  task read_regs(logic [4:0] addr1, logic [4:0] addr2);
    rs1 = addr1;
    rs2 = addr2;
    #1;
  endtask

  // Assert active-high reset for one cycle
 task do_reset;
begin
    rst = 1'b1;
    regwrite = 1'b0;

    #2;
    rst = 1'b0;

    @(posedge clk);
end
endtask


  // Main Test Sequence

  initial begin
    $display("\n========================================");
    $display("  RISC-V RV32I Register File Testbench  ");
    $display("========================================\n");

    // Default signal values
    rs1      = 5'd0;
    rs2      = 5'd0;
    rd       = 5'd0;
    wd       = 32'd0;
    regwrite = 1'b0;
    rst      = 1'b0;

    @(posedge clk);

    // ========================================================================
    // Test Group 1 - Reset Verification
    // ========================================================================
    $display("\n--- Test Group 1: Reset Verification ---\n");

    do_reset();

    read_regs(5'd1, 5'd2);
    check("Reset: x1 = 0",  rd1 == 32'd0);
    check("Reset: x2 = 0",  rd2 == 32'd0);

    read_regs(5'd15, 5'd31);
    check("Reset: x15 = 0", rd1 == 32'd0);
    check("Reset: x31 = 0", rd2 == 32'd0);

    // ========================================================================
    // Test Group 2 - x0 Hardwired to Zero
    // ========================================================================
    $display("\n--- Test Group 2: x0 Hardwired to Zero ---\n");

    read_regs(5'd0, 5'd0);
    check("x0 read: rd1 = 0", rd1 == 32'd0);
    check("x0 read: rd2 = 0", rd2 == 32'd0);

    // Attempt a write to x0 - must not change it
    write_reg(5'd0, 32'hDEADBEEF);
    read_regs(5'd0, 5'd0);
    check("x0 after write attempt: rd1 = 0", rd1 == 32'd0);
    check("x0 after write attempt: rd2 = 0", rd2 == 32'd0);

    // Multiple attempts
    write_reg(5'd0, 32'h12345678);
    write_reg(5'd0, 32'hFFFFFFFF);
    read_regs(5'd0, 5'd0);
    check("x0 always zero (multiple attempts)", rd1 == 32'd0);

    // ========================================================================
    // Test Group 3 - Single Register Write / Read
    // ========================================================================
    $display("\n--- Test Group 3: Single Register Write/Read ---\n");

    write_reg(5'd1, 32'h12345678);
    read_regs(5'd1, 5'd0);
    check("Write x1, read x1", rd1 == 32'h12345678);

    write_reg(5'd31, 32'hDEADBEEF);
    read_regs(5'd31, 5'd0);
    check("Write x31, read x31", rd1 == 32'hDEADBEEF);

    write_reg(5'd16, 32'hCAFEBABE);
    read_regs(5'd16, 5'd0);
    check("Write x16, read x16", rd1 == 32'hCAFEBABE);

    // ========================================================================
    // Test Group 4 - Multiple Register Writes
    // ========================================================================
    $display("\n--- Test Group 4: Multiple Register Writes ---\n");

    write_reg(5'd1, 32'h11111111);
    write_reg(5'd2, 32'h22222222);
    write_reg(5'd3, 32'h33333333);
    write_reg(5'd4, 32'h44444444);
    write_reg(5'd5, 32'h55555555);

    read_regs(5'd1, 5'd2);
    check_read("Multiple writes: x1, x2", 32'h11111111, 32'h22222222);

    read_regs(5'd3, 5'd4);
    check_read("Multiple writes: x3, x4", 32'h33333333, 32'h44444444);

    read_regs(5'd5, 5'd1);
    check_read("Multiple writes: x5, x1", 32'h55555555, 32'h11111111);

    // ========================================================================
    // Test Group 5 - Register Overwrite
    // ========================================================================
    $display("\n--- Test Group 5: Register Overwrite ---\n");

    write_reg(5'd10, 32'hAAAAAAAA);
    read_regs(5'd10, 5'd0);
    check("First write x10",             rd1 == 32'hAAAAAAAA);

    write_reg(5'd10, 32'hBBBBBBBB);
    read_regs(5'd10, 5'd0);
    check("Overwrite x10",               rd1 == 32'hBBBBBBBB);

    write_reg(5'd10, 32'h00000000);
    read_regs(5'd10, 5'd0);
    check("Overwrite x10 with zero",     rd1 == 32'h00000000);

    write_reg(5'd10, 32'hFFFFFFFF);
    read_regs(5'd10, 5'd0);
    check("Overwrite x10 with all-ones", rd1 == 32'hFFFFFFFF);

    // ========================================================================
    // Test Group 6 - Dual Read Port Verification
    // ========================================================================
    $display("\n--- Test Group 6: Dual Read Port Verification ---\n");

    write_reg(5'd5,  32'h55555555);
    write_reg(5'd10, 32'hAAAAAAAA);

    read_regs(5'd5, 5'd10);
    check_read("Dual port: x5 & x10", 32'h55555555, 32'hAAAAAAAA);

    read_regs(5'd10, 5'd5);
    check_read("Dual port swapped", 32'hAAAAAAAA, 32'h55555555);

    write_reg(5'd1, 32'h11111111);
    write_reg(5'd31, 32'hFFFFFFFF);
    read_regs(5'd1, 5'd31);
    check_read("Dual port: x1 & x31", 32'h11111111, 32'hFFFFFFFF);

    // Read same register from both ports
    write_reg(5'd15, 32'hF0F0F0F0);
    read_regs(5'd15, 5'd15);
    check("Same reg both ports: rd1", rd1 == 32'hF0F0F0F0);
    check("Same reg both ports: rd2", rd2 == 32'hF0F0F0F0);

    // ========================================================================
    // Test Group 7 - Write Enable Verification
    // ========================================================================
    $display("\n--- Test Group 7: Write Enable Verification ---\n");

    write_reg(5'd7, 32'h77777777);
    read_regs(5'd7, 5'd0);
    check("Write x7 with regwrite=1", rd1 == 32'h77777777);

    // Attempt write with regwrite=0 - value must not change
    rd       = 5'd7;
    wd       = 32'h88888888;
    regwrite = 1'b0;
    @(posedge clk);
    @(posedge clk);

    read_regs(5'd7, 5'd0);
    check("Write x7 with regwrite=0 (no change)", rd1 == 32'h77777777);

    // ========================================================================
    // Test Group 8 - Register Independence
    // ========================================================================
    $display("\n--- Test Group 8: Register Independence ---\n");

    write_reg(5'd10, 32'h10101010);
    write_reg(5'd11, 32'h11111111);
    write_reg(5'd12, 32'h12121212);

    read_regs(5'd10, 5'd11);
    check("Independence: x10 != x11",     rd1 != rd2);
    check("Independence: x10=0x10101010", rd1 == 32'h10101010);

    read_regs(5'd11, 5'd12);
    check("Independence: x11 != x12",     rd1 != rd2);
    check("Independence: x12=0x12121212", rd2 == 32'h12121212);

    // Write to x11 only - neighbours must not change
    write_reg(5'd11, 32'hBEEFBEEF);
    read_regs(5'd10, 5'd12);
    check("Neighbour x10 unaffected", rd1 == 32'h10101010);
    check("Neighbour x12 unaffected", rd2 == 32'h12121212);

    // ========================================================================
    // Test Group 9 - Data Pattern Tests
    // ========================================================================
    $display("\n--- Test Group 9: Data Pattern Tests ---\n");

    write_reg(5'd8,  32'h00000000);
    read_regs(5'd8, 5'd0);
    check("Pattern: all-zeros",    rd1 == 32'h00000000);

    write_reg(5'd9,  32'hFFFFFFFF);
    read_regs(5'd9, 5'd0);
    check("Pattern: all-ones",     rd1 == 32'hFFFFFFFF);

    write_reg(5'd11, 32'hAAAAAAAA);
    read_regs(5'd11, 5'd0);
    check("Pattern: 0xAAAAAAAA",   rd1 == 32'hAAAAAAAA);

    write_reg(5'd12, 32'h55555555);
    read_regs(5'd12, 5'd0);
    check("Pattern: 0x55555555",   rd1 == 32'h55555555);

    write_reg(5'd13, 32'h00000001);
    read_regs(5'd13, 5'd0);
    check("Pattern: LSB only",     rd1 == 32'h00000001);

    write_reg(5'd14, 32'h80000000);
    read_regs(5'd14, 5'd0);
    check("Pattern: MSB only",     rd1 == 32'h80000000);

    write_reg(5'd17, 32'h7FFFFFFF);
    read_regs(5'd17, 5'd0);
    check("Pattern: 0x7FFFFFFF",   rd1 == 32'h7FFFFFFF);

    // ========================================================================
    // Test Group 10 - Boundary Register Tests (x1 and x31)
    // ========================================================================
    $display("\n--- Test Group 10: Boundary Register Tests ---\n");

    write_reg(5'd1,  32'h00000001);
    read_regs(5'd1, 5'd0);
    check("Boundary: x1",  rd1 == 32'h00000001);

    write_reg(5'd31, 32'h0000001F);
    read_regs(5'd31, 5'd0);
    check("Boundary: x31", rd1 == 32'h0000001F);

    write_reg(5'd16, 32'h00000010);
    read_regs(5'd16, 5'd0);
    check("Boundary: x16 (mid)", rd1 == 32'h00000010);

    // All 31 writable registers - write then read-back
    for (int i = 1; i < 32; i++) begin
      write_reg(i[4:0], i * 32'h01010101);
    end
    for (int i = 1; i < 32; i++) begin
      read_regs(i[4:0], 5'd0);
      check($sformatf("All regs: x%0d", i),
            rd1 == (i * 32'h01010101));
    end

    // ========================================================================
    // Test Group 11 - Reset After Writes
    // ========================================================================
    $display("\n--- Test Group 11: Reset After Writes ---\n");

    for (int i = 1; i < 32; i++)
      write_reg(i[4:0], 32'hDEADBEEF);

    read_regs(5'd15, 5'd20);
    check("Pre-reset: x15 written", rd1 == 32'hDEADBEEF);
    check("Pre-reset: x20 written", rd2 == 32'hDEADBEEF);

    do_reset();

    for (int i = 1; i < 32; i++) begin
      read_regs(i[4:0], 5'd0);
      check($sformatf("Post-reset: x%0d = 0", i), rd1 == 32'd0);
    end

    // ========================================================================
    // Test Group 12 - Consecutive Writes to Same Register
    // ========================================================================
    $display("\n--- Test Group 12: Consecutive Writes to Same Register ---\n");

    for (int i = 0; i < 10; i++)
      write_reg(5'd25, i * 32'h11111111);

    read_regs(5'd25, 5'd0);
    check("Consecutive writes: last value retained",
          rd1 == (9 * 32'h11111111));

    // ========================================================================
 // ========================================================================
// Test Group 13 - Same-Cycle Read/Write Behavior
// ========================================================================
$display("\n--- Test Group 13: Same-Cycle Read/Write Behavior ---\n");

write_reg(5'd5, 32'h11111111);

@(negedge clk);
rd       = 5'd5;
wd       = 32'h22222222;
regwrite = 1'b1;
rs1      = 5'd5;
#1;

check("Same-cycle: old value visible before clock edge",
      rd1 == 32'h11111111);

@(posedge clk);     // write latches here
#2;                 // ← change from #1 to #2, give NBA region extra time
regwrite = 1'b0;

read_regs(5'd5, 5'd0);   // ← re-drive rs1 cleanly after deasserting regwrite

check("Same-cycle: new value visible after clock edge",
      rd1 == 32'h22222222);

//=======================================================================///=
    // Test Group 14 - Randomised Register Tests
    // //=======================================================================///=
    $display("\n--- Test Group 14: Randomized Register Tests ---\n");

    begin
      logic [4:0]  rand_addr;
      logic [31:0] rand_data;

      for (int i = 0; i < 100; i++) begin
        rand_addr = $urandom_range(1, 31);   // never x0
        rand_data = $urandom;

        write_reg(rand_addr, rand_data);
        read_regs(rand_addr, 5'd0);

        check($sformatf("Random test %0d: x%0d", i, rand_addr),
              rd1 == rand_data);
      end
    end

    // ========================================================================
    // Test Summary
    // ========================================================================
    $display("\n========================================");
    $display("  Test Summary");
    $display("========================================");
    $display("Total:  %0d", test_count);
    $display("Passed: %0d", pass_count);
    $display("Failed: %0d", fail_count);
    $display("Rate:   %0.1f%%", (pass_count * 100.0) / test_count);
    $display("========================================\n");

    if (fail_count == 0)
      $display("✓ All tests passed!");
    else
      $display("✗ %0d test(s) failed.", fail_count);

    $finish;
  end

endmodule


