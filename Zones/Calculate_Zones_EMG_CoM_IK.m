%% Calculate average per zone
% Ankle angle, CoM en EMG 
% Zones ankle/com = zones EMG - 100 ms 
% Zone 1 = Onset - Onset + 150 ms 
% Zone 2 = onset + 150 ms tot onset + 250 ms
% Zone 3 = onset + 250 ms tot onset + 400 ms
%Updated 8 august 2023

clear all; close all; clc

% Plotting 
color = [229 229 229; 204 204 204; 179 179 179; 242 242 242; 214 214 214; 192 192 192; 153 153 153; 192 192 192]./255; % grijs
color2= [247, 163, 153; 251, 195, 188; 255, 227, 224; 228, 177, 171; 250, 224, 228; 247, 202, 208; 249, 190, 199; 255, 220, 204]./255; % rood
color3= [202, 240, 248; 202, 240, 248; 173, 232, 244; 202, 233, 255; 190, 233, 232; 187, 222, 251; 227, 242, 253; 187, 222, 251]./255; % blauw

colorz1 = [8 103 136]./255;
colorz2 = [240 200 8]./255;
colorz3 = [221 28 26]./255;

%% info
subj      = 'TD9';  % Subject name
selection = [1:8];  % Selected trials
leg = 'r';          % Selected leg (see demographics excel)

%%
for l = [1]       % Levels to analyse    
    figure(l*10)

    %% C3D data 
    c3d   = ['D:\Zenodo\',char(subj),'\C3D/PT_TO_L',num2str(l),'.c3d'];
    onset = xlsread(['D:\Zenodo\',char(subj),'/OnsetPlatform.xlsx'],'TO');
    onset = onset - 10;             
    
     %% CoM Movement
    BKpos = importdata(['D:\Zenodo\',char(subj),'/BK/PT_TO_L',num2str(l),'_BodyKinematics_pos_global.sto']);
    BKvel = importdata(['D:\Zenodo\',char(subj),'/BK/PT_TO_L',num2str(l),'_BodyKinematics_vel_global.sto']);
        
    % Extract COM data
    pCOM_all     = BKpos.data(:,find(strcmp(BKpos.colheaders,'center_of_mass_Z')))- BKpos.data(:,find(strcmp(BKpos.colheaders,'calcn_r_Z')));           % Z or X depending on rotation of IK 
    vCOM_all     = BKvel.data(:,find(strcmp(BKvel.colheaders,'center_of_mass_Z'))) - BKvel.data(:,find(strcmp(BKvel.colheaders,'calcn_r_Z')));
    
    % Calculate acceleration of COM
    [~, ~, NewAcc]  = Calculate_Acceleration_Option3(pCOM_all,BKpos.data(:,1));
    
    x1 = ones(1,21);   y1 = -0.05:0.01:0.15; 
    x2 = ones(1,11);   y2 = -0.5:0.1:0.5; 
    x3 = ones(1,41);   y3 = -2:0.1:2; 

    for t = selection
        posCOM(:,t) = pCOM_all(onset(t,l)-10:onset(t,l)+55)-pCOM_all(onset(t,l)-10);
        velCOM(:,t) = vCOM_all(onset(t,l)-10:onset(t,l)+55);
        accCOM(:,t) = NewAcc(onset(t,l)-10:onset(t,l)+55);
        
        subplot(5,5,2)
        plot(posCOM(:,t),'Color',color(t,:),'LineWidth',1.5); hold on
        line([10 10],[-0.05 0.15],'Color',[0.7 0.7 0.7]); hold on
        plot(x1*15,y1,'--','Color',[0.7 0.7 0.7]); hold on
        plot(x1*25,y1,'--','Color',[0.7 0.7 0.7]); hold on
        plot(x1*40,y1,'--','Color',[0.7 0.7 0.7]); hold on
        title('CoM')
        xticks([0 10 15 25 40]); xticklabels({'-100','0','50','150','300'}); xlim([0 50]); ylim([-0.05 0.05]); box off
        
        subplot(5,5,7)
        plot(velCOM(:,t),'Color',color(t,:),'LineWidth',1.5); hold on
        line([10 10],[-0.5 0.5],'Color',[0.7 0.7 0.7]); hold on
        plot(x2*15,y2,'--','Color',[0.7 0.7 0.7]); hold on
        plot(x2*25,y2,'--','Color',[0.7 0.7 0.7]); hold on
        plot(x2*40,y2,'--','Color',[0.7 0.7 0.7]); hold on
        xticks([0 10 15 25 40]); xticklabels({'-100','0','50','150','300'}); xlim([0 50]); ylim([-0.1 0.1]); box off
        
        subplot(5,5,12)
        plot(accCOM(:,t),'Color',color(t,:),'LineWidth',1.5); hold on
        line([10 10],[-2.5 2.5],'Color',[0.7 0.7 0.7]); hold on
        plot(x3*15,y3,'--','Color',[0.7 0.7 0.7]); hold on
        plot(x3*25,y3,'--','Color',[0.7 0.7 0.7]); hold on
        plot(x3*40,y3,'--','Color',[0.7 0.7 0.7]); hold on
        xticks([0 10 15 25 40]); xticklabels({'-100','0','50','150','300'}); xlim([0 50]); ylim([-2 2]); box off
    end
    
    for s = 1:length(selection)
        posCOM_sel(:,s) = posCOM(:,selection(s));
        velCOM_sel(:,s) = velCOM(:,selection(s));
        accCOM_sel(:,s) = accCOM(:,selection(s));
    end
    
    % Average across all non-stepping trials
    subplot(5,5,2)
    plot(mean(posCOM_sel'),'k','LineWidth',1.5); hold on
    subplot(5,5,7)
    plot(mean(velCOM_sel'),'k','LineWidth',1.5); hold on
    subplot(5,5,12)
    plot(mean(accCOM_sel'),'k','LineWidth',1.5); hold on

    m_posCOM  = mean(posCOM_sel'); m_velCOM = mean(velCOM_sel'); m_accCOM = mean(accCOM_sel'); 

     %% ANKLE Movement
    IKpos = importdata(['D:\Zenodo\',char(subj),'/IK/PT_TO_L',num2str(l),'_filt.mot']);
        
    % Extract IK data
    if leg == 'r'
        pIK_all      = IKpos.data(:,12); %IKpos.data(:,find(strcmp(IKpos.colheaders,'ankle_angle_r')));
    else
        pIK_all      = IKpos.data(:,19);%IKpos.data(:,find(strcmp(IKpos.colheaders,'ankle_angle_l')));
    end

    % Calculate acceleration of COM
    [~, NewVel, NewAcc]  = Calculate_Acceleration_Option3(pIK_all,IKpos.data(:,1));
    
    x1 = ones(1,151);   y1 = -5:0.1:10; 
    x2 = ones(1,451);   y2 = -25:0.1:20; 
    x3 = ones(1,10001); y3 = -500:0.1:500; 

    for t = selection
        posIK(:,t) = pIK_all(onset(t,l)-10:onset(t,l)+55)-pIK_all(onset(t,l)-10);
        velIK(:,t) = NewVel(onset(t,l)-10:onset(t,l)+55);
        accIK(:,t) = NewAcc(onset(t,l)-10:onset(t,l)+55);
        
      
        subplot(5,5,4)
        plot(posIK(:,t),'Color',color(t,:),'LineWidth',1.5); hold on
        line([10 10],[-5 10],'Color',[0.7 0.7 0.7]); hold on
        plot(x1*15,y1,'--','Color',[0.7 0.7 0.7]); hold on
        plot(x1*25,y1,'--','Color',[0.7 0.7 0.7]); hold on
        plot(x1*40,y1,'--','Color',[0.7 0.7 0.7]); hold on
        title('Ankle'); 
        xticks([0 10 15 25 40]); xticklabels({'-100','0','50','150','300'}); xlim([0 50]); ylim([-5 10]); box off
        
        subplot(5,5,9)
        plot(velIK(:,t),'Color',color(t,:),'LineWidth',1.5); hold on
        line([10 10],[-25 20],'Color',[0.7 0.7 0.7]); hold on
        plot(x2*15,y2,'--','Color',[0.7 0.7 0.7]); hold on
        plot(x2*25,y2,'--','Color',[0.7 0.7 0.7]); hold on
        plot(x2*40,y2,'--','Color',[0.7 0.7 0.7]); hold on
         xticks([0 10 15 25 40]); xticklabels({'-100','0','50','150','300'}); xlim([0 50]); ylim([-30 20]); box off
        
        subplot(5,5,14)
        plot(accIK(:,t),'Color',color(t,:),'LineWidth',1.5); hold on
        line([10 10],[-500 500],'Color',[0.7 0.7 0.7]); hold on
        plot(x3*15,y3,'--','Color',[0.7 0.7 0.7]); hold on
        plot(x3*25,y3,'--','Color',[0.7 0.7 0.7]); hold on
        plot(x3*40,y3,'--','Color',[0.7 0.7 0.7]); hold on
        xticks([0 10 15 25 40]); xticklabels({'-100','0','50','150','300'}); xlim([0 50]); ylim([-500 500]); box off
    end
    
    for s = 1:length(selection)
        posIK_sel(:,s) = posIK(:,selection(s));
        velIK_sel(:,s) = velIK(:,selection(s));
        accIK_sel(:,s) = accIK(:,selection(s));
    end
    
    % Average ankle angle across all non-stepping trials
    subplot(5,5,4)
    plot(mean(posIK_sel'),'k','LineWidth',1.5); hold on
    subplot(5,5,9)
    plot(mean(velIK_sel'),'k','LineWidth',1.5); hold on
    subplot(5,5,14)
    plot(mean(accIK_sel'),'k','LineWidth',1.5); hold on

    m_posIK  = mean(posIK_sel'); m_velIK = mean(velIK_sel'); m_accIK = mean(accIK_sel'); 


    %% EMG 
    EMG         = xlsread(['D:\Zenodo\',char(subj),'/EMG/PT_TO_L',num2str(l),'_Filter40.xlsx']);
    scalefactor = xlsread(['D:\Zenodo\',char(subj),'/MaxPerturbations_AcrossLevel.xlsx'],'Totaal');
    
    if leg == 'l'
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
    time = 0.01:0.01:EMG(end,1); 
    sMG_interp_all  = interp1(EMG(:,1),sMG',time);
    sTA_interp_all  = interp1(EMG(:,1),sTA',time);
    sSOL_interp_all = interp1(EMG(:,1),sSOL',time);
    sLG_interp_all  = interp1(EMG(:,1),sLG',time);

    for t = selection
        MG_sel(:,t) = sMG_interp_all(onset(t,l)-10:onset(t,l)+55);
        TA_sel(:,t) = sTA_interp_all(onset(t,l)-10:onset(t,l)+55);
        SOL_sel(:,t)= sSOL_interp_all(onset(t,l)-10:onset(t,l)+55);
        LG_sel(:,t) = sLG_interp_all(onset(t,l)-10:onset(t,l)+55);
        

        subplot(5,5,17)
        plot(MG_sel(:,t),'Color',color(t,:),'LineWidth',1.5); hold on
        line([10 10],[0 0.5],'Color',[0.7 0.7 0.7]); hold on        % Onset platform
        plot([25 25],[0 0.5],'--','Color',[0.7 0.7 0.7]); hold on   % Zone 1 - geen EMG verwacht
        plot([35 35],[0 0.5],'--','Color',[0.7 0.7 0.7]); hold on   % Zone 2 - reflex PF
        plot([50 50],[0 0.5],'--','Color',[0.7 0.7 0.7]); hold on   % Zone 3 - TA 
        title('MG'); ylim([0 0.5]);
        xticks([0 10 25 35 50 ]); xticklabels({'-100','0','150','250','400'}); xlim([0 50]); ylim([0 0.7]); box off
         
        subplot(5,5,18)
        plot(LG_sel(:,t),'Color',color(t,:),'LineWidth',1.5); hold on
        line([10 10],[0 0.5],'Color',[0.7 0.7 0.7]); hold on
        plot([25 25],[0 0.5],'--','Color',[0.7 0.7 0.7]); hold on
        plot([35 35],[0 0.5],'--','Color',[0.7 0.7 0.7]); hold on
        plot([50 50],[0 0.5],'--','Color',[0.7 0.7 0.7]); hold on
        title('LG'); ylim([0 0.5]);  
        xticks([0 10 25 35 50 ]); xticklabels({'-100','0','150','250','400'}); xlim([0 50]); ylim([0 0.7]); box off
        
        subplot(5,5,19)
        plot(SOL_sel(:,t),'Color',color(t,:),'LineWidth',1.5); hold on
        line([10 10],[0 0.5],'Color',[0.7 0.7 0.7]); hold on
        plot([25 25],[0 0.5],'--','Color',[0.7 0.7 0.7]); hold on
        plot([35 35],[0 0.5],'--','Color',[0.7 0.7 0.7]); hold on
        plot([50 50],[0 0.5],'--','Color',[0.7 0.7 0.7]); hold on
        title('SOL'); ylim([0 0.5]); 
        xticks([0 10 25 35 50 ]); xticklabels({'-100','0','150','250','400'}); xlim([0 50]); ylim([ 0 0.7]); box off
        
        subplot(5,5,20)
        plot(TA_sel(:,t),'Color',color(t,:),'LineWidth',1.5); hold on
        line([10 10],[0 0.5],'Color',[0.7 0.7 0.7]); hold on
        plot([25 25],[0 0.5],'--','Color',[0.7 0.7 0.7]); hold on
        plot([35 35],[0 0.5],'--','Color',[0.7 0.7 0.7]); hold on
        plot([50 50],[0 0.5],'--','Color',[0.7 0.7 0.7]); hold on
        title('TA'); ylim([0 0.5]);  
        xticks([0 10 25 35 50 ]); xticklabels({'-100','0','150','250','400'}); xlim([0 50]); ylim([ 0 0.7]); box off 
    end

    for s = 1:length(selection)
        MG_nz(:,s)   = MG_sel(:,selection(s));  % selected trials without zero trials
        LG_nz(:,s)   = LG_sel(:,selection(s));
        SOL_nz(:,s)  = SOL_sel(:,selection(s));
        TA_nz(:,s)   = TA_sel(:,selection(s));
    end
        
        % Average across all non stepping trials
        subplot(5,5,17)
        plot(mean(MG_nz'),'k','LineWidth',1.5); hold on
        subplot(5,5,18)
        plot(mean(LG_nz'),'k','LineWidth',1.5); hold on
        subplot(5,5,19)
        plot(mean(SOL_nz'),'k','LineWidth',1.5); hold on; 
        subplot(5,5,20)
        plot(mean(TA_nz'),'k','LineWidth',1.5); hold on; 
        
        m_MG   = mean(MG_nz'); m_LG = mean(LG_nz'); m_SOL = mean(SOL_nz'); m_TA = mean(TA_nz'); 
        baseline.MG = mean(m_MG(1:10)); baseline.LG = mean(m_LG(1:10)); baseline.SOL = mean(m_SOL(1:10)); baseline.TA = mean(m_TA(1:10)); 

        %% Calculate average for each zone - EMG
        o1.z1_MG  = sum(m_MG(10:25));  o1.z2_MG  = sum(m_MG(25:35));  o1.z3_MG  = sum(m_MG(35:50)); 
        o1.z1_LG  = sum(m_LG(10:25));  o1.z2_LG  = sum(m_LG(25:35));  o1.z3_LG  = sum(m_LG(35:50)); 
        o1.z1_SOL = sum(m_SOL(10:25)); o1.z2_SOL = sum(m_SOL(25:35)); o1.z3_SOL = sum(m_SOL(35:50)); 
        o1.z1_TA  = sum(m_TA(10:25));  o1.z2_TA  = sum(m_TA(25:35));  o1.z3_TA  = sum(m_TA(35:50)); 
  

            subplot(5,5,22)
        bar(1,o1.z1_MG/15-baseline.MG,'FaceColor',colorz1,'EdgeColor',colorz1); hold on
        bar(2,o1.z2_MG/10-baseline.MG,'FaceColor',colorz2,'EdgeColor',colorz2); hold on
        bar(3,o1.z3_MG/15-baseline.MG,'FaceColor',colorz3,'EdgeColor',colorz3); hold on
        xticks([1 2 3]); xticklabels({'Z1','Z2','Z3'}); box off; ylim([0 0.2])
        
       subplot(5,5,23)
        bar(1,o1.z1_LG/15-baseline.LG,'FaceColor',colorz1,'EdgeColor',colorz1); hold on
        bar(2,o1.z2_LG/10-baseline.LG,'FaceColor',colorz2,'EdgeColor',colorz2); hold on
        bar(3,o1.z3_LG/15-baseline.LG,'FaceColor',colorz3,'EdgeColor',colorz3); hold on
        xticks([1 2 3]); xticklabels({'Z1','Z2','Z3'}); box off; ylim([0 0.2])
        
        subplot(5,5,24)
        bar(1,o1.z1_SOL/15-baseline.SOL,'FaceColor',colorz1,'EdgeColor',colorz1); hold on
        bar(2,o1.z2_SOL/10-baseline.SOL,'FaceColor',colorz2,'EdgeColor',colorz2); hold on
        bar(3,o1.z3_SOL/15-baseline.SOL,'FaceColor',colorz3,'EdgeColor',colorz3); hold on
        xticks([1 2 3]); xticklabels({'Z1','Z2','Z3'}); box off; ylim([0 0.2])
        
       subplot(5,5,25)
        bar(1,o1.z1_TA/15-baseline.TA,'FaceColor',colorz1,'EdgeColor',colorz1); hold on
        bar(2,o1.z2_TA/10-baseline.TA,'FaceColor',colorz2,'EdgeColor',colorz2); hold on
        bar(3,o1.z3_TA/15-baseline.TA,'FaceColor',colorz3,'EdgeColor',colorz3); hold on
        xticks([1 2 3]); xticklabels({'Z1','Z2','Z3'}); box off; ylim([0 0.2])
                
        z.z1.MG =o1.z1_MG/15-baseline.MG;    z.z2.MG = o1.z2_MG/10-baseline.MG;    z.z3.MG = o1.z3_MG/15-baseline.MG; 
        z.z1.LG =o1.z1_LG/15-baseline.LG;    z.z2.LG = o1.z2_LG/10-baseline.LG;    z.z3.LG = o1.z3_LG/15-baseline.LG; 
        z.z1.SOL=o1.z1_SOL/15-baseline.SOL;  z.z2.SOL = o1.z2_SOL/10-baseline.SOL; z.z3.SOL = o1.z3_SOL/15-baseline.SOL; 
        z.z1.TA =o1.z1_TA/15-baseline.TA;    z.z2.TA = o1.z2_TA/10-baseline.TA;    z.z3.TA = o1.z3_TA/15-baseline.TA; 

        %% Calculate average for each zone - CoM
        c.z1_p  = sum(m_posCOM(10:15));  c.z2_p  = sum(m_posCOM(15:25));  c.z3_p  = sum(m_posCOM(25:40)); 
        c.z1_v  = sum(m_velCOM(10:15));  c.z2_v  = sum(m_velCOM(15:25));  c.z3_v  = sum(m_velCOM(25:40)); 
        c.z1_a  = sum(m_accCOM(10:15));  c.z2_a  = sum(m_accCOM(15:25)); c.z3_a  = sum(m_accCOM(25:40)); 
  
        subplot(5,5,3)
        bar(1,c.z1_p/5,'FaceColor',colorz1,'EdgeColor',colorz1); hold on
        bar(2,c.z2_p/10,'FaceColor',colorz2,'EdgeColor',colorz2); hold on
        bar(3,c.z3_p/15,'FaceColor',colorz3,'EdgeColor',colorz3); hold on
        title('CoM'); xticks([1 2 3]);xticklabels({'Z1','Z2','Z3'}); box off; ylim([-0.02 0.01])
        
        subplot(5,5,8)
        bar(1,c.z1_v/5,'FaceColor',colorz1,'EdgeColor',colorz1); hold on
        bar(2,c.z2_v/10,'FaceColor',colorz2,'EdgeColor',colorz2); hold on
        bar(3,c.z3_v/15,'FaceColor',colorz3,'EdgeColor',colorz3); hold on
        xticks([1 2 3]); xticklabels({'Z1','Z2','Z3'}); box off; ylim([-0.1 0.1])
        
       subplot(5,5,13)
        bar(1,c.z1_a/5,'FaceColor',colorz1,'EdgeColor',colorz1); hold on
        bar(2,c.z2_a/10,'FaceColor',colorz2,'EdgeColor',colorz2); hold on
        bar(3,c.z3_a/15,'FaceColor',colorz3,'EdgeColor',colorz3); hold on
        xticks([1 2 3]); xticklabels({'Z1','Z2','Z3'}); box off; ylim([-1.5 1])
        
        cc.z1.p =c.z1_p/5;   cc.z2.p = c.z2_p/10;   cc.z3.p = c.z3_p/15; 
        cc.z1.v =c.z1_v/5;   cc.z2.v = c.z2_v/10;   cc.z3.v = c.z3_v/15; 
        cc.z1.a =c.z1_a/5;   cc.z2.a = c.z2_a/10;   cc.z3.a = c.z3_a/15; 
        
        %% Calculate average for each zone - ankle angle
        a.z1_p  = sum(m_posIK(10:15));  a.z2_p  = sum(m_posIK(15:25));  a.z3_p  = sum(m_posIK(25:40)); 
        a.z1_v  = sum(m_velIK(10:15));  a.z2_v  = sum(m_velIK(15:25));  a.z3_v  = sum(m_velIK(25:40)); 
        a.z1_a  = sum(m_accIK(10:15));  a.z2_a  = sum(m_accIK(15:25));  a.z3_a  = sum(m_accIK(25:40)); 
  
        subplot(5,5,5)
        bar(1,a.z1_p/5,'FaceColor',colorz1,'EdgeColor',colorz1); hold on
        bar(2,a.z2_p/10,'FaceColor',colorz2,'EdgeColor',colorz2); hold on
        bar(3,a.z3_p/15,'FaceColor',colorz3,'EdgeColor',colorz3); hold on
        title('Ankle'); xticks([1 2 3]);xticklabels({'Z1','Z2','Z3'}); box off; ylim([0 1.5])
        
        subplot(5,5,10)
        bar(1,a.z1_v/5,'FaceColor',colorz1,'EdgeColor',colorz1); hold on
        bar(2,a.z2_v/10,'FaceColor',colorz2,'EdgeColor',colorz2); hold on
        bar(3,a.z3_v/15,'FaceColor',colorz3,'EdgeColor',colorz3); hold on
        xticks([1 2 3]); xticklabels({'Z1','Z2','Z3'}); box off; ylim([-2 15])
        
        subplot(5,5,15)
        bar(1,a.z1_a/5,'FaceColor',colorz1,'EdgeColor',colorz1); hold on
        bar(2,a.z2_a/10,'FaceColor',colorz2,'EdgeColor',colorz2); hold on
        bar(3,a.z3_a/15,'FaceColor',colorz3,'EdgeColor',colorz3); hold on
        xticks([1 2 3]); xticklabels({'Z1','Z2','Z3'}); box off; ylim([-150 150])
        
        aa.z1.p =a.z1_p/5;   aa.z2.p = a.z2_p/10;   aa.z3.p = a.z3_p/15; 
        aa.z1.v =a.z1_v/5;   aa.z2.v = a.z2_v/10;   aa.z3.v = a.z3_v/15; 
        aa.z1.a =a.z1_a/5;   aa.z2.a = a.z2_a/10;   aa.z3.a = a.z3_a/15; 
    
end