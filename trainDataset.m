%init deep net
% patternnet([5 10]) would create 2 hidden layers with 5 and 10 neurons
%number of neurons : (Number of inputs + number of outputs) ^ 0.5 + (1 to 10)
nbNeurons = (407 * 8) ^ 0.5;
nbNeurons = nbNeurons - mod(nbNeurons, 10) %nbNeurons end by 0
net = [nbNeurons/10 nbNeurons/10 nbNeurons/10 nbNeurons/5 nbNeurons/5 nbNeurons/10 nbNeurons/10 nbNeurons/10];

layers = [ ...
imageInputLayer([200 200 3])
    convolution2dLayer([5 5],10)
    reluLayer
    fullyConnectedLayer(10)
    softmaxLayer
    classificationLayer];

load('training','trainingInput','trainingOutput')
size(trainingInput)
size(trainingOutput)

options = trainingOptions('sgdm', ...
    'MaxEpochs',20,...
    'InitialLearnRate',1e-4, ...
    'Verbose',false, ...
    'Plots','training-progress');
net=trainNetwork(trainingInput, trainingOutput, layers, options);  

save('net', 'net');
