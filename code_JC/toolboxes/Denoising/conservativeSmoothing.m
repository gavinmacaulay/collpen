function I = conservativeSmoothing(I, mask_size)

center = ceil(mask_size/2);

[h w] = size(I);

for i = center: h-center
   for j = center: w-center
       
       mat = I(i-center+1:i+center-1,j-center+1:j+center-1);
       mat(center,center) = NaN;
       if I(i,j) > max(mat(:))           
           I(i,j) = max(mat(:));
       elseif I(i,j) < min(mat(:)) 
           I(i,j) = min(mat(:));
       end
   end
end

end