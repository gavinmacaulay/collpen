clear
% cpssc_multimodealtreatmentblock
% 
% script to run a single tone in combination with the predator trials for a
% multimodal stimulus (visual, particle motion, auditory)
%
% NB: Note that the gain needs to be adjusted on the amplifier during trials.
%
% Range of parameters to be tested:
%
% Frequency – 160,  Hz
% Source level – 175 dB
% Tone duration – 2000 ms
% Tone rise time 18 ms
%
%
% Based on previous experiments (e.g. Karlsen & Echof, 2011, LowFreq
% project) rise time and frequency are likely to come out as the most
% important parameters, while duration and source level will likely be of
% less importance. However, this is a simple experiment to verify this

%par.filePath='c:\Collpen\Processing\'  % path to write output files to
par.filePath = './';  % path to write output files to
% Frequency range
par.f1_0 = 160%[160 ];%Hz  WE DECIDED THIS SHOULD BE 160 Hz

% SL range
par.RL_0 = [175];%dB
 
% Inswing range
par.rt_0 = [18];%ms
par.rt_end = 1800;%ms "outswing"

% Duration
par.dur_0 = 2000;%ms
par.Fs = 8192;% Hz "sampling frequency"
par.Dt = 120;% Time between treatments within block
par.Dt = 120;% Time between treatments within block
par.range = 1;%m Set this to one for SL's instead of RL's
par.N = 5;% Number of replicas in this block  
par.showImg=1;

par.predName={'Black bottle+tone','Clear bottle+tone','Flat black+tone','Flat clear+tone','Control+tone'};

par.order=randperm(par.N); % order

% MultiModal predator model tests
disp ('Predator Orders')
for i=1:length(par.order);
   disp( par.predName(par.order(i)))
end

%% Create treatment data



% Create combined treatment vectors (not randomized)


            par0.F1(1:par.N) = par.f1_0;
            par0.F2(1:par.N) = par.f1_0;
            par0.RL(1:par.N) = par.RL_0;
            par0.rt(1:par.N) = par.rt_0;
            par0.dur(1:par.N) = par.dur_0;

% Randomize the order of the treatments
sub = randperm(par.N);
Ni = sub(randperm(par.N));

par.F1 = par0.F1(par.order);
par.F2 = par0.F2(par.order);
par.RL = par0.RL(par.order);
par.rt = par0.rt(par.order);
par.dur = par0.dur(par.order);


%% Create the signal
close all
N = par.dur/1000*par.Fs;
% Time vector
t_tone = (1:N)/par.Fs;


for i=1:length(par.F1)
    
        % Raw singal
        t = t_tone;
        y_raw = sin(t*par.F1(i)*2*pi);
        % Add calibration
        [k par.ampGain(i) par.carusoCurrent(i)] = cp_CalibrationConstant(par.F1(i), par.RL(i), par.range);
        p_raw = k.*y_raw;
    
    
    % Linear inswing envelope
    env.t1 = [0 par.rt(i)/1000 par.rt_end/1000 t(end)];
    env.y1 = [0 1 1 0];
    y_env = interp1(env.t1,env.y1,t);
    
    % Enveloped signal
    p = p_raw.*y_env;
    
    % Play back signal and display gain information on screen
      
   
    disp(['Next Predator: ' ,par.predName{par.order(i)}]);
    disp(['Make sure you made a new hydrophone file - tone number is: ' num2str(i)]);
    disp('.')
    
    if i==1
           disp(['TONE SETTINGS Set AmpGain=',num2str(par.ampGain(i)),'dB! AmpCurrent=', num2str(par.carusoCurrent(i)),' F1=',num2str(par.F1(i)),' F2=',num2str(par.F2(i)),'Hz, SL=',num2str(par.RL(i)),'dB, rt=',num2str(par.rt(i)),'ms'])
        disp('.')
        disp('READY ? the experiment starts on next keypress')
     pause
    elseif i>1
        disp(['Waiting for ' num2str(par.Dt) ' s before next sound.'])
        pause(par.Dt)
    end
    disp('.')
    disp('Press any key to play sound')
    pause
    disp(['TX: ',num2str(i), ' AmpGain=',num2str(par.ampGain(i)),'dB! AmpCurrent=', num2str(par.carusoCurrent(i)),' F1=',num2str(par.F1(i)),' F2=',num2str(par.F2(i)),'Hz, SL=',num2str(par.RL(i)),'dB, rt=',num2str(par.rt(i)),'ms'])

    par.treat_start(i) = now;
    sound(p,par.Fs)
    par.treat_stop(i) = now;
    disp('Break the hydrophone file')
    disp('.') % leave some space for legibility
    disp('.') % leave some space for legibility
   
    
end



%set filename
fname=strcat(par.filePath ,'MultiModalParams_',datestr(now,30));

eval(['save ', fname,' par'])   % save parameter file in mat format

% now build up the output for excel
% prepare a cell array for export

% headers
a{1,1}='t_start_time';
a{1,2}='t_stop_time';
a{1,3}='t_soundsource';
a{1,4}='t_carusocurrent';
a{1,5}='t_amplifiergain';
a{1,6}='t_F1';
a{1,7}='t_F2';
a{1,8}='t_SL';
a{1,9}='t_duration';
a{1,10}='t_rt';
a{1,11}='treatmentType';

% place data in cell array (yes this can be vectorized but already did this...
for i=2:length(par.F1)+1
    a{i,1}=datestr(par.treat_start(i-1),'dd.mm.yy HH:MM:SS');
    a{i,2}=datestr(par.treat_stop(i-1),'dd.mm.yy HH:MM:SS');
    a{i,3}='Caruso';
    a{i,4}=par.carusoCurrent(i-1);
    a{i,5}=par.ampGain(i-1);
    a{i,6}=par.F1(i-1);
    a{i,7}=par.F2(i-1);
    a{i,8}=par.RL(i-1);
    a{i,9}=par.dur(i-1);
    a{i,10}=par.rt(i-1);
    a{i,11}=par.predName{par.order(i-1)};   
end



xlswrite(fname,a) % write out xls file

disp('(no problem if crashes after this line)')

% just for fun
if par.showImg==1
figure
[X,map] = imread('monkeyPic.jpg');
image(X)
title('Nice Work Monkey Boys - maybe you will get another hard drive reward')
 pause(10) % hold figure and then close
    close
end

