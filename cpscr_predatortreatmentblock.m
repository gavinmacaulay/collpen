clear
% cpssc_predator_treatmentblock
% 
% script to take times on keypress for predator runs
 % hacked together pretty fast, but should work...

 
par.filePath = './';  % path to write output files to

par.showImg=1
par.predName={'Black bottle','Clear bottle','Flat black','Flat clear','Control'}
par.order=randperm(5); % order
par.Dt=120% % time between trials in seconds


reset(RandStream.getDefaultStream,sum(100*clock)) % works in r2010b and r2012a
%reset(RandStream.getGlobalStream,sum(100*clock))  % works in r2012a


% MultiModal predator model tests
disp ('Predator Orders')
for i=1:length(par.order);
   disp( par.predName(par.order(i)))
end

%% Create treatment data






for i=1:length(par.order)
    
       
    
    % Play back signal and display gain information on screen
      
   
    disp(['Next Predator: ' ,par.predName{par.order(i)}]);
    disp(['Make sure you made a new hydrophone file - pred number is: ' num2str(i)]);
    disp('.')
    
    if i==1
    elseif i>1
        disp(['Waiting for ' num2str(par.Dt) ' s before next trial.'])
        pause(par.Dt)
    end
    disp('.')
    disp('PRESS ANY KEY WHEN MODEL FIRED')
    pause

    par.treat_start(i) = now;
      disp([datestr( par.treat_start(i))])
   disp('PRESS ANY KEY WHEN MODEL HITS LADDER')
      pause
    par.treat_stop(i) = now;
      
    disp([datestr( par.treat_stop(i)), ' hit any key for next time'])
    disp('.') % leave some space for legibility
    disp('.') % leave some space for legibility
   
    
end



%set filename
fname=strcat(par.filePath ,'Predator_params_',datestr(now,30));

eval(['save ', fname,' par'])   % save parameter file in mat format

% now build up the output for excel
% prepare a cell array for export

% headers
a{1,1}='t_start_time';
a{1,2}='t_stop_time';
a{1,3}='treatmentType';

% place data in cell array (yes this can be vectorized but already did this...
for i=2:length(par.order)+1
    a{i,1}=datestr(par.treat_start(i-1),'dd.mm.yy HH:MM:SS');
    a{i,2}=datestr(par.treat_stop(i-1),'dd.mm.yy HH:MM:SS');
    a{i,3}=par.predName{par.order(i-1)};   
end



xlswrite(fname,a) % write out xls file

disp('(no problem if crashes after this line)')

% just for fun
if par.showImg==1
figure
[X,map] = imread('monkeyPic.jpg');
image(X)
title('Nice Work Monkey Boys - keep it up and you will get another hard drive reward')
axis off
end

