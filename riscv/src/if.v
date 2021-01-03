`include "config.v"

module IF(
    input wire                  clk,
    input wire                  rst,
    input wire [`InstAddrBus]   pc_i,
    input wire [`InstBus]       inst_i,
    input wire                  if_done,
    input wire [`InstAddrBus]   if_pc,

    output reg [`InstAddrBus]   pc_o,
    output reg [`InstBus]       inst_o,

    output wire                 if_req,
    output reg [`InstAddrBus]   if_addr,

    output reg                 if_stall
);

reg [`TagBus]       ic_tag[`IndexNum - 1 : 0];
reg [`InstBus]      ic_inst[`IndexNum - 1 : 0];

assign if_req = (ic_tag[if_addr[`IndexBits]] != if_addr[`TagBits]) & (~if_done);

integer i;

always @ (posedge clk) begin
    if(rst) begin
        for(i = 0; i < `IndexNum; i = i + 1)begin
            ic_tag[i][`ValidBit] = `BitInvalid;
        end
//        if_req <= `False;
        if_addr <= `ZERO;
    end else if(if_done == `True)begin 
//        if_req <= `False;
        ic_tag[if_pc[`IndexBits]] = if_pc[`TagBits];
        ic_inst[if_pc[`IndexBits]] = inst_i;
        if_addr <= pc_i + 4;
    end else begin
    //        if_req <= `True;
        if_addr <= pc_i;
    end
end

always @ (*) begin
    if(rst) begin
        inst_o <= `ZERO;
        pc_o <= `ZERO;
        if_stall <= `False;
//        if_req <= `False;
//        if_addr <= `ZERO;
    end else if(ic_tag[pc_i[`IndexBits]] == pc_i[`TagBits]) begin
        inst_o <= ic_inst[pc_i[`IndexBits]];
        pc_o <= pc_i;
        if_stall <= `False;
    end
    else if(if_done == `True && if_pc == pc_i) begin
        inst_o <= inst_i;
        pc_o <= pc_i;
//        if_req <= `True;//when work done, the new address is not ready
//        if_addr <= pc_i;
        if_stall <= `False;
    end else begin
        inst_o <= `ZERO;
        pc_o <= `ZERO;
//        if_req <= `True;
//        if_addr <= pc_i;
        if_stall <= `True;
    end 
end

endmodule