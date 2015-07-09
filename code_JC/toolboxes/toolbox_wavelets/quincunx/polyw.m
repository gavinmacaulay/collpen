function [v,fv] = polyw(alpha,type)

% POLYW - polyharmonic B-spline wavelet
%
% 	Input:
%
%       type
%         lowercase - Rabut style
%         uppercase - isotropic brand
%
% 	alpha = degree of the polyharmonic spline
%
% Dimitri Van De Ville
%      Biomedical Imaging Group, BIO-E/STI
%      Swiss Federal Institute of Technology Lausanne
%      CH-1015 Lausanne EPFL, Switzerland
    

gamma=alpha+2;

warning off MATLAB:divideByZero;

N=16;
Z=16;
step=2*pi/N;
[w1,w2]=meshgrid(-Z*pi:step:Z*pi-step);

% downsampled grid
w1D=(w1+w2)/2;
w2D=(w1-w2)/2;

% scaling function
w1D  = w1D/2; w2D = w2D/2;

loc  = 4*sin(w1D).^2+4*sin(w2D).^2;

if upper(type(1)) == type(1),
  loc = loc - 8/3*sin(w1D).^2.*sin(w2D).^2;
end;

pow = (2*w1D).^2+(2*w2D).^2;

loc=loc.^(gamma/2); 
pow=pow.^(gamma/2);

fv1  = loc ./  pow;
fv1(find(isnan(fv1))) = 1;
w1D  = 2*w1D; w2D = 2*w2D;

% autocorrelation function
[w1o,w2o]=meshgrid(0:step/4:2*pi-step/4);

% refinement filter for [2 0; 0 2]
if upper(type(1)) == type(1),
  H  = 2^(-gamma)*((8/3*(sin(w1o).^2+sin(w2o).^2)+2/3*(sin(w1o+w2o).^2+sin(w1o-w2o).^2))./(8/3*(sin(w1o/2).^2+sin(w2o/2).^2)+2/3*(sin((w1o+w2o)/2).^2+sin((w1o-w2o)/2).^2))).^(gamma/2);
else
  H  = 2^(-gamma)*((sin(w1o).^2+sin(w2o).^2)./(sin(w1o/2).^2+sin(w2o/2).^2)).^(gamma/2);
end;
H(find(isnan(H))) = 1;

% autocorrelation function
ac0 = autocorr2d(H.^2);
ac0(size(ac0,1)+1,:)=ac0(1,:);
ac0(:,size(ac0,2)+1)=ac0(:,1);

[w1o,w2o]=meshgrid(0:step/2:2*pi);
ac = interp2(w1o,w2o,ac0,mod(w1D,2*pi),mod(w2D,2*pi),'*linear');

if lower(type(1)) == 'o' || lower(type(1)) == 'j',
 fv1 = fv1 ./ sqrt(ac);
end;
if lower(type(1)) == 'd',
 fv1 = fv1 ./ ac;
end;

% wavelet filter
w1D = -w1D-pi; w2D = -w2D-pi;

acD = interp2(w1o,w2o,ac0,mod(w1D,2*pi),mod(w2D,2*pi),'*linear');

w1D = w1D/2;  w2D = w2D/2;

% Quincunx scaling filter
if upper(type(1)) == type(1),
  t1 = 8/3*(sin(w1D+w2D).^2 + sin(w1D-w2D).^2) + 2/3*(sin(2*w1D).^2 + sin(2*w2D).^2);
  t2 = 8/3*(sin(w1D).^2 + sin(w2D).^2) + 2/3*(sin(w1D+w2D).^2 + sin(w1D-w2D).^2);
else
  t1 = sin(w1D+w2D).^2 + sin(w1D-w2D).^2;
  t2 = sin(w1D).^2 + sin(w2D).^2;
end;

% Dyadic scaling filter
if length(type)>1 & type(2)=='D',
  t1 = sin(2*w1D).^2 + sin(2*w2D).^2;
  t2 = sin(w1D).^2 + sin(w2D).^2;
end;

t=( 0.5 * t1./t2 ).^(gamma/2);
fv2 = conj(t);
fv2(find(isnan(fv2))) = 1;
w1D = 2*w1D; w2D = 2*w2D;
w1D = -w1D-pi; w2D = -w2D-pi;

if lower(type(1)) == 'i',
  fv2 = loc;
end;
if lower(type(1)) == 'j',
  fv2 = loc;
%  fv2(find(isinf(abs(fv2)))) = 0;
end;

% shift
fv2 = fv2 .* exp(-i*w1D);

acD2 = interp2(w1o,w2o,ac0,mod(w1,2*pi),mod(w2,2*pi),'*linear');

if lower(type(1)) == 'o',
  fv3 = sqrt(acD./acD2);
end;
if lower(type(1)) == 'b',
  fv3 = acD;
end;
if lower(type(1)) == 'd',
  fv3 = 1./acD2;
end;
if lower(type(1)) == 'i',
  fv3 = 1./ac;
end;

% scale relation
fv = 2^(gamma/2-1)*fv1.*fv2.*fv3;
%fv=fv1;
fv = ifftshift(fv);

% compute spatial version
v = ifft2(fv)*Z^2;

[x1,x2]=meshgrid(-N/4:1/Z:N/4-1/Z);
v=fftshift(v);
v=v((N*Z)/4:(N*Z)*3/4-1,(N*Z)/4:(N*Z)*3/4-1);
v=ifftshift(v);

surfl(x1,x2,fftshift(real(v))); shading flat; view(-26,44);
xlabel('x_1');
ylabel('x_2');
