load('mppt_dataset.mat','X_all','Y_clean');


Xcell = num2cell(X_all',1); 
Ycell = num2cell(Y_clean',1);


inputs = X_all';
targets = Y_clean';

hiddenSize = 8; 
autoenc_net = feedforwardnet([hiddenSize hiddenSize]);
autoenc_net.trainFcn = 'trainlm';
autoenc_net.layers{1}.transferFcn = 'tansig';
autoenc_net.layers{2}.transferFcn = 'tansig';
autoenc_net.layers{3}.transferFcn = 'purelin';

autoenc_net = configure(autoenc_net, inputs, targets);

[autoenc_net, tr] = train(autoenc_net, inputs, targets, 'UseParallel','yes');


save('autoencoder_net.mat','autoenc_net');