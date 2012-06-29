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

% Frequency range
par.f1_0 = [160 320 500];%Hz

% SL range
par.RL_0 = [145 160 177];%dB

% Duration
par.dur_0 = 2000;%ms

% Inswing range
par.rt_0 = [18 31 250];%ms
par.rt_end = 1800;%ms "outswing"

% Frequency sweep treatment
par.f_sweep = [160 500];% Frequency sweep
par.rt_sweep = 250;%Rise time
par.RL_sweep = 177;%Received level
par.dur_sweep = 5000;%ms
 
par.Fs = 8192;% Hz "sampling frequency"
par.N = 10;% Number of replicas in this block
par.Dt = 30;% Time between treatments within block
par.range = 1;%m Set this to one for SL's instead of RL's

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
Ni = randperm(k);
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

for i=1:K
    if par.F1(i)==par.F2(i)     % Tone signal
        % Raw singal
        t = t_tone;
        y_raw = sin(t*par.F1(i)*2*pi);
        % Add calibration
        [par.k(i) ampGain] = cp_CalibrationConstant(par.F1(i), par.RL(i), par.range);
        p_raw = par.k(i).*y_raw;
    else % The sweep signal
        % Frequency vector
        t = t_sweep;
        Fsweep = (1:N_sweep)./N_sweep*(par.F2(i)-par.F1(i))+par.F1(i);
        % Raw sweep signal
        y_raw = sin(t.*Fsweep.*2.*pi);
        warning('TODO: Add frequency dependent calibration!!!')
%         [par.k(i) ampGain] = cp_CalibrationConstant(par.F(i), par.RL(i), par.range);
%         p_raw = par.k(i).*y_raw;
        ampGain=NaN
        p_raw = y_raw;
    end
    
    % Linear inswing envelope
    env.t1 = [0 par.rt(i)/1000 par.rt_end/1000 t(end)];
    env.y1 = [0 1 1 0];
    y_env = interp1(env.t1,env.y1,t);
    
    % Enveloped signal
    p = p_raw.*y_env;
    
    % Play back signal and display gain information on screen

    disp(['Set AmpGain=',num2str(ampGain),'dB!! F=',num2str(par.F1(i)),'Hz, SL=',num2str(par.RL(i)),'dB, rt=',num2str(par.rt(i)),'ms'])
    for j=0:9
        disp(num2str(10-j))
%        pause(1)
        
    end
    %     close all
    %     plot(t,p)
    disp(['TX: AmpGain=',num2str(ampGain),'dB, F=',num2str(par.F1(i)),'Hz, SL=',num2str(par.RL(i)),'dB, rt=',num2str(par.rt(i)),'ms'])
    par.treat_start(i) = now;
    sound(p,par.Fs)
    par.treat_stop(i) = now;
    disp(['TX ending, wait',num2str(par.Dt-10),'s'])
 %   pause(par.Dt-10)
end

disp('Finished. Save the par variable!!!')
