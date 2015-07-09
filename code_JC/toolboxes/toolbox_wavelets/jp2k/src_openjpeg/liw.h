#ifndef principal_liw_h
#define principal_liw_h

#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <float.h>

#define SUCCESS 0
#define FAILURE 1

#define SQR(a) (Mul((a),(a)))
#define MIN(a,b) ((a)<(b)?(a):(b))
#define MAX(a,b) ((a)>(b)?(a):(b))

/* PLATFORM-DEPENDENT SETTINGS */

#define compil_gcc

/* The corresponding define statement is now external (Makefile / Project settings) */
#ifndef compil_gcc
#ifndef compil_vcc
#error Either compil_gcc or compil_vcc must be defined!
#endif
#endif

#ifdef compil_gcc
#define INLINE inline
#define INT32 int
#define INT64 long long
#define BOOLEAN int
#define CALL_TYPE
#define DECL_TYPE
#endif

#ifdef compil_vcc
#define INLINE __inline
#define INT32 __int32
#define INT64 __int64
#define rint(a) floor((a)+0.5)
#define snprintf    _snprintf
#define BOOLEAN int


#define CALL_TYPE __stdcall


#ifdef DISABLE_DLL_EXPORT
#define DECL_TYPE
#else
#define DECL_TYPE __declspec(dllexport)
#endif
#endif

/*
 Some switches for debugging

 Disable following three triggers when creating a sharable library (for Yorick, for example).

 Controls whether any of main functions of the project are included,
 as well as the inclusion of Rescale_Image_Yorick_Wrapper
 (see rescale/rescale.c) */
/* #define _ALLOW_MAIN_FUNCTIONS */

/* #define _ALLOW_CONSOLE_OUTPUT */
/* while detecting eyes */

/* Enables file output to /tmp (images and other data) while detecting eyes */
/* #define _ALLOW_FILE_OUTPUT */

#define unix_txt
/* #define windows_msg */

/* #define noerrormessage */

#define notermoutput

/* #define noencoder */
/* #define nodecoder */
#define nofile
/* #define nostream */

/* #define no1channel */
/* #define no3channels */
#define nonchannels

/*
    Math_Type definitions
*/

#define Math_INT32

#ifdef Math_INT32
typedef INT32 Math_Type;
#define Math_Type_Epsilon 0
#define fixedmath
#endif

#ifdef Math_Float
typedef float Math_Type;
#define Math_Type_Epsilon FLT_EPSILON
#endif

#ifdef Math_Double
typedef double Math_Type;
#define Math_Type_Epsilon DBL_EPSILON
#endif

/* end of Math_Type definitions */

/* Comment the following line for any RELEASE */

#define LIW_INTERNAL                        /* choice of client-dependent signature */

/*
    client-dependent signature
*/

/* here (do not erase these lines!):
   echo "Let It Wave ID Photo Compression SDK. Seulement pour l'usage interne.
   Toute distribution interdite." | md5sum
*/

#ifdef LIW_INTERNAL
/* here: LIW (internal) */
static const unsigned char _LIW_INT_KEY[] = {
    0x36, 0x22, 0xa8, 0xcf, 0x13, 0x54, 0x7f, 0x6c,
    0x9d, 0xa6, 0x39, 0xfe, 0x9d, 0x8f, 0x86, 0xa8
    };
#else

static const unsigned char _LIW_INT_KEY[] = {
0xfd, 0x70, 0x46, 0x11, 0x5a, 0xab, 0xa8, 0x4d,
    0x17, 0xf9, 0xd8, 0xb5, 0x78, 0x72, 0x44, 0x9b
};

#endif

#define _LIW_INSERT_FAKE_KEY_USAGE unsigned char _liw_int_key = _LIW_INT_KEY[0]; _liw_int_key++
#define _LIW_INSERT_PDA_DATE_CHECK

#define FREE(a) free((void *)(a))

#endif              /* principal_liw_h */
