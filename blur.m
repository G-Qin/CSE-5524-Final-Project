function output=blur(image,y,x,radius)
    sigma=10.0; % use different values
    G = fspecial('gaussian', 2*ceil(3*sigma)+1, sigma);
    blurIm=image((y-radius):(y+radius),(x-radius):(x+radius),:);
    blurIm=imfilter(blurIm, G, 'replicate');
    output=image;
    output((y-radius):(y+radius),(x-radius):(x+radius),:)=blurIm;
end