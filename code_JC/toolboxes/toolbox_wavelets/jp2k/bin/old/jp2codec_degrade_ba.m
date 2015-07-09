function [result_dble] = jp2codec_degrade_ba(Isrc, comp_ratio, bit_depth, nbr_bit_geom, Isrc_dble, mean_low_level, pixel_low_level)
%
% Attention: a) no rounding operation; it should be performed beforehand
%            b) returns uint32 matrix; convert it to double for further
%            processing
%
% See also:
%    jp2_codec, TestJP2, MakePlainImage


%2 voies d'entree-sortie.
% voie classique :  entree de l'image dans la chaine de compression/ sortie de l'image apres degradation
% voie d'insertion dans le codeur : entree de la transformee inseree directement dans la chaine en lieu et place de
% 				   la transformee normalement calculee a partir de l'image.la sortie se fait avant
%				   la phase normale d'inversion de la transformee.
% utilit? de garder l'image en entree. L'encodeur jp2k peut se baser sur l'image originale pour definir des strategies
% optimales de codage qu'il appliquera ensuite au codage de la transformee (decoupage en tuile ...) et a son decodage.
% Dans l'utilisation qu'il est ici faite de jpeg2k, l'image d'entree n'a aucune incidence quant au codage de la transformee
% (peut etre dans une version future ?)

x_size = size(Isrc,2);
y_size = size(Isrc,1);

I_cropped = int32(Isrc);

header_size_in_bytes = nbr_bit_geom;                                                           % for large images, it is not important
target_size = header_size_in_bytes + (x_size * y_size * bit_depth) / (comp_ratio * 8);     % 8 for bytes instead of bits

%nbre_bloc_y = min(pixel_low_level/4 , y_size);
%nbre_bloc_x = pixel_low_level/nbre_bloc_y ;

% Pour Jmin = 4  
nbre_bloc_x = 64;
nbre_bloc_y = 1;

[comp_data] = jp2_codec_ba(MakePlainImage(I_cropped), target_size, bit_depth, transpose(Isrc_dble), mean_low_level, nbre_bloc_x, nbre_bloc_y);
[decoded,result_dble] = jp2_codec_ba(comp_data, 0, 0, 0, mean_low_level, nbre_bloc_x, nbre_bloc_y);
result_dble = transpose(result_dble);