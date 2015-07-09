% compile the mex files for the Wavelet toolbox.
%
%   Copyright (c) 2006 Gabriel Peyré

disp('---> Compiling Jpeg2000 mex files.');

rep = 'jp2k/src/';
strbase = 'mex ';
if ispc
    % windows special definitions
    strbase = [strbase ' -Dcompil_vcc -DWIN32 '];
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Compile jp2_class
if 0
files = {'jp2_codec.c' 'bio.c' 'dwt.c' 'j2k.c' 'mct.c' 'pi.c' 't2.c' 'tgt.c' ...
            'cio.c' 'fix.c' 'int.c' 'mqc.c' 't1.c' ...
            'tcd.c' 'image_jp2.c' 'liw_jp2_dll.c' 'liw_error.c'};
str = [strbase '-output jp2_class '];
for i=1:length(files)
    str = [str rep files{i} ' '];
end
eval(str);
end
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Compile jp2_class
files = {'jp2_codec.c' 'bio.c' 'dwt.c' 'j2k.c' 'mct.c' 'pi.c' 't2.c' ...
            'tgt.c' 'cio.c' 'fix.c' 'int.c' 'mqc.c' 't1.c' 'tcd.c' ...
            'image_jp2.c' 'liw_jp2_dll.c' 'liw_error.c'};
str = [strbase ' -DENCODE_ONLY -output perform_jp2k_encoding '];
for i=1:length(files) 
    str = [str rep files{i} ' '];
end
eval(str);



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
disp('---> Compiling wavelet transforms mex files.');

mex mex/perform_79_transform.cpp
mex mex/perform_haar_transform.cpp
mex mex/perform_lifting_transform.cpp