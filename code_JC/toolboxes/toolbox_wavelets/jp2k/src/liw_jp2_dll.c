#include "liw.h"
#include "liw_id_dll.h"

#include "image.h"
#include "image_jp2.h"
#include "liw_error.h"
#include "mathop.h"
#include "stream.h"

#define FILEID "J1"

int CALL_TYPE liw_jp2_encode_ex(void * in_image_ex,
               int in_size_x,
               int in_size_y,
               int nb_components,
               int bits_per_pixel,
               int bytes_per_pixel,
               unsigned char * out_jp2_code,
               int jp2_code_size)
{
    IMAGE32 tmp1;

    tmp1=Image32_Alloc(nb_components,in_size_x,in_size_y,bits_per_pixel);
    CATCHFAIL(tmp1==NULL);

    Image_Ex2Image32(in_image_ex, tmp1, bytes_per_pixel);

    CATCHFAILLAB(Image_J2K_Write_Ex(tmp1,out_jp2_code,jp2_code_size, jp2_code_size-2),flag_err);

    Image32_Free(tmp1);
    return(SUCCESS);

flag_err:

    Image32_Free(tmp1);
    return(FAILURE);
}

int CALL_TYPE liw_jp2_encode(unsigned char * in_rgb_image,
               int in_size_x,
               int in_size_y,
               unsigned char * out_jp2_code,
               int  jp2_code_size)
{
   IMAGE tmp1;

   tmp1=Image_Alloc(3,in_size_x,in_size_y);
   CATCHFAIL(tmp1==NULL);

  Image_RGB2Image(in_rgb_image,tmp1);

  CATCHFAILLAB(Image_J2K_Write(tmp1,out_jp2_code,jp2_code_size, jp2_code_size-2),flag_err);

  Image_Free(tmp1);

  return(SUCCESS);

 flag_err:
  Image_Free(tmp1);
  return(FAILURE);
}

/* *********************************************************** */
/* *********************************************************** */

int CALL_TYPE liw_jp2_decode(unsigned char * in_jp2_code,
               int jp2_code_size,
               unsigned char * out_rgb_image)
{
   IMAGE tmp1;

   tmp1=Image_J2K_Read(in_jp2_code,jp2_code_size);

   CATCHFAIL(tmp1==NULL);

   Image_Saturation(tmp1,IntTo(0),IntTo(255));

   Image_Image2RGB(tmp1,out_rgb_image);

   Image_Free(tmp1); /* dirty */

   return(SUCCESS);
}

int CALL_TYPE liw_jp2_decode_ex(
    unsigned char * in_jp2_code,
    int jp2_code_size,
    void * out_image_ex,
    int bytes_per_pixel)
{
   IMAGE32 tmp1;
   /* Note: Saturation is inside */
   tmp1=Image_J2K_Read_Ex(in_jp2_code, jp2_code_size);
   CATCHFAIL(tmp1==NULL);
   Image_Image322Ex(tmp1, out_image_ex, bytes_per_pixel);
   Image32_Free(tmp1); /* dirty */

   return(SUCCESS);
}

/* *********************************************************** */
/* *********************************************************** */

int CALL_TYPE liw_jp2_info(unsigned char * jp2_code,
             int jp2_code_size,
             int * size_x, int * size_y)
{
  int nchannels;

  *size_x=-1;
  if(Image_J2K_Info(jp2_code,jp2_code_size,&nchannels,size_x,size_y))
    return(FAILURE);
  else
    if (*size_x==-1)
      return(FAILURE);

  return(SUCCESS);
}

int CALL_TYPE liw_jp2_info_ex(unsigned char * jp2_code,
             int jp2_code_size,
             int * size_x, int * size_y, int * nb_components, int * bits_per_pixel)
{
  *size_x=-1;
  if(Image_J2K_Info_Ex(jp2_code,jp2_code_size,nb_components,size_x,size_y,bits_per_pixel))
    return(FAILURE);
  else
    if (*size_x==-1)
      return(FAILURE);

  return(SUCCESS);
}

/* *********************************************************** */
/* *********************************************************** */

/* Memory allocation */
IMAGE
Image_Alloc(INT32 nchannels, INT32 nx, INT32 ny)
{
  IMAGE  I =  malloc(sizeof(Image));
  INT32 k;
  size_t const nxnysize=nx*ny*sizeof(Math_Type);

  CATCHFAILLAB(I==NULL,flag_err_I);

  I->pix = (Math_Type **) malloc(nchannels*sizeof(Math_Type *));
  CATCHFAILLAB(I->pix==NULL,flag_err_Ipix);


  for (k=0;k<nchannels;k++)
    {
      I->pix[k] =  (Math_Type *) malloc(nxnysize);
      CATCHFAILLAB(I->pix[k]==NULL,flag_err_Ipixk);
    }

  I->nchannels=nchannels;
  I->nx=nx;
  I->ny=ny;
  return(I);
  /* In case of emergency */
 flag_err_Ipixk:
  for (k--;k--;)
    free(I->pix[k]);
 flag_err_Ipix:
  free(I);
 flag_err_I:
  return(NULL);
}


BOOLEAN Image_RGB2Image(const unsigned char * RGB, IMAGE I)
{
  INT32 sizexy=I->nx*I->ny;
  unsigned char * cur= (unsigned char *) RGB;
  INT32 ind;

  CATCHFAIL(I->nchannels != 3);

  for (ind=0;ind<sizexy;ind++)
    {

      I->pix[0][ind]=IntTo((unsigned char)(*cur++));
      I->pix[1][ind]=IntTo((unsigned char)(*cur++));
      I->pix[2][ind]=IntTo((unsigned char)(*cur++));
    }

  return(SUCCESS);
}

BOOLEAN Image_Image2RGB(IMAGE I, unsigned char * RGB)
{
  unsigned char *cur;
  INT32 size=I->nx*I->ny;
  INT32 ind;


  CATCHFAIL(I->nchannels != 3);

  cur=RGB;
   for (ind=0;ind<size;ind++)
    {

      *cur++=(unsigned char) ToInt(I->pix[0][ind]);
      *cur++=(unsigned char) ToInt(I->pix[1][ind]);
      *cur++=(unsigned char) ToInt(I->pix[2][ind]);
    }

   return(SUCCESS);
}

void Image_Free(/*@null@*/ /*@special@*/ IMAGE I)
     /*@releases I->pix,I@*/
{
    INT32 k;
    if (I != NULL)
    {
        for (k=0; k<I->nchannels; k++)
            free(I->pix[k]);

        free(I->pix);
        free(I);
    }
}

void Image_Saturation(IMAGE in, Math_Type min, Math_Type max)
{
  int k,ind;
  int size=in->nx*in->ny;
  Math_Type * pixcur, tmp;


  for (k=0;k<in->nchannels;k++)
    for (pixcur=in->pix[k],ind=0;ind< size;ind++,pixcur++)
      {
	if ( (tmp=*pixcur) < min)
	   *pixcur=min;
	else
	  if (tmp>max)
	  *pixcur=max;
      }

}


/* Image32 ************************************************************/

IMAGE32 Image32_Alloc(INT32 nchannels, INT32 nx, INT32 ny, int bits_per_pixel)
{
  IMAGE32  I =  malloc(sizeof(Image32));
  INT32 k;
  size_t const nxnysize=nx*ny*sizeof(INT32);

  CATCHFAILLAB(I==NULL,flag_err_I);

  I->pix = (INT32 **) malloc(nchannels*sizeof(INT32 *));
  CATCHFAILLAB(I->pix==NULL, flag_err_Ipix);

  for (k=0;k<nchannels;k++)
    {
      I->pix[k] =  (INT32 *) malloc(nxnysize);
      CATCHFAILLAB(I->pix[k]==NULL,flag_err_Ipixk);
    }

  I->nchannels=nchannels;
  I->nx=nx;
  I->ny=ny;
  I->bits_per_pixel=bits_per_pixel;
  return(I);
  /* In case of emergency */
 flag_err_Ipixk:
  for (k--;k--;)
    free(I->pix[k]);
 flag_err_Ipix:
  free(I);
 flag_err_I:
  return(NULL);
}

void Image32_Free(IMAGE32 I)
{
    INT32 k;
    if (I != NULL)
    {
        for (k=0; k<I->nchannels; k++)
            free(I->pix[k]);

        free(I->pix);
        free(I);
    }
}

BOOLEAN Image_Ex2Image32(const void * multiplexed, IMAGE32 I, int bytes_per_pixel)
{
    INT32 sizexy = I->nx * I->ny;
    char *   cur_1 = (char *)   multiplexed;
    short *  cur_2 = (short *)  multiplexed;
    long *   cur_4 = (long *)   multiplexed;
    INT32 ind;
    int channel;

    if (bytes_per_pixel == 1)
    {
        for (ind=0;ind<sizexy;ind++)
        for ( channel = 0; channel < I->nchannels ; channel ++)
            I->pix[channel][ind] = *cur_1++;
    }
    else if (bytes_per_pixel == 2)
    {
        for (ind=0;ind<sizexy;ind++)
        for ( channel = 0; channel < I->nchannels ; channel ++)
            I->pix[channel][ind] = *cur_2++;
    }
    else if (bytes_per_pixel == 4)
    {
        for (ind=0;ind<sizexy;ind++)
        for ( channel = 0; channel < I->nchannels ; channel ++)
            I->pix[channel][ind] = *cur_4++;
    }
    else
        return (FAILURE);

  return(SUCCESS);
}

BOOLEAN Image_Image322Ex(IMAGE32 I, void * multiplexed, int bytes_per_pixel)
{
    char     * cur_1 = (char *)     multiplexed;
    short    * cur_2 = (short *)    multiplexed;
    long     * cur_4 = (long *)     multiplexed;
    INT32 size=I->nx*I->ny;
    INT32 ind;
    int channel;

    if (bytes_per_pixel == 1)
    {
        for (ind=0;ind<size;ind++)
        for (channel=0;channel < I->nchannels;channel++)
            *cur_1++ = (char) (I->pix[channel][ind]);
    }
    else if (bytes_per_pixel == 2)
    {
        for (ind=0;ind<size;ind++)
        for (channel=0;channel < I->nchannels;channel++)
            *cur_2++ = (short) (I->pix[channel][ind]);
    }
    else if (bytes_per_pixel == 4)
    {
        for (ind=0;ind<size;ind++)
        for (channel=0;channel < I->nchannels;channel++)
            *cur_4++ = (long) (I->pix[channel][ind]);
    }
    else
        return (FAILURE);

    return(SUCCESS);
}

void Image32_Saturation(IMAGE32 in, INT32 min, INT32 max)
{
  int k,ind;
  int size=in->nx*in->ny;
  INT32 * pixcur, tmp;

  for (k=0;k<in->nchannels;k++)
    for (pixcur=in->pix[k],ind=0;ind< size;ind++,pixcur++)
      {
	if ( (tmp=*pixcur) < min)
	   *pixcur=min;
	else
	  if (tmp>max)
	  *pixcur=max;
      }

}
