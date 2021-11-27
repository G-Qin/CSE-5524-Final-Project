function [output]=blur(image,y,x,radiusy,radiusx)
disp(radiusy);
disp(radiusx);
disp(y);
disp(x);
    sigma=10.0; % use different values
    G = fspecial('gaussian', 2*ceil(3*sigma)+1, sigma);
    template=double(image(y:y+radiusy*2,x:x+radiusx*2,:));
    s = size(template);
    blurIm=imfilter(template, G, 'replicate');
    output=image;
    output(y:y+radiusy*2,x:x+radiusx*2,:)=blurIm;
end