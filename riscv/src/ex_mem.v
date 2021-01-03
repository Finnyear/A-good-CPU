`timescale 1ns / 1ps
`include "config.v"


module ex_mem(
    input wire                  clk,
    input wire                  rst,

    input wire [`RegAddrBus]    ex_rd_addr,
    input wire                  ex_rd_enable,
    input wire [`RegBus]        ex_rd_data,
    input wire [`AluOpBus]      ex_aluop,
    input wire [`MemAddrBus]    ex_ram_addr,

    input wire [`StallBus]      stall,

    output reg [`RegAddrBus]    mem_rd_addr,
    output reg                  mem_rd_enable,
    output reg [`RegBus]        mem_rd_data,
    output reg [`AluOpBus]      mem_aluop,
    output reg [`MemAddrBus]    mem_ram_addr
);

always @ (posedge clk) begin
    if(rst == `True) begin
        mem_rd_addr <= `ZERO;
        mem_rd_enable <= `False;
        mem_rd_data <= `ZERO;
        mem_aluop <= `EX_NOP;
        mem_ram_addr <= `ZERO;
    end else if(stall[`Stall_MEM] == `True) begin
        
    end else if(stall[`Stall_EX] == `False) begin
        mem_rd_addr <= ex_rd_addr;
        mem_rd_enable <= ex_rd_enable;
        mem_rd_data <= ex_rd_data;
        mem_aluop <= ex_aluop;
        mem_ram_addr <= ex_ram_addr;
    end else begin
        mem_rd_addr <= `ZERO;
        mem_rd_enable <= `False;
        mem_rd_data <= `ZERO;
        mem_aluop <= `EX_NOP;
        mem_ram_addr <= `ZERO;
    end
end

endmodule
















/*

module ex_mem(
    input wire clk,
    input wire rst,
    input wire [`RegLen - 1 : 0] ex_rd_data,
    input wire [`RegAddrLen - 1 : 0] ex_rd_addr,
    input wire ex_rd_enable,

    output reg [`RegLen - 1 : 0] mem_rd_data,
    output reg [`RegAddrLen - 1 : 0] mem_rd_addr,
    output reg mem_rd_enable
    );

always @ (posedge clk) begin
    if (rst == `ResetEnable) begin
        //TODO: Reset
    end
    else begin
        mem_rd_data <= ex_rd_data;
        mem_rd_addr <= ex_rd_addr;
        mem_rd_enable <= ex_rd_enable;
    end
end

endmodule
*/