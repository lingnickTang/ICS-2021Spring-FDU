`ifndef __MYHEADFILE_SVH__
`define __MYHEADFILE_SVH__

//addad in lab1
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
parameter BGTZ = 6'b000111;
parameter BLEZ = 6'b000110;
parameter LB = 6'b100000;
parameter LBU = 6'b100100;
parameter LH = 6'b100001;
parameter LHU = 6'b100101;
parameter SB = 6'b101000;
parameter SH = 6'b101001;


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
parameter JALR = 6'b001001;
parameter SLLV = 6'b000100;
parameter SRAV = 6'b000111;
parameter SRLV = 6'b000110;


//REGIMM
parameter REGIMM = 6'b000001;

parameter BGEZ = 5'b00001;
parameter BGEZAL = 5'b10001;
parameter BLTZ = 5'b00000;
parameter BLTZAL = 5'b10010;



`endif 