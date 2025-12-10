function w_ref = run_sensorless_AI(inputs)


    persistent ae_net mppt_net ps_P ps_w ps_T ps_opt inited
    
    if isempty(inited)
        data = load('Sensorless_AE_Data.mat');
        ae_net = data.ae_net;
        mppt_net = data.mppt_net;
        ps_P = data.ps_P;
        ps_w = data.ps_w;
        ps_T = data.ps_T;
        ps_opt = data.ps_opt;
        inited = true;
    end
    

    P_in = inputs(1);
    w_in = inputs(2);
    T_in = inputs(3);

    P_norm = mapminmax('apply', P_in, ps_P);
    P_clean = ae_net(P_norm); % Denoised Power
    

    w_norm = mapminmax('apply', w_in, ps_w);
    T_norm = mapminmax('apply', T_in, ps_T);

    mppt_in = [P_clean; w_norm; T_norm];
    
    w_out_norm = mppt_net(mppt_in);

    w_ref = mapminmax('reverse', w_out_norm, ps_opt);
end