//* IF unit with pc_reg implementation

module pc_reg(
    input wire clk,
    input wire rst,

    input wire start_pulse,
    input wire[`InstAddrBus] start_pc,

    input wire[5:0] stall,  
    input wire flush, 

    input wire branch_flag_i,
    input wire[`RegBus] branch_target_address_i,

    output reg[`InstAddrBus] pc,
    output reg ce,
    output reg we,
    output reg[`InstAddrBus] data,

    // exception
    output reg pc_invalid
);

assign we = 1'b0;
assign data = `ZeroWord;

reg if_start;

always @ (posedge clk) begin
    if(rst == `RstEnable) begin
        ce <= `ChipDisable;
    end 
    else begin
        ce <= `ChipEnable;
    end
end

always @ (posedge clk) begin
    if(ce == `ChipDisable) begin
        pc <= 32'h00000000;
    end else begin
        if_start <= start_pulse;

        if(flush == 1'b1) begin
            pc <= `ZeroWord;
        end
        ///< need to do async op
        else if(start_pulse == 1'b1 && if_start == 1'b0) begin
            pc <= start_pc;
        end
        else if(stall[0] == `NOSTOP) begin
            if(branch_flag_i == `Branch) begin
                pc <= branch_target_address_i;
            end
            else begin
                pc <= pc + 4'h4;
            end
        end
    end
end

always @ (*) begin
    if(pc[1:0] == 2'b00) begin
        pc_invalid <= 1'b0;
    end
    else begin
        pc_invalid <= 1'b1;
    end
end

endmodule

