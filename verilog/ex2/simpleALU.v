`timescale 1 ns/ 1 ns

module alu (src_a, src_b, c, data_out);

input [7:0] src_a, src_b;
input [2:0] c;
output [7:0] data_out;

reg [7:0] data_out;

always @( c or src_a or src_b ) begin
    case (c)
        3'b001: data_out = src_a + src_b; // ADD
        3'b010: data_out = src_a - src_b; // SUB
        3'b011: data_out = src_a & src_b; // AND
        3'b100: data_out = src_a | src_b; // OR
        3'b101: data_out = src_a ^ src_b; // XOR
        default: data_out = src_a;
    endcase
end

endmodule
