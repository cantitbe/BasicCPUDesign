//*********** Global Macros  **********************************

`define RstEnable      1'b1 
`define RstDisable     1'b0
`define ChipEnable     1'b1
`define ChipDisable    1'b0
`define ZeroWord       32'b00000000
`define WriteEnable    1'b1
`define WriteDisable   1'b0
`define ReadEnable     1'b1
`define ReadDisable    1'b0
`define AluOpBus       7:0
`define AluSelBus      2:0
`define InstValid      1'b1
`define InstInvalid    1'b0 


`define STOP    1'b1
`define NOSTOP  1'b0
`define Branch  1'b1
`define NotBranch 1'b0

//***********  Instruction specific macros *******************
`define EXE_NOP   7'b0000000
`define EXE_LUI   7'b0110111    ///< LUI opcode 
`define EXE_JAL   7'b1101111    ///< jal
`define EXE_BNE   7'b1100011    ///< bne
`define EXE_SW    7'b0100011    ///< sw
`define EXE_LW    7'b0000011    ///< lw
`define EXE_ADD   6'b0110011    ///< add 

//ALUOp
`define EXE_OR_OP  8'b00100101
`define EXE_NOP_OP 8'b00000000
`define EXE_ADD_OP 
`define EXE_JAL_OP
`define EXE_BEQ_OP
`define EXE_LW_OP

//ALUSel
`define EXE_RES_LOGIC 3'b001
`define EXE_RES_NOP   3'b000
`define EXE_RES_ARITHMETIC 
`define EXE_RES_JUMP_BRANCH
`define EXE_RES_LOAD_STORE

`define EXE_SPECIAL_INST 6'b000000

//**********  Instruction ROM specific macros ***************
`define InstAddrBus    31:0   ///< ROM addresss bus width
`define InstBus        31:0   ///< ROM data bus width

`define InstMemNum
`define InstMemNumLog2





//**********  Regfile related macro ***************************
`define RegAddrBus    4:0      ///< regfile address bus width
`define RegBus        31:0     ///< regfile data bus width
`define RegWidth      32       ///< general reg width 
`define RegNum        32       ///< no of registers
`define RegNumLog2    5        ///< general register address width
`define NOPRegAddr    5'b00000 