module tb();
    reg clk;
    reg reset;
    wire [63:0] pc_out;
    wire [63:0] adder1_out;
    wire [63:0] adder2_out;
    wire [63:0] pc_in;
    wire zero;
    wire [31:0] instruction;
    wire [6:0] opcode;
    wire [4:0] rd;
    wire [2:0] funct3;
    wire [4:0] rs1;
    wire [4:0] rs2;
    wire [6:0] funct7;
    wire [63:0]writedata;
    wire [63:0]readdata1;
    wire [63:0]readdata2;
    wire branch;
    wire memread;
    wire memtoreg; 
    wire memwrite; 
    wire alusrc; 
    wire regwrite;
    wire [1:0] aluop;
    wire [63:0] immdata;
    wire [63:0] mux2out;
    wire [3:0] operation;
    wire [63:0] aluout;
    wire [63:0] datamemoryreaddata;
    wire [63:0] element1;
    wire [63:0] element2;
    wire [63:0] element3;
    wire [63:0] element4;
    wire [63:0] element5;
    wire [63:0] element6;
    wire [63:0] element7;
    wire [63:0] element8;
  
  RISC_V_processor r1(
    clk, 
    reset,
    pc_out, 
    adder1_out, 
    adder2_out, 
    pc_in, 
    zero,
    instruction, 
    opcode, 
    rd, 
    funct3, 
    rs1, 
    rs2, 
    funct7,
    writedata, 
    readdata1, 
    readdata2,
    branch, 
    memread, 
    memtoreg, 
    memwrite, 
    alusrc, 
    regwrite,
    aluop, 
    immdata, 
    mux2out, 
    operation, 
    aluout, 
    datamemoryreaddata,
    element1, 
    element2, 
    element3, 
    element4, 
    element5, 
    element6,
    element7,
    element8
    );
  
  initial 
    begin
    	clk = 1'b0;
  end
  
  always 
    begin
    #1
    clk = ~clk;
  	end
  initial 
    begin
      reset = 1'b1;
      #2
      reset = 1'b0;
  	end
  
  initial begin
    $dumpfile("tests.vcd");
    $dumpvars();
  end
endmodule