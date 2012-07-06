clear

%
% This file prepares the vesselnoise treatment block. It reads the audio files,
% filters them and store them as wav files.
%
%
% Range of parameters to be tested:
%
% 1. GOS: realRL = ?
% 2. GOS: scaledRL = ?
% 3. JH: realRL = ?

vessel(1).treatment = 'JH_unfiltered';
vessel(2).treatment = 'GOS_unfiltered';
vessel(3).treatment = 'GOS_upscaled';

par.dt = 5;% pm 5 s to scalue up GOS
par.playBackStartPoint = [0 0 0]; % place in the file to start in seconds  
par.waitTime = 120; % duration pause between playbacks  in s
par.soundCard = '100 %';
par.amplifier='Caruso';
par.carusoCurrent=4;
par.carusoGain=[-8 -13 -6];
par.filePath='.\';  % path to write output files to
par.forceSoundPause=0; %whether to force a pause duining playback (Alex PC=1, Nils Olav=0)


% seed the random number generator
%reset(RandStream.getDefaultStream,sum(100*clock)) % works in r2010b and r2012a
reset(RandStream.getGlobalStream,sum(100*clock))  % works in r2012a
%% Load noise data
[ona.GOS.y,ona.GOS.FS,ona.GOS.NBITS] = wavread('NewGOSPass1wSound.wav');
[ona.JH.y,ona.JH.FS,ona.JH.NBITS] = wavread('NewJHPass1wSound.wav');
ona.JH.y = ona.JH.y(:,1);
ona.GOS.y = ona.GOS.y(:,1);

ona.GOS.t=(1:length(ona.GOS.y))/ona.GOS.FS;
ona.JH.t=(1:length(ona.JH.y ))/ona.JH.FS;
% dum1JH = onaJH.y(ona.JH.t<10);
% dum2JH = onaJH.y(ona.JH.t> (ona.JH.t(end)-10));
%
% sc1 = sqrt(mean(ona.JH.y(1:48000).^2))/sqrt(mean(dum1JH((end-48000:end)).^2));
% sc2 = sqrt(mean(dum1JH((1:48000)).^2))/sqrt(mean(ona.JH.y((end-48000:end)).^2));
% ona.JH.y = [dum1JH.*sc2; ona.JH.y; dum2JH.*sc2];

% 10 s ramp up and slodown
ramp_t=[0 3 30 32 120];
ramp_y=[0 1 1 0 0];
k = interp1(ramp_t,ramp_y,ona.JH.t);
ona.JH.y =  ona.JH.y'.*k;
k = interp1(ramp_t,ramp_y,ona.GOS.t);
ona.GOS.y =  ona.GOS.y'.*k;

% % % high pass filter
% Hd = cp_highpass_filter(ona.JH.FS); % Don't forget to tweak the parameters!!!
% ona.JH.p = filter(Hd.Numerator, 1, JH.p);
% ona.GOS.p = filter(Hd.Numerator, 1, GOS.p);
%
% % a filter to compensate for the CARUSO response
% Hd = cp_CarusoResponseFilter(ona.JH.FS);
% ona.JH.yf = filter(Hd, ona.JH.y);
% ona.GOS.yf = filter(Hd, ona.GOS.y);

%%

% Upscale GOS
ind = [(round(length(ona.JH.t)/2)-ona.JH.FS*par.dt):(round(length(ona.JH.t)/2)+ ona.JH.FS*par.dt)];
sc = mean(sqrt(ona.JH.y(ind).^2))/mean(sqrt(ona.GOS.y(ind).^2));

vessel(1).y = ona.JH.y;
vessel(2).y = ona.GOS.y.*(sqrt(2));
vessel(3).y = ona.GOS.y.*sc;

vessel(1).FS = ona.JH.FS;
vessel(2).FS = ona.GOS.FS;
vessel(3).FS = ona.GOS.FS;




% visualise the signals
% clf
% subplot(2,1,1)
% spectrogram(JH.y, 256, 64, [0:100:5000], 48000)
% subplot(2,1,2)
% spectrogram(JH.p, 256, 64, [0:100:5000], 48000)




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

%semilogx(ona.GOS_h(:,1)*1000,ona.GOS_h(:,2),ona.JH_h(:,1)*1000,ona.JH_h(:,2))


ind = ona.GOS_h(:,1)*1000>50  & ona.GOS_h(:,1)*1000 < 2000;

10*log10(trapz(ona.GOS_h(ind,1)*1000,10.^(ona.GOS_h(ind,2)/10)))
10*log10(trapz(ona.JH_h(ind,1)*1000,10.^(ona.JH_h(ind,2)/10)))

% SPL 50Hz-1kHz



%%
% cpscr_whaletreatmentblock
%
% script to present 3 whale calls in random order during Collpen expts

% 1) Johan Hjort at SPL equivalent to that observed duing Ona et al expt at 30m
% 2) G.O. Sars at SPL equivalent to that observed duing Ona et al expt at 30m
% 2) G.O. Sars at SPL equivalent to that observed duing Ona et al expt at 30m



% compute playback duration (used for start and stop times)
par.playBackDuration=[length(vessel(1).y)/vessel(1).FS length(vessel(1).y)/vessel(2).FS length(vessel(1).y)/vessel(3).FS];

%%%%%%% prompt for changes
disp('Check Caruso is connected and hit any key')
pause
disp(['Check Caruso current is  ' num2str(par.carusoCurrent) ' amps and hit any key'])
pause
disp('Check PC times and hit any key')
pause
disp('check that sound card output is set to 100% and hit a key')
pause

pause
%%%%  present the stimuli in random order


par.randTrial=randperm(3);
for i=1:length(par.randTrial)
    
   disp('NOTE THAT WE ARE NOW CHANGING GAINS DURING THIS TRIAL')
   disp(['Set AmpGain=',num2str(par.carusoGain(par.randTrial(i))),'dB! and press any key' ])
    pause
    disp('.')
   if i==1
    disp('READY? the experiment starts on next keypress')
    pause
   end
   
    par.treatStart(i)=now;
    
    % play the sound
    disp(['Playback: ',num2str(i),' ', vessel(par.randTrial(i)).treatment]);
    sound(vessel(par.randTrial(i)).y,vessel(par.randTrial(i)).FS);
    
    if par.forceSoundPause==1
        pause;
        disp('.');
        disp('forcing pause during playback') ; %needed if PC keeps executing during pause
    end
    par.treatEnd(i)=now;
    disp('playback over')
    disp('.');
    par.treatment(i)=par.randTrial(i); % assing treatment name
    par.carusoGainOrdered(i)=(par.carusoGain(par.randTrial(i)));
    if i<length(par.randTrial) % pause
        disp(['waiting ' num2str(par.waitTime) ' sec'])
        pause(par.waitTime)
    end
end




% write files
%set filename
fname=strcat(par.filePath ,'VesselParams_',datestr(now,30));

eval(['save ', fname, ' par'])   % save parameter file in mat format

% now build up the output for excel
% prepare a cell array for export

% headers
a{1,1}='t_start_time';
a{1,2}='t_stop_time';
a{1,3}='t_soundsource';
a{1,4}='treatment';
a{1,5}='Caruso current';
a{1,6}='Caruso Gain';


% place data in cell array
for i=2:length(par.treatStart)+1
    a{i,1}=datestr(par.treatStart(i-1),'dd.mm.yy HH:MM:SS');
    a{i,2}=datestr(par.treatEnd(i-1),'dd.mm.yy HH:MM:SS');
    a{i,3}=par.amplifier;
    
    a{i,4}=par.treatment(i-1); % code for each treatment - could be replaced by a string later if desired
    a{i,5}=par.carusoCurrent;
    a{i,6}=par.carusoGainOrdered(i-1);
       
  
 
end

xlswrite(fname,a) % write out xls file

disp('Finished !')
