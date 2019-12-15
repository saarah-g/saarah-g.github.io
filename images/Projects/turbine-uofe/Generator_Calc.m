% Generator_Calc
% Generator Design Calculations
% Maurice Rahme - 28/01/2018
clc; clear all;

%% Input Variables --------------------------------------------------------
%Basic
P_turb = 15; % Power generated at Turbine [W]
n_eff = 0.9; % Generator Efficiency 

% Generator Voltage Range (2.1 Battery)
V_batt = 30; % Battery Voltage - according to v.regulator (4V-36V)

% Generator Frequency, Pole Pairs and Coil Number Per Phase (3)
f_nom = 400; % Generator Nominal Frequency [Hz]
n_nom = 6000; % Nominal RPM 

% Generator Axial Dimensions
g = 2/1000; % mechanical clearance gap [m] (1mm for resin over mag, 1mm for resin over coil, 1 mm mechanical gap)
B_r = (1280+1320)/2000; % remanent magnetic flux density [T] - N42 
B_mg = B_r/2; % Magnetic flux density on magnet surface [T] half of B_r
mew_0 = 1.257*10^(-6); % vacuum permeability [Wb/(A*m)]
H_c = 915*10^(15); % corrective field strength [pA/m]
h_m = 5/1000; % permanent magnet thickness/height [m] - see Figure 3 page 8 PDF
rk_sat = 1; % saturation factor =1 since coreless stator

% Generator Winding Dimensions
w_m = 10/1000; % permanent magnet radial width [m]
l_a = 10/1000; % active/magnet length [m] - see Figure 4 page 8 PDF
rk_w = 0.95; % winding coefficient 
n_cutin = 4000; % Cut-in RPM 
C_q = 0.3; % heat coefficient [W/cm^2] - page 9 PDF
rho_cu = 1.72*10^(-8); % Electrical resistivity of Copper [Ohm m]
rk_f = 0.65; % Coil fill factor - between 0.55-0.78 - see page 9 PDF!!!1 IMPORTANT

% Generator Terminal Voltage
L_s = 0; % Generator inductance [mH]
R_c = 0; % Coil Resistance [Ohm]

% Generator Outer Radius (already included)

%% Generator Voltage Range (2.1 Battery) ----------------------------------
P_nom = P_turb*n_eff; % Nominal Generator Power [W]
V_ac = (V_batt+1.4)/(sqrt(3)*1.35);
E_fcutin = V_ac; % Cut-in EMF [V]
E_fnom = E_fcutin*(n_nom/n_cutin); % Nominal EMF [V]

%% Generator Frequency, Pole Pairs and Coil Number Per Phase (3) ----------
p = 120*(f_nom/n_nom); % Number of pole pairs
Q = (3/4)*p; % Total number of coils
q = Q/3; % number of coils per phase 
n_m = (4/3)*Q; % Number of magnets per rotor

%% Generator Axial Dimensions (4) -----------------------------------------
mew_rrec = B_r/(mew_0*H_c); % Recoil Permeability 
%%mew_rrec = 1.05*10^(-6);
%%t_w = 2*(((B_r-B_mg)*h_m)/((mew_rrec*B_mg*rk_sat))-g); % Stator Axial Thickness [m]
%%t_w = 0.1;
t_w = 2*((h_m/(mew_rrec*rk_sat))-g);
%%t_w = ((2*h_m)/(rk_sat*mew_rrec))*((B_r/B_mg)-1)-(2*g);
h_r = h_m;% page 7 of PDF - READ - back iron thickness [m]

%% Generator Winding Dimensions (5) ---------------------------------------
I_acmax = (1.1*P_nom)/(3*E_fnom*n_eff); % Maximum Generator AC current [A]
phi_max = B_mg*w_m*l_a; % Max Magnetic Flux per pole (Wb)
N_c = (sqrt(2)*E_fcutin)/(q*2*pi*rk_w*phi_max*n_cutin*(p/120)); % Number of turns per coil
w_c = (I_acmax*N_c)/sqrt((2*C_q*rk_f*t_w)/rho_cu); % coil leg/side width [m]
s_c = (rk_f*w_c*t_w)/N_c; % Copper cross section [mm^2]
J_max = I_acmax/s_c; % Maximum current density [A/mm^2] - around 6A/mm^2?
d_c = sqrt((4*s_c)/pi); % copper diameter [mm]

%% Generator Terminal Voltage (5) -----------------------------------------
I_rms = I_acmax/sqrt(2); % Generator RMS Current [A]
delta = asin((I_rms*2*pi*f_nom*L_s)/E_fnom);
V_t = E_fnom*cos(delta)-I_rms*q*R_c; % Terminal Voltage [V]

%% Generator Outer Radius (6) ---------------------------------------------
R_in = (((2*Q*w_c)+(p*w_m))/(2*pi))*1000; % Generator Inner Diameter [mm]
R_out = R_in + l_a*1000; % Generator Outer Diameter [mm]

%% Display Results --------------------------------------------------------
Array_Basics = [R_in,R_out,V_t,d_c,s_c,N_c,w_c,n_m,Q,q,h_r,t_w,P_nom,...
                J_max,I_acmax,E_fnom];
Basics = array2table(Array_Basics,'VariableNames',{'Inner_R_mm','Outer_R_mm',...
                      'Terminal_V','Copper_D_mm','Copper_X_Sect_mm2',...
                      'Turns_per_coil','Coil_Leg_Side_Width_m',...
                      'Magnets_per_Rotor','Number_of_Coils',...
                      'Coils_Per_Phase','Back_Iron_Thickness_m',...
                      'Stator_thickness_m','Nominal_Generator_Power',...
                      'Max_Current_Density','Max_AC_Current',...
                      'Nominal_Generator_Voltage'});
disp(Basics)
