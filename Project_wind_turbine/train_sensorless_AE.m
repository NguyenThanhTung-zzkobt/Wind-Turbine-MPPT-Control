load('AE_MPPT_real_dataset.mat'); 

P_noisy = X_all(:, 2)';         
P_clean = Y_clean(:, 2)';       
w_r     = X_all(:, 3)';        
T_gen   = X_all(:, 4)';         
omega_target = omega_targets';  

[P_norm, ps_P] = mapminmax(P_noisy);
[P_clean_norm, ps_P_clean] = mapminmax(P_clean);
[w_norm, ps_w] = mapminmax(w_r);
[T_norm, ps_T] = mapminmax(T_gen);
[opt_norm, ps_opt] = mapminmax(omega_target);


disp('Training Power Autoencoder...');
ae_net = fitnet([10 5 10], 'trainlm');
ae_net.trainParam.epochs = 200;
[ae_net, tr_ae] = train(ae_net, P_norm, P_clean_norm);


P_features = ae_net(P_norm);


disp('Training Sensorless MPPT...');

mppt_inputs = [P_features; w_norm; T_norm]; 

mppt_net = fitnet([20 15], 'trainlm');
mppt_net.trainParam.epochs = 500;
[mppt_net, tr_mppt] = train(mppt_net, mppt_inputs, opt_norm);


save('Sensorless_AE_Data.mat', 'ae_net', 'mppt_net', ...
     'ps_P', 'ps_P_clean', 'ps_w', 'ps_T', 'ps_opt');
disp('Done! Saved Sensorless_AE_Data.mat');