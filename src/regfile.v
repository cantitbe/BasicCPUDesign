//*******  32 * 32 bit integer registers 
//*******  with 2-read & 1-write simutaneous access 

module regfile(
    input wire clk,
    input wire rst,

    input wire we,
    input wire[`RegAddrBus] waddr,
    input wire[`RegBus]     wdata,

    input wire re1,
    input wire[`RegaddrBus] raddr1,
    output reg[`RegBus]     rdata1,

    input wire re2,
    input wire[`RegaddrBus] raddr2,
    output reg[`RegBus]     rdata2, 

);


//****************8  32 x 32 bit register*****************

reg[`RegBus] regs[0:`RegNum-1];

//*************** write *********************************

always @ (posedge clk) begin
    if(rst == `RstDiable) begin
        if((we == `WriteEnable) && (waddr != `RegNumLog2'h0)) begin
            regs[waddr] <= wdata;
        end
    end
end

//*************** read ************************************
always @ (*) begin

    if(rst == `RstEnable) begin
        rdata1 <= `ZeroWord;
    end else if(raddr1 == `RegNumLog2'h0) begin
        rdata1 <= `ZeroWord;
    end 
    else if(((raddr1 == waddr) && (we == `WriteEnable))
                && (re1 == `ReadEnable)) begin
                rdata1 <= wdata;    
            end 
            else if(re1 == `ReadEnable) begin
                    rdata1 <= regs[raddr1];
            end else begin
                rdata1 <= `ZeroWord;
            end
end

always @ (*) begin

    if(rst == `RstEnable) begin
        rdata2 <= `ZeroWord;
    end else if(raddr2 == `RegNumLog2'h0) begin
        rdata2 <= `ZeroWord;
    end 
    else if(((raddr2 == waddr) && (we == `WriteEnable))
                && (re2 == `ReadEnable)) begin
                rdata2 <= wdata;    
            end 
            else if(re2 == `ReadEnable) begin
                    rdata2 <= regs[raddr2];
            end else begin
                rdata2 <= `ZeroWord;
            end
end

endmodule