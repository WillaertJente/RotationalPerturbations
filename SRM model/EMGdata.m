function [g,EMG] = EMGdata(info, time_COM, p_full, start)
% Prepare and plot EMG data 
map  = info.map; 
cond = info.cond; 
t    = info.t;
selection = info.selection; 

% Import and scale EMG 
EMG         = xlsread([map,'/EMG/PT_',char(cond),'_L',num2str(t),'_Filter40.xlsx']);
scalefactor = xlsread([map,'/MaxPerturbations_AcrossLevel.xlsx'],'Totaal');

if info.leg == 'l'
    MG   = EMG(:,8); TA = EMG(:,10); SOL = EMG(:,9); LG = EMG(:,7);
    sMG  = MG./scalefactor(7);
    sSOL = SOL./scalefactor(8);
    sTA  = TA./scalefactor(9);
    sLG  = LG./scalefactor(6); 
    
else
    MG   = EMG(:,3);  TA = EMG(:,5); SOL = EMG(:,4); LG = EMG(:,2); 
    sMG  = MG./scalefactor(2);
    sSOL = SOL./scalefactor(3);
    sTA  = TA./scalefactor(4);
    sLG  = LG./scalefactor(1); 
end

% Interpoleer EMG to COM data 
sMG_interp_all  = interp1(EMG(:,1),sMG',time_COM);
sTA_interp_all  = interp1(EMG(:,1),sTA',time_COM);
sSOL_interp_all = interp1(EMG(:,1),sSOL',time_COM);
sLG_interp_all  = interp1(EMG(:,1),sLG',time_COM); 

% Sync EMG with peak acceleration COM and include 100 ms  
for o = selection
    synct_MG(:,o)  = sMG_interp_all(p_full(o)-100:p_full(o)+300); % delay included % 100
    synct_TA(:,o)  = sTA_interp_all(p_full(o)-100:p_full(o)+300); % delay included
    synct_SOL(:,o) = sSOL_interp_all(p_full(o)-100:p_full(o)+300); % delay included
    synct_LG(:,o)  = sLG_interp_all(p_full(o)-100:p_full(o)+300); % delay included
end

% figure
g = figure(24); 
subplot(431)
plot(synct_MG,'LineWidth',1.5); hold on
box off; title('Synct EMG'); ylabel('MG'); 
subplot(434)
plot(synct_TA,'LineWidth',1.5); hold on
box off; ylabel('TA'); 
subplot(437)
plot(synct_SOL,'LineWidth',1.5); hold on
box off; ylabel('SOL'); 
subplot(4,3,10)
plot(synct_LG,'LineWidth',1.5); hold on
box off; ylabel('LG'); 

% Plot selection trials 
figure(24); 
subplot(432)
plot(synct_MG(:,selection),'LineWidth',1.5); hold on
box off; title('Selected trials'); ylabel('MG'); 
subplot(435)
plot(synct_TA(:,selection),'LineWidth',1.5); hold on
box off; ylabel('TA'); 
subplot(438)
plot(synct_SOL(:,selection),'LineWidth',1.5); hold on
box off; ylabel('SOL'); 
subplot(4,3,11)
plot(synct_LG(:,selection),'LineWidth',1.5); hold on
box off; ylabel('LG'); 

% Calculate mean EMG signal of selected trials 
m_MG  = mean(synct_MG(:,selection)');
m_TA  = mean(synct_TA(:,selection)');
m_SOL = mean(synct_SOL(:,selection)');
m_LG  = mean(synct_LG(:,selection)'); 

% Plot mean data 
figure(24)
subplot(433)
plot(m_MG,'LineWidth',1.5); hold on
box off; title('Mean signal'); ylabel('MG')
subplot(436)
plot(m_TA,'LineWidth',1.5); hold on
box off; ylabel('TA')
subplot(439)
plot(m_SOL,'LineWidth',1.5); hold on
box off; ylabel('SOL')
subplot(4,3,12)
plot(m_LG,'LineWidth',1.5); hold on
box off; ylabel('LG')

% Selected data such as acceleration
m_MG_sel  = m_MG(start-50:end);
m_TA_sel  = m_TA(start-50:end);
m_SOL_sel = m_SOL(start-50:end);
m_LG_sel  = m_LG(start-50:end); 

% plot onset op figuur
figure(24)
subplot(433)
line([start start],[0 0.1],'Color',[0.7 0.7 0.7],'LineWidth',1.5); hold on
subplot(436)
line([start start],[0 0.1],'Color',[0.7 0.7 0.7],'LineWidth',1.5); hold on
subplot(439)
line([start start],[0 0.1],'Color',[0.7 0.7 0.7],'LineWidth',1.5); hold on
subplot(4,3,12)
line([start start],[0 0.1],'Color',[0.7 0.7 0.7],'LineWidth',1.5); hold on

EMG = [m_MG_sel; m_TA_sel; m_SOL_sel; m_LG_sel];
end

