/*Error handling */
#include "liw.h"
#include "liw_error.h"
#ifdef windows_msg
#include <windows.h>
#endif

#ifndef noerrormessage
char ErrorMess[NumberMess*SizeOneMess+1];
INT32 ErrorMessCur=0;

void Error_Message_Add(char const * fileid, int line)
{
  char tmp[5];
  if (ErrorMessCur<(NumberMess-1)*SizeOneMess)
    {
      ErrorMess[ErrorMessCur++]=fileid[0];
      ErrorMess[ErrorMessCur++]=fileid[1];
      (void) snprintf(tmp, 5, "%4d", line);
      ErrorMess[ErrorMessCur++]=tmp[0];
      ErrorMess[ErrorMessCur++]=tmp[1];
      ErrorMess[ErrorMessCur++]=tmp[2];
      ErrorMess[ErrorMessCur++]=tmp[3];
      ErrorMess[ErrorMessCur++]='-';
    }
}


void Error_Message_Print()
{
  char * tmpmess;
  INT32 tmpcur;
  ErrorMess[ErrorMessCur]= (char) 0;
#ifdef  windows_msg
  wchar_t wmess[NumberMess*SizeOneMess+1];
#endif


  tmpmess=ErrorMess;
  tmpcur=ErrorMessCur;
#ifdef unix_txt
  do {
    printf("%.35s\n",tmpmess);
    tmpcur-=35;
    tmpmess+=35;
  }
  while (tmpcur>0);
#else
#ifdef windows_msg
  mbstowcs(wmess,ErrorMess,tmpcur+1);
  MessageBox(0,wmess, L"Error", MB_OK);
#endif
#endif
 
}

void Error_Message_CleanLast()
{
  if (ErrorMessCur>=SizeOneMess)
    ErrorMessCur-=SizeOneMess;
}

void Error_Message_Clean()
{
  ErrorMessCur=0;
}

BOOLEAN  
Error_Status()
{
  if (ErrorMessCur>0)
    return(FAILURE);
  else
    return(SUCCESS);
}
#endif

