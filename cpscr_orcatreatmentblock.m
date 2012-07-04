% cpscr_whaletreatmentblock
%
% script to present 3 whale calls in random order during Collpen expts



clear
par.wavName{1,1}= 'NorwegianOrcaCalls.wav'
par.wavName{2,1}= 'CanadianOrcaCalls.wav'
par.wavName{3,1}= 'IcelandicOrcaCalls.wav'


par.playBackDuration=[30 30 30] % duration of playback in sec
par.playBackStartPoint=[30 30 30] % place in the file to start in seconds  (starting 30 sec in as boat noise at beginning of one file
par.waitTime=60 % duration pause between playbacks  in s
par.soundCard='50 %'
par.amplifier='Lubell';
par.filePath='c:\Collpen\Processing\';  % path to write output files to
par.forceSoundPause=0; %whether to force a pause duining playback (Alex PC=1, Nils Olav=0)

%%%%%%% prompt for changes
disp('Check Lubell is connected and hit any key')
pause
disp('check that card is set to 50% and hit a key')
pause
disp('very well, playback starts')

%%%%  present teh stimuli in random order

% seed the random number generator
reset(RandStream.getDefaultStream,sum(100*clock)) % works in r2010b and r2012a
%reset(RandStream.getGlobalStream,sum(100*clock))  % works in r2012a
par.randTrial=randperm(3)
for i=1:length(par.randTrial)
    
    [y, Fs] = wavread(par.wavName{par.randTrial(i),1});
    disp(['Playback: ',num2str(i),' ', par.wavName{par.randTrial(i),1}, ' Duration = ',num2str(par.playBackDuration) ])
    ind=(1:Fs*par.playBackDuration)+par.playBackStartPoint(1);
    disp(par.wavName{par.randTrial(i),1})
    par.treatStart(i)=now;
    sound(y(ind),Fs)
    if par.forceSoundPause==1
        pause(par.playBackDuration(par.randTrial(i)));
        disp('.');
        disp('forcing pause during playback') ; %needed if PC keeps executing during pause
    end
    par.treatEnd(i)=now;
    disp('.')
    disp('playback over')
    disp('.')
    par.treatment(i,:)=par.randTrial(i); % assing treatment name
    
    if i<length(par.randTrial)
        disp(['waiting ' num2str(par.waitTime) ' sec'])
        pause(par.waitTime)
    end
end


% write files
%set filename
fname=strcat(par.filePath ,'OrcaParams_',datestr(now,30));

eval(['save ', fname, ' par'])   % save parameter file in mat format

% now build up the output for excel
% prepare a cell array for export

% headers
a{1,1}='t_start_time';
a{1,2}='t_stop_time';
a{1,3}='t_soundsource';
a{1,4}='treatment';


% place data in cell array
for i=2:length(par.treatStart)+1
    a{i,1}=datestr(par.treatStart(i-1),'dd.mm.yy HH:MM:SS');
    a{i,2}=datestr(par.treatEnd(i-1),'dd.mm.yy HH:MM:SS');
    a{i,3}='Lubell';
    a{i,4}=par.treatment(i-1); % code for each treatment - could be replaced by a string later if desired
    
end

xlswrite(fname,a) % write out xls file

disp('Finished !')
