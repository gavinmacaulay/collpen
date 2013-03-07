
%% Create avi from Didson data relative to each "passing"
clear
close all

% Read test data
par.datadir = '\\callisto\collpen\AustevollExp\data\HERRINGexp';
par.parfile ='\\callisto\collpen\AustevollExp\data\HERRINGexp\CollPenAustevollLog.xls';

%\\callisto\collpen\AustevollExp\data\HERRINGexp\temporary files
D=dir(fullfile(par.datadir,'temporary files','*.mat'));

%22 4 4

fil = fullfile(par.datadir,'\scoring_package\didson\didson_block22_sub4_treat4.avi');
mov=aviread(fil);

%%
%
%bottle =[];
%wave =[];
pm = 512/9;% pixels per meter
dt = 8;% pings per second

load(fullfile(par.datadir,'bottlewavespeed_22_sub4_treat4.mat'))

for k=1:20
    clf
    m=imshow(mov(1).cdata);
    t=text(22,34,num2str(i));
    axis equal
    hold on
    for i=55:68
        set(m,'Cdata',mov(i).cdata)
        delete(t)
        t=text(22,34,num2str(i),'Color','w');
        
        if i>=bottle(1,1) && i<=bottle(end,1)
            % Draw bottle
            ind = (i==bottle(:,1));
            plot(bottle(ind,2),bottle(ind,3),'r*')
        end
        if i>=wave(1,1) && i<=wave(end,1)
            % Draw bottle
            ind = (i==wave(:,1));
            plot(wave(ind,2),wave(ind,3),'c*')
        end
        pause
        %         [x,y]=ginput(1);
        %         bottle = [bottle;[i x y]];
        %          [x,y]=ginput(1);
        %          wave = [wave;[i x y]];
    end
end
%save(fullfile(par.datadir,'bottlewavespeed_22_sub4_treat4.mat'),'bottle','wave')

%% Speed of bottle
v=sqrt(diff(bottle(:,2)).^2 + diff(bottle(:,3)).^2)*pm^-1*dt;
vb=sqrt(diff(wave(:,2)).^2 + diff(wave(:,3)).^2)*pm^-1*dt;

figure
plot(bottle(1:end-1,1)./dt,v,'r',wave(1:end-1,1)./dt,vb,'c');
xlabel('Time (s)')
ylabel('speed (m/s)')
title('Bottle speed')
legend('Bottle','Behavioural wave')




