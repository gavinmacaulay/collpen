function cp_ProcessHydrophonedata(blockn,block,par)

% This is the block, subblock, treatment vector. If the vecotr is shorter,
%
% Parameters for picking the right data

% block(blockn).subblock(subblockn).treatment(treatmentn)
%
% %%%Note that this was changed  on 2 july to 118.816 Pa/V for block 10 and greater
% par.nexus1.cal=115.4 % Pa/volt
%
% % This is our calibration after changing the NExus
% %par.nexus2.cal= 118.816% 37.6% Pa/volt Note that this was changed  on 2 july to 118.816 Pa/V for block 10 and greater
%
% %Block 13_2 ambient
% %load F:\collpen\AustevollExp\data\HERRINGexp\block13\hydrophones\block13_2.mat
% %par.nexus2.cal= 118.816% 37.6% Pa/volt FOR BLOCK 10 USE THIS AS WE CHANGED THE GAIN ON THIS PHONE  TO 1 PA PER MV
%
% % block 9 ship noise playback
%
% par.nexus2.cal= 37.6% 37.6% Pa/volt FOR BLOCK 9 AND LOWER , 118.816 for block 10 and higher

%% Load hydrophone data
files = dir(fullfile(par.datadir,['block',num2str(blockn)],'hydrophones','*.mat'));

if length(files)==0
    error('No hydrophone files available. Run preparation script.')
end
for f=1:length(files)
    file =  fullfile(par.datadir,['block',num2str(blockn)],'hydrophones',files(f).name);
    hdr = ['hydrophones_',files(f).name(1:end-4)];
    % if length(bbt)==1
    %     file = fullfile(par.datadir,['block',num2str(bbt(1))],'hydrophones',['block',num2str(blockn),'.mat']);
    %     hdr = ['hydrophones_block',num2str(bbt(1))];
    % elseif length(bbt)==2
    %     hdr = ['hydrophones_block',num2str(bbt(1)),'_',num2str(bbt(2))];
    %     file = fullfile(par.datadir,['block',num2str(bbt(1))],'hydrophones',['block',num2str(bbt(1)),'_',num2str(bbt(2)),'.mat']);
    % elseif length(bbt)==3
    %     hdr = ['hydrophones_block',num2str(bbt(1)),'_',num2str(bbt(2)),'_',num2str(treatmentn)];
    %     file = fullfile(par.datadir,['block',num2str(bbt(1))],'hydrophones',['block',num2str(bbt(1)),'_',num2str(bbt(2)),'_',num2str(bbt(3))'.mat']);
    % else
    %     error('bbt vector is wrong')
    % end
    
    nexus1 = 17;
    nexus2 = 18;
%     nexus1 = 1;
%     nexus2 = 2;
    
    load(file)
    par.Fs=data.sample_rate(nexus1);
    par.start_time=data.start_time(nexus1);
    par.avg_bin=floor(par.Fs*par.avgtime);  % average into 1/10 second  bins
    nexus.ch1.press= data.values(:,nexus1).*block(blockn).b_nexus1sens;  % pressure in Pa
    nexus.ch2.press= data.values(:,nexus2).*block(blockn).b_nexus2sens;  % pressure in Pa
    % Release memory
    clear data
    
    %% compute RMS pressure by averaging
    for i=1:floor(length(nexus.ch2.press)/par.avg_bin)-1
        ind_start(i)=((i-1)*floor(par.avg_bin))+1;
        ind_end(i)=((i)*floor(par.avg_bin));
        % compute rms via a homebrew function by taking rms of small section
        temp=nexus.ch1.press(ind_start(i):ind_end(i))-mean(nexus.ch1.press(ind_start(i):ind_end(i))); %  % these are de-trended as per Nils Olav's suggestion
        nexus.ch1.press_rms_avg(i)= (mean(temp.^2))^.5;
        temp=nexus.ch2.press(ind_start(i):ind_end(i))-mean(nexus.ch2.press(ind_start(i):ind_end(i)));  % these are de-trended as per Nils Olav's suggestion
        nexus.ch2.press_rms_avg(i)= (mean(temp.^2))^.5;
        nexus.time(i) = ((mean([ind_start(i) ind_end(i)])));%./(par.Fs*24*60*60)) + par.start_time;
    end
    
    
    %% Plot spectrogram
    par.figdir = fullfile(par.datadir,'figures');
    if ~exist(par.figdir)
        mkdir(par.figdir)
        warning('figure directory not created - fixed')
    end
    
    spectrogram(double(nexus.ch1.press).*10e6,par.Nwindow,par.Noverlap,par.Nfft,par.Fs,'yaxis');
    title([hdr,'_psd_nexus1'],'Interpreter','none')
    colorbar
    xlabel('time (s)')
    print('-dpng','-r200',fullfile(par.figdir,[hdr,'_psd_nexus1.png']))
    
    figure
    spectrogram(double(nexus.ch2.press).*10e6,par.Nwindow,par.Noverlap,par.Nfft,par.Fs,'yaxis');
    title([hdr,'_psd_nexus2'],'Interpreter','none')
    colorbar
    xlabel('time (s)')
    print('-dpng','-r200',fullfile(par.figdir,[hdr,'_psd_nexus2.png']))
    
    figure
    plot(1:length(nexus.ch2.press),nexus.ch2.press,'r',1:length(nexus.ch2.press),nexus.ch1.press,'b')
    datetick
    xlabel('Sample number')
    ylabel('Pressure (Pa)')
    title([hdr,'_pressure'],'Interpreter','none')
    print('-dpng','-r200',fullfile(par.figdir,[hdr,'_pressure.png']))
    
    % plot SPL
    figure
    plot(nexus.time,20*log10(nexus.ch1.press_rms_avg./par.p_ref),'b',...
        nexus.time,20*log10(nexus.ch2.press_rms_avg./par.p_ref),'r')
    legend('nexus1','nexus2')
    datetick
    xlabel('Time')
    ylabel('SPL dB re 1 \mu Pa')
    title([hdr,'_SPL'],'Interpreter','none')
    print('-dpng','-r200',fullfile(par.figdir,[hdr,'_SPL.png']))
    
    close all
end