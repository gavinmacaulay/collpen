function [v,fv] = poly(alpha,type)

% POLY - compute the polyharmonic B-spline 
%
% 	Input:
% 	alpha = degree of the polyharmonic spline
%       type = type of B-spline (b,d,o,B,D,O)
%
% Dimitri Van De Ville
%      Biomedical Imaging Group, BIO-E/STI
%      Swiss Federal Institute of Technology Lausanne
%      CH-1015 Lausanne EPFL, Switzerland
    

warning off MATLAB:divideByZero;

N=16; % spatial support: [-N/4:N/4[
Z=16; % spatial zoom factor
%N=64;
%Z=2;

step=2*pi/N;
[x,y]=meshgrid(-Z*pi:step:Z*pi-step);
w1=x; w2=y;

% compute frequency response
gamma=alpha+2;

x = x/2; y = y/2;
loc = sin(x).^2+sin(y).^2;

% alternative localization
if upper(type(1)) == type(1),
  loc = ( 8/3*loc + 2/3*(sin(x+y).^2+sin(x-y).^2) ) / 4;
end;

pow=(x.^2+y.^2);

loc=loc.^(gamma/2); 
pow=pow.^(gamma/2);

fv  = ( loc ./ pow );
fv(find(isnan(fv))) = 1;

% autocorrelation function
[xo,yo]=meshgrid(0:step/2:2*pi-step/2);

% refinement filter for [2 0; 0 2]
if upper(type(1)) == type(1),
  H  = 2^(-gamma)*((8/3*(sin(xo).^2+sin(yo).^2)+2/3*(sin(xo+yo).^2+sin(xo-yo).^2))./(8/3*(sin(xo/2).^2+sin(yo/2).^2)+2/3*(sin((xo+yo)/2).^2+sin((xo-yo)/2).^2))).^(gamma/2);
else
  H  = 2^(-gamma)*((sin(xo).^2+sin(yo).^2)./(sin(xo/2).^2+sin(yo/2).^2)).^(gamma/2);
end;
H(find(isnan(H))) = 1;

% autocorrelation function
ac0 = autocorr2d(H.^2);

sx = size(ac0,1); sy = size(ac0,2);
ac = zeros(size(fv));
for iterx=1:Z,
 for itery=1:Z,
  bx=(iterx-1)*sx+1;
  by=(itery-1)*sy+1;
  ac(bx:bx+sx-1,by:by+sy-1)=ac0;
 end;
end;
ac = fftshift(ac);

if lower(type(1)) == 'o',
 fv = fv ./ sqrt(ac);
end;

if lower(type(1)) == 'd',
 fv = fv ./ ac;
end;

% compute spatial version
fv = ifftshift(fv);              % shift to [0:2pi[
v = real((ifft2(fv)))*Z^2;       % compensate for zooming

% only keep the half [-N/4:N/4[ instead of [-N/2:N/2[ (to avoid aliasing)
[x,y]=meshgrid(-N/4:1/Z:N/4-1/Z);
v=fftshift(v);
v=v((N*Z)/4:(N*Z)*3/4-1,(N*Z)/4:(N*Z)*3/4-1);
v=ifftshift(v);

% optional: normalize energy (for movies)
if length(type)>1 & type(2) == 'n',
  s=sum(v(:).^2)/(Z*Z);
  v=v*sqrt(1/s);
end;

% surface plot with lighting
surfl(x,y,fftshift(v)); shading flat; view(-26,44);
xlabel('x_1');
ylabel('x_2');

