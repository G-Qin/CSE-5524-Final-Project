sadFrames = frames;
[height, width, ~, fNum] = size(frames);
template = double(imread('template.png'));
[templateH,templateW,~]=size(template);

for f = 1:fNum
    bigImg = frames(:,:,:,f);
    which=1;
    sad=double(zeros((height-(templateH)*2+1)*(width-(templateW)*2+1),3));
    for h=templateH:height-templateH+1
        for w=templateW:width-templateW+1
            this=double(bigImg(h-((templateH)/2-1):h+((templateH)/2-1),w-((templateW)/2-1):w+((templateW)/2-1),:));
            temp=0;
            for i=1:templateH-1
                for j=1:templateW-1
                    temp=temp+abs(this(i,j,1)-template(i,j,1));
                    temp=temp+abs(this(i,j,2)-template(i,j,2));
                    temp=temp+abs(this(i,j,3)-template(i,j,3));
                end
            end
            sad(which,1)=temp;
            sad(which,2)=h;
            sad(which,3)=w;
            which=which+1;
        end
    end
    sad=sortrows(sad,'ascend');
    h1=sad(1,2);
    w1=sad(1,3);
    sadFrames(:,:,:,f) = insertShape(sadFrames(:,:,:,f), 'rectangle', [w1-(templateW+1)/2-1 h1-(templateH+1)/2-1 templateW templateH], 'LineWidth', 5);
    filename = sprintf('sadFrames/frame%d.png', f);
    blurIm=blur(sadFrames(:,:,:,f),h1,w1,100);
    imwrite(uint8(blurIm), filename);
end


