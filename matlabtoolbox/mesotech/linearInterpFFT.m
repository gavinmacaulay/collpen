%this is the linear interpolation using FFT. 
%Input: x: the data to be interpolated
%       xIndex: the actual index for x
%       R_M: Interpolation factor
%Output: y: the data after the interpolation
%       yIndex: the index after the interpolation

function [y,yIndex]=linearInterpFFT(x, xIndex,R_M)
% Interpolation using zero padding in the frequence domain (fft)
[row,col]=size(x);
if col~=1
    x=x.'; %convert it to colomn vector
end

[row,col]=size(xIndex);
if col~=1
    xIndex=xIndex.';
end

if ~isreal(x)
    x=abs(x); % Note: interpolation is done on the absolute values to avoid
% "zero-crossing" issues that can occur when interpolating real and
% imaginary components separately.
end
Fy = fft(x);   
nFy = length(Fy);   % length of x
N = nFy*R_M;        % final length of interpolated vector
nzs = N - nFy;      % number of zeros to add
zpd = zeros(nzs,1); % vector of zeros to add
if mod(nFy,2)==0
    nmid = nFy/2;
else
    nmid = (nFy+1)/2;
end
zpdFy = [Fy(1:nmid); zpd; Fy(nmid+1:end)]; % insert the zeros
y = ifft(zpdFy)*R_M;
y = y(1:end-R_M+1);
yIndex = linspace(xIndex(1), xIndex(end), length(y));
