$c	This is the master version of the .hcl code for the pipeline.
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
$c	b: Broken pipeline.  Does not handle any hazards
$c	f: iaddl+leave problem
$c	F: iaddl+leave solution
$c	l: Load forward problem
$c	L: Load forward solution
$c	n: Branches not-taken problem
$c	N: Branches not-taken solution
$c	t: Backward taken, forward-not taken problem
$c	T: Backward taken, forward-not taken solution
$c	w: Single write port problem
$c	W: Single write port solution
$c	s: Stall-based pipeline control problem
$c	S: Stall-based pipeline control solution
#/* $begin pipe-all-hcl */
####################################################################
#    HCL Description of Control for Pipelined Y86 Processor        #
#    Copyright (C) Randal E. Bryant, David R. O'Hallaron, 2010     #
####################################################################
$fF	
$f	## Your task is to implement the iaddl and leave instructions
$f	## The file contains a declaration of the icodes
$f	## for iaddl (IIADDL) and leave (ILEAVE).
$f	## Your job is to add the rest of the logic to make it work
$F	## This is the solution for the iaddl and leave problems
$lL	
$l	## Your task is to implement load-forwarding, where a value
$l	## read from memory can be stored to memory by the immediately
$l	## following instruction without stalling
$l	## This requires modifying the definition of e_valA
$l	## and relaxing the stall conditions.  Relevant sections to change
$l	## are shown in comments containing the keyword "LB"
$L	## This is the solution to the load-forwarding problem
$nN	
$n	## Your task is to modify the design so that conditional branches are
$n	## predicted as being not-taken.  The code here is nearly identical
$n	## to that for the normal pipeline.  
$n	## Comments starting with keyword "BNT" have been added at places
$n	## relevant to the exercise.
$N	## This is the solution for the branches not-taken problem
$tT	
$t	## Your task is to modify the design so that conditional branches are
$t	## predicted as being taken when backward and not-taken when forward
$t	## The code here is nearly identical to that for the normal pipeline.  
$t	## Comments starting with keyword "BBTFNT" have been added at places
$t	## relevant to the exercise.
$T	## BBTFNT: This is the solution for the backward taken, forward
$T	## not-taken branch prediction problem
$wW	
$w	## Your task is to modify the design so that on any cycle, only
$w	## one of the two possible (valE and valM) register writes will occur.
$w	## This requires special handling of the popl instruction.
$W	## This is a solution to the single write port problem
$wW	## Overall strategy:  IPOPL passes through pipe, 
$wW	## treated as stack pointer increment, but not incrementing the PC
$wW	## On refetch, modify fetched icode to indicate an instruction "IPOP2",
$wW	## which reads from memory.
$w	## This requires modifying the definition of f_icode
$w	## and lots of other changes.  Relevant positions to change
$w	## are indicated by comments starting with keyword "1W".
$sS	
$s	## Your task is to make the pipeline work without using any forwarding
$s	## The normal bypassing logic in the file is disabled.
$s	## You can only change the pipeline control logic at the end of this file.
$s	## The trick is to make the pipeline stall whenever there is a data hazard.
$S	## This is the solution for the stall-based pipeline control problem.
$b	## This version does not detect or handle any hazards

####################################################################
#    C Include's.  Don't alter these                               #
####################################################################

quote '#include <stdio.h>'
quote '#include "isa.h"'
quote '#include "pipeline.h"'
quote '#include "stages.h"'
quote '#include "sim.h"'
quote 'int sim_main(int argc, char *argv[]);'
quote 'int main(int argc, char *argv[]){return sim_main(argc,argv);}'

####################################################################
#    Declarations.  Do not change/remove/delete any of these       #
####################################################################

$a	#/* $begin pipe-fetch-all-hcl */
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
$wW	# 1W: Special instruction code for second try of popl
$wW	intsig IPOP2	'I_POP2'

##### Symbolic represenations of Y86 function codes            #####
intsig FNONE    'F_NONE'        # Default function code

##### Symbolic representation of Y86 Registers referenced      #####
intsig RESP     'REG_ESP'    	     # Stack Pointer
$fF	intsig REBP     'REG_EBP'    	     # Frame Pointer
intsig RNONE    'REG_NONE'   	     # Special value indicating "no register"

##### ALU Functions referenced explicitly ##########################
intsig ALUADD	'A_ADD'		     # ALU should add its arguments
$nNtT
$nN	## BNT: For modified branch prediction, need to distinguish
$tT	## BBTFNT: For modified branch prediction, need to distinguish
$nNtT	## conditional vs. unconditional branches
$nNtT	##### Jump conditions referenced explicitly
$nNtT	intsig UNCOND 'C_YES'       	     # Unconditional transfer

##### Possible instruction status values                       #####
intsig SBUB	'STAT_BUB'	# Bubble in stage
intsig SAOK	'STAT_AOK'	# Normal execution
intsig SADR	'STAT_ADR'	# Invalid memory address
intsig SINS	'STAT_INS'	# Invalid instruction
intsig SHLT	'STAT_HLT'	# Halt instruction encountered

##### Signals that can be referenced by control logic ##############

##### Pipeline Register F ##########################################

intsig F_predPC 'pc_curr->pc'	     # Predicted value of PC

##### Intermediate Values in Fetch Stage ###########################

intsig imem_icode  'imem_icode'      # icode field from instruction memory
intsig imem_ifun   'imem_ifun'       # ifun  field from instruction memory
intsig f_icode	'if_id_next->icode'  # (Possibly modified) instruction code
intsig f_ifun	'if_id_next->ifun'   # Fetched instruction function
intsig f_valC	'if_id_next->valc'   # Constant data of fetched instruction
intsig f_valP	'if_id_next->valp'   # Address of following instruction
$wW	## 1W: Provide access to the PC value for the current instruction
$wW	intsig f_pc	'f_pc'               # Address of fetched instruction
boolsig imem_error 'imem_error'	     # Error signal from instruction memory
boolsig instr_valid 'instr_valid'    # Is fetched instruction valid?

##### Pipeline Register D ##########################################
intsig D_icode 'if_id_curr->icode'   # Instruction code
intsig D_rA 'if_id_curr->ra'	     # rA field from instruction
intsig D_rB 'if_id_curr->rb'	     # rB field from instruction
intsig D_valP 'if_id_curr->valp'     # Incremented PC

##### Intermediate Values in Decode Stage  #########################

intsig d_srcA	 'id_ex_next->srca'  # srcA from decoded instruction
intsig d_srcB	 'id_ex_next->srcb'  # srcB from decoded instruction
intsig d_rvalA 'd_regvala'	     # valA read from register file
intsig d_rvalB 'd_regvalb'	     # valB read from register file

##### Pipeline Register E ##########################################
intsig E_icode 'id_ex_curr->icode'   # Instruction code
intsig E_ifun  'id_ex_curr->ifun'    # Instruction function
intsig E_valC  'id_ex_curr->valc'    # Constant data
intsig E_srcA  'id_ex_curr->srca'    # Source A register ID
intsig E_valA  'id_ex_curr->vala'    # Source A value
intsig E_srcB  'id_ex_curr->srcb'    # Source B register ID
intsig E_valB  'id_ex_curr->valb'    # Source B value
intsig E_dstE 'id_ex_curr->deste'    # Destination E register ID
intsig E_dstM 'id_ex_curr->destm'    # Destination M register ID

##### Intermediate Values in Execute Stage #########################
intsig e_valE 'ex_mem_next->vale'	# valE generated by ALU
boolsig e_Cnd 'ex_mem_next->takebranch' # Does condition hold?
intsig e_dstE 'ex_mem_next->deste'      # dstE (possibly modified to be RNONE)

##### Pipeline Register M                  #########################
intsig M_stat 'ex_mem_curr->status'     # Instruction status
intsig M_icode 'ex_mem_curr->icode'	# Instruction code
intsig M_ifun  'ex_mem_curr->ifun'	# Instruction function
intsig M_valA  'ex_mem_curr->vala'      # Source A value
intsig M_dstE 'ex_mem_curr->deste'	# Destination E register ID
intsig M_valE  'ex_mem_curr->vale'      # ALU E value
intsig M_dstM 'ex_mem_curr->destm'	# Destination M register ID
boolsig M_Cnd 'ex_mem_curr->takebranch'	# Condition flag
boolsig dmem_error 'dmem_error'	        # Error signal from instruction memory
$lL	## LF: Carry srcA up to pipeline register M
$lL	intsig M_srcA 'ex_mem_curr->srca'	# Source A register ID

##### Intermediate Values in Memory Stage ##########################
intsig m_valM 'mem_wb_next->valm'	# valM generated by memory
intsig m_stat 'mem_wb_next->status'	# stat (possibly modified to be SADR)

##### Pipeline Register W ##########################################
intsig W_stat 'mem_wb_curr->status'     # Instruction status
intsig W_icode 'mem_wb_curr->icode'	# Instruction code
intsig W_dstE 'mem_wb_curr->deste'	# Destination E register ID
intsig W_valE  'mem_wb_curr->vale'      # ALU E value
intsig W_dstM 'mem_wb_curr->destm'	# Destination M register ID
intsig W_valM  'mem_wb_curr->valm'	# Memory M value

####################################################################
#    Control Signal Definitions.                                   #
####################################################################

################ Fetch Stage     ###################################

$a	#/* $begin pipe-fetch-logic-hcl */
## What address should instruction be fetched at
$a	#/* $begin pipe-f_pc-hcl */
int f_pc = [
	# Mispredicted branch.  Fetch at incremented PC
$!NT		M_icode == IJXX && !M_Cnd : M_valA;
$N		# BNT: Changed misprediction condition
$N		M_icode == IJXX && M_ifun != UNCOND && M_Cnd : M_valE;
$T		# BBTFNT: Mispredicted forward branch.  Fetch at target (now in valE)
$T	        M_icode == IJXX && M_ifun != UNCOND && M_valE >= M_valA
$T	   	   && M_Cnd : M_valE;
$T		# BBTFNT: Mispredicted backward branch.
$T		#    Fetch at incremented PC (now in valE)
$T	 	M_icode == IJXX && M_ifun != UNCOND && M_valE < M_valA
$T		  && !M_Cnd : M_valA;
	# Completion of RET instruction.
	W_icode == IRET : W_valM;
	# Default: Use predicted value of PC
	1 : F_predPC;
];
$a	#/* $end pipe-f_pc-hcl */

## Determine icode of fetched instruction
$wW	## 1W: To split ipopl into two cycles, need to be able to 
$wW	## modify value of icode,
$wW	## so that it will be IPOP2 when fetched for second time.
int f_icode = [
	imem_error : INOP;
$W		## Can detected refetch of ipopl, since now have
$W		## IPOPL as icode for instruction in decode.
$W		imem_icode == IPOPL && D_icode == IPOPL : IPOP2;
	1: imem_icode;
];

# Determine ifun
int f_ifun = [
	imem_error : FNONE;
	1: imem_ifun;
];

# Is instruction valid?
bool instr_valid = f_icode in 
	{ INOP, IHALT, IRRMOVL, IIRMOVL, IRMMOVL, IMRMOVL,
$!FW		  IOPL, IJXX, ICALL, IRET, IPUSHL, IPOPL };
$F		  IOPL, IJXX, ICALL, IRET, IPUSHL, IPOPL, IIADDL, ILEAVE };
$W		  IOPL, IJXX, ICALL, IRET, IPUSHL, IPOPL, IPOP2 };

$a	#/* $begin pipe-f_stat-hcl */
# Determine status code for fetched instruction
int f_stat = [
	imem_error: SADR;
	!instr_valid : SINS;
	f_icode == IHALT : SHLT;
	1 : SAOK;
];
$a	#/* $end pipe-f_stat-hcl */

# Does fetched instruction require a regid byte?
bool need_regids =
	f_icode in { IRRMOVL, IOPL, IPUSHL, IPOPL, 
$W			     IPOP2,
$!F			     IIRMOVL, IRMMOVL, IMRMOVL };
$F			     IIRMOVL, IRMMOVL, IMRMOVL, IIADDL };

# Does fetched instruction require a constant word?
bool need_valC =
$!F		f_icode in { IIRMOVL, IRMMOVL, IMRMOVL, IJXX, ICALL };
$F		f_icode in { IIRMOVL, IRMMOVL, IMRMOVL, IJXX, ICALL, IIADDL };

# Predict next value of PC
$a	#/* $begin pipe-f_predPC-hcl */
int f_predPC = [
$n		# BNT: This is where you'll change the branch prediction rule
$t		# BBTFNT: This is where you'll change the branch prediction rule
$!TN		f_icode in { IJXX, ICALL } : f_valC;
$N		# BNT: Revised branch prediction rule:
$N		#   Unconditional branch is taken, others not taken
$N		f_icode == IJXX && f_ifun == UNCOND : f_valC;
$NT		f_icode in { ICALL } : f_valC;
$T		f_icode == IJXX && f_ifun == UNCOND : f_valC; # Unconditional branch
$T		f_icode == IJXX && f_valC < f_valP : f_valC; # Backward branch
$Ww		## 1W: Want to refetch popl one time
$W		# (on second time f_icode will be IPOP2). Refetch popl
$W		f_icode == IPOPL : f_pc;  
$T		# BBTFNT: Forward conditional branches will default to valP
	1 : f_valP;
];
$a	#/* $end pipe-f_predPC-hcl */
$a	#/* $end pipe-fetch-logic-hcl */
$a	#/* $end pipe-fetch-all-hcl */

################ Decode Stage ######################################

$wW	## W1: Strategy.  Decoding of popl rA should be treated the same
$wW	## as would iaddl $4, %esp
$wW	## Decoding of pop2 rA treated same as mrmovl -4(%esp), rA

## What register should be used as the A source?
$a	#/* $begin pipe-d_srcA-hcl */
int d_srcA = [
	D_icode in { IRRMOVL, IRMMOVL, IOPL, IPUSHL  } : D_rA;
	D_icode in { IPOPL, IRET } : RESP;
$F		D_icode in { ILEAVE } : REBP;
	1 : RNONE; # Don't need register
];
$a	#/* $end pipe-d_srcA-hcl */

## What register should be used as the B source?
int d_srcB = [
$!F		D_icode in { IOPL, IRMMOVL, IMRMOVL  } : D_rB;
$F		D_icode in { IOPL, IRMMOVL, IMRMOVL, IIADDL  } : D_rB;
$!W		D_icode in { IPUSHL, IPOPL, ICALL, IRET } : RESP;
$W		D_icode in { IPUSHL, IPOPL, ICALL, IRET, IPOP2 } : RESP;
$F		D_icode in { ILEAVE } : REBP;
	1 : RNONE;  # Don't need register
];

## What register should be used as the E destination?
$a	#/* $begin pipe-d_dstE-hcl */
int d_dstE = [
$!F		D_icode in { IRRMOVL, IIRMOVL, IOPL} : D_rB;
$F		D_icode in { IRRMOVL, IIRMOVL, IOPL, IIADDL } : D_rB;
$!F		D_icode in { IPUSHL, IPOPL, ICALL, IRET } : RESP;
$F		D_icode in { IPUSHL, IPOPL, ICALL, IRET, ILEAVE } : RESP;
	1 : RNONE;  # Don't write any register
];
$a	#/* $end pipe-d_dstE-hcl */

## What register should be used as the M destination?
int d_dstM = [
$!W		D_icode in { IMRMOVL, IPOPL } : D_rA;
$W		D_icode in { IMRMOVL, IPOP2 } : D_rA;
$F		D_icode in { ILEAVE } : REBP;
	1 : RNONE;  # Don't write any register
];

## What should be the A value?
$!bsS	## Forward into decode stage for valA
$a	#/* $begin pipe-nobypass-hcl */
$a	#/* $begin pipe-d_valA-hcl */
$sS	##  DO NOT MODIFY THE FOLLOWING CODE.
$bsS	## No forwarding.  valA is either valP or value from register file
int d_valA = [
	D_icode in { ICALL, IJXX } : D_valP; # Use incremented PC
$!bsS		d_srcA == e_dstE : e_valE;    # Forward valE from execute
$!bsS		d_srcA == M_dstM : m_valM;    # Forward valM from memory
$!bsS		d_srcA == M_dstE : M_valE;    # Forward valE from memory
$!bsS		d_srcA == W_dstM : W_valM;    # Forward valM from write back
$!bsS		d_srcA == W_dstE : W_valE;    # Forward valE from write back
	1 : d_rvalA;  # Use value read from register file
];
$a	#/* $end pipe-d_valA-hcl */

$!bsS## Forward into decode stage for valB
$a	#/* $begin pipe-d_valB-hcl */
$!bsS	int d_valB = [
$!bsS		d_srcB == e_dstE : e_valE;    # Forward valE from execute
$!bsS		d_srcB == M_dstM : m_valM;    # Forward valM from memory
$!bsS		d_srcB == M_dstE : M_valE;    # Forward valE from memory
$!bsS		d_srcB == W_dstM : W_valM;    # Forward valM from write back
$!bsS		d_srcB == W_dstE : W_valE;    # Forward valE from write back
$!bsS		1 : d_rvalB;  # Use value read from register file
$!bsS	];
$bsS	## No forwarding.  valB is value from register file
$bsS	int d_valB = d_rvalB;
$a	#/* $end pipe-d_valB-hcl */
$a	#/* $end pipe-nobypass-hcl */

################ Execute Stage #####################################
$nNtT	
$nN	# BNT: When some branches are predicted as not-taken, you need some
$tT	# BBTFNT: When some branches are predicted as not-taken, you need some
$ntNT	# way to get valC into pipeline register M, so that
$ntNT	# you can correct for a mispredicted branch.
$NT	# One way to do this is to run valC through the ALU, adding 0
$NT	# so that valC will end up in M_valE

## Select input A to ALU
int aluA = [
	E_icode in { IRRMOVL, IOPL } : E_valA;
$!FNT		E_icode in { IIRMOVL, IRMMOVL, IMRMOVL } : E_valC;
$F		E_icode in { IIRMOVL, IRMMOVL, IMRMOVL, IIADDL } : E_valC;
$N		# BNT: Use ALU to pass E_valC to M_valE
$T		# BBTFNT: Use ALU to pass E_valC to M_valE
$NT		E_icode in { IIRMOVL, IRMMOVL, IMRMOVL, IJXX } : E_valC;
$!W		E_icode in { ICALL, IPUSHL } : -4;
$W		E_icode in { ICALL, IPUSHL, IPOP2 } : -4;
$!F		E_icode in { IRET, IPOPL } : 4;
$F		E_icode in { IRET, IPOPL, ILEAVE } : 4;
	# Other instructions don't need ALU
];

## Select input B to ALU
int aluB = [
	E_icode in { IRMMOVL, IMRMOVL, IOPL, ICALL, 
$!FW			     IPUSHL, IRET, IPOPL } : E_valB;
$F			     IPUSHL, IRET, IPOPL, IIADDL, ILEAVE } : E_valB;
$W			     IPUSHL, IRET, IPOPL, IPOP2 } : E_valB;
$N		# BNT: Add 0 to valC
$T		# BBTFNT: Add 0 to valC
$!NT		E_icode in { IRRMOVL, IIRMOVL } : 0;
$NT		E_icode in { IRRMOVL, IIRMOVL, IJXX } : 0;
	# Other instructions don't need ALU
];

## Set the ALU function
int alufun = [
	E_icode == IOPL : E_ifun;
	1 : ALUADD;
];

$a	#/* $begin pipe-set_cc-hcl */
## Should the condition codes be updated?
$!F	bool set_cc = E_icode == IOPL &&
$F	bool set_cc = E_icode in { IOPL, IIADDL } &&
	# State changes only during normal operation
	!m_stat in { SADR, SINS, SHLT } && !W_stat in { SADR, SINS, SHLT };
$a	#/* $end pipe-set_cc-hcl */

## Generate valA in execute stage
$!lL	int e_valA = E_valA;    # Pass valA through stage
$lL	## LB: With load forwarding, want to insert valM 
$lL	##   from memory stage when appropriate
$l	## Here it is set to the default used in the normal pipeline
$Ll	int e_valA = [
$L		# Forwarding Condition
$L		M_dstM == E_srcA && E_icode in { IPUSHL, IRMMOVL } : m_valM;
$lL		1 : E_valA;  # Use valA from stage pipe register
$lL	];

$a	/* $begin pipe-e_dstE-hcl */
## Set dstE to RNONE in event of not-taken conditional move
int e_dstE = [
	E_icode == IRRMOVL && !e_Cnd : RNONE;
	1 : E_dstE;
];
$a	/* $end pipe-e_dstE-hcl */

################ Memory Stage ######################################

## Select memory address
int mem_addr = [
$!W		M_icode in { IRMMOVL, IPUSHL, ICALL, IMRMOVL } : M_valE;
$W		M_icode in { IRMMOVL, IPUSHL, ICALL, IMRMOVL, IPOP2 } : M_valE;
$!FW		M_icode in { IPOPL, IRET } : M_valA;
$F		M_icode in { IPOPL, IRET, ILEAVE } : M_valA;
$W		M_icode in { IRET } : M_valA;
	# Other instructions don't need address
];

## Set read control signal
$!FW	bool mem_read = M_icode in { IMRMOVL, IPOPL, IRET };
$F	bool mem_read = M_icode in { IMRMOVL, IPOPL, IRET, ILEAVE };
$W	bool mem_read = M_icode in { IMRMOVL, IPOP2, IRET };

## Set write control signal
bool mem_write = M_icode in { IRMMOVL, IPUSHL, ICALL };

#/* $begin pipe-m_stat-hcl */
## Update the status
int m_stat = [
	dmem_error : SADR;
	1 : M_stat;
];
#/* $end pipe-m_stat-hcl */

$wW	################ Write back stage ##################################
$wW	
$wW	## 1W: For this problem, we introduce a multiplexor that merges
$wW	## valE and valM into a single value for writing to register port E.
$wW	## DO NOT CHANGE THIS LOGIC
$wW
$wW	## Merge both write back sources onto register port E 
$a	/* $begin pipe-1w-wbe-hcl */
## Set E port register ID
$!wW	int w_dstE = W_dstE;
$wW	int w_dstE = [
$wW		## writing from valM
$wW		W_dstM != RNONE : W_dstM;
$wW		1: W_dstE;
$wW	];

## Set E port value
$!wW	int w_valE = W_valE;
$wW	int w_valE = [
$wW		W_dstM != RNONE : W_valM;
$wW		1: W_valE;
$wW	];
$a	/* $end pipe-1w-wbe-hcl */

$a	/* $begin pipe-1w-wbm-hcl */
$wW	## Disable register port M
## Set M port register ID
$!wW	int w_dstM = W_dstM;
$wW	int w_dstM = RNONE;

## Set M port value
$!wW	int w_valM = W_valM;
$wW	int w_valM = 0;
$a	/* $end pipe-1w-wbm-hcl */

## Update processor status
$a	#/* $begin pipe-Stat-hcl */
int Stat = [
	W_stat == SBUB : SAOK;
	1 : W_stat;
];
$a	#/* $end pipe-Stat-hcl */

################ Pipeline Register Control #########################

$S	#/* $begin pipe-nobypass-cntl-hcl */
# Should I stall or inject a bubble into Pipeline Register F?
# At most one of these can be true.
bool F_bubble = 0;
$a	#/* $begin pipe-F-cntl-hcl */
bool F_stall =
$b		0;
$!bsS		# Conditions for a load/use hazard
$l		## Set this to the new load/use condition
$l		0 ||
$!FlLWbsS		E_icode in { IMRMOVL, IPOPL } &&
$F		E_icode in { IMRMOVL, IPOPL, ILEAVE } &&
$L		E_icode in { IMRMOVL, IPOPL } &&
$L		 (E_dstM == d_srcB ||
$L	          (E_dstM == d_srcA && !D_icode in { IRMMOVL, IPUSHL })) ||
$W		E_icode in { IMRMOVL, IPOP2 } &&
$!lLbsS		 E_dstM in { d_srcA, d_srcB } ||
$s		# Modify the following to stall the update of pipeline register F
$s		0 ||
$S		# Stall if either operand source is destination of 
$S		# instruction in execute, memory, or write-back stages
$S		d_srcA != RNONE && d_srcA in 
$S		  { E_dstM, e_dstE, M_dstM, M_dstE, W_dstM, W_dstE } ||
$S		d_srcB != RNONE && d_srcB in 
$S		  { E_dstM, e_dstE, M_dstM, M_dstE, W_dstM, W_dstE } ||
$!b		# Stalling at fetch while ret passes through pipeline
$!b		IRET in { D_icode, E_icode, M_icode };
$a	#/* $end pipe-F-cntl-hcl */

# Should I stall or inject a bubble into Pipeline Register D?
# At most one of these can be true.
$a	#/* $begin pipe-D-stall-hcl */
bool D_stall = 
$b		0;
$!bsS		# Conditions for a load/use hazard
$l		## Set this to the new load/use condition
$l		0; 
$!lFBWbsS		E_icode in { IMRMOVL, IPOPL } &&
$F		E_icode in { IMRMOVL, IPOPL, ILEAVE } &&
$L		E_icode in { IMRMOVL, IPOPL } &&
$L		 (E_dstM == d_srcB ||
$L	          (E_dstM == d_srcA && !D_icode in { IRMMOVL, IPUSHL }));
$W		E_icode in { IMRMOVL, IPOP2 } &&
$!bsSlL		 E_dstM in { d_srcA, d_srcB };
$s		# Modify the following to stall the instruction in decode
$s		0;
$S		# Stall if either operand source is destination of 
$S		# instruction in execute, memory, or write-back stages
$S		# but not part of mispredicted branch
$S		!(E_icode == IJXX && !e_Cnd) &&
$S		 (d_srcA != RNONE && d_srcA in 
$S		    { E_dstM, e_dstE, M_dstM, M_dstE, W_dstM, W_dstE } ||
$S		  d_srcB != RNONE && d_srcB in 
$S		    { E_dstM, e_dstE, M_dstM, M_dstE, W_dstM, W_dstE });
$a	#/* $end pipe-D-stall-hcl */

$a	#/* $begin pipe-D-bubble-hcl */
bool D_bubble =
$b		0;
$!b		# Mispredicted branch
$N		# BNT: Changed misprediction condition
$!bNT		(E_icode == IJXX && !e_Cnd) ||
$N		(E_icode == IJXX && E_ifun != UNCOND && e_Cnd) ||
$t		# BBTFNT: This condition will change
$T		# BBTFNT: Changed misprediction condition
$T		(E_icode == IJXX && E_ifun != UNCOND &&
$T	          (E_valC < E_valA && !e_Cnd || E_valC >= E_valA && e_Cnd)) ||
$!b		# Stalling at fetch while ret passes through pipeline
$!bsS		# but not condition for a load/use hazard
$!bFW		!(E_icode in { IMRMOVL, IPOPL } && E_dstM in { d_srcA, d_srcB }) &&
$w		# 1W: This condition will change
$W		# 1W: Changed Load/Use condition
$W		!(E_icode in { IMRMOVL, IPOP2 } && E_dstM in { d_srcA, d_srcB }) &&
$F		!(E_icode in { IMRMOVL, IPOPL, ILEAVE } && E_dstM in { d_srcA, d_srcB }) &&
$sS		# but not condition for a generate/use hazard
$s		!0 &&
$S		!(d_srcA != RNONE && d_srcA in 
$S		   { E_dstM, e_dstE, M_dstM, M_dstE, W_dstM, W_dstE } ||
$S		  d_srcB != RNONE && d_srcB in 
$S		   { E_dstM, e_dstE, M_dstM, M_dstE, W_dstM, W_dstE }) &&
$!b		  IRET in { D_icode, E_icode, M_icode };
$a	#/* $end pipe-D-bubble-hcl */

# Should I stall or inject a bubble into Pipeline Register E?
# At most one of these can be true.
bool E_stall = 0;
$a	#/* $begin pipe-E-bubble-hcl */
bool E_bubble =
$b		0;
$!b		# Mispredicted branch
$N		# BNT: Changed misprediction condition
$!bNT		(E_icode == IJXX && !e_Cnd) ||
$N		(E_icode == IJXX && E_ifun != UNCOND && e_Cnd) ||
$t		# BBTFNT: This condition will change
$T		# BBTFNT: Changed misprediction condition
$T		(E_icode == IJXX && E_ifun != UNCOND &&
$T	          (E_valC < E_valA && !e_Cnd || E_valC >= E_valA && e_Cnd)) ||
$!bsS		# Conditions for a load/use hazard
$l		## Set this to the new load/use condition
$l		0;
$!FlLWbsS		E_icode in { IMRMOVL, IPOPL } &&
$F		E_icode in { IMRMOVL, IPOPL, ILEAVE } &&
$L		E_icode in { IMRMOVL, IPOPL } &&
$L		 (E_dstM == d_srcB ||
$L	          (E_dstM == d_srcA && !D_icode in { IRMMOVL, IPUSHL }));
$W		E_icode in { IMRMOVL, IPOP2 } &&
$!lLbsS		 E_dstM in { d_srcA, d_srcB};
$s		# Modify the following to inject bubble into the execute stage
$s		0;
$S		  # Inject bubble if either operand source is destination of 
$S		  # instruction in execute, memory, or write back stages
$S		  d_srcA != RNONE && 
$S		    d_srcA in { E_dstM, e_dstE, M_dstM, M_dstE, W_dstM, W_dstE } ||
$S		  d_srcB != RNONE && 
$S		    d_srcB in { E_dstM, e_dstE, M_dstM, M_dstE, W_dstM, W_dstE };
$a	#/* $end pipe-E-bubble-hcl */

# Should I stall or inject a bubble into Pipeline Register M?
# At most one of these can be true.
bool M_stall = 0;
$a	#/* $begin pipe-M-bubble-hcl */
# Start injecting bubbles as soon as exception passes through memory stage
bool M_bubble = m_stat in { SADR, SINS, SHLT } || W_stat in { SADR, SINS, SHLT };
$a	#/* $end pipe-M-bubble-hcl */

# Should I stall or inject a bubble into Pipeline Register W?
$a	#/* $begin pipe-W-stall-hcl */
bool W_stall = W_stat in { SADR, SINS, SHLT };
$a	#/* $end pipe-W-stall-hcl */
bool W_bubble = 0;
$S	#/* $end pipe-nobypass-cntl-hcl */
$a	#/* $end pipe--hcl */
#/* $end pipe-all-hcl */
