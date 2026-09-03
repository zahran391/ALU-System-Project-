module logical_unit#(parameter DATA_SIZE = 8, OPCODE_SIZE = 3)
(
input [DATA_SIZE-1:0]A,B,
input[OPCODE_SIZE-1:0]OPCODE,
input clk,rst_n,
output reg [DATA_SIZE-1:0]RESULT
);

reg [DATA_SIZE-1:0]A_regis, B_regis;
reg [OPCODE_SIZE-1:0]OPCODE_regis;

always @(posedge clk or negedge rst_n) begin
if (~rst_n)
begin
A_regis <= 0;
B_regis <= 0;
OPCODE_regis <= 0;
RESULT <= 0;
end
else begin
A_regis <= A; B_regis <= B;
OPCODE_regis <= OPCODE;
end
end

// logical operation
always @(*) begin
case (OPCODE_regis)
3'b100: RESULT <= A_regis & B_regis;
3'b101: RESULT <= A_regis | B_regis;
3'b110: RESULT <= A_regis ^ B_regis;
3'b111: RESULT <= ~A_regis;
default: begin
RESULT <= 1'b0;
end
endcase
end

endmodule