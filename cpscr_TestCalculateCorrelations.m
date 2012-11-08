
%% Create avi from Didson data relative to each "passing"
clear
close all

% Read test data
par.datadir = '\\callisto\collpen\AustevollExp\data\HERRINGexp';
par.parfile ='\\callisto\collpen\AustevollExp\data\HERRINGexp\CollPenAustevollLog.xls';

%\\callisto\collpen\AustevollExp\data\HERRINGexp\temporary files
D=dir(fullfile(par.datadir,'temporary files','*.mat'));
for i=1:length(D)
    Dat(i)=load(fullfile(par.datadir,'temporary files',D(i).name));
    % X{i}  = [1 i matlabtime NaN NaN x_position y_position dx_speed dy_speed;
    %          2 i matlabtime NaN NaN x_position y_position dx_speed dy_speed];
    %         where 'i' denotes frame number
    
    % Reshape vector
    M=length(Dat(i).vectors);
    Xsub = NaN(M,9);
    for j=1:M
        x = mean([Dat(i).vectors(j).endpoint1.x Dat(i).vectors(j).endpoint2.x]);
        y = mean([Dat(i).vectors(j).endpoint1.y Dat(i).vectors(j).endpoint2.y]);
        vx = Dat(i).vectors(j).endpoint2.x - Dat(i).vectors(j).endpoint1.x;
        vy = Dat(i).vectors(j).endpoint2.y - Dat(i).vectors(j).endpoint1.y;
        Xsub(j,:) = [j i NaN NaN NaN x y vx vy];
    end
    X{i}=Xsub;
end

%% Run correlations

par.correlation = true; % Direction correlations (scales V to unity)
par.direction = true; % Use this if the velicities have 180 deg ambiguity
par.rangebin = 0:50:400; % The unit is pixels

correlation = cp_CalculateCorrelations(X,par);

%%

close all

for i=1:length(X)
    figure(i)
    axes('position',[.4 .1 .5 .8])
    imagesc(Dat(i).RGB)
    str = ['Phi:',num2str(correlation.phi(i))];
    text(20,20,str)
    xlabel('pixels')
    ylabel('pixels')
    title(['Frame ',num2str(i)])
    
    axes('position',[.1  .1  .2  .8])
    plot(correlation.range,correlation.Ckn(i,:),correlation.range,repmat(2/pi,size(correlation.range)))
    ylim([0 1])
    xlim([0 max(par.rangebin)])
    xlabel('Range (pixels)')
    ylabel('C_{kn}')
    pause
end
