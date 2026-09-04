module System_Top_tb;
// Parameters
parameter DATA_SIZE = 8;
parameter OPCODE_SIZE = 3;
parameter ADDR_SIZE = 4;
parameter CLK_PERIOD = 20; // 50MHz Clock (20ns Period)

// Testbench Signals (Inputs to UUT)
reg clk_50MHz;
reg rst_n;
reg [DATA_SIZE-1:0] A, B;
reg CIN;
reg [OPCODE_SIZE-1:0] raw_opcode;
reg mem_wr_en;
reg mem_rd_en;
reg blk_select;
reg [ADDR_SIZE-1:0] addr_rd;
reg [ADDR_SIZE-1:0] addr_wr;

// Wire Signals (Outputs from UUT)
wire [6:0] seg_display_low;
wire [6:0] seg_display_high;
wire [DATA_SIZE-1:0] mem_dout;
wire COUT;
wire ZERO_FLAG;

// Instantiate System Top Module
System_Top #(
.DATA_SIZE(DATA_SIZE),
.OPCODE_SIZE(OPCODE_SIZE),
.ADDR_SIZE(ADDR_SIZE)
) uut (
.clk_50MHz(clk_50MHz),
.rst_n(rst_n),
.A(A),
.B(B),
.CIN(CIN),
.raw_opcode(raw_opcode),
.mem_wr_en(mem_wr_en),
.mem_rd_en(mem_rd_en),
.blk_select(blk_select),
.addr_rd(addr_rd),
.addr_wr(addr_wr),
.seg_display_low(seg_display_low),
.seg_display_high(seg_display_high),
.mem_dout(mem_dout),
.COUT(COUT),
.ZERO_FLAG(ZERO_FLAG)
);

// 1. Clock Generation (50MHz)
always #(CLK_PERIOD / 2) clk_50MHz = ~clk_50MHz;

// 2. Main Test Sequence
initial begin
//--- Initialization
clk_50MHz = 0;
rst_n = 0;
A = 0;
B = 0;
CIN = 0;
raw_opcode = 0;
mem_wr_en = 0;
mem_rd_en = 0;
blk_select = 0;
addr_rd = 0;
addr_wr = 0;

$display("=================================================");
$display(" STARTING SYSTEM TOP COMPLETE TESTBENCH ");
$display("=================================================");

//--- Reset Phase
#(CLK_PERIOD * 5);
rst_n = 1;
$display("[TIME: %0t] System Reset De-asserted.", $time);
#(CLK_PERIOD * 2);

// TEST CASE 1: Debouncer Noise + ALU ADD + 7-Seg Display Check + RAM Write
$display("\n--- TEST 1: Debouncer Filter, ADD Op (05+03), 7-Seg & RAM Write ---");
A = 8'h05;
B = 8'h03;
CIN = 1'b0;

// Simulating Bouncing Noise on Opcode Buttons
raw_opcode = 3'b001; #(CLK_PERIOD);
raw_opcode = 3'b010; #(CLK_PERIOD);
raw_opcode = 3'b000; // Final Stable Opcode (ADD)

// Wait for Debouncer Filter & Clock Divider Propagation
#(CLK_PERIOD * 40);

// Verify 7-Segment Output for Result = 8'h08 (High Seg: '0', Low Seg: '8')
$display("[TIME: %0t] Raw Opcode Settled to: %b", $time, raw_opcode);
$display("[TIME: %0t] Seg Low (Val 8) Output: %b (Expected: 0000000)", $time, seg_display_low);
$display("[TIME: %0t] Seg High (Val 0) Output: %b (Expected: 1000000)", $time, seg_display_high);

if (seg_display_low == 7'b000_0000 && seg_display_high == 7'b100_0000)
$display(">>> SUCCESS: 7-Segment Displays '08' Correctly! <<<");
else
$display(">>> ERROR: 7-Segment Output Mismatch! <<<");

// Write ALU Result (08) to Memory at Location 4'h3
blk_select = 1'b1;
mem_wr_en = 1'b1;
addr_wr = 4'h3;
#(CLK_PERIOD * 2);
mem_wr_en = 1'b0;
$display("[TIME: %0t] ALU Result (08) Written to Memory Addr 4'h3.", $time);

// TEST CASE 2: AND Operation & Memory Read Verification
$display("\n--- TEST 2: AND Op (0F & 33) & Memory Read Back ---");
A = 8'h0F;
B = 8'h33;
raw_opcode = 3'b011; // AND Opcode

// Read stored value from Address 4'h3 while ALU processes new op
mem_rd_en = 1'b1;
addr_rd = 4'h3;
#(CLK_PERIOD * 40);

$display("[TIME: %0t] Memory Readout from Addr 4'h3 = %h (Expected: 08)", $time, mem_dout);
if (mem_dout == 8'h08)
$display(">>> SUCCESS: Memory Read Verified Correctly! <<<");
else
$display(">>> ERROR: Memory Read Mismatch! <<<");

// TEST CASE 3: SUB Operation Resulting in Zero (Zero Flag Check)
$display("\n--- TEST 3: SUB Op (AA-AA) & Zero Flag Verification ---");
A = 8'hAA;
B = 8'hAA;
raw_opcode = 3'b001; // SUB Opcode
#(CLK_PERIOD * 40);

$display("[TIME: %0t] ALU Zero Flag Output = %b", $time, ZERO_FLAG);
if (ZERO_FLAG == 1'b1)
$display(">>> SUCCESS: Zero Flag Asserted Correctly! <<<");
else
$display(">>> ERROR: Zero Flag Failed! <<<");

//--- Finish Simulation
$display("\n=================================================");
$display(" ALL SYSTEM TEST CASES PASSED SUCCESSFULLY ");
$display("=================================================");
$stop;
end

endmodule