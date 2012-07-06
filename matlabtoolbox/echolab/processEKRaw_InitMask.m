function mask = processEKRaw_InitMask(pings)

global EKMASKBITS

if (~isfield(pings, 'sv'))
    error(['processEKRaw_InitMask requires the volume backscatter ' ...
        'coefficient field "sv".  Set the "linear" parameter to true ' ...
        'when calling readEKRaw_Power2Sv']);
end

%  define ping or sample mode for each bit
%  0 is a sample mask, 1 is a ping mask
EKMASKBITS.bitMode = uint32(bin2dec('00000001111000000000000000000000'));

%  define the EKMASKBITS structure
EKMASKBITS.valid = uint8(32);               %  valid data to integrate
EKMASKBITS.thresholdLow = uint8(31);        %  sample is above min threshold
EKMASKBITS.thresholdHigh = uint8(30);       %  sample is below max threshold
EKMASKBITS.inRegion = uint8(29);            %  sample is in integration region
EKMASKBITS.twentyEight = uint8(28);
EKMASKBITS.twentySeven = uint8(27);
EKMASKBITS.twentySix = uint8(26);
EKMASKBITS.bubbleHigh = uint8(25);          %  bubblehigh state (0 pass  1 fail)
EKMASKBITS.bubbleLow = uint8(24);           %  bubblelow state (0 pass  1 fail)
EKMASKBITS.noBottom = uint8(23);            %  no bottom data
EKMASKBITS.altBottom = uint8(22);           %  alternate bottom used
EKMASKBITS.twentyOne = uint8(21);
EKMASKBITS.twenty = uint8(20);
EKMASKBITS.nineteen = uint8(19);
EKMASKBITS.eighteen = uint8(18);
EKMASKBITS.seventeen = uint8(17);
EKMASKBITS.sixteen = uint8(16);
EKMASKBITS.fifteen = uint8(15);
EKMASKBITS.fourteen = uint8(14);
EKMASKBITS.thirteen = uint8(13);
EKMASKBITS.twelve = uint8(12);
EKMASKBITS.eleven = uint8(11);
EKMASKBITS.ten = uint8(10);
EKMASKBITS.nine = uint8(9);
EKMASKBITS.eight = uint8(8);
EKMASKBITS.seven = uint8(7);
EKMASKBITS.six = uint8(6);
EKMASKBITS.five = uint8(5);
EKMASKBITS.four = uint8(4);
EKMASKBITS.three = uint8(3);
EKMASKBITS.two = uint8(2);
EKMASKBITS.one = uint8(1);

%  set default mask value to '11110000000000000000000000000000'
defMaskVal = uint32(bin2dec('11110000000000000000000000000000'));

%  initialize the mask
mask = repmat(defMaskVal, size(pings(1).sv));