%this is the algorithm from reading the raw data till locating the point target using splited beam detection. 
%It is modified from the code titled "PointExtraction_rawData". 

%Features: 
%1. support correction file for the receiver
%2. support subarray design for split beam
%3. support weighting window adjustment for both range and azimuth directions
%4. support equiangular and equispace beamforming


%Required subroutines: beamListGeneration.m, rangeCompression.m,
%azimuthProcess.m, load_raw_data.mexw32,read_rx_corrns_file.m if the
%correction is required, and linerInterpFFT.m.

%Author: Jinyun Ren v0.0 Sept 23 2011

close all;
clear all;

%*************Beamforming Parameters***********************
%**********************************************************
%*************FIXED****************************************
MUM_MAX_RANGE=500;
MAX_FOCAL_ZONES=128;
j=sqrt(-1);  %j is reserved for the complex function
Focusing=1;  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%1 or 0 for dynamic focusing
Correction=1; %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%1 or 0 for correction 


%*************AJUSTABLE**************************************
viewAngle=[180 90];  %view angle for head down installation. The default is viewAngle=[0 90];  
simulatedTarget=0;
rangeKaiserCoef=1.7; %filter coefficient for the range compression - default is 1.7
azKaiserCoefFullbeam=1.7;  %%filter coefficient for the azimuth process using Full beam - default is 1.7
azKaiserCoefSplitbeam=4;  %%filter coefficient for the azimuth process using splited beam - default is 4
numBeams=128; %number of beams, could be 62, 128 and 256 -default is 128.

%prepare the beam List based on the application
% 'equiangular' or 'equispaced'
beamList=beamListGeneration('equiangular', numBeams);
if length(beamList)~=numBeams   %the beamListGeneration may increase the numBeams by 1;
    numBeams=length(beamList);
end


% Read raw data THIS ONE IS GOOD
%pathname='C:\Users\peterf\Documents\M3\M3_Horizontal_Split_Beam\';
pathname = '';
% filename='Aug10,2011,22-29-21.mmb';
% actual_ping_num=1167;


% filename='Sep08,2011,18-40-44.mmb';
% actual_ping_num=12909;
% 

%filename='Fish_at_wier_looking_horizontal_stationary_split_beam.mmb';
%actual_ping_num=2301;

% filename = 'Oct05,2011,23-44-21LOOP.mmb';
% actual_ping_num = 126;
[header refPulse rawData PING_FOUND] = load_raw_ping ('Fish_at_wier_looking_horizontal_stationary_split_beam.mmb', 2301, []);


% filename='Wshape.mmb';
% actual_ping_num=2134;

% filelocation=[pathname,filename];
% ping_num=0;
% [header refPulse rawData] = load_raw_data(filelocation, ping_num);

%*************Profiling Parameters***********************
%********************ADJUSTABLE***************************
numElementsInSubArray=42; %number of elements in the subarray
distanceBWSubArray=20; % distance between two subarrays in terms of number of elements

%***********************END of Parameters**************************
%*******************************************************************

%read some parameter from the header
transmitPulseDuration=1/header.Rx_Filter_BW;
rangeMin = header.Min_Range;
rangeMax = header.Max_Range;
c=header.Velocity_Sound;
fCarrier=500000;
lambda=c/fCarrier;

sampleRawInterval = header.Raw_Sample_Interval; % in seconds
sampleRawRate = 1/sampleRawInterval;              % range sampling rate in Hz
  
%Sample Window Start Time and Sample Window Length
sampleWindowStartTime = header.Sampling_Window_Start_Time;%2*rangeMin/c                                % in seconds
sampleWindowLength = header.Sampling_Window_Length;%2*(rangeMax/1400 - rangeMin/1560)+transmitPulseDuration;            %in seconds
% number of raw samples in the sampling window
numRawSamples = header.End_Raw_Sample-header.Start_Raw_Sample+1;
numElements=header.Num_Elements; 

% array parameters for linear array
elementPositions = struct('xCoordinate', {}, 'yCoordinate', {});
elementXPosition=linspace(-48.006/1000, 48.006/1000, 64);
for eI=1:length(elementXPosition)
    elementPositions(eI).xCoordinate=elementXPosition(eI); %geometry for M3 sonar
    elementPositions(eI).yCoordinate=0.039370;
end

% % note that without deliberate interpolation in the range processor, that
% % the sampling interval in the processed data is the same at that in the
% % raw data
% 
sampleCompInterval = sampleRawInterval;
%numCompSamples = floor((2*(rangeMax - rangeMin)/c)/sampleCompInterval);
numCompSamples=numRawSamples-length(refPulse); %change this one to be consistent with the HSW



if simulatedTarget==1
    %simulating point targets
    % settings
    %==========
    settings.TXWST = 25;
    settings.SWST = sampleWindowStartTime*1e6;
    settings.SWL = sampleWindowLength*1e6;
    settings.T_s = sampleRawInterval*1e6;
    settings.Sound_Speed = c;
    settings.F_c = 500e3;
    settings.Rx_Array_Geometry_XYZ (:,1)= elementXPosition;
    settings.Rx_Array_Geometry_XYZ(:,2) = zeros(64,1);  % Zero the y-component
    settings.Rx_Array_Geometry_XYZ(:,3) = zeros(64,1);  % Zero the z-component
    settings.Tx_Geometry_XYZ = [0 0 0];
    settings.Tx_Phase=0;
    % targets
    %========
    targets{1}.range    = 1.25;
    targets{1}.azimuth  = -6;
    targets{1}.height   = 0;
    targets{1}.strength = 0;

    targets{2}.range    = 2.09;
    targets{2}.azimuth  = 15;
    targets{2}.height   = 0;
    targets{2}.strength = 0;

    targets{3}.range    = 3.5;
    targets{3}.azimuth  = 0;
    targets{3}.height   = 0;
    targets{3}.strength = 0;
    
    options.Noise_Power = -40;

    [simHeader rawData] = point_target_simulator(refPulse, settings, targets, options);
    figure;imagesc(abs(rawData))
    title('Raw data amplitude');
    set(gca, 'XDir', 'reverse', 'YDir', 'normal');
  
else
    
%     %Find the ping to be read
% 
%     if (header.Ping_Counter~=actual_ping_num)
%         deltaP=actual_ping_num-header.Ping_Counter;
%         ping_num=ping_num+deltaP-floor(deltaP*0.5); %count the missing pings as 50 percent of the total number
%     end
% 
%     ping_num = 0;
%     disp(['Searching for Ping Count ' num2str(actual_ping_num)]);
%     while (header.Ping_Counter~=actual_ping_num)   
%         ping_num=ping_num+1;
%         [header refPulse rawData] = load_raw_data(filelocation, ping_num);
%         disp([filelocation '; ping_num = ' num2str(ping_num) '; Ping Counter = ' num2str(header.Ping_Counter)]);
%     end

    figure;imagesc(abs(rawData))
    title('Raw data amplitude');
    set(gca, 'XDir', 'reverse', 'YDir', 'normal');
end

%******************************************************************%
%******************************************************************%
%Range Compression
if Correction==0
    corrCoef=ones(numElements,1);
else
    %read the correction data
    corrCoef = header.Rx_Phase_Amp_Corrections(1:numElements);
end 
echoRangeCompressed=rangeCompression(rawData, refPulse, numRawSamples, numCompSamples, numElements,rangeKaiserCoef,corrCoef);

% Display the range-compressed data
figure;
imagesc(abs(echoRangeCompressed));
title(['Range-compressed data amplitude',' ping number=', num2str(header.Ping_Counter)]);
set(gca, 'XDir', 'reverse', 'YDir', 'normal');


%******************************************************************%
%******************************************************************%
% perform Azimuth process (include beamforming and dynamic focusing)
systemMinRange=header.System_Min_SWST*header.Velocity_Sound/2;
focalTolerance=header.Focal_Tolerance; %the default setup is 22.5.
%focalTolerance=11.25; %for testing
sampleCompStep = c*sampleCompInterval/2;
TXWST=25e-6;  %this is Tx Window Start time
rangeMinActual=(sampleWindowStartTime-TXWST)*c/2; %the actual sampling range is closer than the min range in the setup
% here 25us is TXWST, tx window start time, the acoustic signal start after
% TXWST, so the rangle of the first sample should be calculated in this
% way, which is always smaller than 0.2.
rangeList = rangeMinActual+(0:numCompSamples-1)*sampleCompStep;                 % Index from zero

imageRangeAzimuth=AzimuthProcess(echoRangeCompressed,sampleCompStep,...
    elementPositions,beamList,focalTolerance,systemMinRange,rangeMinActual,MAX_FOCAL_ZONES,MUM_MAX_RANGE,lambda,Focusing,azKaiserCoefFullbeam);
% figure;
% imagesc(beamList, rangeList,abs(imageRangeAzimuth));
% title(['beamformed data- full beam',' ping number=', num2str(header.Ping_Counter)]);
% xlabel('Beam Angle (\circ)');
% ylabel('Range (m)');
% set(gca, 'XDir', 'reverse', 'YDir', 'normal'); %reversing x axis is because the element of the M3 starts from right side. 

%convert polar to cartisan coordiante
imageX=zeros(numCompSamples,numBeams);
imageZ=zeros(numCompSamples,numBeams);
for rangeIndex=1:numCompSamples
    for beamIndex=1:numBeams
      imageX(rangeIndex,beamIndex)=rangeList(rangeIndex)*sin(beamList(beamIndex)*pi/180);  
      imageZ(rangeIndex,beamIndex)=rangeList(rangeIndex)*cos(beamList(beamIndex)*pi/180);  
    end
end


%% split beam processing
totalSubArray=floor((numElements-numElementsInSubArray)/distanceBWSubArray)+1;
imageRangeAzimuthTotal=zeros(numCompSamples,numBeams,totalSubArray);
subArrayPosition=zeros(totalSubArray,1);
filterL=floor(transmitPulseDuration/sampleCompInterval); %filter the range using the pulse length
aveWin=ones(filterL,filterL)/(filterL*filterL);
   
for arrayIndex=1:totalSubArray
    subArray=(arrayIndex-1)*distanceBWSubArray+1:(arrayIndex-1)*distanceBWSubArray+numElementsInSubArray;
    subArrayElementPosition=elementPositions(subArray);
    %the position of array is assumed to be the middle of the subarray
    subArrayPosition(arrayIndex)=(subArrayElementPosition(end).xCoordinate-subArrayElementPosition(1).xCoordinate)/2+subArrayElementPosition(1).xCoordinate;
    for subIndex=1:length(subArrayElementPosition)
        subArrayElementPosition(subIndex).xCoordinate=subArrayElementPosition(subIndex).xCoordinate-subArrayPosition(1); %all the element positions is relative to the center of the first subarray
    end

    subEechoRangeCompressed=echoRangeCompressed(:,subArray);

    imageRangeAzimuthTotal(:,:,arrayIndex)=AzimuthProcess(subEechoRangeCompressed,sampleCompStep,...
        subArrayElementPosition,beamList,focalTolerance,systemMinRange,rangeMinActual,MAX_FOCAL_ZONES,MUM_MAX_RANGE,lambda,Focusing,azKaiserCoefSplitbeam);
    %filter the image before finding the phase difference turns out to have
    %better results.
    imageRangeAzimuthTotal(:,:,arrayIndex)=conv2(imageRangeAzimuthTotal(:,:,arrayIndex),aveWin,'same'); %mean filter
end
figure;
pcolor(imageX,imageZ,abs(imageRangeAzimuthTotal(:,:,1)))
shading flat
title(['beamformed data- first subarray',' ping number=', num2str(header.Ping_Counter)]);
xlabel('Azimuth (m)')
ylabel('Distance from sonar head (m)')
set(gca, 'XDir', 'reverse', 'YDir', 'normal'); %reversing x axis is because the element of the M3 starts from right side.


figure;
pcolor(imageX,imageZ,abs(imageRangeAzimuthTotal(:,:,2)))
shading flat
title(['beamformed data- second subarray',' ping number=', num2str(header.Ping_Counter)]);
xlabel('Azimuth (m)')
ylabel('Distance from sonar head (m)')
set(gca, 'XDir', 'reverse', 'YDir', 'normal'); %reversing x axis is because the element of the M3 starts from right side.

phaseDiff=angle(imageRangeAzimuthTotal(:,:,2))-angle(imageRangeAzimuthTotal(:,:,1)); %phase difference for each point
%It is not good to filter the phaseDiff if a point target is of interest
% figure;
% pcolor(imageX,imageZ,phaseDiff)
% shading flat
% title(['beamformed data- second subarray',' ping number=', num2str(header.Ping_Counter)]);
% xlabel('Azimuth (m)')
% ylabel('Distance from sonar head (m)')
% set(gca, 'XDir', 'reverse', 'YDir', 'normal'); %reversing x axis is because the element of the M3 starts from right side.

ArraySeparation=subArrayPosition(2)-subArrayPosition(1);
aK=2*pi*ArraySeparation/lambda;

%% Target detection mannually
figure;
pcolor(imageX,imageZ,20*log(abs(imageRangeAzimuth))) %this is the beamformed data using full array
shading flat
xlabel('Azimuth (m)')
ylabel('Distance from sonar head (m)')
title('Beamformed Data in polar');
hold on;
r1=rangeList(1);
r2=rangeList(end);
for a = -60:30:60
        plot([r1 r2].*sin(-a*pi/180), [r1 r2].*cos(-a*pi/180), 'r--');
        text(r2*1.05*sin(-a*pi/180), r2*1.05*cos(-a*pi/180), [num2str(-a) '\circ']);
end
set(gca, 'XDir', 'reverse', 'YDir', 'normal');
%grid on;
%axis equal;
view(viewAngle)


waitfor(msgbox({'1. Maximize the figure First.'; '2. Select the target using left-button of the mouse to estimate its bearing.'; '3. Press CTRL+C to exit!'},'Instruction') );
displayFormat='%10.2f';
targetNum=1;
targetEst=[];
while (1)
    k = waitforbuttonpress;
    point1 = get(gca,'CurrentPoint');    % button down detected
    finalRect = rbbox;                   % return figure units
    point2 = get(gca,'CurrentPoint');    % button up detected
    point1 = point1(1,1:2);              % extract x and y
    point2 = point2(1,1:2);
    p1 = min(point1,point2);             % calculate locations
    offset = abs(point1-point2);         % and dimensions
    x = [p1(1) p1(1)+offset(1) p1(1)+offset(1) p1(1) p1(1)];
    y = [p1(2) p1(2) p1(2)+offset(2) p1(2)+offset(2) p1(2)];
    hold on
    axis manual
    plot(x,y,'w')                            % redraw in dataspace units
    
    %get the range and beamlist for each point defined by x and y
    pointRange=zeros(4,1);
    pointAngle=zeros(4,1);
    for pointIndex=1:4
        pointRange(pointIndex)=sqrt(x(pointIndex)^2+y(pointIndex)^2);
        pointAngle(pointIndex)=atan(x(pointIndex)/y(pointIndex))*180/pi;
    end
    startRange=min(pointRange);
    endRange=max(pointRange);
    startAngle=min(pointAngle);
    endAngle=max(pointAngle);
    
    %match the point position to the range and beam list
    tempIndex=find(rangeList<=startRange);
    rangeStartIndex=tempIndex(end);
    tempIndex=find(rangeList>=endRange);
    rangeEndIndex=tempIndex(1);
    
    tempIndex=find(beamList<=startAngle);
    beamStartIndex=tempIndex(end);
    tempIndex=find(beamList>=endAngle);
    beamEndIndex=tempIndex(1);
    
    pointOfInterest=imageRangeAzimuth(rangeStartIndex:rangeEndIndex,beamStartIndex:beamEndIndex);
    
    %figure;imagesc(beamList(beamStartIndex:beamEndIndex),rangeList(rangeStartIndex:rangeEndIndex),abs(pointOfInterest))
    
    %find the maximum inside the rectangle
    %change y here which is used before!!!
    [MRIndex,MBIndex]=find(abs(imageRangeAzimuth)==max(max(abs(pointOfInterest)))); %find the max index from the original data set
    [beamY,yIndex]=linearInterpFFT(imageRangeAzimuth(MRIndex,beamStartIndex:beamEndIndex), beamList(beamStartIndex:beamEndIndex),8);
    maxMag=max(abs(beamY));
    maxBeamIndex=find(abs(beamY)==maxMag); %abs is used to avoid the complex value of y
    maxBeamAngle=yIndex(maxBeamIndex); %find the beam angle after the interpolation
    
%     figure;plot(beamList(beamStartIndex:beamEndIndex),(abs(imageRangeAzimuth(MRIndex,beamStartIndex:beamEndIndex))),'b-')
%     hold on; plot(yIndex,abs(beamY),'g-*')
    
    %however, we want to put the point inside one particular beam, so we
    %need find the beam angle in the beamList which is closer to the
    %maxBeamAngle.
    tbeam=abs(beamList-maxBeamAngle); %the beam angle closest to the maxBeamAngle has a value closer to zero
    chosenBeamIndex=find(tbeam==min(tbeam));%note here might be two indices
    beamCenter_deg=beamList(chosenBeamIndex(1)); %sometimes the estimated angle is right in the middle of two beams so the chosen beam indes has two entries.
  %shift the off center angle using the beam angle in the beam List  
      
    targetNum
    targetPD=phaseDiff(MRIndex,chosenBeamIndex(1)); %the phase difference for the target
    theta=asin(targetPD/aK)*180/pi;
    offCenterAngle_deg=theta; %the target angle off the beam center
    AOA_deg=theta+beamCenter_deg; %actual angle of arrival of the target
    Range_m=rangeList(MRIndex); % range in meter
    mag_dB=20*log10(maxMag); %target strength in dB
    targetEst(targetNum,1)=offCenterAngle_deg
    targetEst(targetNum,2)=beamCenter_deg
    targetEst(targetNum,3)=AOA_deg
    targetEst(targetNum,4)=Range_m
    targetEst(targetNum,5)=mag_dB
    targetNum=targetNum+1;
%     
%         text(0,0,['Off-Center Angle: ', num2str(offCenterAngle_deg,displayFormat), '\circ'],'color','w')
%         text(x(3)+0.01,y(2),['Beam Angle: ', num2str(beamCenter_deg,displayFormat),'\circ'],'color','w')
%         text(x(3)+0.01,y(2)+0.02*rangeList(end),['AOA: ', num2str(beamCenter_deg+offCenterAngle_deg,displayFormat),'\circ'],'color','w')
%         text(x(3)+0.01,y(2)+0.04*rangeList(end),['Range: ', num2str(Range_m,displayFormat),' m'],'color','w')
%         text(x(3)+0.01,y(2)+0.06*rangeList(end),['Strength: ', num2str(mag_dB,displayFormat),' dB'],'color','w')
%         
%         
%     if viewAngle(1)==180
%         text(x(3)+0.01,y(3)-0.02*rangeList(end),['Off-Center Angle: ', num2str(offCenterAngle_deg,displayFormat), '\circ'],'color','g')
%         text(x(3)+0.01,y(3),['Beam Angle: ', num2str(beamCenter_deg,displayFormat),'\circ'],'color','g')
%         text(x(3)+0.01,y(3)+0.02*rangeList(end),['AOA: ', num2str(beamCenter_deg+offCenterAngle_deg,displayFormat),'\circ'],'color','g')
%         text(x(3)+0.01,y(3)+0.04*rangeList(end),['Range: ', num2str(Range_m,displayFormat),' m'],'color','g')
%         text(x(3)+0.01,y(3)+0.06*rangeList(end),['Strength: ', num2str(mag_dB,displayFormat),' dB'],'color','g')
%     else
%         text(x(4)-0.01,y(4)+0.02*rangeList(end),['Off-Center Angle: ', num2str(offCenterAngle_deg,displayFormat), '\circ'],'color','w')
%         text(x(4)-0.01,y(4),['Beam Angle: ', num2str(beamCenter_deg,displayFormat),'\circ'],'color','w')
%         text(x(4)-0.01,y(4)-0.02*rangeList(end),['AOA: ', num2str(beamCenter_deg+offCenterAngle_deg,displayFormat),'\circ'],'color','w')
%         text(x(4)-0.01,y(4)-0.04*rangeList(end),['Range: ', num2str(Range_m,displayFormat),' m'],'color','w')
%         text(x(4)-0.01,y(4)-0.06*rangeList(end),['Strength: ', num2str(mag_dB,displayFormat),' dB'],'color','w')
%     end 

display(['Off-Center Angle: ', num2str(offCenterAngle_deg,displayFormat),' degrees'])
display(['Beam Angle: ', num2str(beamCenter_deg,displayFormat),' degrees'])
display(['AOA: ', num2str(beamCenter_deg+offCenterAngle_deg,displayFormat),' degrees'])
display(['Range: ', num2str(Range_m,displayFormat),' m'])
display(['Strength: ', num2str(mag_dB,displayFormat),' dB'])
   
    
    figure;plot(beamList(beamStartIndex:beamEndIndex),20*log10(abs(imageRangeAzimuth(MRIndex,beamStartIndex:beamEndIndex))),'r-x')
    xlabel('beam angle (degree)')
    ylabel('Amplitude (dB)')

    figure;plot(beamList(beamStartIndex:beamEndIndex),(phaseDiff(MRIndex,beamStartIndex:beamEndIndex)),'g-o')
    xlabel('beam angle (degree)')
    ylabel('phase difference (radians)')
    
end

%***************************************************************
%***************************************************************
% %% target localization automatically
% 
% echoThreshold=10; %echo level relative to the neighbouring data, default 10dB level
% minThreshold=-60;
% sidelobeLevel=18; %Sidelobe level at the same range in dB, default 10dB down
% 
% filterL=floor(transmitPulseDuration/sampleCompInterval); %filter the range using the pulse length
% aveWin=ones(filterL,1)/(1*filterL);
% imageRangeAzimuthMagFiltered=conv2(abs(imageRangeAzimuth),aveWin,'same'); %mean filter
% imageRangeAzimuthMagFiltereddB=20*log10(imageRangeAzimuthMagFiltered); %convert the image to dB
% 
% [maxPerBeam, maxIndex]=max(abs(imageRangeAzimuthMagFiltered);
% for 
% for beamIndex=1:numBeams
%     beamSlice=imageRangeAzimuthMagFiltered(:,beamIndex);
%     tt=max(beamSlice);
%     
% end
% 
% candSet=zeros(size(imageRangeAzimuth));
% bottomCandFlag=zeros(1,numBeams);
% 
% for beamIndex=1:numBeams
%     imageSlice=imageRangeAzimuthMagFiltereddB(:,beamIndex);
%     imageSliceFiltered=filter(ones(1,filterWindowSize)/filterWindowSize,1,imageSlice);
% %     figure;plot(imageSlice)
% %     hold on;plot(imageSliceFiltered,'r')
%     IX=find((imageSlice-imageSliceFiltered)>=echoThreshold); %find candidates which are 10dB larger than the averaged neighbouring data
%     candSet(IX,beamIndex)=imageSlice(IX);
%     candSet(find(candSet(:,beamIndex)<minThreshold),beamIndex)=0; %remove the point below minimum signal level
%     if ~isempty(find(candSet(:, beamIndex)))
%        bottomCandFlag(beamIndex)=1; %yes, this beam contains candidates 
%     end
% end
% 
% figure;
% pcolor(imageX,imageZ,candSet)
% shading flat
% set(gca, 'XDir', 'reverse', 'YDir', 'normal');
% xlabel('Azimuth (m)')
% ylabel('Distance from sonar head (m)')
% title('Bottom detection candidates');
% 
% % apply the sidelobe filter
%  if sidelobeFilter==1
%            
%         for sampleIndex=1:numCompSamples
%             rangeSlice=candSet(sampleIndex,:);
%             maxMag=max(rangeSlice);
%             candIndex=find(rangeSlice<maxMag); %10dB for sidelobes
%             candSet(sampleIndex,candIndex)=0;
%         end
% 
%         for beamIndex=1:numBeams
%             if isempty(find(candSet(:, beamIndex)))
%                 bottomCandFlag(beamIndex)=0; %check again and see if this beam contains candidates
%             end
%         end
% 
%         figure;
%         pcolor(imageX,imageZ,candSet)
%         shading flat
%         set(gca, 'XDir', 'reverse', 'YDir', 'normal');
%         xlabel('Azimuth (m)')
%         ylabel('Distance from sonar head (m)')
%         title('Bottom Candidates after the sidelobe filter');
%  end
% 
% ArraySeparation=subArrayPosition(2)-subArrayPosition(1);
% aK=2*pi*ArraySeparation/lambda;
% 
% candSetMag=zeros(size(candSet)); %the candidate set magnitude
% nonZeroIndex=find(candSet); %find non zero index
% candSetMag(nonZeroIndex)=10.^(candSet(nonZeroIndex)/20); %convert it to non dB value
% targetNum=length(find(bottomCandFlag)); %number of targets
% targetEst=zeros(targetNum,3); %the first column is angle, the second one is range, and the third one is amplitude
% targetIndex=1;
% for beamIndex=1:numBeams
%     %detect phase difference for the maximum value if this beam is not
%     %empty
%     if bottomCandFlag(beamIndex)~=0
%         imageSlice=candSetMag(:,beamIndex);
%         maxIndex=find(imageSlice==max(imageSlice)); %at range direction
%         deltaP=phaseDiff(maxIndex,beamIndex);
%         theta=asin(deltaP/aK)*180/pi; %angle of arrival relative to the beam
%         targetEst(targetIndex,1)=theta+beamList(beamIndex); %actual angle in degree
%         targetEst(targetIndex,2)=rangeList(maxIndex); %actual angle in degree
%         targetEst(targetIndex,3)=abs(imageRangeAzimuth(maxIndex,beamIndex)); %actual angle in degree
%         targetIndex=targetIndex+1;
%     end
% end
% 
% 
% % figure;plot(abs(imageRangeAzimuthTotal(:,67,1)))
% % hold on;plot(abs(imageRangeAzimuthTotal(:,67,2)),'r')
% % 
% % figure;plot(angle(imageRangeAzimuthTotal(:,67,1)))
% % hold on;plot(angle(imageRangeAzimuthTotal(:,67,2)),'r')
% % 
% % figure;plot(angle(imageRangeAzimuthTotal(:,67,1))-angle(imageRangeAzimuthTotal(:,67,2)))
% % hold on;plot(angle(imageRangeAzimuthTotal(:,67,2)),'r')
