module System_Top
#(
parameter DATA_SIZE = 8,
parameter OPCODE_SIZE = 3,
parameter ADDR_SIZE = 4
)
(
// System Clock
input wire clk_50MHz,
// Active Low Reset
input wire rst_n,
// ALU Inputs
input wire [DATA_SIZE-1:0] A, B,
input wire CIN,
// Raw Buttons Input
input wire [OPCODE_SIZE-1:0] raw_opcode,

// Memory Control Signals
input wire mem_wr_en, // Write Enable
input wire mem_rd_en, // Read Enable
input wire blk_select, // Memory Block Select
input wire [ADDR_SIZE-1:0] addr_rd, // Read Address
input wire [ADDR_SIZE-1:0] addr_wr, // Write Address

// Displays & Flags Outputs
output wire [6:0] seg_display_low, // First Digit (Right)
output wire [6:0] seg_display_high, // Second Digit (Left)
output wire [DATA_SIZE-1:0] mem_dout, // Memory Read Data
output wire COUT,
output wire ZERO_FLAG
);

// Internal Wires from Schematic
wire slow_clk;
wire [OPCODE_SIZE-1:0] clean_opcode;
wire [DATA_SIZE-1:0] alu_result;

// 1. Clock Divider Instance
ClockDivider #(.DIVISOR(250000)) u_clk_div
(
.clk(clk_50MHz),
.rst_n(rst_n),
.slow_clk(slow_clk)
);

// 2. Debouncer Instances for Opcode Buttons
genvar i;
generate
for (i = 0; i < OPCODE_SIZE; i = i + 1)
begin: gen_debouncers
Debounce u_deb
(
.clk(clk_50MHz),
.rst_n(rst_n),
.btn_in(raw_opcode[i]),
.btn_out(clean_opcode[i])
);
end
endgenerate

// 3. ALU Core Instance (Connected to slow_clk and clean_opcode)
Top_level #(
.DATA_SIZE(DATA_SIZE),
.OPCODE_SIZE(OPCODE_SIZE)
)
u_alu
(
.clk(slow_clk), .rst_n(rst_n),
.A(A), .B(B), .CIN(CIN),
.OPCODE(clean_opcode),
.RESULT(alu_result),
.COUT(COUT), .ZERO_FLAG(ZERO_FLAG)
);

// 4. Synchronous Dual-Port Memory Instance
dpr_sync #(
.MEM_WIDTH(DATA_SIZE),
.MEM_DEPTH(16),
.ADDR_SIZE(ADDR_SIZE)
)
u_memory
(
.clk(clk_50MHz), .rst_n(rst_n), .wr_en(mem_wr_en), .rd_en(mem_rd_en),
.blk_select(blk_select),
.din(alu_result), // Connects directly to ALU result
.addr_rd(addr_rd), .addr_wr(addr_wr),
.dout(mem_dout)
);

// 5. Seven-Segment Decoders (Lower 4-bit)
Seven_Seg_Decoder u_seg_low
(
.hex_in(alu_result[3:0]),
.seg_out(seg_display_low)
);

// 6. Seven-Segment Decoders (Upper 4-bit)
Seven_Seg_Decoder u_seg_high
(
.hex_in(alu_result[7:4]),
.seg_out(seg_display_high)
);

endmodule
