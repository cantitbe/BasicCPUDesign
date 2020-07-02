module ctrl
(
    input wire rst,

    input wire[2] core_configuration,
    output wire[2] core_status,
    output wire[2] core_exception,
    output wire[2] core_exception_pc,

    // input wire stallreq_from_id,
    // input wire stallreq_from_ex,
    input wire start_pc,

    input wire pc_invalid,
    input wire inst_invalid,
    input wire is_wfi,
    input wire is_loadrelated,

    output reg[5:0] stall,
    output reg flush

);

reg pc_unalign_exception;
reg illegal_instruction_exception;

always @ (*) begin
    if(rst == `RstEnable) begin
        pc_unalign_exception <= 1'0;
        illegal_instruction_exception <= 1'0;
    end
    else begin
        pc_unalign_exception <= ~core_configuration[0] & pc_invalid;
        illegal_instruction_exception <= ~core_configuration[1] & inst_invalid;
    end
end


always @ (*) begin
    if(rst == `RstEnable) begin
        stall <= 6'b000000;
    end

    else if(illegal_instruction_exception | 
            is_wfi | is_loadrelated == 1'b1) begin
        stall <= 6'b000111;
    end   
    else if(pc_unalign_exception == 1'b1) begin
        stall <= 6'b001111
    end

    else begin 
        stall <= 6'b000000;
    end
end

endmodule