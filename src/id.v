module id(

    input wire rst,
    input wire[`InstAddrBus] pc_i,
    input wire[`InstBus]  inst_i,

    //< read regfile
    input wire[`RegBus] reg1_data_i,
    input wire[`RegBus] reg2_data_i,

    //< write regfile
    output reg reg1_read_o,
    output reg reg2_read_o,
    output reg[`RegAddrBus] reg1_addr_o,
    output reg[`RegAddrBus] reg2_addr_o,

    ///< output to ex unit
    output reg[`AluOpBus] aluop_o,
    output reg[`AluSelBus] alusel_o,

    ///< solve data dependency 
    input wire ex_wreg_i,
    input wire[`RegBus] ex_wdata_i
    input wire[`RegAddrBus] ex_wd_i,

    input wire mem_wreg_i,
    input wire[`RegBus] mem_wdata_i,
    input wire[`RegAddrBus] mem_wd_i,

    ///< reg to ex 
    output reg[`RegBus] reg1_o,
    output reg[`RegBus] reg2_o,

    ///< write to regfile
    output reg[`RegAddrBus] wd_o,
    output reg wreg_o

    // branch 
    output reg branch_flag_o,
    output reg[`RegBus] branch_target_address_o,
    output reg[`RegBus] link_addr_o

);

wire[5:0] op  = inst_i[31:26];
wire[4:0] op2 = inst_i[10:6];
wire[5:0] op3 = inst_i[5:0];
wire[4:0] op4 = inst_i[20:16];

// store the imm value
wire[`RegBus] pc_plus_8;
wire[`RegBus] pc_plus_4;

wire[`RegBus] imm_sll2_signedext;

reg[`RegBus] imm;

reg instvalid;

assign pc_plus_8 = pc_i + 8;
assign pc_plus_4 = pc_i + 4;
assign imm_sll2_signedext = {{14{inst_i[15]}}, inst_i[15:0], 2'b00};

always @ (*) begin
    if(rst == `RstEnable) begin
        aluop_o  <= `EXE_NOP_OP;
        alusel_o <= `EXE_RES_NOP;
        wd_o     <= `NOPRegAddr;
        wreg_o   <= `WriteDisable;

        instvalid <= `InstValid;
        reg1_read_o <= 1'b0;
        reg2_read_o <= 1'b0;
        reg1_addr_o <= `NOPRegAddr;
        reg1_addr_o <= `NOPRegAddr;

        imm <= `ZeroWord;

        link_addr_o <= `ZeroWord;
        branch_flag_o <= `NotBranch;
        branch_target_address_o <= `ZeroWord;
        
    end

    else begin
        aluop_o  <= `EXE_NOP_OP;
        alusel_o <= `EXE_RES_NOP;
        wd_o     <= inst_i[15:11];
        wreg_o   <= `WriteDisable;

        instvalid <= `InstValid;
        reg1_read_o <= 1'b0;
        reg2_read_o <= 1'b0;
        reg1_addr_o <= inst_i[25:21];
        reg1_addr_o <= inst_i[20:16];

        imm <= `ZeroWord;

        link_addr_o <= `ZeroWord;
        branch_flag_o <= `NotBranch;
        branch_target_address_o <= `ZeroWord;


    case(op)
    `EXE_SPECIAL_INST: begin
        case(op2)
        5'b00000: begin
            case(op3)
            `EXE_ADD: begin
                wreg_o <= `WriteEnable;

                aluop_o <= `EXE_ADD_OP;
                alusel_o <= `EXE_RES_ARITHMETIC;
                
                reg1_read_o <= 1'b1;
                reg2_read_o <= 1'b1;

                instvalid <= `InstValid;

            default: begin
                
            end
            endcase

        default: begin
        end
        endcase

        `EXE_JAL: begin
            wreg_o <= `WriteEnable   
            aluop_o <= `EXE_JAL_OP;
            alusel_o <= `EXE_RES_JUMP_BRANCH;

            reg1_read_o <= 1'b0;
            reg2_read_o <= 1'b0;
            wd_0 <= 5'b11111;
            
            link_addr_o <= pc_plus_8;
            branch_flag_o <= `Branch;
            branch_target_address_o <= {pc_plus_4[31:28], 
            inst[25:0], 2'b00};

            instvalid <= `InstValid;           
        end

        `EXE_ORI: begin
            wreg_o <= `WriteEnable   
            aluop_o <= `EXE_OR_OP;
            alusel_o <= `EXE_RES_LOGIC;

            reg1_read_o <= 1'b1;
            reg2_read_o <= 1'b0;

            imm <= {16'h0, inst_i[15:0]};
            wd_o <= inst_i[20:16];
            instvalid <= `InstValid;
        end
        `EXE_LUI: begin
            reg_o <= `WriteEnable;
            aluop_o <= `EXE_OR_OP;
            alusel_o <= `EXE_RES_LOGIC;
            
            reg1_read_o <= 1'b1;
            reg2_read_o <= 1'b0;

            imm <= {inst_i[15:0], 16'h0};
            wd_o <= inst_i[20:16];
            instvalid <= `InstValid;
        end

        default: begin
            
        end

    endcase
    
    end  // else
end

always @ (*) begin
    if(rst == `RstEnable) begin
        reg1_o <= `ZeroWord
    end
    //< remove data dependency stall cycles from MEM
    else if((reg_read_o == 1'b1) && (mem_wreg_i == 1'b1)
            && (mem_wd_i == reg1_addr_o)) begin
            reg1_o <= mem_wdata_i;
    end
    else if((reg_read_o == 1'b1) && (ex_wreg_i == 1'b1)
            && (ex_wd_i == reg1_addr_o)) begin
            reg1_o <= ex_wdata_i;
    end
    else if(reg1_read_o == 1'b1) begin
        reg1_o <= reg1_data_i;
    end
    else if(reg1_read_o == 1'b0) begin
        reg1_o <= imm;
    end
    else begin 
        reg1_o <= `ZeroWord;
    end
end

always @ (*) begin
    if(rst == `RstEnable) begin
        reg2_o <= `ZeroWord
    end 
    //< remove data dependency stall cycles from MEM
    else if((reg_read_o == 1'b1) && (mem_wreg_i == 1'b1)
            && (mem_wd_i == reg2_addr_o)) begin
            reg2_o <= mem_wdata_i;
    end
    else if((reg_read_o == 1'b1) && (ex_wreg_i == 1'b1)
            && (ex_wd_i == reg2_addr_o)) begin
            reg2_o <= ex_wdata_i;
    end
    else if(reg2_read_o == 1'b1) begin
        reg2_o <= reg2_data_i;
    end
    else if(reg2_read_o == 1'b0) begin
        reg2_o <= imm;
    end
    else begin 
        reg2_o <= `ZeroWord;
    end
end


    

endmodule
