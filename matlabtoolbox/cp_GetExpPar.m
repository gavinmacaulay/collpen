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
% for i=1:s(1)-1
%     cruise(i).cruise_starttime = datenum(cruise(i).cruise_starttime,'dd.mm.yyyy HH:MM:SS');
%     cruise(i).cruise_stoptime  = datenum(cruise(i).cruise_stoptime,'dd.mm.yyyy HH:MM:SS');
% end

function[cruise]=importsubblock(file)
% import cruise structure
[num,txt,raw]=xlsread(file,'subblock');
s=size(raw);
fields = txt(1,1:s(2));
cruise = cell2struct(raw(2:s(1),:),fields,2);

% s_start_time	s_stop_time
% convert times and date
% for i=1:s(1)-1
%     cruise(i).cruise_starttime = datenum(cruise(i).cruise_starttime,'dd.mm.yyyy HH:MM:SS');
%     cruise(i).cruise_stoptime  = datenum(cruise(i).cruise_stoptime,'dd.mm.yyyy HH:MM:SS');
% end


function[passing]=importtreatment(file)
% Import passing structure
[num,txt,raw]=xlsread(file,'treatment');
s=size(raw);
fields = txt(1,1:s(2));
passing = cell2struct(raw(2:s(1),:),fields,2);

% t_start_time t_stop_time t_start_hydrophonePC 
% convert times and date
% for i=1:s(1)-1
%      passing(i).t_start_time = datenum(passing(i).t_start_time,'dd.mm.yyyy HH:MM:SS');
%      passing(i).t_stop_time  = datenum(passing(i).t_stop_time,'dd.mm.yyyy HH:MM:SS');
%      passing(i).t_start_time = datenum(passing(i).t_start_time,'dd.mm.yyyy HH:MM:SS');
% end
