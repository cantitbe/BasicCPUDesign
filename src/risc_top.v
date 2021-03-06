module riscv_cpu(
    input wire clk,
    input wire rst,

    input wire[`RegBus]  rom_data_i,
    output wire[`RegBus] rom_addr_o,

    output wire rom_ce_o
);


// from if/id to id
wire[`InstAddrBus] pc;
wire[`InstAddrBus] id_pc_i;
wire[`InstBus] id_inst_i;

// from id to id/ex
wire[`AluOpBus] id_aluop_o;
wire[`AluSelBus] id_alusel_o;
wire[`RegBus] id_reg1_o;
wire[`RegBus] id_reg2_o;
wire id_wreg_o;
wire[`RegAddrBus] id_wd_o;

// id for branch inst
wire id_branch_flag_o;
wire[`RegBus] id_branch_target_address_o;
wire[`RegBus] id_link_addr_o;

// from id/ex to ex
wire[`AluOpBus] ex_aluop_i;
wire[`AluSelBus] ex_alusel_i;
wire[`RegBus] ex_reg1_i;
wire[`RegBus] ex_reg2_i;
wire ex_wreg_i;
wire[`RegAddrBus] ex_wd_i;
wire[`RegBus] ex_link_address_i;

// from ex to ex/mem
wire ex_wreg_o;
wire[`RegAddrBus] ex_wd_o;
wire[`RegBus] ex_wdata_o;

// from ex/mem to mem
wire mem_wreg_i;
wire[`RegAddrBus] mem_wd_i;
wire[`RegBus] mem_wdata_i;

// from mem to mem/wb
wire mem_wreg_o;
wire[`RegAddrBus] mem_wd_o;
wire[`RegBus] mem_wdata_o;

// mem/wb
wire wb_wreg_i;
wire[`RegAddrBus] wb_wd_i;
wire[`RegBus] wb_wdata_i;

// id to regfile
wire reg1_read;
wire reg2_read;

wire[`RegBus] reg1_data;
wire[`RegBus] reg2_data;

wire[`RegAddrBus] reg1_addr;
wire[`RegAddrBus] reg2_addr;

// pc_reg instance
pc_reg pc_reg0(
    .clk(clk), .rst(rst), 
    .id_link_addr(id_link_addr_o),
    .branch_flag_i(id_branch_flag_o), 
    .branch_target_address_i(id_branch_target_address_o),
    .pc(pc), .ce(rom_ce_o)
);

assign rom_addr_o = pc;  // inst addr = pc

// if/id
if_id if_id0(
    .clk(clk), .rst(rst), .if_pc(pc),
    .if_inst(rom_data_i), .id_pc(id_pc_i),
    .id_inst(id_inst_i)
);

// id
id id0(
    .rst(rst), .pc_i(id_pc_i), .inst_i(id_inst_i),

    //< from regfile
    .reg1_data_i(reg1_data), .reg1_data_i(reg2_data),

    //< to regfile
    .reg1_read_o(reg1_read), .reg2_read_o(reg2_read),
    .reg1_addr_o(reg1_addr), .reg2_addr_o(reg2_addr),

    // from ex
    .ex_wreg_i(ex_wreg_o), .ex_wdata_i(ex_wdata_o), 
    .ex_wd_i(ex_wd_o),

    // from mem
    .mem_wreg_i(mem_wreg_o), .mem_wdata_i(mem_wdata_o),
    .mem_wd_i(mem_wd_o),

    //< to id/ex
    .aluop_o(id_aluop_o), .alusel_o(id_alusel_o),
    .reg1_o(id_reg1_o), .reg2_o(id_reg2_o),
    .wd_o(id_wd_o), ..wreg_o(id_wreg_o)

    // for branch inst
    .branch_flag_o(branch_flag_o),
    .branch_target_address_o(branch_target_address_o),
    .link_addr_o(link_addr_o)
);

regfile regfile1(
    .clk(clk), .rst(rst),
    .we(wb_wreg_i), .waddr(wb_wd_i),
    .wdata(wb_wdata_i), .re1(reg1_read),
    .raddr1(reg1_addr, .rdata1(reg1_data),
    .re2(reg2_read), .raddr2(reg2_addr),
    .rdata2(reg2_data)
);

id_ex id_ex0(
    .clk(clk), .rst(rst),

    //< from id
    .id_aluop(id_aluop_o), .id_alusel(id_aluop_o),
    .id_reg1(id_reg1_o), .id_reg2(id_reg2_o),
    .id_wd(id_wd_o), .id_wreg(id_wreg_o),

    // from id for branch inst
    .id_link_address(id_link_addr_o),
    
    // to ex for brach inst
    .ex_link_address(ex_link_address_i),

    //< to ex
    .ex_aluop(ex_aluop_i), .ex_alusel(ex_alusel_i),
    .ex_reg1(ex_reg1_i), .ex_reg(ex_reg2_i),
    .ex_wd(ex_wd_i), .ex_wreg(ex_wreg_i)
);

ex ex0(
    .rst(rst),

    // from id/ex
    .aluop_i(ex_aluop_i), .alusel_i(ex_alusel_i),
    .reg1_i(ex_reg1_i), .reg2_i(ex_reg2_i),
    .wd_i(ex_wd_i), .wreg_i(ex_wreg_i),

    // to ex/mem
    .wd_o(ex_wd_o), .wreg_o(ex_wreg_o),
    .wdata_o(ex_wdata_o)

);

ex_mem ex_mem0(
    .clk(clk), .rst(rst),

    // ex
    .ex_wd(ex_wd_o), .ex_wreg(ex_wreg_o),
    .ex_wdata(ex_wdata_o),

    // to mem
    .mem_wd(mem_wd_i), .mem_wreg(mem_wreg_i),
    .mem_wdata(mem_wdata_i)
);

mem mem0(
    .rst(rst),

    // from ex/mem
    .wd_i(mem_wd_i), .wreg_i(mem_wreg_i),
    .wdata_i(mem_wdata_i),

    // to mem/wb & id
    .wd_o(mem_wd_o), .wreg_o(mem_wreg_o),
    .wdata_o(mem_wdata_o)

);

mem_wb mem_wb0
(
    .clk(clk), .rst(rst),

    //< from mem
    .mem_wr(mem_wd_o), .mem_wreg(mem_wreg_o),
    .mem_wdata(mem_wdata_o),

    //< to wb
    .wb_wd(wb_wd_i), .wb_wreg(wb_wreg_i),
    .wb_wdata(wb_wdata_i)  
);

ctrl ctrl0
(
    .rst(rst),


)