
Kp0 = 2.8e6;
Ki0 = 1.0e6;

N = 2000;
omega_r = 1.0 + 1.5*rand(1,N);   
V       = 6 + 8*rand(1,N);       
omega_ref = 1.5 + 0.5*rand(1,N); 

Kp_heuristic = max(1e6, Kp0 + 0.5e6*(V-10) + 1e6*(omega_r-1.8));
Ki_heuristic = max(1e6, Ki0 + 0.3e6*(V-10));


DeltaKp_target = Kp_heuristic - Kp0;
DeltaKi_target = Ki_heuristic - Ki0;


data_in  = [omega_r; V; omega_ref];
data_out = [DeltaKp_target; DeltaKi_target]; 


[data_in_norm, ps_in] = mapminmax(data_in);
[data_out_norm, ps_out] = mapminmax(data_out);


net = fitnet([32 16],'trainlm'); 
net.performParam.regularization = 0.001; 
net.trainParam.epochs = 500;
net.trainParam.goal = 1e-4;


net.divideParam.trainRatio = 0.7;
net.divideParam.valRatio = 0.15;
net.divideParam.testRatio = 0.15;

[net,tr] = train(net, data_in_norm, data_out_norm);


save('NN_PID_Delta.mat','net','ps_in','ps_out');

disp('New Delta-NN trained and saved successfully!');