`timescale 1ns / 1ps

`include "config.v"

module mem(
    input wire                  clk,
    input wire                  rst,

    input wire [`RamAddrBus]    mem_addr_i,
    input wire [`RegBus]        rd_data_i,
    input wire                  rd_enable_i,
    input wire [`RegAddrBus]    rd_addr_i,
    input wire [`AluOpBus]      aluop,

    input wire [`RegBus]        re_data,
    input wire                  re_done,
    input wire                  wr_done,

    output reg                 re_req,
    output reg                 wr_req,
    output reg [`RamAddrBus]   mem_addr,
    output reg [`StageBus]     mem_stage,
    output reg [`RegBus]       wr_data,
    
    output reg [`RegBus]       rd_data_o,
    output reg                 rd_enable_o,
    output reg [`RegAddrBus]   rd_addr_o,

    output reg                 mem_stall
);

//wire [`RegBus]  load_data;

always @ (*) begin
    if(rst == `True) begin
        re_req = `False;
        wr_req = `False;
        mem_addr = `ZERO;
        mem_stage = 2'b00;
        wr_data = `ZERO;
        rd_data_o = `ZERO;
        rd_enable_o = `False;
        rd_addr_o = `ZERO;
        mem_stall = `False;
    end else begin
        rd_enable_o = rd_enable_i;
        rd_addr_o = rd_addr_i;
        rd_data_o = rd_data_i;
        wr_data = `ZERO;
        case (aluop)
            `EX_NOP: begin
                rd_data_o = rd_data_i;
                mem_addr = `ZERO;
                re_req = `False;
                wr_req = `False;
                wr_data = `ZERO;
                mem_stage = 2'b00;
                mem_stall = `False;
            end
            `EX_LB: begin
                mem_addr = mem_addr_i;
                re_req = `True;
                wr_req = `False;
                mem_stage = 2'b00;
                rd_data_o = {{24{re_data[7]}},re_data[7: 0]};
                mem_stall = !re_done; 
            end
            `EX_LBU: begin
                mem_addr = mem_addr_i;
                re_req = `True;
                wr_req = `False;
                mem_stage = 2'b00;
                rd_data_o = {24'b0,re_data[7: 0]};
                mem_stall = !re_done; 
            end
            `EX_LH: begin
                mem_addr = mem_addr_i;
                re_req = `True;
                wr_req = `False;
                mem_stage = 2'b01;
                rd_data_o = {{16{re_data[15]}},re_data[15: 0]};
                mem_stall = !re_done; 
            end
            `EX_LHU: begin
                mem_addr = mem_addr_i;
                re_req = `True;
                wr_req = `False;
                mem_stage = 2'b01;
                rd_data_o = {16'b0,re_data[15: 0]};
                mem_stall = !re_done; 
            end
            `EX_LW: begin
                mem_addr = mem_addr_i;
                re_req = `True;
                wr_req = `False;
                mem_stage = 2'b11;
                rd_data_o = re_data;
                mem_stall = !re_done;
            end
            `EX_SB: begin
                mem_addr = mem_addr_i;
                wr_req = `True;
                re_req = `False;
                mem_stage = 2'b00;
                wr_data = rd_data_i;
                mem_stall = !wr_done;
            end
            `EX_SH: begin
                mem_addr = mem_addr_i;
                wr_req = `True;
                re_req = `False;
                mem_stage = 2'b01;
                wr_data = rd_data_i;
                mem_stall = !wr_done;
            end
            `EX_SW: begin
                mem_addr = mem_addr_i;
                wr_req = `True;
                re_req = `False;
                mem_stage = 2'b11;
                wr_data = rd_data_i;
                mem_stall = !wr_done;
            end
            default: begin
                rd_data_o = rd_data_i;
                mem_addr = `ZERO;
                re_req = `False;
                wr_req = `False;
                wr_data = `ZERO;
                mem_stage = 2'b00;
                mem_stall = `False;
            end
        endcase
    end
end


endmodule



















/*
module mem(
    input rst,
    input wire [`RegLen - 1 : 0] rd_data_i,
    input wire [`RegAddrLen - 1 : 0] rd_addr_i,
    input wire rd_enable_i,

    output reg [`RegLen - 1 : 0] rd_data_o,
    output reg [`RegAddrLen - 1 : 0] rd_addr_o,
    output reg rd_enable_o
    );

always @ (*) begin
    if (rst == `ResetEnable) begin
        rd_data_o = `ZERO_WORD;
        rd_addr_o = `RegAddrLen'h0;
        rd_enable_o = `WriteDisable;
    end
    else begin
        rd_data_o = rd_data_i;
        rd_addr_o = rd_addr_i;
        rd_enable_o = rd_enable_i;
    end
end

endmodule
*/