
load_system('m01_plant_model.slx');
m02_model_parameters;

Ts = 0.001;

% Find the operating point
[X0, U0, Y0] = trim('m01_plant_model');

%
[Ad, Bd, Cd, Dd] = dlinmod('m01_plant_model', Ts, X0, U0);
Pd = ss(Ad, Bd, Cd, Dd, Ts);


save dlinearized_model Pd X0 U0 Y0 
