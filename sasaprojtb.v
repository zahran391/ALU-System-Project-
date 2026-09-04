module Top_level_tb;
parameter DATA_SIZE = 8;
parameter OPCODE_SIZE = 3;

reg [DATA_SIZE-1:0] A, B;
reg [OPCODE_SIZE-1:0] OPCODE;
reg clk, rst_n, CIN;
wire [DATA_SIZE-1:0] RESULT;
wire COUT, ZERO_FLAG;

// (Golden Model)
reg [DATA_SIZE:0] EXPECTED_ARITH;
reg [DATA_SIZE-1:0] EXPECTED_RESULT;
reg EXPECTED_COUT;
reg EXPECTED_ZERO;

integer i;
integer pass_count = 0;
integer fail_count = 0;

// Instantiate DUT
Top_level #(DATA_SIZE, OPCODE_SIZE) DUT
(
.A(A), .B(B), .OPCODE(OPCODE),
.clk(clk), .rst_n(rst_n), .CIN(CIN),
.RESULT(RESULT),
.COUT(COUT), .ZERO_FLAG(ZERO_FLAG)
);

always #5 clk = ~clk;

task calculate_expected;
begin
case (OPCODE)
3'b000: begin // ADD
EXPECTED_ARITH = A + B + CIN;
EXPECTED_RESULT = EXPECTED_ARITH[DATA_SIZE-1:0];
EXPECTED_COUT = EXPECTED_ARITH[DATA_SIZE];
end
3'b001: begin // SUB
EXPECTED_ARITH = A - B - CIN;
EXPECTED_RESULT = EXPECTED_ARITH[DATA_SIZE-1:0];
EXPECTED_COUT = EXPECTED_ARITH[DATA_SIZE];
end
3'b010: begin // INC A
EXPECTED_ARITH = A + 1;
EXPECTED_RESULT = EXPECTED_ARITH[DATA_SIZE-1:0];
EXPECTED_COUT = EXPECTED_ARITH[DATA_SIZE];
end
3'b011: begin // DEC B
EXPECTED_ARITH = B - 1;
EXPECTED_RESULT = EXPECTED_ARITH[DATA_SIZE-1:0];
EXPECTED_COUT = EXPECTED_ARITH[DATA_SIZE];
end
3'b100: begin // AND
EXPECTED_RESULT = A & B;
EXPECTED_COUT = 0;
end
3'b101: begin // OR
EXPECTED_RESULT = A | B;
EXPECTED_COUT = 0;
end
3'b110: begin // XOR
EXPECTED_RESULT = A ^ B;
EXPECTED_COUT = 0;
end
3'b111: begin // NOT A
EXPECTED_RESULT = ~A;
EXPECTED_COUT = 0;
end
default: begin
EXPECTED_RESULT = 0;
EXPECTED_COUT = 0;
end
endcase

// Zero Flag
EXPECTED_ZERO = (EXPECTED_RESULT == 0) ? 1'b1 : 1'b0;
end
endtask

// Main Test Sequence
initial begin
clk = 0;
rst_n = 0; // active rst
A = 0; B = 0; OPCODE = 0; CIN = 0;
#15

// deactive rst
rst_n = 1;
@(negedge clk);

$display("=== STARTING RANDOM TESTING (100 ITERATIONS) ===");

repeat (100) begin
@(negedge clk);
A = $random;
B = $random;
CIN = $random;
OPCODE = $random;

calculate_expected();

repeat (2)
@(negedge clk);

// المقارنة بين المخرج الفعلي والمتوقع //
if (RESULT !== EXPECTED_RESULT || COUT !== EXPECTED_COUT || ZERO_FLAG !== EXPECTED_ZERO)
begin
$display("ERROR at Iteration %0d | OPCODE=%b A=%h B=%h CIN=%b", fail_count + pass_count + 1, OPCODE, A, B, CIN);
$display(" GOT : RESULT=%h COUT=%b ZERO=%b", RESULT, COUT, ZERO_FLAG);
$display(" EXPECTED: RESULT=%h COUT=%b ZERO=%b", EXPECTED_RESULT, EXPECTED_COUT, EXPECTED_ZERO);
fail_count = fail_count + 1;
end
else
begin
pass_count = pass_count + 1;
end
end

// التقرير النهائي //
$display("\n=================================");
$display("=== SIMULATION RESULTS SUMMARY ===");
$display(" TOTAL TESTS: %0d", pass_count + fail_count);
$display(" PASSED : %0d", pass_count);
$display(" FAILED : %0d", fail_count);
$display("=================================\n");

if (fail_count == 0)
$display("SUCCESS: ALL 100 RANDOM TESTS PASSED!");
else
$display("FAILURE: SOME TESTS FAILED!");

$finish;
end

endmodule