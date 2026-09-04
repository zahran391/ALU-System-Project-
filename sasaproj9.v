module Debounce (
input wire clk,
input wire rst_n,
input wire btn_in,
output reg btn_out
);

reg [2:0] samples;

always @(posedge clk or negedge rst_n)
begin
if (!rst_n)
begin
samples <= 3'b000;
btn_out <= 1'b0;
end else
begin
samples <= {samples[1:0], btn_in};
btn_out <= (samples == 3'b111);
end
end

endmodule