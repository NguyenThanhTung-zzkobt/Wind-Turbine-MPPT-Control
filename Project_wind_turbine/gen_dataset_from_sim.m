modelName = 'pid_testing'; 
outMat = 'AE_MPPT_real_dataset.mat';
dt = 0.05;          
Tsim = 300;         
Nsim = 30;          
rng(1234);           


X_all = [];
Y_clean = [];
omega_targets = [];


extract_sig = @(logs, name, t_query) ...
    interp1(logs.getElement(name).Values.Time, ...       
            double(logs.getElement(name).Values.Data), ... 
            t_query, 'linear', 'extrap');                


for run = 1:Nsim
    fprintf('Sim run %d/%d... ', run, Nsim);
    
    U_mean = 6 + 8*rand();   
    Iu = 0.08 + 0.12*rand(); 
    assignin('base', 'U_mean', U_mean);
    assignin('base', 'Iu', Iu);
    assignin('base', 'Tsim', Tsim);
    assignin('base', 'dt', dt);
    
    sigma_u = Iu * U_mean; L = 340; N = round(Tsim/dt); fs = 1/dt; df = fs/N; f = (0:N/2)' * df;
    n_f = f * L / U_mean;
    S_kaimal = zeros(size(f));
    S_kaimal(2:end) = (sigma_u^2 ./ f(2:end)) .* (4.*n_f(2:end) ./ (1 + 6.*n_f(2:end)).^(5/3));
    S_full = zeros(N,1); S_full(1:(N/2+1)) = S_kaimal; S_full((N/2+2):end) = flipud(S_kaimal(2:end-1));
    amp = sqrt(S_full * N * df); phases = exp(1i * 2*pi * rand(N,1));
    spec = amp .* phases; spec(1) = 0; spec(N/2+1) = real(spec(N/2+1));
    for k = 2:N/2, spec(N - k + 2) = conj(spec(k)); end
    u = real(ifft(spec)); t = (0:N-1)' * dt; u = u(1:N);
    wind_total = U_mean + u;
    wind_ts = timeseries(wind_total, t);
    assignin('base', 'wind_ts', wind_ts);

    assignin('base', 'MPPT_Port', 2); 

    try
        simOut = sim(modelName, 'StopTime', num2str(Tsim), 'SaveOutput', 'on', 'SaveFormat', 'Dataset');
    catch ME
        fprintf('Simulation failed: %s\n', ME.message);
        continue; 
    end
    
    try
        logs = simOut.logsout;
        t_grid = (0:dt:Tsim)'; 

        required_sigs = {'V_wind', 'P_gen', 'w_r', 'T_gen'};
        for k = 1:length(required_sigs)
            if isempty(logs.find(required_sigs{k}))
                error('Signal "%s" not found in logsout! Check Simulink signal name.', required_sigs{k});
            end
        end
        

        V_meas  = extract_sig(logs, 'V_wind', t_grid);
        P_gen   = extract_sig(logs, 'P_gen',  t_grid);
        omega_r = extract_sig(logs, 'w_r',    t_grid);
        T_gen   = extract_sig(logs, 'T_gen',  t_grid);
        

        V_meas = V_meas(:); P_gen = P_gen(:); omega_r = omega_r(:); T_gen = T_gen(:);
        

        P_gen   = max(min(P_gen, 1e7), -1e7);
        T_gen   = max(min(T_gen, 1e6), -1e6); 
        omega_r = max(min(omega_r, 5), 0);   
        

        mask = ~isnan(V_meas) & ~isnan(P_gen) & ~isnan(omega_r) & ~isnan(T_gen);
        
        V_meas = V_meas(mask);
        P_gen  = P_gen(mask);
        omega_r= omega_r(mask);
        T_gen  = T_gen(mask);

        if sum(mask) < (length(t_grid) * 0.5)
            warning('Run %d discarded: Too many NaNs/crashes.', run);
            continue;
        end

        V_filt = smoothdata(V_meas, 'gaussian', 50); 
        lambda_opt = 8.1; R = 40;
        omega_opt = (lambda_opt .* V_filt) ./ R;
        P_filtered = smoothdata(P_gen, 'gaussian', 50);

        X = [V_meas, P_gen, omega_r, T_gen];
        Y = [V_filt, P_filtered];
        
        X_all = [X_all; X];
        Y_clean = [Y_clean; Y];
        omega_targets = [omega_targets; omega_opt];
        
        fprintf('Done (Rows: %d).\n', length(X));
        
    catch ME
        fprintf('Error: %s\n', ME.message);
        return;
    end
end

save(outMat, 'X_all', 'Y_clean', 'omega_targets', 'dt', 'Tsim', 'Nsim');
fprintf('Success! Saved robust dataset to %s\n', outMat);