module if_id(
    input wire clk,
    input wire rst,

    input wire[5:0] stall,

    input wire[`InstAddrBus] if_pc,
    input wire[`InstBus]     if_inst,

    output reg[`InstAddrBus] id_pc,
    output reg[`InstBus]     id_inst

);

always @ (posedge clk) begin
    if(rst == `RstEnable) begin
        id_pc   <= `ZeroWord;     ///< pc = 0 under reset
        id_inst <= `ZeroWord;     ///< inst = 0 under reset
    end
    else if(stall[1] == `STOP && stall[2] == NOSTOP) begin
        id_pc <= `ZeroWord;
        id_inst <= `ZeroWord;
    end
    else if(stall[1] == `NOSTOP)
        id_pc <= if_pc;
        id_inst <= if_inst;
    end
end

endmodule

