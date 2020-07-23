clear;
files = dir('*.png');
files = [files; dir('*.jpg')];

for id = 1:length(files)
    filename = files(id).name;
    images{id} = imread(filename);
    
    scalefactor = 250 / max(size(images{id}));
    if scalefactor < 1
        images{id} = imresize(images{id}, scalefactor);
    end
        
    fprintf('%d\n', id);
end

clear filename files id scalefactor
cd Master
save images.mat
cd ..