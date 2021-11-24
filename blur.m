function [output,template]=blur(image,y,x,radiusy,radiusx)
    sigma=10.0; % use different values
    G = fspecial('gaussian', 2*ceil(3*sigma)+1, sigma);
    template=double(image((y-radiusy/2):(y+radiusy/2),(x-radiusx/2):(x+radiusx/2),:));
    blurIm=imfilter(template, G, 'replicate');
    output=image;
    output((y-radiusy/2):(y+radiusy/2),(x-radiusx/2):(x+radiusx/2),:)=blurIm;
end