`timescale 1ps/1ps
// And ///////////////////////////////
module AND (
    input [31:0] A_AND,
    input [31:0] B_AND,
    output [31:0] C_AND
);
assign C_AND = A_AND & B_AND;
endmodule

// Or ///////////////////////////////
module OR (
    input [31:0] A_OR,
    input [31:0] B_OR,
    output [31:0] C_OR
);
assign C_OR = A_OR | B_OR;
endmodule

// Add ///////////////////////////////
module ADD (
    input [31:0] A_ADD,
    input [31:0] B_ADD,
    output [31:0] C_ADD
);
assign C_ADD = A_ADD + B_ADD;
endmodule

// Subtract ///////////////////////////////
module SUB (
    input [31:0] A_SUB,
    input [31:0] B_SUB,
    output [31:0] C_SUB
);
assign C_SUB = A_SUB - B_SUB;
endmodule

// Set On Less Than  //////////////////////
module SOLT (
    input [31:0] A_SOLT,
    input [31:0] B_SOLT,
    output [31:0] C_SOLT
);
assign C_SOLT = (A_SOLT < B_SOLT) ? 32'd1 : 32'd0;
endmodule

// Nor ///////////////////////////////
module NOR (
    input [31:0] A_NOR,
    input [31:0] B_NOR,
    output [31:0] C_NOR
);
assign C_NOR = ~(A_NOR | B_NOR);
endmodule

// Memoria operadores/////////////////////////
module Mem_operandos (
	input[4:0] dirLec1,
	input[4:0] dirLec2,
	input we,
	output reg[31:0] salida1,
	output reg[31:0] salida2
);

reg [31:0] mem [0:63];

initial begin
    $readmemh("Datos.txt", mem);
    #10;
end

always @(*) begin
    salida1 = mem[dirLec1];
    salida2 = mem[dirLec2];
end
endmodule


// Alu ///////////////////////////////
module alu (
    input [31:0] op1,
    input [31:0] op2,
    input [2:0] sel,
    output reg [31:0] resultado
);

wire [31:0] C1, C2, C3, C4, C5, C6;

AND I1(.A_AND(op1), .B_AND(op2), .C_AND(C1));
OR I2(.A_OR(op1), .B_OR(op2), .C_OR(C2));
ADD I3(.A_ADD(op1), .B_ADD(op2), .C_ADD(C3));
SUB I4(.A_SUB(op1), .B_SUB(op2), .C_SUB(C4));
SOLT I5(.A_SOLT(op1), .B_SOLT(op2), .C_SOLT(C5));
NOR I6(.A_NOR(op1), .B_NOR(op2), .C_NOR(C6));

always @(*) begin
    case (sel)
        3'b000: begin
            resultado = C1;
        end
        3'b001: begin
            resultado = C2;
        end
        3'b010: begin
            resultado = C3;
        end
        3'b110: begin
            resultado = C4;
        end
        3'b111: begin
            resultado = C5;
        end
        3'b100: begin
            resultado = C6;
        end
    endcase
end

endmodule

// Memoria resulatdos/////////////////////////
module Mem_resultados (
	input[31:0] datos,
	input[4:0] dirEsc,
	input[4:0] dirLec1,
	input we,
	output reg[31:0] salida1
);

reg [31:0] mem [0:63];

always @(*) begin
	if (we)
		mem[dirEsc] = datos;
	else
		salida1 = mem[dirLec1];
end
endmodule

// Chocorol/////////////////////////
module Chocorol(
    input [19:0] in,
    output [31:0] sal
);

wire [31:0] C1;
wire [31:0] C2;
wire [31:0] C3;

Mem_operandos I1 (.dirLec1(in[17:13]), .dirLec2(in[9:5]), .we(in[19:19]), .salida1(C1), .salida2(C2));
alu I2 (.op1(C1), .op2(C2), .sel(in[12:10]), .resultado(C3));
Mem_resultados I3 (.datos(C3), .dirEsc(in[4:0]), .dirLec1(in[4:0]), .we(in[18:18]), .salida1(sal));

endmodule

// TB_Chocorol/////////////////////////
module TB_Chocorol;
reg [19:0] TB_in;
wire [31:0] TB_out;

reg [19:0] mem[0:20];
integer i;

Chocorol I1(.in(TB_in), .sal(TB_out));

initial begin
    $readmemb("instrucciones.txt", mem);
    for (i = 0; i < 20; i = i + 1) begin
        TB_in = mem[i];
        #10;
    end
end

endmodule
