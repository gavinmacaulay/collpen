function[block] = cp_GetExpPar(file)
% Imports metadata for the CollPen/HerringEXP experiment

% Import block structure
block = importblock(file);

% Import subblock structure
subblock = importsubblock(file);

% Import treatment structure
treatment = importtreatment(file);

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
%Importfunctions

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
        warning('t_start_hydrophonePC did not convert')
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
