`timescale 1ns / 1ps

`define ZERO_WORD   32'h00000000
`define ZERO        32'h00000000
`define True        1'b1
`define False       1'b0

`define RegBus      31 : 0
`define ImmBus      31 : 0
`define RegAddrBus  4 : 0
`define InstBus     31 : 0
`define InstAddrBus 31 : 0
`define RegNum      32

`define RamIOBus    7 : 0
`define RamAddrBus  31 : 0

`define IndexNum    256
`define TagBus      7 : 0
`define TagBits     17 : 10
`define IndexBits   9 : 2
`define ValidBit    7
`define BitInvalid 1'b1

`define PIndexNum   128
`define PTagBus     8 : 0
`define PTagBits    17 : 9
`define PIndexBits  8 : 2

`define MemAddrBus  31 : 0
`define StageBus    1 : 0
`define X0_Addr     5'b00000 
`define State_NONE  2'b00 
`define State_IF    2'b01 
`define State_LOAD  2'b10
`define State_STORE 2'b11 
`define Read        1'b0
`define Write       1'b1

`define StallBus    5 : 0
`define Stall_PC    0
`define Stall_IF    1
`define Stall_ID    2
`define Stall_EX    3
`define Stall_MEM   4
`define IF_Stall    6'b000011
`define ID_Stall    6'b000111
`define EX_Stall    6'b001111
`define MEM_Stall   6'b011111

`define OP_OPIMM    7'b0010011
`define OP_OP       7'b0110011
`define OP_LUI      7'b0110111
`define OP_AUIPC    7'b0010111
`define OP_JAL      7'b1101111
`define OP_JALR     7'b1100111
`define OP_BRANCH   7'b1100011
`define OP_LOAD     7'b0000011
`define OP_STORE    7'b0100011
`define F3_ADD  3'b000 
`define F3_SLL  3'b001 
`define F3_SLT  3'b010 
`define F3_SLTU 3'b011 
`define F3_XOR  3'b100 
`define F3_SR   3'b101 
`define F3_OR   3'b110 
`define F3_AND  3'b111 
`define F3_LB   3'b000 
`define F3_LH   3'b001 
`define F3_LW   3'b010 
`define F3_LBU  3'b100 
`define F3_LHU  3'b101 
`define F3_SB   3'b000 
`define F3_SH   3'b001
`define F3_SW   3'b010 
`define F3_BEQ  3'b000
`define F3_BNE  3'b001 
`define F3_BLT  3'b100 
`define F3_BGE  3'b101 
`define F3_BLTU 3'b110 
`define F3_BGEU 3'b111 
`define F7_ADD  7'b0000000
`define F7_SUB  7'b0100000
`define F7_SRL  7'b0000000
`define F7_SRA  7'b0100000 

// `define TypeBus     5 : 0
// `define Type_ADDI   6'b000000 
// `define Type_SLTI   6'b000001 
// `define Type_SLTIU  6'b000010 
// `define Type_ANDI   6'b000011 
// `define Type_ORI    6'b000100 
// `define Type_XORI   6'b000101 
// `define Type_SLLI   6'b000110 
// `define Type_SRLI   6'b000111 
// `define Type_SRAI   6'b001000 
// `define Type_LUI    6'b001001 
// `define Type_AUIPC  6'b001010 
// `define Type_ADD    6'b001011
// `define Type_SUB    6'b001100 
// `define Type_SLL    6'b001101 
// `define Type_SLT    6'b001110 
// `define Type_SLTU   6'b001111 
// `define Type_XOR    6'b010000 
// `define Type_SRL    6'b010001 
// `define Type_SRA    6'b010010 
// `define Type_OR     6'b010011 
// `define Type_AND    6'b010100 
// `define Type_JAL    6'b010101 
// `define Type_JALR   6'b010110 
// `define Type_BEQ    6'b010111 
// `define Type_BNE    6'b011000 
// `define Type_BLT    6'b011001
// `define Type_BGE    6'b011010 
// `define Type_BLTU   6'b011011 
// `define Type_BGEU   6'b011100 
// `define Type_LB     6'b011101 
// `define Type_LH     6'b011110 
// `define Type_LW     6'b011111  
// `define Type_LBU    6'b100000 
// `define Type_LHU    6'b100001 
// `define Type_SB     6'b100010 
// `define Type_SH     6'b100011 
// `define Type_SW     6'b100100
// `define Type_NONE   6'b111111

`define AluOpBus    4 : 0
`define EX_NOP     5'b00000 
`define EX_ADD      5'b00001 
`define EX_SUB      5'b00010 
`define EX_SLT      5'b00011 
`define EX_SLTU     5'b00100 
`define EX_AUIPC    5'b00101 
`define EX_AND      5'b00110 
`define EX_OR       5'b00111 
`define EX_XOR      5'b01000 
`define EX_SLL      5'b01001 
`define EX_SRL      5'b01010 
`define EX_SRA      5'b01011 
`define EX_JAL      5'b01100 
`define EX_JALR     5'b01101 
`define EX_BEQ      5'b01110
`define EX_BNE      5'b01111 
`define EX_BLT      5'b10000 
`define EX_BGE      5'b10001 
`define EX_BLTU     5'b10010 
`define EX_BGEU     5'b10011 
`define EX_LB       5'b10100 
`define EX_LH       5'b10101 
`define EX_LW       5'b10110 
`define EX_LBU      5'b10111 
`define EX_LHU      5'b11000 
`define EX_SB       5'b11001 
`define EX_SH       5'b11010 
`define EX_SW       5'b11011 

`define AluSelBus       2 : 0
`define EX_RES_NOP      3'b000 
`define EX_RES_ARITH    3'b001 
`define EX_RES_LOGIC    3'b010 
`define EX_RES_SHIFT    3'b011 
`define EX_RES_JAL      3'b100 
`define EX_RES_LD_ST    3'b101 
