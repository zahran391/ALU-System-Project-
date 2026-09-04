module Top_level#(parameter DATA_SIZE = 8, OPCODE_SIZE=3)
(
input [DATA_SIZE-1:0]A, B,
input [OPCODE_SIZE-1:0] OPCODE,
input clk,rst_n, CIN,
output reg [DATA_SIZE-1:0] RESULT,
output reg COUT, ZERO_FLAG
);

// From Schematic Diagram
wire ZERO_FLAG_dff;
wire [DATA_SIZE-1:0] RESULT_dff;
wire [DATA_SIZE-1:0] RESULT_Ar;
wire COUT_Ar;
wire [DATA_SIZE-1:0] RESULT_Lo;

// الدمج ب الترتيب //
arithmetic_unit dut1(A, B, OPCODE, clk,rst_n,CIN, RESULT_Ar, COUT_Ar);
logical_unit dut2(A, B, OPCODE, clk,rst_n, RESULT_Lo);

// mux 2 1 with sel opcode[2]
assign RESULT_dff = (OPCODE[2] == 0)? RESULT_Ar : RESULT_Lo;
assign ZERO_FLAG_dff = (RESULT_dff == 0)? 1 : 0;

always @(posedge clk or negedge rst_n) begin
if(~rst_n)
begin
RESULT <= 0;
ZERO_FLAG <= 1; // active low
COUT <= 0;
end
else
begin
COUT <= COUT_Ar;
RESULT <= RESULT_dff;
ZERO_FLAG <= ZERO_FLAG_dff;
end
end

endmodule
