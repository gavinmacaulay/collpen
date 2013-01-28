function[block] = cp_GetExpPar(file)
% Imports metadata for the CollPen/HerringEXP experiment

% Import block structure
block = importblock(file);

% Import subblock structure
subblock = importsubblock(file);

% Import treatment structure
treatment = importtreatment(file);

% Import score structure
[score]=importscore(file);

% Append metadata to block

% Append subblock structure
st = size(subblock);
for i=1:st
    block(subblock(i).s_block).subblock(subblock(i).s_subblock) = subblock(i);
end

% Append treatment structure
st = size(treatment);
for i=1:st
    block(treatment(i).t_block).subblock(treatment(i).t_subblock).treatment(treatment(i).t_treatment) = treatment(i);
end

% Append scoring results
st = size(score.video,1);
for i=1:st
    if ~isempty(score.video(i))
        block(score.video(i).block).subblock(score.video(i).subblock).treatment(score.video(i).treatment).score_video = score.video(i);
    end
end

st = size(score.didson,1);
for i=1:st
    if ~isempty(score.didson(i))
        block(score.didson(i).block).subblock(score.didson(i).subblock).treatment(score.didson(i).treatment).score_didson = score.didson(i);
    end
end

st = size(score.ek60vertical,1);
for i=1:st
    if ~isempty(score.ek60vertical(i))
        block(score.ek60vertical(i).block).subblock(score.ek60vertical(i).subblock).treatment(score.ek60vertical(i).treatment).score_ek60vertical = score.ek60vertical(i);
    end
end


st = size(score.ek60horizontal,1);
for i=1:st
    if ~isempty(score.ek60horizontal(i))
        block(score.ek60horizontal(i).block).subblock(score.ek60horizontal(i).subblock).treatment(score.ek60horizontal(i).treatment).score_ek60horizontal = score.ek60horizontal(i);
    end
end

%Importfunctions

function[score]=importscore(file)

[~,txt1,raw1]=xlsread(file,'score_video');
s=size(raw1);
fields1 = txt1(1,1:s(2));
score.video = cell2struct(raw1(2:s(1),:),fields1,2);

[~,txt2,raw2]=xlsread(file,'score_ek60vertical');
s=size(raw2);
fields2 = txt2(1,1:s(2));
score.ek60vertical = cell2struct(raw2(2:s(1),:),fields2,2);

[~,txt3,raw3]=xlsread(file,'score_ek60horizontal');
s=size(raw3);
fields3 = txt3(1,1:s(2));
score.ek60horizontal = cell2struct(raw3(2:s(1),:),fields3,2);

[~,txt4,raw4]=xlsread(file,'score_didson');
s=size(raw4);
fields4 = txt4(1,1:s(2));
score.didson = cell2struct(raw4(2:s(1),:),fields4,2);



function[cruise]=importblock(file)
% import cruise structure
[num,txt,raw]=xlsread(file,'block');
s=size(raw);
fields = txt(1,1:s(2));
cruise = cell2struct(raw(2:s(1),:),fields,2);

% convert times and date
% b_starttime
for i=1:s(1)-1
    cruise(i).b_starttime_mt = datenum(cruise(i).b_starttime,'dd.mm.yyyy HH:MM:SS');
end

function[cruise]=importsubblock(file)
% import cruise structure
[num,txt,raw]=xlsread(file,'subblock');
s=size(raw);
fields = txt(1,1:s(2));
cruise = cell2struct(raw(2:s(1),:),fields,2);

% s_start_time	s_stop_time
% convert times and date
% for i=1:s(1)-1
%     cruise(i).b_starttime  = datenum(cruise(i).b_starttime,'dd.mm.yyyy HH:MM:SS');
%     cruise(i).cruise_stoptime  = datenum(cruise(i).cruise_stoptime,'dd.mm.yyyy HH:MM:SS');
% end
for i=1:s(1)-1
    try
        cruise(i).s_start_time_mt = datenum(cruise(i).s_start_time,'dd.mm.yyyy HH:MM:SS');
    catch
        cruise(i).s_start_time_mt = NaN;
        warning('s_stop_time did not convert')
    end
    try
        cruise(i).s_stop_time_mt = datenum(cruise(i).s_stop_time,'dd.mm.yyyy HH:MM:SS');
    catch
        cruise(i).s_stop_time_mt = NaN;
        warning('s_stop_time did not convert')
    end
end


function[passing]=importtreatment(file)
% Import passing structure
[num,txt,raw]=xlsread(file,'treatment');
s=size(raw);
fields = txt(1,1:s(2));
passing = cell2struct(raw(2:s(1),:),fields,2);

for i=1:s(1)-1
    try
        passing(i).t_start_time_mt = datenum(passing(i).t_start_time,'dd.mm.yyyy HH:MM:SS');
    catch
        passing(i).t_start_time_mt = NaN;
        warning('t_start_time did not convert')
    end
    try
        passing(i).t_stop_time_mt = datenum(passing(i).t_stop_time,'dd.mm.yyyy HH:MM:SS');
    catch
        passing(i).t_stop_time_mt = NaN;
        warning('t_stop_time did not convert')
    end
    try
        passing(i).t_start_hydrophonePC_mt = datenum(passing(i).t_start_hydrophonePC,'dd.mm.yyyy HH:MM:SS');
    catch
        passing(i).t_start_hydrophonePC_mt = NaN;
        %  warning('t_start_hydrophonePC did not convert')
    end
    % Replace numeric treatmenttypes with characters
    if isnumeric(passing(i).t_treatmenttype)&&~isnan(passing(i).t_treatmenttype)
        if strcmp(passing(i).t_soundsource,'lubell')
            %par.wavName{1,1}= 'NorwegianOrcaCalls.wav';
            %par.wavName{2,1}= 'CanadianOrcaCalls.wav';
            %par.wavName{3,1}= 'IcealandicOrcaCalls_Dtag_ch1.wav';
            treatmenttype ={'orca_nor','orca_can','orca_is'};
            passing(i).t_treatmenttype  = treatmenttype{passing(i).t_treatmenttype};
        elseif strcmp(passing(i).t_soundsource,'caruso')
            %vessel(1).treatment = 'JH_unfiltered';
            %vessel(2).treatment = 'GOS_unfiltered';
            %vessel(3).treatment = 'GOS_upscaled';
            treatmenttype ={'JH_unfiltered','GOS_unfiltered','GOS_upscaled'};
            passing(i).t_treatmenttype  = treatmenttype{passing(i).t_treatmenttype};
        end
    end
end
