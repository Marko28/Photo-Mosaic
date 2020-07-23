clear; close all;
load images.mat
%{
masterX = imread('master2.png');
masterX = imresize(masterX, [3508, NaN]);
master = uint8(zeros(3508, 4960, 3));
master(:, (4960-3508)/2+1:(4960+3508)/2,:) = masterX;
clear masterX

mosaicI = uint8(zeros(size(master)));
mosaicI = randomiseMosaic(images, mosaicI);
%}
load v11.mat

n_images = length(images);
[nrows, ncols, ~] = size(master);

iter = 1;
figure(1); figure(2);
costG = [iter; 0];
id_counter = 0;
c = 1;

while 1
    if id_counter == 0 || id_counter > 10000
        id = randi(n_images);
    end
    id_counter = id_counter + 1;
    row = randi(nrows);
    col = randi(ncols);
    
    image = images{id};
    
    if randi(2)-1
        image = flip(image);
    end
    image = rot90(image, randi(4));
    
    [im_rows, im_cols, ~] = size(image);
    
    up_pix = round(im_rows / 2);
    down_pix = im_rows - up_pix;
    left_pix = round(im_cols / 2);
    right_pix = im_cols - left_pix;
    up_coord = row - up_pix;
    down_coord = row + down_pix;
    left_coord = col  - left_pix;
    right_coord = col + right_pix;
    if up_coord < 1
        diff = 1 - up_coord;
        up_coord = 1;
        image = image(1+diff:end, :, :);
    elseif down_coord > nrows
        diff = down_coord - nrows;
        down_coord = nrows;
        image = image(1:end-diff, :, :);
    end
    if left_coord < 1
        diff = 1 - left_coord;
        left_coord = 1;
        image = image(:, 1+diff:end, :);
    elseif right_coord > ncols
        diff = right_coord - ncols;
        right_coord = ncols;
        image = image(:, 1:end-diff, :);
    end
    
    [cost, cost_diff] = compareCost(image, master(up_coord:down_coord-1, left_coord:right_coord-1, :), ...
            mosaicI(up_coord:down_coord-1, left_coord:right_coord-1, :));
    if cost_diff < 0
        mosaicI(up_coord:down_coord-1, left_coord:right_coord-1, :) = image;
        %{
        %figure(1); imagesc(mosaicI); axis image; drawnow;
        figure(2);
        plot([costG(1), iter], [costG(2), costG(2)+cost_diff], 'k-x'); 
        title(sprintf('%d', iter)); hold on; drawnow;
        if iter > c * 10000
            hold off
            costG = [iter; -cost_diff];
            c = c + 1;
        end
        costG = [iter; costG(2)+cost_diff];
        %}
        id_counter = 0;
        fprintf('YES');
    end
    fprintf('\titer: %d-%d,\timage: %d,\t cost_diff: %f\n',iter, id_counter, id, cost_diff);
    iter = iter + 1;
end

function [mosaicCost, diff] = compareCost(image, master, mosaicI)
imCost = 0;
mosaicCost = 0;
[nrows, ncols, ~] = size(image);
for i = 1:nrows
    for j = 1:ncols
        imCost = imCost + getCost(image(i,j,:), master(i,j,:));
        mosaicCost = mosaicCost + getCost(image(i,j,:), mosaicI(i,j,:));
    end
end
diff = imCost - mosaicCost; diff = diff / (nrows*ncols);
end

function cost = getCost(i, j)
i = double(i); j = double(j);
rbar = (i(1) + j(1))/2;
delta = i - j;
cost = sqrt( (2+rbar/256)*(delta(1))^2+4*(delta(2))^2+(2+(255-rbar)/256)*delta(3)^2 );
end

function mosaicI = randomiseMosaic(images, mosaicI)
n_images = length(images);
[nrows, ncols, ~] = size(mosaicI);
for i = 1:10000
    id = randi(n_images);
    row = randi(nrows);
    col = randi(ncols);
    
    image = images{id};
    
    if randi(2)-1
        image = flip(image);
    end
    image = rot90(image, randi(4));
    
    [im_rows, im_cols, ~] = size(image);
    
    up_pix = round(im_rows / 2);
    down_pix = im_rows - up_pix;
    left_pix = round(im_cols / 2);
    right_pix = im_cols - left_pix;
    up_coord = row - up_pix;
    down_coord = row + down_pix;
    left_coord = col  - left_pix;
    right_coord = col + right_pix;
    if up_coord < 1
        diff = 1 - up_coord;
        up_coord = 1;
        image = image(1+diff:end, :, :);
    elseif down_coord > nrows
        diff = down_coord - nrows;
        down_coord = nrows;
        image = image(1:end-diff, :, :);
    end
    if left_coord < 1
        diff = 1 - left_coord;
        left_coord = 1;
        image = image(:, 1+diff:end, :);
    elseif right_coord > ncols
        diff = right_coord - ncols;
        right_coord = ncols;
        image = image(:, 1:end-diff, :);
    end
    mosaicI(up_coord:down_coord-1, left_coord:right_coord-1, :) = image;
end
end