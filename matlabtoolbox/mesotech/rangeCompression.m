%function: range compression to the raw data due to a Linear FM chirp
%Input: rawData: raw data
%       refPulse: the transmitted pulse in samples
%       numRawSamples: number of the raw data samples
%       numComplexSamples: number of the samples after the range compression, usually smaller than the numRawSamples
%       numElements: number of elements of the receive array
%       rangeKaiserCoef: the parameter that controls the weighting window
%       in the range dimension, from 0 to any large number. larger means
%       better sidelobe compression but with wider main beamwidth.
%       corrCoef: correct coefficient for each element
%Output: echoRangeCompressed: compressed data in the range

function echoRangeCompressed=rangeCompression(rawData, refPulse, numRawSamples, numCompSamples, numElements,rangeKaiserCoef,corrCoef)
%******************************************************************%
%apply correction
% Get the reference pulse from the recorded ping
numTransmitSamples=length(refPulse);
rrfLength = numTransmitSamples;        % Nearest integer
rangeFFTLength = 1024*ceil((numRawSamples+rrfLength-1)/1024);  
%rangeFFTlength should be at least larger than numRawSamples+rrflength-1 to
%make sure the linear convolution

rangeWeighting = kaiser(numTransmitSamples,rangeKaiserCoef);
rangeWeighting=rangeWeighting/sum(rangeWeighting)*numTransmitSamples; %normalize in this way to be consistent with the HSW
% p=100;
% nW=(1:numTransmitSamples)-numTransmitSamples/2;
% nW=nW';
% rangeWeighting =(1/(p*sqrt(2*pi)))*exp(-((nW).^2)/(2*p^2)); %guassian window
rrfTimeWeighted = refPulse.*rangeWeighting;

z = zeros(1,rangeFFTLength-rrfLength);
rrfPadded = [rrfTimeWeighted.',z];
rrfFreq = conj(fft(rrfPadded));  % Note conjugate


%******************************************************************%
%******************************************************************%

% Perform range compression
rngComp=zeros(rangeFFTLength,numElements);

for n = 1:numElements 
    %apply the error correction along the range lines for each element
    rawData(:,n)=rawData(:,n)*corrCoef(n);
    rawDataPadded = [rawData(:,n).',zeros(1,rangeFFTLength-numRawSamples)];
    echoRangeCompFreqDomain = fft(rawDataPadded) .* rrfFreq;
    rngComp(:,n) = ifft(echoRangeCompFreqDomain);
end

% we can discard the zero padded points at the end, and keep only the
% number of compressed samples

echoRangeCompressed = rngComp(1:numCompSamples,:); 

