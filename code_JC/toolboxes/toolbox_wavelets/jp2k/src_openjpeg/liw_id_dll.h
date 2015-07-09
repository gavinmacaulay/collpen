#ifndef liw_id_dll_h
#define liw_id_dll_h

typedef struct Liw_Valid_Area {
  int valid[6];
} Liw_Valid_Area, * LIW_VALID_AREA;

#define CALL_TYPE
#define DECL_TYPE

#ifdef __cplusplus
extern "C" {
#endif

int DECL_TYPE CALL_TYPE liw_jp2_encode(
    unsigned char * in_rgb_image,
    int in_size_x,
    int in_size_y,
    unsigned char * out_jp2_code,
    int jp2_code_size);

int DECL_TYPE CALL_TYPE liw_jp2_encode_ex(
    void * in_image_ex,
    int in_size_x,
    int in_size_y,
    int nb_components,
    int bits_per_pixel,
    int bytes_per_pixel,
    unsigned char * out_jp2_code,
    int jp2_code_size);

int DECL_TYPE CALL_TYPE liw_jp2_decode(
    unsigned char * in_jp2_code,
    int jp2_code_size,
    unsigned char * out_rgb_image);

int DECL_TYPE CALL_TYPE liw_jp2_decode_ex(
    unsigned char * in_jp2_code,
    int jp2_code_size,
    void * out_image_ex,
    int bytes_per_pixel);

int DECL_TYPE CALL_TYPE liw_jp2_info(
    unsigned char * jp2_code,
    int jp2_code_size,
    int * size_x,
    int * size_y);

int DECL_TYPE CALL_TYPE liw_jp2_info_ex(
    unsigned char * jp2_code,
    int jp2_code_size,
    int * size_x,
    int * size_y,
    int * nb_components,
    int * bits_per_pixel);

#ifdef __cplusplus
}
#endif

#endif
