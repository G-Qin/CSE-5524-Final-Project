nccFrames = frames;
[height, width, ~, fNum] = size(frames);
templateOri = double(imread('template.png'));
templateInc = expand(templateOri);
templateDec = shrink(templateOri);
[templateH,templateW,~]=size(templateOri);
templateHI=templateH*2;
templateWI=templateW*2;
templateHD=floor(templateH/2);
templateWD=floor(templateW/2);

for f = 1:1
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
    end
    
    which = 1;
    ncc=double(zeros((height-templateH+1)*(width-templateW+1)+(height-templateHI+1)*(width-templateWI+1)+(height-templateHD+1)*(width-templateWD+1),3));
    bigImg = frames(:,:,:,f);
    state=1;
    [which,ncc]=nccSort(templateOri,which,ncc,height,width,bigImg,state);
    state=2;
    [which,ncc]=nccSort(templateDec,which,ncc,height,width,bigImg,state);
    state=3;
    [which,ncc]=nccSort(templateInc,which,ncc,height,width,bigImg,state);

    maxNcc=findMax(ncc);
    h1=maxNcc(1,2);
    w1=maxNcc(1,3);
    whichState=maxNcc(1,4);
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
        x0 = w1-(templateWD+1)/2-1;
        y0 = h1-(templateHD+1)/2-1;
        w = templateWD;
        h = templateHD;
    else
        x0 = w1-(templateWI+1)/2-1;
        y0 = h1-(templateHI+1)/2-1;
        w = templateWI;
        h = templateHI;
    end
    nccFrames(:,:,:,f) = insertShape(nccFrames(:,:,:,f), 'rectangle', [x0 y0 w h], 'LineWidth', 5);
    filename = sprintf('nccFrames/frame%d.png', f);
    [blurIm]=blur(nccFrames(:,:,:,f),h1,w1,floor(h/2),floor(w/2));
    imwrite(uint8(blurIm), filename);
    
    disp(maxNcc(1,1));
end

function [count,ncc]=nccSort(template,which,ncc,height,width,bigImg,state)
    [templateH,templateW,~]=size(template);
    % Caculate template sigma and mean
    tSigmaR=std(template(:,:,1),0,'all');
    tSigmaG=std(template(:,:,2),0,'all');
    tSigmaB=std(template(:,:,3),0,'all');
    tMeanR=mean2(template(:,:,1));
    tMeanG=mean2(template(:,:,2));
    tMeanB=mean2(template(:,:,3));

            if mod(templateH,2)==1
                templateH = templateH-1;
            end
            if mod(templateW,2)==1
                templateW = templateW-1;
            end
    
    for h=1:height-templateH+1
        for w=1:width-templateW+1
            top = h;
            bottom = h+templateH-1;
            left = w;
            right = w+templateW-1;
            this(:,:,1) = double(bigImg(top:bottom, left:right, 1));
            this(:,:,2) = double(bigImg(top:bottom, left:right, 2));
            this(:,:,3) = double(bigImg(top:bottom, left:right, 3));
            % Calculate sigma for bigImg
            SigmaR = std(this(:,:,1),0,'all');
            SigmaG = std(this(:,:,2),0,'all');
            SigmaB = std(this(:,:,3),0,'all');
            % Calculate mean for bigImg
            MeanR = mean2(this(:,:,1));
            MeanG = mean2(this(:,:,2));
            MeanB = mean2(this(:,:,3));  
            temp=0;
            for i=1:templateH
                for j=1:templateW
                    temp = temp+(this(i,j,1)-MeanR)*(template(i,j,1)-tMeanR)/(tSigmaR*SigmaR);
                    temp = temp+(this(i,j,2)-MeanG)*(template(i,j,2)-tMeanG)/(tSigmaG*SigmaG);
                    temp = temp+(this(i,j,3)-MeanB)*(template(i,j,3)-tMeanB)/(tSigmaB*SigmaB);
                end
            end
            disp(state);
            ncc(which,1)=temp/(templateH*templateW-1);
            ncc(which,2)=h;
            ncc(which,3)=w;
            ncc(which,4)=state;
            which=which+1;
        end
    end
    count=which;
end


function [maxNcc] = findMax(ncc)
    [r,~] = size(ncc);
    tempMax = -3;
    tempPos = 0;
    for i = 1:r
        if ncc(i,1)>tempMax
            tempMax = ncc(i,1);
            tempPos = i;
        end
    end
    maxNcc = ncc(tempPos,:);
end
