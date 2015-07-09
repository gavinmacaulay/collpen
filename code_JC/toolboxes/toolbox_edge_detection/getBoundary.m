function [dist x y] = getBoundary(img, vector)
% This function follows the straight line given by vector until it gets to
% the border of the image or reaches a boundary
% img must be a binary image
%
% Input: 
%   - img : binary input image (check imagePreprocess.m)
%   - vector : vector that defines the origin and direection of the
%   straight line to detect boundaries [start_x start_y end_x end_y]
%
% Output:
%   - dist : distance to the origin of the vector. -1 if no boundary is
%   reached
%   - x : x position of the boundary. -1 if no boundary is found
%   - y : y position of the boundary. -1 if no boundary is found

%
% (c) Jose Carlos Castillo: jccmontoya@gmail.com

    dist = NaN; % by default, no boundary is found
    x = NaN;
    y = NaN;
    
    [h w c] = size(img); % Get image size
    [inc_x inc_y] = getOctantIncrement(vector); % what axis to be incremented
    
    if(inc_x > 0) % Increment in the x axis
        for i=vector(1)+1 : inc_x : w
            pos_y = straightLineFollowAxisX([vector(1) vector(2)] , [vector(3) vector(4)] , i);
            if(pos_y > h || pos_y < 1) 
                return; 
            end
            if (img(pos_y,i) ~= 0) % Border found
                dist = pdist([vector(1), vector(2) ; i , pos_y], 'euclidean');
                x = i;
                y = pos_y;
                return;
            end
        end
        
    elseif(inc_x < 0) % Decrement in the x axis
        for i = vector(1)-1 : inc_x : 1
            pos_y = straightLineFollowAxisX([vector(1) vector(2)] , [vector(3) vector(4)] , i);
            if(pos_y > h || pos_y < 1) 
                return; 
            end
            if (img(pos_y,i) ~= 0) % Border found
                dist = pdist([vector(1), vector(2) ; i , pos_y], 'euclidean');
                x = i;
                y = pos_y;
                return;
            end
        end
    elseif(inc_y > 0) % Increment in the y axis
        for i = vector(2) + 1 : inc_y : h
            pos_x = straightLineFollowAxisY([vector(1) vector(2)] , [vector(3) vector(4)] , i);
            if(pos_x > w || pos_x < 1) 
                return; 
            end
            if(img(i,pos_x) ~=0) % Border found
                dist = pdist([vector(1), vector(2) ; pos_x , i], 'euclidean');
                x = pos_x;
                y = i;
                return;
            end
        end
    elseif(inc_y < 0) % Decrement in the y axis
        for i = vector(2)-1 : inc_y : 1
            pos_x = straightLineFollowAxisY([vector(1) vector(2)] , [vector(3) vector(4)] , i);
            if(pos_x > w || pos_x < 1) 
                return; 
            end
            if(img(i,pos_x) ~=0) % Border found
                dist = pdist([vector(1), vector(2) ; pos_x , i], 'euclidean');
                x = pos_x;
                y = i;
                return;
            end
        end    
    end
end



