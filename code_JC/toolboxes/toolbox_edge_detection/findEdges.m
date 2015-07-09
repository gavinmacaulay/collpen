function findEdges(folder, avifilename, showmsg)
% This method extract the edges of the frames contained in a .avi sequence.
% Also the differnt regions contained in the image are labeled to enable
% further tracking
%
% Input:
%   - folder : path of the video to be analyzed
%   - avifilename: video to be analyzed
%   - showmsg : 1 or 0, if 1 shows messages
%
% Output:
%   - TO DO : find a proper way to store / return the edges
%
% (c) Jose Carlos Castillo: jccmontoya@gmail.com


avifilename=strrep([avifilename '.avi'],'.avi.avi','.avi');

% Datafolder
datafolder = [folder '/PIVdata'];
if ~(exist(datafolder,'dir')==7)
    dispMsg(showmsg,['[findEdges]: Creating data folder, ' datafolder]);
    mkdir(datafolder);
end
tmpfilepathbg = strrep([datafolder '/' avifilename],'.avi','_BG.bmp');


% Setting return to empty
image=[];
filepathbg=[];

% Initiating arguments
if nargin<2
    warning(1,'Too few input arguments: findEdges(folder, avifilename, showmsg)')
    return;
end
if nargin>3
    warning(2,'Too many input arguments: findEdges(folder, avifilename, showmsg)')
    return;
end

    
% getting BG image
dispMsg(showmsg,'[findEdges]: Load BG image');
bg_image = loadBackground(tmpfilepathbg,showmsg);

if(bg_image==-1)
    dispMsg(showmsg,['[findEdges]: BG image not found in: ' tmpfilepathbg '. Aborting...']);
    return;
end

dispMsg(showmsg,'[findEdges]: BG loaded');


% Get edges from video sequence
getEdges([folder '/' avifilename], bg_image, showmsg);

end

%% Load BG image
function BG = loadBackground(bgPath, debug)

if exist(bgPath, 'file') == 2
    dispMsg(debug,'[findEdges]: Loading BG image')
    BG      = imread(bgPath);
    imshow(BG);
    return;
end
dispMsg(debug,'[findEdges]: BG not found')

BG = -1;
end

function dispMsg(on, msgtext)
if on
    disp(msgtext);
end
end