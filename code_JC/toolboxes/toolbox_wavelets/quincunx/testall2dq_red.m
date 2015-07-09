% TESTALL2DQ_RED
%
% Test 2D quincunx wavelet transform
% Redundant version
%
% Dimitri Van De Ville
%      Biomedical Imaging Group, IOA/STI
%      Swiss Federal Institute of Technology Lausanne
%      CH-1015 Lausanne EPFL, Switzerland
             
sx=size(A,1);
sy=size(A,2);

% Setup parameters of wavelet transform
% -------------------------------------
% 1. Type of wavelet transform
%    - McClellan: O/B/D, 
%    - Polyharmonic Rabut: Po/Pb/Pd
%    - Polyharmonic isotropic: PO/PB/PD
%    - Polyharmonic derivative: PI
type='PD'; 

% 2. Degree of the wavelet transform
%    (gamma polyharmonic=alpha+2)
gamma=6;
alpha=gamma-2;

% 3. Number of iterations
J=2*floor(log2(sx));
J=16;

% Precalculate filters
% --------------------
tic; 
[FA,FS]=FFTquincunxfilter2D([size(A)],alpha,type); 
timeIni=toc;

% Perform wavelet analysis
% ------------------------
tic; 
Q=zeros(sx,sy,J+1);
tmp=fft2(Ap);
for iter=1:J,
  step=2^(floor((iter-1)/2));

  if mod(iter,2)==1,
    HP=FA(mod(0:step:sx*step-1,sx)+1,mod(0:step:sy*step-1,sy)+1,2)/sqrt(2);
    LP=FA(mod(0:step:sx*step-1,sx)+1,mod(0:step:sy*step-1,sy)+1,1)/sqrt(2);
  else
    HP=FA(mod(0:step:sx*step-1,sx)+1,mod(0:step:sy*step-1,sy)+1,4)/sqrt(2);
    LP=FA(mod(0:step:sx*step-1,sx)+1,mod(0:step:sy*step-1,sy)+1,3)/sqrt(2);
  end;
  Q(:,:,iter)=real(ifft2(tmp.*LP));
  tmp=tmp.*LP;
end;
Q(:,:,J+1)=real(ifft2(tmp));
timeAna=toc;

Q0=Q;

% Perform wavelet synthesis
% ------------------------- 
tic; 
R=zeros(sx,sy);
tmp=fft2(Q(:,:,J+1));
for iter=J:-1:1,
  step=2^(floor((iter-1)/2));

  if mod(iter,2)==1,
    HP=FS(mod(0:step:sx*step-1,sx)+1,mod(0:step:sy*step-1,sy)+1,2)/sqrt(2);
    LP=FS(mod(0:step:sx*step-1,sx)+1,mod(0:step:sy*step-1,sy)+1,1)/sqrt(2);
  else
    HP=FS(mod(0:step:sx*step-1,sx)+1,mod(0:step:sy*step-1,sy)+1,4)/sqrt(2);
    LP=FS(mod(0:step:sx*step-1,sx)+1,mod(0:step:sy*step-1,sy)+1,3)/sqrt(2);
  end;

  tmp2=fft2(Q(:,:,iter));
  tmp=tmp.*LP+tmp2.*HP;
end;
R=real(ifft2(tmp));
timeSyn=toc;

imagesc(squeeze(R));
%surf(fftshift(R)); shading flat;

% Compute reconstruction error
% ----------------------------
mean((double(A(:))-R(:)).^2)

sprintf('Quincunx FFT WT: %f / %f / %f\n',timeIni,timeAna,timeSyn)
