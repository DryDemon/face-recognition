%init deep net
% patternnet([5 10]) would create 2 hidden layers with 5 and 10 neurons
%number of neurons : (Number of inputs + number of outputs) ^ 0.5 + (1 to 10)
nbNeurons = (size(filenames,1) * 8) ^ 0.5;
nbNeurons = nbNeurons - mod(nbNeurons, 10) %nbNeurons end by 0
net = patternnet([nbNeurons/10 nbNeurons/10 nbNeurons/10 nbNeurons/5 nbNeurons/5 nbNeurons/10 nbNeurons/10 nbNeurons/10]);

load('training','trainingInput','trainingOutput')

net=train(net, trainingInput, trainingOutput);

save('net', 'net');
