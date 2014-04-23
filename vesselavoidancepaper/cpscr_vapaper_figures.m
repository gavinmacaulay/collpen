%% This script plot the figures for the VA paper.
clear
close all

par.datadir = '\\callisto\collpen\AustevollExp\data\HERRINGexp';
par.reposdir = 'C:\repositories\CollPen_mercurial\matlabtoolbox';

file = fullfile(par.datadir,'CollPenAustevollLog.xls');
block = cp_GetExpPar(file);

% Pick 3 examples

%21	1	1	block21_1_1
%21	1	2	block21_1_2
%21	1	3	block21_1_3

%1=GOS
%2=GOSup
%3=JH

% Figure 1(a)
F{1,1}=[24 1 1];
F{1,2}=[24 1 2];
F{1,3}=[24 1 3];

% Figure 1(b)
F{2,1}=[24 1 1];
F{2,2}=[24 1 2];
F{2,3}=[24 1 3];

% Figure 1(c)
F{3,1}=[24 1 1];
F{3,2}=[24 1 2];
F{3,3}=[24 1 3];

par.avgtime = 0.1;%s
par.p_ref = 1e-6; % [Pa]


% % Equiripple Bandpass filter designed using the FIRPM function.
% 
% % All frequency values are in Hz.
% Fs = 10000;  % Sampling Frequency
% 
% Fstop1 = 40;                % First Stopband Frequency
% Fpass1 = 100;               % First Passband Frequency
% Fpass2 = 1000;              % Second Passband Frequency
% Fstop2 = 2000;              % Second Stopband Frequency
% Dstop1 = 0.000177827941;    % First Stopband Attenuation
% Dpass  = 0.00057564620966;  % Passband Ripple
% Dstop2 = 0.000177827941;    % Second Stopband Attenuation
% dens   = 20;                % Density Factor
% 
% % Calculate the order from the parameters using FIRPMORD.
% [N, Fo, Ao, W] = firpmord([Fstop1 Fpass1 Fpass2 Fstop2]/(Fs/2), [0 1 ...
%                           0], [Dstop1 Dpass Dstop2]);
% 
% % Calculate the coefficients using the FIRPM function.
% b  = firpm(N, Fo, Ao, W, {dens});
% Hd = dfilt.dffir(b);

Fs = 10000;  % Sampling Frequency

Fpass = 1000;            % Passband Frequency
Fstop = 1100;            % Stopband Frequency
Dpass = 0.057501127785;  % Passband Ripple
Dstop = 0.0001;          % Stopband Attenuation
dens  = 20;              % Density Factor

% Calculate the order from the parameters using FIRPMORD.
[N, Fo, Ao, W] = firpmord([Fpass, Fstop]/(Fs/2), [1 0], [Dpass, Dstop]);

% Calculate the coefficients using the FIRPM function.
b  = firpm(N, Fo, Ao, W, {dens});
Hd = dfilt.dffir(b);

% Time definition of NULL and TREAT for vessel avoidance
par.ek60.preRefTimeVA = ([-152 -88]+21);% time in seconds to define the reference window for vessel avoidance (adjusted for the difference bewtween start time and max pressure, i.e +21s)
par.ek60.passTimeVA   = [-3 3]+21;%

for i=1:3
    for j=1:3
        disp(['i:',num2str(i),'/3 j:',num2str(j),'/3'])
        % Load hydrophone data
        file = fullfile(par.datadir,['block',num2str(F{i,j}(1))],'hydrophones',...
            [num2str(F{i,j}(1)),'_',num2str(F{i,j}(2)),'_',num2str(F{i,j}(3)),'.mat']);
        if exist(file,'file')
            disp(file)
            load(file)
            nexus1 = 17;
            nexus2 = 18;
            %     nexus1 = 1;
            %     nexus2 = 2;
            par.Fs=data.sample_rate(nexus1);
            par.start_time=data.start_time(nexus1);
            par.avg_bin=floor(par.Fs*par.avgtime);  % average into 1/10 second  bins
            
            % Low Pass Filter the data
            nexus.ch1.press= filter(Hd,data.values(:,nexus1).*block(F{i,j}(1)).b_nexus1sens);  % pressure in Pa
            nexus.ch2.press= filter(Hd,data.values(:,nexus2).*block(F{i,j}(1)).b_nexus2sens);  % pressure in Pa
            % Release memory
            clear data
            
            % compute RMS pressure by averaging
            for k=1:floor(length(nexus.ch2.press)/par.avg_bin)-1
                ind_start(k)=((k-1)*(par.avg_bin))+1;
                ind_end(k)=((k)*(par.avg_bin));
                % compute rms via a homebrew function by taking rms of small section
                temp=nexus.ch1.press(ind_start(k):ind_end(k))-mean(nexus.ch1.press(ind_start(k):ind_end(k))); %  % these are de-trended as per Nils Olav's suggestion
                nexus.ch1.press_rms_avg(k)= (mean(temp.^2))^.5;
                temp=nexus.ch2.press(ind_start(k):ind_end(k))-mean(nexus.ch2.press(ind_start(k):ind_end(k)));  % these are de-trended as per Nils Olav's suggestion
                nexus.ch2.press_rms_avg(k)= (mean(temp.^2))^.5;
                nexus.time(k) = ((mean([ind_start(k) ind_end(k)])))./(par.Fs);%./(par.Fs*24*60*60)) + par.start_time;
            end
            
            t0 = par.start_time;
            t1 = block(F{i,j}(1)).subblock(F{i,j}(2)).treatment(F{i,j}(3)).t_start_time_mt;
            dt = (t0-t1)*24*60*60;%s
            %             disp(['F'  ,num2str(block(F{i,j}(1)).subblock(F{i,j}(2)).treatment(F{i,j}(3)).t_F1),...
            %                   '_SL',num2str(block(F{i,j}(1)).subblock(F{i,j}(2)).treatment(F{i,j}(3)).t_SL),...
            %                   '_RT',num2str(block(F{i,j}(1)).subblock(F{i,j}(2)).treatment(F{i,j}(3)).t_rt)]);
            
            % Export data to R
            switch i
                case 1
                    % SPL
                    DAT{i,j}.x=nexus.time+dt;
                    DAT{i,j}.nexus1 = nexus.ch1.press_rms_avg./par.p_ref;
                    DAT{i,j}.nexus2 = nexus.ch2.press_rms_avg./par.p_ref;
                case 2
                    % Pressure
                    DAT{i,j}.x=(1:length(nexus.ch1.press))./par.Fs + dt;
                    DAT{i,j}.nexus1 = nexus.ch1.press;
                    DAT{i,j}.nexus2 = nexus.ch2.press;
                case 3
                    % Pick data around max pressure i.e. "passing" of the
                    % "vessel"
                    %t = par.start_time + (1:length(nexus.ch1.press))/(par.Fs*24*60*60);
                    t = (1:length(nexus.ch1.press))/par.Fs;
                    ind = t>18 & t<25;
                    
                    % Welch Frequency Spectrum (needs to calculated around max pressure!)
%                     h = spectrum.periodogram;
%                     Hpsd1 = psd(h,double(nexus.ch1.press(ind)).*1e6,'Fs',par.Fs);
%                     Hpsd2 = psd(h,double(nexus.ch2.press(ind)).*1e6,'Fs',par.Fs);
% %                     
                    [Hpsd1_1,f] = pwelch(double(nexus.ch1.press(ind)).*1e6,1000,500,500,par.Fs);
                    [Hpsd2_2,f] = pwelch(double(nexus.ch2.press(ind)).*1e6,1000,500,500,par.Fs);
                    
                    DAT{i,j}.x      = f;%Hpsd1.Frequencies;
                    DAT{i,j}.nexus1 = Hpsd1_1;%Hpsd1.Data;
                    DAT{i,j}.nexus2 = Hpsd2_2;%Hpsd2.Data;
            end
            clear nexus
        else
            warning(['File ',file,' do not exist!'])
        end
    end
end
save DATva DAT par

%% Export files to R/plot figures

% The outer B&K hydrophone (the one close to the caruso) is connected to
% channel 2 on the Nexus, and split to channel 18 on the NTNU sampler  

clear
load DATva
close all
figure(1)
clf
subplot(131)
% Figure 1(a)
for i=1:3
    ind{i}= DAT{1,i}.x>-inf & DAT{1,i}.x<inf;
end
plot(DAT{1,1}.x(ind{1}),20*log10(DAT{1,1}.nexus2(ind{1})),...
    DAT{1,2}.x(ind{2}),20*log10(DAT{1,2}.nexus2(ind{2})),...
    DAT{1,3}.x(ind{3}),20*log10(DAT{1,3}.nexus2(ind{3})))
ylabel('SPL (dB re 1\mu Pa)')
xlabel('time (s)')

% Data for R
fig11_1=[DAT{1,1}.x(ind{1}); 20*log10(DAT{1,1}.nexus1(ind{1}))];
fig12_1=[DAT{1,2}.x(ind{2}); 20*log10(DAT{1,2}.nexus1(ind{2}))];
fig13_1=[DAT{1,3}.x(ind{3}); 20*log10(DAT{1,3}.nexus1(ind{3}))];

fig11_2=[DAT{1,1}.x(ind{1}); 20*log10(DAT{1,1}.nexus2(ind{1}))];
fig12_2=[DAT{1,2}.x(ind{2}); 20*log10(DAT{1,2}.nexus2(ind{2}))];
fig13_2=[DAT{1,3}.x(ind{3}); 20*log10(DAT{1,3}.nexus2(ind{3}))];

% Figure 1(b)
subplot(132)

% DAT{2,1}.x = DAT{2,1}.x - .8077;
% DAT{2,2}.x = DAT{2,2}.x - 1.4892;
% DAT{2,3}.x = DAT{2,3}.x - 1.3425;

for i=1:3
    ind{i}= DAT{2,i}.x>-inf & DAT{2,i}.x<inf;
end
% for i=1:3
%     ind{i}= DAT{2,i}.x>-inf & DAT{2,i}.x<inf;
% end

plot(DAT{2,1}.x(ind{1})*1000,(DAT{2,1}.nexus2(ind{1})),...
    DAT{2,2}.x(ind{2})*1000,(DAT{2,2}.nexus2(ind{2})),...
    DAT{2,3}.x(ind{3})*1000,(DAT{2,3}.nexus2(ind{3})))
ylabel('Pressure (Pa)')
xlabel('time (ms)')

fig21_1=[DAT{2,1}.x(ind{1})*1000; DAT{2,1}.nexus1(ind{1})'];
fig22_1=[DAT{2,2}.x(ind{2})*1000; DAT{2,2}.nexus1(ind{2})'];
fig23_1=[DAT{2,3}.x(ind{3})*1000; DAT{2,3}.nexus1(ind{3})'];
fig21_2=[DAT{2,1}.x(ind{1})*1000; DAT{2,1}.nexus2(ind{1})'];
fig22_2=[DAT{2,2}.x(ind{2})*1000; DAT{2,2}.nexus2(ind{2})'];
fig23_2=[DAT{2,3}.x(ind{3})*1000; DAT{2,3}.nexus2(ind{3})'];

% Figure 1(c)
subplot(133)
plot(DAT{3,1}.x,10*log10(DAT{3,1}.nexus2),...
    DAT{3,2}.x,10*log10(DAT{3,2}.nexus2),...
    DAT{3,3}.x,10*log10(DAT{3,3}.nexus2))
xlim([100 600])
xlabel('Frequency (Hz)')
ylabel('Power spectral density (dB re 1\mu Pa Hz^{-1})')

ind= DAT{3,1}.x<1000 & DAT{3,1}.x>10;
fig31_1=[DAT{3,1}.x(ind)'; 10*log10(DAT{3,1}.nexus1(ind))'];
fig32_1=[DAT{3,2}.x(ind)'; 10*log10(DAT{3,2}.nexus1(ind))'];
fig33_1=[DAT{3,3}.x(ind)'; 10*log10(DAT{3,3}.nexus1(ind))'];
fig31_2=[DAT{3,1}.x(ind)'; 10*log10(DAT{3,1}.nexus2(ind))'];
fig32_2=[DAT{3,2}.x(ind)'; 10*log10(DAT{3,2}.nexus2(ind))'];
fig33_2=[DAT{3,3}.x(ind)'; 10*log10(DAT{3,3}.nexus2(ind))'];

% Cacluate the mean SPL prior to and during passage:
p={'a','b','c'};
for j=1:3
    ind  = ((DAT{1,j}.x > par.ek60.passTimeVA(1)   & DAT{1,j}.x < par.ek60.passTimeVA(2)));
    %plot(DAT{1,j}.x(ind),DAT{1,j}.nexus1(ind))
    disp(['Nexus 1 panel ',p{j},': ',num2str(20*log10(mean(DAT{1,j}.nexus1(ind))),4),'dB'])
    disp(['Nexus 2 panel ',p{j},': ',num2str(20*log10(mean(DAT{1,j}.nexus2(ind))),4),'dB'])
    
end
%
10^((171.1-136)/20)


save Figure1 fig11_1 fig12_1 fig13_1 fig21_1 fig22_1 fig23_1 fig31_1 fig32_1 fig33_1 fig11_2 fig12_2 fig13_2 fig21_2 fig22_2 fig23_2 fig31_2 fig32_2 fig33_2

%VA1 = load(fullfile('C:\repositories\CollPen_mercurial\','VA1.mat'));
%% Prepare VA data

clear
par.datadir = '\\callisto\collpen\AustevollExp\data\HERRINGexp';
par.reposdir = 'C:\repositories\CollPen_mercurial\matlabtoolbox';

file = fullfile(par.datadir,'CollPenAustevollLog.xls');
block = cp_GetExpPar(file);

load(fullfile('C:\repositories\CollPen_mercurial\','VA.mat'));

[D,T,R]=xlsread('C:\repositories\CollPen_mercurial\vesselavoidancepaper\didson_stationary_sorted.xls');

%%

% Fit block informaion and va data
N=1;

% Desse manglar:
%27 3 2
%27 3 3
%33 4 1

% Several of the horizontal blocks are invalid due to net pen wall
% interactions

%# 20,21,22,23,27,28,29,30,31,32,33,34 
blocks{1} = [24:26 35];
% The vertical ones are ok
blocks{2} = 21:35;

for ch=1:2
    eval(['VA=VA',num2str(ch),';']);
    VAvessel={'block','subblock','treatment','sv','sv_0','m','m_0','score','type','groupsize'};
    for b=blocks{ch}
        for sb=1:length(block(b).subblock)
            if strcmp(block(b).subblock(sb).s_treatmenttype,'vessel')
                for trn=1:length(block(b).subblock(sb).treatment)
                    % Match with va data
                    switch block(b).subblock(sb).treatment(trn).t_treatmenttype
                        case 'GOS_upscaled'
                            tr = 'GOSup';
                        case 'GOS_unfiltered'
                            tr = 'GOS';
                        case 'JH_unfiltered'
                            tr = 'JH';
                    end
                    gs='NaN';
                    switch block(b).b_groupsize
                        case 'large group in M09'
                            gs='L';
                        case 'small group in M09'
                            gs='S';
                    end
                    ind=VA(:,1)==b & VA(:,2)==sb & VA(:,3)==trn;
                    if sum(ind)>0
                        vas = num2cell(VA(ind,:));% groupsize tr
                    else
                        vas = num2cell([b sb trn NaN NaN NaN NaN]);% groupsize tr
                    end
                    scrs = num2cell(NaN);% groupsize tr
                    VAvessel=[VAvessel;[vas scrs tr gs]];
                end
            end
        end
    end
    disp(VAvessel)
    % Remove NaN's
    xlswrite(['VAvessel_ch',num2str(ch),'.xls'],VAvessel)
end


%% reformat the Didson data

blocks = 21:35;
Dvessel = {'block','subblock','treatment','cav_0','cav','speed_0','speed','type','groupsize'};

for b = blocks
    for sb = 1:length(block(b).subblock)
        if strcmp(block(b).subblock(sb).s_treatmenttype,'vessel')
            for trn=1:length(block(b).subblock(sb).treatment)
                % Match with va data
                switch block(b).subblock(sb).treatment(trn).t_treatmenttype
                    case 'GOS_upscaled'
                        tr = 'GOSup';
                    case 'GOS_unfiltered'
                        tr = 'GOS';
                    case 'JH_unfiltered'
                        tr = 'JH';
                end
                gs='NaN';
                switch block(b).b_groupsize
                    case 'large group in M09'
                        gs='L';
                    case 'small group in M09'
                        gs='S';
                end
                % Pick Didson data
                cav   = NaN;
                speed = NaN;
                cav_0 = NaN;
                speed_0=NaN;
                for i=1:size(R,1)
                    if R{i,4}==b & R{i,5}==sb & R{i,6}==trn
                        if strcmp(R(i,2),'TREAT')
                            cav   = R{i,8};
                            speed = R{i,7}; 
                        elseif strcmp(R(i,2),'NULL')
                            cav_0   = R{i,8};
                            speed_0 = R{i,7};
                        end
                    end
                end
                sub = {b sb trn cav_0 cav speed_0 speed tr gs};
                % Dvessel = {'block','subblock','treatment','cav_0','cav',
                % 'speed_0','speed','score','type','groupsize'} 
                Dvessel=[Dvessel;sub];
            end
        end
    end
end
disp(Dvessel)
% Remove NaN's
xlswrite(['Dvessel.xls'],Dvessel)
