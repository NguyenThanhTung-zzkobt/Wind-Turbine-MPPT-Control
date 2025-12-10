function net_obj = loadMyNet()
    disp('runMyNet called');
    data = load('NN_PID_Delta.mat', 'net');
    net_obj = data.net;
end