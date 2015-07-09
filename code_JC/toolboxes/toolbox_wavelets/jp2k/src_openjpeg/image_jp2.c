#include "liw.h"
#include "opj_includes.h"
#include "j2k.h"
#include "liw_image.h"
#include "mathop.h"
#include "liw_error.h"

#define j2k_image_t opj_image_t
#define j2k_comp_t opj_comp_t

/* TODO MALLOC */
static j2k_image_t * writej2kimage(IMAGE image)
{
  j2k_image_t * img = malloc(sizeof(j2k_image_t));
  int size=image->nx*image->ny;
  int k,i;

  img->x0=0; img->y0=0; img->x1=image->nx; img->y1=image->ny;
  img->numcomps=image->nchannels;
  img->comps=(j2k_comp_t*)malloc(img->numcomps*sizeof(j2k_comp_t));

  for (k=0;k<image->nchannels;k++)
    {
      img->comps[k].data=(int*)malloc(size*sizeof(int));
      img->comps[k].prec=8;
      img->comps[k].sgnd=0;
      img->comps[k].dx=1;
      img->comps[k].dy=1;
      for (i=0; i<size; i++)
    {
      img->comps[k].data[i]=ToInt(image->pix[k][i]);
    }
    }
  return(img);
}

static j2k_image_t * writej2kimage_ex(IMAGE32 image)
{
  j2k_image_t * img = malloc(sizeof(j2k_image_t));
  int size=image->nx*image->ny;
  int k,i;

  img->x0=0; img->y0=0; img->x1=image->nx; img->y1=image->ny;
  img->numcomps=image->nchannels;
  img->comps=(j2k_comp_t*)malloc(img->numcomps*sizeof(j2k_comp_t));

  for (k=0;k<image->nchannels;k++)
    {
      img->comps[k].data=(int*)malloc(size*sizeof(int));
      img->comps[k].prec=image->bits_per_pixel;
      img->comps[k].sgnd=1;         /* was 0 */
      img->comps[k].dx=1;
      img->comps[k].dy=1;
      for (i=0; i<size; i++)
    {                               /* component data is always signed ? */
      img->comps[k].data[i]=(int)(image->pix[k][i]);        /* ??? if sizeof(int) = 2, and bits_per_pixel > 16, we can't proceed */
    }
    }
  return(img);
}

static IMAGE readj2kimage(j2k_image_t * j2kimage)
{
  IMAGE image;
  int k,i;
  int size=j2kimage->x1*j2kimage->y1;

  image=Image_Alloc(j2kimage->numcomps,j2kimage->x1,j2kimage->y1);

  for (k=0;k<image->nchannels;k++)
    {
      for (i=0;i<size;i++)
    {
      image->pix[k][i]=IntTo(j2kimage->comps[k].data[i]);
    }
    }

  return(image);
 }

static IMAGE32 readj2kimage_ex(j2k_image_t * j2kimage)
{
  IMAGE32 image;
  int k,i;
  int size=j2kimage->x1*j2kimage->y1;

  image=Image32_Alloc(j2kimage->numcomps,j2kimage->x1,j2kimage->y1,j2kimage->comps[0].prec);

  for (k=0;k<image->nchannels;k++)
  for (i=0;i<size;i++)
      image->pix[k][i] = j2kimage->comps[k].data[i];

  return(image);
 }

/* This table contains the norms of the 9-7 wavelets for different bands.  <=> dwt_norms_real  */

static double dwt_norms_97[4][10]={
    {1.000, 1.965, 4.177, 8.403, 16.90, 33.84, 67.69, 135.3, 270.6, 540.9},
    {2.022, 3.989, 8.355, 17.04, 34.27, 68.63, 137.3, 274.6, 549.0},
    {2.022, 3.989, 8.355, 17.04, 34.27, 68.63, 137.3, 274.6, 549.0},
    {2.080, 3.865, 8.307, 17.18, 34.71, 69.59, 139.3, 278.6, 557.2}
};

/* This table contains the norms of the 9-7 wavelets for different bands.  <=> dwt_norms  */

static double dwt_norms_53[4][10]={
    {1.000, 1.500, 2.750, 5.375, 10.68, 21.34, 42.67, 85.33, 170.7, 341.3},
    {1.038, 1.592, 2.919, 5.703, 11.33, 22.64, 45.25, 90.48, 180.9},
    {1.038, 1.592, 2.919, 5.703, 11.33, 22.64, 45.25, 90.48, 180.9},
    {.7186, .9218, 1.586, 3.043, 6.019, 12.01, 24.00, 47.97, 95.93}
};

static int floorlog2(int a) {
    int l;
    for (l=0; a>1; l++) {
        a>>=1;
    }
    return l;
}

static void encode_stepsize(int stepsize, int numbps, int *expn, int *mant) {
    int p, n;
    p=floorlog2(stepsize)-13;
    n=11-floorlog2(stepsize);
    *mant=(n<0?stepsize>>-n:stepsize<<n)&0x7ff;
    *expn=numbps-p;
}

static int calc_explicit_stepsizes(j2k_tccp_t *tccp, int prec) {
    int numbands, bandno;
    numbands=3*tccp->numresolutions-2;
    for (bandno=0; bandno<numbands; bandno++) {
        double stepsize;

        int resno, level, orient, gain;
        resno=bandno==0?0:(bandno-1)/3+1;
        orient=bandno==0?0:(bandno-1)%3+1;
        level=tccp->numresolutions-1-resno;
        gain=tccp->qmfbid==0?0:(orient==0?0:(orient==1||orient==2?1:2));
        if (tccp->qntsty==J2K_CCP_QNTSTY_NOQNT) {
            stepsize=1.0;
        }
        else if (tccp->qmfbid==0)
        {
            double norm=dwt_norms_97[orient][level];
            stepsize=(1<<(gain+1))/norm;
        }
        else    
        {
            double norm=dwt_norms_53[orient][level];
            stepsize=(1<<(gain+1))/norm;
        }
        encode_stepsize((int)floor(stepsize*8192.0), prec+gain, &tccp->stepsizes[bandno].expn, &tccp->stepsizes[bandno].mant);
    }

    return(SUCCESS);
}


void j2kimage_free(j2k_image_t * image)
{
  int k;
   for (k=0;k<image->numcomps;k++)
     {
       free(image->comps[k].data);
     }
   free(image->comps);
   free(image);
}

int Image_J2K_Write(IMAGE image, unsigned char * buff, int buffsize, int codesize)
{
   j2k_cp_t cp;
   j2k_tcp_t *tcp;
   j2k_tccp_t *tccp;
   j2k_image_t * img;
   int ir=0; /*  1 = integer transform , 0 = real transform (7-9)  */
   int i;

   cp.tx0=0; cp.ty0=0;
   cp.tw=1; cp.th=1;
   cp.tcps=(j2k_tcp_t*)malloc(sizeof(j2k_tcp_t));
   tcp=&cp.tcps[0];

   tcp->numlayers=0;
   tcp->rates[tcp->numlayers]=codesize;
   tcp->numlayers++;

   img=writej2kimage(image);

   cp.tdx=img->x1-img->x0; cp.tdy=img->y1-img->y0;

   tcp->csty=0;
   tcp->prg=0;
   tcp->mct=img->numcomps==3?1:0;                   /* that must be number of components: three (RGB) or one */
   tcp->tccps=(j2k_tccp_t*)malloc(img->numcomps*sizeof(j2k_tccp_t));

   for (i=0; i<img->numcomps; i++) {
     tccp=&tcp->tccps[i];
     tccp->csty=0;
     tccp->numresolutions=8;
     tccp->cblkw=5;/* 6 */
     tccp->cblkh=5;/* 6 */
     tccp->cblksty=0;
     tccp->qmfbid=ir?1:0;           /* 1 = int (5-3), 0 = real (7-9) */
     tccp->qntsty=ir?J2K_CCP_QNTSTY_NOQNT:J2K_CCP_QNTSTY_SEQNT;
     tccp->numgbits=2;
     tccp->roishift=0;
     calc_explicit_stepsizes(tccp, img->comps[i].prec);
   }

   if (!j2k_encode(img,&cp,buff, tcp->rates[tcp->numlayers-1]+2))
     {
       j2kimage_free(img);
       free(tcp->tccps);
       free(cp.tcps);
       return(FAILURE);
     }

   j2k_release_encode(img,&cp);
   /*    j2kimage_free(img); */
   /*    free(tcp->tccps); */
   /*    free(cp.tcps); */
   return(SUCCESS);
}


int Image_J2K_Write_Ex(IMAGE32 image, unsigned char * buff, int buffsize, int codesize)
{
   j2k_cp_t cp;
   j2k_tcp_t *tcp;
   j2k_tccp_t *tccp;
   j2k_image_t * img;
   int ir=0; /*  1 = integer transform , 0 = real transform (7-9)  */
   int i;

   cp.tx0=0; cp.ty0=0;
   cp.tw=1; cp.th=1;
   cp.tcps=(j2k_tcp_t*)malloc(sizeof(j2k_tcp_t));
   tcp=&cp.tcps[0];

   tcp->numlayers=0;
   tcp->rates[tcp->numlayers]=codesize;
   tcp->numlayers++;

   img=writej2kimage_ex(image);

   cp.tdx=img->x1-img->x0; cp.tdy=img->y1-img->y0;

   tcp->csty=0;
   tcp->prg=0;
   tcp->mct=img->numcomps==3?1:0;                   /* that must be number of components: three (RGB) or one */
   tcp->tccps=(j2k_tccp_t*)malloc(img->numcomps*sizeof(j2k_tccp_t));

   for (i=0; i<img->numcomps; i++) {
     tccp=&tcp->tccps[i];
     tccp->csty=0;
     tccp->numresolutions=8;
     tccp->cblkw=6; /* was 5 */
     tccp->cblkh=6; /* was 5 */ 
     tccp->cblksty=0;
     tccp->qmfbid=ir?1:0;           /* 1 = int (5-3), 0 = real (7-9) */
     tccp->qntsty=ir?J2K_CCP_QNTSTY_NOQNT:J2K_CCP_QNTSTY_SEQNT;
     tccp->numgbits=2;
     tccp->roishift=0;
     calc_explicit_stepsizes(tccp, img->comps[i].prec);
   }

   if (!j2k_encode(img,&cp,buff, tcp->rates[tcp->numlayers-1]+2))
     {
       j2kimage_free(img);
       free(tcp->tccps);
       free(cp.tcps);
       return(FAILURE);
     }

   j2k_release_encode(img,&cp);
   /*    j2kimage_free(img); */
   /*    free(tcp->tccps); */
   /*    free(cp.tcps); */
   return(SUCCESS);
}

IMAGE Image_J2K_Read(unsigned char * buff, int buffsize)
{
  IMAGE image;
  j2k_image_t *img;
  j2k_cp_t *cp;

  j2k_decode(buff, buffsize, &img, &cp);

  image=readj2kimage(img);

  j2k_release(img,cp);

  return(image);

}

IMAGE32 Image_J2K_Read_Ex(unsigned char * buff, int buffsize)
{
    IMAGE32 image;
    j2k_image_t *img;
    j2k_cp_t *cp;
    UINT32 max_value;
    j2k_decode(buff, buffsize, &img, &cp);
    max_value = (1 << (img->comps[0].prec)) - 1;
    image=readj2kimage_ex(img);
    j2k_release(img,cp);

    /* Image32_Saturation(image, 0, max_value); */

    return(image);
}

/* ****************************** */

BOOLEAN Image_J2K_Info(const unsigned char * buff, int buffsize, INT32 * nchannels, INT32 * size_x, INT32 * size_y)
{
  j2k_image_t *img;
  j2k_cp_t *cp;

  j2k_info((unsigned char* ) buff, buffsize, &img, &cp);

  *nchannels=img->numcomps;
  *size_x=img->x1-img->x0;
  *size_y=img->y1-img->y0;

  j2k_release(img,cp);

  return(SUCCESS);
}

BOOLEAN Image_J2K_Info_Ex(const unsigned char * buff, int buffsize, INT32 * nchannels, INT32 * size_x, INT32 * size_y,
    INT32 * bits_per_pixel)
{
  j2k_image_t *img;
  j2k_cp_t *cp;

  j2k_info((unsigned char* ) buff, buffsize, &img, &cp);

  *nchannels        = img->numcomps;
  *size_x           = img->x1-img->x0;
  *size_y           = img->y1-img->y0;
  *bits_per_pixel   = img->comps[0].prec;

  j2k_release(img,cp);

  return(SUCCESS);
}
