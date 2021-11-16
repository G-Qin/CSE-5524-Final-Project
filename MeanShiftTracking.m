% Mean-shift tracking
template = frames(:,:,:,1);
img2 = frames(:,:,:,2);
% The starting point and size need to be determined manually
x0 = 385;
y0 = 105;
radius = 75;

[row, col, ~] = size(template);
modelNeighbor = circularNeighbors(template, x0, y0, radius);
q_model = colorHistogram(modelNeighbor, 16, x0, y0, radius);

subplot(1,2,1);
imagesc(template);
axis('equal');
hold on;
viscircles([x0, y0], radius);
hold off;

for i = 1:15    
    testNeighbor = circularNeighbors(img2, x0, y0, radius);
    p_test = colorHistogram(testNeighbor, 16, x0, y0, radius);
    w = meanshiftWeights(testNeighbor, q_model, p_test, 16);
    
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
lastXY = [x0 y0];
disp(lastXY);

subplot(1,2,2);
imagesc(img2);
axis('equal');
hold on;
viscircles(lastXY, radius);
hold off;





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