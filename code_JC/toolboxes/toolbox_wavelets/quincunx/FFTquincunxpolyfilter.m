function [ac,acD,loc,B] = FFTquincunxpolyfilter(x,y,gamma,type)

% FFTQUINCUNXPOLYFILTER Supplies orthonormalizing part of the 2D polyharmonic 
%       spline filters for 2D quincunx transform.
%
% 	v=FFTquincunxpolyfilter(x,y,gamma,type)
%
% 	Input:
% 	x,y = coordinates in the frequency domain
% 	gamma = order of the filters, any real number >=0 
%
% Dimitri Van De Ville
%      Biomedical Imaging Group, BIO-E/STI
%      Swiss Federal Institute of Technology Lausanne
%      CH-1015 Lausanne EPFL, Switzerland
    

% Get dimensions
[m n]=size(x);
m=2*m; n=2*n;

% Construct fine grid [0,2pi[ x [0,2pi[
[xo,yo]=ndgrid(2*pi*([1:m]-1)/m,2*pi*([1:n]-1)/n);

warning off MATLAB:divideByZero;

% Refinement filter for [2 0; 0 2]
if upper(type(1)) == type(1),
  loc = 8/3*(sin(xo/2).^2+sin(yo/2).^2)+2/3*(sin((xo+yo)/2).^2+sin((xo-yo)/2).^2);
  H  = 2^(-gamma)*((8/3*(sin(xo).^2+sin(yo).^2)+2/3*(sin(xo+yo).^2+sin(xo-yo).^2))./loc).^(gamma/2);
else
  loc = sin(xo/2).^2+sin(yo/2).^2;
  H  = 2^(-gamma)*((sin(xo).^2+sin(yo).^2)./loc).^(gamma/2);
end;
H(find(isnan(H))) = 1;

% Autocorrelation function
ac = autocorr2d(H.^2);

% Construct fine grid [0,2pi] x [0,2pi]
[xo2,yo2]=ndgrid(2*pi*([1:m/2+1]-1)/(m/2),2*pi*([1:n/2+1]-1)/(n/2));

% Extend autocorrelation function
ac(m/2+1,:)=ac(1,:);
ac(:,n/2+1)=ac(:,1);

% Compute autocorrelation function on subsampled grid; D=[1 1; 1 -1]
x2=mod(xo2+yo2,2*pi);
y2=mod(xo2-yo2,2*pi);

% Compute values on grid (x,y)
%------------------------------
% Autocorrelation filter
acD= interp2(xo2,yo2,ac,mod(x+y,2*pi),mod(x-y,2*pi),'*nearest');
ac = interp2(xo2,yo2,ac,mod(x,2*pi),mod(y,2*pi),'*nearest');

% Localization operator
loc = interp2(xo,yo,loc,mod(x,2*pi),mod(y,2*pi),'*nearest');
loc = loc.^(gamma/2);

% Scaling filter for quincunx lattice
if upper(type(1)) == type(1),
   B = 2^(-gamma/2)*((8/3*(sin((x+y)/2).^2+sin((x-y)/2).^2)+2/3*(sin(x).^2+sin(y).^2))./(8/3*(sin(x/2).^2+sin(y/2).^2)+2/3*(sin((x+y)/2).^2+sin((x-y)/2).^2))).^(gamma/2);
else 
   B = 2^(-gamma/2)*((sin((x+y)/2).^2+sin((x-y)/2).^2)./(sin(x/2).^2+sin(y/2).^2)).^(gamma/2);
end;
B(find(isnan(B))) = 1;

