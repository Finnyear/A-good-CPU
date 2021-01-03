// RISCV32I CPU top module
// port modification allowed for debugging purposes

`include "config.v"

module cpu(
  input  wire                 clk_in,			// system clock signal
  input  wire                 rst_in,			// reset signal
  input  wire			      rdy_in,			// ready signal, pause cpu when low

  input  wire [7 : 0]         mem_din,		// data input bus
  output wire [7 : 0]         mem_dout,		// data output bus
  output wire [31 : 0]        mem_a,			// address bus (only 17:0 is used)
  output wire                 mem_wr,			// write/read signal (1 for write)

  input  wire                 io_buffer_full, // 1 if uart buffer is full
	
  output wire [31:0]		dbgreg_dout		// cpu register output (debugging demo)
);

wire rst = rst_in | (~rdy_in);

wire [`InstAddrBus]     pc;
wire [`InstAddrBus]     pc_if;
wire [`InstAddrBus]     pc_id_i;
wire [`InstAddrBus]     pc_id_o;
wire [`InstAddrBus]     pc_ex;

wire                    is_ld;

wire                    jump_res;
wire [`InstAddrBus]     jump_dst;

wire [`StallBus]        stall_state;
wire                    stall_if;
wire                    stall_id;
wire                    stall_ex;
wire                    stall_mem;

wire [`InstBus]         ram_if_inst;
wire [`RamAddrBus]      ram_if_addr;
wire [`RamAddrBus]      ram_if_pc;
wire                    ram_if_req;
wire                    ram_if_done;

wire [`RamAddrBus]      ram_mem_addr;
wire [`RegBus]          ram_mem_re_data;
wire                    ram_mem_re_req;
wire                    ram_mem_re_done;
wire [`RegBus]          ram_mem_wr_data;
wire                    ram_mem_wr_req;
wire                    ram_mem_wr_done;
wire [`StageBus]        ram_mem_stage;

wire [`InstBus]         inst_if;
wire [`InstBus]         inst_id;

wire [`RegBus]          reg_r1_data;
wire [`RegBus]          reg_r2_data;
wire [`RegBus]          reg_w_data;
wire [`RegAddrBus]      reg_r1_addr;
wire [`RegAddrBus]      reg_r2_addr;
wire [`RegAddrBus]      reg_w_addr;
wire                    reg_r1_enable;
wire                    reg_r2_enable;
wire                    reg_w_enable;

wire                    rd_enable_id;
wire [`RegAddrBus]      rd_addr_id;
wire                    rd_enable_ex_i;
wire [`RegAddrBus]      rd_addr_ex_i;
wire                    rd_enable_ex_o;
wire [`RegAddrBus]      rd_addr_ex_o;
wire [`RegBus]          rd_data_ex;
wire                    rd_enable_mem_i;
wire [`RegAddrBus]      rd_addr_mem_i;
wire [`RegBus]          rd_data_mem_i;
wire                    rd_enable_mem_o;
wire [`RegAddrBus]      rd_addr_mem_o;
wire [`RegBus]          rd_data_mem_o;

wire [`RegBus]          rs1_data_id;
wire [`RegBus]          rs2_data_id;
wire [`RegBus]          offset_id;

wire [`RegBus]          rs1_data_ex;
wire [`RegBus]          rs2_data_ex;
wire [`RegBus]          offset_ex;

wire [`AluOpBus]         aluop_id;
wire [`AluOpBus]         aluop_ex_i;
wire [`AluOpBus]         aluop_ex_o;
wire [`AluOpBus]         aluop_mem;

wire [`AluSelBus]       alusel_id;
wire [`AluSelBus]       alusel_ex;

wire [`RamAddrBus]      ram_addr_ex;
wire [`RegBus]          ram_data_ex;
wire [`RamAddrBus]      ram_addr_mem;
wire [`RegBus]          ram_data_mem;

pc_reg pc_reg0(
      .clk(clk_in),
      .rst(rst),
      .jump_res(jump_res),
      .jump_dst(jump_dst),
      .stall(stall_state),
      .pc(pc)
);

register register0(
      .clk(clk_in),
      .rst(rst),
      .w_enable(reg_w_enable),
      .w_addr(reg_w_addr),
      .w_data(reg_w_data),
      .r1_enable(reg_r1_enable),
      .r1_addr(reg_r1_addr),
      .r1_data(reg_r1_data),
      .r2_enable(reg_r2_enable),
      .r2_addr(reg_r2_addr),
      .r2_data(reg_r2_data)
);

mem_ctrl mem_ctrl0(
      .clk(clk_in),
      .rst(rst),
      .io_buffer_full(io_buffer_full),

      .if_req(ram_if_req),
      .if_addr(ram_if_addr),
      .if_data(ram_if_inst),
      .if_pc(ram_if_pc),
      .if_done(ram_if_done),

      .mem_re_req(ram_mem_re_req),
      .mem_wr_req(ram_mem_wr_req),
      .mem_addr(ram_mem_addr),
      .mem_stage(ram_mem_stage),
      .mem_wr_data(ram_mem_wr_data),
      .mem_wr_done(ram_mem_wr_done),
      .mem_re_data(ram_mem_re_data),
      .mem_re_done(ram_mem_re_done),

      .cpu_din(mem_din),
      .cpu_dout(mem_dout),
      .cpu_a(mem_a),
      .cpu_wr(mem_wr)
);

stall stall0(
      .clk(clk_in),
      .rst(rst),
      .if_stall(stall_if),
      .id_stall(stall_id),
      .ex_stall(stall_ex),
      .mem_stall(stall_mem),

      .stall_state(stall_state)
);

IF if0(
      .clk(clk_in),
      .rst(rst),
      .pc_i(pc),
      .inst_i(ram_if_inst),
      .if_done(ram_if_done),
      .if_pc(ram_if_pc),

      .pc_o(pc_if),
      .inst_o(inst_if),
      .if_req(ram_if_req),
      .if_addr(ram_if_addr),
      .if_stall(stall_if)
);


if_id if_id0(
      .clk(clk_in),
      .rst(rst),
      .if_pc(pc_if),
      .if_inst(inst_if),
      .ex_flag(jump_res),
      .stall(stall_state),
      .id_pc(pc_id_i),
      .id_inst(inst_id)
);

id id0(
      .clk(clk_in),
      .rst(rst),
      
      .pc_i(pc_id_i),
      .inst_i(inst_id),

      .rs1_i(reg_r1_data),
      .rs2_i(reg_r2_data),
      
      .rs1_enable(reg_r1_enable),
      .rs1_addr(reg_r1_addr),
      
      .rs2_enable(reg_r2_enable),
      .rs2_addr(reg_r2_addr),

      .rd_enable(rd_enable_id),
      .rd_addr(rd_addr_id),

      .rs1_data(rs1_data_id),
      .rs2_data(rs2_data_id),
      .offset(offset_id),

      .aluop(aluop_id),
      .alusel(alusel_id),
      .pc_o(pc_id_o),

      .ex_ld(is_ld),
      .ex_rd_enable(rd_enable_ex_o),
      .ex_rd_addr(rd_addr_ex_o),
      .ex_rd_data(rd_data_ex),
      .mem_rd_enable(rd_enable_mem_o),
      .mem_rd_addr(rd_addr_mem_o),
      .mem_rd_data(rd_data_mem_o),

      .id_stall(stall_id)
);

id_ex id_ex0(
      .clk(clk_in),
      .rst(rst),

      .ex_flag(jump_res),
      .stall(stall_state),

      .id_rs1_data(rs1_data_id),
      .id_rs2_data(rs2_data_id),
      .id_rd_addr(rd_addr_id),
      .id_rd_enable(rd_enable_id),
      .id_offset(offset_id),
      .id_aluop(aluop_id),
      .id_alusel(alusel_id),
      .id_pc(pc_id_o),

      .ex_rs1_data(rs1_data_ex),
      .ex_rs2_data(rs2_data_ex),
      .ex_rd_addr(rd_addr_ex_i),
      .ex_rd_enable(rd_enable_ex_i),
      .ex_offset(offset_ex),
      .ex_aluop(aluop_ex_i),
      .ex_alusel(alusel_ex),
      .ex_pc(pc_ex)
);

ex ex0(
      .clk(clk_in),
      .rst(rst),

      .rs1_data(rs1_data_ex),
      .rs2_data(rs2_data_ex),
      .offset(offset_ex),
      .rd_addr_i(rd_addr_ex_i),
      .rd_enable_i(rd_enable_ex_i),
      .aluop_i(aluop_ex_i),
      .alusel(alusel_ex),
      .pc(pc_ex),

      .rd_addr_o(rd_addr_ex_o),
      .rd_enable_o(rd_enable_ex_o),
      .rd_data(rd_data_ex),
      .aluop_o(aluop_ex_o),
      .ram_addr(ram_addr_ex),

      .is_ld(is_ld),

      .jump_res(jump_res),
      .jump_dst(jump_dst)
);

ex_mem ex_mem0(
      .clk(clk_in),
      .rst(rst),

      .ex_rd_addr(rd_addr_ex_o),
      .ex_rd_enable(rd_enable_ex_o),
      .ex_rd_data(rd_data_ex),
      .ex_aluop(aluop_ex_o),
      .ex_ram_addr(ram_addr_ex),

      .stall(stall_state),

      .mem_rd_addr(rd_addr_mem_i),
      .mem_rd_enable(rd_enable_mem_i),
      .mem_rd_data(rd_data_mem_i),
      .mem_aluop(aluop_mem),
      .mem_ram_addr(ram_addr_mem)
);

mem mem0(
      .clk(clk_in),
      .rst(rst),

      .mem_addr_i(ram_addr_mem),
      .rd_data_i(rd_data_mem_i),
      .rd_enable_i(rd_enable_mem_i),
      .rd_addr_i(rd_addr_mem_i),
      .aluop(aluop_mem),

      .re_data(ram_mem_re_data),
      .re_done(ram_mem_re_done),
      .wr_done(ram_mem_wr_done),

      .re_req(ram_mem_re_req),
      .wr_req(ram_mem_wr_req),
      .mem_addr(ram_mem_addr),
      .mem_stage(ram_mem_stage),
      .wr_data(ram_mem_wr_data),

      .rd_data_o(rd_data_mem_o),
      .rd_enable_o(rd_enable_mem_o),
      .rd_addr_o(rd_addr_mem_o),

      .mem_stall(stall_mem)
);

mem_wb mem_wb0(
      .clk(clk_in),
      .rst(rst),
      .mem_rd_data(rd_data_mem_o),
      .mem_rd_addr(rd_addr_mem_o),
      .mem_rd_enable(rd_enable_mem_o),

      .stall(stall_state),

      .wb_rd_data(reg_w_data),
      .wb_rd_addr(reg_w_addr),
      .wb_rd_enable(reg_w_enable)
);

endmodule
/*
//IF/ID -> ID
wire [`AddrLen - 1 : 0] id_pc_i;
wire [`InstLen - 1 : 0] id_inst_i;

//Register -> ID
wire [`RegLen - 1 : 0] reg1_data;
wire [`RegLen - 1 : 0] reg2_data;

//ID -> Register
wire [`RegAddrLen - 1 : 0] reg1_addr;
wire reg1_read_enable;
wire [`RegAddrLen - 1 : 0] reg2_addr;
wire reg2_read_enable;

//ID -> ID/EX
wire [`OpCodeLen - 1 : 0] id_aluop;
wire [`OpSelLen - 1 : 0] id_alusel;
wire [`RegLen - 1 : 0] id_reg1, id_reg2, id_Imm, id_rd;
wire id_rd_enable;

//ID/EX -> EX
wire [`OpCodeLen - 1 : 0] ex_aluop;
wire [`OpSelLen - 1 : 0] ex_alusel;
wire [`RegLen - 1 : 0] ex_reg1, ex_reg2, ex_Imm, ex_rd;
wire ex_rd_enable_i;

//EX -> EX/MEM
wire [`RegLen - 1 : 0] ex_rd_data;
wire [`RegAddrLen - 1 : 0] ex_rd_addr;
wire ex_rd_enable_o;

//EX/MEM -> MEM
wire [`RegLen - 1 : 0] mem_rd_data_i;
wire [`RegAddrLen - 1 : 0] mem_rd_addr_i;
wire mem_rd_enable_i;

//MEM -> MEM/WB
wire [`RegLen - 1 : 0] mem_rd_data_o;
wire [`RegAddrLen - 1 : 0] mem_rd_addr_o;
wire mem_rd_enable_o;

//MEM/WB -> Register
wire write_enable;
wire [`RegAddrLen - 1 : 0] write_addr;
wire [`RegLen - 1 : 0] write_data;

assign rom_addr_o = pc;

//Instantiation
pc_reg pc_reg0(.clk(clk_in), .rst(rst_in), .pc(pc), .chip_enable(rom_ce_o));

if_id if_id0(.clk(clk_in), .rst(rst_in), .if_pc(pc), .if_inst(rom_data_i), .id_pc(id_pc_i), .id_inst(id_inst_i));

id id0(.rst(rst_in), .pc(id_pc_i), .inst(id_inst_i), .reg1_data_i(reg1_data), .reg2_data_i(reg2_data), 
      .reg1_addr_o(reg1_addr), .reg1_read_enable(reg1_read_enable), .reg2_addr_o(reg2_addr), .reg2_read_enable(reg2_read_enable),
      .reg1(id_reg1), .reg2(id_reg2), .Imm(id_Imm), .rd(id_rd), .rd_enable(id_rd_enable), .aluop(id_aluop), .alusel(id_alusel));
      
register register0(.clk(clk_in), .rst(rst_in), 
                  .write_enable(write_enable), .write_addr(write_addr), .write_data(write_data),
                  .read_enable1(reg1_read_enable), .read_addr1(reg1_addr), .read_data1(reg1_data),
                  .read_enable2(reg2_read_enable), .read_addr2(reg2_addr), .read_data2(reg2_data));
id_ex id_ex0(.clk(clk_in), .rst(rst_in),
            .id_reg1(id_reg1), .id_reg2(id_reg2), .id_Imm(id_Imm), .id_rd(id_rd), .id_rd_enable(id_rd_enable), .id_aluop(id_aluop), .id_alusel(id_alusel),
            .ex_reg1(ex_reg1), .ex_reg2(ex_reg2), .ex_Imm(ex_Imm), .ex_rd(ex_rd), .ex_rd_enable(ex_rd_enable_i), .ex_aluop(ex_aluop), .ex_alusel(ex_alusel));

ex ex0(.rst(rst_in),
      .reg1(ex_reg1), .reg2(ex_reg2), .Imm(ex_Imm), .rd(ex_rd), .rd_enable(ex_rd_enable_i), .aluop(ex_aluop), .alusel(ex_alusel),
      .rd_data_o(ex_rd_data), .rd_addr(ex_rd_addr), .rd_enable_o(ex_rd_enable_o));
      
ex_mem ex_mem0(.clk(clk_in), .rst(rst_in),
              .ex_rd_data(ex_rd_data), .ex_rd_addr(ex_rd_addr), .ex_rd_enable(ex_rd_enable_o),
              .mem_rd_data(mem_rd_data_i), .mem_rd_addr(mem_rd_addr_i), .mem_rd_enable(mem_rd_enable_i));
              
mem mem0(.rst(rst_in),
        .rd_data_i(mem_rd_data_i), .rd_addr_i(mem_rd_addr_i), .rd_enable_i(mem_rd_enable_i),
        .rd_data_o(mem_rd_data_o), .rd_addr_o(mem_rd_addr_o), .rd_enable_o(mem_rd_enable_o));
        
mem_wb mem_wb0(.clk(clk_in), .rst(rst_in),
              .mem_rd_data(mem_rd_data_o), .mem_rd_addr(mem_rd_addr_o), .mem_rd_enable(mem_rd_enable_o),
              .wb_rd_data(write_data), .wb_rd_addr(write_addr), .wb_rd_enable(write_enable));

endmodule

*/