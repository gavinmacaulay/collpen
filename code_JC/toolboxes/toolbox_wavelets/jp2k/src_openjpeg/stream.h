#ifndef stream_h 
#define stream_h
#ifndef nostream
typedef struct {
  unsigned char * stream;
   unsigned char * streamcur;
  INT32  maxsize;
  INT32  remainsize;
} Stream, *STREAM; 

STREAM
Stream_Alloc(INT32 maxsize)
;

STREAM
Stream_Alloc_Char(unsigned char * ch,INT32 maxsize)
;

void Stream_Reinit(STREAM stream);

void Stream_Free(STREAM  stream);

void Stream_Free_Char(STREAM  stream);

BOOLEAN  
Stream_Write(STREAM stream, unsigned char car);

BOOLEAN  
Stream_Read(STREAM stream, unsigned char *car);
#endif
#endif
