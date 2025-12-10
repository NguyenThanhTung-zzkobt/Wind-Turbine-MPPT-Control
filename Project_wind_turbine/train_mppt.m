load('mppt_dataset.mat','X_all','Y_clean','omega_targets','muX','sigX');


V_clean = Y_clean(:,1);
P_clean = Y_clean(:,2);
omega_r = X_all(:,3);


Xin = [V_clean, omega_r, P_clean]';
T = omega_targets'; % 1 x N


muF = mean(Xin,2);
sigF = std(Xin,0,2)+1e-9;
Xin_n = (Xin - muF)./sigF;


hidden = 12;
mppt_net = fitnet(hidden,'trainlm');
mppt_net.trainParam.epochs = 300;
mppt_net.performParam.regularization = 0.01;
[mppt_net, tr] = train(mppt_net, Xin_n, T);

save('mppt_fnn.mat','mppt_net','muF','sigF');