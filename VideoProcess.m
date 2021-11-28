% Read video from folder
vid = VideoReader('Video/final.mp4');
global frames;
frames = read(vid, [1, Inf]);
%imwrite(frames(:,:,:,1), 'template.png');