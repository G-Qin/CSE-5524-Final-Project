ssdFrames = frames;
[height, width, ~, fNum] = size(frames);
template = double(imread('template.png'));
[templateH,templateW,~]=size(template);

for f = 1:fNum
    bigImg = frames(:,:,:,f);
    which=1;
    ssd=double(zeros((height-(templateH)*2+1)*(width-(templateW)*2+1),3));
    for h=templateH:height-templateH+1
        for w=templateW:width-templateW+1
            this=double(bigImg(h-((templateH)/2-1):h+((templateH)/2-1),w-((templateW)/2-1):w+((templateW)/2-1),:));
            temp=0;
            for i=1:templateH-1
                for j=1:templateW-1
                    temp=temp+(this(i,j,1)-template(i,j,1))^2;
                    temp=temp+(this(i,j,2)-template(i,j,2))^2;
                    temp=temp+(this(i,j,3)-template(i,j,3))^2;
                end
            end
            ssd(which,1)=temp;
            ssd(which,2)=h;
            ssd(which,3)=w;
            which=which+1;
        end
    end
    ssd=sortrows(ssd,'ascend');
    h1=ssd(1,2);
    w1=ssd(1,3);
    ssdFrames(:,:,:,f) = insertShape(ssdFrames(:,:,:,f), 'rectangle', [w1-(templateW+1)/2-1 h1-(templateH+1)/2-1 templateW templateH], 'LineWidth', 5);
    filename = sprintf('SSDFrames/frame%d.png', f);
    imwrite(uint8(ssdFrames(:,:,:,f)), filename);
end


