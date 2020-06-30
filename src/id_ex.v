module id_ex(
    input wire clk,
    input wire rst,

    input wire[`AluOpBus] id_aluop,
    input wire[`InstAddrBus] id_pc,

    input wire[`RegBus]  id_reg1,
    input wire[`RegBus]  id_reg2,
    input wire[`RegBus]  id_imm,
    input wire[`RegAddrBus] id_wd,
    input wire           id_wreg,

    input wire[5:0] stall,
    input wire flush,
    
    // load/store
    input wire[`RegBus] id_inst,

    output reg[`RegBus] ex_inst,
       
    // to exe unit
    output reg[`AluOpBus] ex_aluop,
    output wire[`InstAddrBus] ex_pc,


    output reg[`RegBus] ex_reg1,
    output reg[`RegBus] ex_reg2,
    output wire[`RegBus]  ex_imm,
    output reg[`RegAddrBus] ex_wd,
    output reg ex_wreg

);

always @ (posedge clk) begin
    if(rst == `RstEnable) begin
        ex_aluop <= `EXE_NOP_OP;
        //ex_alusel <= `EXE_RES_NOP;
        ex_reg1 <= `ZeroWord;
        ex_reg2 <= `ZeroWord;
        ex_imm <= `ZeroWord;

        ex_wd <= `NOPRegAddr;
        ex_wreg <= `WriteDisable;

        ex_pc <= `ZeroWord;
        ex_inst <= `ZeroWord;
        //ex_link_address <= `ZeroWord;

    end
    else if(flush == 1'b1) begin
        ex_aluop <= `EXE_NOP_OP;
        //ex_alusel <= `EXE_RES_NOP;
        ex_reg1 <= `ZeroWord;
        ex_reg2 <= `ZeroWord;
        ex_imm <= `ZeroWord;

        ex_wd <= `NOPRegAddr;
        ex_wreg <= `WriteDisable;

        ex_pc <= `ZeroWord;
        ex_inst <= `ZeroWord;   

    end     
    else if(stall[2] == `STOP && stall[3] == `NOSTOP) begin
        ex_aluop <= `EXE_NOP_OP;
        //ex_alusel <= `EXE_RES_NOP;
        ex_reg1 <= `ZeroWord;
        ex_reg2 <= `ZeroWord;
        ex_imm <= `ZeroWord;

        ex_wd <= `NOPRegAddr;
        ex_wreg <= `WriteDisable;
        ex_pc <= `ZeroWord;
        ex_inst <= `ZeroWord;
        //ex_link_address <= `ZeroWord;
    end
    else if(stall[2] == `NOSTOP) begin

        ex_aluop <= id_aluop;
        //ex_alusel <= id_alusel;
        ex_reg1 <= id_reg1;
        ex_reg2 <= id_reg2;
        ex_imm <= id_imm;

        ex_wd <= id_wd;
        ex_wreg <= id_wreg;
        //ex_link_address <= id_link_address;

        ex_inst <= id_inst;
        ex_pc <= id_pc;
    end   
end

endmodule