function [Gx, Gy] = gaussDeriv2D(sigma)

%set mask size: ceil(3*sigma)*2+1
maskSize = ceil(3*sigma)*2+1;
center = 0;

%creating Masks
Gx = zeros(maskSize, maskSize);
Gy = zeros(maskSize, maskSize);

y = -3;
for r = 1:maskSize
    x = -3;
    %calculate exponent of e in ppt page 24
    for c = 1:maskSize
        diffx = (x - center);
        diffy = (y - center);
        numeratorE=(diffx^2)+(diffy^2);
        expValue = exp(-1 * numeratorE / (2 * sigma^2)); 
        
        %calculation based on ppt page 28
        Gx(r, c) = ((diffx) / (2 * pi * sigma^4)) * expValue;
        Gy(r, c) = ((diffy) / (2 * pi * sigma^4)) * expValue;
        x = x + 1;
    end
    y = y + 1;
end

