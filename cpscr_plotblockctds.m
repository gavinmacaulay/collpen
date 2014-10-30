%%
% Simple script to plot ctd casts done during the blocks

blocks = 21:35;
dataDir = '\\callisto\collpen\AustevollExp\data\HERRINGexp';

clear ctdData
close all
ii = 1;
for i = blocks
    path = fullfile(dataDir, ['block' num2str(i)], 'ctd');
    d = dir(fullfile(path, '*saleng.txt'));
    if ~isempty(d)
        for j = 1:length(d)
            ctd = txt2struct(fullfile(path, d(j).name), 'skiplines', 3, 'delimiter', '\t');
            
            k = find(ctd.Press > 0.5);
            figure(1)
            plot(ctd.SVel(k), ctd.Press(k), 'k')
            hold on
            figure(2)
            plot(ctd.Temp(k), ctd.Press(k), 'k')
            hold on
            ctdData(ii) = struct('depth', ctd.Press(k), 'svel', ctd.SVel(k), 'block', i,'Temp',ctd.Temp(k),'Sal',ctd.Sal(k));
            ii = ii + 1;
        end
    else
        disp(['No processed ctd files for block ' num2str(i)])
    end
    
end

%% The number for the paper at 2 and 10m depth:

for i = 1:11
    ind1 = ctdData(i).depth>2.5 & ctdData(i).depth < 3.5;
    ind2 = ctdData(i).depth>9.5 & ctdData(i).depth < 10.5;
    mtemp_2(i)  = mean(ctdData(i).Temp(ind1));
    mtemp_10(i) = mean(ctdData(i).Temp(ind2));
    msal_2(i)  = mean(ctdData(i).Sal(ind1));
    msal_10(i) = mean(ctdData(i).Sal(ind2));
end

disp(['Mean temp at 2 m: ',num2str(mean(mtemp_2)),' \pm ',num2str(std(mtemp_2))])
disp(['Mean temp at 10 m: ',num2str(mean(mtemp_10)),' \pm ',num2str(std(mtemp_10))])


disp(['Mean sal at 2 m: ',num2str(mean(msal_2)),' \pm ',num2str(std(msal_2))])
disp(['Mean sal at 10 m: ',num2str(mean(msal_10)),' \pm ',num2str(std(msal_10))])



%%
figure(1)
set(gca, 'Ydir','reverse')
xlabel('Sound speed (m/s)')
ylabel('Depth (m)')
title('CTD casts for blocks 21 to 35')
set(gcf,'color', 'w')
export_fig('-pdf', fullfile(dataDir, 'figures\array\CTD_block21-35'))

figure(2)
set(gca, 'Ydir','reverse')
xlabel('Temperature (deg)')
ylabel('Depth (m)')
title('CTD casts for blocks 21 to 35')
set(gcf,'color', 'w')
export_fig('-pdf', fullfile(dataDir, 'figures\array\CTD_temp_block21-35'))

save('vesselavoidancepaper/ctdData.mat', 'ctdData')

%% 
% Export data for block 28 for use in a COMSOL model

dataDir = '\\callisto\collpen\AustevollExp\data\HERRINGexp';

path = fullfile(dataDir, 'block28', 'ctd');
d = dir(fullfile(dataDir, 'block28', 'ctd', '*eng.txt'));
ctd = txt2struct(fullfile(path, d(1).name), 'skiplines', 3, 'delimiter', '\t');
% just use the upcast
i = 274:331; % from inspection
depth_bin = 1:40;
ctd.ss = interp1(ctd.Press(i), ctd.SVel(i), depth_bin);
ctd.rho = interp1(ctd.Press(i), ctd.Density(i), depth_bin) + 1000;
num2str([depth_bin' ctd.ss' ctd.rho'], '%d %.1f %.1f\n')

