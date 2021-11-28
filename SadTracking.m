sadFrames = frames;
[height, width, ~, fNum] = size(frames);
templateOri = double(imread('template.png'));
templateInc = expand(templateOri);
templateDec = shrink(templateOri);
[templateH,templateW,~]=size(templateOri);
templateHI=templateH*2;
templateWI=templateW*2;
templateHD=floor(templateH/2);
templateWD=floor(templateW/2);
% Template position needs to be determined manually at the first frame
tempPos = [135, 605];

for f = 1:fNum
    % Update template after each cycle
    if f > 1
        templateOri = double(frames(y0:y0+h-1, x0:x0+w-1, :, f-1));
        templateInc = expand(templateOri);
        templateDec = shrink(templateOri);
        [templateH,templateW,~]=size(templateOri);
        templateHI=templateH*2;
        templateWI=templateW*2;
        templateHD=floor(templateH/2);
        templateWD=floor(templateW/2);
        tempPos = [y0,x0];
    end
    which=1;
    sad=double(zeros((height-templateH+1)*(width-templateW+1)+(height-templateHI+1)*(width-templateWI+1)+(height-templateHD+1)*(width-templateWD+1),3));
    bigImg = frames(:,:,:,f);
    state=1;
    [which,sad]=sadSort(templateOri,which,sad,height,width,bigImg,state,tempPos);
    state=2;
    [which,sad]=sadSort(templateDec,which,sad,height,width,bigImg,state,tempPos);
    state=3;
    [which,sad]=sadSort(templateInc,which,sad,height,width,bigImg,state,tempPos);
    
    sad=sortrows(sad,'ascend');
    %find the first match sad
    for p=1:(height-templateH+1)*(width-templateW+1)+(height-templateHI+1)*(width-templateWI+1)+(height-templateHD+1)*(width-templateWD+1)
        if sad(p,4)~=0
            h1=sad(p,2);
            w1=sad(p,3);
            whichState=sad(p,4);
            break
        end
    end
    % Determine template for next frame
    x0 = 0;
    y0 = 0;
    w = 0;
    h = 0;
    if whichState==1
        x0 = w1;
        y0 = h1;
        w = templateW;
        h = templateH;
    elseif whichState==2
        x0 = w1;
        y0 = h1;
        w = templateWD;
        h = templateHD;
    else
        x0 = w1;
        y0 = h1;
        w = templateWI;
        h = templateHI;
    end
    sadFrames(:,:,:,f) = insertShape(sadFrames(:,:,:,f), 'rectangle', [x0 y0 w h], 'LineWidth', 5);
    filename = sprintf('sadFrames/frame%d.png', f);
    [blurIm]=blur(sadFrames(:,:,:,f),h1,w1,floor(h/2),floor(w/2));
    imwrite(uint8(blurIm), filename);
   
end
function [count,sad]=sadSort(template,which,sad,height,width,bigImg,state,tempPos)
    [templateH,templateW,~]=size(template);
    rmin = max(1,tempPos(1,1)-50);
    rmax = min(height-templateH+1, tempPos(1,1)+50);
    cmin = max(1,tempPos(1,2)-50);
    cmax = min(width-templateW+1, tempPos(1,2)+50);
    for h=rmin:rmax
        for w=cmin:cmax
            top = h;
            bottom = h+templateH-1;
            left = w;
            right = w+templateW-1;
            this(:,:,1) = double(bigImg(top:bottom, left:right, 1));
            this(:,:,2) = double(bigImg(top:bottom, left:right, 2));
            this(:,:,3) = double(bigImg(top:bottom, left:right, 3));
            temp=0;
            for i=1:templateH
                for j=1:templateW
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
        end
    end
    count=which;
end
