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

% Figure 1(a)
F{1,1}=[21 1 1];
F{1,2}=[21 1 2];
F{1,3}=[21 1 3];

% Figure 1(b)
F{2,1}=[21 1 1];
F{2,2}=[21 1 2];
F{2,3}=[21 1 3];

% Figure 1(c)
F{3,1}=[21 1 1];
F{3,2}=[21 1 2];
F{3,3}=[21 1 3];

par.avgtime = 0.1;%s
par.p_ref = 1e-6; % [Pa]

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
            nexus.ch1.press= data.values(:,nexus1).*block(F{i,j}(1)).b_nexus1sens;  % pressure in Pa
            nexus.ch2.press= data.values(:,nexus2).*block(F{i,j}(1)).b_nexus2sens;  % pressure in Pa
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
                    h = spectrum.periodogram;
                    Hpsd1 = psd(h,double(nexus.ch1.press(ind)).*1e6,'Fs',par.Fs);
                    Hpsd2 = psd(h,double(nexus.ch2.press(ind)).*1e6,'Fs',par.Fs);
                    DAT{i,j}.x      = Hpsd1.Frequencies;
                    DAT{i,j}.nexus1 = Hpsd1.Data;
                    DAT{i,j}.nexus2 = Hpsd2.Data;
            end
            clear nexus
        else
            warning(['File ',file,' do not exist!'])
        end
    end
end
save DATva DAT

%% Export files to R/plot figures
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
plot(DAT{1,1}.x(ind{1}),20*log10(DAT{1,1}.nexus1(ind{1})),...
    DAT{1,2}.x(ind{2}),20*log10(DAT{1,2}.nexus1(ind{2})),...
    DAT{1,3}.x(ind{3}),20*log10(DAT{1,3}.nexus1(ind{3})))
ylabel('SPL (dB re 1\mu Pa)')
xlabel('time (s)')

% Data for R
fig11=[DAT{1,1}.x(ind{1}); 20*log10(DAT{1,1}.nexus1(ind{1}))];
fig12=[DAT{1,2}.x(ind{2}); 20*log10(DAT{1,2}.nexus1(ind{2}))];
fig13=[DAT{1,3}.x(ind{3}); 20*log10(DAT{1,3}.nexus1(ind{3}))];

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

plot(DAT{2,1}.x(ind{1})*1000,(DAT{2,1}.nexus2(ind{1})),'k',...
    DAT{2,2}.x(ind{2})*1000,(DAT{2,2}.nexus2(ind{2})),'b',...
    DAT{2,3}.x(ind{3})*1000,(DAT{2,3}.nexus2(ind{3})),'r')
ylabel('Pressure (Pa)')
xlabel('time (ms)')

fig21=[DAT{2,1}.x(ind{1})*1000; DAT{2,1}.nexus2(ind{1})'];
fig22=[DAT{2,2}.x(ind{2})*1000; DAT{2,2}.nexus2(ind{2})'];
fig23=[DAT{2,3}.x(ind{3})*1000; DAT{2,3}.nexus2(ind{3})'];

% Figure 1(c)
subplot(133)
plot(DAT{3,1}.x,10*log10(DAT{3,1}.nexus2),...
    DAT{3,2}.x,10*log10(DAT{3,2}.nexus2),...
    DAT{3,3}.x,10*log10(DAT{3,3}.nexus2))
xlim([100 600])
xlabel('Frequency (Hz)')
ylabel('Power spectral density (dB re 1\mu Pa Hz^{-1})')

ind= DAT{3,1}.x<1000 & DAT{3,1}.x>10;
fig31=[DAT{3,1}.x(ind)'; 10*log10(DAT{3,1}.nexus2(ind))'];
fig32=[DAT{3,2}.x(ind)'; 10*log10(DAT{3,2}.nexus2(ind))'];
fig33=[DAT{3,3}.x(ind)'; 10*log10(DAT{3,3}.nexus2(ind))'];

save Figure1 fig11 fig12 fig13 fig21 fig22 fig23 fig31 fig32 fig33

%% Prepare VA data

clear
par.datadir = '\\callisto\collpen\AustevollExp\data\HERRINGexp';
par.reposdir = 'C:\repositories\CollPen_mercurial\matlabtoolbox';

file = fullfile(par.datadir,'CollPenAustevollLog.xls');
block = cp_GetExpPar(file);

load(fullfile('C:\repositories\CollPen_mercurial\','VA.mat'));

% Fit block informaion and va data
N=1;
%%

% Les inn manuell scoring
%b_block;b_groupsize;s_subblock;s_treatmenttype;t_treatment;t_treatmenttype;t_start_time_mt;t_stop_time_mt;t_F1;t_F2;t_SL;t_duration;t_rt;v_score
%17;large group in M09;1;tones;1;tones_F1500_F2160_SL175_dur2000_rt250;735055.384456;735055.384525;500;160;175;2000;250;1.7

str='%u;%*s;%u;%*s;%u;%*s;%*f;%*f;%*u;%*u;%*u;%*u;%*u;%f\n'


fid=fopen('C:/repositories/CollPen_mercurial/score_anova_simple.csv','rt')
getl(fid)
scr = freadf(fid,str);
fid=fclose(fid)

VAvessel={'Block','Sub block','Treatment','sv_0','sv','m_0','m','Score','Type','Group size'};
% Desse manglar:
%27 3 2
%27 3 3
%33 4 1

for b=21:35
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
                indsc=scr(:,1)==b & scr(:,3)==sb & scr(:,5)==trn;
                if sum(ind)>0
                    vas = num2cell(VA(ind,:));% groupsize tr
                else
                    vas = num2cell([b sb trn NaN NaN NaN NaN]);% groupsize tr
                end
                
                if sum(indsc)>0
                    scrs = num2cell(scr(indsc,14));% groupsize tr
                else
                    scrs = num2cell(NaN);% groupsize tr
                end
                
                VAvessel=[VAvessel;[vas scrs tr gs]];
            end
        end
    end
end
disp(VAvessel)
xlswrite('VAvessel.xls',VAvessel)

save VAvessel VAvessel

