function [H,H1]=FFTquincunxfilter2D_lowpass(x,y,type,B,ortho);

% FFTQUINCUNXFILTER2D_LOWPASS Supplies lowpass filters for 2D quincunx transform.
% 	[Hsynthesis,Hanalysis]=FFTquincunxfilter2D_lowpass(x,y,alpha,type)
% 	computes the frequency response of lowpass filters. 
%
% 	Input:
% 	x,y = coordinates in the frequency domain
% 	alpha = degree of the filters, any real number >=0 
%       type = type of filter (ortho, dual, bspline)
%
% Dimitri Van De Ville
%      Biomedical Imaging Group, BIO-E/STI
%      Swiss Federal Institute of Technology Lausanne
%      CH-1015 Lausanne EPFL, Switzerland
         
H=B;

if lower(type(1)) == 'p',
 type = [ type(2:length(type)) ];
end;

switch lower(type(1)),

  % Orthogonal filters
  case 'o',
    H = H*sqrt(2) ./ sqrt(ortho);
    H1  = conj(H);

  % Dual filters (B-spline at the analysis side)
  case 'd',
    H1 = sqrt(2)*conj(H);
    H = conj(H1./(ortho));

  % B-spline filters (B-spline at the synthesis side)
  case 'b',
    H = sqrt(2)*H;
    H1 = conj(H./(ortho));
    
  % Isotropic wavelet filter
  case 'i',
    H1 = sqrt(2)*conj(H);
    H = conj(H1./(ortho));

end;

