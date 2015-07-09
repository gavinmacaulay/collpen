function y = perform_wavelet_transform_classical(x,Jmin,dir, g,h, options)

% wavelet_transform_fwd - perform forward 1D wavelet transform
%
%   !! THIS CODE DOES NOT WORK CORRECTLY !!
%
% y = perform_wavelet_transform_classical(x,Jmin,dir, g,h, options)
%
%   'x' is the original signal.
%   'g' is the low pass filter.
%   'h' is the high pass filter.
%   'J' is the number of scale for the transform.
%
%   'options' is a struct that can contains
%       - 'bound': boundary extension (eiter 'sym' or 'per').
%
%   Copyright (c) 2005 Gabriel Peyré

x = x(:);
g = g(:);
h = h(:);
n = length(x);

if nargin<6
    options.null = 1;
end
if nargin<5
    dir = 1;
end
if nargin<4
   J = floor(log2(n));
end
if nargin<3
    h = mirror_filter(g);
end

if isfield(options, 'bound')
    bound = options.bound;
else
    bound = 'sym';
end



if log2(length(x))<=2^(Jmin-1);
   y = x;
   return;
end
    
    
if dir==1
    
    % Forward transform
    a1 = perform_convolution(x,g, bound);
    a2 = perform_convolution(x,h, bound);
    
    y = [ perform_wavelet_transform_classical(a1(1:2:end),Jmin,dir,g,h,options); a2(1:2:end) ];
    
else
    
    % Backward transform
    
    a1 = zeros(n,1); a2 = a1;
    a1(1:2:end) = perform_wavelet_transform_classical( x(1:end/2),Jmin,g,h, dir, options);
    a2(1:2:end) = x(end/2+1:end);
    
    if 1 % mod(length(g),2)==0
        % shift the filter of 1/2 for even length    
        h = [h;0];
        g = [g;0];
    end

    y = perform_convolution(a1,g,bound) - perform_convolution(a2,h,bound);
    
end