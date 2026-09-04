module ClockDivider #(
parameter DIVISOR = 250000 // Default division factor
)
(
input wire clk,
input wire rst_n, // Active low reset to match your ALU project
output reg slow_clk
);

reg [31:0] count;

always @(posedge clk or negedge rst_n)
begin
if (!rst_n)
begin
count <= 32'd0;
slow_clk <= 1'b0;
end
else
begin
if (count >= (DIVISOR - 1))
begin
count <= 32'd0;
slow_clk <= ~slow_clk; // Toggle output clock
end else
begin
count <= count + 1'b1;
end
end
end

endmodule
