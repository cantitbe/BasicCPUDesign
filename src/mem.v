module mem(

    input wire rst,

    input wire[`RegaddrBus] wd_i,
    input wire wreg_i,
    input wire[`RegBus] wdata_i,

    // for load/store
    input wire[`AluOpBus] aluop_i,

    ///< data from ram
    input wire[`RegBus]   mem_data_i,

    ///< to mem/wb
    output reg[`RegAddrBus] wd_o,
    output reg wreg_o,
    output reg[`RegBus] wdata_o

);


always @ (*) begin
    if(rst == `RstEnable) begin
        wd_o <= `NOPRegAddr;
        wreg_o <= `WriteDisable;
        wdata_o <= `ZeroWord;
    end
    else begin
        wd_o <= wd_i;
        wreg_o <= wreg_i;
        wdata_o <= wdata_i;
        
        if(aluop_i == `EXE_LW_OP) begin
            wdata_o <= mem_data_i;
        end
    end
end

endmodule