%% script to prepare the killer whale sounds for playback

[p fs] = wavread('file03_Herring_Stim_2.wav');
p = p(1:floor(length(p)/3));
wavwrite(p, fs, 'Norwegian orca calls.wav')

[p fs] = wavread('oo181a09_11to22min_monoLeft_filter400Hz_resample44100.wav');
p = p(1:floor(length(p)/3));
wavwrite(p, fs, 'Canadian orca calls.wav')


[p1 fs] = wavread('example2.WAV');
[p2 fs] = wavread('example3.WAV');
p = [p1(:,1); p2(:,1)];

p = [p; p; p; p; p; p; p; p; p; p];
p = p(1:fs*5*60);
wavwrite(p, fs, 'Icelandic orca calls.wav')
