module ex(
    input wire rst,

    input wire[`InstAddrBus] pc_i,

    //< id to ex signal
    input wire[`AluOpBus]   aluop_i,
    input wire[`RegBus]     reg1_i,
    input wire[`RegBus]     reg2_i,
    input wire[`RegBus]     imm_i,
    input wire[`RegAddrBus] wd_i,
    input wire              wreg_i,

    input wire[`RegBus] inst_i,         ///< current inst, not used 

    output reg[`RegAddrBus] wd_o,
    output reg              wreg_o,
    output reg[`RegBus]     wdata_o,

    output wire[`AluOpBus] aluop_o,

    // branch 
    output reg branch_flag_o,
    output reg[`RegBus] branch_target_address_o,

    output reg[`InstAddrBus] mem_addr_o,
    output reg mem_ce_o,
    output reg mem_we_o,
    output reg[`InstBus] mem_data_o

);

wire[`RegBus] pc_plus_4;
wire[`RegBus] target;

assign pc_plus_4 = pc_i + 4;

wire[`RegBus] result_sum;

assign aluop_o = aluop_i;

assign result_sum = reg1_i + reg2_i;


always @ (*) begin
    if(rst_n == `RstEnable) begin
        aluop_o  <= `EXE_NOP_OP;

        wd_o     <= `NOPRegAddr;
        wreg_o   <= `WriteDisable;
        wdata_o <= `ZeroWord;

        branch_flag_o <= `NotBranch;
        branch_target_address_o <= `ZeroWord;

        mem_addr_o <= `ZeroWord;
        mem_we <= `WriteDisable;
        mem_data_o <= `ZeroWord;
        mem_ce_o <= `ChipDisable;

    end
    else begin

        wdata_o <= `ZeroWord;
        wd_o <= `WriteDisable;
        wreg_o <= `NOPRegAddr;

        branch_flag_o <= `NotBranch;
        branch_target_address_o <= `ZeroWord;   

        mem_addr_o <= `ZeroWord;
        mem_we <= `WriteDisable;
        mem_data_o <= `ZeroWord;
        mem_ce_o <= `ChipDisable;

        case(aluop_i)

        `EXE_ADD_OP: begin
            wdata_o <= result_sum;
            wd_o <= wd_i;
            wreg_o <= wreg_i;
        end

        `EXE_LUI_OP: begin
            wdata_o <= imm_i;
            wd_o <= wd_i;
            wreg_o <= wreg_i;
        end
        
        `EXE_JAL_OP: begin

            wdata_o <= pc_plus_4;
            wd_o <= wd_i;
            wreg_o <= wreg_i;
            
            branch_flag_o <= `Branch;
            branch_target_address_o <= pc_i + imm_i;
        end

        `EXE_BEQ_OP: begin
            if(reg1_i == reg2_i) begin
                branch_target_address_o <= pc_i + imm_i;
                branch_flag_o <= `Branch;
            end  
        end

        `EXE_LW_OP: begin
           
            wd_o <= wd_i;
            wreg_o <= wreg_i;

            mem_addr_o <= reg1_i + imm;
            mem_we <= `WriteDisable;
            mem_data_o <= `ZeroWord;
            mem_ce_o <= `ChipEnable;
        end

        `EXE_SW_OP: begin
            mem_addr_o <= reg1_i + imm;
            mem_we <= `WriteEnable;
            mem_data_o <= reg2_i;
            mem_ce_o <= `ChipEnable;

        end

        default: begin
        end
        endcase
    end
end

endmodule
