%%
% Simple script to plot ctd casts done during the blocks

blocks = 21:35;
dataDir = '\\callisto\collpen\AustevollExp\data\HERRINGexp';

figure
clear ctdData 
ii = 1;
for i = blocks
    path = fullfile(dataDir, ['block' num2str(i)], 'ctd');
    d = dir(fullfile(path, '*eng.txt'));
    if ~isempty(d)
        for j = 1:length(d)
            ctd = txt2struct(fullfile(path, d(j).name), 'skiplines', 3, 'delimiter', '\t');
            k = find(ctd.Press > 0.5);
            plot(ctd.SVel(k), ctd.Press(k), 'k')
            %plot(ctd.Density(k)+1000, ctd.Press(k), 'k')
            hold on
            ctdData(ii) = struct('depth', ctd.Press(k), 'svel', ctd.SVel(k), 'block', i);
            ii = ii + 1;
        end
    else
        disp(['No processed ctd files for block ' num2str(i)])
    end
    
end

set(gca, 'Ydir','reverse')
xlabel('Sound speed (m/s)')
ylabel('Depth (m)')
title('CTD casts for blocks 21 to 35')

set(gcf,'color', 'w')
export_fig('-pdf', fullfile(dataDir, 'figures\array\CTD_block21-35'))

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
