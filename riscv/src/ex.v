`timescale 1ns / 1ps
`include "config.v"

module ex(
    input wire                  clk,
    input wire                  rst,

    input wire [`RegBus]        rs1_data,
    input wire [`RegBus]        rs2_data,
    input wire [`RegBus]        offset,
    input wire [`RegAddrBus]    rd_addr_i,
    input wire                  rd_enable_i,
    input wire [`AluOpBus]      aluop_i,
    input wire [`AluSelBus]     alusel,
    input wire [`InstAddrBus]   pc,

    output reg [`RegAddrBus]    rd_addr_o,
    output reg                  rd_enable_o,
    output reg [`RegBus]        rd_data,
    output reg [`AluOpBus]      aluop_o,
    output reg [`MemAddrBus]    ram_addr,

    output reg                  is_ld,

    // output reg                  is_jump,
    output reg                  jump_res,
    output reg [`RamAddrBus]    jump_dst
    // tow
    // tou
    // tuw
    // two
    // toe
    // tue
    // twu
);

reg [`RegBus]       logicout;
reg [`RegBus]       arithout;
reg [`RegBus]       shiftout;

always @ (*) begin//jump and branch
    jump_dst = `ZERO;
    jump_res = `False;
    // is_jump = `False;
    if(rst == `False) begin
        case (aluop_i)
            `EX_JAL: begin
                // is_jump = `True;
                jump_dst = pc + offset;
                jump_res = `True;
            end
            `EX_JALR: begin
                jump_dst = rs1_data + rs2_data;
                jump_dst[0] = 1'b0;
                jump_res = `True;
            end
            `EX_BEQ: begin
                if(rs1_data == rs2_data) begin
                    jump_dst = pc + offset;
                    jump_res = `True;
                end
            end
            `EX_BNE: begin
                if(rs1_data != rs2_data) begin
                    jump_dst = pc + offset;
                    jump_res = `True;
                end
            end
            `EX_BLT: begin
                if($signed(rs1_data) < $signed(rs2_data)) begin
                    jump_dst = pc + offset;
                    jump_res = `True;
                end
            end
            `EX_BLTU: begin
                if(rs1_data < rs2_data) begin
                    jump_dst = pc + offset;
                    jump_res = `True;
                end
            end
            `EX_BGE: begin
                if($signed(rs1_data) >= $signed(rs2_data)) begin
                    jump_dst = pc + offset;
                    jump_res = `True;
                end
            end
            `EX_BGEU: begin
                if(rs1_data >= rs2_data) begin
                    jump_dst = pc + offset;
                    jump_res = `True;
                end
            end
            default: begin
            end
        endcase
    end
end

always @ (*) begin//logic
    if(rst == `True) begin
        logicout = `ZERO;
    end else begin
        case (aluop_i)
            `EX_AND: begin
                logicout = rs1_data & rs2_data;
            end 
            `EX_OR: begin
                logicout = rs1_data | rs2_data;
            end
            `EX_XOR: begin
                logicout = rs1_data ^ rs2_data;
            end
            default: begin
                logicout = `ZERO;
            end
        endcase
    end
end

always @ (*) begin//arith
    if(rst == `True) begin
        arithout = `ZERO;
    end else begin
        case (aluop_i)
            `EX_ADD: begin
                arithout = rs1_data + rs2_data;
            end
            `EX_SUB: begin
                arithout = rs1_data - rs2_data;
            end
            `EX_SLT: begin
                arithout = $signed(rs1_data) < $signed(rs2_data);
            end
            `EX_SLTU: begin
                arithout = rs1_data < rs2_data;
            end
            `EX_AUIPC: begin
                arithout = pc + offset;
            end
            default: begin 
                arithout = `ZERO;
            end
        endcase
    end
end

always @ (*) begin//shift
    if(rst == `True) begin
        shiftout = `ZERO;
    end else begin
        case (aluop_i)
            `EX_SLL: begin
                shiftout = rs1_data << rs2_data;
            end
            `EX_SRL: begin
                shiftout = rs1_data >> rs2_data;
            end
            `EX_SRA: begin
                shiftout = (rs1_data >> rs2_data) | ((rs1_data[31]) << (6'd32 - rs2_data));
            end
            default: begin
                shiftout = `ZERO;
            end
        endcase
    end
end

always @ (*) begin//load and store
    if(rst == `True) begin
        ram_addr = `ZERO;
        is_ld = `False;
    end
    else begin
        case (aluop_i)
            `EX_LB, `EX_LH, `EX_LW, `EX_LBU, `EX_LHU: begin 
                ram_addr = rs1_data + offset;
                is_ld = `True;
            end
            `EX_SB, `EX_SH, `EX_SW: begin
                ram_addr = rs1_data + offset;
                is_ld = `False;
            end
            default: begin
                ram_addr = `ZERO;
                is_ld = `False;
            end
        endcase
    end
end

always @(*) begin
    if(rst == `True) begin
        rd_enable_o = `False;
        rd_addr_o = `ZERO;
        rd_data = `ZERO;
        aluop_o = `EX_NOP;
    end
    else begin
        rd_enable_o = rd_enable_i;
        rd_addr_o = rd_addr_i;
        case (alusel)
            `EX_RES_ARITH: begin
                rd_data = arithout;
                aluop_o = `EX_NOP;
            end
            `EX_RES_LOGIC: begin
                rd_data = logicout;
                aluop_o = `EX_NOP;
            end
            `EX_RES_SHIFT: begin
                rd_data = shiftout;
                aluop_o = `EX_NOP;
            end
            `EX_RES_JAL: begin
                rd_data = pc + 4;
                aluop_o = `EX_NOP;
            end
            `EX_RES_LD_ST: begin
                rd_data = rs2_data;
                aluop_o = aluop_i;
            end
            `EX_RES_NOP: begin
                rd_data = `ZERO;
                aluop_o = `EX_NOP;
            end
            default: begin
                rd_data = `ZERO;
                aluop_o = `EX_NOP;
            end
        endcase
    end
end

endmodule