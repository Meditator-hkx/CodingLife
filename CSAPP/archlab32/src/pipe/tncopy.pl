# #################################################################
# ncopy.ys - Copy a src block of len ints to dst.
# Return the number of positive ints (>0) contained in src.
# 
# Include your name and ID here.
# 
# Describe how and why you modified the baseline code.
# This code unrolls the main loop by a factor of 1.
# #################################################################

# Do not modify this portion
# Function prologue
ncopy:
	pushl %ebp              # Save old frame pointer
	rrmovl %esp,%ebp        # Set up new frame pointer
	pushl %esi              # Save callee-save regs
	pushl %ebx
	pushl %edi
	mrmovl 8(%ebp),%ebx     # src
	mrmovl 12(%ebp),%ecx    # dst
	mrmovl 16(%ebp),%edx    # len

# #################################################################
# You can modify this portion

	xorl %eax,%eax          # count = 0
	andl %edx,%edx          # Test len
	jle SkipLoop            # if <= 0, skip loop
# Main loop.  Copy 1 elements per iteration
Loop:
	mrmovl 0(%ebx), %esi    # read val from src+0
	rrmovl %eax, %edi       # Copy count
	iaddl $1, %edi          # count+1
	andl %esi, %esi         # Test val
	cmovg %edi, %eax        # If val > 0, count = count+1
	rmmovl %esi, 0(%ecx)    # Store val at dst+0
	iaddl $4, %ebx          # src+=1
	iaddl $4, %ecx          # dst+=1
	iaddl $-1, %edx         # len-=1
	jg Loop                 # if len > 0, goto Loop
SkipLoop:

# #################################################################

# Do not modify the following section of code
# Function epilogue
Done:
	popl %edi
	popl %ebx
	popl %esi
	rrmovl %ebp, %esp
	popl %ebp
	ret
# ##################################################################
# # Keep the following label at the end of your function
End:
