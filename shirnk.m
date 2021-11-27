function result = shrink(I)
%get column and row
[h,w,~]= size(I);

%make the smaller column and row
hSmall = ceil(h /2);
wSmall = ceil(w /2);
result=double(zeros(hSmall, wSmall,3));
for i=1:hSmall
    for j=1:wSmall
        result(i,j,1)=I(i*2,j*2,1);
        result(i,j,2)=I(i*2,j*2,2);
        result(i,j,3)=I(i*2,j*2,3);
    end
end
