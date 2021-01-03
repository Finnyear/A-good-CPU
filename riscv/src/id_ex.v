`timescale 1ns / 1ps

`include "config.v"

module id_ex(
    input wire                  clk,
    input wire                  rst,

    input wire                  ex_flag,
    input wire [`StallBus]      stall,

    input wire [`RegBus]        id_rs1_data,
    input wire [`RegBus]        id_rs2_data,
    input wire [`RegAddrBus]    id_rd_addr,
    input wire                  id_rd_enable,
    input wire [`RegBus]        id_offset,
    input wire [`AluOpBus]      id_aluop,
    input wire [`AluSelBus]     id_alusel,
    input wire [`InstAddrBus]   id_pc,

    output reg [`RegBus]        ex_rs1_data,
    output reg [`RegBus]        ex_rs2_data,
    output reg [`RegAddrBus]    ex_rd_addr,
    output reg                  ex_rd_enable,
    output reg [`RegBus]        ex_offset,
    output reg [`AluOpBus]     ex_aluop,
    output reg [`AluSelBus]    ex_alusel,
    output reg [`InstAddrBus]   ex_pc
);

always @ (posedge clk) begin
    if(rst == `True) begin
        ex_rs1_data <= `ZERO;
        ex_rs2_data <= `ZERO;
        ex_rd_addr <= `ZERO;
        ex_rd_enable <= `False;
        ex_offset <= `ZERO;
        ex_aluop <= `EX_NOP;
        ex_alusel <= `EX_RES_NOP;
        ex_pc <= `ZERO;
    end else if(stall[`Stall_EX] == `True)begin
    
    end else if(ex_flag) begin
        ex_rs1_data <= `ZERO;
        ex_rs2_data <= `ZERO;
        ex_rd_addr <= `ZERO;
        ex_rd_enable <= `False;
        ex_offset <= `ZERO;
        ex_aluop <= `EX_NOP;
        ex_alusel <= `EX_RES_NOP;
        ex_pc <= `ZERO;
    end else if(stall[`Stall_ID] == `False)begin
        ex_rs1_data <= id_rs1_data;
        ex_rs2_data <= id_rs2_data;
        ex_rd_addr <= id_rd_addr;
        ex_rd_enable <= id_rd_enable;
        ex_offset <= id_offset;
        ex_aluop <= id_aluop;
        ex_alusel <= id_alusel;
        ex_pc <= id_pc;
    end else begin
        ex_rs1_data <= `ZERO;
        ex_rs2_data <= `ZERO;
        ex_rd_addr <= `ZERO;
        ex_rd_enable <= `False;
        ex_offset <= `ZERO;
        ex_aluop <= `EX_NOP;
        ex_alusel <= `EX_RES_NOP;
        ex_pc <= `ZERO;
    end
end

endmodule





















/*

module id_ex(
    input wire clk,
    input wire rst,
    input wire [`RegLen - 1 : 0] id_reg1,
    input wire [`RegLen - 1 : 0] id_reg2,
    input wire [`RegLen - 1 : 0] id_offset,
    input wire [`RegLen - 1 : 0] id_rd,
    input wire id_rd_enable,
    input wire [`OpCodeLen - 1 : 0] id_aluop,
    input wire [`OpSelLen - 1 : 0] id_alusel,

    output reg [`RegLen - 1 : 0] ex_reg1,
    output reg [`RegLen - 1 : 0] ex_reg2,
    output reg [`RegLen - 1 : 0] ex_Imm,
    output reg [`RegLen - 1 : 0] ex_rd,
    output reg ex_rd_enable,
    output reg [`OpCodeLen - 1 : 0] ex_aluop,
    output reg [`OpSelLen - 1 : 0] ex_alusel
);

always @ (posedge clk) begin
    if (rst == `ResetEnable) begin
        //TODO: ASSIGN ALL OUTPUT WITH NULL EQUIVALENT
    end
    else begin
        ex_reg1 <= id_reg1;
        ex_reg2 <= id_reg2;
        ex_Imm <= id_offset;
        ex_rd <= id_rd;
        ex_rd_enable <= id_rd_enable;
        ex_aluop <= id_aluop;
        ex_alusel <= id_alusel;
    end
end

endmodule
*/