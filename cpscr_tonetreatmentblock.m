clear
%
% The purpose of this test is to show the relative importance of the
% parameters frequency, rise, time and source level. Combintation from the
% different variables are run in a randomized order.
%
% NB: Note that the gain needs to be adjusted on the amplifier during trials.
%
% Range of parameters to be tested:
%
% Frequency – 160, 320, 500 Hz
% Source level – 157 167 177 dB
% Tone duration – 2000 ms
% Tone rise time 18, 31, 250 ms
%
% Two upsweep signals are added at random in between the tone treatments
%
% Based on previous experiments (e.g. Karlsen & Echof, 2011, LowFreq
% project) rise time and frequency are likely to come out as the most
% important parameters, while duration and source level will likely be of
% less importance. However, this is a simple experiment to verify this

%par.filePath='c:\Collpen\Processing\'  % path to write output files to
par.filePath = './';  % path to write output files to
% Frequency range
par.f1_0 = [160 320 500];%Hz
par.f_sweep = [160 500];% Frequency sweep

% SL range
par.RL_0 = [155 165 175];%dB
par.RL_sweep = 175;%Received level

% Duration
par.dur_0 = 2000;%ms
par.dur_sweep = 5000;%ms

% Inswing range
par.rt_0 = [18 31 250];%ms
par.rt_end = 1800;%ms "outswing"
par.rt_sweep = 250;%Rise time


par.Fs = 8192;% Hz "sampling frequency"
par.Dt = 30;% Time between treatments within block
par.Dt = 1;% Time between treatments within block
par.range = 1;%m Set this to one for SL's instead of RL's
par.N = 10;% Number of replicas in this block - sweeps


%% Create treatment data

% Create combined treatment vectors (not randomized)
k=1;
for i=1:length(par.f1_0)
    for j=1:length(par.RL_0)
        for l=1:length(par.rt_0)
            par0.F1(k) = par.f1_0(i);
            par0.F2(k) = par.f1_0(i);
            par0.RL(k) = par.RL_0(j);
            par0.rt(k) = par.rt_0(l);
            par0.dur(k) = par.dur_0;
            k=k+1;
        end
    end
end

% Include metainformation for the upsweep/downsweep

% Upsweep
par0.F1(k) = par.f_sweep(1);
par0.F2(k) = par.f_sweep(2);
par0.RL(k) = par.RL_sweep;
par0.rt(k) = par.rt_sweep;
par0.dur(k) = par.dur_0;
k=k+1;

% Downsweep
par0.F1(k) = par.f_sweep(2);
par0.F2(k) = par.f_sweep(1);
par0.RL(k) = par.RL_sweep;
par0.rt(k) = par.rt_sweep;
par0.dur(k) = par.dur_0;

% The number of different treatments:
K=k;

% Randomize the order of the treatments
sub = randperm(K-2);
sub2 = [sub(1:par.N) K-1 K];
Ni = sub2(randperm(par.N+2));

par.F1 = par0.F1(Ni);
par.F2 = par0.F2(Ni);
par.RL = par0.RL(Ni);
par.rt = par0.rt(Ni);
par.dur = par0.dur(Ni);


%% Create the signal
close all
N = par.dur/1000*par.Fs;
N_sweep = par.dur_sweep/1000*par.Fs;
% Time vector
t_tone = (1:N)/par.Fs;
t_sweep = (1:N_sweep)/par.Fs;

for i=1:length(par.F2)
    if par.F1(i)==par.F2(i)     % Tone signal
        % Raw singal
        t = t_tone;
        y_raw = sin(t*par.F1(i)*2*pi);
        % Add calibration
        [k par.ampGain(i) par.carusoCurrent(i)] = cp_CalibrationConstant(par.F1(i), par.RL(i), par.range);
        p_raw = k.*y_raw;
    else % The sweep signal
        % Frequency vector
        t = t_sweep;
        Fsweep = (1:N_sweep)./N_sweep*(par.F2(i)-par.F1(i))+par.F1(i);
        % Raw sweep signal
        y_raw = sin(t.*Fsweep.*2.*pi);
        [k tempAmpGain tempCarusoCurrent] = cp_CalibrationConstant(Fsweep, par.RL(i), par.range);
        % assigning Gain and Current to list of parameters
        par.ampGain(i)=tempAmpGain(1);
        par.carusoCurrent(i)=tempCarusoCurrent(1);
        % adjsuting sweep for caruso response (k i s frequency dependent
        % vector)
        p_raw = k.*y_raw;
    end
    
    % Linear inswing envelope
    env.t1 = [0 par.rt(i)/1000 par.rt_end/1000 t(end)];
    env.y1 = [0 1 1 0];
    y_env = interp1(env.t1,env.y1,t);
    
    % Enveloped signal
    p = p_raw.*y_env;
    
    % Play back signal and display gain information on screen
    
    disp(['NEXTTONE Set AmpGain=',num2str(par.ampGain(i)),'dB! AmpCurrent=', num2str(par.carusoCurrent(i)),' F2=',num2str(par.F1(i)),' F2=',num2str(par.F2(i)),'Hz, SL=',num2str(par.RL(i)),'dB, rt=',num2str(par.rt(i)),'ms'])
    
    if i>1
        disp(['Waiting for ' num2str(par.Dt) ' s before next sound.'])
        pause(par.Dt)
    end
    disp('Press any key when amplifier gain is set.')
    pause
    disp(['TX: ',num2str(i), ' AmpGain=',num2str(par.ampGain(i)),'dB! AmpCurrent=', num2str(par.carusoCurrent(i)),' F1=',num2str(par.F1(i)),' F2=',num2str(par.F2(i)),'Hz, SL=',num2str(par.RL(i)),'dB, rt=',num2str(par.rt(i)),'ms'])

    par.treat_start(i) = now;
    sound(p,par.Fs)
    par.treat_stop(i) = now;
    
    disp('.') % leave some space for legibility
    disp('.') % leave some space for legibility
    
end

%set filename
fname=strcat(par.filePath ,'ToneParams_',datestr(now,30));

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

% place data in cell array
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
end

xlswrite(fname,a) % write out xls file

disp('Finished !')