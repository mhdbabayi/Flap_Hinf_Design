%%
clear
target_model_setup
m03_linearization_script
load dlinearized_model.mat Pd X0 U0 Y0

%% Convert to continuous time

bw_rad = 4;

unitDelay = ss(1/tf('z', Pd.Ts));
opt = d2cOptions('Method', 'tustin', 'PrewarpFrequency', bw_rad);
P = d2c(Pd * unitDelay, opt);
clear opt


%% Design our controller however

om_rad = logspace(-3, 3, 1001) * bw_rad;
bode(P, om_rad)

[mag,~] = bode(P, bw_rad);
Wp = 1/mag;
clear mag;

Wpi = tf([1 bw_rad], [1 0]);
[mag,~] = bode(Wpi, bw_rad);
Wpi = Wpi/mag;
clear mag

Whf = tf(bw_rad * 30, [1  bw_rad * 30])^2;
[mag,~] = bode(Whf, bw_rad);
Whf = Whf/mag;
clear mag

Wo = Wp*Whf*Wpi;

Pw = Wo*P;

[Cinf,~,gam] = ncfsyn(Pw);
Cinf = -Cinf;
fprintf('b(Pw,Cinf) = %0.2f\n', 1/gam)
clear gam

Linf = Pw*Cinf;

C = Cinf*ss(Wo);
C = minreal(C, [], false);
C = balreal(C);

figure(gcf)
clf
bode(P, 'r:', Pw, 'k--', Linf, 'b-', om_rad)
grid on


%% Stop and design prefilter

L = P*C;
T = feedback(L, eye(size(P,1)));
zpk(T)

[z,p,k] = zpkdata(T, 'v'); % 'v' makes it vector not cell

% Find high frequency stuff
threshold = 4*bw_rad; % can play about a bit

idx = abs(z) > threshold;
z_hi = z(idx);
z = z(~idx);

idx = abs(p) > threshold;
p_hi = p(idx);
p = p(~idx);

thisGain = real(prod(-p_hi)/prod(-z_hi));
T_hi = zpk(z_hi, p_hi, prod(-p_hi)/prod(-z_hi));
[num,den] = tfdata(T_hi, 'v');
T_hi = tf(real(num), real(den));
k = k/thisGain;
T_lo = zpk(z, p, k);

clear idx thisGain p_hi z_hi threshold

relDeg = numel(p) - numel(z);
T_lo_ideal = tf(bw_rad, [1 bw_rad]) * tf(20*bw_rad, [1 20*bw_rad])^(relDeg);


Q = ss(minreal(T_lo_ideal/T_lo));


figure(1)
clf
step(T, T_lo, T*Q)













%%




%% Convert back to discrete time.

opt = c2dOptions('Method', 'tustin', 'PrewarpFrequency', bw_rad);
Cd =  unitDelay * c2d(C, Pd.Ts, opt);
Qd = c2d(Q, Pd.Ts, opt);


Cd = balreal(Cd);
tol = 1e-6;
Cd.a(abs(Cd.a)< tol ) = 0;
Cd.b(abs(Cd.b)< tol ) = 0;
Cd.c(abs(Cd.c)< tol ) = 0;

Qd = balreal(Qd);
tol = 1e-6;
Qd.a(abs(Qd.a)< tol ) = 0;
Qd.b(abs(Qd.b)< tol ) = 0;
Qd.c(abs(Qd.c)< tol ) = 0;
Qd.d(abs(Qd.d)< tol ) = 0;


%%

Ld = Pd*Cd;

Td = feedback(Ld, 1);
Sd = 1- Td;
CSd = feedback(Cd, Pd);
SPd = feedback(Pd, Cd);

figure(2)
clf
dom_rad = logspace(log10(om_rad(1)), log10(pi/Pd.Ts), numel(om_rad));
dom_rad = unique(dom_rad);
bodemag(Sd, 'k-', Td, 'b-', CSd, 'k--', dom_rad)
grid on

figure(3)
subplot(211)
step(180*Td*Qd, 'b-', 10/bw_rad)
theseAxes = gca;
subplot(212)
step(180*CSd*Qd, 'k--', 10/bw_rad)
linkaxes([gca theseAxes], 'x')
clear theseAxes

save controller Cd U0 X0 Y0

