% Mean-shift tracking

mstFrames = zeros(size(frames));
% The starting point and size need to be determined manually
x0 = 695;
y0 = 235;
radius = 80;

[row, col, ~, fNum] = size(frames);


for f = 2:fNum
    template = frames(:,:,:,f-1);
    img2 = frames(:,:,:,f);
    
    modelNeighbor = circularNeighbors(template, x0, y0, radius);
    q_model = colorHistogram(modelNeighbor, 16, x0, y0, radius);
    
    mstFrames(:,:,:,f-1) = insertShape(template, 'circle', [x0 y0 radius], 'LineWidth', 5);
    filename = sprintf('MSTFrames/frame%d.png', f-1);
    imwrite(uint8(mstFrames(:,:,:,f-1)), filename);
    for i = 1:15    
        testNeighbor = circularNeighbors(img2, x0, y0, radius);
        p_test = colorHistogram(testNeighbor, 16, x0, y0, radius);
        w = meanshiftWeights(testNeighbor, q_model, p_test, 16);
        
        test_plus = circularNeighbors(img2, x0, y0, radius+1);
        p_test_plus = colorHistogram(test_plus, 16, x0, y0, radius+1);
        w_plus = meanshiftWeights(test_plus, q_model, p_test, 16);
        
        test_minus = circularNeighbors(img2, x0, y0, radius-1);
        p_test_minus = colorHistogram(test_minus, 16, x0, y0, radius-1);
        w_minus = meanshiftWeights(test_minus, q_model, p_test, 16);
        
        if mean(w_minus) > mean(w) && mean(w_minus) > mean(w_plus)
            w = w_minus;
            radius = radius - 1;
            testNeighbor = test_minus;
        elseif mean(w_plus) > mean(w) && mean(w_plus) > mean(w_minus)
            w = w_plus;
            radius = radius + 1;
            testNeighbor = test_plus;
        end

        xResult = 0;
        yResult = 0;
        [num,~] = size(testNeighbor);
        for r = 1:num
            xResult = xResult + testNeighbor(r, 1) * w(r, 1);
            yResult = yResult + testNeighbor(r, 2) * w(r, 1);
        end

        x0 = xResult / sum(w, 'all');
        y0 = yResult / sum(w, 'all');
    end
end





function [X] = circularNeighbors(img, x, y, radius)

    [row, column, ~] = size(img);
    rowNum = 0;
    for r = 1:row
        for c = 1:column
            if sqrt((r-y).^2 + (c-x).^2) < radius
                rowNum = rowNum + 1;
            end
        end
    end
    X = zeros(rowNum, 5);
    rowNum = 1;
    for r = 1:row
        for c = 1:column
            if sqrt((r-y).^2 + (c-x).^2) < radius
                X(rowNum, 1) = c;
                X(rowNum, 2) = r;
                X(rowNum, 3) = img(r, c, 1);
                X(rowNum, 4) = img(r, c, 2);
                X(rowNum, 5) = img(r, c, 3);
                rowNum = rowNum + 1;
           end
        end
    end

end

function [hist] = colorHistogram(X, bins, x, y, h)

    hist = double(zeros(bins, bins, bins));
    [row, ~] = size(X);
    for r = 1:row
        k = 1 - ((sqrt((X(r,1)-x)^2 +(X(r,2)-y)^2)) / h)^2;
        if k < 0
            k = 0.0;
        end
        hist(ceil((X(r,3)+1)/bins), ceil((X(r,4)+1)/bins), ceil((X(r,5)+1)/bins)) = hist(ceil((X(r,3)+1)/bins), ceil((X(r,4)+1)/bins), ceil((X(r,5)+1)/bins)) + k;
    end
    hist = hist / sum(hist, 'all');

end


function [w] = meanshiftWeights(X, q_model, p_test, bins)

    [row, ~] = size(X);
    w = double(zeros(row, 1));
    for r = 1:row
        red = ceil((X(r,3)+1)/bins);
        green = ceil((X(r,4)+1)/bins);
        blue = ceil((X(r,5)+1)/bins);
        if p_test(red, green, blue) ~= 0
            w(r) = sqrt(q_model(red, green, blue)/p_test(red, green, blue));
        end
    end
end