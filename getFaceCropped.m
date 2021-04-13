function [coloredImage] = getFaceCropped(Image)

    CropSensitivityX = 0.33; %variable found from statistic, allow to crop the image on the head
    CropSensitivityY = 0.30;
    folder = "pictures/";
    
    %save the image as a double variable
    Krgb = double(Image);
    ColorImage = Image;
    
    %get every physic information from the image (size, colors)
    Height = size(Krgb, 1);
    Width = size(Krgb, 2);
    
    if (Height > Width)
     
        %extracting the Red, Green, blue colors of the image into matrices
        Red = Krgb(:, :, 1);
        Green = Krgb(:, :, 2);
        Blue = Krgb(:, :, 3);
     
        %YCbCr colors space
        Kycbcr = rgb2ycbcr(Krgb);
        Y = Kycbcr(:, :, 1); %extracting luminance
        ImageY = Y / 255; %divide by the rgb colors number (255max)
     
        %normalizing Y
        minimumY = min(min(Y));
        maximumY = max(max(Y));
        Y = 255.0 * (Y - minimumY) ./ (maximumY - minimumY); %remember 255
        %average of the luminance
        Yaverage = sum(sum(Y)) / (Width * Height);
     
        T = 0;
        if (Yaverage < 64)
            T = 1.4;
        elseif (Yaverage > 192)
            T = 0.6;
        end
        %adjusting the colors
        if (T ~= 1)
            RI = Red .^ T;
            GI = Green .^ T;
        else
            RI = Red;
            GI = Green;
        end
     
        C = zeros(Height, Width, 3); %new matrix of colors
        C(:, :, 1) = RI;
        C(:, :, 2) = GI;
        C(:, :, 1) = Blue;
     
        %extracting the potential skin
        Kycbcr = rgb2ycbcr(C);
        Cr = Kycbcr(:, :, 3); %Cr : the red materix - Luminance. Cr is a chrominance
     
        Skin = zeros(Height, Width);
        [SkinIndexRow, SkinIndexCol] = find(10 < Cr & Cr < 45);
        for i = 1:length(SkinIndexRow)
            Skin(SkinIndexRow(i), SkinIndexCol(i)) = 1;
        end
     
        %[centers,radii] = imfindcircles(Skin,[10 30],'ObjectPolarity','bright','Sensitivity',0.94);
        [topPointX, topPointY] = getXYFirstWhiteFromTop(Skin);

        CroppedImage = imcrop(Skin, [topPointX - (Width * CropSensitivityX) topPointY topPointX + (Width * CropSensitivityX) topPointY + (Height * CropSensitivityY)]);
        ColorImage = imcrop(ColorImage, [topPointX - (Width * CropSensitivityX) topPointY topPointX + (Width * CropSensitivityX) topPointY + (Height * CropSensitivityY)]);
     
        [Left Right] = getXYTrimremoveNearEmptyLinesOnSide(CroppedImage);
        CroppedImage = CroppedBorder(CroppedImage, Left, Right);
        ColorImage = CroppedBorder(ColorImage, Left, Right);
     
        coloredImage = ColorImage;
    else
        ColorImage = 0;
     
    end
    end
    
    %Image is 0 for black, 1 for white
    function [X, Y] = getXYFirstWhiteFromTop(Image)
    findTopColorSensitivity = 5; %variable to not get lost white point while searching for top of the face
    % input : I (upright RGB image)
    % output : X, Y image
    sizeImg = size(Image);
    length = sizeImg(1);
    width = sizeImg(2);
    
    %for each line
    for lineIndex = 1:width
        line = Image(lineIndex, :);
        lineSum = sum(line);
        if (lineSum > findTopColorSensitivity)
            firstX = 0;
            lastX = 1;
            %now that we have the Y, we search X in the row
            lengthLineSum = size(line);
            lengthLineSum = lengthLineSum(2);
         
            for collumIndex = 1:lengthLineSum
                if (line(collumIndex) == 1)
                    lastX = collumIndex;
                    if (firstX == 0)
                        firstX = collumIndex;
                    end
                end
            end
            break;
        end
    end
    Y = lineIndex;
    X = (firstX + lastX) / 2;
    end
    
    function [XLeft, XRight] = getXYTrimremoveNearEmptyLinesOnSide(Image)
    sizeImg = size(Image);
    lengthImg = sizeImg(1);
    widthImg = sizeImg(2);
    left = 1;
    
    leftIndex = 0;
    rightIndex = 0;
    %find collums extremities
    
    for collumIndex = 1:widthImg
        collum = Image(:, collumIndex);
     
        %Is collum not part of the face?
        if (~ isCollumCorrect(collum, lengthImg))
            if (left == 1)
                leftIndex = collumIndex;
            else
                if (rightIndex == 0)
                    rightIndex = collumIndex;
                end
            end
        else
            rightIndex = 0;
            left = 0;
        end
    end
    
    XLeft = leftIndex;
    XRight = rightIndex;
    end
    
    function [isCorrect] = isCollumCorrect(collum, lengthCol)
    highLimitListMaximum = 3;
    lowLimitListMaximum = 3;
    numberOfLostWhiteBoxMaximum = 10;
    numberOfTotalWhiteBoxMaximum = 20;
    percentageContinuity = 0.5;
    
    numberOfContinuousPixel = percentageContinuity * lengthCol;
    %Does collum have a least 50% continuity black?
    %output : 0 if not part of the face, or 1 if part of the face
    isCorrect = true;
    
    startSearchBlack = lengthCol / 2 - mod(lengthCol / 2, 2);
    numberOfLostWhiteBox = 0;
    lowLimitList = 0;
    highLimitList = 0;
    stopHigh = 0;
    stoplow = 0;
    
    lastHighIndexBeforeWhite = 0;
    lastlowIndexBeforeWhite = 0;
    
    collumSum = sum(collum);
    
    if (collumSum < numberOfTotalWhiteBoxMaximum)
        isCorrect = false;
    end
    
    if (isCorrect == 1)
        foots = lengthCol / 2;
        foots = foots - mod(foots, 2);
     
        for i = 0:(foots) - 1
            highLimit = startSearchBlack + i;
            lowLimit = startSearchBlack - i;
         
            if (collum(highLimit) == 1) %if white
                %we try to see if it is a low number of black box
                highLimitList = highLimitList + 1;
                if (highLimitList > highLimitListMaximum)
                    stopHigh = 1;
                end
            else
                %isGood, reset list
                if (stopHigh == 0)
                    numberOfLostWhiteBox = numberOfLostWhiteBox + highLimitList;
                    highLimitList = 0;
                    lastHighIndexBeforeWhite = highLimit;
                end
            end
         
            if (collum(lowLimit) == 1) %if white
                %we try to see if it is a low number of black box
                lowLimitList = lowLimitList + 1;
                if (lowLimitList > lowLimitListMaximum)
                    stoplow = 1;
                end
            else
                %isGood, reset list
                if (stoplow == 0)
                    numberOfLostWhiteBox = numberOfLostWhiteBox + lowLimitList;
                    lowLimitList = 0;
                    lastlowIndexBeforeWhite = lowLimit;
                end
            end
         
        end
     
        if (numberOfLostWhiteBox > numberOfLostWhiteBoxMaximum)
         
            if (numberOfContinuousPixel < (lastHighIndexBeforeWhite - lastlowIndexBeforeWhite))
                isCorrect = 0;
            end
        end
    end
    end
    function image = CroppedBorder(image, XLeft, XRight)
    
    imageH = size(image, 1);
    imageW = size(image, 2);
    
    if (XRight == 0)
        image = imcrop(image, [XLeft 0 imageW imageH]);
    else
        image = imcrop(image, [XLeft 0 (XRight - XLeft) imageH]);
    end
    
    end
    