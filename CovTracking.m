% Compute covariance matrix of the template
template = imread('template.png');
[tRow, tCol, ~] = size(template);

tempMatrix = zeros(tRow * tCol, 5);
rowCount = 0;
for r = 1:tRow
    for c = 1:tCol
        rowCount = rowCount + 1;
        tempMatrix(rowCount, 1) = c;
        tempMatrix(rowCount, 2) = r;
        tempMatrix(rowCount, 3) = template(r,c,1);
        tempMatrix(rowCount, 4) = template(r,c,2);
        tempMatrix(rowCount, 5) = template(r,c,3);
    end
end 

covTemp = cov(tempMatrix, 1);

% Compute the covariance matrices of windows in each frame
[fRow, fCol, ~, fNum] = size(frames);
minCoord = [1 1];
minRo = 0;
%for f = 1:fNum    
    for fr = 1:fRow - tRow
        for fc = 1:fCol - tCol
            % Convert image to N*5 matrix
            candidate = zeros(tRow * tCol, 5);
            rowCount = 0;
            for cr = 1:tRow
                for cc = 1:tCol
                    currR = fr + cr - 1;
                    currC = fc + cc - 1;
                    rowCount = rowCount + 1;
                    candidate(rowCount, 1) = currC;
                    candidate(rowCount, 2) = currR;
                    candidate(rowCount, 3) = frames(currR,currC,1,2);
                    candidate(rowCount, 4) = frames(currR,currC,2,2);
                    candidate(rowCount, 5) = frames(currR,currC,3,2);
                end
            end
            % Calculate ro of current candidate and keep track of the
            % minimum row
            covCand = cov(candidate, 1);
            [~, eigVal] = eig(covTemp, covCand);
            [eigRow, eigCol] = size(eigVal);
            ro = 0;

            for eR = 1:eigRow
                for eC = 1:eigCol
                    if eigVal(eR, eC) ~= 0
                        ro = ro + log(eigVal(eR, eC)) ^ 2;
                    end
                end
            end
            ro = sqrt(ro);
            if fr == 1 && fc == 1
                minRo = ro;
            elseif ro < minRo
                minRo = ro;
                minCoord = [fr fc];
            end 
        end
    end

imagesc(frames(:,:,:,2));
figure;
sRow = minCoord(1, 1);
sCol = minCoord(1, 2);
imagesc(frames(sRow:sRow+tRow, sCol:sCol+tCol,:,2));
                    
                    