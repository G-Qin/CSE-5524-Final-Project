function [output]=blur(image,y,x,radiusy,radiusx)
disp(radiusy);
disp(radiusx);
disp(y);
disp(x);
    sigma=10.0; % use different values
    G = fspecial('gaussian', 2*ceil(3*sigma)+1, sigma);
    [row, col] = size(image);
    top = max(floor(y),1);
    bot = min(floor(y+radiusy*2),row);
    left = max(floor(x),1);
    right = min(floor(x+radiusx*2),col);
    template=double(image(top:bot, left:right, :));
    blurIm=imfilter(template, G, 'replicate');
    output=image;
    output(top:bot, left:right, :)=blurIm;
end