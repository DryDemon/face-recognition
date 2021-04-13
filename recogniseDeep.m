function [c] = recogniseDeep(I,trainedNetwork)
    % Recognise the student in image I from the 2021 Spring Y3 ING class
    % input : I (upright RGB image)
    % output : c (integer student id)
    

    % example
    I=imresize(I,[200 200]); %%%%% update to your network input size
    [YPred] = classify(trainedNetwork,I)
    c=str2double(string(YPred))
    
    end
    