`include "config.v"

module if_id(
    input wire                  clk,
    input wire                  rst,

    input wire[`InstAddrBus]    if_pc,
    input wire[`InstBus]        if_inst,

    input wire                  ex_flag,
    input wire[`StallBus]       stall,

    output reg[`InstAddrBus]    id_pc,
    output reg[`InstBus]        id_inst
);

always @ (posedge clk) begin
    if(rst == `True) begin
        id_pc <= `ZERO;
        id_inst <= `ZERO;
    end else if(stall[`Stall_ID] == `True) begin

    end else if(ex_flag) begin
        id_pc <= `ZERO;
        id_inst <= `ZERO;
    end else if(stall[`Stall_IF] == `False)begin
        id_pc <= if_pc;
        id_inst <= if_inst;
    end else begin
        id_pc <= `ZERO;
        id_inst <= `ZERO;
    end
end

endmodule


