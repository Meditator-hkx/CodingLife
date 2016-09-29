$c	This is the master .hcl code for the single cycle processor.
$c	It includes both SEQ and SEQ+
$c	The Perl script ../hcl/vextract.pl extracts the different versions
$c	depending on the options shown in the first characters of each line.
$c	vextract.pl is given a set of single-character version names.
$c	Any line beginning with $[a-zA-Z]*\t is included only if
$c	one of the characters matches one of the version names.
$c	Any line beginning with $![a-zA-Z]*\t is included unless
$c	one of the characters matches one of the version names.
$c	
$c	Options:
$c	c: Comments (won't show up in any extracted version)
$c	a: Add annotations (used for generating .tex files)
$c	+: HCL code for SEQ+
$c	f: iaddl+leave problem
$c	F: iaddl+leave solution
$c	r: Conditional move not implemented
#/* $begin seq-all-hcl */
####################################################################
$!+	#  HCL Description of Control for Single Cycle Y86 Processor SEQ   #
$+	#  HCL Description of Control for Single Cycle Y86 Processor SEQ+  #
#  Copyright (C) Randal E. Bryant, David R. O'Hallaron, 2010       #
####################################################################
$fF	
$f	## Your task is to implement the iaddl and leave instructions
$f	## The file contains a declaration of the icodes
$f	## for iaddl (IIADDL) and leave (ILEAVE).
$f	## Your job is to add the rest of the logic to make it work
$F	## This is the solution for the iaddl and leave problems

####################################################################
#    C Include's.  Don't alter these                               #
####################################################################

quote '#include <stdio.h>'
quote '#include "isa.h"'
quote '#include "sim.h"'
quote 'int sim_main(int argc, char *argv[]);'
$!+	quote 'int gen_pc(){return 0;}'
$!+	quote 'int main(int argc, char *argv[])'
$!+	quote '  {plusmode=0;return sim_main(argc,argv);}'
$+	quote 'int gen_new_pc(){return 0;}'
$+	quote 'int main(int argc, char *argv[])'
$+	quote '  {plusmode=1;return sim_main(argc,argv);}'

####################################################################
#    Declarations.  Do not change/remove/delete any of these       #
####################################################################

##### Symbolic representation of Y86 Instruction Codes #############
intsig INOP 	'I_NOP'
intsig IHALT	'I_HALT'
intsig IRRMOVL	'I_RRMOVL'
intsig IIRMOVL	'I_IRMOVL'
intsig IRMMOVL	'I_RMMOVL'
intsig IMRMOVL	'I_MRMOVL'
intsig IOPL	'I_ALU'
intsig IJXX	'I_JMP'
intsig ICALL	'I_CALL'
intsig IRET	'I_RET'
intsig IPUSHL	'I_PUSHL'
intsig IPOPL	'I_POPL'
$fF	# Instruction code for iaddl instruction
$fF	intsig IIADDL	'I_IADDL'
$fF	# Instruction code for leave instruction
$fF	intsig ILEAVE	'I_LEAVE'

##### Symbolic represenations of Y86 function codes                  #####
intsig FNONE    'F_NONE'        # Default function code

##### Symbolic representation of Y86 Registers referenced explicitly #####
intsig RESP     'REG_ESP'    	# Stack Pointer
$fF	intsig REBP     'REG_EBP'    	# Frame Pointer
intsig RNONE    'REG_NONE'   	# Special value indicating "no register"

##### ALU Functions referenced explicitly                            #####
intsig ALUADD	'A_ADD'		# ALU should add its arguments

##### Possible instruction status values                             #####
intsig SAOK	'STAT_AOK'		# Normal execution
intsig SADR	'STAT_ADR'	# Invalid memory address
intsig SINS	'STAT_INS'	# Invalid instruction
intsig SHLT	'STAT_HLT'	# Halt instruction encountered

##### Signals that can be referenced by control logic ####################

$+	##### PC stage inputs			#####
$+	
$+	## All of these values are based on those from previous instruction
$+	intsig  pIcode 'prev_icode'		# Instr. control code
$+	intsig  pValC  'prev_valc'		# Constant from instruction
$+	intsig  pValM  'prev_valm'		# Value read from memory
$+	intsig  pValP  'prev_valp'		# Incremented program counter
$+	boolsig pCnd 'prev_bcond'		# Condition flag
$+	
$!+	##### Fetch stage inputs		#####
$!+	intsig pc 'pc'				# Program counter
##### Fetch stage computations		#####
intsig imem_icode 'imem_icode'		# icode field from instruction memory
intsig imem_ifun  'imem_ifun' 		# ifun field from instruction memory
intsig icode	  'icode'		# Instruction control code
intsig ifun	  'ifun'		# Instruction function
intsig rA	  'ra'			# rA field from instruction
intsig rB	  'rb'			# rB field from instruction
intsig valC	  'valc'		# Constant from instruction
intsig valP	  'valp'		# Address of following instruction
boolsig imem_error 'imem_error'		# Error signal from instruction memory
boolsig instr_valid 'instr_valid'	# Is fetched instruction valid?

##### Decode stage computations		#####
intsig valA	'vala'			# Value from register A port
intsig valB	'valb'			# Value from register B port

##### Execute stage computations	#####
intsig valE	'vale'			# Value computed by ALU
boolsig Cnd	'cond'			# Branch test

##### Memory stage computations		#####
intsig valM	'valm'			# Value read from memory
boolsig dmem_error 'dmem_error'		# Error signal from data memory


####################################################################
#    Control Signal Definitions.                                   #
####################################################################

$+	################ Program Counter Computation #######################
$+	
$+	# Compute fetch location for this instruction based on results from
$+	# previous instruction.
$+	
$a	#/* $begin seq-plus-pc-hcl */
$+	int pc = [
$+		# Call.  Use instruction constant
$+		pIcode == ICALL : pValC;
$+		# Taken branch.  Use instruction constant
$+		pIcode == IJXX && pCnd : pValC;
$+		# Completion of RET instruction.  Use value from stack
$+		pIcode == IRET : pValM;
$+		# Default: Use incremented PC
$+		1 : pValP;
$+	];
$+	#/* $end seq-plus-pc-hcl */
$+	
################ Fetch Stage     ###################################

# Determine instruction code
int icode = [
	imem_error: INOP;
	1: imem_icode;		# Default: get from instruction memory
];

# Determine instruction function
int ifun = [
	imem_error: FNONE;
	1: imem_ifun;		# Default: get from instruction memory
];

bool instr_valid = icode in 
	{ INOP, IHALT, IRRMOVL, IIRMOVL, IRMMOVL, IMRMOVL,
$F		       IIADDL, ILEAVE,
	       IOPL, IJXX, ICALL, IRET, IPUSHL, IPOPL };

# Does fetched instruction require a regid byte?
$a	#/* $begin seq-need_regids-hcl */
bool need_regids =
	icode in { IRRMOVL, IOPL, IPUSHL, IPOPL, 
$F			     IIADDL,
		     IIRMOVL, IRMMOVL, IMRMOVL };
$a	#/* $end seq-need_regids-hcl */

# Does fetched instruction require a constant word?
$a	#/* $begin seq-need_valC-hcl */
bool need_valC =
$!F		icode in { IIRMOVL, IRMMOVL, IMRMOVL, IJXX, ICALL };
$F		icode in { IIRMOVL, IRMMOVL, IMRMOVL, IJXX, ICALL, IIADDL };
$a	#/* $end seq-need_valC-hcl */

################ Decode Stage    ###################################

## What register should be used as the A source?
$a	#/* $begin seq-srcA-hcl */
int srcA = [
	icode in { IRRMOVL, IRMMOVL, IOPL, IPUSHL  } : rA;
$F		icode in { ILEAVE } : REBP;
	icode in { IPOPL, IRET } : RESP;
	1 : RNONE; # Don't need register
];
$a	#/* $end seq-srcA-hcl */

## What register should be used as the B source?
$a	#/* $begin seq-srcB-hcl */
int srcB = [
	icode in { IOPL, IRMMOVL, IMRMOVL  } : rB;
$F		icode in { IIADDL  } : rB;	
	icode in { IPUSHL, IPOPL, ICALL, IRET } : RESP;
$F		icode in { ILEAVE  } : REBP;	
	1 : RNONE;  # Don't need register
];
$a	#/* $end seq-srcB-hcl */

## What register should be used as the E destination?
$a	#/* $begin seq-dstE-nocmov-hcl */
$a	#/* $begin seq-dstE-cmov-hcl */
$r	# WARNING: Conditional move not implemented correctly here
int dstE = [
$!r		icode in { IRRMOVL } && Cnd : rB;
$!r		icode in { IIRMOVL, IOPL} : rB;
$r		icode in { IRRMOVL } : rB;
$r		icode in { IIRMOVL, IOPL} : rB;
$F		icode in { IIADDL } : rB;
	icode in { IPUSHL, IPOPL, ICALL, IRET } : RESP;
$F		icode in { ILEAVE } : RESP;
	1 : RNONE;  # Don't write any register
];
$a	#/* $end seq-dstE-cmov-hcl */
$a	#/* $end seq-dstE-nocmov-hcl */

## What register should be used as the M destination?
$a	#/* $begin seq-dstM-hcl */
int dstM = [
	icode in { IMRMOVL, IPOPL } : rA;
$F		icode in { ILEAVE } : REBP;
	1 : RNONE;  # Don't write any register
];
$a	#/* $end seq-dstM-hcl */

################ Execute Stage   ###################################

## Select input A to ALU
$a	#/* $begin seq-aluA-hcl */
int aluA = [
	icode in { IRRMOVL, IOPL } : valA;
	icode in { IIRMOVL, IRMMOVL, IMRMOVL } : valC;
$F		icode in { IIADDL } : valC;
	icode in { ICALL, IPUSHL } : -4;
	icode in { IRET, IPOPL } : 4;
$F		icode in { ILEAVE } : 4;
	# Other instructions don't need ALU
];
$a	#/* $end seq-aluA-hcl */

## Select input B to ALU
$a	#/* $begin seq-aluB-hcl */
int aluB = [
	icode in { IRMMOVL, IMRMOVL, IOPL, ICALL, 
		      IPUSHL, IRET, IPOPL } : valB;
$F		icode in { IIADDL, ILEAVE } : valB;
	icode in { IRRMOVL, IIRMOVL } : 0;
	# Other instructions don't need ALU
];
$a	#/* $end seq-aluB-hcl */

## Set the ALU function
$a	#/* $begin seq-alufun-hcl */
int alufun = [
	icode == IOPL : ifun;
	1 : ALUADD;
];
$a	#/* $end seq-alufun-hcl */

## Should the condition codes be updated?
$a	#/* $begin seq-set_cc-hcl */
$!F	bool set_cc = icode in { IOPL };
$F	bool set_cc = icode in { IOPL, IIADDL };
$a	#/* $end seq-set_cc-hcl */

################ Memory Stage    ###################################

## Set read control signal
$a	#/* $begin seq-mem_read-hcl */
$!F	bool mem_read = icode in { IMRMOVL, IPOPL, IRET };
$F	bool mem_read = icode in { IMRMOVL, IPOPL, IRET, ILEAVE };
$a	#/* $end seq-mem_read-hcl */

## Set write control signal
$a	#/* $begin seq-mem_write-hcl */
bool mem_write = icode in { IRMMOVL, IPUSHL, ICALL };
$a	#/* $end seq-mem_write-hcl */

## Select memory address
$a	#/* $begin seq-mem_addr-hcl */
int mem_addr = [
	icode in { IRMMOVL, IPUSHL, ICALL, IMRMOVL } : valE;
	icode in { IPOPL, IRET } : valA;
$F		icode in { ILEAVE } : valA;
	# Other instructions don't need address
];
$a	#/* $end seq-mem_addr-hcl */

## Select memory input data
$a	#/* $begin seq-mem_data-hcl */
int mem_data = [
	# Value from register
	icode in { IRMMOVL, IPUSHL } : valA;
	# Return PC
	icode == ICALL : valP;
	# Default: Don't write anything
];
$a	#/* $end seq-mem_data-hcl */

$a	#/* $begin seq-stat-hcl */
## Determine instruction status
int Stat = [
	imem_error || dmem_error : SADR;
	!instr_valid: SINS;
	icode == IHALT : SHLT;
	1 : SAOK;
];
$a	#/* $end seq-stat-hcl */
$!+	
$!+	################ Program Counter Update ############################
$!+	
$!+	## What address should instruction be fetched at
$!+	
$a	#/* $begin seq-new_pc-hcl */
$!+	int new_pc = [
$!+		# Call.  Use instruction constant
$!+		icode == ICALL : valC;
$!+		# Taken branch.  Use instruction constant
$!+		icode == IJXX && Cnd : valC;
$!+		# Completion of RET instruction.  Use value from stack
$!+		icode == IRET : valM;
$!+		# Default: Use incremented PC
$!+		1 : valP;
$!+	];
$a	#/* $end seq-new_pc-hcl */
#/* $end seq-all-hcl */
