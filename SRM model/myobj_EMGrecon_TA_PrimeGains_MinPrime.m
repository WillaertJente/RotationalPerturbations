function [f_out] = myobj_EMGrecon_TA_PrimeGains_MinPrime(z,params, muscle)

%MYOBJ is the function you want to minimize 

%Input 
if muscle == 'MG'
    EMG_exp = params.EMG(1,:); 
elseif muscle == 'TA'
    EMG_exp = params.EMG(2,:); 
else
    EMG_exp = params.EMG(3,:);
end

% Gains
ka       = z(1);
kv       = z(2);
kp       = z(3);
ka_p     = z(4);
kv_p     = z(5);
kp_p     = z(6); 

stiction = params.COM(4,:);
aCOM     = params.COM(3,:);     
vCOM     = params.COM(2,:);   
pCOM     = params.COM(1,:);  
e0       =  EMG_exp(1);  

EMG_part1                = ka*-aCOM + kv*-vCOM + kp*-pCOM;   
EMG_part1(EMG_part1 < 0) = 0; 
EMG_part2                = ka_p*aCOM + kv_p*vCOM + kp_p*pCOM; 
EMG_part2(EMG_part2 < 0) = 0; 

EMG_recon = e0 + EMG_part1 + EMG_part2;

% Output 
f_out = (EMG_recon - EMG_exp(11:end-90)).^2; %90
% f_out = sum(f_out);
f_out = sum(f_out) + 1e-4*(ka_p.^2) + 1e-4*(kv_p.^2) + 1e-4*(kp_p.^2);
end

