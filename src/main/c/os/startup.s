#	.sh
	.section .text
	.global	_start
#	.type	_start,@function
_start:
#    la      gp,_gp
    la      sp,_stack
	
    la      x8,main
    jalr    x8

loop:
    j       loop
    nop
