
%  this is a collection of code snippets showing how I read in the ES60 raw
%  and bot files. It doesn't actually do anything and it will not actually
%  run unless you define calParms by reading in calibration parameters.


%  Set the GPS source. Use GPGLL for Aldeb and GPGGA for Arcturus
GPSSOURCE = 'GPGGA';

%  set the initial bottom reader state to undefined (-1). The bottom reader
%  state contains details about where readEKOut left off reading a
%  particular bottom file and allows readEKOut to quickly pick up where it
%  left off. We don't make this struct, it is returned from readEKOut.
botStat = -1;

%  define input paths
inPath = '\\AFSC\Acoustic_RACE_GF\2009\EBS_2009_Arcturus';


%  get some info about the input files
rawLines = rawLoader_GetES60LineInfo(inPath);

%  loop thru all lines
nLines = length(rawLines);
for thisLine=1:1 %nLines
    
    %  loop thru all raw files in this line
    for thisFile=1:1 %rawLines(thisLine).nFiles

        %  construct raw filenames
        rawName = rawLines(thisLine).rawFile{thisFile};
        rawFile = [inPath '\' rawName];
        if (thisFile < rawLines(thisLine).nFiles)
            %  construct the next raw file's path
            nextRaw = [inPath '\' ...
                rawLines(thisLine).rawFile{thisFile + 1}];
        else
            nextRaw = [];
        end

        %  read .raw file - it is a good idea to set Skinny to false
        %  becuase you can't rely on the fact that basic parameters such as
        %  sound speed will be constant throughout the data file. Even
        %  though you are specifying sound speed in the calibration
        %  structure, bottom depth is calculated using the sound speed
        %  specified at the time of recording.
        [header, rawData, rawStat] = readEKRaw(rawFile, 'Angles', false, ...
            'Skinny', false, 'GPSSource', GPSSOURCE);


        %  check if we need to reset the bottom reader state
        if (thisFile > 1)
            if (~strcmp(rawLines(thisLine).outFile{thisFile}, ...
                    rawLines(thisLine).outFile{thisFile-1}))
                botStat = -1;
            end
        end
        
        %  read bottom data from .out file for the time range
        %  covered by this .raw file. By passing in the rawData structure
        %  readEKOut assumes we only want bottom data for the pings
        %  contained in the rawData structure.
        botName = rawLines(thisLine).outFile{thisFile};
        botFile = [inPath '\' botName];
        [header, botData, botStat] = readEKOut(botFile, calParms, ...
            rawData, 'ReaderState', botStat, 'Continue', true);

    
    end
end
