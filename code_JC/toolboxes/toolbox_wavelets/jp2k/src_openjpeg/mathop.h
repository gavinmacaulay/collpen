#ifndef mathop_h
#define mathop_h

/*
FIXED MATH
*/

#ifdef fixedmath

#define FIXEDPRECMATH 13

#include "fixed.h"

typedef INT64 LFIXEDMATH;

#define Mul(a,b)        ((Math_Type)    (( ((LFIXEDMATH)(a)) * ((LFIXEDMATH)(b)) ) >> FIXEDPRECMATH))

#define Muleq(a,b)      a=Mul(a,b)

#define FMul(a,b)       (((a) *(b) )>> FIXEDPRECMATH)

#define Div(a,b)        ((Math_Type)    ( ( ((LFIXEDMATH)(a)) << FIXEDPRECMATH ) / ((LFIXEDMATH)(b)) ))
#define Diveq(a,b)      a=Div(a,b)

/* #define Sqrt(a) ((Math_Type)(sqrt((double)(a)/(1<<FIXEDPRECMATH))*(1<<FIXEDPRECMATH))) */
#define Sqrt_Prec(a)    (SqrtFix(a))
#define Sqrt(a)         ( (Math_Type) ((fred_sqrt((a)>>FIXEDPRECMATH))<<FIXEDPRECMATH) )
#define IntTo(a)        ((Math_Type) (((INT32) a)<<FIXEDPRECMATH))
#define ToInt(a)        ((INT32) ((a)>>FIXEDPRECMATH))

#define RintToInt(a)    ((INT32) (((a)+(1<<(FIXEDPRECMATH-1)))>>FIXEDPRECMATH))
#define Realtofix(a)    ((FIXED) ((a)>>(FIXEDPREC-FIXEDPRECMATH)))

INT32 fred_sqrt( INT32 x);

#define ApprovedRealTo(a) ((Math_Type)(((double) a)*(1<<FIXEDPRECMATH)))

#define Abs(a) abs(a)

#ifndef nofloatavailable

#define FloatTo(a) ((Math_Type)(((float) a)*(1<<FIXEDPRECMATH)))
#define ToFloat(a) (((float) (a))/(1<<FIXEDPREC))
#define DoubleTo(a) ((Math_Type)(((double) a)*(1<<FIXEDPRECMATH)))
#define ToDouble(a) (((double) (a))/(1<<FIXEDPRECMATH))
#define RealTo(a)  DoubleTo(a)

#endif  /* nofloatavailable */

# ifndef S_SPLINT_S
static Math_Type SqrtFix(Math_Type x) /* viré INLINE */
{
    int shift=0;
    Math_Type div_x;
    Math_Type z;

    if (x == 0) return(0);

    while ( x>>(31-FIXEDPRECMATH) !=0 )
    {
        x=x>>2;
        shift+=1;
    }
    div_x = x << FIXEDPRECMATH;

    while( ((z = (div_x/x-x)>>1)>>2) != 0 )
        x+=z;

    return(x<<shift);
}
#else
Math_Type SqrtFix(Math_Type x);

#ifdef ASM
#ifdef ARM
#ifdef compil_vcc
static INLINE int fixp_mul_32s_nX_mathop( int a, int b, const int n ) {
        int res, tmp;
        const int p = 32-n;
        __asm {
	  smull  [res], [tmp], a, b;
	  mov [res], [res], lsr n ;
	  add  [tmp], [res], [tmp], lsl p ;
        );
        return res;
}
#undef Mul
#define Mul(a,b)((Math_Type)  (fixp_mul_32s_nX_mathop((int) a, (int) b, FIXEDPRECMATH)
#endif
#endif
#endif
#ifdef X86
#ifdef compil_vcc
#   pragma warning(push)
#   pragma warning(disable: 4035)  /* no return value */
static __forceinline
int Mul_inline_FIXED(int x, int y)
{
  enum {
    fracbits = FIXEDPRECMATH
  };

  __asm {
    mov eax, x
    imul y
    shrd eax, edx, fracbits
  }
#pragma warning(pop)
#undef fix_mul
#define Mul Mul_inline_FIXED
#endif
#ifdef compil_gcc
#define F_MLX_MATH(hi, lo, x, y)  \
    asm ("imull %3"  \
	 : "=a" (lo), "=d" (hi)  \
	 : "%a" (x), "rm" (y)  \
	 : "cc")

#define f_scale64_FIXEDPRECMATH(hi, lo)  \
    ({ int __result;  \
       asm ("shrdl %3,%2,%1"  \
	    : "=rm" (__result)  \
	    : "0" (lo), "r" (hi), "I" (FIXEDPRECMATH)  \
	    : "cc");  \
       __result;  \
    })

#undef Mul
#define Mul(x, y) \
((Math_Type) ({register int __hi; \
  register unsigned int __lo; \
  F_MLX_MATH(__hi, __lo, (x), (y)); \
  f_scale64_FIXEDPRECMATH(__hi, __lo);\
  }))
#endif
#endif
#endif  /* S_SPLINT_S */


/*
   **************************************************** FLOATING POINT
*/

#else

typedef Math_Type Math_Type_L;

#define Mul(a,b)        ((a)*(b))
#define Muleq(a,b)      a*=(b)
#define Fmul(a,b)       ((a)*(b))

#define Div(a,b)        ((a)/(b))
#define Diveq(a,b)      a/=(b)

#define Sqrt(a)         ((Math_Type)sqrt(a))
#define Sqrt_Prec(a)    ((Math_Type)sqrt(a))


#define RintToInt(a) ((INT32) (rint(a)))
#define Realtofix(a) (real2fix(a))

#define ApprovedRealTo(a) ((Math_Type) (a))

#define Abs(a) fabs(a)

#ifndef nofloatavailable

#define FloatTo(a) (Math_Type) ( (float) a)
#define ToFloat(a) (float) ((Math_Type) a)
#define DoubleTo(a) ((Math_Type) ( (double) a))
#define ToDouble(a) ((double) ((Math_Type) a))
#define RealTo(a) ((Math_Type) (a))

#endif /* nofloatavailable */

#define DEFAULT_CONVERSION 1

#define _double2fixmagic  103079215104.0
     /* 2^36 * 1.5,  (52-_shiftamt=36) uses limited precisicion to floor */
#define _shiftamt        16
                   /* 16.16 fixed point representation, */

#if BigEndian_
	#define iexp_				0
	#define iman_				1
#else
	#define iexp_				1
	#define iman_				0
#endif //BigEndian_

/* ================================================================================================
 Real2Int
*/

static INLINE INT32 Real2Int_Double( double  val)
{
#if DEFAULT_CONVERSION
    return (INT32) val;
#else
    val		= val + _double2fixmagic;
    return ((INT32*)&val)[iman_] >> _shiftamt;
#endif
}

/* Real2Int
 ================================================================================================
*/

static INLINE INT32 Real2Int_Float( float  val )
{
#if DEFAULT_CONVERSION
    return (INT32) val;
#else
    return Real2Int_Double ((double)val);
#endif
}

#ifdef Math_Double
#define IntTo(a)   ((Math_Type) ((INT32) a))
#define ToInt(a)    (Real2Int_Double(a))
#endif  /* Math_Double */

#ifdef Math_Float
#define IntTo(a)   ((Math_Type) ((INT32) a))
#define ToInt(a)   (Real2Int_Float(a))
#endif  /* Math_Float */


#endif  /* fixedmath */

#endif  /* mathop_h */
