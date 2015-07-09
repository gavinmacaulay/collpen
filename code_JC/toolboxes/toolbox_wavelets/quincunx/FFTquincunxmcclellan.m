function [ortho,H] = FFTquincunxmcclellan(x,y,alpha)

% FFTQUINCUNXMCCLELLAN Supplies orthonormalizing part of the 2D McClellan
%       filters for 2D quincunx transform.
%
% 	v=FFTquincunmcclellan(x,y,alpha)
%
% 	Input:
% 	x,y = coordinates in the frequency domain
% 	alpha = degree of the filters, any real number >=1
%
% Dimitri Van De Ville
%      Biomedical Imaging Group, BIO-E/STI
%      Swiss Federal Institute of Technology Lausanne
%      CH-1015 Lausanne EPFL, Switzerland
    

% McClellan transform filters
H  = (2*ones(size(x)) + (cos(x) + cos(y))).^((alpha+1)/2);
H  = H/4^((alpha+1)/2);
Hc = (2*ones(size(x)) - (cos(x) + cos(y))).^((alpha+1)/2);
Hc = Hc/4^((alpha+1)/2);

% Orthonormalizing denominator (l_2 dual)
ortho = H.*conj(H) + Hc.*conj(Hc);
