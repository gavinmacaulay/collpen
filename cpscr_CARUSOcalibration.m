function [SL, avgSL] = cpscr_CARUSOcalibration()
%%
%

% calibration of channel 17 

load('C:\Users\gavinj\Documents\G drive\Projects\2011 CollPen\2012 June\PVexp\block2\hydrophones\runZ1')

% just keep ch 17
sig = data.values(:,17);
clear data

%%
start_sample = 1173813; % 80 Hz, first repeat
repeat_length = 861399; % 1960755+45622;
tone_repeat = 50107;
tone_length = 44000;
trim = 0.1*tone_length;
repeats = 15;

freqs = [80 150 225 300 400 600 750 900 1000 1250 1500];

r_ref = 1; % [m]
p_ref = 1e-6; % [Pa]
range = 33; %22.6; % [m]  ESTIMATE!!!

clear SL

% Make filters
disp('Making filters')
for i = 1:length(freqs)
    Hd(i) = cp_bandpass_filter(freqs(i));
end

disp('Processing data')
for j = 0:repeats-1
    for i = 0:length(freqs)-1
        start = start_sample + j*repeat_length + i*tone_repeat;
        stop = start + tone_length;
        
        d = sig(start+trim:stop-trim*1.1);
        
        % apply calibration. Converts from volts to Pascals
        d = d * 115.4; % [V * Pa/V], inner hydrophone   
        plot(d)
        
        %Hd = cp_bandpass_filter(freqs(i+1));
        y = filter(Hd(i+1).Numerator, 1, d);
        
        % calculate SPL
        SPL = 20*log10(rms(y) / p_ref);
        
        % TL
        TL = 20*log10(range/r_ref);
        
        % estimate SL of sound source
        SL(i+1,j+1) = SPL + TL;
        
    end    
end

% plot the curves
clf
for i = 1:repeats
    plot(freqs, SL(:,i),'.')
    hold on
end

% plot the average
press = 10.^(SL/20);
avg = mean(press, 2);
avgSL = 20*log10(avg);
plot(freqs, avgSL, 'r', 'LineWidth', 2);

