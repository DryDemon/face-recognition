%for number = 1:200
    CropSensitivty = 0.66;%variable found from statistic, allow to crop the image on the head
    folder = "pictures/";
    %g through every 
    %filename = folder + number + "-1.jpg";
    %isfile(filename)
    %if isfile(filename) == 1
        %file is here
    %else
     %   filename = folder + number + "-1.jpeg";
    %end

    %if isfile(filename) == 1
        %file is here
    %else
    %filename = folder + "1-1.jpg";
    %end 
   
    filename = folder + "1-2.jpg";
    
    %save the image as a double variable
    Krgb=double(imread(filename));
    
    %get every physic information from the image (size, colors)
    Height=size(Krgb,1);
    Width=size(Krgb,2);
    
    if(Width>Height)
     Krgb=imrotate(Krgb,-90); 
     Height=size(Krgb,1);
    Width=size(Krgb,2);
    end
    
    %extracting the Red, Green, blue colors of the image into matrices
    Red=Krgb(:,:,1);
    Green=Krgb(:,:,2);
    Blue=Krgb(:,:,3);
    
    %YCbCr colors space
    Kycbcr=rgb2ycbcr(Krgb);
    Y=Kycbcr(:,:,1);%extracting luminance
    ImageY = Y/255;%divide by the rgb colors number (255max)
    
    %normalizing Y
    minimumY=min(min(Y));
    maximumY=max(max(Y));
    Y=255.0*(Y-minimumY)./(maximumY-minimumY);%remember 255
    %average of the luminance
    Yaverage=sum(sum(Y))/(Width*Height);
    
    T=0;
    if(Yaverage<64)
        T=1.4;
    elseif(Yaverage>192)
        T=0.6;
    end
    %adjusting the colors
    if(T~=1)
        RI=Red.^T;
        GI=Green.^T;
    else
        RI=Red;
        GI=Green;
    end
    
    C=zeros(Height,Width,3);%new matrix of colors
    C(:,:,1)=RI;
    C(:,:,2)=GI;
    C(:,:,1)=Blue;
    
    %extracting the potential skin
    Kycbcr = rgb2ycbcr(C);
    Cr = Kycbcr(:,:,3);%Cr : the red materix - Luminance. Cr is a chrominance
   
    Skin = zeros(Height,Width);
    [SkinIndexRow,SkinIndexCol] =find(10<Cr & Cr<45);
    for i=1:length(SkinIndexRow)
        Skin(SkinIndexRow(i),SkinIndexCol(i))=1;
    end
    
    
    [centers,radii] = imfindcircles(Skin,[10 30],'ObjectPolarity','bright','Sensitivity',0.94)
    headY = getYFirstWhiteFromTop(Skin);
    figure,imshow(Skin)
    title('skin')
    CroppedImage = imcrop(Skin,[400 headY*CropSensitivty 2000 headY]);
    figure,imshow(CroppedImage)
    title('Cropped');
    viscircles(centers,radii,'EdgeColor', 'y');

%end

%Image is 0 for black, 1 for white
function [lineIndex] = getYFirstWhiteFromTop(Image)
    % input : I (upright RGB image)
    % output : X, Y image
    sizeImg = size(Image);
    length = sizeImg(1)
    width = sizeImg(2)


    %for each line
    for lineIndex=1:width
        line = Image(lineIndex,:);
        lineSum=sum(line);
        if(lineSum ~= 0)
            break;
        end
    end

end
