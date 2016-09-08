
function angle = getAngleTwoVectors(A,B)
    A = single(A);
    B = single(B);
    dotprod = dot(A,B);
    modprod = sqrt(A(1)^2 + A(2)^2) * sqrt(B(1)^2 + B(2)^2);
    cosalpha = dotprod/modprod;
    angle = acosd(cosalpha);
end