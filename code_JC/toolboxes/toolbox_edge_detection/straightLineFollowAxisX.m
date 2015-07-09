function y = straightLineFollowAxisX(p1, p2 , x)
% This function returns the y corresponding to the x coordenate of the
% point that belongs to the straight line that follows p1 and p2
%
% (c) Jose Carlos Castillo: jccmontoya@gmail.com

y = ((x - p1(1)) / (p2(1) - p1(1)) * (p2(2) - p1(2))) + p1(2);
y = round(y);

end
