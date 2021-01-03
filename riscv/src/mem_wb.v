`timescale 1ns / 1ps

`include "config.v"

module mem_wb(
    input                       clk,
    input                       rst,
    input wire [`RegBus]        mem_rd_data,
    input wire [`RegAddrBus]    mem_rd_addr,
    input wire                  mem_rd_enable,

    input wire [`StallBus]      stall,

    output reg [`RegBus]       wb_rd_data,
    output reg [`RegAddrBus]   wb_rd_addr,
    output reg                 wb_rd_enable
);


always @ (posedge clk) begin
    if (rst == `True) begin
        wb_rd_data <= `ZERO;
        wb_rd_addr <= `ZERO;
        wb_rd_enable <= `False;
    end else if(stall[`Stall_MEM] == `False) begin
        wb_rd_data <= mem_rd_data;
        wb_rd_addr <= mem_rd_addr;
        wb_rd_enable <= mem_rd_enable;
    end else begin
        wb_rd_data <= `ZERO;
        wb_rd_addr <= `ZERO;
        wb_rd_enable <= `False;
    end
end


endmodule
