%% Randomize bottle treatments 

% seed the random number generator
reset(RandStream.getDefaultStream,sum(100*clock)); % works in r2010b and r2012a
%reset(RandStream.getGlobalStream,sum(100*clock));  % works in r2012a


par.predName={'Black bottle','Clear bottle','Flat black','Flat clear','Control'};
par.predOrder=randperm(5);

disp('I know you liked the rocks but....')

% display order of bolocks
disp ('Predator Orders')
for i=1:length(par.predOrder);
   disp( par.predName(par.predOrder(i)))
end
return

%% Randomize subblocks
 % Number of blocks to spit out
N= 36;

s_treatmenttype={'tones','orca','predator','vessel'};
s_soundsource={'caruso','lubell','none','caruso'};


D = cell(N*4,4);
D{1,1} = 's_block';
D{1,2} = 's_subblock';
D{1,3} = 's_treatmenttype';
D{1,4} = 's_soundsource';

% display order of subblocks
disp ('Subblock Orders')

k=2;
for j=1:N
    TrialOrder = randperm(4);
    for i=1:4;
        D{k,1} = j;
        D{k,2} = i;
        D{k,3} = s_treatmenttype{TrialOrder(i)};
        D{k,4} = s_soundsource{TrialOrder(i)};
        k = k+1;
    end
end
xlswrite('subblockrandomization.xls',D);

%% Set up treatmentblock

% D = cell(N*4,4);
% D2{1,1} = 't_block';
% D2{1,2} = 't_subblock';
% D2{1,3} = 't_treatment';
% 
% k=2;
% for j=1:N
%     TrialOrder = randperm(4);
%     for i=1:4;
%         
%         for l=1:sl
%         D2{k,1} = i;
%         D2{k,2} = j;
%         D2{k,3} = l;
%         k = k+1;
%     end
% end
% xlswrite('subblockrandomization.xls',D);



