function [output]=averageFiltering(image,y,x,radiusy,radiusx)
    blurIm=double(image(y:y+radiusy*2,x:x+radiusx*2,:));
    disp(size(blurIm));
    for j=y:y+radiusy*2
        for i=x:x+radiusx*2
            A=zeros(21,21,1);
            B=zeros(21,21,1);
            C=zeros(21,21,1);
            for m=1:21
                for n=1:21
                    A=image(j-10:j+10,i-10:i+10,1);
                    B=image(j-10:j+10,i-10:i+10,2);
                    C=image(j-10:j+10,i-10:i+10,3);
                end
            end
            red=mean(A,'all');
            green=mean(B,'all');
            blue=mean(C,'all');
            blurIm(j-y+1,i-x+1,1)=red;
            blurIm(j-y+1,i-x+1,2)=green;
            blurIm(j-y+1,i-x+1,3)=blue;
        end
    end
    output=image;
    output(y:y+radiusy*2,x:x+radiusx*2,:)=blurIm;
end