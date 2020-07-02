module if_id(
    input wire clk,
    input wire rst_n,

    input wire[5:0] stall,
    input wire flush,

    input wire[`InstAddrBus] if_pc,
    input wire[`InstBus]     if_inst,
    input wire if_pc_invalid,

    output reg[`InstAddrBus] id_pc,
    output reg[`InstBus]     id_inst,
    output reg id_pc_invalid

);

always @ (posedge clk or negedge rst_n) begin
    if(rst_n == `RstEnable) begin
        id_pc   <= `ZeroWord;     ///< pc = 0 under reset
        id_inst <= `ZeroWord;     ///< inst = 0 under reset
        id_pc_invalid <= `PCValid;
    end
    else if(flush == 1'b1) begin
        id_pc <= `ZeroWord;
        id_inst <= `ZeroWord;
        id_pc_invalid <= `PCValid;
    end
    else if(stall[1] == `STOP && stall[2] == `NOSTOP) begin
        id_pc <= `ZeroWord;
        id_inst <= `ZeroWord;
        id_pc_invalid <= if_pc_invalid;
    end
    else if(stall[1] == `NOSTOP)
        id_pc <= if_pc;
        id_inst <= if_inst;
        id_pc_invalid <= if_pc_invalid;
    end
    else begin
        id_pc <= id_pc;
        id_inst <= id_inst;
        id_pc_invalid <= id_pc_invalid;
end

endmodule

