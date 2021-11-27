function [output,template]=blur(image,y,x,radiusy,radiusx)
    sigma=10.0; % use different values
    G = fspecial('gaussian', 2*ceil(3*sigma)+1, sigma);
    template=double(image(floor(y-1-radiusy/2):floor(y-1+radiusy/2),floor(x-1-radiusx/2):floor(x-1+radiusx/2),:));
    blurIm=imfilter(template, G, 'replicate');
    output=image;
    output(floor(y-radiusy/2):floor(y+radiusy/2),floor(x-radiusx/2):floor(x+radiusx/2),:)=blurIm;
end