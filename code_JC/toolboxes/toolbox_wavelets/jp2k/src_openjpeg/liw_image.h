/* Image : all functions concerning images */

#ifndef image_h

#define image_h
#include "stream.h"

/* #define nofloatavailable */






typedef Math_Type * Chan;
typedef INT32 * FChan;
/* Image : real valued image */
typedef struct Image {
  Chan * pix; /* array of pixels values */
  INT32 nchannels; /* number of channels */
  INT32 nx,ny; /* size of each channel (columns / lines ) */
}Image, * IMAGE;

/* FImage : fixed point image */
typedef struct FImage {
  FChan * pix; /* array of pixels values */
  INT32 nchannels; /* number of channels */
  INT32 nx,ny; /* size of each channel (columns / lines) */
}FImage, * FIMAGE;

/* Image32 */

typedef unsigned long UINT32;

typedef INT32 * Chan32;
typedef struct Image32 {
  Chan32 * pix;
  INT32 nchannels;
  INT32 nx,ny;
  int bits_per_pixel;
}Image32, * IMAGE32;

IMAGE32 Image32_Alloc(INT32 nchannels, INT32 nx, INT32 ny, int bits_per_pixel);
void Image32_Free(IMAGE32 I);
BOOLEAN Image_Ex2Image32(const void * multiplexed, IMAGE32 I, int bytes_per_pixel);
BOOLEAN Image_Image322Ex(IMAGE32 I, void * multiplexed, int bytes_per_pixel);
void Image32_Saturation(IMAGE32 in, INT32 min, INT32 max);

/* Memory Allocation */
IMAGE
Image_Alloc(INT32 nchannels, INT32 nx, INT32 ny)
     ;

BOOLEAN Image_Resize(IMAGE I, INT32 nchannels, INT32 nx, INT32 ny);

void Image_Free(IMAGE I)
     ;

void Image_Free_Pix(IMAGE I,int k);

BOOLEAN Image_Alloc_Pix(IMAGE I,int k);

FIMAGE FImage_Alloc(INT32 nchannels, INT32 nx, INT32 ny)
     ;

void FImage_Free(FIMAGE I)
     ;

BOOLEAN
Image_Copy(IMAGE in, IMAGE out)
     ;

BOOLEAN
FImage_Copy(FIMAGE in, FIMAGE out)
     ;

#ifndef no3channels
BOOLEAN RGBPlane2Y(unsigned char * RGB, int nx, int ny, Math_Type * Y);

BOOLEAN Image_RGB2Y(IMAGE in, IMAGE out);

BOOLEAN Image_RGB2YCbCr(IMAGE in, IMAGE out);

BOOLEAN Image_YCbCr2RGB(IMAGE in, IMAGE out);
#endif


void Image_Saturation(IMAGE in, Math_Type min, Math_Type max);

IMAGE
Image_Pbm_Read(char const * filename);

BOOLEAN Image_Pbm_Write(IMAGE I, char const * filename, INT32 type, INT32 maxcol);

#ifndef nostream
BOOLEAN
Image_BMP_Raw(STREAM stream, IMAGE  image);
#endif

#ifndef noraw
BOOLEAN
Image_Raw_Write(IMAGE im, char * filename);

IMAGE
Image_Raw_Read(char * filename);

BOOLEAN save_image_raw(IMAGE im, int channel, char * filename);

BOOLEAN save_rgb_image_raw(unsigned char * RGB, int x_size, int y_size, char * filename);

#endif

BOOLEAN Image_RGB2Image(const unsigned char * RGB, IMAGE I);

BOOLEAN Image_Image2RGB(IMAGE I, unsigned char * RGB);

BOOLEAN Image_Char2Image(unsigned char * RGB, IMAGE I);

BOOLEAN Image_Image2Char(IMAGE I, unsigned char * RGB);


INT32 * Image_RGB_Yinteger(unsigned char * RGB, int size);

BOOLEAN save_normalized_pbm_image(IMAGE im, char * filename);

BOOLEAN save_rgb_image_pbm(unsigned char * RGB, int x_size, int y_size, char * filename);



void Image_RGB_Crop(unsigned char * RGB, int x_size, int y_size, int x1, int y1, int x2, int y2,
    unsigned char * out);

/* Mask routines */

IMAGE Image_Alloc_From_Mask(unsigned char * Mask, int x, int y);

unsigned char * Mask_Alloc(int x_size, int y_size);

void Mask_Copy(unsigned char * Source, unsigned char * Destination, int x_size, int y_size);

void Mask_Multiply(unsigned char * Mask_1, unsigned char * Mask_2, int x_size, int y_size);

void Mask_Inv_Multiply(unsigned char * Mask_1, unsigned char * Mask_2, int x_size, int y_size);

void Mask_Free(unsigned char * Mask);

BOOLEAN save_mask_image(unsigned char * Mask, int width, int height, char * filename);

void Enable_Mask_Region(unsigned char * Mask, int x_size, int Left_Limit, int Right_Limit, int Top_Limit, int Bottom_Limit);

BOOLEAN Disable_Small_Variation_Zones(IMAGE Integral_Norm_Image,
    unsigned char * Mask, int Margin, Math_Type Min_NRJ_Density_Factor);

/* Integral image routines */

Math_Type Get_From_Integral_Image(IMAGE In,
    int Feature_X_Offset, int Feature_Y_Offset,
    int Feature_X_Size, int Feature_Y_Size, int i, int j);

BOOLEAN Compute_Squared_Integral_Image(IMAGE Out, Math_Type * Input_Image, int x_size, int y_size, int * Precision_Loss);

/* Logo routines */

void Image_Put_Logo(IMAGE ima);
void Image_Put_Logo_Can(IMAGE ima);
void Image_Put_JPEG2000(IMAGE ima);
void Image_Put_Logo_NoAlpha(IMAGE ima);
void Image_Put_Logo_Can_NoAlpha(IMAGE ima);
void Image_Put_JPEG2000_NoAlpha(IMAGE ima);

void Image_Mask_Index(IMAGE mask,IMAGE index, INT32 X0, INT32 Y0);
void Image_Table_Apply(IMAGE in,INT32 * mask);
void Image_Table_Apply_RGB(IMAGE in,INT32 * mask,INT32 R, INT32 G, INT32 B);
void Image_Mask_Apply(IMAGE in,IMAGE mask);
void Image_Color_GW(IMAGE in, IMAGE out, Math_Type grey);
BOOLEAN Image_Color_GWm(IMAGE in, IMAGE out, Math_Type grey, INT32 max);

void Integer_Equalization(INT32 * image, int size, int strength);

#endif
