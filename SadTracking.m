sadFrames = frames;
[height, width, ~, fNum] = size(frames);
templateOri = double(imread('template.png'));
templateInc = expand(templateOri);
templateDec = shirnk(templateOri);
[templateH,templateW,~]=size(templateOri);
templateHI=templateH*2;
templateWI=templateW*2;
templateHD=templateH/2;
templateWD=templateW/2;

for f = 1:fNum
    sad=double(zeros((height-(templateH)*2+1)*(width-(templateW)*2+1),3));
    bigImg = frames(:,:,:,f);
    state=1;
    [which,sad]=sadSort(templateOri,which,sad,height,width,bigImg,state);
    state=2;
    [which,sad]=sadSort(templateDec,which,sad,height,width,bigImg,state);
    state=3;
    [which,sad]=sadSort(templateInc,which,sad,height,width,bigImg,state);
    
    sad=sortrows(sad,'ascend');
    h1=sad(1,2);
    w1=sad(1,3);
    sadFrames(:,:,:,f) = insertShape(sadFrames(:,:,:,f), 'rectangle', [w1-(templateW+1)/2-1 h1-(templateH+1)/2-1 templateW templateH], 'LineWidth', 5);
    filename = sprintf('sadFrames/frame%d.png', f);
    [blurIm,template]=blur(sadFrames(:,:,:,f),h1,w1,templateH,templateW);
    imwrite(uint8(blurIm), filename);
   
end
function [count,sad]=sadSort(template,which,sad,height,width,bigImg,state)
    [templateH,templateW,~]=size(template);
    for h=templateH:height-templateH+1
        for w=templateW:width-templateW+1
            if mod(templateH,2)==1
                templateH=templateH-1;
            end
            if mod(templateW,2)==1
                templateW=templateW-1;
            end
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
            sad(which,4)=state;
            which=which+1;
            which=which+1;
        end
    end
    count=which;
end

