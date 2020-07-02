module ex_mem(
    input wire clk,
    input wire rst,

    input wire[`RegAddrBus] ex_wd,
    input wire              ex_wreg,
    input wire[`RegBus]     ex_wdata,
    
    input wire[5:0] stall,
    input wire flush,

    // input for load/store
    input wire[`AluOpBus] ex_aluop,

    // output for load/store
    output reg[`AluOpBus]   mem_aluop,
    
    output reg[`RegAddrBus] mem_wd,
    output reg              mem_wreg,
    output reg[`RegBus]     mem_wdata

);

always @ (posedge clk or negedge rst_n) begin
    if(rst == `RstEnable) begin
        mem_wd <= `NOPRegAddr;
        mem_wreg <= `WriteDisable;
        mem_wdata <= `ZeroWord;

        mem_aluop <= `EXE_NON_OP;

    end
    else if(flush == 1'b1) begin
        mem_wd <= `NOPRegAddr;
        mem_wreg <= `WriteDisable;
        mem_wdata <= `ZeroWord;

        mem_aluop <= `EXE_NON_OP;

    end        
    else if(stall[3] == `STOP && stall[4] == `NOSTOP) begin
        mem_wd <= `NOPRegAddr;
        mem_wreg <= `WriteDisable;
        mem_wdata <= `ZeroWord;

        mem_aluop <= `EXE_NON_OP;

    end
    else if(stall[3] == NOSTOP) begin
        mem_wd <= ex_wd;
        mem_wreg <= ex_wreg;
        mem_wdata <= ex_wdata;

        mem_aluop <= ex_aluop;

    end   
    else begin
        mem_wd <= mem_wd;
        mem_wreg <= mem_wreg;
        mem_wdata <= mem_wdata;

        mem_aluop <= mem_aluop;  
    end      

end

endmodule