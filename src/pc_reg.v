//* IF unit with pc_reg implementation

module pc_reg(
    input wire clk,
    input wire rst_n,

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
    output reg pc_invalid,
    output reg if_start
);

assign we = 1'b0;
assign data = `ZeroWord;

reg start_pulse_d1;
reg start_pulse_d2;

always @ (posedge clk or negedge rst_n) begin
    if(rst_n == `RstEnable) begin
        start_pulse_d1 <= 1'b0;
        start_pulse_d2 <= 1'b0;
    end
    else begin
        start_pulse_d1 <= start_pulse;
        start_pulse_d2 <= start_pulse_d1;
    end
end

//< sync to the same clk domain
always @ (*) begin
    if_start <= start_pulse_d1 & (~start_pulse_d2);    
end

always @ (posedge if_start or negedge rst_n) begin
    if(rst_n == `RstEnable) begin
        ce <= `ChipDisable;
    end 
    else begin
        ce <= `ChipEnable;
    end
end

always @ (posedge clk) begin
    if(ce == `ChipDisable) begin
        pc <= 32'h00000000;
    end 
    else if(flush) begin
        pc <= `ZeroWord;
    end
    else if(stall[0] == `STOP) begin
        pc <= pc;
    end
    else if(if_start) begin
        pc <= start_pc;
    end
    else if(branch_flag_i == `Branch) begin
        pc <= branch_target_address_i;
    end
    else begin
        pc <= pc + 4'h4;
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

