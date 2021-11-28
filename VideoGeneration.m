% Video name, source file, frame rate and frame size needs to be determined manually
video = VideoWriter('Video/Median-MST-Video');
video.FrameRate = 24;
f = zeros(480,850,3,261);
[~,~,~,fNum] = size(f);

for i = 1:fNum
    filename = sprintf('MSTFrames/frame%d.png', i); 
    f(:,:,:,i) = imread(filename);
end
open(video);
for i = 1:fNum
    writeVideo(video,uint8(f(:,:,:,i)));
end
close(video);