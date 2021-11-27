nccFrames = frames;
[height, width, ~, fNum] = size(frames);
templateOri = double(imread('template.png'));
templateInc = expand(templateOri);
templateDec = shirnk(templateOri);
[templateH,templateW,~]=size(templateOri);
templateHI=templateH*2;
templateWI=templateW*2;
templateHD=templateH/2;
templateWD=templateW/2;

for f = 55:fNum
    ncc=double(zeros((height-(templateH)*2+1)*(width-(templateW)*2+1)+(height-(templateHI)*2+1)*(width-(templateWI)*2+1)+(height-(templateHD)*2+1)*(width-(templateWD)*2+1),3));
    bigImg = frames(:,:,:,f);
    state=1;
    [which,ncc]=nccSort(templateOri,which,ncc,height,width,bigImg,state);
    state=2;
    [which,ncc]=nccSort(templateDec,which,ncc,height,width,bigImg,state);
    state=3;
    [which,ncc]=nccSort(templateInc,which,ncc,height,width,bigImg,state);
    ncc=sortrows(ncc,'descend');
    h1=ncc(1,2);
    w1=ncc(1,3);
    whichState=ncc(1,4);
    if whichState==1
        nccFrames(:,:,:,f) = insertShape(nccFrames(:,:,:,f), 'rectangle', [w1-(templateW+1)/2-1 h1-(templateH+1)/2-1 templateW templateH], 'LineWidth', 5);
        filename = sprintf('nccFrames/frame%d.png', f);
        [blurIm,template]=blur(nccFrames(:,:,:,f),h1,w1,templateH,templateW);
        imwrite(uint8(blurIm), filename);
    elseif whichState==2
        nccFrames(:,:,:,f) = insertShape(nccFrames(:,:,:,f), 'rectangle', [w1-(templateWD+1)/2-1 h1-(templateHD+1)/2-1 templateWD templateHD], 'LineWidth', 5);
        filename = sprintf('nccFrames/frame%d.png', f);
        [blurIm,template]=blur(nccFrames(:,:,:,f),h1,w1,templateHD,templateWD);
        imwrite(uint8(blurIm), filename);
    else
        nccFrames(:,:,:,f) = insertShape(nccFrames(:,:,:,f), 'rectangle', [w1-(templateWI+1)/2-1 h1-(templateHI+1)/2-1 templateWI templateHI], 'LineWidth', 5);
        filename = sprintf('nccFrames/frame%d.png', f);
        [blurIm,template]=blur(nccFrames(:,:,:,f),h1,w1,templateHI,templateWI);
        imwrite(uint8(blurIm), filename);
    end
    
    disp(whichState);
end

function [count,ncc]=nccSort(template,which,ncc,height,width,bigImg,state)
    [templateH,templateW,~]=size(template);
    %template sigma and mean
    tSigmaR=std(template(:,:,1),0,'all');
    tSigmaG=std(template(:,:,2),0,'all');
    tSigmaB=std(template(:,:,3),0,'all');
    tMeanR=mean2(template(:,:,1));
    tMeanG=mean2(template(:,:,2));
    tMeanB=mean2(template(:,:,3));
    %277-24+1,366-35+1
    for h=templateH:height-templateH+1
        for w=templateW:width-templateW+1
            if mod(templateH,2)==1
                templateH=templateH-1;
            end
            if mod(templateW,2)==1
                templateW=templateW-1;
            end
            this(:,:,1)=double(bigImg(h-((templateH)/2-1):h+((templateH)/2-1),w-((templateW)/2-1):w+((templateW)/2-1),1));
            this(:,:,2)=double(bigImg(h-((templateH)/2-1):h+((templateH)/2-1),w-((templateW)/2-1):w+((templateW)/2-1),2));
            this(:,:,3)=double(bigImg(h-((templateH)/2-1):h+((templateH)/2-1),w-((templateW)/2-1):w+((templateW)/2-1),3));
            %calculate sigma for bigImg
            SigmaR=std(this(:,:,1),0,'all');
            SigmaG=std(this(:,:,2),0,'all');
            SigmaB=std(this(:,:,3),0,'all');
            %calculate mean for bigImg
            MeanR=mean2(this(:,:,1));
            MeanG=mean2(this(:,:,2));
            MeanB=mean2(this(:,:,3));  
            temp=0;
            for i=1:templateH-1
                for j=1:templateW-1
                    temp=temp+(this(i,j,1)-MeanR)*(template(i,j,1)-tMeanR)/(tSigmaR*SigmaR);
                    temp=temp+(this(i,j,2)-MeanG)*(template(i,j,2)-tMeanG)/(tSigmaG*SigmaG);
                    temp=temp+(this(i,j,3)-MeanB)*(template(i,j,3)-tMeanB)/(tSigmaB*SigmaB);
                end
            end
            %47*69-1 (n-1)
            ncc(which,1)=temp/(templateH*templateW-1);
            ncc(which,2)=h;
            ncc(which,3)=w;
            ncc(which,4)=state;
            which=which+1;
        end
    end
    count=which;
end