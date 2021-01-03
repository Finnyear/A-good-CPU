`timescale 1ns / 1ps

`include "config.v"

module id(
    input wire                  clk,
    input wire                  rst,

    input wire [`InstAddrBus]   pc_i,
    input wire [`InstBus]       inst_i,

    input wire [`RegBus]        rs1_i,
    input wire [`RegBus]        rs2_i,
    
    output reg                  rs1_enable,
    output reg [`RegAddrBus]    rs1_addr,

    output reg                  rs2_enable,
    output reg [`RegAddrBus]    rs2_addr,

    output reg                  rd_enable,
    output reg [`RegAddrBus]    rd_addr,

    output reg [`RegBus]        rs1_data,
    output reg [`RegBus]        rs2_data,
    output reg [`RegBus]        offset,
    
    output reg [`AluOpBus]      aluop,
    output reg [`AluSelBus]     alusel,
    output reg [`InstAddrBus]   pc_o,

    input wire                  ex_ld,
    input wire                  ex_rd_enable,
    input wire [`RegAddrBus]    ex_rd_addr,
    input wire [`RegBus]        ex_rd_data,
    input wire                  mem_rd_enable,
    input wire [`RegAddrBus]    mem_rd_addr,
    input wire [`RegBus]        mem_rd_data,
    
    output wire                 id_stall
);

wire [6 : 0] opcode = inst_i [6 : 0];
wire [2 : 0] funct3 = inst_i [14 : 12];
wire [6 : 0] funct7 = inst_i [31 : 25];
wire [`ImmBus] imm_I = {{20{inst_i[31]}}, inst_i [31 : 20]};
wire [`ImmBus] imm_S = {{21{inst_i[31]}}, inst_i[30 : 25], inst_i[11 : 7]};
wire [`ImmBus] imm_B = {{20{inst_i[31]}}, inst_i[7], inst_i[30 : 25], inst_i[11 : 8], 1'b0};
wire [`ImmBus] imm_U = {inst_i[31 : 12], {12{1'b0}}};
wire [`ImmBus] imm_J = {{12{inst_i[31]}}, inst_i[19 : 12], inst_i[20], inst_i[30 : 21], 1'b0};
wire [`RegAddrBus] rs1 = inst_i [19 : 15];
wire [`RegAddrBus] rs2 = inst_i [24 : 20];
wire [`RegAddrBus] rd = inst_i [11 : 7];
reg [`ImmBus] imm_data;

    
//Decode: Get opcode, imm, rd, and the addr of rs1&rs2
always @ (*) begin
    rs1_enable = `False;
    rs1_addr = rs1;
    rs2_enable = `False;
    rs2_addr = rs2;
    rd_enable = `False;
    rd_addr = rd;
    imm_data = `ZERO;
    aluop = `EX_NOP;
    alusel = `EX_RES_NOP;
    pc_o = pc_i;
    if(rst == `True) begin
        rs1_addr = `ZERO;
        rs2_addr = `ZERO;
        rd_addr = `ZERO;
        pc_o = `ZERO;
    end else begin
        case (opcode)
            `OP_OPIMM: begin
                rs1_enable = `True;
                rd_enable = `True;
                case (funct3)
                    `F3_ADD: begin
//                        inst_type = `Type_ADDI;
                        aluop = `EX_ADD;
                        alusel = `EX_RES_ARITH;
                        imm_data = imm_I;
                    end
                    `F3_SLT: begin
//                        inst_type = `Type_SLTI;
                        aluop = `EX_SLT;
                        alusel = `EX_RES_ARITH;
                        imm_data = imm_I;
                    end 
                    `F3_SLTU: begin
                        // inst_type = `Type_SLTIU;
                        aluop = `EX_SLTU;
                        alusel = `EX_RES_ARITH;
                        imm_data = imm_I;
                    end
                    `F3_AND: begin
                        // inst_type = `Type_ANDI;
                        aluop = `EX_AND;
                        alusel = `EX_RES_LOGIC;
                        imm_data = imm_I;
                    end
                    `F3_OR: begin
                        // inst_type = `Type_ORI;
                        aluop = `EX_OR;
                        alusel = `EX_RES_LOGIC;
                        imm_data = imm_I;
                    end
                    `F3_XOR: begin
                        // inst_type = `Type_XORI;
                        aluop = `EX_XOR;
                        alusel = `EX_RES_LOGIC;
                        imm_data = imm_I;
                    end
                    `F3_SLL: begin
                        // inst_type = `Type_SLLI;
                        aluop = `EX_SLL;
                        alusel = `EX_RES_SHIFT;
                        imm_data = {{27{1'b0}}, imm_I[4 : 0]};
                    end
                    `F3_SR: begin
                        imm_data = {{27{1'b0}}, imm_I[4 : 0]};
                        case (funct7)
                            `F7_SRL: begin
                                // inst_type = `Type_SRLI;
                                aluop = `EX_SRL;
                                alusel = `EX_RES_SHIFT;
                            end
                            `F7_SRA: begin
                                // inst_type = `Type_SRAI;
                                aluop = `EX_SRA;
                                alusel = `EX_RES_SHIFT;
                            end
                            default: begin
                            end
                        endcase
                    end
                    default: begin
                    end
                endcase
            end 
            `OP_LUI: begin
                imm_data = imm_U;
                rd_enable = `True;
                // inst_type = `Type_LUI;
                aluop = `EX_OR;
                alusel = `EX_RES_LOGIC;
            end 
            `OP_AUIPC: begin
                imm_data = imm_U;
                rd_enable = `True;
                // inst_type = `Type_AUIPC;
                aluop = `EX_AUIPC;
                alusel = `EX_RES_ARITH;
            end
            `OP_OP: begin
                rs1_enable = `True;
                rs2_enable = `True;
                rd_enable = `True;
                imm_data = `ZERO_WORD;
                case (funct3)
                    `F3_ADD: begin
                        case (funct7)
                            `F7_ADD: begin
                                // inst_type = `Type_ADD;
                                aluop = `EX_ADD;
                                alusel = `EX_RES_ARITH;
                            end
                            `F7_SUB: begin
                                // inst_type = `Type_SUB;
                                aluop = `EX_SUB;
                                alusel = `EX_RES_ARITH;
                            end
                            default: begin
                            end
                        endcase
                    end
                    `F3_SLL: begin
                        // inst_type = `Type_SLL;
                        aluop = `EX_SLL;
                        alusel = `EX_RES_SHIFT;
                    end
                    `F3_SLT: begin
                        // inst_type = `Type_SLT;
                        aluop = `EX_SLT;
                        alusel = `EX_RES_ARITH;
                    end
                    `F3_SLTU: begin
                        // inst_type = `Type_SLTU;
                        aluop = `EX_SLTU;
                        alusel = `EX_RES_ARITH;
                    end
                    `F3_XOR: begin
                        // inst_type = `Type_XOR;
                        aluop = `EX_XOR;
                        alusel = `EX_RES_LOGIC;
                    end
                    `F3_SR: begin
                        case (funct7)
                            `F7_SRL: begin
                                // inst_type = `Type_SRL;
                                aluop = `EX_SRL;
                                alusel = `EX_RES_SHIFT;
                            end
                            `F7_SRA: begin
                                // inst_type = `Type_SRA;
                                aluop = `EX_SRL;
                                alusel = `EX_RES_SHIFT;
                            end
                            default: begin
                            end
                        endcase
                    end
                    `F3_OR: begin
                        // inst_type = `Type_OR;
                        aluop = `EX_OR;
                        alusel = `EX_RES_LOGIC;
                    end
                    `F3_AND: begin
                        // inst_type = `Type_AND;
                        aluop = `EX_AND;
                        alusel = `EX_RES_LOGIC;
                    end
                    default: begin
                    end
                endcase
            end
            `OP_JAL: begin
                rd_enable = `True;
                imm_data = imm_J;
                // inst_type = `Type_JAL;
                aluop = `EX_JAL;
                alusel = `EX_RES_JAL;
            end
            `OP_JALR: begin
                rd_enable = `True;
                rs1_enable = `True;
                imm_data = imm_I;
                // inst_type = `Type_JALR;
                aluop = `EX_JALR;
                alusel = `EX_RES_JAL;
            end
            `OP_BRANCH: begin
                rs1_enable = `True;
                rs2_enable = `True;
                imm_data = imm_B;
                alusel = `EX_RES_NOP;
                case (funct3)
                    `F3_BEQ: begin
                        // inst_type = `Type_BEQ;
                        aluop = `EX_BEQ;
                    end
                    `F3_BNE: begin
                        // inst_type = `Type_BNE;
                        aluop = `EX_BNE;
                    end
                    `F3_BLT: begin
                        // inst_type = `Type_BLT;
                        aluop = `EX_BLT;
                    end
                    `F3_BGE: begin
                        // inst_type = `Type_BGE;
                        aluop = `EX_BGE;
                    end
                    `F3_BLTU: begin
                        // inst_type = `Type_BLTU;
                        aluop = `EX_BLTU;
                    end
                    `F3_BGEU: begin
                        // inst_type = `Type_BGEU;
                        aluop = `EX_BGEU;
                    end
                    default: begin
                    end
                endcase
            end
            `OP_LOAD: begin
                rs1_enable = `True;
                rd_enable = `True;
                imm_data = imm_I;
                alusel = `EX_RES_LD_ST;
                case (funct3)
                    `F3_LB: begin
                        // inst_type = `Type_LB;
                        aluop = `EX_LB;
                    end
                    `F3_LH: begin
                        // inst_type = `Type_LH;
                        aluop = `EX_LH;
                    end
                    `F3_LW: begin
                        // inst_type = `Type_LW;
                        aluop = `EX_LW;
                    end
                    `F3_LBU: begin
                        // inst_type = `Type_LBU;
                        aluop = `EX_LBU;
                    end
                    `F3_LHU: begin
                        // inst_type = `Type_LHU;
                        aluop = `EX_LHU;
                    end
                    default: begin
                    end
                endcase
            end
            `OP_STORE: begin
                rs1_enable = `True;
                rs2_enable = `True;
                imm_data = imm_S;
                alusel = `EX_RES_LD_ST;
                case (funct3)
                    `F3_SB: begin
                        // inst_type = `Type_SB;
                        aluop = `EX_SB;
                    end
                    `F3_SH: begin
                        // inst_type = `Type_SH;
                        aluop = `EX_SH;
                    end
                    `F3_SW: begin
                        // inst_type = `Type_SW;
                        aluop = `EX_SW;
                    end
                    default: begin
                    end
                endcase
            end
            default: begin
            end
        endcase
    end
end
/*
always @(*) begin
    Imm = `ZERO_WORD;
    rd_enable = `WriteDisable;
    reg1_read_enable = `ReadDisable;
    reg2_read_enable = `ReadDisable;
    rd = `ZeroReg; 
    aluop = `NOP;
    alusel = `NOP_SEL;
    useImmInstead = 1'b0;
    case (opcode)
        `INTCOM_ORI: begin
            Imm = { {19{inst[31]}} ,inst[31:20] };
            rd_enable = `WriteEnable;
            reg1_read_enable = `ReadEnable;
            reg2_read_enable = `ReadDisable;
            rd = inst[11 : 7];
            aluop = `EXE_OR;
            alusel = `LOGIC_OP;
            useImmInstead = 1'b1;
        end
        //todo: add more op here. 
    endcase
end
*/
reg rs1_stall;
reg rs2_stall;
assign id_stall = rs1_stall | rs2_stall;
always @ (*) begin
    rs1_stall = `False;
    if(rst == `True) begin
        rs1_data = `ZERO;
    end else if(rs1_enable == `True && ex_ld == `True && ex_rd_addr == rs1_addr)begin
        rs1_data = `ZERO;
        rs1_stall = `True;
    end else if(rs1_enable == `True && ex_rd_enable == `True && ex_rd_addr == rs1_addr) begin
        rs1_data = ex_rd_data;
    end else if(rs1_enable == `True && mem_rd_enable == `True && mem_rd_addr == rs1_addr) begin
        rs1_data = mem_rd_data;
    end else if(rs1_enable == `True) begin
        rs1_data = rs1_i;
    end else if(rs1_enable == `False)begin
        rs1_data = imm_data;
    end else begin
        rs1_data = `ZERO;
    end
end
always @ (*) begin
    rs2_stall = `False;
    if(rst == `True) begin
        rs2_data = `ZERO;
    end else if(rs2_enable == `True && ex_ld == `True && ex_rd_addr == rs2_addr)begin
        rs2_data = `ZERO;
        rs2_stall = `True;
    end else if(rs2_enable == `True && ex_rd_enable == `True && ex_rd_addr == rs2_addr) begin
        rs2_data = ex_rd_data;
    end else if(rs2_enable == `True && mem_rd_enable == `True && mem_rd_addr == rs2_addr) begin
        rs2_data = mem_rd_data;
    end else if(rs2_enable == `True) begin
        rs2_data = rs2_i;
    end else if(rs2_enable == `False) begin
        rs2_data = imm_data;
    end else begin
        rs2_data = `ZERO;
    end
end
always @ (*) begin
    if(rst == `True) begin
        offset = `ZERO;
    end else begin
        offset = imm_data;
    end
end

endmodule