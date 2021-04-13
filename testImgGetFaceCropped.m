% only upright test images in directory
testFolder='pictures\'; %%%%% your test directory


I=imread(strcat(testFolder,("1-3.jpg")));

Image = getFaceCropped(I);
hold on
figure, imshow(Image)
title("ended")
    
    
