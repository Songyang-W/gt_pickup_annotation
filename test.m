imPath = 'C:\Users\Xiu\Dropbox (Personal)\EM_ppc';
imList = dir(fullfile(imPath, '*png'));

M_im = cell(1,length(imList));
for i = 1:length(imList)
    M_im{i} = imread(fullfile(imPath,imList(i).name));
end

RGB = M_im{1};
figure;imagesc(RGB);

%%
% I = rgb2gray(RGB);
% bw = imbinarize(I);
% imshow(bw)
% 
% %%
% % remove all object containing fewer than 30 pixels
% bw = bwareaopen(bw,30);
% 
% % fill a gap in the pen's cap
% se = strel('disk',2);
% bw = imclose(bw,se);
% 
% % fill any holes, so that regionprops can be used to estimate
% % the area enclosed by each of the boundaries
% bw = imfill(bw,'holes');
% 
% imshow(bw)

%%
% % makeMask(location,orientation,scale)
% location = [0,0];
% orientation = 0;
% scale = 1;
% 
% bg_width = 1280;
% bg_height = 1024;
% bg = zeros(bg_height,bg_width);
% a = round(200*scale);
% b = round(150*scale);
% rad = 50*scale;
% 
% % B = imrotate(A,angle)
% % coord of origin
% x0 = bg_width/2 + location(1);
% y0 = bg_height/2 + location(2);

%%
h = impoly;
mask = createMask(h);
figure;imagesc(mask)

save('mask.mat','mask');

%%
pos_poly_slot = pos;

%%
pos_poly_sample = getPosition(h);
save('initMasks.mat','pos_slot_init','pos_sample_init');

%% get mask
img = rgb2gray(RGB);
nimg = img-mean(mean(img));

x = 550;
X = 960;
szx = x:X;

y = 370;
Y = 690;
szy = y:Y;

% mask2 = -mask+1;
Sect = mask(szy,szx);

nSec = mask(szy,szx)-mean(mean(mask));
imagesc(nSec); axis equal
%% get image
img0 = rgb2gray(RGB);
x = 400;
X = 1000;
szx = x:X;

y = 300;
Y = 800;
szy = y:Y;
img = img0(szy,szx);

nimg = img-mean(mean(img));
imagesc(nimg); axis equal
%%
tic
crr = xcorr2(double(nimg),double(nSec));
toc
[ssr,snd] = min(crr(:));
[ij,ji] = ind2sub(size(crr),snd);

figure
plot(crr(:))
title('Cross-Correlation')
hold on
plot(snd,ssr,'or')
hold off
text(snd*1.05,ssr,'Maximum')

%%
figure
img(ij:-1:ij-size(Sect,1)+1,ji:-1:ji-size(Sect,2)+1) = rot90(Sect,2);
% figure
imagesc(img)
axis image off
colormap gray
title('Reconstructed')
hold on
plot([y y Y Y y],[x X X x x],'r')
hold off


%%
% bw = bg;
% figure;
% image(bg)
% axis equal; axis ij;
% 
% r = rectangle('Position',[x0-a/2,y0-b/2,a,b],'Curvature',2/3)
% axis off;
% 
% f=getframe(gca)
% [X, map] = frame2im(f);
% 
% cdata = print('-RGBImage','-r0');
% print('test','-dpng','-r0')
% im2 = imread('test.png');
% figure;image(im2)
% 
% imwrite(X,'test.jpg','jpeg')
% 
% % hold on;
% line([x0,x0],[0,bg_height])
% r = rectangle('Position',[0,0,a,b],'Curvature',2/3)
