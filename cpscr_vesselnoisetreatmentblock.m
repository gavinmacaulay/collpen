clear

%  
% This file rund the vesselnoise treatment. It reads the audio files,
% scales the level and play them back 
%
%
% NB: Note that the gain needs to be adjusted on the amplifier during trials.
%  
% Range of parameters to be tested:
%  
% 1. GOS: realSPL = ?
% 2. GOS: maxSPL = ?
% 3. JH: realSPL = ?
% 4. JH: maxSPL = ?

% Nils Olav:
% Suck the sound and store it to matlab - OK
% Make a loopable signal
% Create a 20log r envelope on the signal
% 
% Gavin:
% High pass filter - OK
% Frequncy respone filter - OK
% Calibration to get "real" spl's 

par.vesselspeed = 11*1800/3600;%m/s
par.vesselstart = -3*60;%sek
par.vesselstop =   1*60;%sek
par.fishdepth = 30;%m This is hte upper depth of the fish layer from the Ona paper

par.pause = 30;%s pause between treatments
par.order = randperm(2);%1==GOS, 2==JH

%% Load noise data
[dumGOS,ona.GOS.FS,ona.GOS.NBITS] = wavread('NewGOSPass1wSound.wav');
[dumJH,ona.JH.FS,ona.JH.NBITS] = wavread('NewJHPass1wSound.wav');

% Pick the signal at passing
indGOS = (9.5*10^5):(1.05*10^6);
indJH = (9.5*10^5):(1.05*10^6);

% The number of chunks to build the whole signal
Nc = ceil((par.vesselstop - par.vesselstart)/(length(indGOS)/ona.JH.FS));

% Create the merged signal
JH.y  = repmat(dumJH(indJH),[1 Nc]);
GOS.y = repmat(dumGOS(indGOS),[1 Nc]);
t = (1:length(JH.y))/ona.JH.FS + par.vesselstart;


% The range to the source
r = sqrt((t.*par.vesselspeed).^2 + par.fishdepth.^2);

% Apply 20logr TVG (note that this is on pressure and should be /r)
tvg = 10*log10(r);
JH.y_tvg = JH.y./r;
GOS.y_tvg = GOS.y./r;

% Apply calibration etc 
JH.p = JH.y_tvg;
GOS.p = GOS.y_tvg;

% high pass filter
Hd = cp_highpass_filter(); % Don't forget to tweak the parameters!!!
JH.p = filter(Hd.Numerator, 1, JH.p);
GOS.p = filter(Hd.Numerator, 1, GOS.p);

% a filter to compensate for the CARUSO response
Hd = cp_CarusoResponseFilter;
JH.p = filter(Hd, JH.p);
GOS.p = filter(Hd, GOS.p);

% scale signal
JH.p = JH.p / max(JH.p);
GOS.p = GOS.p / max(GOS.p);

% and then work out the SPL for a given sound card output level, amplifier
% gain and range 
range = 33; % [m]
amp_gain = -10;

% NOT DONE YET.....
% Thinking so far:
% value of 1 in playback signal, through amplifier with gain of -10 dB
% gives SL as per the 4A calibration. These data are:
calSL = [162.2637
    178.8809
    177.6352
    180.0815
    178.7463
    177.2745
    176.2 %180.1863
    175.3353
    175.7558
    170.0725
    169.5239
    ];
% so do fft, get the right magnitude for the PSD, apply these cal SL to
% give the expected SL in the water, then apply the TL.


% visualise the signals
% clf
% subplot(2,1,1)
% spectrogram(JH.y, 256, 64, [0:100:5000], 48000) 
% subplot(2,1,2)
% spectrogram(JH.p, 256, 64, [0:100:5000], 48000) 

%% Play back signal

warning('Using scaled sound!! Needs calibration and filtering')

k=1;
for i=par.order
    if i==1
        par.start(k) = now;
        soundsc(JH.p,ona.JH.FS)
        pause(par.pause)
        k=k+1;
    else
        par.start(k) = now;
        soundsc(GOS.p,ona.GOS.FS)
        pause(par.pause)
        k=k+1;
    end
end

%% The curves from GOS and JH

%GOS
ona.GOS =[193.3948  215.2115;...
  218.2033  172.9038;...
  229.3491  208.8654;...
  242.6522  203.7885;...
  267.1011  202.9423;...
  277.1683  197.4423;...
  290.8310  212.2500;...
  302.6959  181.7885;...
  326.0662  204.6346;...
  338.2907  154.2885;...
  349.0769  193.2115;...
  372.8068  203.3654;...
  386.1099  222.8269;...
  398.6939  221.9808;...
  409.1206  232.5577;...
  422.0642  253.7115;...
  434.2886  265.9808;...
  446.1536  268.9423;...
  461.2544  281.6346;...
  482.4674  299.8269];
  
ona.JH = [193.7544  169.5192;...
  204.9002   88.7115;...
  218.2033  173.7500;...
  230.7873  160.6346;...
  253.7981  107.7500;...
  265.6630  130.5962;...
  276.8088   91.6731;...
  290.8310   95.9038;...
  302.3364   89.5577;...
  314.2013   78.9808;...
  339.0097   75.5962;...
  361.6610  107.3269;...
  374.6045   95.4808;...
  397.9748  134.4038;...
  422.4237  144.9808;...
  445.7940  147.0962;...
  458.3780  158.5192;...
  482.4674  169.5192];
  
  
ona.XY =[145.5756  320.5577;...
  265.3034  208.0192;...
  386.1099   94.6346];

  
ona.XY_h =[log10(0.0100)  100.0000;...
    log10(0.1000)  120.0000;...
    log10(1.0000)  140.0000];
    
ona.GOS_h = [10.^(interp1(ona.XY(:,1),ona.XY_h(:,1),ona.GOS(:,1),'linear','extrap')) ...
    interp1(ona.XY(:,2),ona.XY_h(:,2),ona.GOS(:,2),'linear','extrap')];

ona.JH_h	 = [10.^(interp1(ona.XY(:,1),ona.XY_h(:,1),ona.JH(:,1),'linear','extrap')) ...
    interp1(ona.XY(:,2),ona.XY_h(:,2),ona.JH(:,2),'linear','extrap')];

semilogx(ona.GOS_h(:,1),ona.GOS_h(:,2),ona.JH_h(:,1),ona.JH_h(:,2))

% SPL 50Hz-1kHz

save(['HerringExp_vesselNoise_par_',datestr(now,30),'.mat'],'par')


