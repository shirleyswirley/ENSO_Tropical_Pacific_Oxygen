function o2 = calco2frompo2(po2,sal,temp,depth)

%----------------------------------------------------
% Calculate o2 from po2, depth (pressure), salinity, temperature
%----------------------------------------------------
% Vars needed are: po2, sal, temp, depth
% o2 units are ml l^-1 
% po2 units are kPa
% sal units are PSU
% temp units are deg C
% depth units are m

%------------------------
% Define constants
%------------------------
a_0= 2.00907;
a_1= 3.22014;
a_2= 4.05010;
a_3= 4.94457;
a_4= -2.56847e-1;
a_5= 3.88767;
b_0= -6.24523e-3;
b_1= -7.37614e-3;
b_2= -1.03410e-2;
b_3= -8.17083e-3;
c_0= -4.88682e-7;

%------------------------
% Calc temp in diff units
%------------------------
tt = 298.15 - temp;
tk = 273.15 + temp;
ts = log(tt./tk);

%------------------------
% Calculate and correct for pressure at depth
%------------------------
% - Define constants
V = 32e-6; % partial molar volume of O2 (m3/mol)
R = 8.31; % Gas constant [J/mol/K]
db2Pa = 1e4; % convert pressure: decibar to Pascal
atm2Pa=1.01325e5; % convert pressure: atm to Pascal

% - Calculate pressure in db from depth in m
db = depth.*(1.0076+depth.*(2.3487e-6 - depth*1.2887e-11)); 

% - Convert pressure in db to pressure in Pa
dp = db*db2Pa;

% - Correct for pressure at depth
pCor = exp((V*dp)./(R*tk));

%------------------------
% Calculate o2sat and po2
%------------------------
o2sat = exp(a_0 + a_1*ts + a_2*ts.^2 + a_3*ts.^3 + a_4*ts.^4 + a_5*ts.^5 +...
         (b_0 + b_1*ts + b_2*ts.^2 + b_3*ts.^3).*sal +...
          c_0*sal.^2);

o2alpha = (o2sat / 0.21); % 0.21 is atm composition of O2
kh = o2alpha.*pCor;
%po2 = (o2./kh)*101.32501; % convert po2 from atm to kPa  
o2 = (po2.*kh)/101.32501;

