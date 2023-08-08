function [h,COM, time, p_full, start] = COMdata(info)
% Prepare and plot COM data
map  = info.map;
cond = info.cond;
t    = info.t; 
selection = info.selection; 

% Import BK data 
BKpos = importdata([map,'/BK/PT_',char(cond),'_L',num2str(t),'_BodyKinematics_pos_global.sto']);
BKvel = importdata([map,'/BK/PT_',char(cond),'_L',num2str(t),'_BodyKinematics_vel_global.sto']);
BKacc = importdata([map,'/BK/PT_',char(cond),'_L',num2str(t),'_BodyKinematics_acc_global.sto']);
time  = BKpos.data(:,1); 

% Extract COM data 
pCOM_all     = BKpos.data(:,find(strcmp(BKpos.colheaders,'center_of_mass_X'))) - BKpos.data(:,find(strcmp(BKpos.colheaders,'calcn_r_X')));      % X of Z depending on rotation in OpenSim
vCOM_all     = BKvel.data(:,find(strcmp(BKvel.colheaders,'center_of_mass_X'))) - BKvel.data(:,find(strcmp(BKvel.colheaders,'calcn_r_X')));

% Calculate acceleration of COM
[~, ~, NewAcc]  = Calculate_Acceleration_Option3(pCOM_all,BKpos.data(:,1));
aCOM_all        = NewAcc;

% Define ROI for onset
onset = xlsread([map,'/OnsetPlatform.xlsx'],char(cond));
for o = selection; %length(onset(:,t))
    pCOM_ROI(:,o) = pCOM_all(onset(o,t)-100:onset(o,t)+400); %100
    vCOM_ROI(:,o) = vCOM_all(onset(o,t)-100:onset(o,t)+400); %100
    aCOM_ROI(:,o) = aCOM_all(onset(o,t)-100:onset(o,t)+400); %100
end

% Define peak of acceleration signal
[~, p] = max(aCOM_ROI);
for o = selection; 
    p_full(o) = onset(o,t)-100+p(o); 
end

% Sync trials based on piek acceleration
for o = selection
    pCOM(:,o) = pCOM_ROI(p(o)-100:p(o)+200,o); % 100
    vCOM(:,o) = vCOM_ROI(p(o)-100:p(o)+200,o);
    aCOM(:,o) = aCOM_ROI(p(o)-100:p(o)+200,o);
end

h = figure(23); 
subplot(331)
plot(pCOM,'LineWidth',1.5); hold on
box off; ylabel('Position COM'); title('synct perturbations')
subplot(334)
plot(vCOM,'LineWidth',1.5); hold on
box off; ylabel('Velocity');
subplot(337)
plot(aCOM,'LineWidth',1.5); hold on
box off; ylabel('Acceleration')

% Plot selection of trials we want to use
figure(23)
subplot(332)
plot(pCOM(:,selection),'LineWidth',1.5); hold on
box off; ylabel('Position COM'); title('Selected trials')
subplot(335)
plot(vCOM(:,selection),'LineWidth',1.5); hold on
box off; ylabel('Velocity');
subplot(338)
plot(aCOM(:,selection),'LineWidth',1.5); hold on
box off; ylabel('Acceleration')

% average of selected trials
m_pCOM = mean(pCOM(:,selection)');
m_vCOM = mean(vCOM(:,selection)');
m_aCOM = mean(aCOM(:,selection)');

% correction for onset value
m_pCOM_corr = m_pCOM - m_pCOM(1);
m_vCOM_corr = m_vCOM - m_vCOM(1);
m_aCOM_corr = m_aCOM - m_aCOM(1);

figure(23)
subplot(333)
plot(m_pCOM_corr,'LineWidth',1.5); hold on
box off; ylabel('Position COM'); title('Corrected mean')
subplot(336)
plot(m_vCOM_corr,'LineWidth',1.5); hold on
box off; ylabel('Velocity');
subplot(339)
plot(m_aCOM_corr,'LineWidth',1.5); hold on
box off; ylabel('Acceleration'); 

% Define onset
x = 0;
piek = 101;  %101
for i = 1:100 %100
    frame1 = piek-x;
    frame2 = piek-x-1;
    value(i) = m_aCOM_corr(frame1)- m_aCOM_corr(frame2);
    x = x + 1;
end

start_ = find(value<0); 
start  = piek-start_(1); 

if start < 21
    disp('Te weinig data voor onset')
else
end

figure(23)
subplot(333)
line([start start],[-0.05 0.1],'Color',[0.7 0.7 0.7],'LineWidth',1.5); hold on
subplot(336)
line([start start],[-0.2 0.2],'Color',[0.7 0.7 0.7],'LineWidth',1.5); hold on
subplot(339)
line([start start],[-1.8 1.8],'Color',[0.7 0.7 0.7],'LineWidth',1.5); hold on

data_pCOM = m_pCOM_corr(start-50:end);
data_vCOM = m_vCOM_corr(start-50:end);
data_aCOM = m_aCOM_corr(start-50:end);

%Filter acceleration and divide by g
fs = 100;
[B,A]     = butter(4, [10/(fs/2)],'low');
acc_filt = filtfilt(B,A, m_aCOM_corr);
m_aCOM   = acc_filt./9.81;

figure(23)
subplot(339)
plot(m_aCOM,'r','LineWidth',1.5); hold on

COM_ = [data_pCOM; data_vCOM; m_aCOM(start-50:end)]; 
cleaned_p = COM_(1,:) - COM_(1,1) ;
cleaned_v = COM_(2,:) - COM_(2,1) ; 
cleaned_a = COM_(3,:) - COM_(3,1) ; 

COM = [cleaned_p; cleaned_v; cleaned_a];


end

