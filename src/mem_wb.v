module mem_wb(
    input wire clk,
    input wire rst,

    input wire[`RegAddrBus] mem_wd,
    input wire mem_wreg,
    input wire[`RegBus] mem_wdata,

    input wire[5:0] stall,
    input wire flush,

    output wire[`RegAddrBus] wb_wd,
    output wire wb_wreg,
    output wire[`RegBus] wb_wdata
);

always @ (posedge clk) begin
    if(rst == `RstEnable) begin
        wb_wd <= `NOPRegAddr;
        wb_wreg <= `WriteDisable;
        wb_wdata <= `ZeroWord;
    end
    else if(flush == 1'b1) begin
        wb_wd <= `NOPRegAddr;
        wb_wreg <= `WriteDisable;
        wb_wdata <= `ZeroWord;
    end        
    else if(stall[4] == `STOP && stall[5] == `NOSTOP) begin 
        wb_wd <= `NOPRegAddr;
        wb_wreg <= `WriteDisable;
        wb_wdata <= `ZeroWord;
    end
    else if(stall[4] == `NOSTOP) begin
        wb_wd <= mem_wd;
        wb_wreg <= mem_wreg;
        wb_wdata <= mem_wdata;
    end
end

endmodule
