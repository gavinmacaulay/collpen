%%
% Simple script to plot ctd casts done during the blocks

blocks = 21:35;
dataDir = '\\callisto\collpen\AustevollExp\data\HERRINGexp';

figure
for i = blocks
    path = fullfile(dataDir, ['block' num2str(i)], 'ctd');
    d = dir(fullfile(path, '*eng.txt'));
    if ~isempty(d)
        for j = 1:length(d)
            ctd = txt2struct(fullfile(path, d(j).name), 'skiplines', 3, 'delimiter', '\t');
            
            k = find(ctd.Press > 0.5);
            plot(ctd.SVel(k), ctd.Press(k), 'k')
            hold on
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
