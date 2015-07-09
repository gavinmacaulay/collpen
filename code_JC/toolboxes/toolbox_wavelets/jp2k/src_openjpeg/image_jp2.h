int Image_J2K_Write(IMAGE image, char * buff, int buffsize, int codesize);
int Image_J2K_Write_Ex(IMAGE32 image, char * buff, int buffsize, int codesize);

IMAGE Image_J2K_Read(char * buff, int buffsize);
IMAGE32 Image_J2K_Read_Ex(char * buff, int buffsize);

BOOLEAN Image_J2K_Info(char * buff, int buffsize, INT32 * nchannels, INT32 * size_x, INT32 * size_y);
BOOLEAN Image_J2K_Info_Ex(char * buff, int buffsize, INT32 * nchannels, INT32 * size_x, INT32 * size_y, INT32 * bits_per_pixel);
