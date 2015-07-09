function [H,H1]=FFTquincunxfilter2D_highpass(x,y,type,B,ortho,ac,ac0,acD,acD0,loc,loc0);

% FFTQUINCUNXFILTER2D_HIGHPASS Supplies highpass filters for 2D quincunx transform.
% 	[Hsynthesis,Hanalysis]=FFTquincunxfilter2D_highpass(x,y,alpha,type)
% 	computes the frequency response of highpass filters. 
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
         

if lower(type(1))=='p', % Polyharmonic splines

 type = [ type(2:length(type)) ];

 switch lower(type(1)),

  % Orthogonal filters
  case 'o',
    H = B*sqrt(2) ./ sqrt(ortho);
    H1  = conj(H);

  % Dual filters (B-spline at the analysis side)
  case 'd',
    H = sqrt(2)*conj(B).*ac;
    H1  = sqrt(2)*B./acD;

  % B-spline filters (B-spline at the synthesis side)
  case 'b',
    H1 = sqrt(2)*conj(B).*ac;
    H  = sqrt(2)*B./acD;
    
  case 'i',
    H = sqrt(2)*loc0./ac0;
    H1 = sqrt(2)*(B.^2).*ac./acD.*ac0./loc0;
    H1(find(isinf(H1)))=0;

 end;

else  % Simple fractional iterate with McClellan transform 
 [H,H1]=FFTquincunxfilter2D_lowpass(x,y,type,B,ortho);
end;



