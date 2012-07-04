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

par.pause = 30;%s pause between treatments
par.length = 60;%s
par.order = randperm(3);%1==nor, 2==



%% Load noise data
orca{1}.name = 'NorwegianOrcaCalls.wav';
orca{2}.name = 'IcelandicOrcaCalls.wav';
orca{3}.name = 'CanadianOrcaCalls.wav';

[orca{1}.y,orca{1}.FS,orca{1}.NBITS] = wavread(orca{1}.name);
[orca{2}.y,orca{2}.FS,orca{2}.NBITS] = wavread(orca{2}.name);
[orca{3}.y,orca{3}.FS,orca{3}.NBITS] = wavread(orca{3}.name);


%% Play back signal

warning('Using scaled sound!! Needs calibration and filtering')



par.SL



k=1;
for i=par.order
    % Pick apropriate signal length
    ind = 1: par.length*orca{i}.FS;
    par.start(k) = now;
    par.name{k} = orca{i}.name;
    disp(['Treatment_',num2str(k),'_',par.name{k}])
    soundsc(orca{i}.y(ind),orca{i}.FS)
    par.stop(k) = now;
    disp('Pause...')
    pause(par.pause)
    k=k+1;
end

save(['HerringExp_orcaTreatment_par_',datestr(now,30),'.mat'],'par')

