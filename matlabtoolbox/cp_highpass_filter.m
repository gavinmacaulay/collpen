function Hd = cp_highpass_filter
%CP_HIGHPASS_FILTER Returns a discrete-time filter object.

%
% MATLAB Code
% Generated by MATLAB(R) 7.14 and the Signal Processing Toolbox 6.17.
%
% Generated on: 01-Jul-2012 21:44:36
%

% Equiripple Highpass filter designed using the FIRPM function.

% All frequency values are in Hz.
Fs = 10000;  % Sampling Frequency

Fstop = 50;              % Stopband Frequency
Fpass = 100;             % Passband Frequency
Dstop = 0.0001;          % Stopband Attenuation
Dpass = 0.057501127785;  % Passband Ripple
dens  = 20;              % Density Factor

% Calculate the order from the parameters using FIRPMORD.
[N, Fo, Ao, W] = firpmord([Fstop, Fpass]/(Fs/2), [0 1], [Dstop, Dpass]);

% Calculate the coefficients using the FIRPM function.
b  = firpm(N, Fo, Ao, W, {dens});
Hd = dfilt.dffir(b);

% [EOF]
