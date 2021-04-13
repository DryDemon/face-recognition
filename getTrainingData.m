% only upright test images in directory
testFolder='pictures\'; %%%%% your test directory
files=dir(testFolder);

%get images
clear filenames
for i=3:size(files,1)
    filenames{i-2,1}=files(i).name;
end

clear trainingInput
clear trainingOutput
trainingInput = [];
trainingOutput = [];

%generate train data
for i=1:size(filenames,1)
    disp(i + "/" + size(filenames,1));    
    I=imread(strcat(testFolder,(filenames{i})));

    if (Height > Width)
    
        I = getTrainingImage(I);

    
        Height = size(I, 1);
        Width = size(I, 2);
    
    
        correctId=strsplit(filenames{i},'-');
        correctId=str2double(correctId{1});
        trainingInput = cat(4, trainingInput, I);
size(trainingInput)
size(trainingOutput)

        trainingOutput=[trainingOutput, correctId];

    end
end
save('training','trainingInput','trainingOutput')

%This function is going to make the image lighter from the basic image
function [Image] = getTrainingImage(Image)
    % input : I (upright raw RGB image)
    % output : Image made for the training dataset
    %get

    Image = getFaceCropped(Image);
    Image = imresize(Image, [200 200]);
    

end



    
