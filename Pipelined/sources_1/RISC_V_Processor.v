`timescale 1ns / 1ps

module RISC_V_processor(
    input clk,
    input reset,
    output wire [63:0] pc_out,
    output wire [63:0] adder1_out,
    output wire [63:0] adder2_out,
    output wire [63:0] pc_in,
    output wire zero,
    output wire [31:0] instruction,
    output wire [6:0] opcode,
    output wire [4:0] rd,
    output wire [2:0] funct3,
    output wire [4:0] rs1,
    output wire [4:0] rs2,
    output wire [6:0] funct7,
    output wire [63:0]writedata,
    output wire [63:0]readdata1,
    output wire [63:0]readdata2,
    output wire branch, 
    output wire memread, 
    output wire memtoreg, 
    output wire memwrite, 
    output wire alusrc, 
    output wire regwrite,
    output wire [1:0] aluop,
    output wire [63:0] immdata,
    output wire [63:0] mux2out,
    output wire [3:0] operation,
    output wire [63:0] aluout,
    output wire [63:0] datamemoryreaddata,
    output wire [63:0] array_1,
    output wire [63:0] array_2,
    output wire [63:0] array_3,
    output wire [63:0] array_4,
    output wire [63:0] array_5,
    output wire [63:0] array_6,
    output wire [63:0] array_7,
    output wire [63:0] array_8
);

wire branch_finale;
wire [3:0] funct;  
wire addermuxselect;

wire [63:0] IF_ID_pc_out;
wire [31:0] IF_ID_inst;

wire [63:0] ID_EX_pc_out, 
            ID_EX_readdata1, 
            ID_EX_readdata2,
            ID_EX_immdata;
            
wire [4:0] ID_EX_rs1, 
           ID_EX_rs2, 
           ID_EX_rd;

wire ID_EX_branch, 
     ID_EX_memread, 
     ID_EX_memtoreg, 
     ID_EX_memwrite,
     ID_EX_regwrite,
     ID_EX_alusrc;
     
wire [3:0] ID_EX_funct;
     
wire [1:0] ID_EX_aluop;

wire [63:0] EX_MEM_adderout,
            EX_MEM_aluout,
            EX_MEM_writedataout;
            
wire EX_MEM_zero, 
     EX_MEM_branch,
     EX_MEM_memread,
     EX_MEM_memtoreg,
     EX_MEM_memwrite,
     EX_MEM_regwrite;

wire [4:0] EX_MEM_rd;
  
wire [63:0] MEM_WB_readdataout,
            MEM_WB_aluout;
            
wire [4:0] MEM_WB_rd;

wire MEM_WB_memtoreg,  
     MEM_WB_regwrite;
     
wire [1:0] forwarda,
           forwardb;
        
wire [63:0] mux_3x1__out1,
            mux_3x1_out2;
            
Program_Counter pc(clk, reset, pc_in,pc_out);

Instruction_Memory im(pc_out, instruction);

Adder a1(pc_out, 64'd4, adder1_out);

IF_ID ifid(clk, reset, pc_out, instruction, IF_ID_pc_out, IF_ID_inst);

Instruction ip(instruction, opcode, rd, funct3, rs1, rs2, funct7);
Control_Unit cu(opcode, branch, memread, memtoreg, memwrite, alusrc, regwrite, aluop);

RegisterFile rf(writedata, rs1, rs2, MEM_WB_rd, regwrite, clk, reset, readdata1, readdata2);

Imm_data_gen imm_gen(IF_ID_inst, immdata);

ID_EX idex(clk, reset, IF_ID_pc_out, readdata1, readdata2, immdata,   rs1, rs2, rd,
                {IF_ID_inst[30], IF_ID_inst[14:12] },  branch, memread, memtoreg, memwrite, regwrite, alusrc, 
               aluop, ID_EX_pc_out, ID_EX_readdata1,ID_EX_readdata2, ID_EX_immdata,  
               ID_EX_rs1, ID_EX_rs2, ID_EX_rd,   ID_EX_funct,   ID_EX_branch, ID_EX_memread, 
               ID_EX_memtoreg, ID_EX_memwrite, ID_EX_regwrite, ID_EX_alusrc,   ID_EX_aluop);

Adder a2(ID_EX_pc_out,  ID_EX_immdata*2, adder2_out);

mux_3to1 mux1(ID_EX_readata1, writedata, EX_MEM_aluout, forwarda, mux_3x1__out1);

mux_3to1 mux2(ID_EX_readata2, writedata, EX_MEM_aluout, forwardb, mux_3x1__out2);

Mux m1(mux_3x1_out2, ID_EX_immdata, ID_EX_alusrc, mux2out);

ALU_64_bit alu( mux_3x1__out1, mux2out, operation, aluout, zero);

ALU_Control alu_c( ID_EX_aluop, ID_EX_funct, operation);

EX_MEM exmem( 
   clk,reset,
   adder2_out, 
   aluout, 
   zero,
   mux_3x1__out2,
   ID_EX_rd, 
   ID_EX_branch, ID_EX_memread, ID_EX_memtoreg, ID_EX_memwrite, ID_EX_regwrite,
   addermuxselect,
   EX_MEM_adderout,
   EX_MEM_zero,
   EX_MEM_aluout,
   EX_MEM_writedataout,
   EX_MEM_rd,
   EX_MEM_branch, EX_MEM_memread, EX_MEM_memtoreg, EX_MEM_memwrite, EX_MEM_regwrite,
   branch_finale);

Data_Memory dm( EX_MEM_aluout, EX_MEM_writedataout, clk, EX_MEM_memwrite, EX_MEM_memread, datamemoryreaddata, array_1, array_2, array_3, array_4, array_5, array_6, array_7, array_8);

MEM_WB memwb(clk, reset, datamemoryreaddata, EX_MEM_aluout, EX_MEM_rd, EX_MEM_memtoreg, EX_MEM_regwrite, 
                            MEM_WB_readdataout, MEM_WB_aluout, MEM_WB_rd, MEM_WB_memtoreg, MEM_WB_regwrite);

Mux m3( adder1_out, EX_MEM_adderout, (EX_MEM_branch&&branch_finale), pc_in);

forwardingunit f1( ID_EX_rs1, ID_EX_rs2, EX_MEM_rd, MEM_WB_rd, MEM_WB_regwrite, EX_MEM_regwrite, forwarda, forwardb);

branching_unit bu( ID_EX_funct[2:0], ID_EX_readdata1, mux2out, addermuxselect);
endmodule
