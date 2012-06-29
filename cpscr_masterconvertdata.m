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

% SL range
par.RL_0 = [145 177 145 177];%dB

% Duration
par.dur_0 = 2000;%ms Symmetric around "before after"
 
par.Dt = 30;% Time between treatments within block
par.range = 1;%m Set this to one for SL's instead of RL's

%% Create treatment data

% Create combined treatment vectors (not randomized)
k=1;
for i=1:4
    for l=1:length(par.rt_0)
        par0.RL(k) = par.RL_0(j);
        par0.rt(k) = par.rt_0(l);
        par0.dur(k) = par.dur_0;
        k=k+1;
    end
end

im=imread('noiselevels.bmp');


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
    %sound(p,par.Fs)
    par.treat_stop(i) = now;
    disp(['TX ending, wait',num2str(par.Dt-10),'s'])
 %   pause(par.Dt-10)
end

disp('Finished. Save the par variable!!!')


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

  
ona.XY_h =[0.0100  100.0000;...
    0.1000  120.0000;...
    1.0000  140.0000];
    
ona.GOS_h = [interp1(ona.XY(:,1),ona.XY_h(:,1),ona.GOS(:,1),'extrap','linear') ...
    interp1(ona.XY(:,2),ona.XY_h(:,2),ona.GOS(:,2),'extrap','linear')];


  