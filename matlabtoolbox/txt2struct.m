function [output_structure] = txt2struct(textfile, varargin)
% txt2struct: function to automatically convert any delimited textfile into a structure
% format
% preconditions:
% first row is the headerfile
% datatype of each column in the second row are representative of the
% datatypes in the entire file - if not this program will not work!!!!!
%
% NOTE: only works for csv files at present!!!!!!!
% needs a bit of further work to generalise to tab and space delimited
% It does handle NaNs as double not char.
%
% 'skiplines', xx
% 'delimiter', xx
% 'MultipleDelimsAsOne', 1 or 0
%

% Provided to Gavin Macaulay by Tim Ryan, CSIRO  (18 Dec 2007)

% $Id$

% ----------------- START MAIN ------------------

p = inputParser;
p.FunctionName = 'txt2struct';
p.addRequired('textfile', @ischar);
p.addParamValue('skiplines', 0, @isnumeric);
p.addParamValue('delimiter', ',', @ischar);
p.addParamValue('MultiDelimsAsOne', 0, @isnumeric);
p.parse(textfile, varargin{:});

skiplines = p.Results.skiplines;
delimiter = p.Results.delimiter;
multiDelims = p.Results.MultiDelimsAsOne;


if strcmp(delimiter, '\t')
    delimiter = char(9);
end

fid1 = fopen(textfile);
for i = 1:skiplines
    fgetl(fid1);
end

header = fgetl(fid1);
first_row = fgetl(fid1); 
% clear white spaces if the delimiter is not white space
if delimiter~=' '
    first_row = first_row(first_row~=char(32)); 
end

% analyse the first row to determine datatypes
[class_string] = determine_datatype(first_row, delimiter);
% now read entire file into a single cell C
frewind(fid1)
C = textscan(fid1,class_string, 'MultipleDelimsAsOne', multiDelims, 'delimiter',delimiter, 'headerlines',skiplines+1);

% now convert C to a structure using the header fields to name the data
% columns
Hfield = []; S=[];
for i = 1:max(size(C))
    % pick out the next header item
    [Hfield header] = strtok(header, delimiter);
    % trim leading and trailing spaces
    Hfield = strtrim(Hfield);
    % remove /, \, ", and . characters,
    % trailing underscores, and then reduce multiple underscores into one
    % underscore 
    Hfield = regexprep(Hfield, ...
        {'[\./\\"]'; '_+$'; '_+'}, ...
        {'';       '';    '_'; }); 
    % then let matlab adjust the name further to make it a valid structure
    % name. The genvarname() function takes care of whitespace.
    Hfield = genvarname(Hfield);

    try
        % accepts character fields of equal length, otherwise crashes
        if iscell(C{i})
            S.(Hfield) = cell2mat(C{i});
        else
            S.(Hfield) = C{i};
        end
    catch
        % if character field is not equal length, make it a cell
        S.(Hfield) = C{i};
    end
end

output_structure = S;

fclose(fid1);

% ----------------- END MAIN --------------------


% ----------------- LOCAL FUNCTIONS
%
% -------- function determine_datatype ----------------
function [class_string] = determine_datatype(first_row, delimiter)
% function to analyse the first row of a datafile and determine the
% datatype for each column. Assumes that subsequent datatypes will be the
% same for the entire column 
% TER 1-11-2007

i=0; class_string = []; field = [];
while i<max(size(first_row))
    i=i+1;
    while first_row(i) ~= delimiter
        if i< max(size(first_row)) % don't let it exceed the vector length
            field = [field first_row(i)];
            i=i+1;
        else % if it does exceed vector length we've hit the end of the line so break
            field = [field first_row(i)];
            break
        end
    end
    
    if isnan(str2double(field)) && ~isequal(field,'NaN') % we have a non numeric field
        class_string = [class_string '%s'];
    else
        class_string = [class_string '%f'];
    end
    field = [];
end
% -------- end function determine_datatype ------------

