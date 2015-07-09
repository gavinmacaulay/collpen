function [increment_x increment_y] = getOctantIncrement(vect)
% This function calculates the octant in which 'vect' is located. Moreover,
% the sign of the increment is also calculated, returning one among
% the following values:
% [1 0] : positive increment in x
% [-1 0] : negative increment in x
% [0 1] : positive increment in y
% [0 -1] : negative increment in y

%             y++
%          \ 8| 1 /
%           \ |  /
%          7 \| /  2
%  x--________\/________ x++
%             /\
%          6 /| \  3
%           / |  \
%          / 5| 4 \ 
%             y--
%
% Intput:
%   - vect : vector to calculate the octant in which it is located. It must
%   be stored following this pattern [start_x start_y end_x end_y]
%
% Output:
%   - increment_x : increment in the x axis -1, 0 or 1, depending on the
%   octant
%   - increment_y : increment in the y axis -1, 0 or 1, depending on the
%   octant
%
% (c) Jose Carlos Castillo: jccmontoya@gmail.com

x = vect(3) - vect(1);
y = vect(4) - vect(2);

increment_x = 0;
increment_y = 0;

if(abs(y)>=abs(x)) % Octants 1, 4, 5 and 8
    if(y>0) % Octants 1 and 8 -> y++
        increment_y = 1;
    else % Octants 4 and 5 -> y--
        increment_y = -1;
    end
else % Octants 2, 3, 6 and 7
    if(x>0)
        increment_x = 1;
    else
        increment_x = -1;
    end
end


end