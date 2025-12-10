FF_Wind_Axis = [11, 12, 13, 14, 15, 16, 17, 18, 20, 22, 24, 25];   % m/s
FF_Pitch_Table = [0, 3.5, 6.0, 8.2, 10.4, 12.3, 14.0, 15.5, 18.2, 20.5, 22.5, 23.5]; % deg


FF_interp = griddedInterpolant(FF_Wind_Axis, FF_Pitch_Table, 'linear', 'nearest'); 


vtest = 14.3;
beta_ff = FF_interp(vtest);

tau_ff = 2.0;
num = 1;
den = [tau_ff 1];  