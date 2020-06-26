module ex(
    input wire rst,

    //< id to ex signal
    input wire[`AluOpBus]   aluop_i,
    input wire[`AluSelBus]  alusel_i,
    input wire[`RegBus]     reg1_i,
    input wire[`RegBus]     reg2_i,
    input wire[`RegAddrBus] wd_i,
    input wire              wreg_i,

    input wire[`RegBus] link_address_i,

    output reg[`RegAddrBus] wd_o,
    output reg              wreg_o,
    output reg[`RegBus]     wdata_o

);

reg[`RegBus] logicout;

wire ov_sum;
reg[`RegBus] arithmetricres;
wire[`RegBus] result_sum;

assign result_sum = reg1_i + reg2_i;
assign ov_sum = ((!reg1_i[31] && !reg2_i[31]) && result_sum[31])
                || ((reg1_i[31] && reg2_i[31]) && (!result_sum[31]));

always @ (*) begin
    if(rst == `RstEnable) begin
        logicout <= `ZeroWord;
    end
    else begin
        case(aluop_i)
        `EXE_OR_OP: begin
            logicout <= reg1_i | reg2_i;           
        end

        `EXE_ADD_OP: begin
            arithmetricres <= result_sum;
        default: begin
            logicout <= `ZeroWord;
        end

        `EXE_RES_JUMP_BRANCH: begin
            wdata_o <= link_address_i;
        end

        default:
            wdata_o <= `ZeroWord;
        end

        endcase

    end //< end if-else
end

always @ (*) begin

    wd_o <= wd_i;

    if((aluop_i == `·EXE_ADD_OP) || (ov_sum == 1'b1)) begin
        wreg_o <= `WriteDisable;
    end else begin
        wreg_o <= wreg_i;

    case(alusel_i)
    `EXE_RES_LOGIC: begin
        wdata_o <= logicout;
    end
    `EXE_RES_ARITHMETIC: begin
        wdata_o <= arithmetricres;
    end
    default: begin
        wdata_o <= `ZeroWord;
    end

    endcase

end

endmodule
