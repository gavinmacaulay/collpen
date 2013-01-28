%%
% matlab code
% This creates a synthetic upsweep stimuli for the Caruso source
Fs = 10000;%Samplingfrequency Hz
F1 = 5;%Lower frequency for upsweep Hz
F2 = 500;%Higher frequency for upsweep Hz
% Time vector
t  = 1:(1/Fs):10;%20 sek length
f = F1+(F2-F1)*(1:length(t))/length(t);
% Upsweep from F1 to F2
y = real(exp(-i*2*pi.*f.*t));
wavwrite(y,Fs,32,fullfile('../data', 'upsweep.wav'))


%%
% single freq tone
f = [5:5:100 200:100:1000]; % Hz
%f = 4000;
Fs = 10000; % sampling freq Hz
% Time vector
t  = 1:(1/Fs):10;% length s
for i = 1:length(f)
    y = real(exp(-1j*2*pi.*f(i).*t));
    wavwrite(y,Fs,32,fullfile('../results/tones', ...
        ['tone_' num2str(f(i), '%04.f') '_Hz.wav']))
end

%%
% play back the sounds
d = dir('../results/tones/tone_*.wav');

for i = 1:length(d)
    disp(['Playing ' d(i).name])
    [y f] = wavread(fullfile('../results/tones/', d(i).name));
    y = double(y);
    max_sig = max(abs(y));
    y = y / max_sig;
    pl = audioplayer(y, f);
    playblocking(pl)
end


