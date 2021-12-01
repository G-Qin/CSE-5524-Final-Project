% Compute covariance matrix of the template
template = imread('template.png');
[tRow, tCol, ~] = size(template);
% Start coordinates need to be determined manually
startCoord = [113, 221];

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
covFrames = zeros(size(frames));

% Compute the covariance matrices of windows in each frame
% Consider the movement of the template should be linear, reduce the range
% of detection to speed up calculations
[fRow, fCol, ~, fNum] = size(frames);
rRange = ceil(fRow * 0.05);
cRange = ceil(fCol * 0.025);

for f = 1:fNum
    sR = startCoord(1,1);
    sC = startCoord(1,2);
    if f > 1
        % Save previous tracking image
        disp(f);
        covFrames(:,:,:,f-1) = insertShape(frames(:,:,:,f-1), 'rectangle', [sC sR tCol tRow], 'LineWidth', 5);
        filename = sprintf('CovFrames/frame%d.png', f-1);
        imwrite(uint8(covFrames(:,:,:,f-1)), filename);
        
        % Update the template
        template = frames(sR:sR+tRow, sC:sC+tCol,:,f-1);
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
    end
 
    
    % Determine the window for detection
    up = max(sR-rRange, 1);
    down = min(sR+rRange, fRow-tRow);
    left = max(sC-cRange, 1);
    right = min(sC+cRange, fCol-tCol);
    minCoord = [up left];
    minRo = 0;
    minH = 1;
    firstFlag = true;
    for fr = up:down
        for fc = left:right
            % Adjut bandwidth
            for h = -3:3
                % Convert image to N*5 matrix
                % Use min for edge limitation
                tempRow = min(ceil(tRow * (1 + h*0.01)), fRow-fr);
                tempCol = min(ceil(tCol * (1 + h*0.01)), fCol-fc);
                candidate = zeros(tempRow * tempCol, 5);
                rowCount = 0;
                
                for cr = 1:tempRow
                    for cc = 1:tempCol
                        currR = fr + cr - 1;
                        currC = fc + cc - 1;
                        rowCount = rowCount + 1;
                        candidate(rowCount, 1) = currC;
                        candidate(rowCount, 2) = currR;
                        candidate(rowCount, 3) = frames(currR,currC,1,f);
                        candidate(rowCount, 4) = frames(currR,currC,2,f);
                        candidate(rowCount, 5) = frames(currR,currC,3,f);
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
                if firstFlag == true
                    minRo = ro;  
                    firstFlag = false;
                elseif ro < minRo
                    minRo = ro;
                    startCoord = [fr fc];
                    minH = h;
                end 
            end
        end
    end
    tRow = ceil(tRow * (1 + minH*0.01));
    tCol = ceil(tCol * (1 + minH*0.01));
end


                    
                    