`ifndef __MYHEADFILE_SVH__
`define __MYHEADFILE_SVH__

parameter ADDIU = 6'b001001;
parameter ANDI = 6'b001100;
parameter BEQ = 6'b000100;
parameter BNE = 6'b000101;
parameter J = 6'b000010;
parameter JAL = 6'b000011;
parameter LUI = 6'b001111;
parameter LW = 6'b100011;
parameter ORI = 6'b001101;
parameter SLTI = 6'b001010;
parameter SLTIU = 6'b001011;
parameter SW = 6'b101011;
parameter XORI =6'b001110;

//special
parameter SPE = 6'b000000;

parameter ADDU =  6'b100001;
parameter AND_ = 6'b100100;
parameter JR =  6'b001000;
parameter NOR_ =  6'b100111;
parameter OR_ =  6'b100101;
parameter SLL =  6'b000000;
parameter SLT =  6'b101010;
parameter SLTU =  6'b101011;
parameter SRA = 6'b000011;
parameter SRL = 6'b000010;
parameter SUBU = 6'b100011;
parameter XOR_ = 6'b100110;


`endif 