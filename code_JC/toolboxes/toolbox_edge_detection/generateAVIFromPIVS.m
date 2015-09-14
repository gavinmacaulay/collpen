function generateAVIFromPIVS(folder)

d=dir([folder '*.avi']);

for i=1:length(d)
    filedir{i} = '/Volumes/Datos/collpen/predator/';
    file{i} = d(i).name;
end

% Datafolder
datafolder = [filedir{1} 'PIVdata2'];


f = figure;

for i = 1:length(d)
     
    filepath = [filedir{i}  file{i}];
    % Datapath
    datapath   = strrep([filedir{i} 'PIVdata2/' file{i}],'.avi','_PIV.mat');
    pivavipath = strrep(datapath, 'mat','avi');
    disp(['Generate PIV video for file ' filepath]);
    load(datapath);
    
     % Opening movie object
    disp(['..Opening ' filepath]);
    
    movieobj = VideoReader(filepath);
    
    n    = movieobj.NumberOfFrames-1;
    %aviobj = avifile(pivavipath, 'compression', 'none', 'fps',8);
    aviobj = VideoWriter(pivavipath);
    aviobj.FrameRate = movieobj.FrameRate;
    open(aviobj);

    % Loop to generate avi file
    disp(['Creating PIV avi in ' pivavipath]);
    tic
    for j = 1: n
            I   = rgb2gray(read(movieobj, j));
            colormap gray
            [r, c] = size(I);
            subplot(1,2,1);
            imagesc(I); axis equal;axis tight;
            subplot(1,2,2); 
            imagesc(I); axis equal;axis tight;
            hold on
            %US = imresizeNN(us(:,:,j),size(I));
            %VS = imresizeNN(vs(:,:,j),size(I));
            US = us(:,:,j);
            VS = vs(:,:,j);
            US = medfilt2(US); % Median filter
            VS = medfilt2(VS); % Median filter
            uindex = find(US);
            ux = floor(uindex/100)+1;
            uy = mod(uindex,100);
            USi = US(uindex);
            VSi = VS(uindex);
            quiver(ux*c/100, uy*r/100, USi, VSi, 2,'r');

            hold off
            pause(0.125);
            F = getframe(f);
           % aviobj = addframe(aviobj,F.cdata);
            videoWriter(aviobj,F.cdata);

    end
    toc
    close(aviobj); 
    disp('Video created');
end
