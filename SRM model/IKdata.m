function [f, IK] = IKdata(info, p_full, start)
% Prepare and plot IK (ankle) data
map       = info.map;
cond      = info.cond;
t         = info.t;
selection = info.selection; 
leg       = info.leg; 

% Import IK data 
IKdata = importdata([map,'/IK/PT_',char(cond),'_L',num2str(t),'.mot']);
if leg == 'l'
    ankle_angle = IKdata.data(:,19);
else
    ankle_angle = IKdata.data(:,12);
end

% Position Ankle 
pANKLE_all = ankle_angle;

% Calculate velocity and acceleration
[Filt_pos, Filt_vel, Filt_acc]  = Calculate_Acceleration_AnkleAngle(ankle_angle,IKdata.data(:,1));

vANKLE_all = Filt_vel;
aANKLE_all = Filt_acc;

% Sync IK based on acceleration peak in COM 
for o = selection
    p_ankle(:,o)  = Filt_pos(p_full(o)-100:p_full(o)+200); %100
    v_ankle(:,o)  = vANKLE_all(p_full(o)-100:p_full(o)+200); 
    a_ankle(:,o)  = aANKLE_all(p_full(o)-100:p_full(o)+200);
end

% Plot synct motions of ankle angle 
f = figure(25);
subplot(331)
plot(p_ankle,'LineWidth',1.5); hold on
ylabel('Position ANKLE'); title('Synct perturbations'); box off;
subplot(334)
plot(v_ankle,'LineWidth',1.5); hold on
ylabel('Velocity'); box off;
subplot(337)
plot(a_ankle,'LineWidth',1.5); hold on
ylabel('Acceleration'); box off;

% Plot selection of trials we want to use
figure(25)
subplot(332)
plot(p_ankle(:,selection),'LineWidth',1.5); hold on
box off; ylabel('Position ANKLE'); title('Selected trials')
subplot(335)
plot(v_ankle(:,selection),'LineWidth',1.5); hold on
box off; ylabel('Velocity');
subplot(338)
plot(a_ankle(:,selection),'LineWidth',1.5); hold on
box off; ylabel('Acceleration')

% average of selected trials
m_pAnkle = mean(p_ankle(:,selection)');
m_vAnkle = mean(v_ankle(:,selection)');
m_aAnkle = mean(a_ankle(:,selection)');

% correction for onset value
m_pAnkle_corr = m_pAnkle - m_pAnkle(1);
m_vAnkle_corr = m_vAnkle - m_vAnkle(1);
m_aAnkle_corr = m_aAnkle - m_aAnkle(1);

% Plot corrected average values 
figure(25)
subplot(333)
plot(m_pAnkle_corr,'LineWidth',1.5); hold on
box off; ylabel('Position ANKLE'); title('Corrected mean')
subplot(336)
plot(m_vAnkle_corr,'LineWidth',1.5); hold on
box off; ylabel('Velocity');
subplot(339)
plot(m_aAnkle_corr,'LineWidth',1.5); hold on
box off; ylabel('Acceleration'); 

% Plot onset of movement 
subplot(333)
line([start start],[-10 5],'Color',[0.7 0.7 0.7],'LineWidth',1.5); hold on
subplot(336)
line([start start],[-40 20],'Color',[0.7 0.7 0.7],'LineWidth',1.5); hold on
subplot(339)
line([start start],[-500 500],'Color',[0.7 0.7 0.7],'LineWidth',1.5); hold on

% Select data 
data_pAnkle = m_pAnkle_corr(start-50:end);
data_vAnkle = m_vAnkle_corr(start-50:end);
data_aAnkle = m_aAnkle_corr(start-50:end);

cleaned_p   = data_pAnkle - data_pAnkle(1); 
cleaned_v   = data_vAnkle - data_vAnkle(1); 
cleaned_a   = data_aAnkle - data_aAnkle(1);

IK = [cleaned_p; cleaned_v; cleaned_a];
end

