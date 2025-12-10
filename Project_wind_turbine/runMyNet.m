function K_deltas = runMyNet(x)

    persistent myLoadedNet ps_in ps_out
    
    if isempty(myLoadedNet)
        data = load('NN_PID_Delta.mat');
        myLoadedNet = data.net;
        ps_in = data.ps_in;
        ps_out = data.ps_out;
    end
    
    x_norm = mapminmax('apply', x, ps_in);
    
    K_norm = myLoadedNet(x_norm);
    

    K_deltas = mapminmax('reverse', K_norm, ps_out);
end