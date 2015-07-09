
#ifndef liw_error_h

#define liw_error_h
/* Error handling */
enum liw_error {
  Undefined_Error=0,
  Malloc_Error=1,
  Output_Image_Error=2,
  Input_Image_Error=3
};

/* Can't use const here! */
#define SizeOneMess 7
#define NumberMess 16

#ifndef noerrormessage
#define CATCHFAIL(ins) if ((ins)==FAILURE) { Error_Message_Add(FILEID,__LINE__); return FAILURE; }
#else
#define CATCHFAIL(ins) if ((ins)==FAILURE) { return FAILURE; }
#endif

#ifndef noerrormessage
#define CATCHFAILLAB(ins,lab) if ((ins)==FAILURE) { Error_Message_Add(FILEID,__LINE__); goto lab; }
#else
#define CATCHFAILLAB(ins,lab) if ((ins)==FAILURE) { goto lab; }
#endif

#ifndef noerrormessage
#define CATCHFAILNULL(ins) if ((ins)==FAILURE) { Error_Message_Add(FILEID,__LINE__); return NULL; }
#else
#define CATCHFAILNULL(ins) if ((ins)==FAILURE) { return NULL; }
#endif

#ifndef noerrormessage

extern char ErrorMess[NumberMess*SizeOneMess+1];
extern INT32  ErrorMessCur;

void Error_Message_Add(char const * fileid, int line);

void Error_Message_Print();

void Error_Message_CleanLast();

void Error_Message_Clean();

BOOLEAN Error_Status();
#endif
#endif
