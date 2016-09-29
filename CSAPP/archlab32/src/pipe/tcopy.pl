# #################################################################
# ncopy.ys - Copy a src block of len ints to dst.
# Return the number of positive ints (>0) contained in src.
# 
# Include your name and ID here.
# 
# Describe how and why you modified the baseline code.
# This code unrolls the main loop by a factor of 16.
# It finishes by jumping to the appropriate position in a code
# sequence that copies the possible remaining elements
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
	irmovl $15, %edi        # Mask for residue
	andl %edx, %edi         # residue = cnt mod 16
	irmovl $16, %esi
	subl %edi, %esi         # a = 16 - residue
# Back up starting point of copy by a (between 1 and 16)
	addl %esi, %edx         # Increase len by a
	addl %esi, %esi         # 2a
	addl %esi, %esi         # 4a
	subl %esi, %ebx         # src-a
	subl %esi, %ecx         # dst-a
# Compute offset into loop code by 24a
	addl %esi, %esi         # 8a
	rrmovl %esi, %edi       # 8a
	addl %edi, %edi         # 16a
	addl %edi, %esi         # 24a
	iaddl Loop, %esi        # Starting position for first loop
	pushl %esi
	ret                     # Jump to starting position
# Main loop.  Copy 16 elements per iteration
Loop:
Copied0:
	mrmovl 0(%ebx), %esi    # read val from src+0
	rrmovl %eax, %edi       # Copy count
	iaddl $1, %edi          # count+1
	andl %esi, %esi         # Test val
	cmovg %edi, %eax        # If val > 0, count = count+1
	rmmovl %esi, 0(%ecx)    # Store val at dst+0
Copied1:
	mrmovl 4(%ebx), %esi    # read val from src+1
	rrmovl %eax, %edi       # Copy count
	iaddl $1, %edi          # count+1
	andl %esi, %esi         # Test val
	cmovg %edi, %eax        # If val > 0, count = count+1
	rmmovl %esi, 4(%ecx)    # Store val at dst+1
Copied2:
	mrmovl 8(%ebx), %esi    # read val from src+2
	rrmovl %eax, %edi       # Copy count
	iaddl $1, %edi          # count+1
	andl %esi, %esi         # Test val
	cmovg %edi, %eax        # If val > 0, count = count+1
	rmmovl %esi, 8(%ecx)    # Store val at dst+2
Copied3:
	mrmovl 12(%ebx), %esi   # read val from src+3
	rrmovl %eax, %edi       # Copy count
	iaddl $1, %edi          # count+1
	andl %esi, %esi         # Test val
	cmovg %edi, %eax        # If val > 0, count = count+1
	rmmovl %esi, 12(%ecx)   # Store val at dst+3
Copied4:
	mrmovl 16(%ebx), %esi   # read val from src+4
	rrmovl %eax, %edi       # Copy count
	iaddl $1, %edi          # count+1
	andl %esi, %esi         # Test val
	cmovg %edi, %eax        # If val > 0, count = count+1
	rmmovl %esi, 16(%ecx)   # Store val at dst+4
Copied5:
	mrmovl 20(%ebx), %esi   # read val from src+5
	rrmovl %eax, %edi       # Copy count
	iaddl $1, %edi          # count+1
	andl %esi, %esi         # Test val
	cmovg %edi, %eax        # If val > 0, count = count+1
	rmmovl %esi, 20(%ecx)   # Store val at dst+5
Copied6:
	mrmovl 24(%ebx), %esi   # read val from src+6
	rrmovl %eax, %edi       # Copy count
	iaddl $1, %edi          # count+1
	andl %esi, %esi         # Test val
	cmovg %edi, %eax        # If val > 0, count = count+1
	rmmovl %esi, 24(%ecx)   # Store val at dst+6
Copied7:
	mrmovl 28(%ebx), %esi   # read val from src+7
	rrmovl %eax, %edi       # Copy count
	iaddl $1, %edi          # count+1
	andl %esi, %esi         # Test val
	cmovg %edi, %eax        # If val > 0, count = count+1
	rmmovl %esi, 28(%ecx)   # Store val at dst+7
Copied8:
	mrmovl 32(%ebx), %esi   # read val from src+8
	rrmovl %eax, %edi       # Copy count
	iaddl $1, %edi          # count+1
	andl %esi, %esi         # Test val
	cmovg %edi, %eax        # If val > 0, count = count+1
	rmmovl %esi, 32(%ecx)   # Store val at dst+8
Copied9:
	mrmovl 36(%ebx), %esi   # read val from src+9
	rrmovl %eax, %edi       # Copy count
	iaddl $1, %edi          # count+1
	andl %esi, %esi         # Test val
	cmovg %edi, %eax        # If val > 0, count = count+1
	rmmovl %esi, 36(%ecx)   # Store val at dst+9
Copied10:
	mrmovl 40(%ebx), %esi   # read val from src+10
	rrmovl %eax, %edi       # Copy count
	iaddl $1, %edi          # count+1
	andl %esi, %esi         # Test val
	cmovg %edi, %eax        # If val > 0, count = count+1
	rmmovl %esi, 40(%ecx)   # Store val at dst+10
Copied11:
	mrmovl 44(%ebx), %esi   # read val from src+11
	rrmovl %eax, %edi       # Copy count
	iaddl $1, %edi          # count+1
	andl %esi, %esi         # Test val
	cmovg %edi, %eax        # If val > 0, count = count+1
	rmmovl %esi, 44(%ecx)   # Store val at dst+11
Copied12:
	mrmovl 48(%ebx), %esi   # read val from src+12
	rrmovl %eax, %edi       # Copy count
	iaddl $1, %edi          # count+1
	andl %esi, %esi         # Test val
	cmovg %edi, %eax        # If val > 0, count = count+1
	rmmovl %esi, 48(%ecx)   # Store val at dst+12
Copied13:
	mrmovl 52(%ebx), %esi   # read val from src+13
	rrmovl %eax, %edi       # Copy count
	iaddl $1, %edi          # count+1
	andl %esi, %esi         # Test val
	cmovg %edi, %eax        # If val > 0, count = count+1
	rmmovl %esi, 52(%ecx)   # Store val at dst+13
Copied14:
	mrmovl 56(%ebx), %esi   # read val from src+14
	rrmovl %eax, %edi       # Copy count
	iaddl $1, %edi          # count+1
	andl %esi, %esi         # Test val
	cmovg %edi, %eax        # If val > 0, count = count+1
	rmmovl %esi, 56(%ecx)   # Store val at dst+14
Copied15:
	mrmovl 60(%ebx), %esi   # read val from src+15
	rrmovl %eax, %edi       # Copy count
	iaddl $1, %edi          # count+1
	andl %esi, %esi         # Test val
	cmovg %edi, %eax        # If val > 0, count = count+1
	rmmovl %esi, 60(%ecx)   # Store val at dst+15
Copied16:
	iaddl $64, %ebx         # src+=16
	iaddl $64, %ecx         # dst+=16
	iaddl $-16, %edx        # cnt-=16
	jg Loop                 # if cnt > 0, goto Loop

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
