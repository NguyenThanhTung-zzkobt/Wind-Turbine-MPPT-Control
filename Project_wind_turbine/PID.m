
U_mean = 14;            % mean wind speed [m/s] 
Iu = 0.12;             % turbulence intensity (sigma/U) 0.08 - 0.20
sigma_u = Iu * U_mean; % std dev of longitudinal turbulence
L = 340;               % turbulence length scale [m] 
Tsim = 600;            % simulation time [s]
dt = 0.05;             % time step [s] 
N = round(Tsim/dt);
fs = 1/dt;
df = fs/N;
omega_r0 =1.5;
R = 40;
beta = 0;
rho = 1.225;
J_r = 4.0e6;   % rotor inertia [kg*m^2]
J_g = 3.0e4;   % generator inertia [kg*m^2]
K_s = 2.0e6;   % shaft stiffness [N*m/rad]
B_s = 1.0e5;   % shaft damping [N*m*s/rad]
omega_n = 0.5;
zeta = 0.7;
Kp = 2 * zeta * omega_n * J_r;
Ki = (omega_n)^2 * J_r;
T_gen_max = 8.0e5;
T_gen_min = 0;
tau_act = 0.05;


omega_rated   = 2.0;        % Rated rotor speed [rad/s]
T_gen_rated   = 5.0e5;      % Rated generator torque [N*m]


T_gen_hyst_on = 0.95 * T_gen_rated;   
T_gen_hyst_off= 0.90 * T_gen_rated;   
omega_hyst_on = 1.02 * omega_rated;  
omega_hyst_off= 0.98 * omega_rated;   


beta_min_deg  = 0;          % Pitch min [deg]
beta_max_deg  = 30;         % Pitch max safe [deg]
beta_rate_max_degps = 4;    % Max pitch rate [deg/s]


lambda_opt = 8.1;
Nsim = 40;


f = (0:N/2)' * df;    

n = f * L / U_mean;
S_kaimal = zeros(size(f));
S_kaimal(1) = 0; 
S_kaimal(2:end) = (sigma_u^2 ./ f(2:end)) .* (4.*n(2:end) ./ (1 + 6.*n(2:end)).^(5/3));

S_full = zeros(N,1);

S_full(1:(N/2+1)) = S_kaimal;        

S_full((N/2+2):end) = flipud(S_kaimal(2:end-1));

rng('shuffle'); 
amp = sqrt(S_full * N * df);  
phases = exp(1i * 2*pi * rand(N,1));
spec = amp .* phases;


spec(1) = 0; )
spec(N/2+1) = real(spec(N/2+1)); 

for k = 2:N/2
    spec(N - k + 2) = conj(spec(k));
end

u = real(ifft(spec));


t = (0:N-1)' * dt;
u = u(1:N);



turb_ts = timeseries(u, t);
wind_total = U_mean + u; 
wind_ts = timeseries(wind_total, t);


disp('Generated wind_ts and turb_ts for Simulink From Workspace block.')

figure; subplot(2,1,1);
plot(t(1:2000), wind_total(1:2000)); xlabel('time (s)'); ylabel('U (m/s)');
title('Example wind (mean + turbulence) - first 100 s');
subplot(2,1,2);
pwelch(u,[],[],[],fs,'onesided');
title('Estimated PSD of generated turbulence (Welch)');
