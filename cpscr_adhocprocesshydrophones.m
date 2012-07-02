%%
%
dataDir = 'C:\Users\gavinj\Documents\G drive\Projects\2011 CollPen\2012 June\PVexp\block2\hydrophones';
filename = 'runZ1';

% just keep ch 17 & 18, as they are the only ones with a proper calibration
sig.v = data.values(:,17:18);
clear data

p_ref = 1e-6;

% calibrate
sig.p(:,1) = sig.v(:,1) * 115.4; % [V * Pa/V]
sig.p(:,2) = sig.v(:,2) * 37.6; % [V * Pa/V]

sig.SPL = 20*log10(sig.p ./ p_ref);

