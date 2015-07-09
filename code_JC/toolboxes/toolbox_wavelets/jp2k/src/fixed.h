#ifndef fixed_h
#define fixed_h
#define FIXEDPREC 16

typedef INT32 FIXED;

typedef INT64 LFIXED;

#define int2fix(i) (((INT32) (i))<<FIXEDPREC)
#define fix2int(i) ((i)>>FIXEDPREC)
#define fix_rint(i) ((i+(1<<(FIXEDPREC-1)))>>FIXEDPREC)
#define fix_add(a,b) ((a)+(b))
#define fix_dif(a,b) ((a)-(b))
#define fix_neg(a) (-(a))
#define fix_one int2fix(1)
#define fix2double(a) (((double)(a))/(1<<FIXEDPREC))
#define double2fix(a) ((FIXED)((a)*(1<<FIXEDPREC)))
#define fix2float(a) (((float)(a))/(1<<FIXEDPREC))
#define float2fix(a) ((FIXED)((a)*(1<<FIXEDPREC)))
/* Dirty */
#define fix2(a)  ((Math_Type) DoubleTo(fix2double(a)))
/* #define fix2(a)  (((Math_Type) ApprovedRealTo((a))/(1<<FIXEDPREC))) */
#define real2fix(a) ((FIXED)((a)*(1<<FIXEDPREC)))

#define fix_mul(a,b) ((FIXED)(((LFIXED)(a))*((LFIXED)(b))>>FIXEDPREC))
#define fix_fmul(a,b) ((a)*(b)>>FIXEDPREC)
#define fix_div(a,b) ((FIXED)((((LFIXED)(a))<<FIXEDPREC)/(b)))

/* static INLINE FIXED fix_mul(FIXED a,FIXED b) */
/* { */
/* 	 LFIXED tmp= (LFIXED) a * (LFIXED) b; */


/* 	if ((tmp>>(31+FIXEDPREC))==0) */
/* 	{ */
/* 		tmp=tmp>>FIXEDPREC; */
/* 		return ((FIXED) tmp ); */
/* 	} */
/* 	else { */
/* 	  if (tmp>0) */
/* 	    return (1<<31); */
/* 	  else */
/* 	    return(-(1<<30));	 */
/* 	} */
/* } */

#ifdef ASM
#ifdef ARM
#ifdef compil_vcc
static INLINE int fixp_mul_32s_nX_fixed( int a, int b, const int n ) {
        int res, tmp;
        const int p = 32-n;
        __asm {
	  smull  [res], [tmp], a, b ;
	  mov [res], [res], lsr n  ;
	  add  [tmp], [res], [tmp], lsl p ;
        );
        return res;
}
#undef fix_mul
#define fix_mul(a,b)((FIXED)  (fixp_mul_32s_nX_fixed((int) a, (int) b, FIXEDPREC)
#endif
#endif
#ifdef X86
#ifdef compil_vcc
#   pragma warning(push)
#   pragma warning(disable: 4035)  /* no return value */
static __forceinline
int f_mul_inline_FIXED(int x, int y)
{
  enum {
    fracbits = FIXEDPREC
  };

  __asm {
    mov eax, x
    imul y
    shrd eax, edx, fracbits
  }
#pragma warning(pop)
#undef fix_mul
#define fix_mul fix_mul_inline_FIXED
#endif
#ifdef compil_gcc
#define F_MLX_FIXED(hi, lo, x, y)  \
    asm ("imull %3"  \
	 : "=a" (lo), "=d" (hi)  \
	 : "%a" (x), "rm" (y)  \
	 : "cc")

#define f_scale64_FIXED(hi, lo, n)  \
    ({ int __result;  \
       asm ("shrdl %3,%2,%1"  \
	    : "=rm" (__result)  \
	    : "0" (lo), "r" (hi), "I" (n)  \
	    : "cc");  \
       __result;  \
    })

#undef fix_mul
#define fix_mul(x, y) \
( (FIXED) ({register int __hi; \
  register unsigned int __lo; \
  F_MLX_FIXED(__hi, __lo, (x), (y)); \
  f_scale64_FIXED(__hi, __lo, FIXEDPREC);\
  }))
#endif
#endif
#endif

#endif
