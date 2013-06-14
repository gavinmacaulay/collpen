%% This script plot the figures for the tone paper.


par.datadir = '\\callisto\collpen\AustevollExp\data\HERRINGexp';
par.reposdir = 'C:\repositories\CollPen_mercurial\matlabtoolbox';

file = fullfile(par.datadir,'CollPenAustevollLog.xls');
block = cp_GetExpPar(file);

% Pick 3 examples.
%F=160, SL=175, RT=18  : 22-2-12
%F=320, SL=165, RT=31  : 23-1-3
%F=500, SL=155, RT=250 : 27-4-11

% Figure 1(a)
% F160RT18SL155 22_2_11
F{1,1}=[22 2 11];
% F160RT18SL165 28_2_9
F{1,2}=[28 2 9];
% F160RT18SL175 22_2_12
F{1,3}=[22 2 12];

% Figure 1(b)
% F160RT18SL175
F{2,1}=[22 2 12];
% F160RT31SL175 23_1_11
F{2,2}=[28 2 7];
% F160RT250SL175 32_4_4
F{2,3}=[32 4 4];

% Figure 1(c)
% F160RT18SL175
F{3,1}=[22 2 12];
% F320RT18SL175
F{3,2}=[23 1 10];
% F500RT18SL175
F{3,3}=[24 2 10];

%%
par.avgtime = 0.1;%s
par.p_ref = 1e-6; % [Pa]

for i=1:3
    for j=1:3
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
            disp(['F'  ,num2str(block(F{i,j}(1)).subblock(F{i,j}(2)).treatment(F{i,j}(3)).t_F1),...
                  '_SL',num2str(block(F{i,j}(1)).subblock(F{i,j}(2)).treatment(F{i,j}(3)).t_SL),...
                  '_RT',num2str(block(F{i,j}(1)).subblock(F{i,j}(2)).treatment(F{i,j}(3)).t_rt)]);
            
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
                    % Welch Frequency Spectrum
                    h = spectrum.periodogram;
                    Hpsd1 = psd(h,double(nexus.ch1.press).*1e6,'Fs',par.Fs);
                    Hpsd2 = psd(h,double(nexus.ch2.press).*1e6,'Fs',par.Fs);
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
save DAT DAT
%% Export files to R/plot figures
clear
load DAT
close all
figure(1)
clf
subplot(131)
% Figure 1(a)
for i=1:3
    ind{i}= DAT{1,i}.x>0 & DAT{1,i}.x<4;
end
plot(DAT{1,1}.x(ind{1}),20*log10(DAT{1,1}.nexus1(ind{1})),...
     DAT{1,2}.x(ind{2}),20*log10(DAT{1,2}.nexus1(ind{2})),...
     DAT{1,3}.x(ind{3}),20*log10(DAT{1,3}.nexus1(ind{3})))
ylabel('SPL (dB re 1\mu Pa)')
xlabel('time (s)')

% Figure 1(b)
subplot(132)

DAT{2,1}.x = DAT{2,1}.x - .8077;
DAT{2,2}.x = DAT{2,2}.x - 1.4892;
DAT{2,3}.x = DAT{2,3}.x - 1.3425;

for i=1:3
    ind{i}= DAT{2,i}.x>-.1 & DAT{2,i}.x<.4;
end
% for i=1:3
%     ind{i}= DAT{2,i}.x>-inf & DAT{2,i}.x<inf;
% end

plot(DAT{2,1}.x(ind{1})*1000,(DAT{2,1}.nexus2(ind{1})),'k',...
     DAT{2,2}.x(ind{2})*1000,(DAT{2,2}.nexus2(ind{2})),'b',...
     DAT{2,3}.x(ind{3})*1000,(DAT{2,3}.nexus2(ind{3})),'r')
ylabel('Pressure (Pa)')
xlabel('time (ms)')

% Figure 1(c)
subplot(133)
plot(DAT{3,1}.x,10*log10(DAT{3,1}.nexus2),...
     DAT{3,2}.x,10*log10(DAT{3,2}.nexus2),...
     DAT{3,3}.x,10*log10(DAT{3,3}.nexus2))
xlim([100 600])
xlabel('Frequency (Hz)')
ylabel('Power spectral density (dB re 1\mu Pa Hz^{-1})')

