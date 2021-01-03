`include "config.v"
module stall(
    input wire              clk,
    input wire              rst,

    input wire              if_stall,
    input wire              id_stall,
    input wire              ex_stall,
    input wire              mem_stall,
    // input wire              wb_stall,

    output reg [5 : 0]      stall_state
);

always @ (*) begin
    if(rst == `True) begin
        stall_state = 6'b111111;
    end else if(mem_stall == `True) begin
        stall_state = 6'b011111;
    end else if(ex_stall == `True) begin
        stall_state = 6'b001111;
    end else if(id_stall == `True) begin
        stall_state = 6'b000111;
    end else if(if_stall == `True) begin
        stall_state = 6'b000011;
    end else begin
        stall_state = 6'b000000;
    end
end


endmodule