 % cpscr_selectblockorder.m
 %
 % script to select block and predator model orders for 2012 Collpen expts
 

% seed the random number generator
reset(RandStream.getDefaultStream,sum(100*clock)); % works in r2010b and r2012a
%reset(RandStream.getGlobalStream,sum(100*clock));  % works in r2012a


par.trialName={'Tones','Orca','Predator','Vessel'};
par.predName={'Black bottle','Clear bottle','Flat black','Flat clear','Control'};
 
par.TrialOrder=randperm(4);
par.predOrder=randperm(5);

disp('I know you liked the rocks but....')
% display order of subblocks
disp ('Subblock Orders')
for i=1:length(par.TrialOrder);
   disp( par.trialName(par.TrialOrder(i)))
end

% display order of bolocks
disp ('Predator Orders')
for i=1:length(par.predOrder);
   disp( par.predName(par.predOrder(i)))
end
