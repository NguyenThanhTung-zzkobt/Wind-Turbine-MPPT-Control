clearvars; close all; clc;


dataFile = 'AE_MPPT_real_dataset.mat';
fprintf('Loading %s ...\n', dataFile);
S = load(dataFile); 
X_all = S.X_all;    
omega_targets = S.omega_targets;


inputs_raw = X_all(:, 2:4)';  
targets_raw = omega_targets'; 


valid = all(isfinite(inputs_raw),1) & isfinite(targets_raw);
inputs_raw = inputs_raw(:, valid);
targets_raw = targets_raw(:, valid);


N = size(inputs_raw,2);
perm = randperm(N);
inputs_raw = inputs_raw(:,perm);
targets_raw = targets_raw(:,perm);


[inputs_norm, ps_in] = mapminmax(inputs_raw);      
[targets_norm, ps_out] = mapminmax(targets_raw);   

hidden = [24 16]; 
net = fitnet(hidden,'trainlm');
net.trainParam.epochs = 500;
net.trainParam.max_fail = 30;
net.performParam.regularization = 0.02; 
net.divideParam.trainRatio = 0.75;
net.divideParam.valRatio   = 0.15;
net.divideParam.testRatio  = 0.10;

fprintf('Training sensorless net (this may take a minute)...\n');
[net, tr] = train(net, inputs_norm, targets_norm);

% --- Evaluate training quality ---
pred_norm = net(inputs_norm);
pred = mapminmax('reverse', pred_norm, ps_out);
true = mapminmax('reverse', targets_norm, ps_out);
R2 = 1 - sum((true - pred).^2)/sum((true - mean(true)).^2);
fprintf('Training complete. R^2 = %.6f\n', R2);

% --- Export fast prediction function for Simulink ---
fprintf('Generating genFunction outputs (ae not used here)...\n');
genFunction(net, 'sensorless_predict', 'MatrixOnly', 'yes');

% --- Save nets and normalizers ---
save('Sensorless_AI.mat', 'net', 'ps_in', 'ps_out', 'tr');

fprintf('Saved Sensorless_AI.mat and sensorless_predict.m\n');