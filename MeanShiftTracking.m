% Mean-shift tracking
template = imread('img1.jpg');
img2 = imread('img2.jpg');
% The starting point need to be determined manually
x0 = 150;
y0 = 175;

[row, col, ~] = size(template);
modelNeighbor = circularNeighbors(template, x0, y0, 25);
q_model = colorHistogram(modelNeighbor, 16, x0, y0, 25);

subplot(1,3,1);
imagesc(template);
axis('equal');
hold on;
viscircles([x0, y0], 25);
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