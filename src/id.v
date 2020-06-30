module id(

    input wire rst,
    input wire[`InstAddrBus] pc_i,
    input wire[`InstBus]  inst_i,

    input wire pc_invalid_i,
    //< solve lw data dependency stall
    input wire[`AluOpBus] ex_aluop_i,

    //< read regfile
    input wire[`RegBus] reg1_data_i,
    input wire[`RegBus] reg2_data_i,

    //< write regfile
    output reg reg1_read_o,
    output reg reg2_read_o,
    output reg[`RegAddrBus] reg1_addr_o,
    output reg[`RegAddrBus] reg2_addr_o,

    ///< solve data dependency 
    input wire ex_wreg_i,
    input wire[`RegBus] ex_wdata_i
    input wire[`RegAddrBus] ex_wd_i,

    input wire mem_wreg_i,
    input wire[`RegBus] mem_wdata_i,
    input wire[`RegAddrBus] mem_wd_i,

    output reg stallreq,
    
    ///<  to ex 
    output reg[`RegAddrBus] wd_o,
    output reg wreg_o,
    output reg[`RegBus] imm,
    output reg[`RegBus] reg1_o,
    output reg[`RegBus] reg2_o,
    
    ///< output to ex unit
    output reg[`AluOpBus] aluop_o,
    ///< pc
    output reg[`InstAddrBus] pc_o,
    ///< lw/sw
    output reg[`InstBus] inst_o,

    ///< to ctrl unit
    output reg pc_invalid_o,
    output reg inst_invalid_o,
    output reg is_wfi_o;

);

assign inst_o = inst_i;

reg stallreq_for_reg1_loadrelated;
reg stallreq_for_reg2_loadrelated;
wire pre_inst_is_load;

assign pre_inst_is_load = ex_aluop_i == `EXE_LW_OP;

wire[6:0] op  = inst_i[6:0];
wire[2:0] op2 = inst_i[14:12];
wire[6:0] op3 = inst_i[31:25];

// store the imm value
wire[`RegBus] pc_plus_4;

reg[`RegBus] imm;
reg instvalid;

assign pc_plus_4 = pc_i + 4;

always @ (*) begin
    if(rst == `RstEnable) begin
        aluop_o  <= `EXE_NOP_OP;
        //alusel_o <= `EXE_RES_NOP;
        wd_o     <= `NOPRegAddr;
        wreg_o   <= `WriteDisable;

        instvalid <= `InstValid;
        reg1_read_o <= 1'b0;
        reg2_read_o <= 1'b0;
        reg1_addr_o <= `NOPRegAddr;
        reg1_addr_o <= `NOPRegAddr;

        imm <= `ZeroWord;
        
    end

    else begin
        aluop_o  <= `EXE_NOP_OP;
        alusel_o <= `EXE_RES_NOP;
        
        wd_o     <= inst_i[11:7];
        wreg_o   <= `WriteDisable;

        instvalid <= `InstValid;
        reg1_read_o <= `RaadDisable;
        reg2_read_o <= `ReadDsiable;
        reg1_addr_o <= inst_i[19:15];
        reg2_addr_o <= inst_i[24:20];

        imm <= `ZeroWord;

        case(op)
        `EXE_LUI: begin
            
            reg_o <= `WriteEnable;
            aluop_o <= `EXE_LUI_OP;
                
            reg1_read_o <= `RaadDisable;
            reg2_read_o <= `RaadDisable;

            imm <= {inst_i[31:12], 12'h0};
                
            instvalid <= `InstValid;     

        end

        `EXE_ARTH: begin
            
            case(op3)
            `EXE_ADD: begin

                reg_o <= `WriteEnable;
                aluop_o <= `EXE_ADD_OP;
                    
                reg1_read_o <= `ReadEnable;
                reg2_read_o <= `RaadEnable;

                imm <= `ZeroWord;
                    
                instvalid <= `InstValid;   
            end

            default: begin
                instvalid <= `InstInvalid;
            end

            endcase
        end

        `EXE_JAL: begin
            wreg_o <= `WriteEnable;
            aluop_o <= `EXE_JAL_OP;
                
            reg1_read_o <= `RaadDisable;
            reg2_read_o <= `RaadDisable;

            imm <= {11{inst_i[31]}, inst_i[31], inst_i[19:12], inst_i[20], inst_i[30:21], 1'b0};
                
            instvalid <= `InstValid;    
        end   

        `EXE_B: begin    

            case(op2) 

            `EXE_BEQ: begin
                wreg_o <= `WriteDisable;
                aluop_o <= `EXE_BEQ_OP;
                
                reg1_read_o <= `RaadEnable;
                reg2_read_o <= `RaadEnable;

                imm <= {19{inst_i[31]}, inst_i[31], inst_i[7], inst_i[30:25], inst_i[11:8], 1'b0};
                
                instvalid <= `InstValid; 
            end

            default: begin
                instvalid <= `InstInvalid;       
            end

            endcase
        end
        `EXE_L: begin

            case(op2)
                `EXE_LW: begin
                    wreg_o <= `WriteDisable;
                    aluop_o <= `EXE_LW_OP;
                
                    reg1_read_o <= `RaadEnable;
                    reg2_read_o <= `RaadDisable; 

                    imm <= {20{inst_i[31], inst_i[31:20]};

                    instvalid <= `InstValid;  
                end

                default: begin
                    instvalid <= `InstInvalid;
                end
            endcase         
    
        `EXE_S: begin

            case(op2)
                `EXE_SW: begin
                    wreg_o <= `WriteDisable;
                    aluop_o <= `EXE_SW_OP;
                
                    reg1_read_o <= `RaadEnable;
                    reg2_read_o <= `RaadEnable; 

                    imm <= {20{inst_i[31], inst_i[31:25], inst_i[11:7]};

                    instvalid <= `InstValid;  
                end

                default: begin
                    instvalid <= `InstInvalid;
                end
            endcase  
        end 
        
        default: begin
            instvalid <= `InstInvalid;
        end
        endcase  
    end  // else
end

always @ (*) begin
    stallreq_for_reg1_loadrelated <= `NOSTOP;

    if(rst == `RstEnable) begin
        reg1_o <= `ZeroWord
    end
    else if(pre_inst_is_load == 1'b1 && ex_wd_i == reg1_addr_o
    && reg1_addr_o == 1'b1) begin
        stallreq_for_reg1_loadrelated <= `STOP;
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
    else begin 
        reg1_o <= `ZeroWord;
    end
end

always @ (*) begin
    stallreq_for_reg2_loadrelated <= `NOSTOP;

    if(rst == `RstEnable) begin
        reg2_o <= `ZeroWord
    end 
    else if(pre_inst_is_load == 1'b1 && ex_wd_i == reg2_addr_o
    && reg2_addr_o == 1'b1) begin
        stallreq_for_reg2_loadrelated <= `STOP;
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
    else begin 
        reg2_o <= `ZeroWord;
    end
end

always @ (*) begin
    if(rst == `RstEnable) begin
        imm_o <= `ZeroWord
    end 
    else begin
        imm_o <= imm;
    end
end

always @ (*) begin
    if(rst == `RstEnable) begin
        pc_invalid_o <= `PCValid;
        inst_invalid_o <= `InstValid;
    end
    else begin
        pc_invalid_o <= pc_invalid_i;
        inst_invalid_o <= instvalid;
    end
end


assign stallreq = stallreq_for_reg1_loadrelated | stallreq_for_reg2_loadrelated;
    

endmodule
