function x = straightLineFollowAxisY(p1, p2 , y)
% This function returns the x corresponding to the y coordenate of the
% point that belongs to the straight line that follows p1 and p2
%
% (c) Jose Carlos Castillo: jccmontoya@gmail.com

x = ((y - p1(2))/ (p2(2) - p1(2)) * (p2(1) - p1(1))) + p1(1);
x = round(x);
end