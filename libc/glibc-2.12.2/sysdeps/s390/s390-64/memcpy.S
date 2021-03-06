/* memcpy - copy a block from source to destination.  64 bit S/390 version.
   Copyright (C) 2000, 2001, 2003 Free Software Foundation, Inc.
   This file is part of the GNU C Library.
   Contributed by Martin Schwidefsky (schwidefsky@de.ibm.com).

   The GNU C Library is free software; you can redistribute it and/or
   modify it under the terms of the GNU Lesser General Public
   License as published by the Free Software Foundation; either
   version 2.1 of the License, or (at your option) any later version.

   The GNU C Library is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
   Lesser General Public License for more details.

   You should have received a copy of the GNU Lesser General Public
   License along with the GNU C Library; if not, write to the Free
   Software Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA
   02111-1307 USA.  */

/* INPUT PARAMETERS
     %r2 = address of destination memory area
     %r3 = address of source memory area
     %r4 = number of bytes to copy.  */

#include "sysdep.h"
#include "asm-syntax.h"

	.text
ENTRY(memcpy)
	ltgr	%r4,%r4
	jz	.L3
	aghi	%r4,-1		    # length - 1
	lgr	%r1,%r2		    # copy destination address
	srlg	%r5,%r4,8
	ltgr    %r5,%r5             # < 256 bytes to mvoe ?
	jz	.L1
	chi     %r5,255             # > 1 MB to move ?
	jh	.L4
.L0:	mvc	0(256,%r1),0(%r3)   # move in 256 byte chunks
	la	%r1,256(%r1)
	la	%r3,256(%r3)
	brctg	%r5,.L0
.L1:	bras	%r5,.L2		    # setup base pointer for execute
	mvc	0(1,%r1),0(%r3)	    # instruction for execute
.L2:	ex	%r4,0(%r5)	    # execute mvc with length ((%r4)&255)+1
.L3:	br	%r14
	# data copies > 1MB are faster with mvcle.
.L4:	aghi    %r4,1               # length + 1
	lgr	%r5,%r4	            # source length
	lgr	%r4,%r3             # source address
	lgr	%r3,%r5             # destination length = source length
.L5:	mvcle	%r2,%r4,0           # thats it, MVCLE is your friend
	jo	.L5
	lgr     %r2,%r1             # return destination address
	br	%r14
END(memcpy)
libc_hidden_builtin_def (memcpy)
