/* 
 * CS:APP Data Lab 
 * 
 * <Please put your name and userid here>
 * 
 * bits.c - Source file with your solutions to the Lab.
 *          This is the file you will hand in to your instructor.
 *
 * WARNING: Do not include the <stdio.h> header; it confuses the dlc
 * compiler. You can still use printf for debugging without including
 * <stdio.h>, although you might get a compiler warning. In general,
 * it's not good practice to ignore compiler warnings, but in this
 * case it's OK.  
 */

#if 0
/*
 * Instructions to Students:
 *
 * STEP 1: Read the following instructions carefully.
 */

You will provide your solution to the Data Lab by
editing the collection of functions in this source file.

INTEGER CODING RULES:
 
  Replace the "return" statement in each function with one
  or more lines of C code that implements the function. Your code 
  must conform to the following style:
 
  int Funct(arg1, arg2, ...) {
      /* brief description of how your implementation works */
      int var1 = Expr1;
      ...
      int varM = ExprM;

      varJ = ExprJ;
      ...
      varN = ExprN;
      return ExprR;
  }

  Each "Expr" is an expression using ONLY the following:
  1. Integer constants 0 through 255 (0xFF), inclusive. You are
      not allowed to use big constants such as 0xffffffff.
  2. Function arguments and local variables (no global variables).
  3. Unary integer operations ! ~
  4. Binary integer operations & ^ | + << >>
    
  Some of the problems restrict the set of allowed operators even further.
  Each "Expr" may consist of multiple operators. You are not restricted to
  one operator per line.

  You are expressly forbidden to:
  1. Use any control constructs such as if, do, while, for, switch, etc.
  2. Define or use any macros.
  3. Define any additional functions in this file.
  4. Call any functions.
  5. Use any other operations, such as &&, ||, -, or ?:
  6. Use any form of casting.
  7. Use any data type other than int.  This implies that you
     cannot use arrays, structs, or unions.

 
  You may assume that your machine:
  1. Uses 2s complement, 32-bit representations of integers.
  2. Performs right shifts arithmetically.
  3. Has unpredictable behavior when shifting an integer by more
     than the word size.

EXAMPLES OF ACCEPTABLE CODING STYLE:
  /*
   * pow2plus1 - returns 2^x + 1, where 0 <= x <= 31
   */
  int pow2plus1(int x) {
     /* exploit ability of shifts to compute powers of 2 */
     return (1 << x) + 1;
  }

  /*
   * pow2plus4 - returns 2^x + 4, where 0 <= x <= 31
   */
  int pow2plus4(int x) {
     /* exploit ability of shifts to compute powers of 2 */
     int result = (1 << x);
     result += 4;
     return result;
  }

FLOATING POINT CODING RULES

For the problems that require you to implent floating-point operations,
the coding rules are less strict.  You are allowed to use looping and
conditional control.  You are allowed to use both ints and unsigneds.
You can use arbitrary integer and unsigned constants.

You are expressly forbidden to:
  1. Define or use any macros.
  2. Define any additional functions in this file.
  3. Call any functions.
  4. Use any form of casting.
  5. Use any data type other than int or unsigned.  This means that you
     cannot use arrays, structs, or unions.
  6. Use any floating point data types, operations, or constants.


NOTES:
  1. Use the dlc (data lab checker) compiler (described in the handout) to 
     check the legality of your solutions.
  2. Each function has a maximum number of operators (! ~ & ^ | + << >>)
     that you are allowed to use for your implementation of the function. 
     The max operator count is checked by dlc. Note that '=' is not 
     counted; you may use as many of these as you want without penalty.
  3. Use the btest test harness to check your functions for correctness.
  4. Use the BDD checker to formally verify your functions
  5. The maximum number of ops for each function is given in the
     header comment for each function. If there are any inconsistencies 
     between the maximum ops in the writeup and in this file, consider
     this file the authoritative source.

/*
 * STEP 2: Modify the following functions according the coding rules.
 * 
 *   IMPORTANT. TO AVOID GRADING SURPRISES:
 *   1. Use the dlc compiler to check that your solutions conform
 *      to the coding rules.
 *   2. Use the BDD checker to formally verify that your solutions produce 
 *      the correct answers.
 */


#endif
/* Copyright (C) 1991-2012 Free Software Foundation, Inc.
   This file is part of the GNU C Library.

   The GNU C Library is free software; you can redistribute it and/or
   modify it under the terms of the GNU Lesser General Public
   License as published by the Free Software Foundation; either
   version 2.1 of the License, or (at your option) any later version.

   The GNU C Library is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
   Lesser General Public License for more details.

   You should have received a copy of the GNU Lesser General Public
   License along with the GNU C Library; if not, see
   <http://www.gnu.org/licenses/>.  */
/* This header is separate from features.h so that the compiler can
   include it implicitly at the start of every compilation.  It must
   not itself include <features.h> or any other header that includes
   <features.h> because the implicit include comes before any feature
   test macros that may be defined in a source file before it first
   explicitly includes a system header.  GCC knows the name of this
   header in order to preinclude it.  */
/* We do support the IEC 559 math functionality, real and complex.  */
/* wchar_t uses ISO/IEC 10646 (2nd ed., published 2011-03-15) /
   Unicode 6.0.  */
/* We do not support C11 <threads.h>.  */
/* 
 * absVal - absolute value of x
 *   Example: absVal(-1) = 1.
 *   You may assume -TMax <= x <= TMax
 *   Legal ops: ! ~ & ^ | + << >>
 *   Max ops: 10
 *   Rating: 4
 */
int absVal(int x) {
  int mask = x>>31;
  return (x ^ mask) + ~mask + 1L;
}
/* 
 * addOK - Determine if can compute x+y without overflow
 *   Example: addOK(0x80000000,0x80000000) = 0,
 *            addOK(0x80000000,0x70000000) = 1, 
 *   Legal ops: ! ~ & ^ | + << >>
 *   Max ops: 20
 *   Rating: 3
 */
int addOK(int x, int y) {
  int sum = x+y;
  int x_neg = x>>31;
  int y_neg = y>>31;
  int s_neg = sum>>31;
  /* Overflow when x and y have same sign, but s is different */
  return !(~(x_neg ^ y_neg) & (x_neg ^ s_neg));
}
/* 
 * allEvenBits - return 1 if all even-numbered bits in word set to 1
 *   Examples allEvenBits(0xFFFFFFFE) = 0, allEvenBits(0x55555555) = 1
 *   Legal ops: ! ~ & ^ | + << >>
 *   Max ops: 12
 *   Rating: 2
 */
int allEvenBits(int x) {
  int m8 = 0xAA;
  int m16 = m8 | m8 << 8;
  int m32 = m16 | m16 <<16;
  int fillx = x | m32;
  return !~fillx;
}
/* 
 * allOddBits - return 1 if all odd-numbered bits in word set to 1
 *   Examples allOddBits(0xFFFFFFFD) = 0, allOddBits(0xAAAAAAAA) = 1
 *   Legal ops: ! ~ & ^ | + << >>
 *   Max ops: 12
 *   Rating: 2
 */
int allOddBits(int x) {
  int m8 = 0x55;
  int m16 = m8 | m8 << 8;
  int m32 = m16 | m16 <<16;
  int fillx = x | m32;
  return !~fillx;
}
/* 
 * anyEvenBit - return 1 if any even-numbered bit in word set to 1
 *   Examples anyEvenBit(0xA) = 0, anyEvenBit(0xE) = 1
 *   Legal ops: ! ~ & ^ | + << >>
 *   Max ops: 12
 *   Rating: 2
 */
int anyEvenBit(int x) {
  int m8 = 0x55;
  int m16 = m8 | m8 << 8;
  int m32 = m16 | m16 <<16;
  int evenx = x & m32;
  return !!evenx;
}
/* 
 * anyOddBit - return 1 if any odd-numbered bit in word set to 1
 *   Examples anyOddBit(0x5) = 0, anyOddBit(0x7) = 1
 *   Legal ops: ! ~ & ^ | + << >>
 *   Max ops: 12
 *   Rating: 2
 */
int anyOddBit(int x) {
    int m8 = 0xAA;
    int m16 = m8 | m8 << 8;
    int m32 = m16 | m16 <<16;
    int oddx = x & m32;
    return !!oddx;
}
/* 
 * bang - Compute !x without using !
 *   Examples: bang(3) = 0, bang(0) = 1
 *   Legal ops: ~ & ^ | + << >>
 *   Max ops: 12
 *   Rating: 4 
 */
int bang(int x) {
  int minus_x = ~x+1;
  /* Cute trick: 0 is the only value of x
   * for which neither x nor -x are negative */
  return (~(minus_x|x) >> 31) & 1;
}
/* 
 * bitAnd - x&y using only ~ and | 
 *   Example: bitAnd(6, 5) = 4
 *   Legal ops: ~ |
 *   Max ops: 8
 *   Rating: 1
 */
int bitAnd(int x, int y) {
  return ~(~x | ~y);
}
/*
 * bitCount - returns count of number of 1's in word
 *   Examples: bitCount(5) = 2, bitCount(7) = 3
 *   Legal ops: ! ~ & ^ | + << >>
 *   Max ops: 40
 *   Rating: 4
 */
int bitCount(int x) {
    /* Sum 8 groups of 4 bits each */
    int m1 = 0x11 | (0x11 << 8);
    int mask = m1 | (m1 << 16);
    int s = x & mask;
    s += x>>1 & mask;
    s += x>>2 & mask;
    s += x>>3 & mask;
    /* Now combine high and low order sums */
    s = s + (s >> 16);
    /* Low order 16 bits now consists of 4 sums,
       each ranging between 0 and 8.
       Split into two groups and sum */
    mask = 0xF | (0xF << 8);
    s = (s & mask) + ((s >> 4) & mask);
    return (s + (s>>8)) & 0x3F;
}
/* 
 * bitMask - Generate a mask consisting of all 1's 
 *   lowbit and highbit
 *   Examples: bitMask(5,3) = 0x38
 *   Assume 0 <= lowbit <= 31, and 0 <= highbit <= 31
 *   If lowbit > highbit, then mask should be all 0's
 *   Legal ops: ! ~ & ^ | + << >>
 *   Max ops: 16
 *   Rating: 3
 */
int bitMask(int highbit, int lowbit) {
  int on = (2<<highbit) + ~0;
  int off = (1<<lowbit) + ~0;
  return on & ~off;
}
/* 
 * bitNor - ~(x|y) using only ~ and & 
 *   Example: bitNor(0x6, 0x5) = 0xFFFFFFF8
 *   Legal ops: ~ &
 *   Max ops: 8
 *   Rating: 1
 */
int bitNor(int x, int y) {
  return (~x & ~y);
}
/* 
 * bitOr - x|y using only ~ and & 
 *   Example: bitOr(6, 5) = 7
 *   Legal ops: ~ &
 *   Max ops: 8
 *   Rating: 1
 */
int bitOr(int x, int y) {
  return ~(~x & ~y);
}
/*
 * bitParity - returns 1 if x contains an odd number of 0's
 *   Examples: bitParity(5) = 0, bitParity(7) = 1
 *   Legal ops: ! ~ & ^ | + << >>
 *   Max ops: 20
 *   Rating: 4
 */
int bitParity(int x) {
  /* Work things down.  At any time, upper part of words will
     contain junk.  Mask this off at the very end
  */
 int wd16 = x ^ x>>16; /* Combine into 16 bits */
 int wd8 = wd16 ^ wd16>>8; /* Combine into 8 bits */
 int wd4 = wd8 ^ wd8>>4;
 int wd2 = wd4 ^ wd4>>2;
 int bit = (wd2 ^ wd2>>1) & 0x1;
 return bit;
}
/* 
 * bitXor - x^y using only ~ and & 
 *   Example: bitXor(4, 5) = 1
 *   Legal ops: ~ &
 *   Max ops: 14
 *   Rating: 1
 */
int bitXor(int x, int y) {
  int x_and_y = x&y;
  int x_or_y = ~(~x & ~y);
  return x_or_y & ~x_and_y;
}
/* 
 * byteSwap - swaps the nth byte and the mth byte
 *  Examples: byteSwap(0x12345678, 1, 3) = 0x56341278
 *            byteSwap(0xDEADBEEF, 0, 2) = 0xDEEFBEAD
 *  You may assume that 0 <= n <= 3, 0 <= m <= 3
 *  Legal ops: ! ~ & ^ | + << >>
 *  Max ops: 25
 *  Rating: 2
 */
int byteSwap(int x, int n, int m) {
    int n8 = n << 3;
    int m8 = m << 3;
    int n_mask = 0xff << n8;
    int m_mask = 0xff << m8;
    int n_byte = (( x & n_mask ) >> n8) & 0xff;
    int m_byte = (( x & m_mask ) >> m8) & 0xff;
    int bytes_mask = n_mask | m_mask;
    int left_over = x & ~bytes_mask;
    return left_over | (n_byte << m8) | (m_byte << n8);
}
/* 
 * conditional - same as x ? y : z 
 *   Example: conditional(2,4,5) = 4
 *   Legal ops: ! ~ & ^ | + << >>
 *   Max ops: 16
 *   Rating: 3
 */
int conditional(int x, int y, int z) {
  int notx = !x;
  int mask = notx + ~0L;
  return (y & mask) | (z & ~mask);
}
/* 
 * copyLSB - set all bits of result to least significant bit of x
 *   Example: copyLSB(5) = 0xFFFFFFFF, copyLSB(6) = 0x00000000
 *   Legal ops: ! ~ & ^ | + << >>
 *   Max ops: 5
 *   Rating: 2
 */
int copyLSB(int x) {
  /* Shift bit to MSB and then right shift (arithmetically) back */
  int result = (x<<31)>>31;
  return result;
}
/* 
 * divpwr2 - Compute x/(2^n), for 0 <= n <= 30
 *  Round toward zero
 *   Examples: divpwr2(15,1) = 7, divpwr2(-33,4) = -2
 *   Legal ops: ! ~ & ^ | + << >>
 *   Max ops: 15
 *   Rating: 2
 */
int divpwr2(int x, int n) {
    /* Handle rounding by generating bias:
       0 when x >= 0
       2^n-1 when x < 0
    */
    int mask = (1 << n) + ~0;
    int bias = (x >> 31) & mask;
    return (x+bias) >> n;
}
/* 
 * evenBits - return word with all even-numbered bits set to 1
 *   Legal ops: ! ~ & ^ | + << >>
 *   Max ops: 8
 *   Rating: 1
 */
int evenBits(void) {
  int byte = 0x55;
  int word = byte | byte<<8;
  return word | word<<16;
}
/*
 * ezThreeFourths - multiplies by 3/4 rounding toward 0,
 *   Should exactly duplicate effect of C expression (x*3/4),
 *   including overflow behavior.
 *   Examples: ezThreeFourths(11) = 8
 *             ezThreeFourths(-9) = -6
 *             ezThreeFourths(1073741824) = -268435456 (overflow)
 *   Legal ops: ! ~ & ^ | + << >>
 *   Max ops: 12
 *   Rating: 3
 */
int ezThreeFourths(int x) {
  int threex = ((x << 1) + x);
  int bias = (threex >> 31) & 3;
  return (threex + bias) >> 2;
}
/* 
 * fitsBits - return 1 if x can be represented as an 
 *  n-bit, two's complement integer.
 *   1 <= n <= 32
 *   Examples: fitsBits(5,3) = 0, fitsBits(-4,3) = 1
 *   Legal ops: ! ~ & ^ | + << >>
 *   Max ops: 15
 *   Rating: 2
 */
int fitsBits(int x, int n) {
  int shift = 32 + ~n + 1;
  int move = (x << shift) >> shift;
  return !(x ^ move);
}
/* 
 * fitsShort - return 1 if x can be represented as a 
 *   16-bit, two's complement integer.
 *   Examples: fitsShort(33000) = 0, fitsShort(-32768) = 1
 *   Legal ops: ! ~ & ^ | + << >>
 *   Max ops: 8
 *   Rating: 1
 */
int fitsShort(int x) {
  int shift1 = x >> 15;
  int shift2 = x >> 16;
  return !(shift1 ^ shift2);
}
/* 
 * float_abs - Return bit-level equivalent of absolute value of f for
 *   floating point argument f.
 *   Both the argument and result are passed as unsigned int's, but
 *   they are to be interpreted as the bit-level representations of
 *   single-precision floating point values.
 *   When argument is NaN, return argument..
 *   Legal ops: Any integer/unsigned operations incl. ||, &&. also if, while
 *   Max ops: 10
 *   Rating: 2
 */
unsigned float_abs(unsigned uf) {
  unsigned mask = 1 << 31;
  unsigned abs = uf & ~mask;
  if (abs > 0x7F800000)
    return uf;
  return abs;
}
/* 
 * float_f2i - Return bit-level equivalent of expression (int) f
 *   for floating point argument f.
 *   Argument is passed as unsigned int, but
 *   it is to be interpreted as the bit-level representation of a
 *   single-precision floating point value.
 *   Anything out of range (including NaN and infinity) should return
 *   0x80000000u.
 *   Legal ops: Any integer/unsigned operations incl. ||, &&. also if, while
 *   Max ops: 30
 *   Rating: 4
 */
int float_f2i(unsigned uf) {
  unsigned sign = uf >> 31;
  unsigned exp = (uf >> 23) & 0xFF;
  unsigned frac = uf & 0x7FFFFF;
  /* Create normalized value with leading one inserted,
     and rest of significand in bits 8--30.
  */
  unsigned val = 0x80000000u + (frac << 8);
  if (exp < 127) {
    /* Absolute value is < 1 */
    return 0;
  }
  if (exp > 158)
    /* Overflow */
    return 0x80000000u;
  /* Shift val right */
  val = val >> (158 - exp);
  /* Check if out of range */
  if (sign) {
    /* Negative */
    return val > 0x80000000u ? 0x80000000u : -val;
  } else {
    /* Positive */
    return val > 0x7FFFFFFF ? 0x80000000u : val;
  }
}
/* 
 * float_half - Return bit-level equivalent of expression 0.5*f for
 *   floating point argument f.
 *   Both the argument and result are passed as unsigned int's, but
 *   they are to be interpreted as the bit-level representation of
 *   single-precision floating point values.
 *   When argument is NaN, return argument
 *   Legal ops: Any integer/unsigned operations incl. ||, &&. also if, while
 *   Max ops: 30
 *   Rating: 4
 */
unsigned float_half(unsigned uf) {
  unsigned sign = uf>>31;
  unsigned exp = uf>>23 & 0xFF;
  unsigned frac = uf & 0x7FFFFF;
  /* Only roundup case will be when rounding to even */
  unsigned roundup = (frac & 0x3) == 3;
  if (exp == 0) {
    /* Denormalized.  Must halve fraction */
    frac = (frac >> 1) + roundup;
  } else if (exp < 0xFF) {
    /* Normalized.  Decrease exponent */
    exp--;
    if (exp == 0) {
      /* Denormalize, adding back leading one */
      frac = (frac >> 1) + roundup + 0x400000;
    }
  }
  /* NaN Infinity do not require any changes */
  return (sign << 31) | (exp << 23) | frac;
}
/* 
 * float_i2f - Return bit-level equivalent of expression (float) x
 *   Result is returned as unsigned int, but
 *   it is to be interpreted as the bit-level representation of a
 *   single-precision floating point values.
 *   Legal ops: Any integer/unsigned operations incl. ||, &&. also if, while
 *   Max ops: 30
 *   Rating: 4
 */
unsigned float_i2f(int x) {
  unsigned sign = (x < 0);
  unsigned ax = (x < 0) ? -x : x;
  unsigned exp = 127+31;
  unsigned residue;
  unsigned frac = 0;
  if (ax == 0) {
    exp = 0;
    frac = 0;
  } else {
    /* Normalize so that msb = 1 */
    while ((ax & (1<<31)) == 0) {
      ax = ax << 1;
      exp--;
    }
    /* Now have Bit 31 = MSB (becomes implied leading one)
       Bits 8-30 are tentative fraction,
       Bits 0-7 require rounding.
    */
    residue = ax & 0xFF;
    frac = (ax >> 8) & 0x7FFFFF; /* 23 bits */
    if (residue > 0x80 || (residue == 0x80 && (frac & 0x1))) {
      /* Round up */
      frac ++;
      /* Might need to renormalize */
      if (frac > 0x7FFFFF) {
 frac = (frac & 0x7FFFFF) >> 1;
 exp++;
      }
    }
  }
  return (sign << 31) | (exp << 23) | frac;
}
/* 
 * float_neg - Return bit-level equivalent of expression -f for
 *   floating point argument f.
 *   Both the argument and result are passed as unsigned int's, but
 *   they are to be interpreted as the bit-level representations of
 *   single-precision floating point values.
 *   When argument is NaN, return argument.
 *   Legal ops: Any integer/unsigned operations incl. ||, &&. also if, while
 *   Max ops: 10
 *   Rating: 2
 */
unsigned float_neg(unsigned uf) {
 unsigned mask = 1 << 31;
 unsigned result = uf ^ mask;
 unsigned abs = uf & ~mask;
 if (abs > 0x7F800000){
      /* NaN */
      result = uf;
 }
 return result;
}
/* 
 * float_twice - Return bit-level equivalent of expression 2*f for
 *   floating point argument f.
 *   Both the argument and result are passed as unsigned int's, but
 *   they are to be interpreted as the bit-level representation of
 *   single-precision floating point values.
 *   When argument is NaN, return argument
 *   Legal ops: Any integer/unsigned operations incl. ||, &&. also if, while
 *   Max ops: 30
 *   Rating: 4
 */
unsigned float_twice(unsigned uf) {
  unsigned sign = uf>>31;
  unsigned exp = uf>>23 & 0xFF;
  unsigned frac = uf & 0x7FFFFF;
  if (exp == 0) {
    /* Denormalized.  Must double fraction */
    frac = 2*frac;
    if (frac > 0x7FFFFF) {
      /* Result normalized */
      frac = frac & 0x7FFFFF; /* Chop off leading bit */
      exp = 1;
    }
  } else if (exp < 0xFF) {
    /* Normalized.  Increase exponent */
    exp++;
    if (exp == 0xFF) {
      /* Infinity */
      frac = 0;
    }
  }
  /* Infinity and NaN do not require any changes */
  return (sign << 31) | (exp << 23) | frac;
}
/* 
 * getByte - Extract byte n from word x
 *   Bytes numbered from 0 (LSB) to 3 (MSB)
 *   Examples: getByte(0x12345678,1) = 0x56
 *   Legal ops: ! ~ & ^ | + << >>
 *   Max ops: 6
 *   Rating: 2
 */
int getByte(int x, int n) {
  /* Shift x n*8 positions right */
  int shift = n << 3;
  int xs = x >> shift;
  /* Mask byte */
  return xs & 0xFF;
}
/* 
 * greatestBitPos - return a mask that marks the position of the
 *               most significant 1 bit. If x == 0, return 0
 *   Example: greatestBitPos(96) = 0x40
 *   Legal ops: ! ~ & ^ | + << >>
 *   Max ops: 70
 *   Rating: 4 
 */
int greatestBitPos(int x) {
    /* Set of bits being probed */
    int probe_bits = x;
    /* 1 if x != 0 */
    int position = !!x;
    /* Use divide and conquer to move position to correct spot */
    int upper_zero;
    int uz_mask;
    /* Is there a 1 in the upper 16/32 bits? */
    upper_zero = !(probe_bits >> 16);
    uz_mask = ~upper_zero + 1;
    /* If so, shift */
    position <<= (!upper_zero << 4);
    /* Merge upper and lower probe bits */
    probe_bits = (probe_bits & uz_mask) | (probe_bits >> 16);
    /* Is there a 1 in the remaining upper 8/16 bits? */
    upper_zero = !(probe_bits >> 8);
    uz_mask = ~upper_zero + 1;
    /* If so, shift */
    position <<= (!upper_zero << 3);
    /* Merge upper and lower probe bits */
    probe_bits = (probe_bits & uz_mask) | (probe_bits >> 8);
    /* Is there a 1 in the remaining upper 4/8 bits? */
    upper_zero = !(probe_bits >> 4);
    uz_mask = ~upper_zero + 1;
    /* If so, shift */
    position <<= (!upper_zero << 2);
    /* Merge upper and lower probe bits */
    probe_bits = (probe_bits & uz_mask) | (probe_bits >> 4);
    /* Is there a 1 in the remaining upper 2/4 bits? */
    upper_zero = !(probe_bits >> 2);
    uz_mask = ~upper_zero + 1;
    /* If so, shift */
    position <<= (!upper_zero << 1);
    /* Merge upper and lower probe bits */
    probe_bits = (probe_bits & uz_mask) | (probe_bits >> 2);
    /* Is there a 1 in the remaining upper 1/2 bits? */
    upper_zero = !(probe_bits >> 1);
    /* If so, shift */
    position <<= !upper_zero;
    return position;
}
/* howManyBits - return the minimum number of bits required to represent x in
 *             two's complement
 *  Examples: howManyBits(12) = 5
 *            howManyBits(298) = 10
 *            howManyBits(-5) = 4
 *            howManyBits(0)  = 1
 *            howManyBits(-1) = 1
 *            howManyBits(0x80000000) = 32
 *  Legal ops: ! ~ & ^ | + << >>
 *  Max ops: 90
 *  Rating: 4
 */
int howManyBits(int x) {
    int sign, pos, bias;
    sign = x>>31;
    /* if negative, don't negate, just flip bits */
    x = (sign & (~x)) | (~sign & x);
    /* bias=1 if x==0 */
    bias = !(x^0);
    pos = (!!(x >> 16)) << 4;
    pos |= (!!(x >> (pos + 8))) << 3;
    pos |= (!!(x >> (pos + 4))) << 2;
    pos |= (!!(x >> (pos + 2))) << 1;
    pos |= x >> (pos + 1);
    return (pos + 2 + (~bias + 1));
}
/*
 * ilog2 - return floor(log base 2 of x), where x > 0
 *   Example: ilog2(16) = 4
 *   Legal ops: ! ~ & ^ | + << >>
 *   Max ops: 90
 *   Rating: 4
 */
int ilog2(int x) {
  int m16 = ((1<<16) + ~0) << 16; /* groups of 16 */
  int m8 = (((1<<8) + ~0) << 24) + (((1<<8) + ~0) << 8); /* groups of 8 */
  int m4 = (0xf0<<24) + (0xf0<<16) + (0xf0<<8) + 0xf0; /* groups of 4 */
  int m2 = (0xcc<<24) + (0xcc<<16) + (0xcc<<8) + 0xcc; /* groups of 2 */
  int m1 = (0xaa<<24) + (0xaa<<16) + (0xaa<<8) + 0xaa; /* groups of 1 */
  int result = 0;
  int upper;
  int mask;
  /* m16 */
  upper = !!(x & m16);
  result += upper << 4;
  mask = m16 ^ ~((upper<<31)>>31);
  /* m8 */
  upper = !!(x & m8 & mask);
  result += upper << 3;
  mask &= (m8 ^ ~((upper<<31)>>31));
  /* m4 */
  upper = !!(x & m4 & mask);
  result += upper << 2;
  mask &= (m4 ^ ~((upper<<31)>>31));
  /* m2 */
  upper = !!(x & m2 & mask);
  result += upper << 1;
  mask &= (m2 ^ ~((upper<<31)>>31));
  /* m1 */
  upper = !!(x & m1 & mask);
  result += upper;
  return result;
}
/* 
 * implication - return x -> y in propositional logic - 0 for false, 1
 * for true
 *   Example: implication(1,1) = 1
 *            implication(1,0) = 0
 *   Legal ops: ! ~ ^ |
 *   Max ops: 5
 *   Rating: 2
 */
int implication(int x, int y) {
    return (!x)|y;
}
/* 
 * isAsciiDigit - return 1 if 0x30 <= x <= 0x39 (ASCII codes for characters '0' to '9')
 *   Example: isAsciiDigit(0x35) = 1.
 *            isAsciiDigit(0x3a) = 0.
 *            isAsciiDigit(0x05) = 0.
 *   Legal ops: ! ~ & ^ | + << >>
 *   Max ops: 15
 *   Rating: 3
 */
int isAsciiDigit(int x) {
  int bias1 = ~0x2F;
  int bias2 = 0x3a;
  int lower = x + bias1;
  int upper = ~x + bias2;
  return !((lower|upper) >> 31);
}
/* 
 * isEqual - return 1 if x == y, and 0 otherwise 
 *   Examples: isEqual(5,5) = 1, isEqual(4,5) = 0
 *   Legal ops: ! ~ & ^ | + << >>
 *   Max ops: 5
 *   Rating: 2
 */
int isEqual(int x, int y) {
  return !(x ^ y);
}
/* 
 * isGreater - if x > y  then return 1, else return 0 
 *   Example: isGreater(4,5) = 0, isGreater(5,4) = 1
 *   Legal ops: ! ~ & ^ | + << >>
 *   Max ops: 24
 *   Rating: 3
 */
int isGreater(int x, int y) {
  int x_neg = x>>31;
  int y_neg = y>>31;
  return !((x_neg & !y_neg) | (!(x_neg ^ y_neg) & (~y+x)>>31));
}
/* 
 * isLess - if x < y  then return 1, else return 0 
 *   Example: isLess(4,5) = 1.
 *   Legal ops: ! ~ & ^ | + << >>
 *   Max ops: 24
 *   Rating: 3
 */
int isLess(int x, int y) {
  int x_neg = (x>>31);
  int y_neg = (y>>31);
  return !((!x_neg & y_neg) | (!(x_neg ^ y_neg) & (y+~x)>>31));
}
/* 
 * isLessOrEqual - if x <= y  then return 1, else return 0 
 *   Example: isLessOrEqual(4,5) = 1.
 *   Legal ops: ! ~ & ^ | + << >>
 *   Max ops: 24
 *   Rating: 3
 */
int isLessOrEqual(int x, int y) {
  int x_neg = x>>31;
  int y_neg = y>>31;
  return !(((!x_neg) & y_neg) | ((!(x_neg ^ y_neg)) & (y+~x+1)>>31));
}
/* 
 * isNegative - return 1 if x < 0, return 0 otherwise 
 *   Example: isNegative(-1) = 1.
 *   Legal ops: ! ~ & ^ | + << >>
 *   Max ops: 6
 *   Rating: 2
 */
int isNegative(int x) {
    return (x>>31) & 0x1;
}
/* 
 * isNonNegative - return 1 if x >= 0, return 0 otherwise 
 *   Example: isNonNegative(-1) = 0.  isNonNegative(0) = 1.
 *   Legal ops: ! ~ & ^ | + << >>
 *   Max ops: 6
 *   Rating: 3
 */
int isNonNegative(int x) {
    return ((~x)>>31) & 0x1;
}
/* 
 * isNonZero - Check whether x is nonzero using
 *              the legal operators except !
 *   Examples: isNonZero(3) = 1, isNonZero(0) = 0
 *   Legal ops: ~ & ^ | + << >>
 *   Max ops: 10
 *   Rating: 4 
 */
int isNonZero(int x) {
  int minus_x = ~x+1;
  return ((minus_x|x) >> 31) & 1;
}
/* 
 * isNotEqual - return 0 if x == y, and 1 otherwise 
 *   Examples: isNotEqual(5,5) = 0, isNotEqual(4,5) = 1
 *   Legal ops: ! ~ & ^ | + << >>
 *   Max ops: 6
 *   Rating: 2
 */
int isNotEqual(int x, int y) {
  return !!(x ^ y);
}
/* 
 * isPositive - return 1 if x > 0, return 0 otherwise 
 *   Example: isPositive(-1) = 0.
 *   Legal ops: ! ~ & ^ | + << >>
 *   Max ops: 8
 *   Rating: 3
 */
int isPositive(int x) {
    return !((!x) | (x >> 31));
}
/*
 * isPower2 - returns 1 if x is a power of 2, and 0 otherwise
 *   Examples: isPower2(5) = 0, isPower2(8) = 1, isPower2(0) = 0
 *   Note that no negative number is a power of 2.
 *   Legal ops: ! ~ & ^ | + << >>
 *   Max ops: 20
 *   Rating: 4
 */
int isPower2(int x) {
  /* Solve using trick: x & (x-1) == 0 only when x==0 or has single 1 bit */
  int xm1 = x + ~0; // Decrement x
  int possible = !(x&xm1);
  int result = possible & !!x & !(x & (1<<31));
  return result;
}
/*
 * isTmax - returns 1 if x is the maximum, two's complement number,
 *     and 0 otherwise 
 *   Legal ops: ! ~ & ^ | +
 *   Max ops: 10
 *   Rating: 1
 */
int isTmax(int x) {
    int nx = ~x;
    int nxnz = !!nx;
    int nxovf = !(nx+nx);
    return nxnz & nxovf;
}
/*
 * isTmin - returns 1 if x is the minimum, two's complement number,
 *     and 0 otherwise 
 *   Legal ops: ! ~ & ^ | +
 *   Max ops: 10
 *   Rating: 1
 */
int isTmin(int x) {
  return (!!x) & (!(x+x));
}
/*
 * isZero - returns 1 if x == 0, and 0 otherwise 
 *   Examples: isZero(5) = 0, isZero(0) = 1
 *   Legal ops: ! ~ & ^ | + << >>
 *   Max ops: 2
 *   Rating: 1
 */
int isZero(int x) {
  return !x;
}
/* 
 * leastBitPos - return a mask that marks the position of the
 *               least significant 1 bit. If x == 0, return 0
 *   Example: leastBitPos(96) = 0x20
 *   Legal ops: ! ~ & ^ | + << >>
 *   Max ops: 6
 *   Rating: 2 
 */
int leastBitPos(int x) {
  /* The only bit set in both x and -x will be the least significant one */
  return x & (~x+1);
}
/*
 * leftBitCount - returns count of number of consective 1's in
 *     left-hand (most significant) end of word.
 *   Examples: leftBitCount(-1) = 32, leftBitCount(0xFFF0F0F0) = 12
 *   Legal ops: ! ~ & ^ | + << >>
 *   Max ops: 50
 *   Rating: 4
 */
int leftBitCount(int x) {
    int c16, s16, x16;
    int c8, s8, x8;
    int c4, s4, x4;
    int c2, s2, x2;
    int c1, s1, x1;
    int result = 0;
    /* Check upper 16 bits */
    c16 = !((x >> 16) + 1);
    s16 = c16<<4; /* == 16 if upper 16 bits are set to 1, 0 otherwise */
    result = s16;
    /* Move lower bits up if upper bits all 1's */
    x16 = x << s16;
    /* Check upper 8 bits */
    c8 = !((x16 >> 24) + 1);
    s8 = c8<<3; /* == 8 if upper 8 bits are set to 1, 0 otherwise */
    result += s8;
    /* Move lower bits up if upper bits all 1's */
    x8 = x16 << s8;
    /* Check upper 4 bits */
    c4 = !((x8 >> 28) + 1);
    s4 = c4<<2; /* == 4 if upper 4 bits are set to 1, 0 otherwise */
    result += s4;
    /* Move lower bits up if upper bits all 1's */
    x4 = x8 << s4;
    /* Check upper 2 bits */
    c2 = !((x4 >> 30) + 1);
    s2 = c2<<1; /* == 2 if upper 2 bits are set to 1, 0 otherwise */
    result += s2;
    /* Move lower bits up if upper bits all 1's */
    x2 = x4 << s2;
    /* Check upper bit */
    c1 = (x2 >> 31) & 0x1;
    s1 = c1; /* == 1 if upper bit is set to 1, 0 otherwise */
    result += s1;
    /* Move lower bits up if upper bit is 1 */
    x1 = x2 << s1;
    /* Now just add in the MSB */
    result += (x1 >> 31) & 0x1;
    return result;
}
/* 
 * logicalNeg - implement the ! operator, using all of 
 *              the legal operators except !
 *   Examples: logicalNeg(3) = 0, logicalNeg(0) = 1
 *   Legal ops: ~ & ^ | + << >>
 *   Max ops: 12
 *   Rating: 4 
 */
int logicalNeg(int x) {
  int minus_x = ~x+1;
  return ~((minus_x|x) >> 31) & 1;
}
/* 
 * logicalShift - shift x to the right by n, using a logical shift
 *   Can assume that 0 <= n <= 31
 *   Examples: logicalShift(0x87654321,4) = 0x08765432
 *   Legal ops: ! ~ & ^ | + << >>
 *   Max ops: 20
 *   Rating: 3 
 */
int logicalShift(int x, int n) {
    /* Create mask for n = 0 */
    int zmask = (~!n)+1;
    /* Arithmetic shift right by n */
    int right = x >> n;
    /* Mask off upper 1's */
    int lmask = ~0 << (33 + ~n);
    right &= ~lmask;
    return (zmask & x) | (~zmask & right);
}
/* 
 * minusOne - return a value of -1 
 *   Legal ops: ! ~ & ^ | + << >>
 *   Max ops: 2
 *   Rating: 1
 */
int minusOne(void) {
  return ~0;
}
/*
 * multFiveEighths - multiplies by 5/8 rounding toward 0.
 *   Should exactly duplicate effect of C expression (x*5/8),
 *   including overflow behavior.
 *   Examples: multFiveEighths(77) = 48
 *             multFiveEighths(-22) = -13
 *             multFiveEighths(1073741824) = 13421728 (overflow)
 *   Legal ops: ! ~ & ^ | + << >>
 *   Max ops: 12
 *   Rating: 3
 */
int multFiveEighths(int x) {
  int fivex = ((x << 2) + x);
  int bias = (fivex >> 31) & 7;
  return (fivex + bias) >> 3;
}
/* 
 * negate - return -x 
 *   Example: negate(1) = -1.
 *   Legal ops: ! ~ & ^ | + << >>
 *   Max ops: 5
 *   Rating: 2
 */
int negate(int x) {
  return ~x+1;
}
/* 
 * oddBits - return word with all odd-numbered bits set to 1
 *   Legal ops: ! ~ & ^ | + << >>
 *   Max ops: 8
 *   Rating: 2
 */
int oddBits(void) {
  int byte = 0xAA;
  int word = byte | byte<<8;
  return word | word<<16;
}
/* 
 * rempwr2 - Compute x%(2^n), for 0 <= n <= 30
 *   Negative arguments should yield negative remainders
 *   Examples: rempwr2(15,2) = 3, rempwr2(-35,3) = -3
 *   Legal ops: ! ~ & ^ | + << >>
 *   Max ops: 20
 *   Rating: 3
 */
int rempwr2(int x, int n) {
    /* First compute x / (1<<n) */
    int mask = (1 << n) + ~0;
    int bias = (x >> 31) & mask;
    int quo = (x+bias) >> n;
    /* Now multiply by (1<<n) and subtract off */
    int factor = ~(quo << n) + 1;
    return factor + x;
}
/* 
 * replaceByte(x,n,c) - Replace byte n in x with c
 *   Bytes numbered from 0 (LSB) to 3 (MSB)
 *   Examples: replaceByte(0x12345678,1,0xab) = 0x1234ab78
 *   You can assume 0 <= n <= 3 and 0 <= c <= 255
 *   Legal ops: ! ~ & ^ | + << >>
 *   Max ops: 10
 *   Rating: 3
 */
int replaceByte(int x, int n, int c) {
  /* Mask out current byte value and OR in replacement */
  int n8 = n << 3;
  int mask = 0xff << n8;
  int cshift = c << n8;
  return (x & ~mask) | cshift;
}
/* 
 * rotateLeft - Rotate x to the left by n
 *   Can assume that 0 <= n <= 31
 *   Examples: rotateLeft(0x87654321,4) = 0x76543218
 *   Legal ops: ~ & ^ | + << >> !
 *   Max ops: 25
 *   Rating: 3 
 */
int rotateLeft(int x, int n) {
    /* Create mask for n = 0 */
    int zmask = (~!n)+1;
    int left = x << n;
    /* Arithmetic shift right by 32-n */
    int right = x >> (33 + ~n);
    /* Mask off upper 1's */
    int lmask = ~0 << n;
    right &= ~lmask;
    return (zmask&x) | (~zmask&(left|right));
}
/* 
 * rotateRight - Rotate x to the right by n
 *   Can assume that 0 <= n <= 31
 *   Examples: rotateRight(0x87654321,4) = 0x76543218
 *   Legal ops: ~ & ^ | + << >> !
 *   Max ops: 25
 *   Rating: 3 
 */
int rotateRight(int x, int n) {
    /* Create mask for n = 0 */
    int zmask = (~!n)+1;
    int lsval = 33+~n;
    /* Shift left by 32-n */
    int left = x << lsval;
    /* Arithmetic shift right by n */
    int right = x >> n;
    /* Mask off upper 1's */
    int lmask = ~0 << lsval;
    right &= ~lmask;
    return (zmask&x) | (~zmask&(left|right));
}
/*
 * satAdd - adds two numbers but when positive overflow occurs, returns
 *          maximum possible value, and when negative overflow occurs,
 *          it returns minimum positive value.
 *   Examples: satAdd(0x40000000,0x40000000) = 0x7fffffff
 *             satAdd(0x80000000,0xffffffff) = 0x80000000
 *   Legal ops: ! ~ & ^ | + << >>
 *   Max ops: 30
 *   Rating: 4
 */
int satAdd(int x, int y) {
  int signbit = 31;
  int buzz = ((x^y) | (x^~(x+y))) >> signbit;
  /* buzz is all 1's if no overflow. if overflow, return maxint or minint
   * depending on which way we hit the wall */
  int out = (buzz & (x+y)) | (~buzz & (((x+y)>>signbit) ^ (1L<<signbit)));
  return out;
}
/*
 * satMul2 - multiplies by 2, saturating to Tmin or Tmax if overflow
 *   Examples: satMul2(0x30000000) = 0x60000000
 *             satMul2(0x40000000) = 0x7FFFFFFF (saturate to TMax)
 *             satMul2(0x60000000) = 0x80000000 (saturate to TMin)
 *   Legal ops: ! ~ & ^ | + << >>
 *   Max ops: 20
 *   Rating: 3
 */
int satMul2(int x) {
  int twox = x << 1;
  int mask = (x ^ twox) >> 31;
  int sat_val = (1 << 31) + (twox >> 31);
  return (twox & ~mask) | (sat_val & mask);
}
/*
 * satMul3 - multiplies by 3, saturating to Tmin or Tmax if overflow
 *  Examples: satMul3(0x10000000) = 0x30000000
 *            satMul3(0x30000000) = 0x7FFFFFFF (Saturate to TMax)
 *            satMul3(0x70000000) = 0x7FFFFFFF (Saturate to TMax)
 *            satMul3(0xD0000000) = 0x80000000 (Saturate to TMin)
 *            satMul3(0xA0000000) = 0x80000000 (Saturate to TMin)
 *  Legal ops: ! ~ & ^ | + << >>
 *  Max ops: 25
 *  Rating: 3
 */
int satMul3(int x) {
    int sign = x >> 31;
    int tmin = 1 << 31;
    int tmax = ~tmin;
    int overflow = 0;
    int threex, twox = x << 1;
    overflow = x ^ twox;
    threex = twox + x;
    overflow |= twox ^ threex;
    overflow >>= 31;
    return (overflow & ((sign & tmin) | (~sign & tmax))) | (~overflow & threex);
}
/* 
 * sign - return 1 if positive, 0 if zero, and -1 if negative
 *  Examples: sign(130) = 1
 *            sign(-23) = -1
 *  Legal ops: ! ~ & ^ | + << >>
 *  Max ops: 10
 *  Rating: 2
 */
int sign(int x) {
    return (x>>31) | (!!x);
}
/* 
 * sm2tc - Convert from sign-magnitude to two's complement
 *   where the MSB is the sign bit
 *   Example: sm2tc(0x80000005) = -5.
 *   Legal ops: ! ~ & ^ | + << >>
 *   Max ops: 15
 *   Rating: 4
 */
int sm2tc(int x) {
  int mask = x>>31;
  int mag = x & ~(1<<31);
  return (mag ^ mask) + ~mask + 1;
}
/* 
 * subOK - Determine if can compute x-y without overflow
 *   Example: subOK(0x80000000,0x80000000) = 1,
 *            subOK(0x80000000,0x70000000) = 0, 
 *   Legal ops: ! ~ & ^ | + << >>
 *   Max ops: 20
 *   Rating: 3
 */
int subOK(int x, int y) {
  int diff = x+~y+1;
  int x_neg = x>>31;
  int y_neg = y>>31;
  int d_neg = diff>>31;
  /* Overflow when x and y have opposite sign, and d different from x */
  return !(~(x_neg ^ ~y_neg) & (x_neg ^ d_neg));
}
/* 
 * tc2sm - Convert from two's complement to sign-magnitude 
 *   where the MSB is the sign bit
 *   You can assume that x > TMin
 *   Example: tc2sm(-5) = 0x80000005.
 *   Legal ops: ! ~ & ^ | + << >>
 *   Max ops: 15
 *   Rating: 4
 */
int tc2sm(int x) {
  int mask = x >> 31;
  int sign = mask & 1;
  /* Compute absolute value of x */
  int abs = (mask ^ x) + sign;
  return abs | (sign << 31);
}
/* 
 * thirdBits - return word with every third bit (starting from the LSB) set to 1
 *   Legal ops: ! ~ & ^ | + << >>
 *   Max ops: 8
 *   Rating: 1
 */
int thirdBits(void) {
  int bits9 = 0x49;
  int bits18 = bits9 | (bits9<<9);
  return bits18 | (bits18<<18);
}
/* 
 * TMax - return maximum two's complement integer 
 *   Legal ops: ! ~ & ^ | + << >>
 *   Max ops: 4
 *   Rating: 1
 */
int tmax(void) {
  return ~(1 << 31);
}
/* 
 * tmin - return minimum two's complement integer 
 *   Legal ops: ! ~ & ^ | + << >>
 *   Max ops: 4
 *   Rating: 1
 */
int tmin(void) {
  return 1<<31;
}
/*
 * trueFiveEighths - multiplies by 5/8 rounding toward 0,
 *  avoiding errors due to overflow
 *  Examples: trueFiveEighths(11) = 6
 *            trueFiveEighths(-9) = -5
 *            trueFiveEighths(0x30000000) = 0x1E000000 (no overflow)
 *  Legal ops: ! ~ & ^ | + << >>
 *  Max ops: 25
 *  Rating: 4
 */
int trueFiveEighths(int x)
{
    int xs1 = x >> 1;
    int xs2 = x >> 3;
    int bias = (x >> 31) & 7;
    int xl2 = x & 7;
    int xl1 = (x & 1) << 2;
    int incr = (xl2 + xl1 + bias) >> 3;
    return xs1 + xs2 + incr;
}
/*
 * trueThreeFourths - multiplies by 3/4 rounding toward 0,
 *   avoiding errors due to overflow
 *   Examples: trueThreeFourths(11) = 8
 *             trueThreeFourths(-9) = -6
 *             trueThreeFourths(1073741824) = 805306368 (no overflow)
 *   Legal ops: ! ~ & ^ | + << >>
 *   Max ops: 20
 *   Rating: 4
 */
int trueThreeFourths(int x)
{
  int xs1 = x >> 1;
  int xs2 = x >> 2;
  /* Compute value from low-order 2 bits */
  int bias = (x >> 31) & 0x3;
  int xl2 = x & 0x3;
  int xl1 = (x & 0x1) << 1;
  int incr = (xl2 + xl1 + bias) >> 2;
  return xs1 + xs2 + incr;
}
/* 
 * upperBits - pads n upper bits with 1's
 *  You may assume 0 <= n <= 32
 *  Example: upperBits(4) = 0xF0000000
 *  Legal ops: ! ~ & ^ | + << >>
 *  Max ops: 10
 *  Rating: 1
 */
int upperBits(int n) {
  return (((!!n)<<31)>>31) & ( (1<<31) >> (n+(~0)) );
}
