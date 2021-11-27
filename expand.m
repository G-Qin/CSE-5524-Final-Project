function result = expand(I)

% Get the size of initial image and calculate the dimensions of
% interpolated image
[rowNum, columnNum,~] = size(I);
itpRowNum = rowNum * 2 - 1;
itpColumnNum = columnNum * 2 - 1;
result = double(zeros(itpRowNum, itpColumnNum,3));

for r = 1:itpRowNum    
    if mod(int32(r), 2) == 1
        for c = 1:itpColumnNum
            rInt = int32(r);
            cInt = int32(c);
            if mod(cInt, 2) == 1
                result(rInt, cInt,1) = I(rInt/2, cInt/2,1);
                result(rInt, cInt,2) = I(rInt/2, cInt/2,2);
                result(rInt, cInt,3) = I(rInt/2, cInt/2,3);
            else
                result(rInt, cInt,1) = (I(rInt/2, cInt/2 + 1,1) + I(rInt/2, cInt/2,1))./2;
                result(rInt, cInt,2) = (I(rInt/2, cInt/2 + 1,2) + I(rInt/2, cInt/2,2))./2;
                result(rInt, cInt,3) = (I(rInt/2, cInt/2 + 1,3) + I(rInt/2, cInt/2,3))./2;
            end
        end
    end
end

for r = 1:itpRowNum
    if mod(int32(r), 2) == 0
        for c = 1:itpColumnNum
            rInt = int32(r);
            cInt = int32(c);
            result(rInt, cInt,1) = (result(rInt - 1, cInt,1) + result(rInt + 1, cInt,1))./2;
            result(rInt, cInt,2) = (result(rInt - 1, cInt,2) + result(rInt + 1, cInt,2))./2;
            result(rInt, cInt,3) = (result(rInt - 1, cInt,3) + result(rInt + 1, cInt,3))./2;
        end
    end
end