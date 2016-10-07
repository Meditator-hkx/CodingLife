#/* $begin seq-all-hcl */
####################################################################
#  HCL Description of Control for Single Cycle Y86 Processor SEQ   #
#  Copyright (C) Randal E. Bryant, David R. O'Hallaron, 2010       #
####################################################################

####################################################################
#    C Include's.  Don't alter these                               #
####################################################################

quote '#include <stdio.h>'
quote '#include "isa.h"'
quote '#include "sim.h"'
quote 'int sim_main(int argc, char *argv[]);'
quote 'int gen_pc(){return 0;}'
quote 'int main(int argc, char *argv[])'
quote '  {plusmode=0;return sim_main(argc,argv);}'

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

##### Symbolic represenations of Y86 function codes                  #####
intsig FNONE    'F_NONE'        # Default function code

##### Symbolic representation of Y86 Registers referenced explicitly #####
intsig RESP     'REG_ESP'    	# Stack Pointer
intsig RNONE    'REG_NONE'   	# Special value indicating "no register"

##### ALU Functions referenced explicitly                            #####
intsig ALUADD	'A_ADD'		# ALU should add its arguments

##### Possible instruction status values                             #####
intsig SAOK	'STAT_AOK'		# Normal execution
intsig SADR	'STAT_ADR'	# Invalid memory address
intsig SINS	'STAT_INS'	# Invalid instruction
intsig SHLT	'STAT_HLT'	# Halt instruction encountered

##### Signals that can be referenced by control logic ####################

##### Fetch stage inputs		#####
intsig pc 'pc'				# Program counter
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

#/* $begin seq-plus-pc-hcl */
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
	       IOPL, IJXX, ICALL, IRET, IPUSHL, IPOPL };

# Does fetched instruction require a regid byte?
#/* $begin seq-need_regids-hcl */
bool need_regids =
	icode in { IRRMOVL, IOPL, IPUSHL, IPOPL, 
		     IIRMOVL, IRMMOVL, IMRMOVL };
#/* $end seq-need_regids-hcl */

# Does fetched instruction require a constant word?
#/* $begin seq-need_valC-hcl */
bool need_valC =
	icode in { IIRMOVL, IRMMOVL, IMRMOVL, IJXX, ICALL };
#/* $end seq-need_valC-hcl */

################ Decode Stage    ###################################

## What register should be used as the A source?
#/* $begin seq-srcA-hcl */
int srcA = [
	icode in { IRRMOVL, IRMMOVL, IOPL, IPUSHL  } : rA;
	icode in { IPOPL, IRET } : RESP;
	1 : RNONE; # Don't need register
];
#/* $end seq-srcA-hcl */

## What register should be used as the B source?
#/* $begin seq-srcB-hcl */
int srcB = [
	icode in { IOPL, IRMMOVL, IMRMOVL  } : rB;
	icode in { IPUSHL, IPOPL, ICALL, IRET } : RESP;
	1 : RNONE;  # Don't need register
];
#/* $end seq-srcB-hcl */

## What register should be used as the E destination?
#/* $begin seq-dstE-nocmov-hcl */
#/* $begin seq-dstE-cmov-hcl */
int dstE = [
	icode in { IRRMOVL } && Cnd : rB;
	icode in { IIRMOVL, IOPL} : rB;
	icode in { IPUSHL, IPOPL, ICALL, IRET } : RESP;
	1 : RNONE;  # Don't write any register
];
#/* $end seq-dstE-cmov-hcl */
#/* $end seq-dstE-nocmov-hcl */

## What register should be used as the M destination?
#/* $begin seq-dstM-hcl */
int dstM = [
	icode in { IMRMOVL, IPOPL } : rA;
	1 : RNONE;  # Don't write any register
];
#/* $end seq-dstM-hcl */

################ Execute Stage   ###################################

## Select input A to ALU
#/* $begin seq-aluA-hcl */
int aluA = [
	icode in { IRRMOVL, IOPL } : valA;
	icode in { IIRMOVL, IRMMOVL, IMRMOVL } : valC;
	icode in { ICALL, IPUSHL } : -4;
	icode in { IRET, IPOPL } : 4;
	# Other instructions don't need ALU
];
#/* $end seq-aluA-hcl */

## Select input B to ALU
#/* $begin seq-aluB-hcl */
int aluB = [
	icode in { IRMMOVL, IMRMOVL, IOPL, ICALL, 
		      IPUSHL, IRET, IPOPL } : valB;
	icode in { IRRMOVL, IIRMOVL } : 0;
	# Other instructions don't need ALU
];
#/* $end seq-aluB-hcl */

## Set the ALU function
#/* $begin seq-alufun-hcl */
int alufun = [
	icode == IOPL : ifun;
	1 : ALUADD;
];
#/* $end seq-alufun-hcl */

## Should the condition codes be updated?
#/* $begin seq-set_cc-hcl */
bool set_cc = icode in { IOPL };
#/* $end seq-set_cc-hcl */

################ Memory Stage    ###################################

## Set read control signal
#/* $begin seq-mem_read-hcl */
bool mem_read = icode in { IMRMOVL, IPOPL, IRET };
#/* $end seq-mem_read-hcl */

## Set write control signal
#/* $begin seq-mem_write-hcl */
bool mem_write = icode in { IRMMOVL, IPUSHL, ICALL };
#/* $end seq-mem_write-hcl */

## Select memory address
#/* $begin seq-mem_addr-hcl */
int mem_addr = [
	icode in { IRMMOVL, IPUSHL, ICALL, IMRMOVL } : valE;
	icode in { IPOPL, IRET } : valA;
	# Other instructions don't need address
];
#/* $end seq-mem_addr-hcl */

## Select memory input data
#/* $begin seq-mem_data-hcl */
int mem_data = [
	# Value from register
	icode in { IRMMOVL, IPUSHL } : valA;
	# Return PC
	icode == ICALL : valP;
	# Default: Don't write anything
];
#/* $end seq-mem_data-hcl */

#/* $begin seq-stat-hcl */
## Determine instruction status
int Stat = [
	imem_error || dmem_error : SADR;
	!instr_valid: SINS;
	icode == IHALT : SHLT;
	1 : SAOK;
];
#/* $end seq-stat-hcl */

################ Program Counter Update ############################

## What address should instruction be fetched at

#/* $begin seq-new_pc-hcl */
int new_pc = [
	# Call.  Use instruction constant
	icode == ICALL : valC;
	# Taken branch.  Use instruction constant
	icode == IJXX && Cnd : valC;
	# Completion of RET instruction.  Use value from stack
	icode == IRET : valM;
	# Default: Use incremented PC
	1 : valP;
];
#/* $end seq-new_pc-hcl */
#/* $end seq-all-hcl */
