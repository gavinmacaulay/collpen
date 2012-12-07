function A04PlotSL
    
    %
    
    %
    
    load(fullfile('..', 'results', 'A03CalculateSL_experiments'), 'experiments')
    

    for exp_i = 1:length(experiments)
        clf
        d = [];
        if ~isempty(experiments(exp_i).file)
            % collect data into a more convenient form
            for chan_i = 1:length(experiments(exp_i).signal)
                dSL(:, chan_i) = experiments(exp_i).signal(chan_i).SL;
                dSPL(:, chan_i) = experiments(exp_i).signal(chan_i).SPL;
            end
            
            legend_text = {};
            for i = 1:length(experiments(exp_i).signal(chan_i).SL)
                legend_text{i} = ['Ch ' num2str(i)];
            end
            
            % and plot
            plot([experiments(exp_i).signal.freq] , dSL, '.-')
            xlabel('Frequency (Hz)')
            ylabel('SL (dB re 1m re 1\muPa)')
            title(['Experiment ' experiments(exp_i).file])
            legend(legend_text, 'Location', 'EastOutside', 'FontSize', 6)
            print('-dpng', '-r300', fullfile('..', 'results', ...
                   ['A04PlotSL_' experiments(exp_i).file(1:end-4)]))

            plot([experiments(exp_i).signal.freq] , dSPL, '.-')
            xlabel('Frequency (Hz)')
            ylabel('SPL (dB re 1\muPa)')
            title(['Experiment ' experiments(exp_i).file])
            legend(legend_text, 'Location', 'EastOutside', 'FontSize', 6)
            print('-dpng', '-r300', fullfile('..', 'results', ...
                   ['A04PlotSL_SPL_' experiments(exp_i).file(1:end-4)]))

               %pause
        end
    end
end


