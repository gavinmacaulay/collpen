% TESTALL2DQ
%
% Test 2D quincunx wavelet transform
%
% Dimitri Van De Ville
%      Biomedical Imaging Group, BIO-E/STI
%      Swiss Federal Institute of Technology Lausanne
%      CH-1015 Lausanne EPFL, Switzerland
             
% Create 2D test data
% -------------------
if 1, % zoneplate test image
 A=make_zoneplate(256); 
else  % cameraman test image
 A=double(imread('cameraman.tif'));
end;

if 0, % add noise
 A=A+30*randn(size(A));
end;
A=double(A);

sx=size(A,1);
sy=size(A,2);

% Setup parameters of wavelet transform
% -------------------------------------
% 1. Type of wavelet transform
%    - McClellan: O/B/D, 
%    - Polyharmonic Rabut: Po/Pb/Pd
%    - Polyharmonic isotropic: PO/PB/PD
type='PO'; 

% 2. Degree of the wavelet transform
%    (order gamma polyharmonic=degree alpha+2)
gamma=4;
alpha=gamma-2;

% 3. Number of iterations
%J=2*floor(log2(sx)); % maximal
J=4;

% Prefilter data
% --------------
% To be completely correct, data should be prefiltered/postfiltered with
% the interpolation prefilter to start really from the space V_0
% 
% Put this constant to 1 to do so; notice that the prefilter is only well
% defined for gamma>2
%
CONST_PREFILTER=0;

if CONST_PREFILTER,
step=2*pi/sx;
[xo,yo]=meshgrid(0:step/2:2*pi-step/2);

% refinement filter for [2 0; 0 2]
if upper(type(2)) == type(2),
  H  = 2^(-gamma)*((8/3*(sin(xo).^2+sin(yo).^2)+2/3*(sin(xo+yo).^2+sin(xo-yo).^2))./(8/3*(sin(xo/2).^2+sin(yo/2).^2)+2/3*(sin((xo+yo)/2).^2+sin((xo-yo)/2).^2))).^(gamma/2);
else
  H  = 2^(-gamma)*((sin(xo).^2+sin(yo).^2)./(sin(xo/2).^2+sin(yo/2).^2)).^(gamma/2);
end;
H(find(isnan(H))) = 1;

% interpolation prefilter
ac0 = ifftshift(autocorr2d(H.^1));
Ap=real(ifft2(fft2(A)./ac0));
else
Ap=A;
end;

% Precalculate filters
% --------------------
tic; 
[FA,FS]=FFTquincunxfilter2D([size(A)],alpha,type); 
timeIni=toc;

% Perform wavelet analysis
% ------------------------
tic; 
Q=FFTquin2D_analysis(Ap,J,FA); Q=real(Q);
timeAna=toc;

% Visualize wavelet analysis
% --------------------------
Q2=showdecomposition(Q,J);
Q2=uint8(Q2/max(abs(Q2(:)))*128+128);
figure; imshow(Q2,[]);

% Put some treatment here if you like to
% --------------------------------------
%Q=threshold(Q,J,2);
%Q(1:256,129:256)=0;
%Q(129:256,1:128)=0;
%Q=real(Q)+imag(Q);

% Perform wavelet synthesis
% ------------------------- 
tic; 
R=FFTquin2D_synthesis(Q,J,FS); 
timeSyn=toc;

% Postfilter if required
% ----------------------
if CONST_PREFILTER,
 R=real(ifft2(fft2(R).*ac0));
end;

figure; imshow(squeeze(R),[]);

% Compute reconstruction error
% ----------------------------
mean((double(A(:))-R(:)).^2)

sprintf('Quincunx FFT WT: %f / %f / %f\n',timeIni,timeAna,timeSyn)
