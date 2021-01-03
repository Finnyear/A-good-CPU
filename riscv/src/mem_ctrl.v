`include "config.v"

module mem_ctrl(
    input wire                      clk,
    input wire                      rst,

    input wire                      io_buffer_full,

    input wire                      if_req,
    input wire [`InstAddrBus]       if_addr,
    output reg [`RegBus]            if_data,
    output reg [`InstAddrBus]       if_pc,
    output reg                      if_done,

    input wire                      mem_re_req,
    input wire                      mem_wr_req,
    input wire [`MemAddrBus]        mem_addr,
    input wire [`StageBus]          mem_stage,
    input wire [`RegBus]            mem_wr_data,
    output reg                      mem_wr_done,
    output reg [`RegBus]            mem_re_data,
    output reg                      mem_re_done,

    input wire [7 : 0]              cpu_din,
    output reg [7 : 0]              cpu_dout,
    output reg [31 : 0]             cpu_a,
    output reg                      cpu_wr
);

reg [1 : 0]    state;
reg [2 : 0]    stage;
reg [`MemAddrBus]   ram_addr;

reg             wr_flag;

always @ (posedge clk) begin
    if(rst == `True) begin
        stage <= 3'o0;
        state <= `State_NONE;
        mem_wr_done <= `False;
        mem_re_done <= `False;
        mem_re_data <= `ZERO;
        if_done <= `False;
        if_data <= `ZERO;
        cpu_dout <= `ZERO;
        cpu_a <= `ZERO;
        cpu_wr <= `False;
        ram_addr <= `ZERO;
        if_pc <= `ZERO;
    end else begin
        if(state == `State_NONE) begin
            if(!mem_re_done && mem_re_req == `True) begin
                cpu_wr <= `Read;
                cpu_a <= mem_addr + mem_stage;
                ram_addr <= mem_addr;
                if_done <= `False;
                mem_re_done <= `False;
                mem_wr_done <= `False;
                state <= `State_LOAD;
                case (mem_stage)
                    2'b11: begin stage <= 3'o4; end 
                    2'b01: begin stage <= 3'o2; end
                    2'b00: begin stage <= 3'o1; end
                    default: begin end
                endcase
                wr_flag <= `False;
            end else if(!mem_wr_done && mem_wr_req == `True && io_buffer_full == `False) begin
                if(wr_flag == `True) begin
                    wr_flag = `False;
                end else begin
                    cpu_wr <= `Write;
                    cpu_a <= mem_addr + mem_stage;
                    ram_addr <= mem_addr;
                    if_done <= `False;
                    mem_re_done <= `False;
                    mem_wr_done <= `False;
                    state <= `State_STORE;
                    case (mem_stage)
                        2'b11: begin 
                            stage <= 3'o3; 
                            cpu_dout <= mem_wr_data[31 : 24];
                        end 
                        2'b01: begin 
                            stage <= 3'o1; 
                            cpu_dout <= mem_wr_data[15 : 8];
                        end
                        2'b00: begin 
                            stage <= 3'o0; 
                            cpu_dout <= mem_wr_data[7 : 0];
                        end
                        default: begin end
                    endcase
                end
            end else if(if_req == `True) begin
                cpu_wr <= `Read;
                cpu_a <= if_addr + 3;
                ram_addr <= if_addr;
                state <= `State_IF;
                if_done <= `False;
                mem_re_done <= `False;
                mem_wr_done <= `False;
                stage <= 3'o4;
                wr_flag <= `False;
            end else begin
                if_done <= `False;
                mem_wr_done <= `False;
                mem_re_done <= `False;
                state <= `State_NONE;
                cpu_a <= `ZERO;
                cpu_wr <= `Read;
                wr_flag <= `False;
            end
        end else if (state == `State_IF && if_req &&if_addr != ram_addr) begin
            ram_addr <= if_addr;
            cpu_a <= if_addr + 3;
            stage <= 3'o4;
            if_done <= `False;
            mem_re_done <= `False;
            mem_wr_done <= `False;
        end else if (state == `State_IF) begin
            if_done <= `False;
            mem_re_done <= `False;
            mem_wr_done <= `False;
            case (stage)
                3'o4: begin
                    stage <= 3'o3;
                    cpu_a <= ram_addr + 2;
                end
                3'o3: begin
                    if_data[31 : 24] <= cpu_din;
                    stage <= 3'o2;
                    cpu_a <= ram_addr + 1;
                end
                3'o2: begin
                    if_data[23 : 16] <= cpu_din;
                    stage <= 3'o1;
                    cpu_a <= ram_addr;
                end 
                3'o1: begin
                    if_data[15 : 8] <= cpu_din;
                    stage <= 3'o0;
                end
                3'o0: begin
                    if_data[7 : 0] <= cpu_din;
                    if_done <= `True;
                    if_pc <= ram_addr;
                    state <= `State_NONE;
                end
                default: begin
                end
            endcase
        end else if(state == `State_LOAD) begin
            if_done <= `False;
            mem_re_done <= `False;
            mem_wr_done <= `False;
            case (stage)
                3'o4: begin
//                    mem_re_data[31 : 24] <= cpu_din;
                    stage <= 3'o3;
                    cpu_a <= ram_addr + 2;
                end
                3'o3: begin
                    mem_re_data[31 : 24] <= cpu_din;
                    stage <= 3'o2;
                    cpu_a <= ram_addr + 1;
                end
                3'o2: begin
                    mem_re_data[23 : 16] <= cpu_din;
                    stage <= 3'o1;
                    cpu_a <= ram_addr;
                end
                3'o1: begin
                    mem_re_data[15 : 8] <= cpu_din;
                    stage <= 3'o0;
                end
                3'o0: begin
                    mem_re_data[7 : 0] <= cpu_din;
                    mem_re_done <= `True;
                    state <= `State_NONE;
                end
                default: begin end
            endcase
        end else if(state == `State_STORE && io_buffer_full == `False) begin
            if_done <= `False;
            mem_re_done <= `False;
            mem_wr_done <= `False;
            case (stage)
                3'o3: begin
                    cpu_dout <= mem_wr_data[23 : 16];
                    stage <= 3'o2;
                    cpu_a <= ram_addr + 2;
                end
                3'o2: begin
                    cpu_dout <= mem_wr_data[15 : 8];
                    stage <= 3'o1;
                    cpu_a <= ram_addr + 1;
                end
                3'o1: begin
                    cpu_dout <= mem_wr_data[7 : 0];
                    stage <= 3'o0;
                    cpu_a <= ram_addr;
                end
                3'o0: begin
                    mem_wr_done <= `True;
                    state <= `State_NONE;
                    cpu_wr <= `Read;
                    wr_flag <= `True;
                end
                default: begin
                end
            endcase
        end
    end
end

endmodule

















