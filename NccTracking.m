nccFrames = frames;
[height, width, ~, fNum] = size(frames);
template = double(imread('template.png'));
[templateH,templateW,~]=size(template);

for f = 1:fNum
    bigImg = frames(:,:,:,f);
    %template sigma and mean
    tSigmaR=std(template(:,:,1),0,'all');
    tSigmaG=std(template(:,:,2),0,'all');
    tSigmaB=std(template(:,:,3),0,'all');
    tMeanR=mean2(template(:,:,1));
    tMeanG=mean2(template(:,:,2));
    tMeanB=mean2(template(:,:,3));
    which=1;
    %277-24+1,366-35+1
    ncc=double(zeros((height-(templateH)*2+1)*(width-(templateW)*2+1),3));
    for h=templateH:height-templateH+1
        for w=templateW:width-templateW+1
            this=double(bigImg(h-((templateH)/2-1):h+((templateH)/2-1),w-((templateW)/2-1):w+((templateW)/2-1),:));
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
            which=which+1;
        end
    end
    ncc=sortrows(ncc,'descend');
    h1=ncc(1,2);
    w1=ncc(1,3);
    nccFrames(:,:,:,f) = insertShape(nccFrames(:,:,:,f), 'rectangle', [w1-(templateW+1)/2-1 h1-(templateH+1)/2-1 templateW templateH], 'LineWidth', 5);
    filename = sprintf('nccFrames/frame%d.png', f);
    imwrite(uint8(nccFrames(:,:,:,f)), filename);
end


