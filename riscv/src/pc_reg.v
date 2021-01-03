`timescale 1ns / 1ps

`include "config.v"

module pc_reg(
    input wire  clk,
    input wire  rst,

    input wire                  jump_res,
    input wire [`InstAddrBus]   jump_dst,

    input wire [`StallBus]      stall,

    output reg [`InstAddrBus]   pc

);



always @ (posedge clk) begin
    if (rst == `True) begin
        pc <= `ZERO_WORD;
//        $display("True :: rst == %B   pc == %H", rst, pc);
    // end else if(stall[2]) begin
        
    end else if(jump_res == `True) begin
        pc <= jump_dst;
    end else if(stall[0]) begin
    
    end else begin
        pc <= pc + 4'h4;
//        $display("False :: rst == %B   pc == %H", rst, pc);
    end
//        $display("rst == %B   pc == %H", rst, pc);
end

endmodule //pc:1194


// module predictor(
//     input wire          clk,
//     input wire          rst,

//     input wire [`InstAddrBus]   pc,
//     output reg                  pre_res,
//     output reg [`InstAddrBus]   pre_addr,

//     input wire [`InstAddrBus]   ex_pc,
//     input wire                  ex_flag,
//     input wire [`InstAddrBus]   ex_addr,
//     input wire                  ex_res
// );

// reg [`PTagBus]      tag[`PIndexNum - 1 : 0];
// reg [`InstAddrBus]  des[`PIndexNum - 1 : 0];
// reg [1 : 0]         res[`PIndexNum - 1 : 0];

// integer i;

// always @ (posedge clk) begin
//     if(rst == `True) begin
//         for(i = 0; i < `PIndexNum; i = i + 1) begin
//             tag[i][`PValidBit] <= `BitInvalid;
//             res[i] <= 2'b10;
//         end
//     end else if(ex_flag & ex_res) begin
//         tag[ex_pc[`PIndexBits]] <= ex_pc[`PTagBits];
//         des[ex_pc[`PIndexBits]] <= ex_addr;
//         if(res[ex_pc[`PIndexBits]] < 2'b11) begin
//             res[ex_pc[`PIndexBits]] <= res[ex_pc[`PIndexBits]] + 1;
//         end
//     end else if(ex_flag & (~ex_res)) begin
//         tag[ex_pc[`PIndexBits]] <= ex_pc[`PTagBits];
//         des[ex_pc[`PIndexBits]] <= ex_addr;
//         if(res[ex_pc[`PIndexBits]] > 2'b00) begin
//             res[ex_pc[`PIndexBits]] <= res[ex_pc[`PIndexBits]] - 1;
//         end
//     end
// end

// always @ (*) begin
//     if(rst == `True) begin
//         pre_res = `False;
//         pre_addr = `ZERO;
//     end else if(tag[pc[`PIndexBits]] == pc[`PTagBits] && res[pc[`PIndexBits]] == 1'b1) begin
//         pre_res = `True;
//         pre_addr = des[pc[`PIndexBits]];
//     end else begin
//         pre_res = `False;
//         pre_addr = `ZERO;
//     end
// end

// endmodule