%% Reconstruction of EMG using fmincon - Toe up rotations
% Based on paper of Ting et al. 2014
% Adapted to only minimize prime gains 
% Fmincon with direct collocation 
clear all; close all; clc;

info.subj = {'CP12'};       % Subject number
info.cond = {'TO'};         % Always TO
info.t    = 4               % Perturbation level
info.leg  = 'l';            % Selected leg (see excel demography)
info.map  = ['D:\Zenodo/',char(info.subj)];
info.selection =  [1:8]     % Selected trials 
opt       = 'Test';         % Name to safe results 

%% COM data 
[h, COM, time_COM, p_full, start] = COMdata(info); 
%saveas(h,[info.map,'/Combined plot/EMG_reconstruction_TO/Input/EMG_Reconstruction_',char(info.cond),'_Level',num2str(info.t),'_Inputdata_COM_',opt,'.png']);

%% EMG data
[g, EMG] = EMGdata(info, time_COM, p_full, start); 
%saveas(g,[info.map,'/Combined plot/EMG_reconstruction_TO/Input/EMG_Reconstruction_',char(info.cond),'_Level',num2str(info.t),'_Inputdata_EMG_',opt,'.png']);

%% IK data 
[f, IK] = IKdata(info, p_full, start);
%saveas(f,[info.map,'/Combined plot/EMG_reconstruction_TO/Input/EMG_Reconstruction_',char(info.cond),'_Level',num2str(info.t),'_Inputdata_IK_',opt,'.png']);
 
%% Define stiction based on ankle angle 
new              = IK(1,:)- IK(1,50); 
end_stiction_new = find(new > 0.5);
end_stiction     = end_stiction_new(1) 

COM(4,:) = [COM(3,1:end_stiction) zeros(1,length(COM(3,:))-length(COM(3,1:end_stiction)))]; 
q = figure(26);
plot(COM(3,:),'k','LineWidth',1.5); hold on
plot(COM(4,:),'r','LineWidth',1.5); hold on
line([51 51],[-0.05 0.1],'Color',[0.7 0.7 0.7]); hold on;
box off; title('Stiction based on ankle angle 0.5{\circ}')
%saveas(q,[info.map,'/Combined plot/EMG_reconstruction_TO/Input/EMG_Reconstruction_',char(info.cond),'_Level',num2str(info.t),'_Inputdata_stiction',opt,'.png']);

%% Save input data 
input.COM = COM; input.EMG = EMG; input.IK = IK; 
%save([info.map,'\EMG\EMGreconstruction\TO\Input/','EMG_Reconstruction_',char(info.cond),'_Level',num2str(info.t),'_Inputdata_',opt,'.mat'], 'input'); 

%% Fmincon for MG - With double gains 
% Objective function
muscle      = 'MG'; 
F_hanlde    = @(z)myobj_EMGrecon_PF_PrimeGains_Stiction2_e0_MinPrime(z,input, muscle);

% Options
options     = optimoptions('fmincon','MaxFunctionEvaluations',1000000);

% Initial guess
ig(1:7)     = 0.5;     

% Equality constraints
A = [];     Aeq= [];
B = [];     Beq= [];

% Bounds
Lb(1:7)   = 0;
Ub(1:7)   = 10;

% Simulation
[z, fval ] = fmincon(F_hanlde,ig,A,B,Aeq,Beq,Lb,Ub,[],options);
z_MG       = z;
clear z; clear ig; clear Lb; clear Ub; 

% Recalculation
EMG_part1_MG  = EMG(1,1) + z_MG(1)*COM(3,:) + z_MG(2)*COM(2,:) + z_MG(3)*COM(1,:) + z_MG(7)*COM(4,:);
EMG_part1_MG(EMG_part1_MG <0) = 0;

EMG_part2_MG                = z_MG(4)*-COM(3,:) + z_MG(5)*-COM(2,:) + z_MG(6)*-COM(1,:);   
EMG_part2_MG(EMG_part2_MG < 0) = 0; 

EMG_recon_MG = EMG_part1_MG + EMG_part2_MG; 

%% Fmincon for TA 
muscle    = 'TA'; 
F_hanlde  = @(z)myobj_EMGrecon_TA_PrimeGains_MinPrime(z,input, muscle);

% Options
options   = optimoptions('fmincon','MaxFunctionEvaluations',1000000);

% Initial guess
ig(1:6)                = 0.5;                    % ig(ka)

% Equality constraints
A = [];     Aeq= [];
B = [];     Beq= [];

% Bounds
Lb(1:6)  = 0;                               
Ub(1:6)  = 10;

% Simulation
[z, fval ] = fmincon(F_hanlde,ig,A,B,Aeq,Beq,Lb,Ub,[],options);
z_TA       = z;
clear z; clear ig; clear Lb; clear Ub; 

% Recalculation
EMG_part1_TA  = z_TA(1)*-COM(3,:) + z_TA(2)*-COM(2,:) + z_TA(3)*-COM(1,:);
EMG_part1_TA(EMG_part1_TA <0) = 0;

EMG_part2_TA  = z_TA(4)*COM(3,:) + z_TA(5)*COM(2,:) + z_TA(6)*COM(1,:);   
EMG_part2_TA(EMG_part2_TA < 0) = 0; 

EMG_recon_TA = EMG(2,1) + EMG_part1_TA + EMG_part2_TA; 

%% Fmincon for SOL
% Objective function
muscle = 'SO'; 
F_hanlde       = @(z)myobj_EMGrecon_PF_PrimeGains_Stiction2_e0_MinPrime(z,input, muscle);

% Options
options   = optimoptions('fmincon','MaxFunctionEvaluations',1000000);

% Initial guess
ig(1:7)   = 0.5;     % ig(kas kv kp)

% Equality constraints
A = [];     Aeq= [];
B = [];     Beq= [];

% Bounds
Lb(1:7)   = 0; 
Ub(1:7)   = 10;

% Simulation
[z, fval ] = fmincon(F_hanlde,ig,A,B,Aeq,Beq,Lb,Ub,[],options);
z_SOL       = z;
clear z; clear ig; clear Lb; clear Ub; 

% Recalculation
EMG_part1_SOL  = EMG(3,1) + z_SOL(1)*COM(3,:) + z_SOL(2)*COM(2,:) + z_SOL(3)*COM(1,:) + z_SOL(7)*COM(4,:);
EMG_part1_SOL(EMG_part1_SOL <0) = 0;

EMG_part2_SOL                = z_SOL(4)*-COM(3,:) + z_SOL(5)*-COM(2,:) + z_SOL(6)*-COM(1,:);   
EMG_part2_SOL(EMG_part2_SOL < 0) = 0; 

EMG_recon_SOL =  EMG_part1_SOL + EMG_part2_SOL; 

%% Fmincon for LG
% Objective function
muscle = 'LG'; 
F_hanlde       = @(z)myobj_EMGrecon_PF_PrimeGains_Stiction2_e0_MinPrime(z,input, muscle);

% Options
options   = optimoptions('fmincon','MaxFunctionEvaluations',1000000);

% Initial guess
ig(1:7)   = 0.5;     % ig(kas kv kp)

% Equality constraints
A = [];     Aeq= [];
B = [];     Beq= [];

% Bounds
Lb(1:7)   = 0; 
Ub(1:7)   = 10;

% Simulation
[z, fval ] = fmincon(F_hanlde,ig,A,B,Aeq,Beq,Lb,Ub,[],options);
z_LG       = z;
clear z; clear ig; clear Lb; clear Ub; 

% Recalculation
EMG_part1_LG  = EMG(4,1) + z_LG(1)*COM(3,:) + z_LG(2)*COM(2,:) + z_LG(3)*COM(1,:) + z_LG(7)*COM(4,:);
EMG_part1_LG(EMG_part1_LG <0) = 0;

EMG_part2_LG                = z_LG(4)*-COM(3,:) + z_LG(5)*-COM(2,:) + z_LG(6)*-COM(1,:);   
EMG_part2_LG(EMG_part2_LG < 0) = 0; 

EMG_recon_LG =  EMG_part1_LG + EMG_part2_LG; 

%% Figure
figure(34)
subplot(441)
plot(COM(1,:),'k','LineWidth',1.5); title('Position COM'); box off;
line([51 51],[-0.05 0.1],'Color',[0.7 0.7 0.7]); ylabel('m');xlim([0 200])
subplot(442)
plot(COM(2,:),'k','LineWidth',1.5); title('Velocity COM'); box off;
line([51 51],[-0.2 0.2],'Color',[0.7 0.7 0.7]); ylabel('m/s');xlim([0 200])
subplot(443)
plot(COM(3,:),'k','LineWidth',1.5); hold on
plot(COM(4,:),'Color',[0.7 0.7 0.7],'LineWidth',1.5); title('Stiction'); box off;
line([51 51],[-0.5 0.5],'Color',[0.7 0.7 0.7]); ylabel('g');xlim([0 200])
subplot(444)
plot(IK(1,:),'k','LineWidth',1.5); title('Ankle angle'); box off
line([51 51],[-5 5],'Color',[0.7 0.7 0.7]); ylabel('g');xlim([0 200])

subplot(445)
plot(EMG(4,:),'k','LineWidth',1.5); hold on; 
shifted_lg = [zeros(1,10) EMG_recon_LG]; 
plot(shifted_lg,'r','LineWidth',1.5); hold on
title('LG'); box off; line([51 51],[0 0.5],'Color',[0.7 0.7 0.7]); xlim([0 200])
subplot(446)
plot(EMG(1,:),'k','LineWidth',1.5); hold on
shifted_mg = [zeros(1,10) EMG_recon_MG]; 
plot(shifted_mg,'r','LineWidth',1.5); hold on
title('MG'); box off; line([51 51],[0 0.5],'Color',[0.7 0.7 0.7]); xlim([0 200])
subplot(447)
plot(EMG(3,:),'k','LineWidth',1.5); hold on
shifted_sol = [zeros(1,10) EMG_recon_SOL]; 
plot(shifted_sol,'r','LineWidth',1.5); hold on
title('SOL'); box off ; line([51 51],[0 0.5],'Color',[0.7 0.7 0.7]);xlim([0 200])
subplot(448)
plot(EMG(2,:),'k','LineWidth',1.5); hold on
shifted_ta = [zeros(1,10) EMG_recon_TA]; 
plot(shifted_ta,'r','LineWidth',1.5); hold on
title('TA'); box off ; line([51 51],[0 0.2],'Color',[0.7 0.7 0.7]);xlim([0 200])

subplot(4,4,9)
contr_a = z_LG(1)*COM(3,:); contr_v = z_LG(2)*COM(2,:); contr_p = z_LG(3)*COM(1,:); contr_s = z_LG(7)*COM(4,:);  
plot(contr_a,'Color',[245,203,92]./255,'LineWidth',1.5); hold on
plot(contr_v,'Color',[98,182,203]./255,'LineWidth',1.5); hold on
plot(contr_p,'Color',[125,75,129]./255,'LineWidth',1.5); hold on
plot(contr_s,'Color',[0.7 0.7 0.7],'LineWidth',1.5); hold on
contr_a = z_LG(4)*-COM(3,:); contr_v = z_LG(5)*-COM(2,:); contr_p = z_LG(6)*-COM(1,:); 
plot(contr_a,'--','Color',[245,203,92]./255,'LineWidth',1.5); hold on
plot(contr_v,'--','Color',[98,182,203]./255,'LineWidth',1.5); hold on
plot(contr_p,'--','Color',[125,75,129]./255,'LineWidth',1.5); hold on
title('LG'); box off; line([51 51],[-0.3 0.3],'Color',[0.7 0.7 0.7]);  xlim([0 200])
subplot(4,4,10)
contr_a = z_MG(1)*COM(3,:); contr_v = z_MG(2)*COM(2,:); contr_p = z_MG(3)*COM(1,:); contr_s = z_MG(7)*COM(4,:);  
plot(contr_a,'Color',[245,203,92]./255,'LineWidth',1.5); hold on
plot(contr_v,'Color',[98,182,203]./255,'LineWidth',1.5); hold on
plot(contr_p,'Color',[125,75,129]./255,'LineWidth',1.5); hold on
plot(contr_s,'Color',[0.7 0.7 0.7],'LineWidth',1.5); hold on
contr_a = z_MG(4)*-COM(3,:); contr_v = z_MG(5)*-COM(2,:); contr_p = z_MG(6)*-COM(1,:); 
plot(contr_a,'--','Color',[245,203,92]./255,'LineWidth',1.5); hold on
plot(contr_v,'--','Color',[98,182,203]./255,'LineWidth',1.5); hold on
plot(contr_p,'--','Color',[125,75,129]./255,'LineWidth',1.5); hold on
title('MG'); box off; line([51 51],[-0.3 0.3],'Color',[0.7 0.7 0.7]);  xlim([0 200])
subplot(4,4,11)
contr_a = z_SOL(1)* COM(3,:); contr_v = z_SOL(2)* COM(2,:); contr_p = z_SOL(3)* COM(1,:);contr_s = z_SOL(7)*COM(4,:); 
plot(contr_a,'Color',[245,203,92]./255,'LineWidth',1.5); hold on
plot(contr_v,'Color',[98,182,203]./255,'LineWidth',1.5); hold on
plot(contr_p,'Color',[125,75,129]./255,'LineWidth',1.5); hold on
plot(contr_s,'Color',[0.7 0.7 0.7],'LineWidth',1.5); hold on
contr_a = z_SOL(4)*-COM(3,:); contr_v = z_SOL(5)*-COM(2,:); contr_p = z_SOL(6)*-COM(1,:); 
plot(contr_a,'--','Color',[245,203,92]./255,'LineWidth',1.5); hold on
plot(contr_v,'--','Color',[98,182,203]./255,'LineWidth',1.5); hold on
plot(contr_p,'--','Color',[125,75,129]./255,'LineWidth',1.5); hold on
title('SOL'); box off; line([51 51],[-0.3 0.3],'Color',[0.7 0.7 0.7]);  xlim([0 200])
subplot(4,4,12)
contr_a = z_TA(1)*-COM(3,:); contr_v = z_TA(2)*-COM(2,:); contr_p = z_TA(3)*-COM(1,:);
plot(contr_a,'Color',[245,203,92]./255,'LineWidth',1.5); hold on
plot(contr_v,'Color',[98,182,203]./255,'LineWidth',1.5); hold on
plot(contr_p,'Color',[125,75,129]./255,'LineWidth',1.5); hold on
contr_a = z_TA(4)*COM(3,:); contr_v = z_TA(5)*COM(2,:); contr_p = z_TA(6)*COM(1,:);
plot(contr_a,'--','Color',[245,203,92]./255,'LineWidth',1.5); hold on
plot(contr_v,'--','Color',[98,182,203]./255,'LineWidth',1.5); hold on
plot(contr_p,'--','Color',[125,75,129]./255,'LineWidth',1.5); hold on
title('TA'); box off; line([51 51],[-0.3 0.3], 'Color',[0.7 0.7 0.7]); xlim([0 200])
  
subplot(4,4,13)
bar(1,z_LG(1),'FaceColor',[245,203,92]./255,'EdgeColor',[245,203,92]./255); hold on
bar(2,z_LG(2),'FaceColor',[98,182,203]./255,'EdgeColor',[98,182,203]./255); hold on
bar(3,z_LG(3),'FaceColor',[98,182,203]./255,'EdgeColor',[98,182,203]./255); hold on
bar(4,z_LG(4),'FaceColor',[245,203,92]./255,'EdgeColor',[245,203,92]./255); hold on
bar(5,z_LG(5),'FaceColor',[98,182,203]./255,'EdgeColor',[98,182,203]./255); hold on
bar(6,z_LG(6),'FaceColor',[98,182,203]./255,'EdgeColor',[98,182,203]./255); hold on
bar(7,z_LG(7),'FaceColor',[0.7 0.7 0.7]./255,'EdgeColor',[0.7 0.7 0.7]./255); hold on
axis([0 8 0 5]); box off; xticks([1 2 3 4 5 6 7]); xticklabels({'kA','kV','kP','kAp','kVp','kPp','kS'})

subplot(4,4,14)
bar(1,z_MG(1),'FaceColor',[245,203,92]./255,'EdgeColor',[245,203,92]./255); hold on
bar(2,z_MG(2),'FaceColor',[98,182,203]./255,'EdgeColor',[98,182,203]./255); hold on
bar(3,z_MG(3),'FaceColor',[125,75,129]./255,'EdgeColor',[125,75,129]./255); hold on
bar(4,z_MG(4),'FaceColor',[245,203,92]./255,'EdgeColor',[245,203,92]./255); hold on
bar(5,z_MG(5),'FaceColor',[98,182,203]./255,'EdgeColor',[98,182,203]./255); hold on
bar(6,z_MG(6),'FaceColor',[125,75,129]./255,'EdgeColor',[125,75,129]./255); hold on
bar(7,z_MG(7),'FaceColor',[0.7 0.7 0.7]./255,'EdgeColor',[0.7 0.7 0.7]./255); hold on
axis([0 8 0 5]); box off; xticks([1 2 3 4 5 6 7]); xticklabels({'kA','kV','kP','kAp','kVp','kPp','kS'})

subplot(4,4,16)
bar(1,z_TA(1),'FaceColor',[245,203,92]./255,'EdgeColor',[245,203,92]./255); hold on
bar(2,z_TA(2),'FaceColor',[98,182,203]./255,'EdgeColor',[98,182,203]./255); hold on
bar(3,z_TA(3),'FaceColor',[125,75,129]./255,'EdgeColor',[125,75,129]./255); hold on
bar(4,z_TA(4),'FaceColor',[245,203,92]./255,'EdgeColor',[245,203,92]./255); hold on
bar(5,z_TA(5),'FaceColor',[98,182,203]./255,'EdgeColor',[98,182,203]./255); hold on
bar(6,z_TA(6),'FaceColor',[125,75,129]./255,'EdgeColor',[125,75,129]./255); hold on
axis([0 8 0 5]); box off; xticks([1 2 3 4 5 6 7]); xticklabels({'kA','kV','kP','kAp','kVp','kPp'})

subplot(4,4,15)
bar(1,z_SOL(1),'FaceColor',[245,203,92]./255,'EdgeColor',[245,203,92]./255); hold on
bar(2,z_SOL(2),'FaceColor',[98,182,203]./255,'EdgeColor',[98,182,203]./255); hold on
bar(3,z_SOL(3),'FaceColor',[125,75,129]./255,'EdgeColor',[125,75,129]./255); hold on
bar(4,z_SOL(4),'FaceColor',[245,203,92]./255,'EdgeColor',[245,203,92]./255); hold on
bar(5,z_SOL(5),'FaceColor',[98,182,203]./255,'EdgeColor',[98,182,203]./255); hold on
bar(6,z_SOL(6),'FaceColor',[125,75,129]./255,'EdgeColor',[125,75,129]./255); hold on
bar(7,z_SOL(7),'FaceColor',[0.7 0.7 0.7]./255,'EdgeColor',[0.7 0.7 0.7]./255); hold on
axis([0 8 0 5]); box off; xticks([1 2 3 4 5 6]); xticklabels({'kA','kV','kP','kAp','kVp','kPp','kS'})


sgtitle([char(info.cond), '  Level', num2str(info.t)])
%saveas(gcf,[info.map,'/Combined Plot/EMG_reconstruction_TO/Output/EMG_Reconstruction_',char(info.cond),'_Level',num2str(info.t),'_Solution_',opt,'.png'])

%% Output
output.LG = z_LG; output.MG = z_MG; output.SOL = z_SOL; output.TA = z_TA; 
output.shifted_LG = shifted_lg; output.shifted_MG = shifted_mg; output.shifted_SOL = shifted_sol; output.shifted_TA = shifted_ta; 
