function [psX, psY, psXin, psOmega] = load_AI_Params()

    data = load('AE_MPPT_real_nets.mat');
    
    psX = data.psX;
    psY = data.psY;
    psXin = data.psXin;
    psOmega = data.psOmega;
end