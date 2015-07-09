/*=================================================================
 *
 * This is a MEX-file for Matlab, it serves as an interface between
 * the Matlab environment and external C functions.
 *
 * See function-specific documentation in the corresponding .m file.
 *
 * NOTE: Do not include comments starting by double slash in source files
 *       Functions in linked files have to be declared extern
 *
 * USEFUL Functions:
 *      mxIsDouble, mxIsClass, mxGetPr, mxGetScalar
 *      mxGetM, mxGetN, mxGetNumberOfDimensions, mxGetDimensions
 *      mxCreateDoubleMatrix, mxCreateNumericArray
 *      mexErrMsgTxt
 *
 *=================================================================*/

#include <math.h>
#include "mex.h"


void * matlab_ex_data;
void * matlab_in_data;

void * taille_x_e;
void * taille_y_e;


/* INCLUDE HERE THE AUXILIARY FUNCTION PROTOTYPES */
int liw_jp2_encode(unsigned char * in_rgb_image,
               int in_size_x,
               int in_size_y,
               unsigned char * out_jp2_code,
               int  jp2_code_size);

int liw_jp2_decode(unsigned char * in_jp2_code,
               int jp2_code_size,
               unsigned char * out_rgb_image);

int liw_jp2_info(unsigned char * jp2_code,
             int jp2_code_size,
             int * size_x, int * size_y);

int liw_jp2_encode_ex(
    void * in_image_ex,
    int in_size_x,
    int in_size_y,
    int nb_components,
    int bits_per_pixel,
    int bytes_per_pixel,
    unsigned char * out_jp2_code,
    int jp2_code_size);

int liw_jp2_decode_ex(
    unsigned char * in_jp2_code,
    int jp2_code_size,
    void * out_image_ex,
    int bytes_per_pixel);

int liw_jp2_info_ex(
    unsigned char * jp2_code,
    int jp2_code_size,
    int * size_x,
    int * size_y,
    int * nb_components,
    int * bits_per_pixel);

/* IN THE FOLLOWING TRACK 'IN' AND 'OUT' IF CHANGING NUMBER OF IN/OUTPUTS */
/* Input Arguments */

#define IN_1    prhs[0]
#define IN_2    prhs[1]
#define IN_3    prhs[2]

#ifdef ENCODE_ONLY

	#define IN_4    prhs[3]
	#define NUM_IN  4 
#else
	#define NUM_IN	3

#endif

/* Output Arguments */

#define OUT_1   plhs[0]
#define OUT_2   plhs[1]
#define NUM_OUT 2



/* This is the mexfunc part. Its prototype is NEVER changed */


void mexFunction(
    int nlhs, mxArray *plhs[],     /* left  hand side i.e. out */
    int nrhs, const mxArray*prhs[] /* right hand side i.e. in */
    )
{
    unsigned char * rgb_image;
    int jp2_code_size;
    unsigned char * jp2_code;

    double * transformee;

    int nb_dims_in1;
    int * dims_in1;
    int* ptr_out2;
    int m, n;

    int dimensions[3];
    int x_size, y_size, nb_components, bits_per_pixel;

    mxClassID out_class;
    int nb_out_dims;
    int bytes_per_pixel;


    /* Check for proper number of arguments */
    if (nrhs != NUM_IN)
        mexErrMsgTxt("Wrong number of input arguments.");
    else if (nlhs > NUM_OUT)
        mexErrMsgTxt("Too many output arguments.");

    /* Processing the input parameters */
    jp2_code_size   = (int) mxGetScalar(IN_2);

    if (jp2_code_size == 0)         /******************* Decoding mode ****************************/
    {

#ifdef ENCODE_ONLY

	transformee    = (double *) mxGetPr(IN_4);

	taille_x_e =  &x_size;
	taille_y_e =  &y_size;

#endif

        /* Note: IN_3 (bits_per_pixel) is ignored in decoding mode */

        if (!mxIsClass(IN_1, "uint8"))
            mexErrMsgTxt("The compressed JPEG2000 data should be of type 'real uint8'.");

        m = mxGetM(IN_1);
        n = mxGetN(IN_1);

        if (m == 1)
            jp2_code_size = n;
        else if (n==1)
            jp2_code_size = m;
        else
            mexErrMsgTxt("The compressed JPEG2000 data should be a vector.");

        if (jp2_code_size < 256 || jp2_code_size > 10000000)
            mexErrMsgTxt("Invalid size of the compressed JPEG2000 data.");

        /* More processing of the input parameters */
        jp2_code    = (unsigned char *) mxGetPr(IN_1);

	/* Requesting the size of the output image in order to allocate sufficient memory */
        if (liw_jp2_info_ex(jp2_code, jp2_code_size, &x_size, &y_size, &nb_components, &bits_per_pixel))
            mexErrMsgTxt("JPEG-2000: error getting info about the file. Corrupt code?");

        /* Create a matrix for the return argument : determining parameters ... */
        if (nb_components == 1)
        {
            nb_out_dims = 2;
            dimensions[0] = x_size;
            dimensions[1] = y_size;
        }
        else
        {
            nb_out_dims = 3;
            dimensions[0] = nb_components;
            dimensions[1] = x_size;
            dimensions[2] = y_size;
        }

        if (bits_per_pixel <= 8)
            bytes_per_pixel = 1;
        else if (bits_per_pixel <= 16)
            bytes_per_pixel = 2;
        else if (bits_per_pixel <= 32)
            bytes_per_pixel = 4;
        else
            mexErrMsgTxt("Invalid JPEG-2000 data? Number of bits per pixel is > 32");

        switch(bytes_per_pixel)
        {
        case 1:
            out_class = mxINT8_CLASS;
            break;
        case 2:
            out_class = mxINT16_CLASS;
            break;
        case 4:
            out_class = mxINT32_CLASS;
            break;
        }

        /* Create a matrix for the return argument */
        OUT_1 = mxCreateNumericArray(nb_out_dims, dimensions, out_class, mxREAL);

	#ifdef ENCODE_ONLY
        dimensions[0] = x_size;
        dimensions[1] = y_size;

        OUT_2 = mxCreateNumericArray(2, dimensions, mxDOUBLE_CLASS, mxREAL);
	matlab_ex_data = (void*) mxGetPr(OUT_2);
	#endif

        /* Assign pointers to the output parameters */
        rgb_image 	= 	(void *) mxGetPr(OUT_1);

	if (liw_jp2_decode_ex(jp2_code, jp2_code_size, rgb_image, bytes_per_pixel))
            mexErrMsgTxt("JPEG-2000: decoding error.");

    }
    else                            /* Encoding mode ****************************/
    {
    	taille_x_e =  &m;
	taille_y_e =  &n;

	bits_per_pixel  = (int) mxGetScalar(IN_3);

        if ( bits_per_pixel < 8 || bits_per_pixel > 32 )
            mexErrMsgTxt("The bits_per_pixel range is 8 .. 32.");


        if (mxIsClass(IN_1, "int8"))
            bytes_per_pixel = 1;
        else if (mxIsClass(IN_1, "int16"))
            bytes_per_pixel = 2;
        else if (mxIsClass(IN_1, "int32"))
            bytes_per_pixel = 4;
        else
            mexErrMsgTxt("The image must be 'real' and of type 'int8', 'int16' or 'int32'.");

        /* Check the dimensions of IN_1 : it should be an image  */
        nb_dims_in1 = mxGetNumberOfDimensions(IN_1);
        dims_in1 = (int *) mxGetDimensions(IN_1);       /* WARNING: discards const qualifier! */

        if (nb_dims_in1 == 2)
        {
            nb_components = 1;
            m = mxGetM(IN_1);
            n = mxGetN(IN_1);
        }
        else if (nb_dims_in1 == 3)
        {
            nb_components = dims_in1[0];    /* dims_in1: comp x X x Y */
            m = dims_in1[1];
            n = dims_in1[2];
        }
        else
            mexErrMsgTxt("The input image must be a 2- or 3- dimensional matrix.");

        if (m<16 || n<16 || m>4096 || n>4096)
            mexErrMsgTxt("The input image size range is 16x16 .. 4096x4096.");

        /* More processing of the input parameters */
        rgb_image    = (void *) mxGetPr(IN_1);

	#ifdef ENCODE_ONLY

	transformee    	= 	(double *) mxGetPr(IN_4);
	matlab_in_data 	= 	malloc(sizeof(double)*n*m);
	memcpy((double *)matlab_in_data, transformee, sizeof(double)*n*m);

	#endif

	dimensions[0] = m;
	dimensions[1] = n;

	OUT_2 = mxCreateNumericArray(2, dimensions, mxINT32_CLASS, mxREAL);

	matlab_ex_data = (int*) malloc(n*m*sizeof(int));
	ptr_out2 =(void*) mxGetPr(OUT_2);


	/* Create a matrix for the return argument */
        dimensions[0] = 1;
        dimensions[1] = jp2_code_size;
        OUT_1 = mxCreateNumericArray(2, dimensions, mxUINT8_CLASS, mxREAL);

        /* Assign pointers to the output parameters */
        jp2_code = (unsigned char *) mxGetPr(OUT_1);

        /* Do the actual computations in a subroutine */
        if (liw_jp2_encode_ex(rgb_image, m, n, nb_components, bits_per_pixel, bytes_per_pixel, jp2_code, jp2_code_size))
            mexErrMsgTxt("JPEG-2000: encoding failure.");

	memcpy(((int*) ptr_out2), ((int*) matlab_ex_data) ,n*m*sizeof(int));

	#ifdef ENCODE_ONLY

	free(matlab_in_data, sizeof(double)*n*m);

	#endif
     }

    return;
}
