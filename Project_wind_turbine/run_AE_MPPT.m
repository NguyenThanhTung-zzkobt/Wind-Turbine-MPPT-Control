function w_ref = run_AE_MPPT(inputs)


    persistent autoenc mppt ps_in ps_out ps_omega
    
    if isempty(autoenc)

        data = load('AE_MPPT_Data.mat');
        autoenc  = data.autoenc_net;
        mppt     = data.mppt_net;
        ps_in    = data.ps_in;    
        ps_out   = data.ps_out;   
        ps_omega = data.ps_omega; 
    end
    

    x_norm = mapminmax('apply', inputs, ps_in);
    

    y_clean_norm = autoenc(x_norm);
    

    w_ref_norm = mppt(y_clean_norm);
    

    w_ref = mapminmax('reverse', w_ref_norm, ps_omega);
end