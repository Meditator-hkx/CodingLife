// Basic building blocks for constructing a Y86 processor.

// Different types of registers, all derivatives of module cenrreg

//* $begin cenrreg-verilog */
// Clocked register with enable signal and synchronous reset
// Default width is 8, but can be overriden
module cenrreg(out, in, enable, reset, resetval, clock);
   parameter width = 8;
   output [width-1:0] out;
   reg [width-1:0]    out;
   input [width-1:0]  in;
   input 	      enable;
   input 	      reset;
   input [width-1:0]  resetval;
   input 	      clock;

   always
     @(posedge clock) 
     begin
	if (reset)
	  out <= resetval;
	else if (enable) 
	  out <= in;
     end
endmodule
//* $end cenrreg-verilog */

// Clocked register with enable signal.
// Default width is 8, but can be overriden
module cenreg(out, in, enable, clock);
   parameter width = 8;
   output [width-1:0] out;
   input [width-1:0]  in;
   input 	      enable;
   input 	      clock;

   cenrreg #(width) c(out, in, enable, 0, 0, clock);
endmodule

// Basic clocked register.  Default width is 8.
module creg(out, in, clock);
   parameter width = 8;
   output [width-1:0] out;
   input [width-1:0]  in;
   input 	      clock;

   cenreg #(width) r(out, in, 1, clock);
endmodule

//* $begin preg-verilog */
// Pipeline register.  Uses reset signal to inject bubble
// When bubbling, must specify value that will be loaded
module preg(out, in, stall, bubble, bubbleval, clock);
   parameter width = 8;
   output [width-1:0] out;
   input [width-1:0]  in;
   input 	      stall, bubble;
   input [width-1:0]  bubbleval;
   input 	      clock;

   cenrreg #(width) r(out, in, ~stall, bubble, bubbleval, clock);
endmodule
//* $end preg-verilog */

// Register file /// line:arch:verilog:regfile_start
module regfile(dstE, valE, dstM, valM, srcA, valA, srcB, valB,
         reset, clock, eax, ecx, edx, ebx, esp, ebp, esi, edi);
   input [3:0] dstE;
   input [31:0] valE;
   input [3:0] 	dstM;
   input [31:0] valM;
   input [3:0] 	srcA;
   output [31:0] valA;
   input [3:0] 	 srcB;
   output [31:0] valB;
   input 	 reset;  // Set registers to 0
   input 	 clock;
   // Make individual registers visible for debugging
   output [31:0] eax, ecx, edx, ebx, esp, ebp, esi, edi;

   // Define names for registers used in HCL code
   parameter 	 REAX =  4'h0;
   parameter 	 RECX =  4'h1;
   parameter 	 REDX =  4'h2;
   parameter 	 REBX =  4'h3;
   parameter 	 RESP =  4'h4;
   parameter 	 REBP =  4'h5;
   parameter 	 RESI =  4'h6;
   parameter 	 REDI =  4'h7;
   parameter 	 RNONE =  4'hf;

   // Input data for each register
   wire [31:0] 	 eax_dat, ecx_dat, edx_dat, ebx_dat, 
		 esp_dat, ebp_dat, esi_dat, edi_dat; 

   // Input write controls for each register
   wire 	 eax_wrt, ecx_wrt, edx_wrt, ebx_wrt, 
		 esp_wrt, ebp_wrt, esi_wrt, edi_wrt; 

   // Implement with clocked registers
   cenrreg #(32) eax_reg(eax, eax_dat, eax_wrt, reset, 0, clock);
   cenrreg #(32) ecx_reg(ecx, ecx_dat, ecx_wrt, reset, 0, clock);
   cenrreg #(32) edx_reg(edx, edx_dat, edx_wrt, reset, 0, clock);
   cenrreg #(32) ebx_reg(ebx, ebx_dat, ebx_wrt, reset, 0, clock);
   cenrreg #(32) esp_reg(esp, esp_dat, esp_wrt, reset, 0, clock);
   cenrreg #(32) ebp_reg(ebp, ebp_dat, ebp_wrt, reset, 0, clock);
   cenrreg #(32) esi_reg(esi, esi_dat, esi_wrt, reset, 0, clock);
   cenrreg #(32) edi_reg(edi, edi_dat, edi_wrt, reset, 0, clock);

   // Reads occur like combinational logic
   assign 	 valA =
		 srcA == REAX ? eax :
		 srcA == RECX ? ecx :
		 srcA == REDX ? edx :
		 srcA == REBX ? ebx :
		 srcA == RESP ? esp :
		 srcA == REBP ? ebp :
		 srcA == RESI ? esi :
		 srcA == REDI ? edi :
		 0;

   assign 	 valB =
		 srcB == REAX ? eax :
		 srcB == RECX ? ecx :
		 srcB == REDX ? edx :
		 srcB == REBX ? ebx :
		 srcB == RESP ? esp :
		 srcB == REBP ? ebp :
		 srcB == RESI ? esi :
		 srcB == REDI ? edi :
		 0;

   assign 	 eax_dat = dstM == REAX ? valM : valE;
   assign 	 ecx_dat = dstM == RECX ? valM : valE;
   assign 	 edx_dat = dstM == REDX ? valM : valE;
   assign 	 ebx_dat = dstM == REBX ? valM : valE;
   assign 	 esp_dat = dstM == RESP ? valM : valE;
   assign 	 ebp_dat = dstM == REBP ? valM : valE;
   assign 	 esi_dat = dstM == RESI ? valM : valE;
   assign 	 edi_dat = dstM == REDI ? valM : valE;

   assign 	 eax_wrt = dstM == REAX | dstE == REAX;
   assign 	 ecx_wrt = dstM == RECX | dstE == RECX;
   assign 	 edx_wrt = dstM == REDX | dstE == REDX;
   assign 	 ebx_wrt = dstM == REBX | dstE == REBX;
   assign 	 esp_wrt = dstM == RESP | dstE == RESP;
   assign 	 ebp_wrt = dstM == REBP | dstE == REBP;
   assign 	 esi_wrt = dstM == RESI | dstE == RESI;
   assign 	 edi_wrt = dstM == REDI | dstE == REDI;

endmodule /// line:arch:verilog:regfile_end

// Memory.  This memory design uses 8 memory banks, each ///line:arch:verilog:bmemory_start
// of which is one byte wide.  Banking allows us to select an
// arbitrary set of 6 contiguous bytes for instruction reading
// and an arbitrary set of 4 contiguous bytes 
// for data reading & writing.
// It uses an external RAM module from either the file
// combram.v (using combinational reads) 
// or synchram.v (using clocked reads)
// The SEQ & SEQ+ processors only work with combram.v.
// PIPE works with either.

//* $begin memory-decl-verilog */
module bmemory(maddr, wenable, wdata, renable, rdata, m_ok, 
               iaddr, instr, i_ok, clock);
   parameter memsize = 4096; // Number of bytes in memory
   input [31:0]  maddr;    // Read/Write address
   input         wenable;  // Write enable
   input [31:0]  wdata;    // Write data
   input 	 renable;  // Read enable
   output [31:0] rdata;    // Read data
   output 	 m_ok;     // Read & write addresses within range
   input [31:0]  iaddr;    // Instruction address
   output [47:0] instr;    // 6 bytes of instruction
   output 	 i_ok;     // Instruction address within range
   input 	 clock;
//* $end memory-decl-verilog */

   wire [7:0] 	 ib0, ib1, ib2, ib3, ib4, ib5; // Instruction bytes
   wire [7:0] 	 db0, db1, db2, db3;           // Data bytes

   wire [2:0] 	 ibid = iaddr[2:0];     // Instruction Bank ID
   wire [28:0] 	 iindex = iaddr[31:3];  // Address within bank
   wire [28:0] 	 iip1 = iindex+1;       // Next address within bank

   wire [2:0] 	 mbid = maddr[2:0];     // Data Bank ID
   wire [28:0] 	 mindex = maddr[31:3];  // Address within bank
   wire [28:0] 	 mip1 = mindex+1;       // Next address within bank

   // Instruction addresses for each bank
   wire [28:0] 	 addrI0, addrI1, addrI2, addrI3, addrI4, addrI5, addrI6, addrI7;
   // Instruction data for each bank
   wire [7:0] 	 outI0, outI1, outI2, outI3, outI4, outI5, outI6, outI7;

   // Data addresses for each bank
   wire [28:0] 	 addrD0, addrD1, addrD2, addrD3, addrD4, addrD5, addrD6, addrD7;
   // Data output for each bank
   wire [7:0] 	 outD0, outD1, outD2, outD3, outD4, outD5, outD6, outD7;
   // Data input for each bank
   wire [7:0] 	 inD0, inD1, inD2, inD3, inD4, inD5, inD6, inD7;
   // Data write enable signals for each bank
   wire 	 dwEn0, dwEn1, dwEn2, dwEn3, dwEn4, dwEn5, dwEn6, dwEn7;

   // The bank memories
   ram #(8, memsize/8, 29) bank0(clock, addrI0, 0, 0, 1, outI0, // Instruction
                                 addrD0, dwEn0, inD0, renable, outD0); // Data

   ram #(8, memsize/8, 29) bank1(clock, addrI1, 0, 0, 1, outI1, // Instruction
                                 addrD1, dwEn1, inD1, renable, outD1); // Data

   ram #(8, memsize/8, 29) bank2(clock, addrI2, 0, 0, 1, outI2, // Instruction
                                 addrD2, dwEn2, inD2, renable, outD2); // Data

   ram #(8, memsize/8, 29) bank3(clock, addrI3, 0, 0, 1, outI3, // Instruction
                                 addrD3, dwEn3, inD3, renable, outD3); // Data

   ram #(8, memsize/8, 29) bank4(clock, addrI4, 0, 0, 1, outI4, // Instruction
                                 addrD4, dwEn4, inD4, renable, outD4); // Data

   ram #(8, memsize/8, 29) bank5(clock, addrI5, 0, 0, 1, outI5, // Instruction
                                 addrD5, dwEn5, inD5, renable, outD5); // Data

   ram #(8, memsize/8, 29) bank6(clock, addrI6, 0, 0, 1, outI6, // Instruction
                                 addrD6, dwEn6, inD6, renable, outD6); // Data

   ram #(8, memsize/8, 29) bank7(clock, addrI7, 0, 0, 1, outI7, // Instruction
                                 addrD7, dwEn7, inD7, renable, outD7); // Data


   // Determine the instruction addresses for the banks
   assign 	 addrI0 = ibid >= 3 ? iip1 : iindex;
   assign 	 addrI1 = ibid >= 4 ? iip1 : iindex;
   assign 	 addrI2 = ibid >= 5 ? iip1 : iindex;
   assign 	 addrI3 = ibid >= 6 ? iip1 : iindex;
   assign 	 addrI4 = ibid >= 7 ? iip1 : iindex;
   assign 	 addrI5 = iindex;
   assign 	 addrI6 = iindex;
   assign 	 addrI7 = iindex;

   // Get the bytes of the instruction
   assign 	 i_ok = 
		 (iaddr + 5) < memsize;

   assign 	 ib0 = !i_ok ? 0 :
		 ibid == 0 ? outI0 :
		 ibid == 1 ? outI1 :
		 ibid == 2 ? outI2 :
		 ibid == 3 ? outI3 :
		 ibid == 4 ? outI4 :
		 ibid == 5 ? outI5 :
		 ibid == 6 ? outI6 :
		 outI7;
   assign 	 ib1 = !i_ok ? 0 :
		 ibid == 0 ? outI1 :
		 ibid == 1 ? outI2 :
		 ibid == 2 ? outI3 :
		 ibid == 3 ? outI4 :
		 ibid == 4 ? outI5 :
		 ibid == 5 ? outI6 :
		 ibid == 6 ? outI7 :
		 outI0;
   assign 	 ib2 = !i_ok ? 0 :
		 ibid == 0 ? outI2 :
		 ibid == 1 ? outI3 :
		 ibid == 2 ? outI4 :
		 ibid == 3 ? outI5 :
		 ibid == 4 ? outI6 :
		 ibid == 5 ? outI7 :
		 ibid == 6 ? outI0 :
		 outI1;
   assign 	 ib3 = !i_ok ? 0 :
		 ibid == 0 ? outI3 :
		 ibid == 1 ? outI4 :
		 ibid == 2 ? outI5 :
		 ibid == 3 ? outI6 :
		 ibid == 4 ? outI7 :
		 ibid == 5 ? outI0 :
		 ibid == 6 ? outI1 :
		 outI2;
   assign 	 ib4 = !i_ok ? 0 :
		 ibid == 0 ? outI4 :
		 ibid == 1 ? outI5 :
		 ibid == 2 ? outI6 :
		 ibid == 3 ? outI7 :
		 ibid == 4 ? outI0 :
		 ibid == 5 ? outI1 :
		 ibid == 6 ? outI2 :
		 outI3;
   assign 	 ib5 = !i_ok ? 0 :
		 ibid == 0 ? outI5 :
		 ibid == 1 ? outI6 :
		 ibid == 2 ? outI7 :
		 ibid == 3 ? outI0 :
		 ibid == 4 ? outI1 :
		 ibid == 5 ? outI2 :
		 ibid == 6 ? outI3 :
		 outI4;

   assign 	 instr[ 7: 0] = ib0;
   assign 	 instr[15: 8] = ib1;
   assign 	 instr[23:16] = ib2;
   assign 	 instr[31:24] = ib3;
   assign 	 instr[39:32] = ib4;
   assign 	 instr[47:40] = ib5;

   assign 	 m_ok = 
		 (!renable & !wenable | (maddr + 3) < memsize);

   assign 	 addrD0 = mbid >= 5 ? mip1 : mindex;
   assign 	 addrD1 = mbid >= 6 ? mip1 : mindex;
   assign 	 addrD2 = mbid >= 7 ? mip1 : mindex;
   assign 	 addrD3 = mindex;
   assign 	 addrD4 = mindex;
   assign 	 addrD5 = mindex;
   assign 	 addrD6 = mindex;
   assign 	 addrD7 = mindex;

   // Get the bytes of data;
   assign 	 db0 = !m_ok ? 0 :
		 mbid == 0 ? outD0 :
		 mbid == 1 ? outD1 :
		 mbid == 2 ? outD2 :
		 mbid == 3 ? outD3 :
		 mbid == 4 ? outD4 :
		 mbid == 5 ? outD5 :
		 mbid == 6 ? outD6 :
		 outD7;
   assign 	 db1 = !m_ok ? 0 :
		 mbid == 0 ? outD1 :
		 mbid == 1 ? outD2 :
		 mbid == 2 ? outD3 :
		 mbid == 3 ? outD4 :
		 mbid == 4 ? outD5 :
		 mbid == 5 ? outD6 :
		 mbid == 6 ? outD7 :
		 outD0;
   assign 	 db2 = !m_ok ? 0 :
		 mbid == 0 ? outD2 :
		 mbid == 1 ? outD3 :
		 mbid == 2 ? outD4 :
		 mbid == 3 ? outD5 :
		 mbid == 4 ? outD6 :
		 mbid == 5 ? outD7 :
		 mbid == 6 ? outD0 :
		 outD1;
   assign 	 db3 = !m_ok ? 0 :
		 mbid == 0 ? outD3 :
		 mbid == 1 ? outD4 :
		 mbid == 2 ? outD5 :
		 mbid == 3 ? outD6 :
		 mbid == 4 ? outD7 :
		 mbid == 5 ? outD0 :
		 mbid == 6 ? outD1 :
		 outD2;

   assign 	 rdata[ 7: 0] = db0;
   assign 	 rdata[15: 8] = db1;
   assign 	 rdata[23:16] = db2;
   assign 	 rdata[31:24] = db3;

   wire [7:0] 	 wd0 = wdata[7:0];
   wire [7:0] 	 wd1 = wdata[15:8];
   wire [7:0] 	 wd2 = wdata[23:16];
   wire [7:0] 	 wd3 = wdata[31:24];

   assign 	 inD0 =
		 mbid == 5 ? wd3 :
		 mbid == 6 ? wd2 :
		 mbid == 7 ? wd1 :
		 mbid == 0 ? wd0 :
		 0;

   assign 	 inD1 =
		 mbid == 6 ? wd3 :
		 mbid == 7 ? wd2 :
		 mbid == 0 ? wd1 :
		 mbid == 1 ? wd0 :
		 0;

   assign 	 inD2 =
		 mbid == 7 ? wd3 :
		 mbid == 0 ? wd2 :
		 mbid == 1 ? wd1 :
		 mbid == 2 ? wd0 :
		 0;

   assign 	 inD3 =
		 mbid == 0 ? wd3 :
		 mbid == 1 ? wd2 :
		 mbid == 2 ? wd1 :
		 mbid == 3 ? wd0 :
		 0;

   assign 	 inD4 =
		 mbid == 1 ? wd3 :
		 mbid == 2 ? wd2 :
		 mbid == 3 ? wd1 :
		 mbid == 4 ? wd0 :
		 0;

   assign 	 inD5 =
		 mbid == 2 ? wd3 :
		 mbid == 3 ? wd2 :
		 mbid == 4 ? wd1 :
		 mbid == 5 ? wd0 :
		 0;

   assign 	 inD6 =
		 mbid == 3 ? wd3 :
		 mbid == 4 ? wd2 :
		 mbid == 5 ? wd1 :
		 mbid == 6 ? wd0 :
		 0;

   assign 	 inD7 =
		 mbid == 4 ? wd3 :
		 mbid == 5 ? wd2 :
		 mbid == 6 ? wd1 :
		 mbid == 7 ? wd0 :
		 0;

   // Which banks get written
   assign 	 dwEn0 = wenable & (mbid <= 0 | mbid >= 5);  
   assign 	 dwEn1 = wenable & (mbid <= 1 | mbid >= 6);  
   assign 	 dwEn2 = wenable & (mbid <= 2 | mbid >= 7);  
   assign 	 dwEn3 = wenable & (mbid <= 3);
   assign 	 dwEn4 = wenable & (mbid >= 1 & mbid <= 4);
   assign 	 dwEn5 = wenable & (mbid >= 2 & mbid <= 5);
   assign 	 dwEn6 = wenable & (mbid >= 3 & mbid <= 6);
   assign 	 dwEn7 = wenable & (mbid >= 4);

endmodule ///line:arch:verilog:bmemory_end


// Combinational blocks

// Fetch stage

//* $begin fetch-blocks-verilog */
// Split instruction byte into icode and ifun fields
module split(ibyte, icode, ifun);
   input  [7:0] ibyte;
   output [3:0] icode;
   output [3:0] ifun;

   assign 	icode = ibyte[7:4];
   assign 	ifun  = ibyte[3:0];
endmodule

// Extract immediate word from 5 bytes of instruction
module align(ibytes, need_regids, rA, rB, valC);
   input [39:0]  ibytes;
   input 	 need_regids;
   output [3:0]  rA;
   output [3:0]  rB;
   output [31:0] valC;
   assign 	 rA = ibytes[7:4];
   assign 	 rB = ibytes[3:0];
   assign 	 valC = need_regids ? ibytes[39:8] : ibytes[31:0];
endmodule

// PC incrementer
module pc_increment(pc, need_regids, need_valC, valP);
   input [31:0]  pc;
   input 	 need_regids;
   input 	 need_valC;
   output [31:0] valP;
   assign 	 valP = pc + 1 + 4*need_valC + need_regids;
endmodule
//* $end fetch-blocks-verilog */

// Execute Stage

// ALU
//* $begin alu-verilog */
module alu(aluA, aluB, alufun, valE, new_cc);
   input [31:0]  aluA, aluB;	// Data inputs
   input [3:0] 	 alufun;	// ALU function
   output [31:0] valE;		// Data Output
   output [2:0]  new_cc; 	// New values for ZF, SF, OF

   parameter 	 ALUADD = 4'h0;
   parameter 	 ALUSUB = 4'h1;
   parameter 	 ALUAND = 4'h2;
   parameter 	 ALUXOR = 4'h3;

   assign 	 valE = 
		 alufun == ALUSUB ? aluB - aluA :
		 alufun == ALUAND ? aluB & aluA :
		 alufun == ALUXOR ? aluB ^ aluA :
		 aluB + aluA;
   assign 	 new_cc[2] = (valE == 0);  // ZF
   assign 	 new_cc[1] = valE[31];     // SF
   assign 	 new_cc[0] =		   // OF
		   alufun == ALUADD ?
		      (aluA[31] == aluB[31])  & (aluA[31] != valE[31]) :
		   alufun == ALUSUB ?
		      (~aluA[31] == aluB[31]) & (aluB[31] != valE[31]) :
		   0;
endmodule
//* $end alu-verilog */


// Condition code register
module cc(cc, new_cc, set_cc, reset, clock);
   output[2:0] cc;
   input [2:0] new_cc;
   input       set_cc;
   input       reset;
   input       clock;

   cenrreg #(3) c(cc, new_cc, set_cc, reset, 3'b100, clock);
endmodule

// branch condition logic
module cond(ifun, cc, Cnd);
   input [3:0] ifun;
   input [2:0] cc;
   output      Cnd;

   wire        zf = cc[2];
   wire        sf = cc[1];
   wire        of = cc[0];

   // Jump & move conditions.
   parameter   C_YES  = 4'h0;
   parameter   C_LE   = 4'h1;
   parameter   C_L    = 4'h2;
   parameter   C_E    = 4'h3;
   parameter   C_NE   = 4'h4;
   parameter   C_GE   = 4'h5;
   parameter   C_G    = 4'h6;

   assign      Cnd = 
	       (ifun == C_YES) |               //
	       (ifun == C_LE & ((sf^of)|zf)) | // <=
	       (ifun == C_L  & (sf^of)) |      // <
	       (ifun == C_E  & zf) |           // ==
	       (ifun == C_NE & ~zf) |          // !=
	       (ifun == C_GE & (~sf^of)) |     // >=
	       (ifun == C_G  & (~sf^of)&~zf);  // >

endmodule
