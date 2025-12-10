
disp('Loading real dataset...');
load('AE_MPPT_real_dataset.mat'); 


inputs  = X_all';       % [V; P; w; T] (4 x N)
targets_ae = Y_clean';  % [V_filt; P_filt] (2 x N)
targets_mppt = omega_targets'; % [w_opt] (1 x N)

N = size(inputs, 2);
perm = randperm(N);
inputs = inputs(:, perm);
targets_ae = targets_ae(:, perm);
targets_mppt = targets_mppt(:, perm);


[X_norm, psX] = mapminmax(inputs);
[Y_norm, psY] = mapminmax(targets_ae);
[omega_norm, psOmega] = mapminmax(targets_mppt);


disp('Training Autoencoder...');

hiddenSize = 10;
ae_net = fitnet([20 10 20], 'trainlm'); 
ae_net.trainParam.epochs = 300;
ae_net.trainParam.showWindow = true;
[ae_net, tr_ae] = train(ae_net, X_norm, Y_norm);


genFunction(ae_net, 'ae_predict', 'MatrixOnly', 'yes');


Y_ae_norm = ae_net(X_norm);

disp('Training MPPT Network...');

Xin = [Y_ae_norm; X_norm(3:4, :)]; 
[Xin_norm, psXin] = mapminmax(Xin);

mppt_net = fitnet([16 12], 'trainlm');
mppt_net.trainParam.epochs = 500;
[mppt_net, tr_mppt] = train(mppt_net, Xin_norm, omega_norm);


genFunction(mppt_net, 'mppt_predict', 'MatrixOnly', 'yes');


save('AE_MPPT_real_nets.mat', 'psX', 'psY', 'psOmega', 'psXin');
disp('Done! Created ae_predict.m, mppt_predict.m, and saved params.');