`timescale 1ns / 1ps

`include "config.v"

module register(
    input wire                  clk,
    input wire                  rst,
    input wire                  w_enable,
    input wire [`RegAddrBus]    w_addr,
    input wire [`RegBus]        w_data,
    input wire                  r1_enable,
    input wire [`RegAddrBus]    r1_addr,
    output reg [`RegBus]       r1_data,
    input wire                  r2_enable,
    input wire [`RegAddrBus]    r2_addr,
    output reg [`RegBus]       r2_data
);

reg [`RegBus]   regs[`RegNum - 1 : 0];
integer i;

always @ (posedge clk) begin
    if (rst == `True) begin
        for(i = 0; i < `RegNum; i = i + 1) begin
            regs[i] <= `ZERO;
        end
    end else if(w_enable == `True) begin
        if(w_addr != `X0_Addr) begin
            regs[w_addr] <= w_data;
        end
    end
end

always @ (*) begin
    if(rst == `True || r1_enable == `False) begin
        r1_data <= `ZERO;
    end else begin
        if(r1_addr == `X0_Addr) begin
            r1_data <= `ZERO;
        end else if(w_enable && r1_addr == w_addr) begin
            r1_data <= w_data;
        end else begin
            r1_data <= regs[r1_addr];
        end
    end
end

always @ (*) begin
    if(rst == `True || r2_enable == `False) begin
        r2_data <= `ZERO;
    end else begin
        if(r2_addr == `X0_Addr) begin
            r2_data <= `ZERO;
        end else if(w_enable && r2_addr == w_addr) begin
            r2_data <= w_data;
        end else begin
            r2_data <= regs[r2_addr];
        end
    end
end

endmodule
